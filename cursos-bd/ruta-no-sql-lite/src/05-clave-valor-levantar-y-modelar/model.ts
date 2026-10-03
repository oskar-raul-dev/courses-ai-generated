// El modelo de clave-valor de Cóndor en Valkey (Fase 05): sesiones con TTL, un índice secundario
// escrito a mano, la reserva del puesto con foso, el candado de la orden abierta, la cola de
// pendientes y el registro de eventos. Mide memoria, viajes y lo que el índice a mano deja atrás.
//
//   node 05-clave-valor-levantar-y-modelar/model.ts [--dataset lab/data/workOrder-1m] [--sessions 100000]
//                                          (desde src/, con el perfil clave-valor arriba)
import { resolve, join } from "node:path";
import { parseArgs } from "node:util";
import { Valkey } from "iovalkey";
import { verifyDataset, readNdjson } from "../lab/harness/dataset.ts";
import { countSocketWrites } from "../lab/harness/roundtrips.ts";

const { values: args } = parseArgs({ options: { dataset: { type: "string", default: "lab/data/workOrder-1m" }, sessions: { type: "string", default: "100000" } } });
const dir = resolve(args.dataset!);
const manifest = await verifyDataset(dir);
const N = Number(args.sessions);
const v = new Valkey({ host: "localhost", port: Number(process.env.CLAVE_VALOR_PORT ?? 16379), lazyConnect: true });
await v.connect();
const trips = countSocketWrites(v);
const used = async () => Number((await v.info("memory")).match(/used_memory:(\d+)/)![1]);

try {
  console.log(`dataset ${manifest.focus}-${manifest.volume} (${manifest.datasetSha256.slice(0, 12)}…)\n`);
  // el laboratorio del curso: nada más vive en esta instancia. Línea base limpia para medir memoria
  await v.flushall("SYNC"); await v.call("MEMORY", "PURGE"); await new Promise((r) => setTimeout(r, 1000));
  const technicians: { technicianId: string; hangarId: string }[] = [];
  for await (const t of readNdjson<{ technicianId: string; hangarId: string }>(join(dir, "technician.ndjson"))) technicians.push(t);

  // ── 1 · sesiones del terminal de plataforma: un hash por sesión, con TTL de 8 h ─────────
  //      y el índice secundario, escrito a mano: un set por técnico con sus sesiones
  const m0 = await used();
  trips.reset();
  for (let i = 0; i < N; i += 1000) {
    const p = v.pipeline();
    for (let j = i; j < Math.min(i + 1000, N); j++) {
      const t = technicians[j % technicians.length];
      const id = `session:${String(j).padStart(7, "0")}`;
      p.hset(id, "technicianId", t.technicianId, "hangarId", t.hangarId, "terminal", `plataforma-${j % 12}`, "openedAt", "2026-09-29T06:00:00Z");
      p.expire(id, 8 * 3600);
      p.sadd(`technician:${t.technicianId}:sessions`, id);
    }
    await p.exec();
  }
  const loadTrips = trips.count; // antes de las dos llamadas de medición
  await v.call("MEMORY", "PURGE"); await new Promise((r) => setTimeout(r, 500));
  const m1 = await used();
  console.log(`sesiones: ${N} en ${loadTrips} viajes · ${((m1 - m0) / N).toFixed(0)} bytes por sesión, con su entrada en el índice · MEMORY USAGE de una: ${await v.memory("USAGE", "session:0000000")} bytes`);

  // ── 2 · el 🪞: las sesiones de un técnico, sin índice (SCAN) y con el índice a mano ──────
  const target = technicians[1].technicianId;
  trips.reset();
  let cursor = "0";
  let scanned = 0;
  const found: string[] = [];
  do {
    const [next, keys] = await v.scan(cursor, "MATCH", "session:*", "COUNT", 1000);
    cursor = next;
    scanned += keys.length;
    const p = v.pipeline();
    for (const k of keys) p.hget(k, "technicianId");
    const res = await p.exec();
    res!.forEach(([, tech], i) => { if (tech === target) found.push(keys[i]); });
  } while (cursor !== "0");
  const scanTrips = trips.count;
  trips.reset();
  const members = await v.smembers(`technician:${target}:sessions`);
  const p2 = v.pipeline();
  for (const k of members) p2.hgetall(k);
  await p2.exec();
  console.log(`sesiones de ${target}: sin índice, SCAN de ${scanned} claves en ${scanTrips} viajes → ${found.length} · con el set a mano: ${members.length} en ${trips.count} viajes`);

  // lo que el índice a mano deja atrás cuando la sesión vence por TTL
  const ghost = "technician:T-GHOST:sessions";
  const p3 = v.pipeline();
  for (let i = 0; i < 1000; i++) { p3.hset(`session:ghost:${i}`, "technicianId", "T-GHOST"); p3.pexpire(`session:ghost:${i}`, 1000); p3.sadd(ghost, `session:ghost:${i}`); }
  await p3.exec();
  await new Promise((r) => setTimeout(r, 1500));
  const stale = await v.smembers(ghost);
  const alive = (await Promise.all(stale.map((k) => v.exists(k)))).reduce((a, b) => a + b, 0);
  console.log(`índice a mano tras vencer 1000 sesiones por TTL: el set sigue con ${stale.length} miembros, de los que existen ${alive}\n`);
  await v.del(ghost);

  // ── 3 · la reserva del puesto con foso: el primero gana, el segundo recibe null ─────────
  const slot = "slot:VVC:foso-1:2026-10-06";
  const r1 = await v.set(slot, "grupo-motores", "PX", 12 * 3600 * 1000, "NX");
  const r2 = await v.set(slot, "grupo-estructuras", "PX", 12 * 3600 * 1000, "NX");
  console.log(`reserva de ${slot}: grupo-motores → ${r1} · grupo-estructuras → ${r2} · dueño: ${await v.get(slot)}`);

  // ── 4 · el candado de la orden abierta, con liberación atómica en Lua ───────────────────
  v.defineCommand("releaseLock", { numberOfKeys: 1, lua: `if redis.call("GET", KEYS[1]) == ARGV[1] then return redis.call("DEL", KEYS[1]) else return 0 end` });
  const lock = "lock:workOrder:WO-0000001";
  const a = await v.set(lock, "terminal-2", "PX", 30000, "NX");
  const b = await v.set(lock, "terminal-5", "PX", 30000, "NX");
  const foreign = await (v as unknown as { releaseLock(k: string, t: string): Promise<number> }).releaseLock(lock, "terminal-5");
  const own = await (v as unknown as { releaseLock(k: string, t: string): Promise<number> }).releaseLock(lock, "terminal-2");
  console.log(`candado de WO-0000001: terminal-2 → ${a} · terminal-5 → ${b} · liberar con token ajeno → ${foreign} · con el propio → ${own}`);

  // ── 5 · la cola de pendientes por base (sorted set) y el registro de eventos (stream) ───
  const m2 = await used();
  let queued = 0;
  let q = v.pipeline();
  for await (const wo of readNdjson<{ workOrderId: string; hangarId: string; openedAt: string; type: string }>(join(dir, "workOrder.ndjson"))) {
    if (wo.openedAt < "2026-09-01") continue; // las órdenes del último mes
    q.zadd(`queue:${wo.hangarId}`, Date.parse(wo.openedAt), wo.workOrderId);
    q.xadd("events:workOrder", "*", "workOrderId", wo.workOrderId, "event", "opened", "type", wo.type);
    if (++queued % 1000 === 0) { await q.exec(); q = v.pipeline(); }
  }
  await q.exec();
  const m3 = await used();
  const [oldest] = await v.zrange("queue:VVC", 0, 0, "WITHSCORES");
  await v.xgroup("CREATE", "events:workOrder", "planeacion", "0");
  const read = await v.xreadgroup("GROUP", "planeacion", "yamile", "COUNT", 5, "STREAMS", "events:workOrder", ">") as [string, [string, string[]][]][];
  console.log(`cola y eventos: ${queued} órdenes del último mes · ${((m3 - m2) / queued).toFixed(0)} bytes por orden (entrada en la cola + evento) · la más antigua en VVC: ${oldest} · XREADGROUP entregó ${read[0][1].length} eventos a yamile`);
} finally {
  await v.quit();
}
