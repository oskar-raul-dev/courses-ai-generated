// El sistema del boss del Bloque II tal como lo encuentra quien recibe el encargo: tres tableros del
// costo por hora volada, cada uno armado por alguien distinto con buen criterio, sobre reading-5m.
//   · Timescale (perfil series, base condor): las órdenes en una tabla y las horas en un agregado
//     continuo mensual, cortado en hora de Colombia.
//   · OpenSearch (perfil busqueda): el catálogo de partes de reading-5m con las correcciones de precio
//     que hizo almacén en el buscador, y las órdenes indexadas para calcular el costo de partes. La carga
//     de las órdenes se cortó una vez y se relanzó un lote.
//   · DuckDB: la base de la Fase 07, tal como está (tablero_duckdb.py).
//
//   node 12-busqueda-romper-y-medir/boss/setup.ts   (desde src/, con los perfiles base, series y busqueda arriba)
import { join, resolve } from "node:path";
import { Client as OpenSearch } from "@opensearch-project/opensearch";
import pg from "pg";
import { readNdjson, verifyDataset } from "../../lab/harness/dataset.ts";

const dir = resolve("lab/data/reading-5m");
const manifest = await verifyDataset(dir);
console.log(`dataset reading-5m · datasetSha256 ${manifest.datasetSha256.slice(0, 12)}… verificado`);

interface WorkOrder { workOrderId: string; aircraft: string; openedAt: string; laborCostUsd: number; partsCostUsd: number; installed: { partNumber: string }[] }
interface Aircraft { registration: string; model: string; operatorId: string; hasFlightRecorder: boolean }
interface Entry { partNumber: string; description: string; category: string; unitCostUsd: number }
const aircraft = new Map<string, Aircraft>();
for await (const a of readNdjson<Aircraft>(join(dir, "aircraft.ndjson"))) aircraft.set(a.registration, a);
const orders: WorkOrder[] = [];
for await (const w of readNdjson<WorkOrder>(join(dir, "workOrder.ndjson"))) orders.push(w);

// ── Timescale: órdenes y horas por mes de Colombia ─────────────────────────────────────────────────
const ts = new pg.Client({ host: "localhost", port: Number(process.env.SERIES_PORT ?? 15433), user: "postgres", password: "condor", database: "condor" });
await ts.connect();
await ts.query("DROP MATERIALIZED VIEW IF EXISTS boss_hours_monthly CASCADE");
await ts.query("DROP TABLE IF EXISTS boss_work_order, boss_aircraft");
await ts.query("CREATE TABLE boss_aircraft (registration text PRIMARY KEY, model text, operator_id text, has_flight_recorder boolean)");
await ts.query("INSERT INTO boss_aircraft SELECT * FROM jsonb_to_recordset($1::jsonb) AS x(registration text, model text, operator_id text, has_flight_recorder boolean)",
  [JSON.stringify([...aircraft.values()].map((a) => ({ registration: a.registration, model: a.model, operator_id: a.operatorId, has_flight_recorder: a.hasFlightRecorder })))]);
await ts.query("CREATE TABLE boss_work_order (work_order_id text PRIMARY KEY, aircraft text, opened_at timestamp, labor_cost_usd numeric(12, 2), parts_cost_usd numeric(12, 2))");
for (let i = 0; i < orders.length; i += 5000) {
  await ts.query("INSERT INTO boss_work_order SELECT * FROM jsonb_to_recordset($1::jsonb) AS x(work_order_id text, aircraft text, opened_at timestamp, labor_cost_usd numeric, parts_cost_usd numeric)",
    [JSON.stringify(orders.slice(i, i + 5000).map((w) => ({ work_order_id: w.workOrderId, aircraft: w.aircraft, opened_at: w.openedAt.slice(0, 19), labor_cost_usd: w.laborCostUsd, parts_cost_usd: w.partsCostUsd })))]);
}
// las horas de cada mes de calendario colombiano (UTC−5, sin horario de verano)
await ts.query(`CREATE MATERIALIZED VIEW boss_hours_monthly WITH (timescaledb.continuous) AS
  SELECT aircraft, time_bucket(INTERVAL '1 month', ts, "offset" => INTERVAL '5 hours') AS month_co, count(*) / 60.0 AS flight_hours
  FROM reading GROUP BY aircraft, month_co`);
console.log(`timescale: ${orders.length} órdenes, agregado mensual de horas creado`);
await ts.end();

// ── OpenSearch: el catálogo con las correcciones de almacén, y las órdenes ─────────────────────────
const os = new OpenSearch({ node: `http://localhost:${process.env.BUSQUEDA_PORT ?? 19200}`, requestTimeout: 120_000 });
for (const index of ["boss_catalog", "boss_work_order"]) await os.indices.delete({ index, ignore_unavailable: true });
await os.indices.create({ index: "boss_catalog", body: { mappings: { properties: { partNumber: { type: "keyword" }, description: { type: "text" }, category: { type: "keyword" }, unitCostUsd: { type: "scaled_float", scaling_factor: 100 } } } } });
const catalog: Entry[] = [];
for await (const e of readNdjson<Entry>(join(dir, "partCatalog.ndjson"))) catalog.push(e);
for (let i = 0; i < catalog.length; i += 5000) {
  await os.bulk({ body: catalog.slice(i, i + 5000).flatMap((e) => [{ index: { _index: "boss_catalog", _id: e.partNumber } }, { partNumber: e.partNumber, description: e.description, category: e.category, unitCostUsd: e.unitCostUsd }]) });
}
// almacén actualizó en el buscador el precio de lo que más se compra: llantas, actuadores y bombas
const raised = catalog.filter((e) => ["tire", "actuator", "pump"].includes(e.category));
for (let i = 0; i < raised.length; i += 5000) {
  await os.bulk({ body: raised.slice(i, i + 5000).flatMap((e) => [{ update: { _index: "boss_catalog", _id: e.partNumber } }, { doc: { unitCostUsd: Math.round(e.unitCostUsd * 112) / 100 } }]) });
}
await os.indices.refresh({ index: "boss_catalog" });

await os.indices.create({ index: "boss_work_order", body: { mappings: { properties: {
  workOrderId: { type: "keyword" }, aircraft: { type: "keyword" }, model: { type: "keyword" }, operatorId: { type: "keyword" },
  openedAt: { type: "date" }, laborCostUsd: { type: "scaled_float", scaling_factor: 100 }, installedPartNumbers: { type: "keyword" } } } } });
// sin _id propio: OpenSearch genera uno por documento. El lote 4 se mandó dos veces, como el reintento
// del cliente de la Fase 11 (E-49), y nadie lo notó
const docs = orders.map((w) => ({ workOrderId: w.workOrderId, aircraft: w.aircraft, model: aircraft.get(w.aircraft)!.model, operatorId: aircraft.get(w.aircraft)!.operatorId,
  openedAt: w.openedAt, laborCostUsd: w.laborCostUsd, installedPartNumbers: w.installed.map((p) => p.partNumber) }));
const BATCH = 1000;
for (let b = 0; b * BATCH < docs.length; b++) {
  const body = docs.slice(b * BATCH, (b + 1) * BATCH).flatMap((d) => [{ index: { _index: "boss_work_order" } }, d]);
  await os.bulk({ body });
  if (b === 28) await os.bulk({ body });
}
await os.indices.refresh({ index: "boss_work_order" });
const { body: c1 } = await os.count({ index: "boss_catalog" });
const { body: c2 } = await os.count({ index: "boss_work_order" });
console.log(`opensearch: boss_catalog ${c1.count} referencias (${raised.length} con precio actualizado) · boss_work_order ${c2.count} órdenes`);
await os.close();
