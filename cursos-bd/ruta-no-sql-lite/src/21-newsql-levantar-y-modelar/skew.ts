// "Una posición, una pieza": la regla que ninguna restricción de la tabla expresa. La llanta de nariz de
// HC-2157 se retiró, y dos bases la reponen a la vez, cada una con su llanta: el Coca con una de su almacén
// y Bogotá con otra. Cada una comprueba que la posición está libre y después instala. Se intercalan así:
//   Coca lee · Bogotá lee · Coca instala · Bogotá instala · Coca confirma · Bogotá confirma
// y se corre con cada aislamiento de cada motor (sección 6.2).
//
//   node 21-newsql-levantar-y-modelar/skew.ts   (desde src/, con base y newsql arriba y load.ts corrido)
import type pg from "pg";
import { connect, type Target } from "./db.ts";
import { AIRCRAFT } from "./expediente.ts";

const POSITION = "tire-nose", OLD = "SN-0001685";
const TIRES = { coca: { serial: "SN-0001174", hangar: "OCC" }, bogota: { serial: "SN-0004351", hangar: "BOG" } };

async function setup(db: pg.Client) {
  await db.query(`UPDATE part SET status = 'scrapped', aircraft = NULL, position = NULL WHERE serial_number = $1`, [OLD]);
  for (const t of Object.values(TIRES))
    await db.query(`UPDATE part SET status = 'inStore', aircraft = NULL, position = NULL, hangar_id = $2 WHERE serial_number = $1`, [t.serial, t.hangar]);
}
async function restore(db: pg.Client) {
  await setup(db);
  await db.query(`UPDATE part SET status = 'installed', aircraft = $2, position = $3, hangar_id = NULL WHERE serial_number = $1`, [OLD, AIRCRAFT, POSITION]);
}

const free = (db: pg.Client) =>
  db.query(`SELECT count(*)::int AS n FROM part WHERE aircraft = $1 AND position = $2 AND status = 'installed'`, [AIRCRAFT, POSITION]).then((r) => r.rows[0].n);
const install = (db: pg.Client, serial: string) =>
  db.query(`UPDATE part SET status = 'installed', aircraft = $2, position = $3, hangar_id = NULL WHERE serial_number = $1`, [serial, AIRCRAFT, POSITION]);

/** Corre un paso y, si falla, devuelve el error en lugar de lanzarlo. */
const attempt = async (f: () => Promise<unknown>) => { try { await f(); return null; } catch (e: any) { return e as { code: string; message: string }; } };

const cases: [Target, string, string][] = [
  ["base", "expediente", "READ COMMITTED"],
  ["base", "expediente", "SERIALIZABLE"],
  ["newsql", "condor", "SERIALIZABLE"],
  ["newsql", "condor", "READ COMMITTED"],
];

for (const [target, database, isolation] of cases) {
  const admin = await connect(target, database);
  await setup(admin);
  const coca = await connect(target, database), bogota = await connect(target, database);
  const errors: string[] = [];
  const step = async (who: string, f: () => Promise<unknown>) => {
    const e = await attempt(f);
    if (e) errors.push(`${who}: ${e.code} ${e.message.split("\n")[0]}`);
    return e;
  };
  await coca.query(`BEGIN ISOLATION LEVEL ${isolation}`);
  await bogota.query(`BEGIN ISOLATION LEVEL ${isolation}`);
  const { rows: [{ transaction_isolation: actual }] } = await coca.query("SHOW transaction_isolation");
  const seenCoca = await free(coca), seenBogota = await free(bogota);
  let failedCoca = await step("Coca, al instalar", () => install(coca, TIRES.coca.serial));
  // el UPDATE de Bogotá puede quedar esperando el bloqueo de la fila del Coca: se lanza y se confirma el Coca
  const bogotaInstall = step("Bogotá, al instalar", () => install(bogota, TIRES.bogota.serial));
  failedCoca ??= await step("Coca, al confirmar", () => coca.query("COMMIT"));
  if (failedCoca) await coca.query("ROLLBACK").catch(() => {});
  const failedBogota = (await bogotaInstall) ?? (await step("Bogotá, al confirmar", () => bogota.query("COMMIT")));
  if (failedBogota) await bogota.query("ROLLBACK").catch(() => {});
  const { rows } = await admin.query(`SELECT serial_number FROM part WHERE aircraft = $1 AND position = $2 AND status = 'installed' ORDER BY 1`, [AIRCRAFT, POSITION]);
  console.log(`${target === "base" ? "Postgres" : "CockroachDB"} ${isolation.padEnd(14)} (la sesión dice: ${actual}) · las dos vieron ${seenCoca} y ${seenBogota} llantas · ` +
    `confirmó el Coca: ${failedCoca ? "no" : "sí"}, Bogotá: ${failedBogota ? "no" : "sí"} · en la nariz quedaron ${rows.length}: ${rows.map((r) => r.serial_number).join(", ")}`);
  for (const e of errors) console.log(`    ${e}`);
  await restore(admin);
  await Promise.all([coca.end(), bogota.end(), admin.end()]);
}
