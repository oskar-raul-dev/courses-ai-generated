\set q 'EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_recent WHERE recorded_at >= ''2024-10-15'' AND recorded_at < ''2024-10-16'''
BEGIN;
DROP INDEX staging.result_recent_recorded_at_analyte_code_idx;
DROP INDEX staging.result_recent_analyte_code_recorded_at_idx;
\echo == recién creada
:q;
ROLLBACK;
SELECT min(recorded_at), max(recorded_at) FROM staging.result_recent WHERE lab_order_id BETWEEN 10800000 AND 10800500;
UPDATE staging.result_recent SET recorded_at = recorded_at WHERE lab_order_id BETWEEN 10800000 AND 10800500;
VACUUM staging.result_recent;
BEGIN;
DROP INDEX staging.result_recent_recorded_at_analyte_code_idx;
DROP INDEX staging.result_recent_analyte_code_recorded_at_idx;
\echo == después del UPDATE del ejercicio 8 y el VACUUM
:q;
ROLLBACK;
