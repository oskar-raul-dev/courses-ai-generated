// Mediciones de la Fase 06: la apuesta contra una tabla UNLOGGED (viajes por operación, memoria por
// sesión y qué se pierde al reiniciar), maxmemory con sus políticas, y RDB contra AOF.
//
//   node 06-clave-valor-romper-y-medir/measure.ts [--sessions 100000] [--only apuesta,memoria,persistencia]
//     (desde src/, con clave-valor y base arriba; reconfigura y reinicia Valkey, y lo deja como estaba)
import { execFileSync } from "node:child_process";
import { resolve } from "node:path";
import { parseArgs } from "node:util";
import { Valkey } from "iovalkey";
import pg from "pg";
import { countSocketWrites, countRoundTrips } from "../lab/harness/roundtrips.ts";

const { values: args } = parseArgs({ options: { sessions: { type: "string", default: "100000" }, only: { type: "string", default: "apuesta,memoria,persistencia" } } });
const N = Number(args.sessions);
const only = new Set(args.only!.split(","));
const lab = resolve(import.meta.dirname, "../lab");
const port = Number(process.env.CLAVE_VALOR_PORT ?? 16379);
const connect = async () => { const c = new Valkey({ host: "localhost", port, lazyConnect: true }); await c.connect(); return c; };
const restart = (signal: "KILL" | null) => {
  if (signal) execFileSync("docker", ["kill", `--signal=${signal}`, "condor-lab-clave-valor-1"]);
  else execFileSync("docker", ["compose", "--profile", "clave-valor", "stop"], { cwd: lab, stdio: "ignore" });
  execFileSync("docker", ["compose", "--profile", "clave-valor", "up", "-d", "--wait"], { cwd: lab, stdio: "ignore" });
};
const session = (i: number) => ({ id: `session:${String(i).padStart(7, "0")}`, technicianId: `T-${String((i % 900) + 1).padStart(3, "0")}`, hangarId: ["VVC", "BOG", "EJA", "NVA", "IQT", "OCC"][i % 6], terminal: `plataforma-${i % 12}` });
const fill = async (v: Valkey, from: number, to: number, ttl = 8 * 3600) => {
  for (let i = from; i < to; i += 1000) {
    const p = v.pipeline();
    for (let j = i; j < Math.min(i + 1000, to); j++) { const s = session(j); p.hset(s.id, "technicianId", s.technicianId, "hangarId", s.hangarId, "terminal", s.terminal); p.expire(s.id, ttl); }
    const res = await p.exec();
    const err = res!.find(([e]) => e);
    if (err) return { stoppedAt: i, error: err[0] as Error };
  }
  return { stoppedAt: to, error: null };
};
const keys = async (v: Valkey) => Number((await v.info("keyspace")).match(/keys=(\d+)/)?.[1] ?? 0);

let v = await connect();
const pgc = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "postgres" });
// al apagar base para la prueba de reinicio, el servidor avisa con 57P01: se espera, no es un fallo
pgc.on("error", () => {});
await pgc.connect();
try {
  if (only.has("apuesta")) {
    // línea base limpia: sin ella, used_memory arrastra lo que el asignador liberó antes y la resta
    // sale corta (una primera versión de este script midió 91 bytes por sesión en vez de 155)
    await v.flushall("SYNC"); await v.call("MEMORY", "PURGE"); await new Promise((r) => setTimeout(r, 1000));
    const m0 = Number((await v.info("memory")).match(/used_memory:(\d+)/)![1]);
    await fill(v, 0, N);
    await v.call("MEMORY", "PURGE"); await new Promise((r) => setTimeout(r, 500));
    const m1 = Number((await v.info("memory")).match(/used_memory:(\d+)/)![1]);
    await pgc.query(`DROP TABLE IF EXISTS session_unlogged;
      CREATE UNLOGGED TABLE session_unlogged (session_id text PRIMARY KEY, technician_id text NOT NULL, hangar_id text NOT NULL, terminal text NOT NULL, expires_at timestamptz NOT NULL);
      CREATE INDEX ON session_unlogged (expires_at);`);
    for (let i = 0; i < N; i += 5000) {
      const rows = Array.from({ length: Math.min(5000, N - i) }, (_, k) => session(i + k));
      await pgc.query(`INSERT INTO session_unlogged SELECT id, "technicianId", "hangarId", terminal, now() + interval '8 hours'
        FROM jsonb_to_recordset($1::jsonb) AS x(id text, "technicianId" text, "hangarId" text, terminal text)`, [JSON.stringify(rows)]);
    }
    await pgc.query("VACUUM ANALYZE session_unlogged");
    const { rows: [sz] } = await pgc.query("SELECT pg_table_size('session_unlogged') AS t, pg_indexes_size('session_unlogged') AS i");
    // viajes por operación: leer una sesión y abrir una nueva
    const vt = countSocketWrites(v);
    const pt = countRoundTrips(pgc, "query");
    vt.reset(); await v.hgetall("session:0000042"); const vRead = vt.count;
    vt.reset(); await v.pipeline().hset("session:new", "technicianId", "T-001", "hangarId", "VVC", "terminal", "plataforma-1").expire("session:new", 28800).exec(); const vWrite = vt.count;
    pt.reset(); await pgc.query("SELECT * FROM session_unlogged WHERE session_id = $1", ["session:0000042"]); const pRead = pt.count;
    pt.reset(); await pgc.query("INSERT INTO session_unlogged VALUES ('session:new', 'T-001', 'VVC', 'plataforma-1', now() + interval '8 hours')"); const pWrite = pt.count;
    // el vencimiento: Valkey lo hace solo; Postgres necesita un DELETE periódico
    await pgc.query("UPDATE session_unlogged SET expires_at = now() - interval '1 minute' WHERE session_id < 'session:0001000'");
    const { rows: [plan] } = await pgc.query("EXPLAIN (ANALYZE, FORMAT JSON) DELETE FROM session_unlogged WHERE expires_at < now()");
    const del = plan["QUERY PLAN"][0].Plan;
    const vBytes = (m1 - m0) / N;
    const pBytes = (Number(sz.t) + Number(sz.i)) / N;
    console.log(`apuesta · ${N} sesiones`);
    console.log(`   viajes para leer una sesión:  Valkey ${vRead} · Postgres ${pRead}`);
    console.log(`   viajes para abrir una sesión: Valkey ${vWrite} (HSET + EXPIRE en pipeline) · Postgres ${pWrite}`);
    console.log(`   memoria por sesión: Valkey ${vBytes.toFixed(0)} bytes · Postgres UNLOGGED ${pBytes.toFixed(0)} bytes (tabla ${(Number(sz.t) / N).toFixed(0)} + índices ${(Number(sz.i) / N).toFixed(0)}) → ${(pBytes / vBytes).toFixed(2)}×`);
    console.log(`   vencimiento: Valkey por TTL, sin consulta · Postgres, DELETE de las vencidas: ${del.Plans?.[0]?.["Node Type"] ?? del["Node Type"]}, ${del.Plans?.[0]?.["Actual Rows"]} filas`);
    // qué se pierde al reiniciar: apagado limpio y caída, en los dos
    const survive = async (signal: "KILL" | null) => {
      await v.quit(); restart(signal); v = await connect();
      const pgSig = signal ? "KILL" : null;
      if (pgSig) execFileSync("docker", ["kill", "--signal=KILL", "condor-lab-base-1"]); else execFileSync("docker", ["compose", "--profile", "base", "stop"], { cwd: lab, stdio: "ignore" });
      execFileSync("docker", ["compose", "--profile", "base", "up", "-d", "--wait"], { cwd: lab, stdio: "ignore" });
      await pgc.end().catch(() => {});
      const c = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "postgres" });
      await c.connect();
      const { rows: [r] } = await c.query("SELECT count(*)::int AS n FROM session_unlogged");
      await c.end();
      return [await keys(v), r.n];
    };
    const [vClean, pClean] = await survive(null);
    console.log(`   tras un apagado limpio: Valkey ${vClean} claves · Postgres ${pClean} filas`);
    await v.flushall(); await fill(v, 0, N); await v.save();
    await fill(v, N, N + 1000); // mil sesiones nuevas después del último guardado
    const [vKill] = await survive("KILL");
    console.log(`   tras SIGKILL, con ${N} sesiones guardadas y 1000 nuevas sin guardar: Valkey ${vKill} claves · Postgres UNLOGGED: ver a07, se vacía\n`);
  }

  if (only.has("memoria")) {
    // maxmemory: con noeviction, la escritura falla; con allkeys-lru, se borran claves en silencio
    await v.flushall();
    await v.config("SET", "maxmemory", "16mb");
    await v.config("SET", "maxmemory-policy", "noeviction");
    const r = await fill(v, 0, 1_000_000);
    console.log(`maxmemory 16mb, noeviction: la escritura falla a partir de la sesión ${r.stoppedAt} · ${r.error?.message}`);
    await v.flushall();
    await v.config("SET", "maxmemory-policy", "allkeys-lru");
    const reservation = "slot:VVC:foso-1:2026-10-06";
    await v.set(reservation, "grupo-motores"); // una reserva sin TTL, que alguien cree persistente
    await fill(v, 0, 200_000);
    const evicted = Number((await v.info("stats")).match(/evicted_keys:(\d+)/)![1]);
    console.log(`maxmemory 16mb, allkeys-lru, 200000 sesiones escritas: quedan ${await keys(v)} claves · evicted_keys ${evicted} · la reserva sin TTL: ${await v.get(reservation) ?? "desapareció"} · ningún error`);
    await v.flushall();
    await v.config("SET", "maxmemory-policy", "volatile-lru");
    await v.set(reservation, "grupo-motores");
    const r2 = await fill(v, 0, 200_000);
    console.log(`maxmemory 16mb, volatile-lru: quedan ${await keys(v)} claves · la reserva sin TTL: ${await v.get(reservation) ?? "desapareció"} · escritura: ${r2.error ? r2.error.message : "sin error"}\n`);
    await v.config("SET", "maxmemory", "0");
    await v.config("SET", "maxmemory-policy", "noeviction");
    await v.flushall();
  }

  if (only.has("persistencia")) {
    // RDB contra AOF: lo que se pierde con SIGKILL justo después de escribir. Cada configuración en su
    // propio contenedor, con la persistencia en la línea de comandos: CONFIG SET no sobrevive a un
    // reinicio, y el contenedor volvería a arrancar sin AOF.
    const image = "valkey/valkey@sha256:418652cfb58ef879d4978c33553735d7147016032d5aefaa14c828e611eb9dfd";
    for (const [label, extra] of [["RDB por defecto", []], ["AOF everysec", ["--appendonly", "yes", "--appendfsync", "everysec"]], ["AOF always", ["--appendonly", "yes", "--appendfsync", "always"]]] as const) {
      const name = "condor-lab-persistencia";
      execFileSync("docker", ["rm", "-f", name], { stdio: "ignore" });
      execFileSync("docker", ["run", "-d", "--name", name, "-p", "16390:6379", image, "valkey-server", ...extra], { stdio: "ignore" });
      await new Promise((r) => setTimeout(r, 1500));
      const t = new Valkey({ host: "localhost", port: 16390, lazyConnect: true });
      await t.connect();
      await fill(t, 0, 50_000);
      await t.quit();
      execFileSync("docker", ["kill", "--signal=KILL", name]);
      execFileSync("docker", ["start", name]);
      await new Promise((r) => setTimeout(r, 1500));
      const u = new Valkey({ host: "localhost", port: 16390, lazyConnect: true });
      await u.connect();
      console.log(`${label}: 50000 sesiones escritas y SIGKILL inmediato → sobreviven ${await keys(u)}`);
      await u.quit();
      execFileSync("docker", ["rm", "-f", name], { stdio: "ignore" });
    }
  }
} finally {
  await v.quit().catch(() => {});
  await pgc.end().catch(() => {});
}
