\pset pager off
\echo == F10 Postgres
SELECT c.relname, pg_size_pretty(pg_relation_size(c.oid)) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='staging' AND c.relkind='i' AND c.relname ~ '^order_(bigint|uuid4|uuid7)' ORDER BY 1;
SELECT max(lab_order_id), 2147483647 - max(lab_order_id) AS al_techo FROM alameda.lab_order;
\echo == F11 compuesto
BEGIN;
DROP INDEX staging.result_recent_recorded_at_analyte_code_idx;
DROP INDEX staging.result_recent_recorded_at_brin;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_recent WHERE analyte_code = 'GLU' AND recorded_at >= '2024-10-01' AND recorded_at < '2024-11-01';
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_recent WHERE recorded_at >= '2024-10-15' AND recorded_at < '2024-10-16';
ROLLBACK;
BEGIN;
DROP INDEX staging.result_recent_analyte_code_recorded_at_idx;
DROP INDEX staging.result_recent_recorded_at_brin;
DROP INDEX staging.result_recent_glu_value_idx;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_recent WHERE analyte_code = 'GLU' AND recorded_at >= '2024-10-01' AND recorded_at < '2024-11-01';
ROLLBACK;
\echo == F11 tamaños
SELECT c.relname, pg_size_pretty(pg_relation_size(c.oid)) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='staging' AND c.relname LIKE 'result_recent%' ORDER BY 1;
\echo == F11 parcial
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_recent WHERE analyte_code = 'GLU' AND qualifier IS NULL AND value_numeric > 250;
BEGIN; DROP INDEX staging.result_recent_glu_value_idx;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_recent WHERE analyte_code = 'GLU' AND qualifier IS NULL AND value_numeric > 250;
ROLLBACK;
\echo == F11 expresión
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_eav WHERE analyte_code = 'GLU'
  AND CASE WHEN value ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(value, ',', '.')::numeric END > 250;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_eav WHERE analyte_code = 'GLU'
  AND CASE WHEN value ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(value, ',', '.')::numeric(10,2) END > 250;
\echo == F11 BRIN
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_recent WHERE recorded_at >= '2024-10-15' AND recorded_at < '2024-10-16';
BEGIN;
DROP INDEX IF EXISTS staging.result_as_is_recorded_at_idx;
CREATE INDEX result_as_is_recorded_at_brin ON staging.result_as_is USING brin (recorded_at);
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_as_is WHERE recorded_at >= '2024-10-15' AND recorded_at < '2024-10-16';
ROLLBACK;
\echo == F11 GIN
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.patient_clean WHERE norm_name LIKE '%SOSA GUTIERREZ%';
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.patient_clean WHERE norm_name LIKE '%BUSTOS%';
\echo == F11 index-only
VACUUM staging.result_recent;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT analyte_code, value_numeric FROM staging.result_recent WHERE lab_order_id BETWEEN 10800000 AND 10801000;
UPDATE staging.result_recent SET recorded_at = recorded_at WHERE lab_order_id BETWEEN 10800000 AND 10800500;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT analyte_code, value_numeric FROM staging.result_recent WHERE lab_order_id BETWEEN 10800000 AND 10801000;
VACUUM staging.result_recent;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT analyte_code, value_numeric FROM staging.result_recent WHERE lab_order_id BETWEEN 10800000 AND 10801000;
