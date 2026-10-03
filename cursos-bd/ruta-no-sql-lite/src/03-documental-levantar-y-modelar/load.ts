// Carga el dataset canónico de a05 en MongoDB, en dos formas, para compararlas (Fase 03):
//
//   condor_ref · "como si fuera relacional": una colección por entidad y referencias por id.
//   condor_doc · "a la manera documental": la ficha de aeronave con sus conjuntos y sus piezas
//                instaladas embebidas, que es la unidad de lectura de esa pantalla.
//
// Las dos bases salen de los mismos bytes: el hash del dataset se comprueba antes de cargar.
//
//   node 03-documental-levantar-y-modelar/load.ts [--dataset lab/data/part-1m]
//                                         (desde src/, con el perfil documental arriba)
import { resolve, join } from "node:path";
import { parseArgs } from "node:util";
import { MongoClient, type AnyBulkWriteOperation, type Document } from "mongodb";
import { readNdjson, verifyDataset } from "../lab/harness/dataset.ts";
import { countMongoRoundTrips } from "../lab/harness/roundtrips.ts";

const { values: args } = parseArgs({
  options: {
    dataset: { type: "string", default: "lab/data/part-1m" },
    batch: { type: "string", default: "5000" },
  },
});
const dir = resolve(args.dataset!);
const batchSize = Number(args.batch);
const uri = `mongodb://localhost:${process.env.DOCUMENTAL_PORT ?? 27018}/?directConnection=true`;

const start = performance.now();
const manifest = await verifyDataset(dir);
console.log(`dataset ${manifest.focus}-${manifest.volume} · datasetSha256 ${manifest.datasetSha256.slice(0, 16)}… verificado`);

const client = new MongoClient(uri, { monitorCommands: true });
const trips = countMongoRoundTrips(client);
await client.connect();

try {
  const ref = client.db("condor_ref");
  const doc = client.db("condor_doc");
  await ref.dropDatabase();
  await doc.dropDatabase();

  /** Inserta un NDJSON en una colección, por lotes; `_id` es la clave natural de la entidad. */
  const loadCollection = async (file: string, collection: string, key: string | null) => {
    let batch: Document[] = [];
    let n = 0;
    for await (const r of readNdjson<Document>(join(dir, file))) {
      batch.push(key ? { _id: r[key], ...r } : r);
      if (batch.length >= batchSize) { await ref.collection(collection).insertMany(batch, { ordered: false }); n += batch.length; batch = []; }
    }
    if (batch.length) { await ref.collection(collection).insertMany(batch, { ordered: false }); n += batch.length; }
    return n;
  };

  // ── condor_ref: una colección por entidad, como las tablas de la Fase 01 ──────────────────
  const counts: Record<string, number> = {};
  for (const [file, collection, key] of [
    ["hangar.ndjson", "hangar", "hangarId"], ["technician.ndjson", "technician", "technicianId"],
    ["supplier.ndjson", "supplier", "supplierId"], ["partCatalog.ndjson", "partCatalog", "partNumber"],
    ["aircraft.ndjson", "aircraft", "registration"], ["part.ndjson", "part", "serialNumber"],
    ["assembly.ndjson", "assembly", "assemblyId"], ["pirep.ndjson", "pirep", "pirepId"],
    ["workOrder.ndjson", "workOrder", "workOrderId"],
  ] as const) {
    counts[`condor_ref.${collection}`] = await loadCollection(file, collection, key);
  }
  // los índices que pondría quien piensa en relacional: uno por cada clave foránea
  await ref.collection("part").createIndex({ aircraft: 1 });
  await ref.collection("assembly").createIndex({ aircraft: 1 });
  await ref.collection("workOrder").createIndex({ aircraft: 1, openedAt: 1 });

  // ── condor_doc: la ficha de aeronave, una por documento ───────────────────────────────────
  // la ficha embebe lo que la pantalla lee junto: conjuntos y piezas instaladas, con lo
  // imprescindible del catálogo copiado (descripción y capítulo ATA) para no volver a buscarlo
  const catalog = ref.collection("partCatalog");
  const fichas: Document[] = [];
  for await (const a of readNdjson<Document>(join(dir, "aircraft.ndjson"))) {
    fichas.push({ _id: a.registration, ...a, assemblies: [], installedParts: [] });
  }
  const byRegistration = new Map(fichas.map((f) => [f._id as string, f]));
  for await (const s of readNdjson<Document>(join(dir, "assembly.ndjson"))) {
    const { aircraft, ...assembly } = s;
    byRegistration.get(aircraft)?.assemblies.push(assembly);
  }
  const installed: Document[] = [];
  for await (const p of readNdjson<Document>(join(dir, "part.ndjson"))) {
    if (p.status === "installed" && byRegistration.has(p.aircraft)) installed.push(p);
  }
  // una sola consulta al catálogo para todas las piezas instaladas, no una por pieza
  const pns = [...new Set(installed.map((p) => p.partNumber as string))];
  const cat = new Map((await catalog.find({ _id: { $in: pns } }, { projection: { description: 1, ataChapter: 1 } }).toArray()).map((c) => [c._id, c]));
  for (const p of installed) {
    const { aircraft, status, hangarId, supplierId, sentToSupplierOn, ...part } = p;
    const c = cat.get(p.partNumber);
    byRegistration.get(aircraft)!.installedParts.push({ ...part, catalog: { description: c?.description, ataChapter: c?.ataChapter } });
  }
  for (const f of fichas) f.installedParts.sort((x: Document, y: Document) => (x.position < y.position ? -1 : 1));
  for (let i = 0; i < fichas.length; i += batchSize) await doc.collection("aircraft").insertMany(fichas.slice(i, i + batchSize));
  counts["condor_doc.aircraft"] = fichas.length;
  counts["condor_doc.installedParts (embebidas)"] = installed.length;

  for (const [k, n] of Object.entries(counts)) console.log(`  ${k.padEnd(40)} ${String(n).padStart(9)}`);
  console.log(`cargado en ${((performance.now() - start) / 1000).toFixed(1)} s · ${trips.count} viajes a MongoDB (lotes de ${batchSize})`);
} finally {
  await client.close();
}
