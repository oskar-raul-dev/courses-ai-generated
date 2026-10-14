// El servidor de la Fase 20: las 1 000 000 de órdenes de workOrder-1m en work_order_1m, por _bulk_docs de
// a 10 000, sin PouchDB en el medio. Lo que se mide es lo que ocupa: vivo contra archivo.
//
//   node 20-offline-romper-y-medir/load.ts   (desde src/, con offline arriba)
import { createReadStream } from "node:fs";
import { createInterface } from "node:readline";
import { couch, freshRemote } from "../lab/harness/couch.ts";
import { verifyDataset } from "../lab/harness/dataset.ts";
import { DATASET } from "./scenario.ts";

const MiB = (n: number) => `${(n / 2 ** 20).toFixed(0)} MiB`;
await verifyDataset(DATASET);
await freshRemote("work_order_1m");
const t0 = performance.now();
let batch: string[] = [], total = 0;
const flush = async () => {
  const res = await couch<any[]>("work_order_1m/_bulk_docs", { method: "POST", body: `{"docs":[${batch.join(",")}]}` });
  const failed = res.filter((r) => r.error);
  if (failed.length) throw new Error(`${failed.length} documentos rechazados: ${JSON.stringify(failed[0])}`);
  total += batch.length;
  batch = [];
};
for await (const line of createInterface({ input: createReadStream(`${DATASET}/workOrder.ndjson`) })) {
  if (!line) continue;
  // el _id es el número de orden: se antepone al registro sin parsearlo
  batch.push(`{"_id":${JSON.stringify(/"workOrderId":"([^"]+)"/.exec(line)![1])},${line.slice(1)}`);
  if (batch.length === 10_000) await flush();
}
if (batch.length) await flush();
const info = await couch("work_order_1m");
console.log(`work_order_1m · ${info.doc_count} órdenes en ${((performance.now() - t0) / 1000).toFixed(0)} s · ` +
  `vivos ${MiB(info.sizes.active)} · archivo ${MiB(info.sizes.file)} · NDJSON ${MiB(522676391)}`);
