\pset pager off
\set q 'SELECT o.site_code, count(*) AS tests, count(*) FILTER (WHERE r.value_text = ''DETECTABLE'') AS positives FROM staging.result_2020 r JOIN alameda.lab_order o USING (lab_order_id) JOIN alameda.patient p USING (patient_id) WHERE r.analyte_code = ''COVPCR'' GROUP BY o.site_code'
\timing on
\o /dev/null
:q;
\o
\echo == estadísticas de febrero
:q
\g /dev/null
:q
\g /dev/null
:q
\g /dev/null
:q
\g /dev/null
:q
\g /dev/null
\echo == resultado
:q;
ANALYZE staging.result_2020;
\echo == después del ANALYZE
:q
\g /dev/null
:q
\g /dev/null
:q
\g /dev/null
:q
\g /dev/null
:q
\g /dev/null
