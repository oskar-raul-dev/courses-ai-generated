// La apuesta de la Fase 14: la escalera de profundidades. Desde tres piezas, cuántos nodos se alcanzan a
// 1…8 saltos de estadía (pieza → aeronave → pieza…), y cuánto recorre cada motor para saberlo:
//   neo4j          [:INSTALLED*1..d] con DISTINCT: db hits del PROFILE
//   UNION ALL      WITH RECURSIVE con CYCLE, como en a07: enumera caminos (filas del CTE)
//   UNION          WITH RECURSIVE que descarta repetidos (nodo, profundidad): enumera nodos por nivel
//
//   node 14-grafos-romper-y-medir/ladder.ts [--max 8] [--timeout 120]   (desde src/, después de edges.sql)
import { readFileSync } from "node:fs";
import { parseArgs } from "node:util";
import neo4j from "neo4j-driver";
import pg from "pg";
import { profile } from "../lab/harness/neo4j-profile.ts";

const { values: args } = parseArgs({ options: { max: { type: "string", default: "8" }, timeout: { type: "string", default: "120" } } });
const MAX = Number(args.max);
const driver = neo4j.driver(`bolt://localhost:${process.env.GRAFOS_BOLT_PORT ?? 17687}`, neo4j.auth.basic("neo4j", "condor-mro"));
const session = driver.session();
const db = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "postgres" });
await db.connect();
await db.query(`SET statement_timeout = '${args.timeout}s'`);

const lot = JSON.parse(readFileSync("lab/data/workOrder-1m/answers.json", "utf8")).directiveLot.serials[0];
const byHash = (await db.query("SELECT serial_number FROM part_stint ORDER BY md5(serial_number) LIMIT 1")).rows[0].serial_number;
const STARTS: [string, string][] = [["la de a07", "SN-0391969"], ["una del lote", lot], ["una por hash", byHash]];

const cteRows = async (sql: string): Promise<{ rows: number; pages: number } | string> => {
  try {
    const { rows } = await db.query(`EXPLAIN (ANALYZE, BUFFERS, FORMAT JSON) ${sql}`);
    const plan = rows[0]["QUERY PLAN"][0].Plan;
    let cte = 0;
    const walk = (n: { "Node Type": string; "Actual Rows": number; "Actual Loops": number; Plans?: unknown[] }) => {
      if (n["Node Type"] === "Recursive Union") cte = Math.round(n["Actual Rows"] * n["Actual Loops"]);
      (n.Plans as typeof n[] | undefined)?.forEach(walk);
    };
    walk(plan);
    return { rows: cte, pages: plan["Shared Hit Blocks"] + plan["Shared Read Blocks"] };
  } catch (e) {
    return (e as Error).message;
  }
};

try {
  for (const [label, serial] of STARTS) {
    console.log(`\ndesde ${serial} (${label})`);
    let cycleDead = false;
    for (let d = 1; d <= MAX; d++) {
      const g = await profile(session, `MATCH (p:Part {serialNumber: $s})-[:INSTALLED*1..${d}]-(x) RETURN count(DISTINCT x) AS n`, { s: serial });
      const nodes = (g.records[0] as { n: { toNumber(): number } }).n.toNumber();
      const start = `SELECT 'part:' || '${serial}', 0`;
      const step = `SELECT e.dst, t.depth + 1 FROM t JOIN stint_edge e ON e.src = t.node WHERE t.depth < ${d}`;
      const union = await cteRows(`WITH RECURSIVE t(node, depth) AS (${start} UNION ${step}) SELECT count(DISTINCT node) FROM t WHERE depth > 0`);
      // la de a07 se deja de correr cuando ya no termina: cada salto más solo puede ser peor
      const cycle = cycleDead ? "no se corre" : await cteRows(`WITH RECURSIVE t(node, depth) AS (${start} UNION ALL ${step}) CYCLE node SET is_cycle USING path SELECT count(DISTINCT node) FROM t WHERE depth > 0`);
      if (typeof cycle === "string") cycleDead = true;
      const fmt = (x: typeof union) => (typeof x === "string" ? x.slice(0, 50) : `${x.rows} filas · ${x.pages} pág.`);
      console.log(`  ${d} · nodos ${String(nodes).padStart(6)} · neo4j ${String(g.dbHits).padStart(8)} db hits · UNION ${fmt(union)} · UNION ALL+CYCLE ${fmt(cycle)}`);
    }
  }
} finally {
  await session.close();
  await driver.close();
  await db.end();
}
