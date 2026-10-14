// La doble escritura sin ninguna falla: en cada ronda, dos procesos de la aplicación cambian las horas de la misma
// orden al mismo tiempo. Cada uno confirma en Postgres y después escribe en CouchDB, releyendo la revisión si CouchDB
// le contesta 409, que es lo que haría una aplicación correcta. Terminada la ronda (y entregado lo pendiente, con
// outbox y CDC), se compara esa orden en los dos motores. Postgres ordena las dos escrituras con el candado de la
// fila; CouchDB las recibe en el orden en que llegan, que puede ser otro.
//
//   node 24-poliglota-la-costura/race.ts --mode dual|outbox|cdc [--orders 10] [--rounds 500]
//                                        (desde src/, con lab/compose.costura.yaml: base y offline arriba)
import { spawn } from "node:child_process";
import { request } from "node:http";
import { parseArgs } from "node:util";
import { COUCH, SLOT, client, insertOrder, newId, putDocs, sleep, templates, updateHours, type Mode } from "./common.ts";

const { values } = parseArgs({ options: {
  mode: { type: "string", default: "dual" }, orders: { type: "string", default: "10" }, rounds: { type: "string", default: "500" },
} });
const mode = values.mode as Mode, N = Number(values.orders), R = Number(values.rounds);
const node = (script: string, ...args: string[]) => spawn(process.execPath, [`24-poliglota-la-costura/${script}`, ...args], { stdio: "inherit" });

/** Una petición a CouchDB con node:http: devuelve el código y el cuerpo, o 0 si no hubo respuesta. */
const http = (method: string, path: string, body?: unknown) => new Promise<{ status: number; json: any }>((ok) => {
  const req = request({ host: "localhost", port: Number(process.env.OFFLINE_PORT ?? 15984), path: `/${COUCH}/${path}`, method,
    auth: "condor:condor", headers: { "content-type": "application/json" } }, (res) => {
    let text = "";
    res.on("data", (c) => (text += c)).on("end", () => ok({ status: res.statusCode ?? 0, json: text ? JSON.parse(text) : null }));
  });
  req.on("error", () => ok({ status: 0, json: null }));
  req.end(body === undefined ? undefined : JSON.stringify(body));
});

/** La segunda escritura de la doble escritura: leer la revisión, cambiar las horas, guardar; si otro llegó antes, otra vez. */
async function dualCouch(id: string, hours: number) {
  for (;;) {
    const { json: doc } = await http("GET", id);
    const { status } = await http("PUT", id, { ...doc, laborHours: hours });
    if (status === 201) return;
  }
}

// las órdenes del experimento, ya en los dos motores antes de empezar
await new Promise((ok) => node("setup.ts").on("exit", ok));
const orders = (await templates()).slice(0, N).map((o, i) => ({ ...o, workOrderId: newId(i + 1) }));
const seed = client();
await seed.connect();
for (const o of orders) await insertOrder(seed, o, false);
await putDocs(orders.map((o) => ({ _id: o.workOrderId, ...o })));
await seed.query(`SELECT pg_replication_slot_advance($1, pg_current_wal_lsn())`, [SLOT]);
await seed.end();
const relay = mode === "dual" ? undefined : node("relay.ts", "--mode", mode);

const [a, b, probe] = [client(), client(), client()];
for (const c of [a, b, probe]) await c.connect();
/** Un cambio de la aplicación: Postgres y, con la doble escritura, CouchDB. */
async function change(db: typeof a, id: string, hours: number) {
  await updateHours(db, id, hours, mode === "outbox");
  if (mode === "dual") await dualCouch(id, hours);
}
const hoursIn = async (id: string) => [
  (await probe.query(`SELECT labor_hours FROM work_order WHERE work_order_id = $1`, [id])).rows[0].labor_hours,
  (await http("GET", id)).json.laborHours,
];
/** La misma regla para las tres costuras: se le da al relevo hasta un segundo para que los dos motores coincidan
 *  (su ventana de p99 no pasa de 100 ms). Lo que siga distinto después de eso no se va a arreglar solo. */
async function settle(id: string) {
  const until = Date.now() + 1000;
  for (;;) {
    const [pgHours, couchHours] = await hoursIn(id);
    if (pgHours === couchHours || Date.now() > until) return [pgHours, couchHours];
    await sleep(20);
  }
}

let diverged = 0;
const example: string[] = [];
const t0 = Date.now();
for (let r = 0; r < R; r++) {
  const id = newId((r % N) + 1);
  await Promise.all([change(a, id, 100_000 + r), change(b, id, 200_000 + r)]);
  const [pgHours, couchHours] = await settle(id);
  if (pgHours !== couchHours) {
    diverged++;
    if (example.length < 3) example.push(`ronda ${r} · ${id}: Postgres ${pgHours} · CouchDB ${couchHours}`);
  }
}
const seconds = (Date.now() - t0) / 1000;
relay?.kill("SIGTERM");
let final = 0;
for (const o of orders) { const [p, c] = await hoursIn(o.workOrderId); if (p !== c) final++; }
console.log(`${mode} · ${R} rondas de dos cambios simultáneos sobre ${N} órdenes, en ${seconds.toFixed(1)} s`);
console.log(`  rondas que dejaron CouchDB con el valor que perdió en Postgres: ${diverged} de ${R}`);
console.log(`  órdenes distintas al terminar: ${final} de ${N}`);
for (const e of example) console.log(`  p. ej. ${e}`);
for (const c of [a, b, probe]) await c.end();
