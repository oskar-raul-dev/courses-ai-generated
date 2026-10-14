-- La hypertable de la Fase 10 tal como se usaría: comprimida por antigüedad (perfil series, base condor).
--   docker compose -f lab/compose.yaml exec -T series psql -U postgres -d condor < 10-series-romper-y-medir/compress.sql
\timing on
ALTER TABLE reading_x10 SET (timescaledb.compress,
    timescaledb.compress_segmentby = 'aircraft', timescaledb.compress_orderby = 'ts');
SELECT add_compression_policy('reading_x10', INTERVAL '90 days', if_not_exists => true);
-- lo anterior a 2026, a mano; la política haría lo mismo con el tiempo
SELECT count(compress_chunk(c, true)) FROM show_chunks('reading_x10', older_than => TIMESTAMP '2026-01-01') c;
VACUUM ANALYZE reading_x10;
SELECT pg_size_pretty(hypertable_size('reading_x10')) AS hypertable;
