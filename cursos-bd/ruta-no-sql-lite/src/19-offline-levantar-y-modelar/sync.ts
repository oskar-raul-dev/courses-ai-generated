// La replicación medida en el cable: el servidor con las 10 000 órdenes de workOrder-10k (las cuatro del
// viaje, reabiertas), la tableta de Freddy que baja todo o solo sus cuatro aeronaves, los tres días sin
// señal, y lo que sube al volver. Después, el historial de una orden: qué guarda la tableta y qué el servidor.
//
//   node 19-offline-levantar-y-modelar/sync.ts   (desde src/, con offline arriba)
import { couch, freshRemote, freshTablet, newWire, remote, type Wire } from "../lab/harness/couch.ts";
import { verifyDataset } from "../lab/harness/dataset.ts";
import { DATASET, FREDDY, loadOrders, orderDoc, tripSelector } from "./trip.ts";

const KiB = (n: number) => `${(n / 1024).toFixed(0)} KiB`;
const line = (label: string, w: Wire, r?: { docs_read: number; docs_written: number }, extra = "") =>
  console.log(`  ${label.padEnd(34)} ${r ? `docs leídos ${String(r.docs_read).padStart(5)} · escritos ${String(r.docs_written).padStart(5)} · ` : ""}` +
    `peticiones ${String(w.requests).padStart(3)} · subidos ${KiB(w.up).padStart(8)} · bajados ${KiB(w.down).padStart(9)}${extra}`);

await verifyDataset(DATASET);
const { history, trip } = await loadOrders();
await freshRemote("work_order");
await remote("work_order").bulkDocs([...history, ...trip.flatMap((o) => orderDoc.seed(o))]);
const info = await couch("work_order");
console.log(`servidor · work_order · ${info.doc_count} órdenes · ${KiB(info.sizes.active)} vivos · ${KiB(info.sizes.file)} en disco · _revs_limit ${await couch("work_order/_revs_limit")}`);

console.log("lunes, en Villavicencio, con señal");
let w = newWire();
const full = freshTablet("freddy-full");
let r = await full.replicate.from(remote("work_order", w));
line("todo work_order", w, r);
await full.close();

w = newWire();
const freddy = freshTablet("freddy");
r = await freddy.replicate.from(remote("work_order", w), { selector: tripSelector } as any);
line("sus cuatro aeronaves (selector)", w, r);
w = newWire();
r = await freddy.replicate.from(remote("work_order", w), { selector: tripSelector } as any);
line("otra vez, sin nada nuevo", w, r);

console.log(`lunes a miércoles, sin señal: ${FREDDY.length} guardados en la tableta`);
for (const e of FREDDY) await orderDoc.apply(freddy, e);
const local: any = await freddy.get("WO-0009941", { revs: true, revs_info: true } as any);
console.log(`  WO-0009941 en la tableta: revisión ${local._rev.slice(0, 10)}… · historia de ${local._revisions.ids.length} revisiones · ` +
  local._revs_info.map((x: any) => `${x.rev.split("-")[0]} ${x.status}`).join(", "));

console.log("jueves, de vuelta en Villavicencio");
w = newWire();
r = await freddy.replicate.to(remote("work_order", w));
line("subir lo del viaje", w, r);
w = newWire();
r = await freddy.replicate.from(remote("work_order", w), { selector: tripSelector } as any);
line("bajar lo nuevo", w, r);
// la primera subida le pregunta al servidor por todo lo que la tableta tiene, también lo que bajó de él;
// desde ahí, cada subida empieza donde quedó la anterior
await orderDoc.apply(freddy, { by: "T-004", at: "2026-09-24T17:00:00-05:00", wo: "WO-0009941", kind: "note", text: "cierre de viaje" });
w = newWire();
r = await freddy.replicate.to(remote("work_order", w));
line("una edición más, otra subida", w, r);
const server: any = await remote("work_order").get("WO-0009941", { revs: true, revs_info: true } as any);
console.log(`  WO-0009941 en el servidor: historia de ${server._revisions.ids.length} revisiones · ` +
  server._revs_info.map((x: any) => `${x.rev.split("-")[0]} ${x.status}`).join(", "));
const after = await couch("work_order");
console.log(`servidor · ${after.doc_count} órdenes · ${KiB(after.sizes.active)} vivos · ${KiB(after.sizes.file)} en disco`);
await freddy.close();

// la base de Villavicencio con su propio CouchDB: una replicación persistente, guardada como documento en
// _replicator, que el servidor ejecuta y reintenta solo (sin _replicator no hay dónde guardarla: E-09)
await freshRemote("work_order_vvc");
const old = await couch("_replicator/vvc");
if (old._rev) await couch(`_replicator/vvc?rev=${old._rev}`, { method: "DELETE" });
const src = (db: string) => ({ url: `http://localhost:5984/${db}`, auth: { basic: { username: "condor", password: "condor" } } });
await couch("_replicator/vvc", { method: "PUT", body: JSON.stringify({ source: src("work_order"), target: src("work_order_vvc"), selector: tripSelector }) });
let job: any;
for (let i = 0; i < 60; i++) {
  job = await couch("_scheduler/docs/_replicator/vvc");
  if (job.state === "completed" || job.state === "failed") break;
  await new Promise((ok) => setTimeout(ok, 500));
}
console.log(`replicación persistente work_order → work_order_vvc · estado ${job.state} · docs leídos ${job.info?.docs_read} · escritos ${job.info?.docs_written} · ` +
  `en la base de Villavicencio ${(await couch("work_order_vvc")).doc_count}`);
