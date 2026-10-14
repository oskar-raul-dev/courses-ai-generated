\pset pager off
DROP TABLE IF EXISTS staging.ministry_notice;
-- la planilla de casos notificados al ministerio, importada tal cual: sin clave, sin índice
CREATE TABLE staging.ministry_notice AS
SELECT r.lab_order_id, (r.recorded_at + interval '1 day')::date AS notified_on
FROM alameda.result r
WHERE r.analyte_code = 'COVPCR' AND r.value_text = 'DETECTABLE' AND r.recorded_at < '2022-01-01' AND r.result_id % 10 <> 0;
ANALYZE staging.ministry_notice;
SELECT count(*) FROM staging.ministry_notice;
SET statement_timeout = '120s';
\echo == positivos sin notificar, estadísticas de febrero
EXPLAIN SELECT count(*) FROM staging.result_2020 r JOIN alameda.lab_order o USING (lab_order_id)
WHERE r.analyte_code = 'COVPCR' AND r.value_text = 'DETECTABLE'
AND NOT EXISTS (SELECT 1 FROM staging.ministry_notice n WHERE n.lab_order_id = r.lab_order_id);
\timing on
SELECT count(*) FROM staging.result_2020 r JOIN alameda.lab_order o USING (lab_order_id)
WHERE r.analyte_code = 'COVPCR' AND r.value_text = 'DETECTABLE'
AND NOT EXISTS (SELECT 1 FROM staging.ministry_notice n WHERE n.lab_order_id = r.lab_order_id);
