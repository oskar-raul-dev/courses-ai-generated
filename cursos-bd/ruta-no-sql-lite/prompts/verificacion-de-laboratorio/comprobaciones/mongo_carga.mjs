// Prueba de carga de hallazgos.md §H1: ¿la 8.0.20 aguanta carga sobre un kernel del rango
// roto (6.19–7.0.13), o cae con SIGSEGV como las 8.x sin protección?
// Escritura y lectura concurrentes sostenidas, con muchos hilos del servidor ocupados a la vez,
// que es lo que provoca migraciones de CPU. Si mongod cae, el driver lo reporta y el script
// termina con código 1; el estado del contenedor lo confirma medir-carga.sh.
// Uso: node mongo_carga.mjs <uri> <minutos> <trabajadores>
import { MongoClient } from "mongodb";

const [uri = "mongodb://127.0.0.1:27017/?directConnection=true", minutes = "10", workers = "32"] =
  process.argv.slice(2);
const deadline = Date.now() + Number(minutes) * 60_000;

const client = new MongoClient(uri, { maxPoolSize: Number(workers) + 4 });
await client.connect();
const col = client.db("condor").collection("workOrders");
await col.drop().catch(() => {});
await col.createIndex({ aircraft: 1, openedAt: -1 });

let ops = 0;
let failures = 0;

const worker = async (w) => {
  let i = 0;
  while (Date.now() < deadline) {
    const aircraft = `HK-${4000 + ((w * 7 + i) % 140)}`;
    try {
      // lote de 200 órdenes, una lectura por índice y una actualización con array creciente
      await col.insertMany(
        Array.from({ length: 200 }, (_, k) => ({
          aircraft,
          openedAt: new Date(),
          tasks: Array.from({ length: 8 }, (_, t) => ({ code: `T${t}`, hours: (k + t) % 5 })),
          notes: "inspeccion de tren, sin novedad ".repeat(4),
        })),
        { ordered: false },
      );
      await col.find({ aircraft }).sort({ openedAt: -1 }).limit(50).toArray();
      await col.updateMany({ aircraft }, { $push: { log: { at: new Date(), by: `tec-${w}` } } });
      ops += 3;
    } catch (e) {
      failures++;
      console.error(`[${new Date().toISOString()}] trabajador ${w}: ${e.name}: ${e.message}`);
      if (failures > 20) throw e;
    }
    i++;
  }
};

const ticker = setInterval(
  () => console.log(`[${new Date().toISOString()}] operaciones: ${ops} · fallos: ${failures}`),
  30_000,
);
try {
  await Promise.all(Array.from({ length: Number(workers) }, (_, w) => worker(w)));
} finally {
  clearInterval(ticker);
}
console.log(`FIN · operaciones: ${ops} · fallos: ${failures} · documentos: ${await col.estimatedDocumentCount()}`);
await client.close();
process.exit(failures > 0 ? 1 : 0);
