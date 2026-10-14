// Carga reading-5m en Cassandra, escribiendo cada lectura en cada tabla de consulta que la necesita:
// el mismo dato tres veces, a propósito. Con --x10, carga además la ampliación ×10 de las Fases 07–10
// (matrícula y vuelo con sufijo ~k) en reading_x10_by_aircraft_month, la que se mide contra Postgres.
//
//   node 17-columnar-levantar-y-modelar/load.ts [--dataset lab/data/reading-5m] [--x10] [--only-x10]
//                                               [--concurrency 64]   (desde src/, después de schema.cql)
import { join, resolve } from "node:path";
import { parseArgs } from "node:util";
import cassandra from "cassandra-driver";
import { readNdjson, verifyDataset } from "../lab/harness/dataset.ts";
import { columnar, retries, writeAll } from "../lab/harness/cassandra-trace.ts";

const { values: args } = parseArgs({
  options: {
    dataset: { type: "string", default: "lab/data/reading-5m" },
    x10: { type: "boolean", default: false },
    "only-x10": { type: "boolean", default: false },
    concurrency: { type: "string", default: "64" },
  },
});
const dir = resolve(args.dataset!);
const manifest = await verifyDataset(dir);
console.log(`dataset ${args.dataset} · datasetSha256 ${manifest.datasetSha256.slice(0, 12)}… verificado`);

// el umbral de la consulta 3: el percentil 99 de la EGT en reading-5m es 719 °C
const EGT_THRESHOLD = 720;

interface Reading { aircraft: string; flightId: string; ts: string; altitudeFt: number; iasKt: number; egtC: number; n1Pct: number; oilPressPsi: number; oilTempC: number; fuelFlowPph: number }

const VALUES = "altitude_ft, ias_kt, egt_c, n1_pct, oil_press_psi, oil_temp_c, fuel_flow_pph";
const Q = {
  byAircraftMonth: `INSERT INTO reading_by_aircraft_month (aircraft, month, ts, flight_id, ${VALUES}) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
  byFlight: `INSERT INTO reading_by_flight (flight_id, ts, aircraft, ${VALUES}) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
  exceedance: "INSERT INTO egt_exceedance_by_day (day, aircraft, ts, flight_id, egt_c) VALUES (?, ?, ?, ?, ?)",
  x10: `INSERT INTO reading_x10_by_aircraft_month (aircraft, month, ts, flight_id, ${VALUES}) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
};

const client = columnar();
await client.connect();
const concurrency = Number(args.concurrency);
const counts: Record<string, number> = { byAircraftMonth: 0, byFlight: 0, exceedance: 0, x10: 0 };

// cada lectura se vuelve una o varias escrituras; se mandan en ventanas de 20 000 con
// `concurrency` peticiones en vuelo, y las que no se confirman a tiempo se reintentan (writeAll)
let pending: { query: string; params: unknown[] }[] = [];
const flush = async () => {
  if (!pending.length) return;
  await writeAll(client, pending, concurrency);
  pending = [];
};
const push = async (key: keyof typeof Q, params: unknown[]) => {
  pending.push({ query: Q[key], params });
  counts[key]++;
  if (pending.length >= 20_000) await flush();
};

const started = performance.now();
let read = 0;
for await (const r of readNdjson<Reading>(join(dir, "reading.ndjson"))) {
  const ts = new Date(r.ts);
  const month = r.ts.slice(0, 7);
  const values = [r.altitudeFt, r.iasKt, r.egtC, r.n1Pct, r.oilPressPsi, r.oilTempC, r.fuelFlowPph];
  if (!args["only-x10"]) {
    await push("byAircraftMonth", [r.aircraft, month, ts, r.flightId, ...values]);
    await push("byFlight", [r.flightId, ts, r.aircraft, ...values]);
    if (r.egtC >= EGT_THRESHOLD) await push("exceedance", [cassandra.types.LocalDate.fromString(r.ts.slice(0, 10)), r.aircraft, ts, r.flightId, r.egtC]);
  }
  if (args.x10 || args["only-x10"]) {
    // la misma ampliación que 09-…/load.ts hace en SQL: k = 0 es el original, k = 1…9 llevan sufijo
    for (let k = 0; k < 10; k++) {
      const sfx = k === 0 ? "" : `~${k}`;
      await push("x10", [r.aircraft + sfx, month, ts, r.flightId + sfx, ...values]);
    }
  }
  if (++read % 500_000 === 0) console.log(`  ${read} lecturas · ${((performance.now() - started) / 1000).toFixed(0)} s`);
}
await flush();
const secs = (performance.now() - started) / 1000;
const total = Object.values(counts).reduce((a, b) => a + b, 0);
console.log(`leídas ${read} lecturas · escritas ${total} filas en ${secs.toFixed(0)} s (${Math.round(total / secs)} filas/s)`);
for (const [k, n] of Object.entries(counts)) if (n) console.log(`  ${k.padEnd(16)} ${n}`);
console.log(`reintentos: ${retries.writeTimeout} por write timeout · ${retries.other} por otros motivos`);
await client.shutdown();
