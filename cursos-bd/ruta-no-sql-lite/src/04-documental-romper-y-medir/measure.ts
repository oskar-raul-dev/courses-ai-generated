// Mediciones de la Fase 04: la apuesta contra Postgres, el punto de rotura (el documento que no
// cabe), las transacciones y la actualización de un array embebido.
//
//   node 04-documental-romper-y-medir/measure.ts [--dataset lab/data/part-1m] [--only apuesta,rotura,transacciones,array]
//      (desde src/, con documental cargado por la Fase 03 y base cargado con el mismo dataset)
import { resolve } from "node:path";
import { parseArgs } from "node:util";
import { MongoClient, type Document } from "mongodb";
import pg from "pg";
import { verifyDataset, readNdjson } from "../lab/harness/dataset.ts";
import { countMongoRoundTrips, countRoundTrips } from "../lab/harness/roundtrips.ts";
import { explainFind } from "../lab/harness/mongo-explain.ts";
import { explain } from "../lab/harness/explain.ts";

const { values: args } = parseArgs({
  options: { dataset: { type: "string", default: "lab/data/part-1m" }, only: { type: "string", default: "apuesta,rotura,transacciones,array" } },
});
const only = new Set(args.only!.split(","));
const dir = resolve(args.dataset!);
const manifest = await verifyDataset(dir);
const mongo = new MongoClient(`mongodb://localhost:${process.env.DOCUMENTAL_PORT ?? 27018}/?directConnection=true`, { monitorCommands: true });
const mtrips = countMongoRoundTrips(mongo);
await mongo.connect();
const ref = mongo.db("condor_ref");
const doc = mongo.db("condor_doc");
const pgc = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "postgres" });
await pgc.connect();
const ptrips = countRoundTrips(pgc, "query");
const kb = (b: number) => `${(b / 1024).toFixed(0)} kB`;

try {
  console.log(`dataset ${manifest.focus}-${manifest.volume} (${manifest.datasetSha256.slice(0, 12)}…)\n`);

  if (only.has("apuesta")) {
    // la misma aeronave que la Fase 03: la que más piezas instaladas tiene
    const [t] = await doc.collection("aircraft").aggregate([{ $project: { n: { $size: "$installedParts" } } }, { $sort: { n: -1, _id: 1 } }, { $limit: 1 }]).toArray();
    const reg = t._id as string;

    // Q1 · la ficha completa
    mtrips.reset();
    const m1 = await explainFind(doc.collection("aircraft").find({ _id: reg }));
    await doc.collection("aircraft").findOne({ _id: reg });
    const FICHA = `
      SELECT a.registration, a.options,
        (SELECT json_agg(s) FROM assembly s WHERE s.aircraft = a.registration) AS assemblies,
        (SELECT json_agg(json_build_object('serial', p.serial_number, 'position', p.position, 'details', p.details,
                                           'description', c.description, 'ata', c.ata_chapter))
           FROM part p JOIN part_catalog c USING (part_number)
          WHERE p.aircraft = a.registration AND p.status = 'installed') AS parts
      FROM aircraft a WHERE a.registration = $1`;
    ptrips.reset();
    const p1 = await explain(pgc, FICHA, [reg]);
    ptrips.reset();
    await pgc.query(FICHA, [reg]);
    console.log(`Q1 ficha de ${reg} (${t.n} piezas)   Mongo embebida: ${m1.docsExamined} doc, 1 viaje · Postgres, una consulta: ${p1.examined} filas, ${ptrips.count} viaje`);

    // Q2 · la polimórfica de siempre: motores con TBO de 6000 h
    await ref.collection("part").createIndex({ "details.tboHours": 1 });
    const m2 = await explainFind(ref.collection("part").find({ "details.tboHours": 6000 }));
    await pgc.query("CREATE INDEX IF NOT EXISTS part_details_gin ON part USING gin (details jsonb_path_ops); ANALYZE part;");
    const p2 = await explain(pgc, `SELECT serial_number FROM part WHERE details @> '{"tboHours": 6000}'`);
    // Q3 · otra clave polimórfica que nadie previó: llantas con tres recauchados
    await ref.collection("part").dropIndex("details.$**_1").catch(() => {}); // idempotente
    const m3a = await explainFind(ref.collection("part").find({ "details.retreadCount": 3 }));
    await ref.collection("part").createIndex({ "details.$**": 1 });
    const m3b = await explainFind(ref.collection("part").find({ "details.retreadCount": 3 }).hint({ "details.$**": 1 }));
    const p3 = await explain(pgc, `SELECT serial_number FROM part WHERE details @> '{"retreadCount": 3}'`);
    const ms = await ref.command({ collStats: "part" });
    const { rows: [gin] } = await pgc.query("SELECT pg_relation_size('part_details_gin') AS b");
    console.log(`Q2 details.tboHours = 6000      Mongo (índice del campo): ${m2.docsExamined} docs → ${m2.returned} · Postgres (GIN): ${p2.examined} filas → ${p2.returned}`);
    console.log(`Q3 details.retreadCount = 3     Mongo sin índice: ${m3a.docsExamined} docs · Mongo comodín details.$**: ${m3b.docsExamined} docs → ${m3b.returned} · Postgres (el mismo GIN): ${p3.examined} filas → ${p3.returned}`);
    console.log(`   índices   Mongo details.tboHours_1 ${kb(ms.indexSizes["details.tboHours_1"])} · Mongo details.$**_1 ${kb(ms.indexSizes["details.$**_1"])} · Postgres GIN jsonb_path_ops ${kb(Number(gin.b))}`);
    console.log(`   degradación en filas examinadas, Postgres / Mongo: Q2 ${(p2.examined / m2.docsExamined).toFixed(2)}× · Q3 ${(p3.examined / m3b.docsExamined).toFixed(2)}×\n`);
  }

  if (only.has("rotura")) {
    // el historial que crece sin cota: lecturas de vuelo embebidas en la ficha, de mil en mil
    const growth = doc.collection("fichaGrowth");
    await growth.drop().catch(() => {});
    const ficha = await doc.collection("aircraft").findOne({}, { sort: { _id: 1 } });
    await growth.insertOne({ ...ficha!, readings: [] });
    const readings: Document[] = [];
    for await (const r of readNdjson<Document>(resolve(dir, "reading.ndjson"))) { readings.push(r); if (readings.length === 1000) break; }
    let total = 0;
    let lastSize = 0;
    let firstError = "";
    let lastError = "";
    // lotes de 1000 hasta el primer fallo, y después de 100, de 10 y de 1: el volumen exacto
    for (const step of [1000, 100, 10, 1]) {
      for (;;) {
        try {
          await growth.updateOne({ _id: ficha!._id }, { $push: { readings: { $each: readings.slice(0, step) } } });
          total += step;
        } catch (e) {
          const err = e as Error & { code?: number; codeName?: string };
          lastError = `${err.name}: ${err.message} (code ${err.code}, ${err.codeName})`;
          firstError ||= lastError;
          break;
        }
      }
    }
    const [s] = await growth.aggregate([{ $project: { s: { $bsonSize: "$$ROOT" } } }]).toArray();
    lastSize = s.s;
    console.log(`rotura: la ficha aceptó exactamente ${total} lecturas (${lastSize} bytes, ${(lastSize / 2 ** 20).toFixed(2)} MB); la siguiente ya no cabe`);
    console.log(`   con 1000 más: ${firstError}`);
    console.log(`   con 1 más:    ${lastError}\n`);
    await growth.drop();
  }

  if (only.has("transacciones")) {
    const fichas = doc.collection("aircraft");
    const [a, b] = await fichas.find({ "installedParts.0": { $exists: true } }, { sort: { _id: 1 }, limit: 2, projection: { _id: 1, installedParts: { $slice: 1 } } }).toArray();
    const moved = a.installedParts[0];
    // mover una pieza de una ficha a otra: dos documentos, una sola transacción
    const session = mongo.startSession();
    try {
      await session.withTransaction(async () => {
        await fichas.updateOne({ _id: a._id }, { $pull: { installedParts: { serialNumber: moved.serialNumber } } }, { session });
        await fichas.updateOne({ _id: b._id }, { $push: { installedParts: moved } }, { session });
      });
      console.log(`transacción: ${moved.serialNumber} pasó de ${a._id} a ${b._id} en una sola transacción (replica set de un nodo)`);
    } finally {
      await session.endSession();
    }
    // dos técnicos tocan la misma ficha a la vez, cada uno una pieza distinta
    const s1 = mongo.startSession();
    const s2 = mongo.startSession();
    try {
      s1.startTransaction();
      s2.startTransaction();
      await fichas.updateOne({ _id: b._id }, { $set: { "installedParts.0.hoursSinceNew": 1 } }, { session: s1 });
      try {
        await fichas.updateOne({ _id: b._id }, { $set: { "installedParts.1.hoursSinceNew": 2 } }, { session: s2 });
        console.log("   la segunda transacción no chocó");
      } catch (e) {
        const err = e as Error & { code?: number; codeName?: string; errorLabels?: string[] };
        console.log(`   dos transacciones sobre la misma ficha, piezas distintas: ${err.name}: ${err.message} (code ${err.code}, ${err.codeName}, etiquetas ${JSON.stringify((err as { errorLabelSet?: Set<string> }).errorLabelSet ? [...(err as { errorLabelSet: Set<string> }).errorLabelSet] : err.errorLabels)})`);
      }
      await s1.abortTransaction();
      await s2.abortTransaction().catch(() => {});
    } finally {
      await s1.endSession();
      await s2.endSession();
    }
    // devolver la pieza a su sitio
    await fichas.updateOne({ _id: b._id }, { $pull: { installedParts: { serialNumber: moved.serialNumber } } });
    await fichas.updateOne({ _id: a._id }, { $push: { installedParts: { $each: [moved], $position: 0 } } });
    console.log("");
  }

  if (only.has("array")) {
    // actualizar una pieza dentro del array embebido: lo que se escribe contra lo que pesa la ficha
    const fichas = doc.collection("aircraft");
    const f = await fichas.findOne({ "installedParts.0": { $exists: true } }, { sort: { _id: 1 } });
    const serial = f!.installedParts[0].serialNumber;
    const [size] = await fichas.aggregate([{ $match: { _id: f!._id } }, { $project: { s: { $bsonSize: "$$ROOT" } } }]).toArray();
    await fichas.updateOne({ _id: f!._id }, { $inc: { "installedParts.$[p].hoursSinceNew": 3 } }, { arrayFilters: [{ "p.serialNumber": serial }] });
    const entry = await mongo.db("local").collection("oplog.rs").findOne({ ns: "condor_doc.aircraft", op: "u" }, { sort: { $natural: -1 } });
    const oplogBytes = Buffer.byteLength(JSON.stringify(entry!.o));
    console.log(`array: $inc de una pieza con arrayFilters en una ficha de ${kb(size.s)} → la entrada del oplog registra ${JSON.stringify(entry!.o)} (≈${oplogBytes} bytes en JSON)`);
    await fichas.updateOne({ _id: f!._id }, { $inc: { "installedParts.$[p].hoursSinceNew": -3 } }, { arrayFilters: [{ "p.serialNumber": serial }] });
  }
} finally {
  await mongo.close();
  await pgc.end();
}
