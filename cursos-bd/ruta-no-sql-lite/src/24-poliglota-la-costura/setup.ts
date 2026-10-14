// Deja la costura en cero: la base `costura` copiada de `expediente` (las 10 000 órdenes de la Fase 19 y todo lo que
// referencian), su tabla outbox, el slot lógico del CDC y una base `costura` vacía en CouchDB con esas mismas órdenes,
// como si la costura llevara tiempo funcionando. Con --drop, borra el slot y la base: hay que hacerlo antes de volver
// al compose de siempre, porque con un slot lógico vivo y wal_level=replica Postgres no arranca.
//
//   node 24-poliglota-la-costura/setup.ts [--drop]   (desde src/, con lab/compose.costura.yaml)
import { parseArgs } from "node:util";
import { freshRemote } from "../lab/harness/couch.ts";
import { COUCH, DB, ORDER_DOC, SLOT, client, putDocs, retry } from "./common.ts";

const { values } = parseArgs({ options: { drop: { type: "boolean", default: false } } });

const admin = client("postgres");
await admin.connect();
await admin.query(`SELECT pg_drop_replication_slot(slot_name) FROM pg_replication_slots WHERE slot_name = $1`, [SLOT]);
await admin.query(`DROP DATABASE IF EXISTS ${DB}`);
if (values.drop) {
  await admin.end();
  console.log(`slot ${SLOT} y base ${DB} borrados`);
  process.exit(0);
}
await admin.query(`CREATE DATABASE ${DB} TEMPLATE expediente`);
await admin.end();

const db = client();
await db.connect();
await db.query(`CREATE TABLE outbox (id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY, work_order_id text NOT NULL,
                                     created_at timestamptz NOT NULL DEFAULT clock_timestamp())`);
// test_decoding viene con Postgres: escribe cada cambio como una línea de texto, y basta para saber qué orden cambió
await db.query(`SELECT pg_create_logical_replication_slot($1, 'test_decoding')`, [SLOT]);

await retry(() => freshRemote(COUCH));
const { rows } = await db.query(ORDER_DOC);
for (let i = 0; i < rows.length; i += 2000) await retry(() => putDocs(rows.slice(i, i + 2000).map((r) => ({ _id: r.id, ...r.doc }))));
await db.end();
console.log(`base ${DB} y CouchDB ${COUCH}: ${rows.length} órdenes · outbox vacío · slot ${SLOT} creado`);
