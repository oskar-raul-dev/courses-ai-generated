// La partición, en la mejor jugada de Postgres (sección 4.2): se corta el enlace entre el primario de Bogotá y la
// réplica de Quito, Bogotá firma la inspección mayor de HC-2157, y Quito sigue leyendo su réplica. Después se
// repone el enlace y se cuenta cuánto tarda la firma en llegar. Un cliente de Quito —un contenedor en el enlace—
// intenta además llegar al primario para escribir, antes y durante el corte.
//
//   node 22-newsql-romper-y-medir/partition.ts [--seconds 75]   (desde src/, con compose.replica.yaml arriba y el
//                                                                primario cargado)
import { execSync } from "node:child_process";
import { parseArgs } from "node:util";
import { inline } from "../lab/harness/crdb-explain.ts";
import { connect } from "../21-newsql-levantar-y-modelar/db.ts";
import { BOGOTA, reset, signSteps } from "../21-newsql-levantar-y-modelar/expediente.ts";

const { values: args } = parseArgs({ options: { seconds: { type: "string", default: "75" } } });
const NET = "condor-replica_enlace", PRIMARY = "condor-replica-primario-1";
const IMAGE = "pgvector/pgvector@sha256:2ba9ca5f2e7daa0f0e7723cba1ee9167bab54efd3640516a44ac1a928dd67e7a";
const sh = (cmd: string) => { try { return execSync(cmd, { stdio: ["ignore", "pipe", "pipe"] }).toString().trim(); } catch (e: any) { return `${e.stdout?.toString().trim() || e.stderr?.toString().trim() || e.message}`; } };
const t0 = performance.now();
const at = () => `${((performance.now() - t0) / 1000).toFixed(1).padStart(5)} s`;
// un cliente en Quito que va a escribir: un contenedor en el enlace, que se conecta al primario y pregunta si es
// el primario (pg_is_in_recovery() = f)
const quitoWrites = () => sh(`docker run --rm --network ${NET} --label curso=ruta-no-sql-lite -e PGPASSWORD=condor -e PGCONNECT_TIMEOUT=5 ${IMAGE} ` +
  `psql -h primario -U postgres -d expediente -tAc "SELECT CASE WHEN pg_is_in_recovery() THEN 'réplica' ELSE 'primario, listo para escribir' END" 2>&1`);

const primario = await connect("primario", "expediente");
await reset(primario);
const replica = await connect("replica", "expediente");
const seen = async () => (await replica.query(`SELECT count(*)::int AS n FROM work_order WHERE work_order_id = $1`, [BOGOTA.workOrderId])).rows[0].n;
const receiver = async () => (await replica.query(`SELECT status, last_msg_receipt_time FROM pg_stat_wal_receiver`)).rows[0] ?? { status: "sin receptor" };

console.log(`${at()} · antes del corte · la réplica ve la orden de Bogotá: ${await seen()} · receptor: ${(await receiver()).status}`);
console.log(`${at()} · cliente de Quito → primario: ${quitoWrites().split("\n").pop()}`);
console.log(`${at()} · corte: docker network disconnect ${NET} ${PRIMARY} ${sh(`docker network disconnect ${NET} ${PRIMARY}`)}`);
console.log(`${at()} · cliente de Quito → primario: ${quitoWrites().split("\n").pop()}`);

// Bogotá firma: su primario sigue de pie y acepta
await primario.query(["BEGIN", ...signSteps(BOGOTA, "copy").map((s) => inline(primario, s.sql, s.params)), "COMMIT"].join(";\n"));
console.log(`${at()} · Bogotá firmó ${BOGOTA.workOrderId} en el primario, sin error`);

let reads = 0, stale = 0, errors = 0;
let last = "";
while (performance.now() - t0 < Number(args.seconds) * 1000) {
  try {
    const n = await seen(); reads++; if (!n) stale++;
    const r = await receiver();
    const line = `réplica: ve la orden ${n} · receptor ${r.status}`;
    if (line !== last) { console.log(`${at()} · ${line}`); last = line; }
  } catch (e: any) { errors++; console.log(`${at()} · error al leer la réplica: ${e.message}`); }
  await new Promise((ok) => setTimeout(ok, 1000));
}
console.log(`${at()} · durante el corte · lecturas en Quito ${reads} · sin la firma de Bogotá ${stale} · con error ${errors}`);
console.log(`${at()} · el log de la réplica: ${sh("docker logs --tail 2 condor-replica-replica-1 2>&1").split("\n")[0]}`);

// al reponer hay que devolverle su nombre en la red: sin el alias, la réplica no encuentra a "primario" (sección 9)
console.log(`${at()} · reponer: ${sh(`docker network connect --alias primario ${NET} ${PRIMARY}`) || "conectado"}`);
const back = performance.now();
while (!(await seen())) await new Promise((ok) => setTimeout(ok, 200));
console.log(`${at()} · la réplica ve la orden ${((performance.now() - back) / 1000).toFixed(1)} s después de reponer el enlace · receptor ${(await receiver()).status}`);
await reset(primario);
await Promise.all([primario.end(), replica.end()]);
