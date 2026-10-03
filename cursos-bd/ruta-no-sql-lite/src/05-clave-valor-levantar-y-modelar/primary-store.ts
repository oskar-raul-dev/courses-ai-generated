// La situación 3 de la Fase 05: Valkey como almacén primario del estado de cada orden de trabajo,
// con la persistencia por defecto de la imagen (RDB con puntos de guardado, sin AOF). Carga las
// órdenes, mata el contenedor con SIGKILL y cuenta cuántas sobrevivieron.
//
//   node 05-clave-valor-levantar-y-modelar/primary-store.ts [--dataset lab/data/workOrder-1m]
//                                  (desde src/, con el perfil clave-valor arriba; ¡borra la instancia!)
import { execFileSync } from "node:child_process";
import { resolve, join } from "node:path";
import { parseArgs } from "node:util";
import { Valkey } from "iovalkey";
import { verifyDataset, readNdjson } from "../lab/harness/dataset.ts";

const { values: args } = parseArgs({ options: { dataset: { type: "string", default: "lab/data/workOrder-1m" } } });
const dir = resolve(args.dataset!);
const manifest = await verifyDataset(dir);
const lab = resolve(import.meta.dirname, "../lab");
const port = Number(process.env.CLAVE_VALOR_PORT ?? 16379);
const connect = async () => { const v = new Valkey({ host: "localhost", port, lazyConnect: true }); await v.connect(); return v; };
const crash = () => {
  execFileSync("docker", ["kill", "--signal=KILL", "condor-lab-clave-valor-1"]);
  execFileSync("docker", ["compose", "--profile", "clave-valor", "up", "-d", "--wait"], { cwd: lab, stdio: "ignore" });
};
const count = async (v: Valkey) => { let n = 0; let c = "0"; do { const [nx, ks] = await v.scan(c, "MATCH", "wo:*", "COUNT", 5000); c = nx; n += ks.length; } while (c !== "0"); return n; };

console.log(`dataset ${manifest.focus}-${manifest.volume} (${manifest.datasetSha256.slice(0, 12)}…)`);
let v = await connect();
console.log(`persistencia: save "${(await v.config("GET", "save"))[1]}" · appendonly ${(await v.config("GET", "appendonly"))[1]}`);
await v.flushall();
await v.save(); // punto de partida: una instantánea vacía

const load = async (limit = Infinity) => {
  let n = 0;
  let p = v.pipeline();
  for await (const wo of readNdjson<{ workOrderId: string; aircraft: string; type: string; openedAt: string; closedAt: string }>(join(dir, "workOrder.ndjson"))) {
    p.hset(`wo:${wo.workOrderId}`, "aircraft", wo.aircraft, "type", wo.type, "status", "closed", "openedAt", wo.openedAt, "closedAt", wo.closedAt);
    if (++n % 1000 === 0) { await p.exec(); p = v.pipeline(); }
    if (n >= limit) break;
  }
  await p.exec();
  return n;
};

// 1 · cargar y caer enseguida: antes del primer punto de guardado
const t0 = Date.now();
const loaded = await load();
const mem = (await v.info("memory")).match(/used_memory_human:(\S+)/)![1];
console.log(`cargadas ${loaded} órdenes como hash en ${((Date.now() - t0) / 1000).toFixed(1)} s · memoria ${mem} · último guardado hace ${Math.round(Date.now() / 1000 - Number(await v.lastsave()))} s`);
await v.quit();
crash();
v = await connect();
console.log(`tras SIGKILL: sobreviven ${await count(v)} de ${loaded}`);

// 2 · cargar, esperar al punto de guardado "60 10000", y después escribir 5000 más y caer
await load();
await new Promise((r) => setTimeout(r, 65_000));
console.log(`tras esperar 65 s: último guardado hace ${Math.round(Date.now() / 1000 - Number(await v.lastsave()))} s`);
const p = v.pipeline();
for (let i = 0; i < 5000; i++) p.hset(`wo:NEW-${i}`, "status", "open");
await p.exec();
await v.quit();
crash();
v = await connect();
console.log(`5000 órdenes nuevas escritas después del guardado y SIGKILL: sobreviven ${await count(v)} de ${loaded + 5000}`);
await v.flushall();
await v.quit();
