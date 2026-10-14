// El backfill: dos meses de lecturas que llegan tarde —una aeronave cuyo grabador se descargó con
// retraso— dentro de un período que en Timescale ya está comprimido. Las mismas filas, en la hypertable
// (base condor) y en las particiones de Postgres (reading_part, base series_base).
//
//   node 10-series-romper-y-medir/backfill.ts   (desde src/, después de compress.sql y partition.ts)
import pg from "pg";

const ts = new pg.Client({ host: "localhost", port: Number(process.env.SERIES_PORT ?? 15433), user: "postgres", password: "condor", database: "condor" });
const base = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "series_base" });
await ts.connect();
await base.connect();
const one = async (c: pg.Client, sql: string) => (await c.query(sql)).rows[0];
const mib = (b: number) => `${(b / 2 ** 20).toFixed(1)} MiB`;
// las lecturas de HK-4207 en marzo y abril de 2025, como si fueran de otra aeronave que llegó tarde
const LATE = (t: string) => `INSERT INTO ${t} SELECT 'HK-TARDE', flight_id || '-T', ts, altitude_ft, ias_kt, egt_c, n1_pct, oil_press_psi, oil_temp_c, fuel_flow_pph
  FROM ${t} WHERE aircraft = 'HK-4207' AND ts >= '2025-03-01' AND ts < '2025-05-01'`;
const PARTIAL = `SELECT count(*) AS n FROM _timescaledb_catalog.chunk c JOIN _timescaledb_catalog.hypertable h ON h.id = c.hypertable_id
  WHERE h.table_name = 'reading_x10' AND c.status & 8 = 8`;
try {
  for (const [engine, c, table] of [["timescale", ts, "reading_x10"], ["postgres", base, "reading_part"]] as const) {
    await c.query("CHECKPOINT");
    const lsn = (await one(c, "SELECT pg_current_wal_insert_lsn() AS l")).l;
    const t = performance.now();
    const r = await c.query(LATE(table));
    const seconds = (performance.now() - t) / 1000;
    const wal = Number((await one(c, `SELECT pg_wal_lsn_diff(pg_current_wal_insert_lsn(), '${lsn}') AS w`)).w);
    const extra = engine === "timescale" ? ` · chunks a medias ${(await one(ts, PARTIAL)).n}` : "";
    console.log(`${engine.padEnd(9)} filas ${r.rowCount} · WAL ${mib(wal)} · ${seconds.toFixed(1)} s${extra}`);
  }
  // recomprimir lo que quedó a medias: la otra mitad de la factura
  await ts.query("CHECKPOINT");
  const lsn = (await one(ts, "SELECT pg_current_wal_insert_lsn() AS l")).l;
  const t = performance.now();
  await ts.query("SELECT count(compress_chunk(c, true)) FROM show_chunks('reading_x10', older_than => TIMESTAMP '2026-01-01') c");
  const wal = Number((await one(ts, `SELECT pg_wal_lsn_diff(pg_current_wal_insert_lsn(), '${lsn}') AS w`)).w);
  console.log(`timescale recomprimir · WAL ${mib(wal)} · ${((performance.now() - t) / 1000).toFixed(1)} s · chunks a medias ${(await one(ts, PARTIAL)).n}`);
  // las filas de prueba se van
  await ts.query("SET timescaledb.max_tuples_decompressed_per_dml_transaction = 0");
  await ts.query("DELETE FROM reading_x10 WHERE aircraft = 'HK-TARDE'");
  await ts.query("SELECT count(compress_chunk(c, true)) FROM show_chunks('reading_x10', older_than => TIMESTAMP '2026-01-01') c");
  await base.query("DELETE FROM reading_part WHERE aircraft = 'HK-TARDE'");
} finally {
  await ts.end();
  await base.end();
}
