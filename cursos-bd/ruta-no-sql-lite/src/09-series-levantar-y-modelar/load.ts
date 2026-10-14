// Carga reading-5m en TimescaleDB (perfil series) y en Postgres (perfil base, base series_base), los
// mismos registros en los dos, y amplía ×10 dentro de cada motor como las Fases 07 y 08. Al final
// imprime la huella de reading_x10 en los dos, que tiene que ser idéntica.
//
//   node 09-series-levantar-y-modelar/load.ts [--dataset lab/data/reading-5m] [--batch 50000]   (desde src/)
import { readFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { parseArgs } from "node:util";
import pg from "pg";
import { readNdjson, verifyDataset } from "../lab/harness/dataset.ts";

const { values: args } = parseArgs({
  options: { dataset: { type: "string", default: "lab/data/reading-5m" }, batch: { type: "string", default: "50000" } },
});
const dir = resolve(args.dataset!);
const here = import.meta.dirname;
const manifest = await verifyDataset(dir);
console.log(`dataset ${args.dataset} · datasetSha256 ${manifest.datasetSha256.slice(0, 12)}… verificado`);

const connect = async (port: number, database: string) => {
  const c = new pg.Client({ host: "localhost", port, user: "postgres", password: "condor", database });
  await c.connect();
  return c;
};
// las dos bases se crean de cero
for (const [port, db] of [[Number(process.env.SERIES_PORT ?? 15433), "condor"], [Number(process.env.BASE_PORT ?? 15432), "series_base"]] as const) {
  const admin = await connect(port, "postgres");
  await admin.query(`DROP DATABASE IF EXISTS ${db} WITH (FORCE)`);
  await admin.query(`CREATE DATABASE ${db}`);
  await admin.end();
}
const engines = {
  timescale: await connect(Number(process.env.SERIES_PORT ?? 15433), "condor"),
  postgres: await connect(Number(process.env.BASE_PORT ?? 15432), "series_base"),
};
await engines.timescale.query(readFileSync(join(here, "schema-timescale.sql"), "utf8"));
await engines.postgres.query(readFileSync(join(here, "schema-base.sql"), "utf8"));

interface Reading { aircraft: string; flightId: string; ts: string; altitudeFt: number; iasKt: number; egtC: number; n1Pct: number; oilPressPsi: number; oilTempC: number; fuelFlowPph: number }
const COLS = ["aircraft", "flight_id", "ts", "altitude_ft", "ias_kt", "egt_c", "n1_pct", "oil_press_psi", "oil_temp_c", "fuel_flow_pph"];
const TYPES = ["text", "text", "timestamp", "int", "int", "int", "int", "int", "int", "int"];
// un lote, un viaje: cada columna viaja como un array y unnest las vuelve filas
const insert = `INSERT INTO reading (${COLS.join(", ")}) SELECT * FROM unnest(${TYPES.map((t, i) => `$${i + 1}::${t}[]`).join(", ")})`;

const started = performance.now();
let batch: unknown[][] = COLS.map(() => []);
let loaded = 0;
const flush = async () => {
  if (!batch[0].length) return;
  // "2021-10-01T00:00:00Z" sin la Z: el instante es UTC y las columnas son timestamp sin zona
  await Promise.all(Object.values(engines).map((c) => c.query(insert, batch)));
  loaded += batch[0].length;
  batch = COLS.map(() => []);
};
for await (const r of readNdjson<Reading>(join(dir, "reading.ndjson"))) {
  const row = [r.aircraft, r.flightId, r.ts.slice(0, 19), r.altitudeFt, r.iasKt, r.egtC, r.n1Pct, r.oilPressPsi, r.oilTempC, r.fuelFlowPph];
  row.forEach((v, i) => batch[i].push(v));
  if (batch[0].length >= Number(args.batch)) await flush();
}
await flush();
console.log(`cargadas ${loaded} lecturas en los dos motores: ${((performance.now() - started) / 1000).toFixed(1)} s`);

const AMPLIFY = `INSERT INTO reading_x10
  SELECT CASE WHEN k = 0 THEN aircraft ELSE aircraft || '~' || k END,
         CASE WHEN k = 0 THEN flight_id ELSE flight_id || '~' || k END,
         ts, altitude_ft, ias_kt, egt_c, n1_pct, oil_press_psi, oil_temp_c, fuel_flow_pph
  FROM generate_series(0, 9) AS k, reading ORDER BY k, aircraft, ts`;
const FINGERPRINT = readFileSync(join(here, "../07-analitico-levantar-y-modelar/fingerprint.sql"), "utf8");
for (const [name, c] of Object.entries(engines)) {
  const t = performance.now();
  await c.query(AMPLIFY);
  await c.query("VACUUM ANALYZE");
  const { rows } = await c.query(FINGERPRINT);
  const f = rows[0];
  console.log(`${name.padEnd(9)} ×10 en ${((performance.now() - t) / 1000).toFixed(1)} s · huella ${f.readings} · ${f.aircraft} · ${f.flights} · ${f.first_ts.toISOString?.() ?? f.first_ts} · ${f.egt} · ${f.fuel_flow}`);
}
await Promise.all(Object.values(engines).map((c) => c.end()));
