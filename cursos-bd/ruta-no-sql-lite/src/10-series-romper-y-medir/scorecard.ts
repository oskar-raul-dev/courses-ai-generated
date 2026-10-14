// La apuesta de la Fase 10 en una tarjeta de cinco medidas de forma: la hypertable comprimida de
// TimescaleDB (base condor) contra Postgres con particionado declarativo por mes (reading_part, base
// series_base), sobre las mismas 50 M lecturas. La apuesta se gana si Postgres queda a 1,25× o menos de
// Timescale en al menos cuatro de las cinco.
//
//   node 10-series-romper-y-medir/scorecard.ts [--with-retention]   (desde src/)
//   --with-retention borra el primer año en los dos (destructivo: después, 09-…/load.ts otra vez)
import { parseArgs } from "node:util";
import pg from "pg";
import { explain, type PlanNode } from "../lab/harness/explain.ts";

const { values: args } = parseArgs({ options: { "with-retention": { type: "boolean", default: false } } });
const ts = new pg.Client({ host: "localhost", port: Number(process.env.SERIES_PORT ?? 15433), user: "postgres", password: "condor", database: "condor" });
const base = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "series_base" });
await ts.connect();
await base.connect();
const one = async (c: pg.Client, sql: string) => (await c.query(sql)).rows[0];
const mib = (b: number) => `${(b / 2 ** 20).toFixed(1)} MiB`;
const card: { metric: string; timescale: number; postgres: number; unit: string }[] = [];

/** Tablas distintas que aparecen en el plan: chunks o particiones tocadas. */
const tablesIn = (plan: PlanNode, prefix: string): number => {
  const seen = new Set<string>();
  const walk = (n: PlanNode) => { if (n["Relation Name"]?.startsWith(prefix)) seen.add(n["Relation Name"]); n.Plans?.forEach(walk); };
  walk(plan);
  return seen.size;
};
const tuplesRead = async (c: pg.Client, tables: string[]): Promise<number> => {
  await c.query("SELECT pg_stat_force_next_flush()");
  const { rows } = await c.query(`SELECT coalesce(sum(seq_tup_read + coalesce(idx_tup_fetch, 0)), 0)::bigint AS n FROM pg_stat_user_tables WHERE relname = ANY($1)`, [tables]);
  return Number(rows[0].n);
};
const walSince = async (c: pg.Client, run: () => Promise<unknown>): Promise<number> => {
  await c.query("CHECKPOINT");
  const lsn = (await one(c, "SELECT pg_current_wal_insert_lsn() AS l")).l;
  await run();
  return Number((await one(c, `SELECT pg_wal_lsn_diff(pg_current_wal_insert_lsn(), '${lsn}') AS w`)).w);
};

try {
  // 1 y 2: leer
  const READS: [string, string][] = [
    ["páginas · la flota, marzo de 2025", `SELECT aircraft, avg(egt_c), max(egt_c) FROM %T WHERE ts >= '2025-03-01' AND ts < '2025-04-01' GROUP BY aircraft`],
    ["páginas · HC-2157, 60 días", `SELECT date_trunc('day', ts), avg(egt_c) FROM %T WHERE aircraft = 'HC-2157' AND ts >= '2025-09-15' AND ts < '2025-11-14' GROUP BY 1`],
  ];
  for (const [metric, sql] of READS) {
    const a = await explain(ts, sql.replace("%T", "reading_x10"));
    const b = await explain(base, sql.replace("%T", "reading_part"));
    console.log(`${metric}\n  timescale examinadas ${a.examined} · páginas ${a.sharedHit + a.sharedRead} · chunks ${tablesIn(a.plan, "_hyper_")} (${[...new Set(a.access.map((x) => x.replace(/_hyper_\d+_\d+_chunk/g, "<chunk>")))].join(", ")})`);
    console.log(`  postgres  examinadas ${b.examined} · páginas ${b.sharedHit + b.sharedRead} · particiones ${tablesIn(b.plan, "reading_part_")} (${[...new Set(b.access.map((x) => x.replace(/reading_part_\w+/g, "<partición>")))].join(", ")})`);
    card.push({ metric, timescale: a.sharedHit + a.sharedRead, postgres: b.sharedHit + b.sharedRead, unit: "páginas" });
  }

  // 3: tamaño de los cinco años
  const sTs = Number((await one(ts, "SELECT hypertable_size('reading_x10') AS s")).s);
  const sPg = Number((await one(base, "SELECT sum(pg_total_relation_size(inhrelid)) AS s FROM pg_inherits WHERE inhparent = 'reading_part'::regclass")).s);
  console.log(`tamaño en disco, con índices\n  timescale ${mib(sTs)} (comprimido lo anterior a 2026)\n  postgres  ${mib(sPg)}`);
  card.push({ metric: "tamaño de los cinco años", timescale: sTs / 2 ** 20, postgres: sPg / 2 ** 20, unit: "MiB" });

  // 4: mantener el diario tras un vuelo nuevo. Postgres, de dos formas: la vista materializada y un
  // resumen en tabla que se refresca a mano solo en la ventana, que es lo que haría alguien que sabe.
  await base.query("DROP MATERIALIZED VIEW IF EXISTS reading_part_daily_mv");
  await base.query(`CREATE MATERIALIZED VIEW reading_part_daily_mv AS SELECT aircraft, date_trunc('day', ts) AS bucket,
      count(*) AS minutes, avg(egt_c) AS egt_avg, max(egt_c) AS egt_max FROM reading_part GROUP BY 1, 2`);
  await base.query("DROP TABLE IF EXISTS reading_part_daily");
  await base.query(`CREATE TABLE reading_part_daily AS SELECT * FROM reading_part_daily_mv`);
  await base.query("CREATE INDEX ON reading_part_daily (bucket)");
  const flight = (t: string) => `INSERT INTO ${t} SELECT 'HK-PRUEBA', 'FL-PRUEBA', g, 16000, 220, 700, 88, 100, 80, 420
    FROM generate_series(timestamp '2026-09-29 10:00', timestamp '2026-09-29 11:29', interval '1 minute') AS g`;
  await ts.query(flight("reading_x10"));
  await base.query(flight("reading_part"));
  const chunks = (await ts.query("SELECT chunk_name FROM timescaledb_information.chunks WHERE hypertable_name = 'reading_x10'")).rows.map((r) => r.chunk_name as string);
  const parts = (await base.query("SELECT inhrelid::regclass::text AS t FROM pg_inherits WHERE inhparent = 'reading_part'::regclass")).rows.map((r) => r.t as string);
  let before = await tuplesRead(ts, chunks);
  await ts.query("CALL refresh_continuous_aggregate('reading_hourly', '2026-09-27', '2026-09-30')");
  await ts.query("CALL refresh_continuous_aggregate('reading_daily', '2026-09-27', '2026-09-30')");
  const readTs = (await tuplesRead(ts, chunks)) - before;
  before = await tuplesRead(base, parts);
  await base.query("REFRESH MATERIALIZED VIEW reading_part_daily_mv");
  const readMv = (await tuplesRead(base, parts)) - before;
  before = await tuplesRead(base, parts);
  await base.query("BEGIN");
  await base.query("DELETE FROM reading_part_daily WHERE bucket >= '2026-09-27' AND bucket < '2026-09-30'");
  await base.query(`INSERT INTO reading_part_daily SELECT aircraft, date_trunc('day', ts), count(*), avg(egt_c), max(egt_c)
    FROM reading_part WHERE ts >= '2026-09-27' AND ts < '2026-09-30' GROUP BY 1, 2`);
  await base.query("COMMIT");
  const readWindow = (await tuplesRead(base, parts)) - before;
  console.log(`lecturas leídas para mantener el diario tras un vuelo de 90 minutos\n  timescale ${readTs} (agregado continuo)\n  postgres  ${readMv} (REFRESH MATERIALIZED VIEW) · ${readWindow} (resumen en tabla, ventana a mano)`);
  card.push({ metric: "lecturas para mantener el diario", timescale: readTs, postgres: readWindow, unit: "lecturas" });
  await ts.query("DELETE FROM reading_x10 WHERE aircraft = 'HK-PRUEBA'");
  await ts.query("CALL refresh_continuous_aggregate('reading_hourly', '2026-09-27', '2026-09-30')");
  await ts.query("CALL refresh_continuous_aggregate('reading_daily', '2026-09-27', '2026-09-30')");
  await base.query("DELETE FROM reading_part WHERE aircraft = 'HK-PRUEBA'");

  // 5: borrar el primer año
  if (args["with-retention"]) {
    let dropped = 0;
    const walTs = await walSince(ts, async () => { dropped = (await ts.query("SELECT drop_chunks('reading_x10', older_than => TIMESTAMP '2022-10-01')")).rows.length; });
    const old = parts.filter((p) => /reading_part_(2021_1[0-2]|2022_0[1-9])$/.test(p));
    const walPg = await walSince(base, async () => { for (const p of old) await base.query(`DROP TABLE ${p}`); });
    console.log(`borrar el primer año\n  timescale ${dropped} chunks · WAL ${mib(walTs)}\n  postgres  ${old.length} particiones · WAL ${mib(walPg)}`);
    card.push({ metric: "WAL de borrar el primer año", timescale: walTs / 2 ** 20, postgres: walPg / 2 ** 20, unit: "MiB" });
  }

  console.log("\nla tarjeta (Postgres / Timescale; la apuesta pide ≤ 1,25 en cuatro de cinco)");
  let won = 0;
  for (const m of card) {
    const ratio = m.postgres / m.timescale;
    if (ratio <= 1.25) won++;
    console.log(`  ${m.metric.padEnd(36)} ${m.timescale.toFixed(1).padStart(10)} · ${m.postgres.toFixed(1).padStart(10)} ${m.unit.padEnd(9)} → ${ratio.toFixed(2)}× ${ratio <= 1.25 ? "✓" : "✗"}`);
  }
  console.log(`  Postgres llega en ${won} de ${card.length}`);
} finally {
  await ts.end();
  await base.end();
}
