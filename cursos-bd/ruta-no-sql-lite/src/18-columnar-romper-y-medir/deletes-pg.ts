// El mismo borrado de tombstones.ts en Postgres: la partición de HC-2157 de octubre de 2025 (5040 lecturas)
// copiada a una tabla con su índice, borrada fila por fila, y leída antes y después de VACUUM. Postgres
// también deja marcas al borrar —tuplas muertas—, pero las limpia en cuanto ninguna transacción las ve, sin
// esperar diez días: no tiene réplicas que puedan no haberse enterado.
//
//   node 18-columnar-romper-y-medir/deletes-pg.ts   (desde src/, con base arriba y reading_part5 de la Fase 17)
import pg from "pg";
import { explain } from "../lab/harness/explain.ts";

const c = new pg.Client({ host: "localhost", port: Number(process.env.BASE_PORT ?? 15432), user: "postgres", password: "condor", database: "series_base" });
await c.connect();
const SELECT = "SELECT ts, egt_c FROM reading_del WHERE aircraft = 'HC-2157' AND ts >= '2025-10-01' AND ts < '2025-11-01'";
const show = async (label: string) => {
  const e = await explain(c, SELECT);
  const { rows: [s] } = await c.query("SELECT n_live_tup, n_dead_tup, pg_total_relation_size('reading_del') AS bytes FROM pg_stat_user_tables WHERE relname = 'reading_del'");
  console.log(`${label.padEnd(30)} devueltas ${String(e.returned).padStart(5)} · examinadas ${String(e.examined).padStart(5)} · páginas ${String(e.sharedHit + e.sharedRead).padStart(4)} · tuplas muertas ${String(s.n_dead_tup).padStart(5)} · en disco ${(Number(s.bytes) / 1024).toFixed(0)} KiB`);
};
try {
  await c.query("DROP TABLE IF EXISTS reading_del");
  // sin autovacuum, para ver el antes y el después de VACUUM sin que se adelante
  await c.query("CREATE TABLE reading_del WITH (autovacuum_enabled = off) AS SELECT * FROM reading_part5 WHERE aircraft = 'HC-2157' AND ts >= '2025-10-01' AND ts < '2025-11-01'");
  await c.query("CREATE INDEX ON reading_del (aircraft, ts)");
  await c.query("ANALYZE reading_del");
  await show("la partición copiada");
  const { rows } = await c.query("SELECT ts FROM reading_del");
  const { rows: [{ lsn }] } = await c.query("SELECT pg_current_wal_lsn() AS lsn");
  for (const r of rows) await c.query("DELETE FROM reading_del WHERE aircraft = 'HC-2157' AND ts = $1", [r.ts]);
  const { rows: [{ wal }] } = await c.query("SELECT pg_wal_lsn_diff(pg_current_wal_lsn(), $1) AS wal", [lsn]);
  await c.query("SELECT pg_stat_force_next_flush()");
  await show(`${rows.length} DELETE (WAL ${(Number(wal) / 1024).toFixed(0)} KiB)`);
  await c.query("VACUUM reading_del");
  await c.query("SELECT pg_stat_force_next_flush()");
  await show("después de VACUUM");
  await c.query("DROP TABLE reading_del");
} finally {
  await c.end();
}
