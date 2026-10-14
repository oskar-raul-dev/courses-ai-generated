// El historial de revisiones: una orden que se guarda N veces en la tableta sin señal y después sube. Qué
// viaja (la lista de antepasados va con cada documento), cuánto ocupa en la tableta y en el servidor, y
// dónde lo corta _revs_limit (1000 por defecto, en los dos lados).
//
//   node 20-offline-romper-y-medir/history.ts   (desde src/, con offline arriba)
import { couch, freshRemote, freshTablet, newWire, openTablet, remote, tabletBytes } from "../lab/harness/couch.ts";

const KiB = (n: number) => `${(n / 1024).toFixed(0)} KiB`;
const order = { _id: "WO-0999999", aircraft: "HK-4235", status: "open", labor: {} as Record<string, number> };

for (const n of [1, 10, 100, 1000, 2000]) {
  await freshRemote("f20_history");
  const tablet = freshTablet("history");
  await tablet.put(structuredClone(order));
  for (let k = 1; k < n; k++) {
    const d: any = await tablet.get(order._id);
    d.labor["T-004"] = k;                       // cada guardado suma una hora
    await tablet.put(d);
  }
  const local: any = await tablet.get(order._id, { revs: true } as any);
  const wire = newWire();
  await tablet.replicate.to(remote("f20_history", wire));
  const server: any = await couch(`f20_history/${order._id}?revs=true`);
  const info = await couch("f20_history");
  await tablet.close();
  const before = tabletBytes("history");
  const again = openTablet("history");
  await again.compact();
  await again.close();
  console.log(`${String(n).padStart(5)} guardados · tableta: historia ${String(local._revisions.ids.length).padStart(4)} · ` +
    `${KiB(before).padStart(8)} → ${KiB(tabletBytes("history")).padStart(7)} compactada · ` +
    `subida: ${wire.requests} peticiones, ${KiB(wire.up).padStart(6)} · servidor: historia ${String(server._revisions.ids.length).padStart(4)}, ` +
    `vivos ${KiB(info.sizes.active)}, archivo ${KiB(info.sizes.file)}`);
}

