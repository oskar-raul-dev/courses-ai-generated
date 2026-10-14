// La reconstrucción completa: el servidor de las tabletas armado de cero desde Postgres, en una base nueva de CouchDB.
// Se escribe al lado de la vigente y no encima: mientras se arma, las tabletas siguen sincronizando con la vieja, y el
// cambio es apuntar la aplicación a la nueva cuando la comparación da cero distintas.
//
//   node 24-poliglota-la-costura/rebuild.ts [--db postgres] [--couch work_order_1m_v2]   (desde src/, con base y offline)
import { parseArgs } from "node:util";
import { couch, freshRemote } from "../lab/harness/couch.ts";
import { ORDER_DOC, client, retry } from "./common.ts";

const { values } = parseArgs({ options: { db: { type: "string", default: "postgres" }, couch: { type: "string", default: "work_order_1m_v2" } } });
const PAGE = 10_000, BULK = 2000;

await freshRemote(values.couch!);
const db = client(values.db);
await db.connect();
const t0 = performance.now();
let written = 0;
await db.query("BEGIN");
await db.query(`DECLARE orders NO SCROLL CURSOR FOR ${ORDER_DOC} ORDER BY w.work_order_id`);
for (;;) {
  const { rows } = await db.query(`FETCH ${PAGE} FROM orders`);
  if (!rows.length) break;
  // documentos nuevos en una base vacía: sin revisión que buscar, un _bulk_docs por cada 2000
  for (let i = 0; i < rows.length; i += BULK) {
    const docs = rows.slice(i, i + BULK).map((r) => ({ _id: r.id, ...r.doc }));
    await retry(() => couch(`${values.couch}/_bulk_docs`, { method: "POST", body: JSON.stringify({ docs }) }));
  }
  written += rows.length;
  if (written % 100_000 === 0) console.log(`  ${written} · ${((performance.now() - t0) / 1000).toFixed(0)} s`);
}
await db.query("COMMIT");
await db.end();
const seconds = (performance.now() - t0) / 1000;
const info = await couch<{ doc_count: number; sizes: { file: number } }>(values.couch!);
console.log(`${values.db} → ${values.couch} · ${written} órdenes en ${seconds.toFixed(0)} s (${(written / seconds).toFixed(0)}/s) · ${info.doc_count} documentos · ${(info.sizes.file / 2 ** 20).toFixed(0)} MiB`);
