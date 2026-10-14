\echo == parcial (glucemias sin calificador mayores que 250, 2024-2025)
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_recent WHERE analyte_code = 'GLU' AND qualifier IS NULL AND value_numeric > 250;
\echo == lo mismo sin el índice parcial
BEGIN; DROP INDEX staging.result_recent_glu_value_idx;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_recent WHERE analyte_code = 'GLU' AND qualifier IS NULL AND value_numeric > 250;
ROLLBACK;
\echo == de expresión, en el EAV (todas las épocas)
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_eav WHERE analyte_code = 'GLU'
  AND CASE WHEN value ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(value, ',', '.')::numeric END > 250;
\echo == la misma, escrita distinto: el índice no se usa
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.result_eav WHERE analyte_code = 'GLU'
  AND CASE WHEN value ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(value, ',', '.')::numeric(10,2) END > 250;
\echo == GIN con un apellido poco común
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.patient_clean WHERE norm_name LIKE '%BUSTOS%';
BEGIN; DROP INDEX staging.patient_clean_norm_name_trgm_idx;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.patient_clean WHERE norm_name LIKE '%BUSTOS%';
ROLLBACK;
SELECT count(*) FROM staging.patient_clean WHERE norm_name LIKE '%AGUERO%';
