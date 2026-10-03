// Mediciones complementarias de la Fase 04: el conflicto de 4.5 en Postgres, los viajes de una
// transacción en Mongo y el espacio en disco de los mismos datos en los dos motores.
//
//   node 04-documental-romper-y-medir/extra.ts        (desde src/, con documental y base cargados)
import pg from "pg";
import { MongoClient } from "mongodb";
import { countMongoRoundTrips } from "../lab/harness/roundtrips.ts";

const conn = () => new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "postgres" });
const [a, b] = [conn(), conn()];
await a.connect();
await b.connect();
const mongo = new MongoClient(`mongodb://localhost:${process.env.DOCUMENTAL_PORT ?? 27018}/?directConnection=true`, { monitorCommands: true });
const trips = countMongoRoundTrips(mongo);
await mongo.connect();
try {
  // 1 · dos técnicos, dos piezas distintas de la misma aeronave, dos transacciones a la vez
  const { rows: [p1, p2] } = await a.query("SELECT serial_number FROM part WHERE aircraft = 'HC-10265' AND status = 'installed' ORDER BY position LIMIT 2");
  await a.query("BEGIN");
  await b.query("BEGIN");
  await a.query("UPDATE part SET hours_since_new = hours_since_new + 1 WHERE serial_number = $1", [p1.serial_number]);
  await b.query("SET LOCAL lock_timeout = '2s'");
  const t0 = performance.now();
  try {
    await b.query("UPDATE part SET hours_since_new = hours_since_new + 1 WHERE serial_number = $1", [p2.serial_number]);
    console.log(`Postgres, piezas distintas: la segunda transacción actualizó sin esperar (${Math.round(performance.now() - t0)} ms)`);
  } catch (e) { console.log(`Postgres, piezas distintas: ${(e as Error).message}`); }
  await b.query("ROLLBACK");
  await b.query("BEGIN");
  await b.query("SET LOCAL lock_timeout = '2s'");
  try {
    await b.query("UPDATE part SET hours_since_new = hours_since_new + 1 WHERE serial_number = $1", [p1.serial_number]);
    console.log("Postgres, la misma pieza: actualizó");
  } catch (e) { console.log(`Postgres, la misma pieza: ${(e as Error).message} (espera al primero; con lock_timeout de 2 s)`); }
  await b.query("ROLLBACK");
  await a.query("ROLLBACK");

  // 2 · cuántos viajes cuesta mover una pieza entre dos fichas en una transacción de Mongo
  const fichas = mongo.db("condor_doc").collection("aircraft");
  const [x, y] = await fichas.find({ "installedParts.0": { $exists: true } }, { sort: { _id: 1 }, limit: 2, projection: { installedParts: { $slice: 1 } } }).toArray();
  const moved = x.installedParts[0];
  const session = mongo.startSession();
  trips.reset();
  await session.withTransaction(async () => {
    await fichas.updateOne({ _id: x._id }, { $pull: { installedParts: { serialNumber: moved.serialNumber } } }, { session });
    await fichas.updateOne({ _id: y._id }, { $push: { installedParts: moved } }, { session });
  });
  console.log(`Mongo, mover una pieza en una transacción: ${trips.count} viajes ${JSON.stringify(trips.byCommand)}`);
  await session.endSession();
  await fichas.updateOne({ _id: y._id }, { $pull: { installedParts: { serialNumber: moved.serialNumber } } });
  await fichas.updateOne({ _id: x._id }, { $push: { installedParts: { $each: [moved], $position: 0 } } });

  // 3 · el espacio de los mismos datos
  const mb = (n: number) => `${(n / 2 ** 20).toFixed(0)} MB`;
  for (const name of ["condor_ref", "condor_doc"]) {
    const s = await mongo.db(name).stats();
    console.log(`Mongo ${name}: datos sin comprimir ${mb(s.dataSize)} · en disco ${mb(s.storageSize)} · índices ${mb(s.indexSize)}`);
  }
  const part = await mongo.db("condor_ref").command({ collStats: "part" });
  console.log(`Mongo condor_ref.part: sin comprimir ${mb(part.size)} · en disco ${mb(part.storageSize)} · índices ${mb(part.totalIndexSize)}`);
  const { rows: [pp] } = await a.query("SELECT pg_table_size('part') AS t, pg_indexes_size('part') AS i, pg_database_size('postgres') AS d");
  console.log(`Postgres part: tabla ${mb(Number(pp.t))} · índices ${mb(Number(pp.i))} · base entera ${mb(Number(pp.d))}`);
} finally {
  await a.end();
  await b.end();
  await mongo.close();
}
