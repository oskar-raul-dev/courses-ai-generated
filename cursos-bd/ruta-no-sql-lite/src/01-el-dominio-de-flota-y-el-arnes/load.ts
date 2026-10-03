// Carga el dataset canónico de a05 en el esquema relacional de referencia de Postgres.
// Primero comprueba el hash: si el dataset no es el del curso, no carga nada.
//
//   node 01-el-dominio-de-flota-y-el-arnes/load.ts [--dataset lab/data/workOrder-1m] [--batch 5000]
//                                                  (desde src/, con el perfil base arriba)
import { readFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { parseArgs } from "node:util";
import pg from "pg";
import { readNdjson, verifyDataset } from "../lab/harness/dataset.ts";
import { countRoundTrips } from "../lab/harness/roundtrips.ts";

const { values: args } = parseArgs({
  options: {
    dataset: { type: "string", default: "lab/data/workOrder-1m" },
    batch: { type: "string", default: "5000" },
  },
});
const dir = resolve(args.dataset!);
const batchSize = Number(args.batch);
const here = import.meta.dirname;

const snake = (name: string) => name.replace(/[A-Z]/g, (c) => `_${c.toLowerCase()}`);

/** Columnas de cada tabla, con su tipo, en el orden del esquema. */
const TABLES: Record<string, [string, string][]> = {
  hangar: [["hangar_id", "text"], ["name", "text"], ["city", "text"], ["country", "text"], ["pits", "int"]],
  technician: [["technician_id", "text"], ["name", "text"], ["hangar_id", "text"], ["license_type", "text"], ["can_sign", "boolean"], ["itinerant", "boolean"]],
  supplier: [["supplier_id", "text"], ["name", "text"], ["kind", "text"], ["capability", "text"], ["country", "text"], ["agreement_valid_until", "date"]],
  part_catalog: [["part_number", "text"], ["description", "text"], ["category", "text"], ["ata_chapter", "int"], ["serialized", "boolean"], ["compatible_models", "text[]"], ["alternates", "text[]"], ["supplier_ids", "text[]"], ["supplier_part_numbers", "text[]"], ["unit_cost_usd", "numeric"]],
  aircraft: [["registration", "text"], ["model", "text"], ["kind", "text"], ["engines", "int"], ["operator_id", "text"], ["country", "text"], ["year_of_manufacture", "int"], ["base_hangar_id", "text"], ["has_flight_recorder", "boolean"], ["continuous_wing_contract", "boolean"], ["in_fleet_from", "date"], ["left_fleet_on", "date"], ["options", "jsonb"]],
  part: [["serial_number", "text"], ["part_number", "text"], ["category", "text"], ["lot_number", "text"], ["manufactured_on", "date"], ["hours_since_new", "int"], ["cycles_since_new", "int"], ["details", "jsonb"], ["status", "text"], ["aircraft", "text"], ["position", "text"], ["hangar_id", "text"], ["supplier_id", "text"], ["sent_to_supplier_on", "date"]],
  assembly: [["assembly_id", "text"], ["kind", "text"], ["aircraft", "text"], ["position", "text"], ["part_serials", "text[]"]],
  pirep: [["pirep_id", "text"], ["aircraft", "text"], ["reported_at", "timestamptz"], ["ata_chapter", "int"], ["text", "text"]],
  work_order: [["work_order_id", "text"], ["aircraft", "text"], ["hangar_id", "text"], ["type", "text"], ["opened_at", "timestamptz"], ["closed_at", "timestamptz"], ["pirep_id", "text"], ["released_by", "text"], ["labor_hours", "int"], ["labor_cost_usd", "numeric"], ["parts_cost_usd", "numeric"], ["tasks", "text[]"]],
  work_order_technician: [["work_order_id", "text"], ["technician_id", "text"]],
  work_order_movement: [["work_order_id", "text"], ["kind", "text"], ["serial_number", "text"], ["part_number", "text"], ["position", "text"], ["disposition", "text"], ["supplier_id", "text"], ["reason", "text"]],
  reading: [["aircraft", "text"], ["ts", "timestamptz"], ["flight_id", "text"], ["altitude_ft", "int"], ["ias_kt", "int"], ["egt_c", "int"], ["n1_pct", "int"], ["oil_press_psi", "int"], ["oil_temp_c", "int"], ["fuel_flow_pph", "int"]],
};

const client = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "postgres" });
const trips = countRoundTrips(client, "query");

/** Un lote entero en un solo viaje: el array de registros viaja como un parámetro JSONB. */
async function insertBatch(table: string, rows: object[]): Promise<void> {
  const cols = TABLES[table];
  await client.query(
    `INSERT INTO ${table} (${cols.map(([c]) => c).join(", ")})
     SELECT ${cols.map(([c]) => c).join(", ")} FROM jsonb_to_recordset($1::jsonb) AS x(${cols.map(([c, t]) => `${c} ${t}`).join(", ")})`,
    [JSON.stringify(rows)],
  );
}

/** Lee un NDJSON y lo carga por lotes; `explode` convierte un registro en filas de varias tablas. */
async function load(file: string, explode: (r: Record<string, unknown>) => [string, object][]): Promise<Record<string, number>> {
  const pending: Record<string, object[]> = {};
  const loaded: Record<string, number> = {};
  const flush = async (table: string) => {
    if (!pending[table]?.length) return;
    await insertBatch(table, pending[table]);
    loaded[table] = (loaded[table] ?? 0) + pending[table].length;
    pending[table] = [];
  };
  // cuando un lote se llena, se vacían todos y en el orden en que aparecieron: la tabla padre
  // (work_order) siempre antes que sus hijas, o la clave foránea rechaza el lote
  const flushAll = async () => {
    for (const table of Object.keys(pending)) await flush(table);
  };
  for await (const record of readNdjson(join(dir, file))) {
    for (const [table, row] of explode(record)) (pending[table] ??= []).push(row);
    if (Object.values(pending).some((rows) => rows.length >= batchSize)) await flushAll();
  }
  await flushAll();
  return loaded;
}

/** Del camelCase del dataset canónico al snake_case de Postgres (a08). */
const toRow = (r: Record<string, unknown>) => Object.fromEntries(Object.entries(r).map(([k, v]) => [snake(k), v]));

const start = performance.now();
const manifest = await verifyDataset(dir);
console.log(`dataset ${manifest.focus}-${manifest.volume} · generador ${manifest.generatorVersion} · datasetSha256 ${manifest.datasetSha256.slice(0, 16)}… verificado`);

await client.connect();
try {
  await client.query(readFileSync(join(here, "schema.sql"), "utf8"));
  const totals: Record<string, number> = {};
  const add = (loaded: Record<string, number>) => Object.entries(loaded).forEach(([t, n]) => (totals[t] = (totals[t] ?? 0) + n));
  // en orden de dependencia: cada tabla después de las que referencia
  for (const [file, table] of [["hangar", "hangar"], ["technician", "technician"], ["supplier", "supplier"], ["partCatalog", "part_catalog"], ["aircraft", "aircraft"], ["part", "part"], ["assembly", "assembly"], ["pirep", "pirep"]] as const) {
    add(await load(`${file}.ndjson`, (r) => [[table, toRow(r)]]));
  }
  add(await load("workOrder.ndjson", (r) => {
    const { technicianIds, removed, installed, ...wo } = r as Record<string, unknown> & { technicianIds: string[]; removed: Record<string, unknown>[]; installed: Record<string, unknown>[] };
    return [
      ["work_order", toRow(wo)],
      ...technicianIds.map((t) => ["work_order_technician", { work_order_id: wo.workOrderId, technician_id: t }] as [string, object]),
      ...removed.map((m) => ["work_order_movement", { work_order_id: wo.workOrderId, kind: "removed", ...toRow(m) }] as [string, object]),
      ...installed.map((m) => ["work_order_movement", { work_order_id: wo.workOrderId, kind: "installed", ...toRow(m) }] as [string, object]),
    ];
  }));
  add(await load("reading.ndjson", (r) => [["reading", toRow(r)]]));
  for (const [table, n] of Object.entries(totals)) console.log(`  ${table.padEnd(22)} ${String(n).padStart(9)} filas`);
  console.log(`cargado en ${((performance.now() - start) / 1000).toFixed(1)} s · ${trips.count} viajes a Postgres (lotes de ${batchSize})`);
} finally {
  await client.end();
}
