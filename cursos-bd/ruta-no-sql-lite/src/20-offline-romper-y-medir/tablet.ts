// El tamaño razonable de la tableta: la primera bajada desde work_order_1m con un filtro cada vez más ancho
// —las cien órdenes del viaje, sus 87 aeronaves con toda su historia, la base de Villavicencio, el millón—,
// y lo que cuesta en el cable, en el reloj, en el disco de la tableta y en la memoria del proceso.
//
//   node 20-offline-romper-y-medir/tablet.ts [--skip-all]   (desde src/, después de load.ts)
import { parseArgs } from "node:util";
import { freshTablet, newWire, remote, tabletBytes } from "../lab/harness/couch.ts";
import { loadTrip } from "./scenario.ts";

const { values: args } = parseArgs({ options: { "skip-all": { type: "boolean", default: false } } });
const MiB = (n: number) => `${(n / 2 ** 20).toFixed(1)} MiB`;
const trip = await loadTrip(100);

const filters: [string, object][] = [
  ["las 100 órdenes del viaje (doc_ids)", { doc_ids: trip.orders.map((o) => o.workOrderId) }],
  [`sus ${trip.aircraft.length} aeronaves, con su historia (selector)`, { selector: { aircraft: { $in: trip.aircraft } } }],
  ["la base de Villavicencio (selector)", { selector: { hangarId: "VVC" } }],
  ...(args["skip-all"] ? [] : [["todo work_order_1m", {}] as [string, object]]),
];

for (const [label, filter] of filters) {
  const name = `size-${filters.findIndex(([l]) => l === label)}`;
  const tablet = freshTablet(name);
  const wire = newWire();
  const t0 = performance.now();
  const r = await tablet.replicate.from(remote("work_order_1m", wire), filter as any);
  const seconds = (performance.now() - t0) / 1000;
  const rss = process.memoryUsage().rss;
  await tablet.close();
  console.log(`${label.padEnd(48)} · ${String(r.docs_written).padStart(7)} órdenes · ${String(wire.requests).padStart(5)} peticiones · ` +
    `bajados ${MiB(wire.down).padStart(9)} · ${seconds.toFixed(0).padStart(4)} s · en la tableta ${MiB(tabletBytes(name)).padStart(9)} · ` +
    `memoria del proceso ${MiB(rss)}`);
}
