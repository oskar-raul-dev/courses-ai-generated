// La carga de la apuesta, lado Cassandra: las 50 M lecturas ampliadas ×10 en las tres tablas de consulta de
// la Fase 17, y lo que costó escribirlas en el disco. Mide los bytes que el contenedor escribió de verdad
// (commitlog, flushes y compactaciones) desde antes de la primera escritura hasta que no queda ninguna
// compactación pendiente: la escritura de Cassandra no termina cuando el cliente recibe la confirmación.
//
//   node 18-columnar-romper-y-medir/load.ts   (desde src/, con columnar arriba y el keyspace de la Fase 17)
import { execFileSync } from "node:child_process";
import { join } from "node:path";
import cassandra from "cassandra-driver";
import { readNdjson, verifyDataset } from "../lab/harness/dataset.ts";
import { columnar, retries, writeAll } from "../lab/harness/cassandra-trace.ts";
import { containerWrites, MiB, recordWrites } from "../lab/harness/io.ts";

const nodetool = (...args: string[]) =>
  execFileSync("docker", ["compose", "-f", "lab/compose.yaml", "exec", "-T", "columnar", "nodetool", ...args], { encoding: "utf8" });

const dir = "lab/data/reading-5m";
await verifyDataset(dir);
const EGT_THRESHOLD = 720;
const VALUES = "altitude_ft, ias_kt, egt_c, n1_pct, oil_press_psi, oil_temp_c, fuel_flow_pph";
const COLS = "altitude_ft int, ias_kt int, egt_c int, n1_pct int, oil_press_psi int, oil_temp_c int, fuel_flow_pph int";
const TABLES = ["reading_x10_by_aircraft_month", "reading_x10_by_flight", "egt_x10_exceedance_by_day"];

const client = columnar();
await client.connect();
try {
  // las tres tablas desde cero: las mismas de la Fase 17, sobre los 50 M
  for (const t of TABLES) await client.execute(`DROP TABLE IF EXISTS ${t}`);
  // DROP deja una instantánea de lo borrado (Fase 17, sección 9): se libera antes de medir
  nodetool("clearsnapshot", "--all");
  await client.execute(`CREATE TABLE reading_x10_by_aircraft_month (aircraft text, month text, ts timestamp, flight_id text, ${COLS},
    PRIMARY KEY ((aircraft, month), ts)) WITH CLUSTERING ORDER BY (ts ASC)`);
  await client.execute(`CREATE TABLE reading_x10_by_flight (flight_id text, ts timestamp, aircraft text, ${COLS},
    PRIMARY KEY ((flight_id), ts)) WITH CLUSTERING ORDER BY (ts ASC)`);
  await client.execute(`CREATE TABLE egt_x10_exceedance_by_day (day date, aircraft text, ts timestamp, flight_id text, egt_c int,
    PRIMARY KEY ((day), aircraft, ts))`);
  const Q = {
    month: `INSERT INTO reading_x10_by_aircraft_month (aircraft, month, ts, flight_id, ${VALUES}) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    flight: `INSERT INTO reading_x10_by_flight (flight_id, ts, aircraft, ${VALUES}) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    exceedance: "INSERT INTO egt_x10_exceedance_by_day (day, aircraft, ts, flight_id, egt_c) VALUES (?, ?, ?, ?, ?)",
  };

  const w0 = containerWrites("columnar");
  const started = performance.now();
  let pending: { query: string; params: unknown[] }[] = [];
  let rows = 0;
  let read = 0;
  const push = async (query: string, params: unknown[]) => {
    pending.push({ query, params });
    rows++;
    if (pending.length >= 20_000) {
      await writeAll(client, pending);
      pending = [];
    }
  };
  for await (const r of readNdjson<{ aircraft: string; flightId: string; ts: string; altitudeFt: number; iasKt: number; egtC: number; n1Pct: number; oilPressPsi: number; oilTempC: number; fuelFlowPph: number }>(join(dir, "reading.ndjson"))) {
    const ts = new Date(r.ts);
    const values = [r.altitudeFt, r.iasKt, r.egtC, r.n1Pct, r.oilPressPsi, r.oilTempC, r.fuelFlowPph];
    // la misma ampliación ×10 de las Fases 07–10: k = 0 es el original, k = 1…9 llevan sufijo ~k
    for (let k = 0; k < 10; k++) {
      const sfx = k === 0 ? "" : `~${k}`;
      await push(Q.month, [r.aircraft + sfx, r.ts.slice(0, 7), ts, r.flightId + sfx, ...values]);
      await push(Q.flight, [r.flightId + sfx, ts, r.aircraft + sfx, ...values]);
      if (r.egtC >= EGT_THRESHOLD) await push(Q.exceedance, [cassandra.types.LocalDate.fromString(r.ts.slice(0, 10)), r.aircraft + sfx, ts, r.flightId + sfx, r.egtC]);
    }
    if (++read % 500_000 === 0) console.log(`  ${read} lecturas · ${rows} filas · ${((performance.now() - started) / 1000).toFixed(0)} s`);
  }
  if (pending.length) await writeAll(client, pending);
  const acked = (performance.now() - started) / 1000;

  // lo que queda en memoria se escribe, y se espera a que las compactaciones terminen
  nodetool("flush", "condor");
  for (;;) {
    const stats = nodetool("compactionstats");
    // sin tareas pendientes y sin ninguna en curso (las activas salen como filas con el keyspace)
    if (/pending tasks\s+0\b/.test(stats) && !/\bcondor\b/.test(stats)) break;
    await new Promise((r) => setTimeout(r, 10_000));
  }
  const settled = (performance.now() - started) / 1000;
  const written = containerWrites("columnar") - w0;

  // lo que movieron las compactaciones de estas tablas, del historial que guarda el propio nodo
  const since = new Date(Date.now() - settled * 1000 - 60_000);
  const hist = await client.execute("SELECT columnfamily_name, bytes_in, bytes_out, compacted_at FROM system.compaction_history");
  let compacted = 0;
  for (const h of hist.rows) if (TABLES.includes(h.columnfamily_name) && h.compacted_at >= since) compacted += Number(h.bytes_out);
  let live = 0;
  for (const t of TABLES) live += Number(/Space used \(live\): (\d+)/.exec(nodetool("tablestats", `condor.${t}`))?.[1] ?? 0);

  console.log(`cassandra: ${rows} filas en ${TABLES.length} tablas · confirmadas en ${acked.toFixed(0)} s · sin compactaciones pendientes a los ${settled.toFixed(0)} s`);
  console.log(`  escrito al disco ${MiB(written).toFixed(0)} MiB · de eso, compactaciones ${MiB(compacted).toFixed(0)} MiB · en disco al final ${MiB(live).toFixed(0)} MiB`);
  console.log(`  amplificación: ${(written / live).toFixed(2)} bytes escritos por byte que queda`);
  console.log(`reintentos: ${retries.writeTimeout} por write timeout · ${retries.other} por otros motivos`);
  recordWrites("cassandra", { rows, writtenBytes: written, compactedBytes: compacted, liveBytes: live, ackedSeconds: acked, settledSeconds: settled });
} finally {
  await client.shutdown();
}
