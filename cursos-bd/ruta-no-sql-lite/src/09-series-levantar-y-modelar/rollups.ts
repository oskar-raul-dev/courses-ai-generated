// Los roll-ups medidos: el gráfico de tendencia leído del agregado continuo contra la tabla cruda, y
// lo que cuesta mantenerlo al día cuando llega un vuelo nuevo. La línea base es una vista
// materializada de Postgres, que solo sabe refrescarse entera.
//
//   node 09-series-levantar-y-modelar/rollups.ts   (desde src/, después de rollups.sql)
import pg from "pg";
import { explain } from "../lab/harness/explain.ts";

const ts = new pg.Client({ host: "localhost", port: Number(process.env.SERIES_PORT ?? 15433), user: "postgres", password: "condor", database: "condor" });
const base = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "series_base" });
await ts.connect();
await base.connect();

/** Filas leídas de las tablas indicadas, según las estadísticas de Postgres (recorridos e índices). */
const tuplesRead = async (c: pg.Client, tables: string[]): Promise<number> => {
  await c.query("SELECT pg_stat_force_next_flush()");
  const { rows } = await c.query(
    `SELECT coalesce(sum(seq_tup_read + coalesce(idx_tup_fetch, 0)), 0)::bigint AS n FROM pg_stat_user_tables WHERE relname = ANY($1)`, [tables]);
  return Number(rows[0].n);
};

try {
  // 1. el gráfico de cinco años de una aeronave, un punto por día
  const trend = `SELECT bucket, egt_avg FROM reading_daily WHERE aircraft = 'HC-2157' AND bucket < '2026-10-01' ORDER BY bucket`;
  const r1 = await explain(ts, trend);
  console.log(`tendencia de 5 años desde reading_daily: examinadas ${r1.examined} · devueltas ${r1.returned} · páginas ${r1.sharedHit + r1.sharedRead}`);

  await base.query("DROP MATERIALIZED VIEW IF EXISTS reading_daily");
  let t = performance.now();
  await base.query(`CREATE MATERIALIZED VIEW reading_daily AS
    SELECT aircraft, date_trunc('day', ts) AS bucket, count(*) AS minutes, avg(egt_c) AS egt_avg, max(egt_c) AS egt_max
    FROM reading_x10 GROUP BY 1, 2`);
  await base.query("CREATE INDEX ON reading_daily (aircraft, bucket)");
  await base.query("VACUUM ANALYZE reading_daily");
  console.log(`postgres: vista materializada creada en ${((performance.now() - t) / 1000).toFixed(1)} s`);
  const r2 = await explain(base, trend);
  console.log(`tendencia de 5 años desde la vista de Postgres: examinadas ${r2.examined} · devueltas ${r2.returned} · páginas ${r2.sharedHit + r2.sharedRead}`);

  // 2. llega un vuelo nuevo: 90 minutos de una aeronave de prueba el último día de la ventana
  const flight = `INSERT INTO reading_x10 SELECT 'HK-PRUEBA', 'FL-PRUEBA', ts::timestamp, 16000, 220, 700, 88, 100, 80, 420
    FROM generate_series(timestamp '2026-09-29 10:00', timestamp '2026-09-29 11:29', interval '1 minute') AS ts`;
  await ts.query(flight);
  await base.query(flight);

  // los chunks de reading_x10: cada uno es una tabla, y sus contadores dicen cuánto se leyó
  const { rows: chunkRows } = await ts.query(
    "SELECT chunk_name FROM timescaledb_information.chunks WHERE hypertable_name = 'reading_x10'");
  const chunks = chunkRows.map((r) => r.chunk_name as string);
  let before = await tuplesRead(ts, chunks);
  t = performance.now();
  // la ventana que refrescaría la política: los últimos tres días que ya terminaron
  await ts.query("CALL refresh_continuous_aggregate('reading_hourly', '2026-09-27', '2026-09-30')");
  await ts.query("CALL refresh_continuous_aggregate('reading_daily', '2026-09-27', '2026-09-30')");
  let read = (await tuplesRead(ts, chunks)) - before;
  console.log(`timescale: refresco incremental tras un vuelo de 90 min · lecturas leídas ${read} · ${((performance.now() - t) / 1000).toFixed(1)} s`);

  before = await tuplesRead(base, ["reading_x10"]);
  t = performance.now();
  await base.query("REFRESH MATERIALIZED VIEW reading_daily");
  read = (await tuplesRead(base, ["reading_x10"])) - before;
  console.log(`postgres:  REFRESH MATERIALIZED VIEW tras el mismo vuelo · lecturas leídas ${read} · ${((performance.now() - t) / 1000).toFixed(1)} s`);

  // el vuelo de prueba se borra y los agregados vuelven a como estaban
  await ts.query("DELETE FROM reading_x10 WHERE aircraft = 'HK-PRUEBA'");
  await ts.query("CALL refresh_continuous_aggregate('reading_hourly', '2026-09-27', '2026-09-30')");
  await ts.query("CALL refresh_continuous_aggregate('reading_daily', '2026-09-27', '2026-09-30')");
  await base.query("DELETE FROM reading_x10 WHERE aircraft = 'HK-PRUEBA'");
  await base.query("REFRESH MATERIALIZED VIEW reading_daily");
} finally {
  await ts.end();
  await base.end();
}
