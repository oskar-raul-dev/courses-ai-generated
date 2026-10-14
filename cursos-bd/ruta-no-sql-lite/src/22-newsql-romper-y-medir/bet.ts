// La apuesta (sección 3), juzgada como quedó escrita antes de medir: Postgres bien jugado —primario en Bogotá,
// réplica de lectura en Quito, cada transacción en un solo viaje— contra CockroachDB con la autoridad en la clave
// y la ubicación restringida (latency.ts). La latencia de Postgres es la de su servidor más los viajes que el
// cliente hace a otro país, por el RTT que el demo midió entre esas dos regiones: Postgres no tiene red simulada.
// En Postgres el reloj es el del cliente sobre la red local de Docker, una transacción por viaje: el servidor más
// lo que tarda el loopback, y nada de lote.
//
//   node 22-newsql-romper-y-medir/bet.ts [--reps 5]   (desde src/, con compose.replica.yaml arriba, el primario cargado
//                                                       con load.ts --target primario --db expediente, y latency.ts corrido)
import { readFileSync } from "node:fs";
import { parseArgs } from "node:util";
import type pg from "pg";
import { inline } from "../lab/harness/crdb-explain.ts";
import { connect } from "../21-newsql-levantar-y-modelar/db.ts";
import { BOGOTA, COCA, readSteps, reset, signSteps, type Step } from "../21-newsql-levantar-y-modelar/expediente.ts";

const { values: args } = parseArgs({ options: { reps: { type: "string", default: "5" } } });
const reps = Number(args.reps);
const median = (xs: number[]) => { const s = [...xs].sort((a, b) => a - b); return s[Math.floor(s.length / 2)]; };
const crdb = JSON.parse(readFileSync("lab/data/f22-latency-autoridad.json", "utf8"));
const rtt = (a: string, b: string) => crdb.matrix[a][b] - crdb.matrix[a][a];   // un viaje de ida y vuelta, sin el servidor

/** Todas las sentencias en un solo viaje: un texto con varias sentencias y los valores como literales. */
const oneTrip = (db: pg.Client, steps: Step[], tx: boolean) =>
  [tx ? "BEGIN" : "", ...steps.map((s) => inline(db, s.sql, s.params)), tx ? "COMMIT" : ""].filter(Boolean).join(";\n");

async function wall(db: pg.Client, sql: string) { const t0 = performance.now(); await db.query(sql); return performance.now() - t0; }

const primario = await connect("primario", "expediente"), replica = await connect("replica", "expediente");
// CockroachDB también en un solo viaje, medido igual que Postgres: no es el criterio de la apuesta, es el control
const cockroach = { EC: await connect("global", "condor", "EC"), CO: await connect("global", "condor", "CO") };
const crdbAdmin = await connect("global", "condor");
const jobs: [string, string, pg.Client, string, Step[], boolean][] = [
  // trabajo, clave en latency.ts, dónde lo atiende Postgres, país del cliente, sentencias, ¿escribe?
  ["el expediente, pedido desde Ecuador", "el expediente, pedido desde Ecuador", replica, "EC", readSteps("copy"), false],
  ["la rutina, firmada en el Coca", "la rutina, firmada en el Coca", primario, "EC", signSteps(COCA, "copy"), true],
  ["la inspección mayor, firmada en Bogotá", "la inspección mayor, firmada en Bogotá", primario, "CO", signSteps(BOGOTA, "copy"), true],
];
const server = (db: pg.Client) => (db === primario ? "CO" : "EC");   // el primario está en Bogotá, la réplica en Quito
let wins = 0;
console.log(`RTT medido en el demo: Colombia–Ecuador ${rtt("EC", "CO").toFixed(1)} ms · Colombia–Perú ${rtt("PE", "CO").toFixed(1)} ms · Ecuador–Perú ${rtt("EC", "PE").toFixed(1)} ms`);
for (const [label, key, db, country, steps, tx] of jobs) {
  const xs: number[] = [];
  for (let rep = 0; rep <= reps; rep++) { await reset(primario); const ms = await wall(db, oneTrip(db, steps, tx)); if (rep) xs.push(ms); }
  const own = median(xs);
  const trips = server(db) === country ? 0 : 1;
  const pg_ = own + trips * rtt(country, server(db));
  // la misma transacción mandada sentencia por sentencia, como la escribe quien no piensa en viajes
  const interactive = own + (steps.length + (tx ? 2 : 0)) * (server(db) === country ? 0 : rtt(country, server(db)));
  const c = crdb.jobs[key].total;
  const cdb = cockroach[country as "EC" | "CO"];
  const cSteps = tx ? signSteps(key.includes("Coca") ? COCA : BOGOTA, "autoridad") : readSteps("autoridad");
  const ys: number[] = [];
  for (let rep = 0; rep <= reps; rep++) { await reset(crdbAdmin); const ms = await wall(cdb, oneTrip(cdb, cSteps, tx)); if (rep) ys.push(ms); }
  const cOne = median(ys);
  const ok = pg_ <= 0.5 * c;
  if (ok) wins++;
  console.log(`\n${label}`);
  console.log(`  Postgres · ${db === primario ? "primario en Bogotá" : "réplica en Quito"} · servidor ${own.toFixed(1)} ms + ${trips} viaje(s) a otro país = ${pg_.toFixed(1)} ms` +
    (trips ? ` (sentencia por sentencia serían ${steps.length + (tx ? 2 : 0)} viajes: ${interactive.toFixed(1)} ms)` : ""));
  console.log(`  CockroachDB · ${crdb.jobs[key].statements} sentencias en el servidor = ${c.toFixed(1)} ms (en un solo viaje, como Postgres: ${cOne.toFixed(1)} ms)`);
  console.log(`  Postgres / CockroachDB = ${(pg_ / c).toFixed(2)} → ${ok ? "≤ 0,5: cuenta para la apuesta" : "> 0,5: no cuenta"}`);
}
console.log(`latencia: Postgres ≤ 0,5× en ${wins} de 3 trabajos → ${wins >= 2 ? "GANADA" : "PERDIDA"} (la apuesta pedía 2 de 3)`);
await reset(primario);
await reset(crdbAdmin);
await Promise.all([primario.end(), replica.end(), cockroach.EC.end(), cockroach.CO.end(), crdbAdmin.end()]);
