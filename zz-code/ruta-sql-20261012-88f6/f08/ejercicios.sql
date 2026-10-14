\echo == ej15 índice en el tipado
CREATE INDEX result_analyte_code_value_numeric_idx ON alameda.result (analyte_code, value_numeric);
ANALYZE alameda.result;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, SUMMARY ON)
WITH o AS (SELECT lab_order_id, patient_id FROM alameda.lab_order WHERE ordered_on >= '2024-01-01' AND ordered_on < '2025-01-01'),
     d AS (SELECT DISTINCT o.patient_id FROM o JOIN alameda.result AS r USING (lab_order_id)
           WHERE r.analyte_code = 'HBA1C' AND r.qualifier IS NULL AND r.value_numeric > 6.5)
SELECT count(*) FROM o JOIN d USING (patient_id) JOIN alameda.result AS r USING (lab_order_id)
WHERE r.analyte_code = 'GLU' AND r.qualifier IS NULL AND r.value_numeric > 126;
DROP INDEX alameda.result_analyte_code_value_numeric_idx;
\echo == ej16 estadísticas extendidas
CREATE STATISTICS result_analyte_code_value_numeric_stat (mcv, dependencies) ON analyte_code, value_numeric FROM alameda.result;
ANALYZE alameda.result;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, SUMMARY ON)
WITH o AS (SELECT lab_order_id, patient_id FROM alameda.lab_order WHERE ordered_on >= '2024-01-01' AND ordered_on < '2025-01-01'),
     d AS (SELECT DISTINCT o.patient_id FROM o JOIN alameda.result AS r USING (lab_order_id)
           WHERE r.analyte_code = 'HBA1C' AND r.qualifier IS NULL AND r.value_numeric > 6.5)
SELECT count(*) FROM o JOIN d USING (patient_id) JOIN alameda.result AS r USING (lab_order_id)
WHERE r.analyte_code = 'GLU' AND r.qualifier IS NULL AND r.value_numeric > 126;
DROP STATISTICS alameda.result_analyte_code_value_numeric_stat;
ANALYZE alameda.result;
\echo == ej18 el CHECK del valor
BEGIN;
INSERT INTO alameda.result VALUES (-1, 10197772, 'GLU', 126, NULL, NULL, 'HEMOLIZADA', now());
ROLLBACK;
BEGIN;
INSERT INTO alameda.result VALUES (-1, 10197772, 'GLU', NULL, '<', NULL, NULL, now());
ROLLBACK;
\echo == ej19 las tablas anchas al tipado
SELECT count(*) valores, count(*) FILTER (WHERE "Glucemia" ~ '^\s*[<>]?\s*[0-9]+([.,][0-9]+)?\s*$') numericos,
       count(*) FILTER (WHERE "Glucemia" !~ '^\s*[<>]?\s*[0-9]+([.,][0-9]+)?\s*$') no_numericos FROM legacy."Quimica" WHERE "Glucemia" IS NOT NULL;
SELECT "Glucemia", count(*) FROM legacy."Quimica" WHERE "Glucemia" !~ '^\s*[<>]?\s*[0-9]+([.,][0-9]+)?\s*$' GROUP BY 1 ORDER BY 2 DESC;
\echo == ej20 jsonb con GIN
CREATE INDEX result_document_results_idx ON staging.result_document USING gin (results jsonb_path_ops);
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF)
SELECT count(*) FROM staging.result_document WHERE results @? '$.glu ? (@ > 126)';
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF)
SELECT count(*) FROM staging.result_document WHERE results @> '{"glu": 126}';
DROP INDEX staging.result_document_results_idx;
\echo == ej23 con los calificados
WITH o AS (SELECT lab_order_id, patient_id FROM alameda.lab_order WHERE ordered_on >= '2024-01-01' AND ordered_on < '2025-01-01'),
     d AS (SELECT DISTINCT o.patient_id FROM o JOIN alameda.result AS r USING (lab_order_id)
           WHERE r.analyte_code = 'HBA1C' AND (r.qualifier IS NULL AND r.value_numeric > 6.5 OR r.qualifier = '>' AND r.value_numeric >= 6.5))
SELECT count(*) FROM o JOIN d USING (patient_id) JOIN alameda.result AS r USING (lab_order_id)
WHERE r.analyte_code = 'GLU' AND (r.qualifier IS NULL AND r.value_numeric > 126 OR r.qualifier = '>' AND r.value_numeric >= 126);
\echo == ej2
SELECT state, count(*) FROM truth.result_value GROUP BY 1 ORDER BY 2 DESC;
