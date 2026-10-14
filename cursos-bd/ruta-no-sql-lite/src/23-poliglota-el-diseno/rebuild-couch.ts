// ¿Se reconstruye el servidor de las tabletas desde la fuente de verdad? La Fase 20 cargó work_order_1m en
// CouchDB desde el NDJSON; aquí cada orden se arma otra vez con lo que Postgres tiene (las mismas órdenes, en la
// base `postgres`) y se compara, documento por documento, con la que guarda CouchDB.
// Se normaliza lo que Postgres no guarda: el orden de los arreglos de piezas, que es el de la simulación y no
// significa nada; las piezas se comparan ordenadas por número de serie.
//
//   node 23-poliglota-el-diseno/rebuild-couch.ts [--db postgres] [--couch work_order_1m]   (desde src/, con base y offline arriba)
import { parseArgs } from "node:util";
import pg from "pg";
import { couch } from "../lab/harness/couch.ts";

const { values } = parseArgs({ options: { db: { type: "string", default: "postgres" }, couch: { type: "string", default: "work_order_1m" } } });
const PAGE = 10_000;

type Doc = Record<string, any>;
/** Un campo en forma canónica: las piezas por número de serie y las claves de cada objeto en orden. */
const field = (k: string, v: unknown): string => {
  const value = (k === "removed" || k === "installed") && Array.isArray(v)
    ? [...v].sort((a: Doc, b: Doc) => a.serialNumber.localeCompare(b.serialNumber)) : v;
  return JSON.stringify(value, (_, x) => (x && typeof x === "object" && !Array.isArray(x) ? Object.fromEntries(Object.entries(x).sort()) : x));
};
/** Los campos en que difieren dos órdenes, sin contar _id ni _rev. */
const diff = (a: Doc, b: Doc): string[] =>
  [...new Set([...Object.keys(a), ...Object.keys(b)])].filter((k) => k !== "_id" && k !== "_rev" && field(k, a[k]) !== field(k, b[k]));

const client = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: values.db });
await client.connect();
const iso = (col: string) => `to_char(${col} AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS"Z"')`;
const t0 = performance.now();
let compared = 0, equal = 0, missing = 0;
const differing = new Map<string, number>();
const examples: string[] = [];
try {
  await client.query("BEGIN");
  // la orden tal como la escribió el generador, armada desde las cuatro tablas que la guardan
  await client.query(`DECLARE orders NO SCROLL CURSOR FOR
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
    FROM work_order w ORDER BY w.work_order_id`);
  for (;;) {
    const { rows } = await client.query(`FETCH ${PAGE} FROM orders`);
    if (!rows.length) break;
    // las mismas órdenes en CouchDB, pedidas por su _id: si faltan algunas, no se corre la página
    const page = await couch<{ rows: { key: string; doc?: Doc }[] }>(`${values.couch}/_all_docs?include_docs=true`,
      { method: "POST", body: JSON.stringify({ keys: rows.map((r) => r.id) }) });
    const stored = new Map(page.rows.filter((r) => r.doc).map((r) => [r.key, r.doc!]));
    for (const { id, doc } of rows) {
      compared++;
      const s = stored.get(id);
      if (!s) { missing++; continue; }
      const fields = diff(doc, s);
      if (!fields.length) { equal++; continue; }
      for (const f of fields) differing.set(f, (differing.get(f) ?? 0) + 1);
      if (examples.length < 3) examples.push(`${id} · ${fields[0]}: Postgres ${JSON.stringify(doc[fields[0]])} · CouchDB ${JSON.stringify(s[fields[0]])}`);
    }
  }
  await client.query("COMMIT");
} finally {
  await client.end();
}
const info = await couch<{ doc_count: number }>(values.couch);
console.log(`${values.db} → ${values.couch} · ${compared} órdenes de Postgres · ${info.doc_count} documentos en CouchDB · ${((performance.now() - t0) / 1000).toFixed(0)} s`);
console.log(`  iguales ${equal} · distintas ${compared - equal - missing} · ausentes en CouchDB ${missing} · solo en CouchDB ${info.doc_count - (compared - missing)}`);
for (const [f, n] of differing) console.log(`  difiere ${f}: ${n}`);
for (const e of examples) console.log(`  p. ej. ${e}`);
