\echo == compuesto: (analyte_code, recorded_at)
BEGIN;
DROP INDEX staging.result_recent_recorded_at_analyte_code_idx;
DROP INDEX staging.result_recent_recorded_at_brin;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_recent WHERE analyte_code = 'GLU' AND recorded_at >= '2024-10-01' AND recorded_at < '2024-11-01';
\echo == skip scan: solo la fecha, con (analyte_code, recorded_at)
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_recent WHERE recorded_at >= '2024-10-15' AND recorded_at < '2024-10-16';
ROLLBACK;
\echo == compuesto: (recorded_at, analyte_code)
BEGIN;
DROP INDEX staging.result_recent_analyte_code_recorded_at_idx;
DROP INDEX staging.result_recent_recorded_at_brin;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_recent WHERE analyte_code = 'GLU' AND recorded_at >= '2024-10-01' AND recorded_at < '2024-11-01';
ROLLBACK;
\echo == BRIN, en la tabla ordenada
BEGIN;
DROP INDEX staging.result_recent_analyte_code_recorded_at_idx;
DROP INDEX staging.result_recent_recorded_at_analyte_code_idx;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_recent WHERE recorded_at >= '2024-10-15' AND recorded_at < '2024-10-16';
ROLLBACK;
\echo == BRIN, en la tabla como se cargó
CREATE INDEX IF NOT EXISTS result_as_is_recorded_at_brin ON staging.result_as_is USING brin (recorded_at);
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_as_is WHERE recorded_at >= '2024-10-15' AND recorded_at < '2024-10-16';
SELECT attname, correlation FROM pg_stats WHERE schemaname = 'staging' AND tablename IN ('result_recent','result_as_is') AND attname = 'recorded_at';
\echo == parcial
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_recent WHERE analyte_code = 'GLU' AND value_numeric > 400;
\echo == de expresión, en el EAV
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_eav WHERE analyte_code = 'GLU'
  AND CASE WHEN value ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(value, ',', '.')::numeric END > 400;
\echo == INCLUDE e index-only scan, recién hecho el VACUUM
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT analyte_code, value_numeric FROM staging.result_recent WHERE lab_order_id BETWEEN 10800000 AND 10801000;
UPDATE staging.result_recent SET recorded_at = recorded_at WHERE lab_order_id BETWEEN 10800000 AND 10800500;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT analyte_code, value_numeric FROM staging.result_recent WHERE lab_order_id BETWEEN 10800000 AND 10801000;
VACUUM staging.result_recent;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT analyte_code, value_numeric FROM staging.result_recent WHERE lab_order_id BETWEEN 10800000 AND 10801000;
\echo == GIN con trigramas
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.patient_clean WHERE norm_name LIKE '%AGUERO%';
BEGIN; DROP INDEX staging.patient_clean_norm_name_trgm_idx;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.patient_clean WHERE norm_name LIKE '%AGUERO%';
ROLLBACK;
