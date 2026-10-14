// Carga el catálogo de partes en OpenSearch (perfil busqueda, índice part_catalog) y en Postgres
// (perfil base, base busqueda_base, tabla part_catalog): los mismos registros en los dos.
// En OpenSearch, con el mapping de catalog-index.json y en lotes de _bulk; cada lote, un viaje.
//
//   node 11-busqueda-levantar-y-modelar/load.ts [--dataset lab/data/partCatalog-10k] [--batch 5000] [--index part_catalog]
import { readFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { parseArgs } from "node:util";
import { Client as OpenSearch } from "@opensearch-project/opensearch";
import pg from "pg";
import { readNdjson, verifyDataset } from "../lab/harness/dataset.ts";

const { values: args } = parseArgs({
  options: {
    dataset: { type: "string", default: "lab/data/partCatalog-10k" },
    batch: { type: "string", default: "5000" },
    index: { type: "string", default: "part_catalog" },
    "skip-postgres": { type: "boolean", default: false },
  },
});
const dir = resolve(args.dataset!);
const manifest = await verifyDataset(dir);
console.log(`dataset ${args.dataset} · datasetSha256 ${manifest.datasetSha256.slice(0, 12)}… verificado`);

interface Entry { partNumber: string; description: string; category: string; ataChapter: number; serialized: boolean;
  compatibleModels: string[]; alternates: string[]; supplierIds: string[]; supplierPartNumbers: string[]; unitCostUsd: number }

const os = new OpenSearch({ node: `http://localhost:${process.env.BUSQUEDA_PORT ?? 19200}` });
const index = args.index!;
await os.indices.delete({ index, ignore_unavailable: true });
await os.indices.create({ index, body: JSON.parse(readFileSync(join(import.meta.dirname, "catalog-index.json"), "utf8")) });
// sin refresco durante la carga: cada refresco crea un segmento nuevo
await os.indices.putSettings({ index, body: { index: { refresh_interval: "-1" } } });

// el catálogo guarda el alterno en una sola dirección: A dice que B es su alterno, B no dice nada de A.
// Buscar A tiene que encontrar B, así que el índice guarda también la relación inversa (alternateOf).
// Es una primera pasada por el archivo, y es modelar para la búsqueda: el catálogo no la tiene.
const alternateOf = new Map<string, string[]>();
for await (const e of readNdjson<Entry>(join(dir, "partCatalog.ndjson"))) {
  for (const a of e.alternates) alternateOf.set(a, [...(alternateOf.get(a) ?? []), e.partNumber]);
}

let trips = 0;
let loaded = 0;
let started = performance.now();
let batch: Entry[] = [];
const flush = async () => {
  if (!batch.length) return;
  const body = batch.flatMap((e) => [{ index: { _index: index, _id: e.partNumber } }, { ...e, alternateOf: alternateOf.get(e.partNumber) ?? [] }]);
  const { body: r } = await os.bulk({ body });
  trips++;
  if (r.errors) throw new Error(`_bulk con errores: ${JSON.stringify(r.items.find((i: { index: { error?: unknown } }) => i.index.error))}`);
  loaded += batch.length;
  batch = [];
};
for await (const e of readNdjson<Entry>(join(dir, "partCatalog.ndjson"))) {
  batch.push(e);
  if (batch.length >= Number(args.batch)) await flush();
}
await flush();
await os.indices.putSettings({ index, body: { index: { refresh_interval: "1s" } } });
await os.indices.refresh({ index });
const { body: count } = await os.count({ index });
const { body: stats } = await os.indices.stats({ index, metric: "store,segments" });
const primaries = stats.indices[index].primaries;
console.log(`opensearch ${loaded} documentos en ${trips} viajes de _bulk · ${((performance.now() - started) / 1000).toFixed(1)} s · count ${count.count} · ${(primaries.store.size_in_bytes / 2 ** 20).toFixed(1)} MiB · ${primaries.segments.count} segmentos`);
await os.close();

if (!args["skip-postgres"]) {
  const port = Number(process.env.BASE_PORT ?? 15432);
  const admin = new pg.Client({ host: "localhost", port, user: "postgres", password: "condor", database: "postgres" });
  await admin.connect();
  await admin.query("DROP DATABASE IF EXISTS busqueda_base WITH (FORCE)");
  await admin.query("CREATE DATABASE busqueda_base");
  await admin.end();
  const c = new pg.Client({ host: "localhost", port, user: "postgres", password: "condor", database: "busqueda_base" });
  await c.connect();
  await c.query(`CREATE TABLE part_catalog (part_number text PRIMARY KEY, description text, category text, ata_chapter int,
    serialized boolean, compatible_models text[], alternates text[], supplier_ids text[], supplier_part_numbers text[], unit_cost_usd numeric(12, 2))`);
  started = performance.now();
  let rows: Entry[] = [];
  const insert = async () => {
    if (!rows.length) return;
    await c.query(`INSERT INTO part_catalog SELECT x.part_number, x.description, x.category, x.ata_chapter, x.serialized,
        ARRAY(SELECT jsonb_array_elements_text(x.compatible_models)), ARRAY(SELECT jsonb_array_elements_text(x.alternates)),
        ARRAY(SELECT jsonb_array_elements_text(x.supplier_ids)), ARRAY(SELECT jsonb_array_elements_text(x.supplier_part_numbers)), x.unit_cost_usd
      FROM jsonb_to_recordset($1::jsonb) AS x(part_number text, description text, category text, ata_chapter int, serialized boolean,
        compatible_models jsonb, alternates jsonb, supplier_ids jsonb, supplier_part_numbers jsonb, unit_cost_usd numeric)`,
      [JSON.stringify(rows.map((e) => ({ part_number: e.partNumber, description: e.description, category: e.category, ata_chapter: e.ataChapter,
        serialized: e.serialized, compatible_models: e.compatibleModels, alternates: e.alternates, supplier_ids: e.supplierIds,
        supplier_part_numbers: e.supplierPartNumbers, unit_cost_usd: e.unitCostUsd })))]);
    rows = [];
  };
  for await (const e of readNdjson<Entry>(join(dir, "partCatalog.ndjson"))) {
    rows.push(e);
    if (rows.length >= Number(args.batch)) await insert();
  }
  await insert();
  await c.query("VACUUM ANALYZE part_catalog");
  const { rows: r } = await c.query("SELECT count(*) AS n, pg_size_pretty(pg_total_relation_size('part_catalog')) AS s FROM part_catalog");
  console.log(`postgres   ${r[0].n} filas · ${r[0].s} · ${((performance.now() - started) / 1000).toFixed(1)} s`);
  await c.end();
}
