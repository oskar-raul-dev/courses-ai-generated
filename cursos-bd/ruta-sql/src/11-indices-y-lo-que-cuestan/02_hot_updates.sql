-- postgres
-- El flujo de correcciones: hasta 10.000 resultados de 2025, dispersos en la tabla, a los que se les cambia el
-- valor, en cuatro variantes de la misma tabla. Se cuenta cuántas actualizaciones fueron HOT (la versión nueva quedó en la
-- misma página y ningún índice se tocó). Se corre con psql: usa \gset.
DROP TABLE IF EXISTS staging.hot_result;
DROP TABLE IF EXISTS staging.hot_report;
CREATE TABLE staging.hot_report (variant text PRIMARY KEY, updates bigint, hot bigint, wal_bytes bigint);
\set variant '1. tres índices, fillfactor 100'
\set fillfactor 100
\set extra_index ''
\ir hot_round.sql
\set variant '2. tres índices, fillfactor 90'
\set fillfactor 90
\ir hot_round.sql
\set variant '3. cuarto índice sobre recorded_at, fillfactor 90'
\set extra_index 'CREATE INDEX hot_result_recorded_at_idx ON staging.hot_result (recorded_at);'
\ir hot_round.sql
\set variant '4. cuarto índice sobre value_numeric, fillfactor 90'
\set extra_index 'CREATE INDEX hot_result_value_numeric_idx ON staging.hot_result (value_numeric);'
\ir hot_round.sql
SELECT variant, updates, hot, round(100.0 * hot / updates) AS pct_hot, pg_size_pretty(wal_bytes) AS wal,
       round(wal_bytes / updates::numeric) AS wal_per_update
FROM staging.hot_report ORDER BY variant;
