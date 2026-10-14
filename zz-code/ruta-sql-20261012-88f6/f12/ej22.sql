\pset pager off
\echo == la estimación de la Fase 08, sobre result
EXPLAIN SELECT count(*) FROM alameda.result WHERE analyte_code = 'GLU' AND value_numeric > 126;
SELECT count(*) FROM alameda.result WHERE analyte_code = 'GLU' AND value_numeric > 126;
\echo == particionado por determinación
DROP TABLE IF EXISTS staging.result_by_analyte;
CREATE TABLE staging.result_by_analyte (LIKE alameda.result) PARTITION BY LIST (analyte_code);
CREATE TABLE staging.result_by_analyte_glu PARTITION OF staging.result_by_analyte FOR VALUES IN ('GLU');
CREATE TABLE staging.result_by_analyte_rest PARTITION OF staging.result_by_analyte DEFAULT;
INSERT INTO staging.result_by_analyte SELECT * FROM alameda.result;
ANALYZE staging.result_by_analyte;
EXPLAIN SELECT count(*) FROM staging.result_by_analyte WHERE analyte_code = 'GLU' AND value_numeric > 126;
\echo == estadísticas sobre una expresión
CREATE STATISTICS staging.result_as_is_glu_value_stat ON ((CASE WHEN analyte_code = 'GLU' THEN value_numeric END)) FROM staging.result_as_is;
ANALYZE staging.result_as_is;
EXPLAIN SELECT count(*) FROM staging.result_as_is WHERE (CASE WHEN analyte_code = 'GLU' THEN value_numeric END) > 126;
EXPLAIN SELECT count(*) FROM staging.result_as_is WHERE analyte_code = 'GLU' AND value_numeric > 126;
SELECT count(*) FROM staging.result_as_is WHERE analyte_code = 'GLU' AND value_numeric > 126;
DROP STATISTICS staging.result_as_is_glu_value_stat;
