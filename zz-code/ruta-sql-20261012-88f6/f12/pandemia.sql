\pset pager off
\set q 'SELECT o.site_code, count(*) AS tests, count(*) FILTER (WHERE r.value_text = ''DETECTABLE'') AS positives FROM staging.result_2020 r JOIN alameda.lab_order o USING (lab_order_id) JOIN alameda.patient p USING (patient_id) WHERE r.analyte_code = ''COVPCR'' GROUP BY o.site_code'
\echo == con las estadísticas de febrero (dos corridas)
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) :q;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) :q;
ANALYZE staging.result_2020;
\echo == después del ANALYZE (dos corridas)
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) :q;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) :q;
