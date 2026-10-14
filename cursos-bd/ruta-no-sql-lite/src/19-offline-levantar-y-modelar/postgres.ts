// Lo que haría Postgres con el mismo viaje. No corre en la tableta: cada técnico guarda en una cola local
// y la vacía al volver a tener señal, Jairo primero y Freddy después. Dos formas del servidor:
//   1 · la orden como documento con columna de versión (bloqueo optimista): un guardado cuya versión ya
//       no es la del servidor se rechaza. Se prueba subiendo cada guardado (1a) y una vez por orden (1b);
//   2 · una fila por cosa que se edita, con la restricción del dominio —una posición, un serial
//       instalado por orden— declarada en la tabla.
//
//   node 19-offline-levantar-y-modelar/postgres.ts   (desde src/, con base arriba)
import pg from "pg";
import { verifyDataset } from "../lab/harness/dataset.ts";
import { DATASET, FREDDY, JAIRO, found, loadOrders, orderDoc, type Edit } from "./trip.ts";

const db = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "postgres" });
await db.connect();
await verifyDataset(DATASET);
const { trip } = await loadOrders();
const seeds = trip.flatMap((o) => orderDoc.seed(o));

// ── 1 · documento con versión ──────────────────────────────────────────────────────────────────────
/** La tableta sin señal: aplica cada edición a su copia, con la misma función de la app, y encola cada
 *  guardado con la versión que la tableta cree que tiene el servidor (la leída más sus propios guardados). */
async function offlineQueue(edits: Edit[]) {
  const copy = new Map(seeds.map((d) => [d._id, { doc: structuredClone(d), version: 1 }]));
  const queue: { wo: string; doc: any; expected: number; e: Edit }[] = [];
  let current: Edit | undefined;
  const tablet = {
    get: async (id: string) => structuredClone(copy.get(id)!.doc),
    put: async (doc: any) => { const c = copy.get(doc._id)!; queue.push({ wo: doc._id, doc, expected: c.version, e: current! }); c.doc = doc; c.version++; },
  };
  for (const e of edits) { current = e; await orderDoc.apply(tablet as any, e); }
  return queue;
}

async function drain(who: string, q: Awaited<ReturnType<typeof offlineQueue>>) {
  let applied = 0, rejected = 0;
  for (const s of q) {
    const r = await db.query(`UPDATE offline.work_order SET doc = $2, version = version + 1 WHERE work_order_id = $1 AND version = $3`, [s.wo, s.doc, s.expected]);
    if (r.rowCount === 1) applied++; else rejected++;
  }
  console.log(`  ${who.padEnd(6)} guardados aplicados ${applied}/${q.length} · rechazados ${rejected}`);
}

/** Cuántas ediciones de cada técnico están en los documentos que quedaron en el servidor. */
async function tally() {
  const docs = new Map((await db.query(`SELECT work_order_id, doc FROM offline.work_order`)).rows.map((r) => [r.work_order_id, r.doc]));
  const kept = (edits: Edit[]) => edits.filter((e) => found(orderDoc.leafView(docs.get(e.wo)), e) === "kept").length;
  console.log(`  quedan de Freddy ${kept(FREDDY)}/${FREDDY.length} · de Jairo ${kept(JAIRO)}/${JAIRO.length}`);
}

async function reset() {
  await db.query(`DROP SCHEMA IF EXISTS offline CASCADE; CREATE SCHEMA offline`);
  await db.query(`CREATE TABLE offline.work_order (work_order_id text PRIMARY KEY, doc jsonb NOT NULL, version int NOT NULL)`);
  for (const d of seeds) await db.query(`INSERT INTO offline.work_order VALUES ($1, $2, 1)`, [d._id, d]);
}

const [freddyQueue, jairoQueue] = [await offlineQueue(FREDDY), await offlineQueue(JAIRO)];

console.log("1a · la orden como documento con versión, un UPDATE por guardado");
await reset();
await drain("Jairo", jairoQueue);
await drain("Freddy", freddyQueue);
await tally();

console.log("1b · la orden como documento con versión, una subida por orden (su último estado, con la versión leída al salir)");
await reset();
const lastPerOrder = (q: typeof freddyQueue) => [...new Map(q.map((s) => [s.wo, { ...s, expected: 1 }])).values()];
await drain("Jairo", lastPerOrder(jairoQueue));
await drain("Freddy", lastPerOrder(freddyQueue));
await tally();

// ── 2 · una fila por cosa, con la restricción del dominio ───────────────────────────────────────────
console.log("2 · una fila por cosa, con la posición única por orden");
await db.query(`
  CREATE TABLE offline.task_signature (work_order_id text, task text, technician_id text, signed_at timestamptz, PRIMARY KEY (work_order_id, task, technician_id));
  CREATE TABLE offline.part_swap (work_order_id text, position text, removed text, installed text, technician_id text, at timestamptz,
                                  CONSTRAINT one_install_per_position UNIQUE (work_order_id, position));
  CREATE TABLE offline.labor (work_order_id text, technician_id text, hours int, PRIMARY KEY (work_order_id, technician_id));
  CREATE TABLE offline.open_item (work_order_id text, item text, closed_by text, PRIMARY KEY (work_order_id, item));
  CREATE TABLE offline.note (work_order_id text, technician_id text, at timestamptz, text text);`);
for (const d of seeds) for (const i of d.openItems) await db.query(`INSERT INTO offline.open_item VALUES ($1, $2, NULL)`, [d._id, i]);

/** Cada edición, como la orden que la app manda al servidor: una sentencia, no un documento entero. */
async function command(e: Edit): Promise<void> {
  if (e.kind === "task") await db.query(`INSERT INTO offline.task_signature VALUES ($1, $2, $3, $4)`, [e.wo, e.task, e.by, e.at]);
  if (e.kind === "swap") await db.query(`INSERT INTO offline.part_swap VALUES ($1, $2, $3, $4, $5, $6)`, [e.wo, e.position, e.removed, e.installed, e.by, e.at]);
  if (e.kind === "labor") await db.query(`INSERT INTO offline.labor VALUES ($1, $2, $3) ON CONFLICT (work_order_id, technician_id) DO UPDATE SET hours = labor.hours + EXCLUDED.hours`, [e.wo, e.by, e.hours]);
  if (e.kind === "closeItem") await db.query(`UPDATE offline.open_item SET closed_by = coalesce(closed_by, $3) WHERE work_order_id = $1 AND item = $2`, [e.wo, e.item, e.by]);
  if (e.kind === "note") await db.query(`INSERT INTO offline.note VALUES ($1, $2, $3, $4)`, [e.wo, e.by, e.at, e.text]);
}
for (const [who, edits] of [["Jairo", JAIRO], ["Freddy", FREDDY]] as const) {
  let applied = 0;
  for (const e of edits) {
    try { await command(e); applied++; } catch (err) { console.log(`    rechazado ${e.at.slice(5, 16)} ${e.wo} ${e.kind} ${"position" in e ? e.position : ""} · ${(err as Error).message}`); }
  }
  console.log(`  ${who.padEnd(6)} aplicados ${applied}/${edits.length}`);
}
const open = await db.query(`SELECT count(*) FILTER (WHERE closed_by IS NULL) AS open FROM offline.open_item`);
console.log(`  pendientes abiertos al final: ${open.rows[0].open}`);
await db.end();
