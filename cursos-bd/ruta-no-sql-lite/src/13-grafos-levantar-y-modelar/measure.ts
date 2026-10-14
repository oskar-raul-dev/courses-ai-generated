// La directiva que llega un jueves, en sus tres preguntas, contra el grafo (Neo4j) y contra el esquema
// relacional de la Fase 01 (Postgres): en qué aeronaves estuvo alguna vez una pieza del lote, qué se
// desmontó junto con ella, y qué piezas compartieron aeronave con ella mientras estuvo instalada.
// Las dos primeras se comprueban contra answers.json; la tercera, comparando los dos motores.
//
//   node 13-grafos-levantar-y-modelar/measure.ts [--dataset lab/data/workOrder-1m]   (desde src/)
import { readFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { parseArgs } from "node:util";
import neo4j from "neo4j-driver";
import pg from "pg";
import { explain } from "../lab/harness/explain.ts";
import { profile } from "../lab/harness/neo4j-profile.ts";

const { values: args } = parseArgs({ options: { dataset: { type: "string", default: "lab/data/workOrder-1m" } } });
const answers = JSON.parse(readFileSync(join(resolve(args.dataset!), "answers.json"), "utf8")).directiveLot;
const LOT = answers.lotNumber as string;

const driver = neo4j.driver(`bolt://localhost:${process.env.GRAFOS_BOLT_PORT ?? 17687}`, neo4j.auth.basic("neo4j", "condor-mro"));
const session = driver.session();
const db = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "postgres" });
await db.connect();

// las estadías en SQL: no están guardadas, se derivan de los movimientos con una ventana por pieza
const STINTS = `stints AS (
  SELECT serial_number, aircraft,
         CASE WHEN kind = 'installed' THEN opened_at END AS from_ts,
         CASE WHEN kind = 'removed' THEN opened_at
              WHEN next_kind = 'removed' THEN next_at END AS to_ts
  FROM (SELECT m.serial_number, m.kind, wo.aircraft, wo.opened_at,
               lead(m.kind) OVER w AS next_kind, lead(wo.opened_at) OVER w AS next_at,
               lag(m.kind) OVER w AS prev_kind
        FROM work_order_movement m JOIN work_order wo USING (work_order_id)
        WINDOW w AS (PARTITION BY m.serial_number ORDER BY wo.opened_at, m.kind DESC)) x
  -- una estadía empieza en una instalación, o en un retiro sin instalación previa (estaba desde antes)
  WHERE kind = 'installed' OR prev_kind IS DISTINCT FROM 'installed'
  UNION ALL
  -- las piezas que nunca se movieron siguen donde empezaron
  SELECT p.serial_number, p.aircraft, NULL, NULL FROM part p
  WHERE p.aircraft IS NOT NULL AND NOT EXISTS (SELECT 1 FROM work_order_movement m WHERE m.serial_number = p.serial_number))`;

const QUESTIONS = [
  {
    name: "1 · aeronaves donde estuvo alguna pieza del lote",
    expected: (answers.aircraftEverInstalled as string[]).length,
    cypher: "MATCH (p:Part {lotNumber: $lot})-[:INSTALLED]->(a:Aircraft) RETURN count(DISTINCT a) AS n",
    sql: `WITH ${STINTS} SELECT count(DISTINCT s.aircraft) AS n FROM stints s JOIN part p USING (serial_number) WHERE p.lot_number = $1`,
    // la misma pregunta, como la escribiría alguien que conoce el esquema: sin derivar estadías
    sqlDirect: `SELECT count(DISTINCT aircraft) AS n FROM (
      SELECT wo.aircraft FROM part p JOIN work_order_movement m USING (serial_number) JOIN work_order wo USING (work_order_id) WHERE p.lot_number = $1
      UNION ALL SELECT aircraft FROM part WHERE lot_number = $1 AND aircraft IS NOT NULL) x`,
  },
  {
    name: "2 · retiros de una pieza del lote, con lo que salió en la misma orden",
    expected: (answers.removedTogether as unknown[]).length,
    cypher: `MATCH (p:Part {lotNumber: $lot})-[:REMOVED_IN]->(w:WorkOrder)
      OPTIONAL MATCH (w)<-[:REMOVED_IN]-(o:Part) WHERE o <> p
      WITH p, w, collect(o.serialNumber) AS others RETURN count(*) AS n`,
    sql: `SELECT count(*) AS n FROM (SELECT m.serial_number, m.work_order_id, array_agg(o.serial_number) FILTER (WHERE o.serial_number IS NOT NULL)
      FROM part p JOIN work_order_movement m ON m.serial_number = p.serial_number AND m.kind = 'removed'
      LEFT JOIN work_order_movement o ON o.work_order_id = m.work_order_id AND o.kind = 'removed' AND o.serial_number <> m.serial_number
      WHERE p.lot_number = $1 GROUP BY 1, 2) x`,
  },
  {
    name: "3 · piezas que compartieron aeronave con una del lote, al mismo tiempo",
    expected: null,
    cypher: `MATCH (p:Part {lotNumber: $lot})-[s:INSTALLED]->(a:Aircraft)<-[t:INSTALLED]-(o:Part)
      WHERE o <> p AND coalesce(s.from, datetime('2000-01-01')) < coalesce(t.to, datetime('2100-01-01'))
        AND coalesce(t.from, datetime('2000-01-01')) < coalesce(s.to, datetime('2100-01-01'))
      RETURN count(DISTINCT o) AS n`,
    sql: `WITH ${STINTS}
      SELECT count(DISTINCT o.serial_number) AS n FROM stints s JOIN part p USING (serial_number)
      JOIN stints o ON o.aircraft = s.aircraft AND o.serial_number <> s.serial_number
       AND coalesce(s.from_ts, '2000-01-01') < coalesce(o.to_ts, '2100-01-01') AND coalesce(o.from_ts, '2000-01-01') < coalesce(s.to_ts, '2100-01-01')
      WHERE p.lot_number = $1`,
  },
];

// la línea base bien jugada: las estadías guardadas en una tabla con índices, como las guarda el grafo
const STINT_TABLE = `DROP TABLE IF EXISTS part_stint;
  CREATE TABLE part_stint AS WITH ${STINTS} SELECT * FROM stints;
  CREATE INDEX ON part_stint (serial_number); CREATE INDEX ON part_stint (aircraft); ANALYZE part_stint;`;
const Q3_TABLE = `SELECT count(DISTINCT o.serial_number) AS n FROM part_stint s JOIN part p USING (serial_number)
  JOIN part_stint o ON o.aircraft = s.aircraft AND o.serial_number <> s.serial_number
   AND coalesce(s.from_ts, '2000-01-01') < coalesce(o.to_ts, '2100-01-01') AND coalesce(o.from_ts, '2000-01-01') < coalesce(s.to_ts, '2100-01-01')
  WHERE p.lot_number = $1`;

try {
  console.log(`lote ${LOT} · ${(answers.serials as string[]).length} piezas`);
  for (const q of QUESTIONS) {
    const g = await profile(session, q.cypher, { lot: LOT });
    const gn = (g.records[0] as { n: { toNumber(): number } }).n.toNumber();
    const p = await explain(db, q.sql, [LOT]);
    const pn = Number((await db.query(q.sql, [LOT])).rows[0].n);
    console.log(`\n${q.name}${q.expected !== null ? ` · answers.json: ${q.expected}` : ""}`);
    console.log(`  neo4j     resultado ${String(gn).padStart(7)} · db hits ${String(g.dbHits).padStart(9)} · filas máx. ${String(g.maxRows).padStart(7)}`);
    console.log(`  postgres  resultado ${String(pn).padStart(7)} · examinadas ${String(p.examined).padStart(9)} · páginas ${String(p.sharedHit + p.sharedRead).padStart(7)}`);
    if (q.sqlDirect) {
      const d = await explain(db, q.sqlDirect, [LOT]);
      const dn = Number((await db.query(q.sqlDirect, [LOT])).rows[0].n);
      console.log(`  postgres, sin derivar estadías: resultado ${dn} · examinadas ${d.examined} · páginas ${d.sharedHit + d.sharedRead}`);
    }
  }
  const t = performance.now();
  await db.query(STINT_TABLE);
  const { rows } = await db.query("SELECT count(*) AS n, pg_size_pretty(pg_total_relation_size('part_stint')) AS size FROM part_stint");
  const d = await explain(db, Q3_TABLE, [LOT]);
  const dn = Number((await db.query(Q3_TABLE, [LOT])).rows[0].n);
  console.log(`\n3 · con part_stint (${rows[0].n} estadías, ${rows[0].size}, ${((performance.now() - t) / 1000).toFixed(1)} s en crearla)`);
  console.log(`  postgres  resultado ${String(dn).padStart(7)} · examinadas ${String(d.examined).padStart(9)} · páginas ${String(d.sharedHit + d.sharedRead).padStart(7)}`);
} finally {
  await session.close();
  await driver.close();
  await db.end();
}
