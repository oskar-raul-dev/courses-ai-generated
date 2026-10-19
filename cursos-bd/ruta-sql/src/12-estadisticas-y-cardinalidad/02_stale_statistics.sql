-- postgres
-- El informe de la pandemia y el ANALYZE que nadie programó. Una copia de result con enero y febrero de 2020,
-- analizada, con el autovacuum apagado para la tabla (lo apagaron "mientras dure la carga" y nadie lo volvió a
-- prender). Después llegan marzo de 2020 a diciembre de 2021, con el PCR de COVID que el 20 de marzo no
-- existía. Las estadísticas no conocen 'COVPCR': para el optimizador, ese analito no tiene filas.
-- Se corre con psql; la primera ejecución del informe se corta a los cinco minutos.
DROP TABLE IF EXISTS staging.result_2020;
CREATE TABLE staging.result_2020 (LIKE alameda.result) WITH (autovacuum_enabled = false);
INSERT INTO staging.result_2020 SELECT * FROM alameda.result
WHERE recorded_at >= '2020-01-01' AND recorded_at < '2020-03-01' ORDER BY recorded_at;
CREATE INDEX result_2020_analyte_recorded_idx ON staging.result_2020 (analyte_code, recorded_at);
CREATE INDEX result_2020_lab_order_id_idx ON staging.result_2020 (lab_order_id);
ANALYZE staging.result_2020;
-- llegan dos años de pandemia, y nadie corre ANALYZE
INSERT INTO staging.result_2020 SELECT * FROM alameda.result
WHERE recorded_at >= '2020-03-01' AND recorded_at < '2022-01-01' ORDER BY recorded_at;

-- el informe simple: PCR y positivos por sede
\set simple 'SELECT o.site_code, count(*) AS tests, count(*) FILTER (WHERE r.value_text = ''DETECTABLE'') AS positives FROM staging.result_2020 r JOIN alameda.lab_order o USING (lab_order_id) JOIN alameda.patient p USING (patient_id) WHERE r.analyte_code = ''COVPCR'' GROUP BY o.site_code'
-- el informe de las repetidas: pacientes con una PCR repetida dentro de los 14 días
\set report 'SELECT count(DISTINCT oa.patient_id) FROM staging.result_2020 a JOIN alameda.lab_order oa ON oa.lab_order_id = a.lab_order_id JOIN alameda.lab_order ob ON ob.patient_id = oa.patient_id JOIN staging.result_2020 b ON b.lab_order_id = ob.lab_order_id WHERE a.analyte_code = ''COVPCR'' AND b.analyte_code = ''COVPCR'' AND b.recorded_at > a.recorded_at AND b.recorded_at < a.recorded_at + interval ''14 days'''

\echo == con las estadísticas de febrero
EXPLAIN :simple;
\timing on
:simple \g /dev/null
:simple \g /dev/null
:simple \g /dev/null
:simple \g /dev/null
:simple \g /dev/null
\timing off
EXPLAIN :report;
SET statement_timeout = '300s';
\timing on
:report;
\timing off
RESET statement_timeout;

ANALYZE staging.result_2020;
\echo == después del ANALYZE
EXPLAIN :simple;
\timing on
:simple \g /dev/null
:simple \g /dev/null
:simple \g /dev/null
:simple \g /dev/null
:simple \g /dev/null
\timing off
EXPLAIN :report;
\timing on
:report;
:report;
\timing off
