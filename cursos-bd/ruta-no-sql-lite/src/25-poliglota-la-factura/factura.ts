// La factura que se mide: cuánto cuesta guardar y recuperar cada motor del diseño. La fuente de verdad (Postgres) y la
// segunda verdad que todavía existe (el MongoDB de Camilo) se respaldan y se restauran; los derivados no se
// respaldan: se rearman, y su costo es el de la reconstrucción. CouchDB y DuckDB ya lo midieron las Fases 24 y 23
// (M-79, M-73); aquí se rearma TimescaleDB desde la descarga. Al final, lo que ocupa cada motor en disco e imagen.
//
//   node 25-poliglota-la-factura/factura.ts [--skip postgres]   (desde src/, con base, documental y series arriba,
//                                                               y boss/setup.ts corrido)
import { execFileSync } from "node:child_process";
import { parseArgs } from "node:util";
import pg from "pg";
import { readNdjson } from "../lab/harness/dataset.ts";

const { values } = parseArgs({ options: { skip: { type: "string", multiple: true, default: [] } } });
const skip = new Set(values.skip);
const sh = (...args: string[]) => execFileSync("docker", args, { encoding: "utf8", maxBuffer: 64 * 2 ** 20 }).trim();
/** Corre algo y devuelve los segundos que tardó. */
const timed = (fn: () => unknown) => { const t = performance.now(); fn(); return (performance.now() - t) / 1000; };
const mib = (bytes: number) => `${(bytes / 2 ** 20).toFixed(0)} MiB`;
const client = async (port: number, database: string) => {
  const c = new pg.Client({ host: "localhost", port, user: "postgres", password: "condor", database });
  await c.connect();
  return c;
};
const BASE = "condor-lab-base-1", DOC = "condor-lab-documental-1";
const BASE_PORT = Number(process.env.BASE_PORT ?? 15432), SERIES_PORT = Number(process.env.SERIES_PORT ?? 15433);

// ── 1 · Postgres, la fuente: pg_dump de la base entera y pg_restore en una base nueva ─────────────────
if (!skip.has("postgres")) {
  const COUNT = `SELECT (SELECT count(*) FROM work_order) || '/' || (SELECT count(*) FROM work_order_movement) || '/' ||
                        (SELECT count(*) FROM part) || '/' || (SELECT count(*) FROM pirep_embedding)`;
  const dump = timed(() => sh("exec", BASE, "pg_dump", "-U", "postgres", "-Fc", "-f", "/tmp/condor.dump", "postgres"));
  const size = Number(sh("exec", BASE, "stat", "-c", "%s", "/tmp/condor.dump"));
  const admin = await client(BASE_PORT, "postgres");
  const live = Number((await admin.query(`SELECT pg_database_size('postgres') AS b`)).rows[0].b);
  await admin.end();
  sh("exec", BASE, "psql", "-U", "postgres", "-c", "DROP DATABASE IF EXISTS restore_check", "-c", "CREATE DATABASE restore_check");
  // los datos en paralelo; los índices de a uno: con -j 4, los dos HNSW piden 2 GB de memoria compartida cada uno a la
  // vez y no caben en el shm_size de base (a09, E-35). Con maintenance_work_mem de 2 GB, como la Fase 16: con los 64 MB
  // de fábrica, cada índice HNSW tarda 2246 s (M-14)
  const restoreArgs = ["exec", "-e", "PGOPTIONS=-c maintenance_work_mem=2GB", BASE, "pg_restore", "-U", "postgres", "-d", "restore_check"];
  const data = timed(() => sh(...restoreArgs, "-j", "4", "--section=pre-data", "--section=data", "/tmp/condor.dump"));
  const indexes = timed(() => sh(...restoreArgs, "--section=post-data", "/tmp/condor.dump"));
  const restore = data + indexes;
  const [a, b] = ["postgres", "restore_check"].map((d) => sh("exec", BASE, "psql", "-U", "postgres", "-d", d, "-Atc", COUNT));
  console.log(`postgres   · base postgres ${mib(live)} · pg_dump ${dump.toFixed(0)} s → ${mib(size)} · pg_restore ${restore.toFixed(0)} s (datos con -j 4 ${data.toFixed(0)} s, índices ${indexes.toFixed(0)} s) · órdenes/movimientos/piezas/vectores ${a} → ${b} ${a === b ? "iguales" : "DISTINTOS"}`);
  sh("exec", BASE, "psql", "-U", "postgres", "-c", "DROP DATABASE restore_check");
  sh("exec", BASE, "rm", "/tmp/condor.dump");
}

// ── 2 · MongoDB, la segunda verdad: mongodump y mongorestore de la base de Camilo ─────────────────────
{
  const count = (db: string) => sh("exec", DOC, "mongosh", "--quiet", "--eval", `db.getSiblingDB("${db}").component.countDocuments()`);
  const dump = timed(() => sh("exec", DOC, "mongodump", "--quiet", "--db", "camilo", "--gzip", "--archive=/tmp/camilo.gz"));
  const size = Number(sh("exec", DOC, "stat", "-c", "%s", "/tmp/camilo.gz"));
  const restore = timed(() => sh("exec", DOC, "mongorestore", "--quiet", "--gzip", "--archive=/tmp/camilo.gz", "--nsFrom", "camilo.*", "--nsTo", "camilo_restore.*", "--drop"));
  const [a, b] = [count("camilo"), count("camilo_restore")];
  console.log(`mongodb    · base camilo · mongodump ${dump.toFixed(1)} s → ${(size / 1024).toFixed(0)} KiB · mongorestore ${restore.toFixed(1)} s · componentes ${a} → ${b} ${a === b ? "iguales" : "DISTINTOS"}`);
  sh("exec", DOC, "mongosh", "--quiet", "--eval", `db.getSiblingDB("camilo_restore").dropDatabase()`);
  sh("exec", DOC, "rm", "/tmp/camilo.gz");
}

// ── 3 · TimescaleDB, un derivado de la descarga: se rearma, no se restaura ────────────────────────────
{
  const ts = await client(SERIES_PORT, "condor");
  await ts.query(`DROP TABLE IF EXISTS reading_rebuilt; CREATE TABLE reading_rebuilt (LIKE reading INCLUDING DEFAULTS);
                  SELECT create_hypertable('reading_rebuilt', by_range('ts', INTERVAL '7 days'));
                  CREATE INDEX ON reading_rebuilt (aircraft, ts DESC);`);
  const COLS = "aircraft, flight_id, ts, altitude_ft, ias_kt, egt_c, n1_pct, oil_press_psi, oil_temp_c, fuel_flow_pph";
  const t = performance.now();
  let batch: unknown[] = [], n = 0;
  const flush = async () => {
    await ts.query(`INSERT INTO reading_rebuilt (${COLS}) SELECT aircraft, "flightId", ts, "altitudeFt", "iasKt", "egtC", "n1Pct", "oilPressPsi", "oilTempC", "fuelFlowPph"
      FROM jsonb_to_recordset($1::jsonb) AS x(aircraft text, "flightId" text, ts timestamp, "altitudeFt" int, "iasKt" int, "egtC" int, "n1Pct" int, "oilPressPsi" int, "oilTempC" int, "fuelFlowPph" int)`, [JSON.stringify(batch)]);
    n += batch.length;
    batch = [];
  };
  for await (const r of readNdjson("lab/data/reading-5m/reading.ndjson")) { batch.push(r); if (batch.length === 50_000) await flush(); }
  if (batch.length) await flush();
  const seconds = (performance.now() - t) / 1000;
  const same = (await ts.query(`SELECT (SELECT count(*) FROM reading) = (SELECT count(*) FROM reading_rebuilt) AS ok`)).rows[0].ok;
  console.log(`timescale  · reading desde reading-5m · ${n} lecturas en ${seconds.toFixed(0)} s (${(n / seconds).toFixed(0)}/s) · mismas filas que reading: ${same ? "sí" : "NO"}`);
  await ts.query(`DROP TABLE reading_rebuilt`);
  await ts.end();
}

// ── 4 · lo que ocupa cada motor: el volumen y la imagen ──────────────────────────────────────────────
const volumes = JSON.parse(`[${sh("system", "df", "-v", "--format", "{{json .Volumes}}").slice(1, -1)}]`);
for (const service of ["base", "series", "offline", "documental"]) {
  const v = volumes.find((x: any) => x.Name === `condor-lab_${service}-data`);
  const image = sh("inspect", "--format", "{{.Image}}", `condor-lab-${service}-1`);
  const imageSize = Number(sh("image", "inspect", "--format", "{{.Size}}", image));
  console.log(`disco      · ${service.padEnd(10)} volumen ${v?.Size ?? "?"} · imagen ${mib(imageSize)}`);
}
