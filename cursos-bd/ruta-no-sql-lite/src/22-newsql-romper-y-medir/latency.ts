// La latencia como argumento (sección 4.1): la física simulada del laboratorio y lo que cuesta cada trabajo del
// expediente, en el servidor y sentencia por sentencia (SHOW LAST QUERY STATISTICS), con el COMMIT incluido.
//   1 · la matriz: desde cada puerta, leer una aeronave por su clave en cada región (una fila, un rango);
//   2 · los tres trabajos de la Fase 21, cada uno desde su puerta, repetidos --reps veces tras una vuelta de
//       calentamiento: se reporta la mediana de cada sentencia y la suma por trabajo.
// Escribe el resultado en lab/data/f22-latency-<esquema>.json, que lee bet.ts.
//
//   node 22-newsql-romper-y-medir/latency.ts --db condor --schema autoridad [--reps 5]
//                                              (desde src/, con newsql-global y la base cargada con load.ts)
import { writeFileSync } from "node:fs";
import { parseArgs } from "node:util";
import type pg from "pg";
import { lastStatement } from "../lab/harness/crdb-explain.ts";
import { connect } from "../21-newsql-levantar-y-modelar/db.ts";
import { BOGOTA, COCA, readSteps, reset, signSteps, type Schema, type Step } from "../21-newsql-levantar-y-modelar/expediente.ts";

const { values: args } = parseArgs({ options: { db: { type: "string", default: "condor" }, schema: { type: "string", default: "autoridad" }, reps: { type: "string", default: "5" } } });
const schema = args.schema as Schema;
const reps = Number(args.reps);
const median = (xs: number[]) => { const s = [...xs].sort((a, b) => a - b); return s[Math.floor(s.length / 2)]; };
const fmt = (ms: number) => `${ms.toFixed(1).padStart(6)} ms`;
const COUNTRIES = ["CO", "EC", "PE"] as const;
const REGION = { CO: "us-east1", EC: "us-west1", PE: "europe-west1" } as const;
const PLANE = { CO: "HK-5339", EC: "HC-2157", PE: "OB-1565" } as const;   // una aeronave de cada autoridad

/** Corre una sentencia y devuelve su latencia en el servidor. */
async function timed(db: pg.Client, sql: string, params: unknown[] = []) { await db.query(sql, params); return (await lastStatement(db)).serviceMs; }

// ── 1 · la matriz ──────────────────────────────────────────────────────────────────────────────────
const matrix: Record<string, Record<string, number>> = {};
console.log(`${args.db} · esquema ${schema} · mediana de ${reps} lecturas de una aeronave por su clave, en el servidor`);
for (const from of COUNTRIES) {
  const db = await connect("global", args.db!, from);
  matrix[from] = {};
  for (const to of COUNTRIES) {
    const sql = schema === "autoridad" ? `SELECT * FROM aircraft WHERE country = $1 AND registration = $2` : `SELECT * FROM aircraft WHERE registration = $2 AND $1::text IS NOT NULL`;
    await timed(db, sql, [to, PLANE[to]]);
    const xs: number[] = [];
    for (let i = 0; i < reps; i++) xs.push(await timed(db, sql, [to, PLANE[to]]));
    matrix[from][to] = median(xs);
  }
  console.log(`  desde ${from} (${REGION[from].padEnd(12)}) · ` + COUNTRIES.map((to) => `${to} ${fmt(matrix[from][to])}`).join(" · "));
  await db.end();
}

// ── 2 · los tres trabajos ──────────────────────────────────────────────────────────────────────────
const jobs: [string, "CO" | "EC", Step[], boolean][] = [
  ["el expediente, pedido desde Ecuador", "EC", readSteps(schema), false],
  ["la rutina, firmada en el Coca", "EC", signSteps(COCA, schema), true],
  ["la inspección mayor, firmada en Bogotá", "CO", signSteps(BOGOTA, schema), true],
];
const admin = await connect("global", args.db!);
const result: Record<string, { steps: Record<string, number>; total: number; statements: number }> = {};
for (const [label, country, steps, tx] of jobs) {
  const db = await connect("global", args.db!, country);
  const samples: Record<string, number[]> = {};
  for (let rep = 0; rep <= reps; rep++) {          // la vuelta 0 calienta planes y caches, y no cuenta
    await reset(admin);
    if (tx) await db.query("BEGIN");
    for (const s of steps) { const ms = await timed(db, s.sql, s.params); if (rep) (samples[s.name] ??= []).push(ms); }
    if (tx) { const ms = await timed(db, "COMMIT"); if (rep) (samples.COMMIT ??= []).push(ms); }
  }
  const steps_ = Object.fromEntries(Object.entries(samples).map(([k, v]) => [k, median(v)]));
  const total = Object.values(steps_).reduce((a, b) => a + b, 0);
  result[label] = { steps: steps_, total, statements: Object.keys(steps_).length };
  console.log(`\n  ${label} · desde ${country} · ${Object.keys(steps_).length} sentencias · ${fmt(total)} en el servidor`);
  for (const [k, v] of Object.entries(steps_)) console.log(`    ${k.padEnd(28)} ${fmt(v)}`);
  await db.end();
}
await reset(admin);
await admin.end();
writeFileSync(`lab/data/f22-latency-${schema}.json`, JSON.stringify({ db: args.db, schema, reps, matrix, jobs: result }, null, 2));
