// El conflicto masivo: Freddy (T-004) y Jairo (T-009) editan las mismas cien órdenes todo el día, cada uno en
// su tableta, con la forma de siempre (una orden por documento) y sin resolver nada. Cada ronda, cada uno
// guarda una vez cada orden y los dos sincronizan. Después, la compactación del servidor y de la tableta: qué
// libera, qué no, y qué se lleva.
//
//   node 20-offline-romper-y-medir/massive.ts [--rounds 10]   (desde src/, con offline arriba)
import { parseArgs } from "node:util";
import { conflicts, couch, freshRemote, freshTablet, openTablet, remote, tabletBytes, type Db } from "../lab/harness/couch.ts";
import { verifyDataset } from "../lab/harness/dataset.ts";
import { orderDoc } from "../19-offline-levantar-y-modelar/trip.ts";
import { DATASET, loadTrip } from "./scenario.ts";

const { values: args } = parseArgs({ options: { rounds: { type: "string", default: "10" } } });
const KiB = (n: number) => `${(n / 1024).toFixed(0)} KiB`;

await verifyDataset(DATASET);
const { orders } = await loadTrip(100);
await freshRemote("f20_massive");
const server = remote("f20_massive");
await server.bulkDocs(orders.flatMap((o) => orderDoc.seed(o)));
const first = orders[0].workOrderId;
const firstRev = (await server.get(first))._rev;
const tablets: [string, Db][] = [["freddy", freshTablet("massive-freddy")], ["jairo", freshTablet("massive-jairo")]];
for (const [, t] of tablets) await t.replicate.from(server);

/** Hojas por documento en el servidor: la ganadora más las perdedoras. */
async function leafStats() {
  const rows = (await server.allDocs({ include_docs: true, conflicts: true })).rows;
  const leaves = rows.map((r) => 1 + (r.doc?._conflicts?.length ?? 0));
  return { docs: leaves.filter((n) => n > 1).length, max: Math.max(...leaves), total: leaves.reduce((a, b) => a + b, 0) };
}

for (let round = 1; round <= Number(args.rounds); round++) {
  for (const [who, t] of tablets) {
    for (const o of orders) {
      const d: any = await t.get(o.workOrderId);           // la ganadora, la única que ve la app
      d.notes = [...d.notes, `${who}, ronda ${round}`];
      d.updatedAt = `2026-09-21T${String(6 + round).padStart(2, "0")}:00:00-05:00`;
      await t.put(d);
    }
  }
  for (const [, t] of [...tablets, tablets[0]]) await t.sync(server);
  const s = await leafStats();
  const info = await couch("f20_massive");
  console.log(`ronda ${String(round).padStart(2)} · documentos con conflicto ${s.docs} · hojas: máximo ${s.max} por documento, ${s.total} en total · ` +
    `servidor vivos ${KiB(info.sizes.active)}, archivo ${KiB(info.sizes.file)}`);
}

// la compactación del servidor: se pide y se espera a que termine
const ancestor = async () => {
  const r = await couch(`f20_massive/${first}?rev=${firstRev}`);
  return r.error ? `${r.error} (${r.reason})` : "disponible";
};
const before = await couch("f20_massive");
const ancestorBefore = await ancestor();
await couch("f20_massive/_compact", { method: "POST" });
let info = await couch("f20_massive");
while (info.compact_running) { await new Promise((ok) => setTimeout(ok, 200)); info = await couch("f20_massive"); }
const afterLeaves = await leafStats();
console.log(`servidor compactado · archivo ${KiB(before.sizes.file)} → ${KiB(info.sizes.file)} · vivos ${KiB(info.sizes.active)} · ` +
  `hojas en total ${afterLeaves.total} (conflictos ${(await conflicts(server)).docs.length}) · ` +
  `revisión 1 de ${first}: ${ancestorBefore} → ${await ancestor()}`);

// la tableta: cerrada para medir, abierta para compactar
const [, freddy] = tablets[0];
const firstLocal = async (db: Db) => db.get(first, { rev: firstRev } as any).then(() => "disponible", (e: any) => `${e.status} ${e.message}`);
const localBefore = await firstLocal(freddy);
for (const [, t] of tablets) await t.close();
const bytesBefore = tabletBytes("massive-freddy");
const again = openTablet("massive-freddy");
await again.compact();
const localAfter = await firstLocal(again);
const localConflicts = (await conflicts(again)).docs.length;
await again.close();
console.log(`tableta de Freddy compactada · ${KiB(bytesBefore)} → ${KiB(tabletBytes("massive-freddy"))} · conflictos ${localConflicts} · ` +
  `revisión 1 de ${first}: ${localBefore} → ${localAfter}`);
await server.close();
