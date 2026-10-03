// El sistema que Yamile heredó (boss del Bloque I): dos terminales de plataforma abren la misma
// orden de trabajo para el mismo reporte de piloto. Cada terminal toma un candado en Valkey,
// comprueba en Mongo que la orden no exista, la crea y suelta el candado. Algo falla, porque cada
// tanto la orden entra dos veces. Este script reproduce el sistema tal como está: no lo arregles
// aquí; encuentra por qué duplica.
//
//   node 06-clave-valor-romper-y-medir/boss/sistema-roto.ts [--rounds 200]
//                                (desde src/, con los perfiles documental y clave-valor arriba)
import { parseArgs } from "node:util";
import { MongoClient } from "mongodb";
import { Valkey } from "iovalkey";

const { values: args } = parseArgs({ options: { rounds: { type: "string", default: "200" } } });
const mongo = new MongoClient(`mongodb://localhost:${process.env.DOCUMENTAL_PORT ?? 27018}/?directConnection=true`);
await mongo.connect();
const orders = mongo.db("condor_boss").collection("workOrder");
await orders.drop().catch(() => {});
const terminal = async () => { const v = new Valkey({ host: "localhost", port: Number(process.env.CLAVE_VALOR_PORT ?? 16379), lazyConnect: true }); await v.connect(); return v; };
const [t2, t5] = await Promise.all([terminal(), terminal()]);
const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));

// lo que hace cada terminal al abrir una orden para un reporte de piloto
async function openWorkOrder(v: Valkey, terminalId: string, pirepId: string): Promise<string> {
  const lock = `lock:pirep:${pirepId}`;
  // el candado dura 150 ms: "abrir una orden es rápido"
  for (;;) {
    if (await v.set(lock, terminalId, "PX", 150, "NX")) break;
    await sleep(5);
  }
  try {
    const existing = await orders.findOne({ pirepId });
    if (existing) return "ya existía";
    // armar la orden: técnicos disponibles, puesto, tareas… (a veces tarda)
    await sleep(100 + Math.floor(Math.random() * 100));
    await orders.insertOne({ pirepId, aircraft: "HK-5339", openedBy: terminalId, openedAt: new Date() });
    return "creada";
  } finally {
    await v.del(lock);
  }
}

let rounds = 0;
for (let i = 0; i < Number(args.rounds); i++) {
  const pirepId = `PR-BOSS-${i}`;
  await Promise.all([openWorkOrder(t2, "terminal-2", pirepId), openWorkOrder(t5, "terminal-5", pirepId)]);
  rounds++;
}
const dup = await orders.aggregate([{ $group: { _id: "$pirepId", n: { $sum: 1 } } }, { $match: { n: { $gt: 1 } } }, { $count: "duplicados" }]).toArray();
console.log(`${rounds} reportes, dos terminales cada uno: ${await orders.countDocuments()} órdenes creadas · reportes con la orden duplicada: ${dup[0]?.duplicados ?? 0}`);
await t2.quit(); await t5.quit(); await mongo.close();
