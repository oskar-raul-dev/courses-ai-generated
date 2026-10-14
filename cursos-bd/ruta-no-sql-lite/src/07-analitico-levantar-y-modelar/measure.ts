// Lo que lee Postgres para contestar las mismas consultas de measure.py: filas examinadas y páginas
// de 8 kB, del plan real. Primero con la tabla tal como la dejó load_postgres.py; con --indexes,
// después de crear los índices de indexes.sql (la línea base bien jugada); con --no-seqscan, además,
// prohibiendo el recorrido secuencial para ver qué harían los índices que el planificador descartó.
//
//   node 07-analitico-levantar-y-modelar/measure.ts [--table reading_x10] [--indexes] [--no-seqscan]
//                                                   (desde src/)
import { parseArgs } from "node:util";
import pg from "pg";
import { explain } from "../lab/harness/explain.ts";

const { values: args } = parseArgs({
  options: { table: { type: "string", default: "reading_x10" }, indexes: { type: "boolean", default: false }, "no-seqscan": { type: "boolean", default: false } },
});
const T = args.table!;
const COLUMNS = ["aircraft", "flight_id", "ts", "altitude_ft", "ias_kt", "egt_c", "n1_pct", "oil_press_psi", "oil_temp_c", "fuel_flow_pph"];
const QUERIES: Record<string, string> = {
  "all-columns": `SELECT ${COLUMNS.map((c) => `max(${c})`).join(", ")} FROM ${T}`,
  "one-column": `SELECT avg(egt_c) FROM ${T}`,
  "three-columns": `SELECT aircraft, avg(egt_c), avg(fuel_flow_pph) FROM ${T} GROUP BY aircraft`,
  "egt-out-of-range": `SELECT count(*) FROM ${T} WHERE egt_c = -1`,
  "one-aircraft": `SELECT avg(egt_c) FROM ${T} WHERE aircraft = 'HK-4207'`,
};

const client = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "analitico" });
await client.connect();
try {
  if (args["no-seqscan"]) await client.query("SET enable_seqscan = off");
  const { rows } = await client.query(`SELECT pg_relation_size($1) / 8192 AS pages, pg_size_pretty(pg_relation_size($1)) AS size, current_setting('max_parallel_workers_per_gather') AS workers`, [T]);
  console.log(`${T}: ${rows[0].pages} páginas (${rows[0].size}) · ${args.indexes ? "con los índices de indexes.sql" : "sin índices"}${args["no-seqscan"] ? ", enable_seqscan = off" : ""} · ${rows[0].workers} workers por Gather`);
  for (const [name, sql] of Object.entries(QUERIES)) {
    const r = await explain(client, sql);
    const pages = r.sharedHit + r.sharedRead;
    console.log(`  ${name.padEnd(17)} examinadas ${String(r.examined).padStart(10)} · páginas ${String(pages).padStart(7)} (${((pages * 8192) / 2 ** 20).toFixed(1).padStart(7)} MiB) · ${r.access.join(", ")}`);
  }
} finally {
  await client.end();
}
