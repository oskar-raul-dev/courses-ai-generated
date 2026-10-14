\echo == tipado
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) SELECT r.analyte_code, r.value_numeric, r.qualifier, r.value_text, r.sample_flag, a.unit, a.reference_range
FROM alameda.result r JOIN alameda.analyte a USING (analyte_code) WHERE r.lab_order_id = 11232670;
\echo == eav
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) SELECT analyte_code, value, unit, reference_range FROM staging.result_eav WHERE lab_order_id = 11232670;
\echo == ancha
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) SELECT * FROM staging.result_wide WHERE lab_order_id = 11232670;
\echo == jsonb
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) SELECT results FROM staging.result_document WHERE lab_order_id = 11232670;
SELECT results FROM staging.result_document WHERE lab_order_id = 11232670;
