// La costura de vuelta: lo que la tableta registró sin señal, de CouchDB a la fuente de verdad. Se lee el _changes de
// `work_order` (la base de la Fase 19) desde el último punto guardado; cada documento que escribió una tableta entra a
// una bandeja de Postgres, `tablet_report`, con su revisión como clave, y el punto se guarda en la misma transacción.
// Lo que vino de Postgres —el eco de la costura de ida— se salta. Después, cada hecho del informe se clasifica contra
// el esquema de la Fase 01: ya está, es nuevo, no tiene columna, o contradice a la fuente.
// Trabaja sobre `costura_vuelta`, una copia de `expediente`: la base de la Fase 19 no se toca.
//
//   node 24-poliglota-la-costura/back.ts   (desde src/, con base y offline arriba)
import { couch } from "../lab/harness/couch.ts";
import { client } from "./common.ts";

const SOURCE = "work_order", DB = "costura_vuelta";
const admin = client("postgres");
await admin.connect();
await admin.query(`DROP DATABASE IF EXISTS ${DB}`);
await admin.query(`CREATE DATABASE ${DB} TEMPLATE expediente`);
await admin.end();
const db = client(DB);
await db.connect();
await db.query(`
  CREATE TABLE tablet_report (doc_id text, rev text, received_at timestamptz NOT NULL DEFAULT now(), doc jsonb NOT NULL, PRIMARY KEY (doc_id, rev));
  CREATE TABLE couch_checkpoint (source text PRIMARY KEY, seq text NOT NULL);`);

/** Una pasada por el _changes: lo nuevo desde el punto guardado, de a mil, cada lote en una transacción. */
async function ingest() {
  let read = 0, echoes = 0, inserted = 0;
  for (;;) {
    const since = (await db.query(`SELECT seq FROM couch_checkpoint WHERE source = $1`, [SOURCE])).rows[0]?.seq ?? "0";
    const page = await couch<{ results: { id: string; doc: any }[]; last_seq: string }>(
      `${SOURCE}/_changes?include_docs=true&limit=1000&since=${encodeURIComponent(since)}`);
    if (!page.results.length) break;
    // la forma de la tableta tiene quién y cuándo la guardó; la que vino de Postgres, no
    const reports = page.results.filter((r) => r.doc?.updatedBy);
    read += page.results.length;
    echoes += page.results.length - reports.length;
    await db.query("BEGIN");
    for (const r of reports) {
      const res = await db.query(`INSERT INTO tablet_report (doc_id, rev, doc) VALUES ($1, $2, $3) ON CONFLICT DO NOTHING`, [r.id, r.doc._rev, r.doc]);
      inserted += res.rowCount ?? 0;
    }
    await db.query(`INSERT INTO couch_checkpoint VALUES ($1, $2) ON CONFLICT (source) DO UPDATE SET seq = excluded.seq`, [SOURCE, page.last_seq]);
    await db.query("COMMIT");
  }
  return { read, echoes, inserted };
}

const first = await ingest();
console.log(`pasada 1 · ${first.read} cambios leídos · ${first.echoes} ecos de Postgres saltados · ${first.inserted} informes de tableta guardados`);
const second = await ingest();
console.log(`pasada 2 · ${second.read} cambios leídos · ${second.inserted} informes nuevos`);
// la misma pasada desde cero, como si el proceso hubiera perdido su punto: la clave (doc_id, rev) no deja duplicar
await db.query(`DELETE FROM couch_checkpoint`);
const replay = await ingest();
console.log(`pasada 3, sin punto guardado · ${replay.read} cambios leídos · ${replay.inserted} informes nuevos · ${(await db.query(`SELECT count(*) FROM tablet_report`)).rows[0].count} en la bandeja`);

// cada hecho del informe, contra lo que la fuente ya sabe de esa orden
type Verdict = "ya está" | "nuevo" | "sin columna" | "contradice";
const tally = new Map<string, number>();
const note = (fact: string, v: Verdict) => tally.set(`${v.padEnd(12)} ${fact}`, (tally.get(`${v.padEnd(12)} ${fact}`) ?? 0) + 1);
const { rows: reports } = await db.query(`SELECT DISTINCT ON (doc_id) doc_id, doc FROM tablet_report ORDER BY doc_id, received_at DESC`);
for (const { doc_id: id, doc } of reports) {
  const { rows: [wo] } = await db.query(`SELECT closed_at, labor_hours, tasks FROM work_order WHERE work_order_id = $1`, [id]);
  const { rows: moves } = await db.query(`SELECT kind, serial_number, position FROM work_order_movement WHERE work_order_id = $1`, [id]);
  const has = (kind: string, serial: string, position: string) => moves.some((m) => m.kind === kind && m.serial_number === serial && m.position === position);
  for (const [position, p] of Object.entries<any>(doc.parts)) {
    note("pieza retirada", has("removed", p.removed, position) ? "ya está" : "nuevo");
    note("pieza instalada", has("installed", p.installed, position) ? "ya está" : "nuevo");
    note("quién y cuándo cambió la pieza", "sin columna");
  }
  for (const [task, signatures] of Object.entries<any[]>(doc.tasks)) {
    if (!signatures.length) continue;
    note("tarea hecha", wo.tasks.includes(task) ? "ya está" : "nuevo");
    note("quién firmó la tarea", "sin columna");
  }
  const hours = Object.values<number>(doc.labor).reduce((a, b) => a + b, 0);
  note("horas de la orden", hours === wo.labor_hours ? "ya está" : "contradice");
  for (const _ of Object.keys(doc.labor)) note("horas por técnico", "sin columna");
  note("estado de la orden", doc.status === "open" && wo.closed_at ? "contradice" : "ya está");
  for (const _ of doc.openItems) note("pendiente abierto", "sin columna");
  for (const _ of doc.notes) note("nota", "sin columna");
}
console.log(`los hechos de ${reports.length} informes, contra la fuente:`);
for (const [k, n] of [...tally].sort()) console.log(`  ${k.padEnd(48)} ${n}`);
await db.end();
