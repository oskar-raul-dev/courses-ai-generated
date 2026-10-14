// El relevo: el proceso que lleva a CouchDB lo que ya se confirmó en Postgres. Dos fuentes de "qué cambió":
//   outbox · la tabla que la aplicación escribe en la misma transacción que la orden
//   cdc    · el WAL, leído por el slot lógico con test_decoding; la aplicación no escribe nada extra
// En los dos casos se lee la orden entera de Postgres y se escribe en CouchDB, y solo después se da por entregado
// (se borran las filas del outbox, se avanza el slot). Si CouchDB no responde, no se entrega nada y se reintenta:
// lo pendiente espera en Postgres, no en la memoria de este proceso.
//
//   node 24-poliglota-la-costura/relay.ts --mode outbox|cdc   (lo lanza run.ts; se detiene con SIGTERM)
import { parseArgs } from "node:util";
import { SLOT, client, copyToCouch, sleep } from "./common.ts";

const { values } = parseArgs({ options: { mode: { type: "string" }, batch: { type: "string" }, idle: { type: "string", default: "100" } } });
// un lote del WAL cuenta líneas, no órdenes: una orden son su BEGIN, su COMMIT y una línea por fila
const BATCH = Number(values.batch ?? (values.mode === "cdc" ? 5000 : 500)), IDLE = Number(values.idle);
const db = client();
await db.connect();
let stop = false;
process.on("SIGTERM", () => { stop = true; });

/** Un lote del outbox, tomado con SKIP LOCKED para que dos relevos no se pisen; se borra al entregarse. */
async function outboxBatch(): Promise<number> {
  await db.query("BEGIN");
  try {
    const { rows } = await db.query(`SELECT id, work_order_id FROM outbox ORDER BY id LIMIT $1 FOR UPDATE SKIP LOCKED`, [BATCH]);
    if (rows.length) {
      await copyToCouch(db, [...new Set(rows.map((r) => r.work_order_id as string))]);
      await db.query(`DELETE FROM outbox WHERE id = ANY($1)`, [rows.map((r) => r.id)]);
    }
    await db.query("COMMIT");
    return rows.length;
  } catch (e) {
    await db.query("ROLLBACK");
    throw e;
  }
}

/** Un lote del WAL: se mira sin consumir (peek), se entrega, y recién entonces se avanza el slot hasta ahí. */
const CHANGED = /^table public\.work_order: (?:INSERT|UPDATE): work_order_id\[text\]:'([^']+)'/;
async function cdcBatch(): Promise<number> {
  const { rows } = await db.query(`SELECT lsn, data FROM pg_logical_slot_peek_changes($1, NULL, $2)`, [SLOT, BATCH]);
  if (!rows.length) return 0;
  const ids = new Set<string>();
  for (const r of rows) { const m = CHANGED.exec(r.data); if (m) ids.add(m[1]); }
  await copyToCouch(db, [...ids]);
  await db.query(`SELECT pg_replication_slot_advance($1, $2)`, [SLOT, rows.at(-1).lsn]);
  return ids.size;
}

const step = values.mode === "cdc" ? cdcBatch : outboxBatch;
while (!stop) {
  try {
    if (!(await step())) await sleep(IDLE);
  } catch {
    await sleep(1000);   // CouchDB caído: lo pendiente sigue en Postgres
  }
}
await db.end();
