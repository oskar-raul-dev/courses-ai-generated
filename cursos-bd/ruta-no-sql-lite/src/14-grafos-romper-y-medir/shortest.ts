// Se sube la apuesta: no alcanzar nodos, sino devolver EL CAMINO. ¿Por qué cadena de estadías se llega de
// una pieza del lote a la aeronave más lejana que alcanza? En Neo4j, SHORTEST 1. En Postgres, de dos
// formas: arrastrando el camino en un arreglo (vuelve a enumerar caminos) o con niveles de UNION y la
// reconstrucción hacia atrás desde la aplicación, un viaje por salto.
//
//   node 14-grafos-romper-y-medir/shortest.ts [--timeout 120]   (desde src/, después de edges.sql)
import { readFileSync } from "node:fs";
import { parseArgs } from "node:util";
import neo4j from "neo4j-driver";
import pg from "pg";
import { profile } from "../lab/harness/neo4j-profile.ts";
import { explain } from "../lab/harness/explain.ts";

const { values: args } = parseArgs({ options: { timeout: { type: "string", default: "120" } } });
const driver = neo4j.driver(`bolt://localhost:${process.env.GRAFOS_BOLT_PORT ?? 17687}`, neo4j.auth.basic("neo4j", "condor-mro"));
const session = driver.session();
const db = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "postgres" });
await db.connect();
await db.query(`SET statement_timeout = '${args.timeout}s'`);
let trips = 0;
const q = async (sql: string, params: unknown[] = []) => { trips++; return db.query(sql, params); };

const serial: string = JSON.parse(readFileSync("lab/data/workOrder-1m/answers.json", "utf8")).directiveLot.serials[0];
const start = `part:${serial}`;
try {
  // el destino: la aeronave más lejana a la que llega (la primera por nombre, entre las más lejanas)
  const levels = `WITH RECURSIVE t(node, depth) AS (SELECT $1::text, 0 UNION
      SELECT e.dst, t.depth + 1 FROM t JOIN stint_edge e ON e.src = t.node WHERE t.depth < 12)
    SELECT node, min(depth) AS depth FROM t GROUP BY node`;
  const { rows } = await db.query(`${levels.replace("SELECT node, min(depth)", "SELECT node, min(depth)")}`, [start]);
  const far = rows.filter((r) => r.node.startsWith("aircraft:")).sort((a, b) => b.depth - a.depth || a.node.localeCompare(b.node))[0];
  const target = far.node.slice("aircraft:".length);
  console.log(`desde ${serial} hasta ${target}: ${far.depth} saltos (la más lejana de ${rows.length - 1} nodos alcanzables)`);

  // Neo4j: un camino más corto, devuelto entero
  const g = await profile(session, `MATCH p = SHORTEST 1 (a:Part {serialNumber: $s})-[:INSTALLED]-+(b:Aircraft {registration: $r})
    RETURN length(p) AS len, [n IN nodes(p) | coalesce(n.serialNumber, n.registration)] AS path`, { s: serial, r: target });
  const rec = g.records[0] as { len: { toNumber(): number }; path: string[] };
  console.log(`neo4j    · ${rec.len.toNumber()} saltos · ${g.dbHits} db hits · 1 viaje · ${rec.path.join(" → ")}`);

  // Postgres A: el camino en un arreglo, sin repetir nodos dentro del camino
  const arraySql = `WITH RECURSIVE t(node, path) AS (SELECT $1::text, ARRAY[$1::text] UNION ALL
      SELECT e.dst, t.path || e.dst FROM t JOIN stint_edge e ON e.src = t.node
      WHERE NOT e.dst = ANY(t.path) AND cardinality(t.path) <= ${far.depth})
    SELECT path FROM t WHERE node = $2 ORDER BY cardinality(path) LIMIT 1`;
  try {
    const e = await explain(db, arraySql, [start, far.node]);
    console.log(`postgres · arreglo: ${e.examined} filas examinadas · 1 viaje`);
  } catch (err) {
    console.log(`postgres · arreglo: ${(err as Error).message}`);
  }

  // Postgres B: niveles con UNION (una consulta) y la reconstrucción hacia atrás, un viaje por salto
  trips = 0;
  let examined = 0;
  await q("DROP TABLE IF EXISTS bfs_level");
  await q(`CREATE TEMP TABLE bfs_level AS ${levels}`, [start]);
  await q("CREATE INDEX ON bfs_level (node)");
  examined += (await explain(db, levels, [start])).examined;
  const path = [far.node];
  for (let d = far.depth - 1; d >= 0; d--) {
    // un vecino del último nodo que esté en el nivel anterior
    const sql = "SELECT e.dst AS node FROM stint_edge e JOIN bfs_level l ON l.node = e.dst AND l.depth = $2 WHERE e.src = $1 ORDER BY 1 LIMIT 1";
    examined += (await explain(db, sql, [path[0], d])).examined;
    path.unshift((await q(sql, [path[0], d])).rows[0].node);
  }
  console.log(`postgres · niveles + vuelta atrás: ${examined} filas examinadas · ${trips} viajes · ${path.map((p) => p.split(":")[1]).join(" → ")}`);
} finally {
  await session.close();
  await driver.close();
  await db.end();
}
