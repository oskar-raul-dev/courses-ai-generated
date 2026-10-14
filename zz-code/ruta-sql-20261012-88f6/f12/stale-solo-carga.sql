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
\echo == ej10
EXPLAIN SELECT * FROM staging.result_2020 WHERE analyte_code = 'COVPCR';
EXPLAIN SELECT * FROM staging.result_2020 WHERE analyte_code = 'GLU';
SELECT analyte_code, count(*) FROM staging.result_2020 WHERE analyte_code IN ('COVPCR','GLU') GROUP BY 1;
SELECT most_common_vals::text::text[] @> ARRAY['COVPCR'] AS conoce_covpcr, n_distinct FROM pg_stats WHERE schemaname='staging' AND tablename='result_2020' AND attname='analyte_code';
ANALYZE staging.result_2020;
