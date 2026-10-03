// La reserva y el candado de la Fase 05, hechos en Postgres: viajes por operación, qué recibe quien
// pierde, y qué pasa con el candado cuando el terminal que lo tiene se cae (Fase 06, sección 4.4).
//
//   node 06-clave-valor-romper-y-medir/extra.ts     (desde src/, con el perfil base arriba)
import pg from "pg";
import { countRoundTrips } from "../lab/harness/roundtrips.ts";

const conn = async () => {
  const c = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "postgres" });
  c.on("error", () => {}); // la conexión que se mata a propósito avisa con 57P01
  await c.connect();
  return c;
};
const [t2, t5, admin] = await Promise.all([conn(), conn(), conn()]);
try {
  // la reserva del puesto con foso: una fila por puesto y día, la clave primaria decide quién gana
  await admin.query(`DROP TABLE IF EXISTS slot_reservation;
    CREATE TABLE slot_reservation (hangar_id text, slot text, day date, owner text NOT NULL, PRIMARY KEY (hangar_id, slot, day))`);
  const reserve = `INSERT INTO slot_reservation VALUES ('VVC', 'foso-1', '2026-10-06', $1) ON CONFLICT DO NOTHING RETURNING owner`;
  const trips = countRoundTrips(t2, "query");
  const r1 = await t2.query(reserve, ["grupo-motores"]);
  const r2 = await t5.query(reserve, ["grupo-estructuras"]);
  console.log(`reserva: grupo-motores → ${r1.rowCount} fila (${trips.count} viaje) · grupo-estructuras → ${r2.rowCount} filas · dueño: ${(await admin.query("SELECT owner FROM slot_reservation")).rows[0].owner}`);

  // el candado de la orden abierta: un candado consultivo, atado a la conexión que lo toma
  const key = 1; // WO-0000001
  trips.reset();
  const a = (await t2.query("SELECT pg_try_advisory_lock($1) AS ok", [key])).rows[0].ok;
  const takeTrips = trips.count;
  const b = (await t5.query("SELECT pg_try_advisory_lock($1) AS ok", [key])).rows[0].ok;
  const foreign = (await t5.query("SELECT pg_advisory_unlock($1) AS ok", [key])).rows[0].ok;
  // el terminal 2 se cae con el candado tomado: se mata su conexión desde fuera
  const pid = (await t2.query("SELECT pg_backend_pid() AS pid")).rows[0].pid;
  await admin.query("SELECT pg_terminate_backend($1)", [pid]);
  await new Promise((r) => setTimeout(r, 200));
  const after = (await t5.query("SELECT pg_try_advisory_lock($1) AS ok", [key])).rows[0].ok;
  console.log(`candado: terminal-2 → ${a} (${takeTrips} viaje) · terminal-5 → ${b} · soltarlo desde terminal-5 → ${foreign} · terminal-2 se cae y terminal-5 lo intenta → ${after}`);
  await t5.query("SELECT pg_advisory_unlock_all()");
  await admin.query("DROP TABLE slot_reservation");
} finally {
  await Promise.all([t2.end(), t5.end(), admin.end()].map((p) => p.catch(() => {})));
}
