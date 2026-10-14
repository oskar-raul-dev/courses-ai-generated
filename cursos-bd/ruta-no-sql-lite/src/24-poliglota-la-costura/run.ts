// Una costura, medida: se escriben órdenes nuevas en Postgres a un ritmo fijo y se mide cuánto tarda cada una en verse
// en CouchDB (la ventana de inconsistencia), cuántas no llegan nunca, y cuánto cuesta encontrarlas.
//   dual   · la aplicación escribe en Postgres y, confirmado el COMMIT, en CouchDB; si CouchDB falla, lo anota y sigue
//   outbox · la aplicación escribe la orden y su fila de outbox en la misma transacción; relay.ts la lleva
//   cdc    · la aplicación escribe solo la orden; relay.ts lee el WAL
// Con --outage, CouchDB se detiene a los N segundos y vuelve M segundos después, con la carga corriendo.
//
//   node 24-poliglota-la-costura/run.ts --mode dual|outbox|cdc [--rate 200] [--seconds 60] [--outage 20:30]
//                                       (desde src/, con lab/compose.costura.yaml: base y offline arriba)
import { spawn, execFile } from "node:child_process";
import { request } from "node:http";
import { createInterface } from "node:readline";
import { promisify } from "node:util";
import { parseArgs } from "node:util";
import { COUCH, OFFLINE, SLOT, client, insertOrder, ms, newId, pct, sleep, templates, type Mode } from "./common.ts";

const { values } = parseArgs({ options: {
  mode: { type: "string", default: "outbox" }, rate: { type: "string", default: "200" },
  seconds: { type: "string", default: "60" }, outage: { type: "string" },
} });
const mode = values.mode as Mode, rate = Number(values.rate), seconds = Number(values.seconds);
const [downAt, downFor] = values.outage ? values.outage.split(":").map(Number) : [];
const node = (script: string, ...args: string[]) => spawn(process.execPath, [`24-poliglota-la-costura/${script}`, ...args], { stdio: ["ignore", "pipe", "inherit"] });
const run = promisify(execFile);

/** El PUT de la doble escritura, con node:http: con CouchDB detenido, fetch lanzaba el error fuera de la promesa
 *  (setTypeOfService EINVAL) y tumbaba el proceso; así, la falla llega como un error que la aplicación atrapa. */
const put = (id: string, body: string) => new Promise<boolean>((ok) => {
  const req = request({ host: "localhost", port: Number(process.env.OFFLINE_PORT ?? 15984), path: `/${COUCH}/${id}`, method: "PUT",
    auth: "condor:condor", headers: { "content-type": "application/json" } }, (res) => { res.resume(); ok(res.statusCode === 201); });
  req.on("error", () => ok(false));
  req.end(body);
});

// 1 · todo en cero, y el observador escuchando antes de la primera escritura
await new Promise((ok) => node("setup.ts").on("exit", ok));
const watcher = node("watch.ts");
const seenAt = new Map<string, number>();
createInterface({ input: watcher.stdout! }).on("line", (l) => { const [id, t] = l.split(" "); seenAt.set(id, Number(t)); });
const relay = mode === "dual" ? undefined : node("relay.ts", "--mode", mode);
await sleep(1000);

// 2 · la muestra del pendiente: filas del outbox y WAL que el slot retiene
const probe = client();
await probe.connect();
let peakOutbox = 0, peakWal = 0;
const sampler = setInterval(async () => {
  const { rows: [r] } = await probe.query(`SELECT (SELECT count(*) FROM outbox)::int AS outbox,
    (SELECT pg_wal_lsn_diff(pg_current_wal_lsn(), confirmed_flush_lsn) FROM pg_replication_slots WHERE slot_name = $1)::bigint AS wal`, [SLOT]);
  peakOutbox = Math.max(peakOutbox, r.outbox);
  if (mode === "cdc") peakWal = Math.max(peakWal, Number(r.wal));
}, 500);

// 3 · la caída, si se pidió, en paralelo con la carga
let downT0 = 0, upT = 0;
const outage = downAt === undefined ? Promise.resolve() : (async () => {
  await sleep(downAt * 1000);
  downT0 = Date.now();
  await run("docker", ["stop", OFFLINE]);
  await sleep(downFor * 1000 - (Date.now() - downT0));
  await run("docker", ["start", OFFLINE]);
  upT = Date.now();
})();

// 4 · la carga: una orden cada 1000/rate ms, en un solo proceso, como la aplicación de las órdenes
const orders = await templates();
const db = client();
await db.connect();
const committedAt = new Map<string, number>();
let dualFailed = 0;
const t0 = Date.now(), total = rate * seconds;
for (let i = 0; i < total; i++) {
  const wait = t0 + (i * 1000) / rate - Date.now();
  if (wait > 0) await sleep(wait);
  const o = { ...orders[i % orders.length], workOrderId: newId(i + 1) };
  await insertOrder(db, o, mode === "outbox");
  committedAt.set(o.workOrderId, Date.now());
  if (mode === "dual") {
    // la segunda escritura: si falla, la orden ya está confirmada en Postgres y no hay nada que deshacer
    if (!(await put(o.workOrderId, JSON.stringify(o)))) dualFailed++;
  }
}
const loadSeconds = (Date.now() - t0) / 1000;
await outage;

// 5 · esperar a que llegue lo que va a llegar: todo, o quince segundos sin que llegue nada nuevo
let last = seenAt.size, quiet = 0;
while (quiet < 15_000 && [...committedAt.keys()].some((id) => !seenAt.has(id))) {
  await sleep(500);
  quiet = seenAt.size === last ? quiet + 500 : 0;
  last = seenAt.size;
}
clearInterval(sampler);
relay?.kill("SIGTERM");
watcher.kill("SIGTERM");

// 6 · las cuentas
const windows = (filter: (t: number) => boolean) => [...committedAt].filter(([, t]) => filter(t))
  .flatMap(([id, t]) => (seenAt.has(id) ? [seenAt.get(id)! - t] : [])).sort((a, b) => a - b);
const missing = [...committedAt.keys()].filter((id) => !seenAt.has(id)).length;
const line = (label: string, w: number[]) =>
  console.log(`  ${label.padEnd(28)} ${String(w.length).padStart(6)} · p50 ${ms(pct(w, 50))} · p99 ${ms(pct(w, 99))} · máx ${ms(w.at(-1))}`);
console.log(`${mode}${values.outage ? ` · CouchDB caído ${downFor} s desde el segundo ${downAt}` : ""} · ${total} órdenes en ${loadSeconds.toFixed(1)} s (${(total / loadSeconds).toFixed(0)}/s)`);
line("ventana, todas las que llegaron", windows(() => true));
if (downT0) {
  line("confirmadas fuera de la caída", windows((t) => t < downT0 || t > upT));
  line("confirmadas durante la caída", windows((t) => t >= downT0 && t <= upT));
  const lastSeen = Math.max(...[...seenAt.values()]);
  console.log(`  al día ${ms(lastSeen - upT)} después de volver CouchDB`);
}
console.log(`  no llegaron nunca ${missing}${mode === "dual" ? ` · segundas escrituras fallidas ${dualFailed}` : ""}`);
if (mode === "outbox") console.log(`  pico del outbox ${peakOutbox} filas`);
if (mode === "cdc") console.log(`  pico del WAL retenido por el slot ${(peakWal / 2 ** 20).toFixed(1)} MiB`);
await db.end();
await probe.end();

// 7 · y cuánto cuesta encontrarlas: la comparación de la Fase 23, contra esta base
const check = spawn(process.execPath, ["23-poliglota-el-diseno/rebuild-couch.ts", "--db", "costura", "--couch", COUCH], { stdio: "inherit" });
await new Promise((ok) => check.on("exit", ok));
