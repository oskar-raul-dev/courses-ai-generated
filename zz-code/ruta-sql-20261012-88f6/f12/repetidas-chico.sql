\pset pager off
\set q 'SELECT count(DISTINCT oa.patient_id) FROM staging.result_2020 a JOIN alameda.lab_order oa ON oa.lab_order_id = a.lab_order_id JOIN alameda.lab_order ob ON ob.patient_id = oa.patient_id JOIN staging.result_2020 b ON b.lab_order_id = ob.lab_order_id WHERE a.analyte_code = ''COVPCR'' AND b.analyte_code = ''COVPCR'' AND b.recorded_at > a.recorded_at AND b.recorded_at < a.recorded_at + interval ''14 days'''
SET statement_timeout = '1800s';
\echo == estadísticas de febrero
\timing on
:q;
\timing off
ANALYZE staging.result_2020;
\echo == después del ANALYZE
\timing on
:q;
:q;
