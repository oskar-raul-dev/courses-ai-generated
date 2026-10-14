// Lo que lee cada motor para las consultas de una serie temporal, sobre las mismas 50 M lecturas:
// la hypertable de TimescaleDB (perfil series) y la tabla normal con sus índices (perfil base).
// Del plan real: filas examinadas, páginas de 8 kB y, en Timescale, cuántos chunks tocó.
//
//   node 09-series-levantar-y-modelar/measure.ts [--table reading_x10]   (desde src/)
import { parseArgs } from "node:util";
import pg from "pg";
import { explain, type PlanNode } from "../lab/harness/explain.ts";

const { values: args } = parseArgs({ options: { table: { type: "string", default: "reading_x10" } } });
const T = args.table!;
const QUERIES: Record<string, string> = {
  // la tendencia de EGT del caso plantado (a05): una aeronave, sesenta días
  "one-aircraft-60d": `SELECT date_trunc('day', ts) AS day, avg(egt_c) FROM ${T}
     WHERE aircraft = 'HC-2157' AND ts >= '2025-09-15' AND ts < '2025-11-14' GROUP BY 1 ORDER BY 1`,
  // toda la flota, un mes: lo que pide un tablero de operación
  "fleet-one-month": `SELECT aircraft, avg(egt_c), max(egt_c) FROM ${T}
     WHERE ts >= '2025-03-01' AND ts < '2025-04-01' GROUP BY aircraft`,
  // una aeronave, cinco años, un valor por día: el gráfico de tendencia completo
  "one-aircraft-5y": `SELECT date_trunc('day', ts) AS day, avg(egt_c) FROM ${T}
     WHERE aircraft = 'HC-2157' AND ts < '2026-10-01' GROUP BY 1 ORDER BY 1`,
};

const chunksOf = (plan: PlanNode): number => {
  const seen = new Set<string>();
  const walk = (n: PlanNode) => {
    if (n["Relation Name"]?.startsWith("_hyper_")) seen.add(n["Relation Name"]);
    n.Plans?.forEach(walk);
  };
  walk(plan);
  return seen.size;
};

const engines: [string, pg.Client][] = [
  ["timescale", new pg.Client({ host: "localhost", port: Number(process.env.SERIES_PORT ?? 15433), user: "postgres", password: "condor", database: "condor" })],
  ["postgres", new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "series_base" })],
];
try {
  for (const [, c] of engines) await c.connect();
  for (const [name, sql] of Object.entries(QUERIES)) {
    console.log(name);
    for (const [engine, c] of engines) {
      const r = await explain(c, sql);
      const chunks = engine === "timescale" ? ` · chunks ${chunksOf(r.plan)}` : "";
      const access = [...new Set(r.access.map((a) => a.replace(/_hyper_\d+_\d+_chunk/g, "<chunk>")))];
      console.log(`  ${engine.padEnd(9)} examinadas ${String(r.examined).padStart(9)} · devueltas ${String(r.returned).padStart(5)} · páginas ${String(r.sharedHit + r.sharedRead).padStart(7)}${chunks} · ${access.join(", ")}`);
    }
  }
} finally {
  for (const [, c] of engines) await c.end();
}
