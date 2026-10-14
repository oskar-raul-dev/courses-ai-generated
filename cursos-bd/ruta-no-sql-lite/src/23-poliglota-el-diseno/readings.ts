// ¿Se reconstruye la hypertable desde la descarga? La fuente de verdad de una lectura de vuelo no es una base:
// es el archivo que se baja del registrador al aterrizar, que llega en orden y no se corrige. Se calcula la
// misma huella en el archivo (reading.ndjson del dataset) y en `reading` de TimescaleDB, cargada por la Fase 09,
// y se comparan. Una corrección hecha solo en la base aparecería aquí como diferencia.
//
//   node 23-poliglota-el-diseno/readings.ts [--dataset lab/data/reading-5m]   (desde src/, con series arriba)
import { parseArgs } from "node:util";
import pg from "pg";
import { readNdjson, verifyDataset } from "../lab/harness/dataset.ts";

const { values } = parseArgs({ options: { dataset: { type: "string", default: "lab/data/reading-5m" } } });
await verifyDataset(values.dataset!);

interface Reading { aircraft: string; flightId: string; ts: string; altitudeFt: number; iasKt: number; egtC: number; n1Pct: number; oilPressPsi: number; oilTempC: number; fuelFlowPph: number }
const PARAMS = ["altitudeFt", "iasKt", "egtC", "n1Pct", "oilPressPsi", "oilTempC", "fuelFlowPph"] as const;

// la huella por aeronave: lecturas, primera y última, y la suma de cada parámetro
type Print = { n: number; first: string; last: string; sums: number[] };
const file = new Map<string, Print>();
let t0 = performance.now();
for await (const r of readNdjson<Reading>(`${values.dataset}/reading.ndjson`)) {
  const p = file.get(r.aircraft) ?? { n: 0, first: r.ts, last: r.ts, sums: PARAMS.map(() => 0) };
  p.n++;
  if (r.ts < p.first) p.first = r.ts;
  if (r.ts > p.last) p.last = r.ts;
  PARAMS.forEach((k, i) => (p.sums[i] += r[k]));
  file.set(r.aircraft, p);
}
const fileSeconds = (performance.now() - t0) / 1000;

const client = new pg.Client({ host: "localhost", port: Number(process.env.SERIES_PORT ?? 15433), user: "postgres", password: "condor", database: "condor" });
await client.connect();
t0 = performance.now();
const { rows } = await client.query(`
  SELECT aircraft, count(*)::int AS n,
         to_char(min(ts) AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS first,
         to_char(max(ts) AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS last,
         ARRAY[sum(altitude_ft), sum(ias_kt), sum(egt_c), sum(n1_pct), sum(oil_press_psi), sum(oil_temp_c), sum(fuel_flow_pph)]::bigint[] AS sums
  FROM reading GROUP BY aircraft`);
const dbSeconds = (performance.now() - t0) / 1000;
await client.end();

let equal = 0;
const diffs: string[] = [];
for (const r of rows) {
  const f = file.get(r.aircraft);
  const sums = r.sums.map(Number);
  if (f && f.n === r.n && f.first === r.first && f.last === r.last && f.sums.every((s, i) => s === sums[i])) equal++;
  else diffs.push(`${r.aircraft}: archivo ${f ? `${f.n} lecturas` : "no la tiene"} · base ${r.n} lecturas`);
}
for (const a of file.keys()) if (!rows.some((r) => r.aircraft === a)) diffs.push(`${a}: está en el archivo y no en la base`);
const total = [...file.values()].reduce((s, p) => s + p.n, 0);
console.log(`${values.dataset}/reading.ndjson → TimescaleDB reading · ${total} lecturas de ${file.size} aeronaves en el archivo (${fileSeconds.toFixed(0)} s) · huella de la base en ${dbSeconds.toFixed(1)} s`);
console.log(`  aeronaves con la misma huella ${equal} de ${file.size} · distintas ${diffs.length}`);
for (const d of diffs.slice(0, 5)) console.log(`  ${d}`);
