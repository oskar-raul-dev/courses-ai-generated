// La compactación es la otra mitad de cada escritura: Cassandra escribe SSTables inmutables y después las
// reescribe para juntarlas. Las mismas 5 M lecturas, en orden de tiempo y con la marca de tiempo de cada una
// (USING TIMESTAMP, como si llegaran en vivo), en dos tablas iguales salvo la estrategia: SizeTiered, la que
// trae por defecto, y TimeWindow, la que la documentación recomienda para series. Se vuelca a disco cada
// semana de datos y se mide cuánto reescribió cada una, cuántas SSTables quedan y cuántas abre la consulta 1.
//
//   node 18-columnar-romper-y-medir/compaction.ts   (desde src/, con base y columnar arriba)
import { execFileSync } from "node:child_process";
import { readFileSync } from "node:fs";
import cassandra from "cassandra-driver";
import pg from "pg";
import { columnar, traced, writeAll } from "../lab/harness/cassandra-trace.ts";
import { containerWrites, MiB } from "../lab/harness/io.ts";

const nodetool = (...args: string[]) =>
  execFileSync("docker", ["compose", "-f", "lab/compose.yaml", "exec", "-T", "columnar", "nodetool", ...args], { encoding: "utf8" });
const settle = async () => {
  for (;;) {
    const s = nodetool("compactionstats");
    if (/pending tasks\s+0\b/.test(s) && !/\bcondor\b/.test(s)) return;
    await new Promise((r) => setTimeout(r, 5_000));
  }
};

const STRATEGIES = {
  reading_stcs: "{'class': 'SizeTieredCompactionStrategy'}",
  // ventanas de 30 días: una partición (aeronave, mes) cae casi siempre en una o dos ventanas
  reading_twcs: "{'class': 'TimeWindowCompactionStrategy', 'compaction_window_unit': 'DAYS', 'compaction_window_size': 30}",
};
const trend = JSON.parse(readFileSync("lab/data/reading-5m/answers.json", "utf8")).egtTrend as { aircraft: string; from: string; to: string };

const cs = columnar();
await cs.connect();
const pgc = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "series_base" });
await pgc.connect();
try {
  for (const [table, strategy] of Object.entries(STRATEGIES)) {
    await cs.execute(`DROP TABLE IF EXISTS ${table}`);
    nodetool("clearsnapshot", "--all");
    await cs.execute(`CREATE TABLE ${table} (aircraft text, month text, ts timestamp, flight_id text, egt_c int, n1_pct int, fuel_flow_pph int,
      PRIMARY KEY ((aircraft, month), ts)) WITH compaction = ${strategy}`);
    const insert = `INSERT INTO ${table} (aircraft, month, ts, flight_id, egt_c, n1_pct, fuel_flow_pph) VALUES (?, ?, ?, ?, ?, ?, ?) USING TIMESTAMP ?`;
    const started = new Date();
    const w0 = containerWrites("columnar");
    let flushes = 0;
    // las lecturas en orden de tiempo, mes a mes desde Postgres (reading-5m viene agrupado por aeronave)
    for (let m = 0; m < 60; m++) {
      const from = new Date(Date.UTC(2021, 9 + m, 1)).toISOString().slice(0, 10);
      const to = new Date(Date.UTC(2021, 10 + m, 1)).toISOString().slice(0, 10);
      // ts sale como texto: el driver pg corre la hora local sobre un timestamp sin zona (Fase 09)
      const { rows: raw } = await pgc.query(`SELECT aircraft, to_char(ts, 'YYYY-MM-DD"T"HH24:MI:SS"Z"') AS ts, flight_id, egt_c, n1_pct, fuel_flow_pph
        FROM reading WHERE ts >= $1 AND ts < $2 ORDER BY ts`, [from, to]);
      const rows = raw.map((r) => ({ ...r, ts: new Date(r.ts) }));
      // una semana de datos por volcado: la memtable se vacía como lo haría con el tráfico real
      for (let i = 0; i < rows.length; ) {
        const weekEnd = rows[i].ts.getTime() + 7 * 86_400_000;
        const batch = [];
        for (; i < rows.length && rows[i].ts.getTime() < weekEnd; i++) {
          const r = rows[i];
          batch.push({ query: insert, params: [r.aircraft, r.ts.toISOString().slice(0, 7), r.ts, r.flight_id, r.egt_c, r.n1_pct, r.fuel_flow_pph, cassandra.types.Long.fromNumber(r.ts.getTime() * 1000)] });
        }
        await writeAll(cs, batch);
        nodetool("flush", "condor", table);
        flushes++;
      }
    }
    await settle();
    const written = containerWrites("columnar") - w0;
    const hist = await cs.execute("SELECT columnfamily_name, bytes_in, bytes_out, compacted_at FROM system.compaction_history");
    let compacted = 0;
    let compactions = 0;
    for (const h of hist.rows) if (h.columnfamily_name === table && h.compacted_at >= started) {
      compacted += Number(h.bytes_out);
      compactions++;
    }
    const stats = nodetool("tablestats", `condor.${table}`);
    const live = Number(/Space used \(live\): (\d+)/.exec(stats)?.[1]);
    const sstables = Number(/SSTable count: (\d+)/.exec(stats)?.[1]);

    const months = ["2025-09", "2025-10", "2025-11"];
    const q1 = await traced(cs, `SELECT ts, egt_c FROM ${table} WHERE aircraft = ? AND month IN ? AND ts >= ? AND ts < ?`, [trend.aircraft, months, new Date(`${trend.from}T00:00:00Z`), new Date(`${trend.to}T00:00:00Z`)]);
    const last = await traced(cs, `SELECT ts, egt_c FROM ${table} WHERE aircraft = ? AND month = ?`, [trend.aircraft, "2026-09"]);
    console.log(`${table} · ${flushes} volcados · ${compactions} compactaciones que reescribieron ${MiB(compacted).toFixed(0)} MiB · escrito al disco ${MiB(written).toFixed(0)} MiB · en disco ${MiB(live).toFixed(0)} MiB · ${sstables} SSTables`);
    console.log(`  consulta 1 (3 meses)      devueltas ${q1.returned} · particiones ${q1.partitions} · sstables ${q1.sstables}`);
    console.log(`  el último mes de HC-2157  devueltas ${last.returned} · particiones ${last.partitions} · sstables ${last.sstables}`);
  }
} finally {
  await cs.shutdown();
  await pgc.end();
}
