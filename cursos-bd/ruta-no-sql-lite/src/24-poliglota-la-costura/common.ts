// Lo que comparten los guiones de la costura: la base `costura` (una copia de `expediente`, para que las órdenes nuevas
// tengan sus aeronaves, piezas y técnicos), la base `costura` de CouchDB, la orden como documento y las cuentas de la
// ventana. Las tres costuras escriben las mismas órdenes; lo único que cambia es cómo llega cada una a CouchDB.
import { execFileSync } from "node:child_process";
import pg from "pg";
import { readNdjson } from "../lab/harness/dataset.ts";
import { couch } from "../lab/harness/couch.ts";

export type Mode = "dual" | "outbox" | "cdc";
export const MODES: Mode[] = ["dual", "outbox", "cdc"];
export const DB = "costura";
export const COUCH = "costura";
export const SLOT = "costura";
export const OFFLINE = "condor-lab-offline-1";
export type Doc = Record<string, any>;

export const client = (database = DB) =>
  new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database });

export const sleep = (ms: number) => new Promise((r) => setTimeout(r, ms));
/** Reintenta lo que habla con CouchDB: una conexión que el servidor cierra no es una falla de la costura. */
export async function retry<T>(fn: () => Promise<T>, times = 5): Promise<T> {
  for (let i = 1; ; i++) {
    try { return await fn(); } catch (e) { if (i === times) throw e; await sleep(500 * i); }
  }
}
export const docker = (...args: string[]) => execFileSync("docker", args, { stdio: "ignore" });

/** Las órdenes de workOrder-10k, que se vuelven a escribir con un número nuevo: WO-C0000001, WO-C0000002… */
export async function templates(): Promise<Doc[]> {
  const all: Doc[] = [];
  for await (const w of readNdjson<Doc>("lab/data/workOrder-10k/workOrder.ndjson")) all.push(w);
  return all;
}
export const newId = (n: number) => `WO-C${String(n).padStart(7, "0")}`;

/** Una orden en un solo viaje: la cabecera, los técnicos y los movimientos, en una sentencia y por eso en una
 *  transacción. Con `outbox`, la misma sentencia deja la fila del outbox: o se escriben las dos, o ninguna. */
export function insertOrder(db: pg.Client, o: Doc, outbox: boolean) {
  return db.query(`
    WITH x AS (SELECT * FROM jsonb_to_record($1::jsonb) AS x("workOrderId" text, aircraft text, "hangarId" text, type text,
                 "openedAt" timestamptz, "closedAt" timestamptz, "pirepId" text, "releasedBy" text, "laborHours" int,
                 "laborCostUsd" numeric, "partsCostUsd" numeric, tasks text[], "technicianIds" text[], removed jsonb, installed jsonb)),
    w AS (INSERT INTO work_order SELECT "workOrderId", aircraft, "hangarId", type, "openedAt", "closedAt", "pirepId", "releasedBy",
                 "laborHours", "laborCostUsd", "partsCostUsd", tasks FROM x),
    t AS (INSERT INTO work_order_technician SELECT "workOrderId", unnest("technicianIds") FROM x),
    m AS (INSERT INTO work_order_movement
            SELECT x."workOrderId", 'removed', r."serialNumber", r."partNumber", r.position, r.disposition, r."supplierId", r.reason
              FROM x, jsonb_to_recordset(x.removed) AS r("serialNumber" text, "partNumber" text, position text, disposition text, "supplierId" text, reason text)
            UNION ALL
            SELECT x."workOrderId", 'installed', i."serialNumber", i."partNumber", i.position, NULL, NULL, NULL
              FROM x, jsonb_to_recordset(x.installed) AS i("serialNumber" text, "partNumber" text, position text))
    ${outbox ? `INSERT INTO outbox (work_order_id) SELECT "workOrderId" FROM x` : `SELECT 1`}`, [JSON.stringify(o)]);
}

/** El cambio de una orden que ya existe: las horas, y con `outbox`, su fila en la misma sentencia. */
export function updateHours(db: pg.Client, id: string, hours: number, outbox: boolean) {
  return db.query(`
    WITH w AS (UPDATE work_order SET labor_hours = $2 WHERE work_order_id = $1 RETURNING work_order_id)
    ${outbox ? `INSERT INTO outbox (work_order_id) SELECT work_order_id FROM w` : `SELECT 1`}`, [id, hours]);
}

const iso = (col: string) => `to_char(${col} AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')`;
/** La orden como la guarda CouchDB, armada desde las cuatro tablas: la misma consulta que rebuild-couch.ts (Fase 23). */
export const ORDER_DOC = `
  SELECT w.work_order_id AS id, json_build_object(
    'workOrderId', w.work_order_id, 'aircraft', w.aircraft, 'hangarId', w.hangar_id, 'type', w.type,
    'openedAt', ${iso("w.opened_at")}, 'closedAt', ${iso("w.closed_at")}, 'pirepId', w.pirep_id,
    'technicianIds', (SELECT coalesce(json_agg(t.technician_id ORDER BY t.technician_id), '[]') FROM work_order_technician t WHERE t.work_order_id = w.work_order_id),
    'releasedBy', w.released_by, 'laborHours', w.labor_hours, 'laborCostUsd', w.labor_cost_usd, 'partsCostUsd', w.parts_cost_usd,
    'tasks', w.tasks,
    'removed', (SELECT coalesce(json_agg(json_build_object('serialNumber', m.serial_number, 'partNumber', m.part_number, 'position', m.position,
                 'disposition', m.disposition, 'supplierId', m.supplier_id, 'reason', m.reason)), '[]')
               FROM work_order_movement m WHERE m.work_order_id = w.work_order_id AND m.kind = 'removed'),
    'installed', (SELECT coalesce(json_agg(json_build_object('serialNumber', m.serial_number, 'partNumber', m.part_number, 'position', m.position)), '[]')
                 FROM work_order_movement m WHERE m.work_order_id = w.work_order_id AND m.kind = 'installed')
  ) AS doc
  FROM work_order w`;

/** Escribe en CouchDB el estado actual de unas órdenes de Postgres: lo que hacen el relevo del outbox y el del CDC.
 *  Se lee cada orden de la fuente en el momento de copiarla, no se copia el cambio: si llegan dos cambios de la
 *  misma orden, el último gana porque es el que está en Postgres. */
export async function copyToCouch(db: pg.Client, ids: string[]): Promise<void> {
  if (!ids.length) return;
  const { rows } = await db.query(`${ORDER_DOC} WHERE w.work_order_id = ANY($1)`, [ids]);
  await putDocs(rows.map((r) => ({ _id: r.id, ...r.doc })));
}

/** _bulk_docs con la revisión vigente de cada documento: sin ella, CouchDB rechaza el cambio con un conflicto. */
export async function putDocs(docs: Doc[]): Promise<void> {
  const revs = await couch<{ rows: { key: string; value?: { rev: string } }[] }>(`${COUCH}/_all_docs`,
    { method: "POST", body: JSON.stringify({ keys: docs.map((d) => d._id) }) });
  const rev = new Map(revs.rows.filter((r) => r.value).map((r) => [r.key, r.value!.rev]));
  const res = await couch<any>(`${COUCH}/_bulk_docs`,
    { method: "POST", body: JSON.stringify({ docs: docs.map((d) => (rev.has(d._id) ? { ...d, _rev: rev.get(d._id) } : d)) }) });
  if (!Array.isArray(res)) throw new Error(`_bulk_docs: ${JSON.stringify(res)}`);
  const failed = res.filter((r: any) => r.error);
  if (failed.length) throw new Error(`_bulk_docs: ${failed.length} rechazados (${failed[0].error})`);
}

/** Percentil de una lista ya ordenada, por el método del rango más cercano. */
export const pct = (sorted: number[], p: number) => sorted[Math.max(0, Math.ceil((p / 100) * sorted.length) - 1)];
export const ms = (n: number | undefined) => (n === undefined ? "—" : n >= 10_000 ? `${(n / 1000).toFixed(1)} s` : `${n} ms`);
