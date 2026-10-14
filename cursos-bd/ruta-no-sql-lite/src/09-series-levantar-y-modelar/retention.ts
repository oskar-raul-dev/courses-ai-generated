// El 🪞 de la Fase 09: borrar el primer año de lecturas (antes del 01/10/2022) de las 50 M. En la
// tabla normal, un DELETE; en la hypertable, drop_chunks. Se mide lo que escribe cada uno en el WAL,
// cuántas filas toca, el tamaño que queda y qué pasa con el roll-up diario.
// Es destructivo: después hay que volver a correr load.ts (y rollups.sql) para recuperar la huella.
//
//   node 09-series-levantar-y-modelar/retention.ts   (desde src/)
import pg from "pg";

const ts = new pg.Client({ host: "localhost", port: Number(process.env.SERIES_PORT ?? 15433), user: "postgres", password: "condor", database: "condor" });
const base = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "series_base" });
await ts.connect();
await base.connect();
const one = async (c: pg.Client, sql: string) => (await c.query(sql)).rows[0];
const mib = (b: number) => `${(b / 2 ** 20).toFixed(1)} MiB`;
const CUT = "2022-10-01";

const run = async (engine: string, c: pg.Client, sql: string, size: string) => {
  const rowsBefore = Number((await one(c, `SELECT count(*) AS n FROM reading_x10 WHERE ts < '${CUT}'`)).n);
  const sizeBefore = Number((await one(c, `SELECT ${size} AS s`)).s);
  await c.query("CHECKPOINT");
  const lsn = (await one(c, "SELECT pg_current_wal_insert_lsn() AS l")).l;
  const t = performance.now();
  const r = await c.query(sql);
  const seconds = (performance.now() - t) / 1000;
  const wal = Number((await one(c, `SELECT pg_wal_lsn_diff(pg_current_wal_insert_lsn(), '${lsn}') AS w`)).w);
  const sizeAfter = Number((await one(c, `SELECT ${size} AS s`)).s);
  const rowsAfter = Number((await one(c, `SELECT count(*) AS n FROM reading_x10 WHERE ts < '${CUT}'`)).n);
  const touched = engine === "timescale" ? `chunks borrados ${r.rows.length}` : `filas borradas ${r.rowCount}`;
  console.log(`${engine.padEnd(9)} antes del corte ${rowsBefore} → ${rowsAfter} · ${touched} · WAL ${mib(wal)} · tamaño ${mib(sizeBefore)} → ${mib(sizeAfter)} · ${seconds.toFixed(1)} s`);
};

try {
  const dailyBefore = Number((await one(ts, `SELECT count(*) AS n FROM reading_daily WHERE bucket < '${CUT}'`)).n);
  await run("postgres", base, `DELETE FROM reading_x10 WHERE ts < '${CUT}'`, "pg_relation_size('reading_x10')");
  await run("timescale", ts, `SELECT drop_chunks('reading_x10', older_than => TIMESTAMP '${CUT}')`, "hypertable_size('reading_x10')");
  const dailyAfter = Number((await one(ts, `SELECT count(*) AS n FROM reading_daily WHERE bucket < '${CUT}'`)).n);
  console.log(`reading_daily antes del corte: ${dailyBefore} días-aeronave → ${dailyAfter} (el roll-up conserva la historia)`);
  // el espacio del DELETE no vuelve al sistema hasta un VACUUM FULL; un VACUUM solo lo deja reutilizable
  const t = performance.now();
  await base.query("VACUUM reading_x10");
  const afterVacuum = Number((await one(base, "SELECT pg_relation_size('reading_x10') AS s")).s);
  console.log(`postgres  después de VACUUM: ${mib(afterVacuum)} · ${((performance.now() - t) / 1000).toFixed(1)} s`);
} finally {
  await ts.end();
  await base.end();
}
