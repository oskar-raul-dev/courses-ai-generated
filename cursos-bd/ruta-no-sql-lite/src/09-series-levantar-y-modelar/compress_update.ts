// La situación 3 de series temporales: comprimir la historia como parte del modelo y después corregirla.
// Comprime los chunks de reading_x10 anteriores a 2026 (segmentby aircraft, orderby ts) y aplica la
// misma corrección retroactiva —un desfase de calibración de +3 °C en el EGT de marzo de 2025— en
// TimescaleDB y en la tabla normal de Postgres, midiendo filas, WAL y lo que queda descomprimido.
//
//   node 09-series-levantar-y-modelar/compress_update.ts [--skip-compress]   (desde src/)
import { parseArgs } from "node:util";
import pg from "pg";

const { values: args } = parseArgs({ options: { "skip-compress": { type: "boolean", default: false } } });
const ts = new pg.Client({ host: "localhost", port: Number(process.env.SERIES_PORT ?? 15433), user: "postgres", password: "condor", database: "condor" });
const base = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "series_base" });
await ts.connect();
await base.connect();
const one = async (c: pg.Client, sql: string) => (await c.query(sql)).rows[0];
const mib = (b: number) => `${(b / 2 ** 20).toFixed(1)} MiB`;

const CHUNKS = `SELECT count(*) FILTER (WHERE is_compressed) AS compressed, count(*) AS total
  FROM timescaledb_information.chunks WHERE hypertable_name = 'reading_x10'`;
const PARTIAL = `SELECT count(*) AS partial FROM _timescaledb_catalog.chunk c
  JOIN _timescaledb_catalog.hypertable h ON h.id = c.hypertable_id
  WHERE h.table_name = 'reading_x10' AND c.status & 8 = 8`; // 8: comprimido con filas sin comprimir

try {
  if (!args["skip-compress"]) {
    const sizeBefore = Number((await one(ts, "SELECT hypertable_size('reading_x10') AS s")).s);
    let t = performance.now();
    await ts.query(`ALTER TABLE reading_x10 SET (timescaledb.compress,
      timescaledb.compress_segmentby = 'aircraft', timescaledb.compress_orderby = 'ts')`);
    // la política que lo haría sola: comprimir lo que tenga más de 90 días
    await ts.query("SELECT add_compression_policy('reading_x10', INTERVAL '90 days', if_not_exists => true)");
    // aquí se comprime a mano lo anterior a 2026, sin esperar a la política
    await ts.query("SELECT count(compress_chunk(c, true)) FROM show_chunks('reading_x10', older_than => TIMESTAMP '2026-01-01') c");
    const sizeAfter = Number((await one(ts, "SELECT hypertable_size('reading_x10') AS s")).s);
    const c = await one(ts, CHUNKS);
    console.log(`comprimidos ${c.compressed} de ${c.total} chunks en ${((performance.now() - t) / 1000).toFixed(1)} s · hypertable ${mib(sizeBefore)} → ${mib(sizeAfter)}`);
  }

  // un chunk que quedó a medias de una corrida anterior se vuelve a comprimir: se parte limpio
  await ts.query("SELECT count(compress_chunk(c, true)) FROM show_chunks('reading_x10', older_than => TIMESTAMP '2026-01-01') c");
  console.log(`antes de corregir: chunks parcialmente descomprimidos ${(await one(ts, PARTIAL)).partial}`);

  const FIX = `UPDATE reading_x10 SET egt_c = egt_c + 3 WHERE aircraft = 'HK-4207' AND ts >= '2025-03-01' AND ts < '2025-04-01'`;
  const FLEET = `UPDATE reading_x10 SET egt_c = egt_c + 3 WHERE ts >= '2025-03-01' AND ts < '2025-04-01'`;
  const measure = async (label: string, engine: string, c: pg.Client, sql: string) => {
    await c.query("CHECKPOINT");
    const lsn = (await one(c, "SELECT pg_current_wal_insert_lsn() AS l")).l;
    const t = performance.now();
    try {
      const r = await c.query(sql);
      const seconds = (performance.now() - t) / 1000;
      const wal = Number((await one(c, `SELECT pg_wal_lsn_diff(pg_current_wal_insert_lsn(), '${lsn}') AS w`)).w);
      const extra = engine === "timescale" ? ` · chunks parcialmente descomprimidos ${(await one(ts, PARTIAL)).partial}` : "";
      console.log(`${label.padEnd(30)} ${engine.padEnd(9)} filas ${String(r.rowCount).padStart(7)} · WAL ${mib(wal).padStart(12)} · ${seconds.toFixed(1)} s${extra}`);
    } catch (e) {
      const err = e as { message: string; detail?: string; hint?: string };
      console.log(`${label.padEnd(30)} ${engine.padEnd(9)} ERROR: ${err.message}\n${" ".repeat(41)}DETAIL: ${err.detail}\n${" ".repeat(41)}HINT: ${err.hint}`);
    }
  };
  await measure("una aeronave (HK-4207)", "timescale", ts, FIX);
  await measure("una aeronave (HK-4207)", "postgres", base, FIX);
  await measure("toda la flota", "timescale", ts, FLEET);
  // el límite de descompresión por transacción existe para frenar justo esto; aquí se quita a propósito
  await ts.query("SET timescaledb.max_tuples_decompressed_per_dml_transaction = 0");
  await measure("toda la flota, sin límite", "timescale", ts, FLEET);
  await measure("toda la flota", "postgres", base, FLEET);
  const size = Number((await one(ts, "SELECT hypertable_size('reading_x10') AS s")).s);
  console.log(`hypertable después de las correcciones: ${mib(size)}`);
  // se deshacen las correcciones para que los datos vuelvan a tener la huella de la Fase 07
  for (const c of [ts, base]) {
    await c.query(FLEET.replace("+ 3", "- 3"));
    await c.query(FIX.replace("+ 3", "- 3"));
  }
} finally {
  await ts.end();
  await base.end();
}
