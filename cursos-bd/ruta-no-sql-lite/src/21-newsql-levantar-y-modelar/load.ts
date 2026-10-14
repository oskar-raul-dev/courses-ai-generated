// Carga el expediente de workOrder-10k —hangares, técnicos, proveedores, catálogo, aeronaves, piezas,
// conjuntos, reportes y órdenes con sus técnicos y movimientos— en cualquiera de los tres destinos, con el
// esquema que se elija:
//   copy      · el esquema de referencia de la Fase 01, copiado tal cual (menos las dos líneas que
//               CockroachDB no acepta, sección 6.2)
//   regional  · la región por fila, con las claves de la Fase 01 (schema-regional.sql, sección 6.4)
//   autoridad · la región por fila y la autoridad en cada clave (schema-autoridad.sql, sección 6.4)
// Las lecturas de parámetros no se cargan: el expediente no las necesita.
//
//   node 21-newsql-levantar-y-modelar/load.ts --target base|newsql|global --db condor [--schema copy|regional|autoridad]
//                                             (desde src/, con el perfil del destino arriba)
import { readFileSync } from "node:fs";
import { join } from "node:path";
import { parseArgs } from "node:util";
import { readNdjson, verifyDataset } from "../lab/harness/dataset.ts";
import { connect, ensureDatabase, type Target } from "./db.ts";

const { values: args } = parseArgs({
  options: {
    target: { type: "string", default: "newsql" },
    db: { type: "string", default: "condor" },
    schema: { type: "string", default: "copy" },
    batch: { type: "string", default: "2000" },
  },
});
export const DATASET = "lab/data/workOrder-10k";
const target = args.target as Target;
const batchSize = Number(args.batch);

/** El esquema de la Fase 01 sin lo que CockroachDB rechaza: la extensión y el ANALYZE sin tabla. */
export function copiedSchema(): string {
  const f01 = join(import.meta.dirname, "../01-el-dominio-de-flota-y-el-arnes");
  const strip = (sql: string) => sql.split("\n").filter((l) => !/pg_stat_statements|^ANALYZE;/.test(l)).join("\n");
  return strip(readFileSync(join(f01, "schema.sql"), "utf8")) + "\n" + strip(readFileSync(join(f01, "indexes.sql"), "utf8"));
}

const snake = (name: string) => name.replace(/[A-Z]/g, (c) => `_${c.toLowerCase()}`);
const toRow = (r: Record<string, unknown>) => Object.fromEntries(Object.entries(r).map(([k, v]) => [snake(k), v]));

const start = performance.now();
const manifest = await verifyDataset(DATASET);
const regional = args.schema === "regional" || args.schema === "autoridad";
await ensureDatabase(target, args.db!, regional ? `PRIMARY REGION "us-east1" REGIONS "us-west1", "europe-west1"` : "");
const db = await connect(target, args.db!);

await db.query(regional ? readFileSync(join(import.meta.dirname, `schema-${args.schema}.sql`), "utf8") : copiedSchema());

// el tipo de cada columna, leído del destino: el mismo cargador sirve a los dos esquemas
const { rows: cols } = await db.query(
  `SELECT table_name, column_name, data_type, udt_name FROM information_schema.columns
    WHERE table_schema = 'public' AND is_generated = 'NEVER' AND column_name <> 'crdb_region' AND column_name <> 'rowid'
    ORDER BY table_name, ordinal_position`);
const typeOf = (c: any) => (c.data_type === "ARRAY" ? `${c.udt_name.replace(/^_/, "")}[]` : c.data_type === "USER-DEFINED" ? c.udt_name : c.data_type);
const columns = new Map<string, [string, string][]>();
for (const c of cols) (columns.get(c.table_name) ?? columns.set(c.table_name, []).get(c.table_name)!).push([c.column_name, typeOf(c)]);

async function insert(table: string, rows: Record<string, unknown>[]) {
  const cs = columns.get(table)!;
  await db.query(
    `INSERT INTO ${table} (${cs.map(([c]) => c).join(", ")})
     SELECT ${cs.map(([c]) => c).join(", ")} FROM jsonb_to_recordset($1::jsonb) AS x(${cs.map(([c, t]) => `${c} ${t}`).join(", ")})`,
    [JSON.stringify(rows)]);
}

const authority = new Map<string, string>();   // matrícula → país de la autoridad
const totals: Record<string, number> = {};
async function load(file: string, explode: (r: any) => [string, Record<string, unknown>][]) {
  const pending: Record<string, Record<string, unknown>[]> = {};
  const flushAll = async () => {
    // en el orden en que aparecieron: la orden antes que sus técnicos y movimientos
    for (const [t, rows] of Object.entries(pending)) if (rows.length) { await insert(t, rows); totals[t] = (totals[t] ?? 0) + rows.length; pending[t] = []; }
  };
  for await (const r of readNdjson<any>(join(DATASET, file))) {
    for (const [t, row] of explode(r)) (pending[t] ??= []).push(row);
    if (Object.values(pending).some((rows) => rows.length >= batchSize)) await flushAll();
  }
  await flushAll();
}

for (const [file, table] of [["hangar", "hangar"], ["technician", "technician"], ["supplier", "supplier"], ["partCatalog", "part_catalog"]] as const)
  await load(`${file}.ndjson`, (r) => [[table, toRow(r)]]);
await load("aircraft.ndjson", (r) => { authority.set(r.registration, r.country); return [["aircraft", toRow(r)]]; });
await load("part.ndjson", (r) => [["part", toRow(r)]]);
// lo que cuelga de una aeronave lleva el país de su autoridad: el esquema regional lo usa para ubicar la fila
await load("assembly.ndjson", (r) => [["assembly", { ...toRow(r), authority: authority.get(r.aircraft) }]]);
await load("pirep.ndjson", (r) => [["pirep", { ...toRow(r), authority: authority.get(r.aircraft) }]]);
await load("workOrder.ndjson", ({ technicianIds, removed, installed, ...wo }) => {
  const a = authority.get(wo.aircraft);
  return [
    ["work_order", { ...toRow(wo), authority: a }],
    ...technicianIds.map((t: string) => ["work_order_technician", { work_order_id: wo.workOrderId, technician_id: t, authority: a }]),
    ...removed.map((m: any) => ["work_order_movement", { work_order_id: wo.workOrderId, kind: "removed", ...toRow(m), authority: a }]),
    ...installed.map((m: any) => ["work_order_movement", { work_order_id: wo.workOrderId, kind: "installed", ...toRow(m), authority: a }]),
  ] as [string, Record<string, unknown>][];
});
for (const t of Object.keys(totals)) await db.query(`ANALYZE ${t}`);

console.log(`${target} · base ${args.db} · esquema ${args.schema} · ${manifest.focus}-${manifest.volume} (${manifest.datasetSha256.slice(0, 12)}…) · ` +
  Object.entries(totals).map(([t, n]) => `${t} ${n}`).join(" · ") + ` · ${((performance.now() - start) / 1000).toFixed(1)} s`);
await db.end();
