// El tamaño del chunk es una decisión del modelo: las mismas 5 M lecturas reales en dos hypertables,
// con chunks de 7 días (la de load.ts) y de 1 mes, y las consultas de measure.ts sobre cada una.
//
//   node 09-series-levantar-y-modelar/chunk_interval.ts   (desde src/, perfil series)
import pg from "pg";
import { explain, type PlanNode } from "../lab/harness/explain.ts";

const c = new pg.Client({ host: "localhost", port: Number(process.env.SERIES_PORT ?? 15433), user: "postgres", password: "condor", database: "condor" });
await c.connect();
const chunksOf = (plan: PlanNode): number => {
  const seen = new Set<string>();
  const walk = (n: PlanNode) => { if (n["Relation Name"]?.startsWith("_hyper_")) seen.add(n["Relation Name"]); n.Plans?.forEach(walk); };
  walk(plan);
  return seen.size;
};
try {
  await c.query("DROP TABLE IF EXISTS reading_month");
  await c.query("CREATE TABLE reading_month (LIKE reading INCLUDING DEFAULTS)");
  await c.query("SELECT create_hypertable('reading_month', by_range('ts', INTERVAL '1 month'))");
  await c.query("CREATE INDEX ON reading_month (aircraft, ts DESC)");
  await c.query("INSERT INTO reading_month SELECT * FROM reading ORDER BY aircraft, ts");
  await c.query("VACUUM ANALYZE reading_month");
  for (const table of ["reading", "reading_month"]) {
    const { rows } = await c.query(`SELECT count(*) AS n FROM timescaledb_information.chunks WHERE hypertable_name = $1`, [table]);
    console.log(`${table}: ${rows[0].n} chunks`);
    for (const [name, sql] of Object.entries({
      "one-aircraft-60d": `SELECT date_trunc('day', ts), avg(egt_c) FROM ${table} WHERE aircraft = 'HC-2157' AND ts >= '2025-09-15' AND ts < '2025-11-14' GROUP BY 1`,
      "fleet-one-month": `SELECT aircraft, avg(egt_c) FROM ${table} WHERE ts >= '2025-03-01' AND ts < '2025-04-01' GROUP BY aircraft`,
      "one-aircraft-5y": `SELECT date_trunc('day', ts), avg(egt_c) FROM ${table} WHERE aircraft = 'HC-2157' AND ts < '2026-10-01' GROUP BY 1`,
    })) {
      const r = await explain(c, sql);
      console.log(`  ${name.padEnd(17)} examinadas ${String(r.examined).padStart(8)} · páginas ${String(r.sharedHit + r.sharedRead).padStart(6)} · chunks ${chunksOf(r.plan)}`);
    }
  }
} finally {
  await c.end();
}
