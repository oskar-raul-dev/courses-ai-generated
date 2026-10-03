// Mediciones de la Fase 03 sobre las dos formas que cargó load.ts.
//
//   node 03-documental-levantar-y-modelar/measure.ts [--dataset lab/data/part-1m]
//                                         (desde src/, con el perfil documental arriba y cargado)
import { resolve } from "node:path";
import { parseArgs } from "node:util";
import { MongoClient, type Document } from "mongodb";
import { verifyDataset } from "../lab/harness/dataset.ts";
import { countMongoRoundTrips } from "../lab/harness/roundtrips.ts";
import { explainFind } from "../lab/harness/mongo-explain.ts";

const { values: args } = parseArgs({ options: { dataset: { type: "string", default: "lab/data/part-1m" } } });
const manifest = await verifyDataset(resolve(args.dataset!));
const client = new MongoClient(`mongodb://localhost:${process.env.DOCUMENTAL_PORT ?? 27018}/?directConnection=true`, { monitorCommands: true });
const trips = countMongoRoundTrips(client);
await client.connect();
const ref = client.db("condor_ref");
const doc = client.db("condor_doc");
const mb = (b: number) => `${(b / 2 ** 20).toFixed(1)} MB`;

try {
  console.log(`dataset ${manifest.focus}-${manifest.volume} (${manifest.datasetSha256.slice(0, 12)}…)\n`);

  // la aeronave con más piezas instaladas: se elige igual en cualquier máquina
  const [target] = await doc.collection("aircraft").aggregate([
    { $project: { n: { $size: "$installedParts" } } }, { $sort: { n: -1, _id: 1 } }, { $limit: 1 },
  ]).toArray();
  const reg = target._id as string;
  console.log(`ficha de ${reg}: ${target.n} piezas instaladas\n`);

  // ── 1. la ficha completa, de tres maneras ──────────────────────────────────────────────
  trips.reset();
  await doc.collection("aircraft").findOne({ _id: reg });
  const embeddedTrips = trips.count;

  trips.reset();
  await ref.collection("aircraft").findOne({ _id: reg });
  const parts = await ref.collection("part").find({ aircraft: reg, status: "installed" }).toArray();
  await ref.collection("assembly").find({ aircraft: reg }).toArray();
  for (const p of parts) await ref.collection("partCatalog").findOne({ _id: p.partNumber }); // una por pieza
  const nPlusOneTrips = trips.count;

  trips.reset();
  await ref.collection("aircraft").findOne({ _id: reg });
  const parts2 = await ref.collection("part").find({ aircraft: reg, status: "installed" }).toArray();
  await ref.collection("assembly").find({ aircraft: reg }).toArray();
  await ref.collection("partCatalog").find({ _id: { $in: parts2.map((p) => p.partNumber) } }).toArray();
  const batchedTrips = trips.count;

  const lookup = [
    { $match: { _id: reg } },
    { $lookup: { from: "part", localField: "_id", foreignField: "aircraft", as: "parts", pipeline: [{ $match: { status: "installed" } }] } },
    { $lookup: { from: "assembly", localField: "_id", foreignField: "aircraft", as: "assemblies" } },
    { $lookup: { from: "partCatalog", localField: "parts.partNumber", foreignField: "_id", as: "catalog" } },
  ];
  trips.reset();
  await ref.collection("aircraft").aggregate(lookup).toArray();
  const lookupTrips = trips.count;

  const embeddedExplain = await explainFind(doc.collection("aircraft").find({ _id: reg }));
  console.log("ficha completa        viajes");
  console.log(`  embebida            ${embeddedTrips}   (docs examinados ${embeddedExplain.docsExamined}, ${embeddedExplain.stages.join(" ← ")})`);
  console.log(`  referenciada, N+1   ${nPlusOneTrips}   (3 + ${parts.length} piezas)`);
  console.log(`  referenciada, $in   ${batchedTrips}`);
  console.log(`  referenciada, $lookup ${lookupTrips}`);

  // lo que $lookup hace por dentro: un recorrido de la colección ajena por cada documento de entrada
  const lookupStats = async (withIndex: boolean) => {
    if (!withIndex) await ref.collection("part").dropIndex("aircraft_1");
    const e = await ref.collection("aircraft").aggregate(lookup.slice(0, 2)).explain("executionStats");
    if (!withIndex) await ref.collection("part").createIndex({ aircraft: 1 });
    const stage = (e.stages ?? []).find((s: Document) => s.$lookup);
    return { docs: stage?.totalDocsExamined, keys: stage?.totalKeysExamined, scans: stage?.collectionScans, idx: JSON.stringify(stage?.indexesUsed) };
  };
  const lk1 = await lookupStats(true);
  const lk0 = await lookupStats(false);
  console.log(`\n$lookup de piezas     con índice en part.aircraft: docs ${lk1.docs} · claves ${lk1.keys} · índices ${lk1.idx}`);
  console.log(`                      sin índice:                  docs ${lk0.docs} · claves ${lk0.keys} · recorridos completos ${lk0.scans}`);

  // ── 2. el tamaño de la ficha embebida ──────────────────────────────────────────────────
  const [size] = await doc.collection("aircraft").aggregate([
    { $project: { s: { $bsonSize: "$$ROOT" } } },
    { $group: { _id: null, avg: { $avg: "$s" }, max: { $max: "$s" } } },
  ]).toArray();
  console.log(`\nficha embebida: media ${(size.avg / 1024).toFixed(1)} kB · máxima ${(size.max / 1024).toFixed(1)} kB · límite 16384 kB`);

  // ── 3. un índice sobre un array embebido (multikey) ────────────────────────────────────
  const serial = parts[0]?.serialNumber;
  // idempotente: si una ejecución anterior dejó los índices, se quitan antes de medir sin ellos
  await doc.collection("aircraft").dropIndex("installedParts.serialNumber_1").catch(() => {});
  const before = await explainFind(doc.collection("aircraft").find({ "installedParts.serialNumber": serial }));
  await doc.collection("aircraft").createIndex({ "installedParts.serialNumber": 1 });
  const after = await explainFind(doc.collection("aircraft").find({ "installedParts.serialNumber": serial }));
  const docStats = await doc.command({ collStats: "aircraft" });
  console.log(`\n¿en qué ficha está ${serial}?  sin índice: docs ${before.docsExamined} · con índice multikey: docs ${after.docsExamined}, claves ${after.keysExamined}`);
  console.log(`índice multikey: ${mb(docStats.indexSizes["installedParts.serialNumber_1"])} para ${docStats.count} fichas`);

  // ── 4. la consulta polimórfica: piezas de motor con TBO de 6000 h ──────────────────────
  const poly = { "details.tboHours": 6000 };
  await ref.collection("part").dropIndex("details.tboHours_1").catch(() => {});
  const p0 = await explainFind(ref.collection("part").find(poly));
  await ref.collection("part").createIndex({ "details.tboHours": 1 });
  const p1 = await explainFind(ref.collection("part").find(poly));
  const partStats = await ref.command({ collStats: "part" });
  console.log(`\ndetails.tboHours = 6000   sin índice: docs ${p0.docsExamined} → ${p0.returned} · con índice: docs ${p1.docsExamined}, claves ${p1.keysExamined} → ${p1.returned}`);
  console.log(`índice details.tboHours_1: ${mb(partStats.indexSizes["details.tboHours_1"])} (${partStats.count} piezas)`);
} finally {
  await client.close();
}
