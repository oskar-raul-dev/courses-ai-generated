-- postgres
-- Dos maneras de engañar al estimador sin tocar el motor. La primera: el valor en texto de la tabla EAV de la
-- Fase 08, cuyo histograma está en orden alfabético. La segunda: dos columnas que dicen lo mismo (la sede y el
-- prefijo del número de protocolo), que el estimador multiplica como si fueran independientes. Se corre con psql
-- después de lab load --profile m --model.

-- 1. El histograma de un texto que guarda números
SELECT n_distinct, histogram_bounds::text::text[] AS bounds
FROM pg_stats WHERE schemaname = 'staging' AND tablename = 'result_eav' AND attname = 'value' \gx
SELECT count(*) AS mayor_que_126_como_texto
FROM staging.result_eav WHERE analyte_code = 'GLU' AND value > '126';
SELECT count(*) FILTER (WHERE value_numeric > 126) AS mayor_que_126_como_numero
FROM alameda.result WHERE analyte_code = 'GLU';

-- 2. La sede y el prefijo: una copia de Protocolos con las dos columnas tal como vienen del sistema viejo
DROP TABLE IF EXISTS staging.protocol_stats;
CREATE TABLE staging.protocol_stats AS
SELECT "IdProtocolo" AS lab_order_id, "Sede" AS site_code, "NroProtocolo" AS visible_number,
       "Fecha"::date AS ordered_on
FROM legacy."Protocolos";
ALTER TABLE staging.protocol_stats ADD PRIMARY KEY (lab_order_id);
ANALYZE staging.protocol_stats;

SELECT site_code, left(visible_number, 2) AS prefix, count(*)
FROM staging.protocol_stats GROUP BY 1, 2 ORDER BY 3 DESC LIMIT 8;

\echo == sin estadísticas extendidas
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT count(*) FROM staging.protocol_stats WHERE site_code = 'E' AND left(visible_number, 2) = 'E-';
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT r.analyte_code, count(*)
FROM staging.protocol_stats s JOIN staging.result_eav r USING (lab_order_id)
WHERE s.site_code = 'E' AND left(s.visible_number, 2) = 'E-' GROUP BY r.analyte_code;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT r.analyte_code, count(*)
FROM staging.protocol_stats s JOIN staging.result_as_is r USING (lab_order_id)
WHERE s.site_code = 'E' AND left(s.visible_number, 2) = 'E-' GROUP BY r.analyte_code;

CREATE STATISTICS staging.protocol_stats_site_prefix_stat (dependencies, mcv)
ON site_code, (left(visible_number, 2)) FROM staging.protocol_stats;
ANALYZE staging.protocol_stats;

\echo == con estadísticas extendidas
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT count(*) FROM staging.protocol_stats WHERE site_code = 'E' AND left(visible_number, 2) = 'E-';
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT r.analyte_code, count(*)
FROM staging.protocol_stats s JOIN staging.result_eav r USING (lab_order_id)
WHERE s.site_code = 'E' AND left(s.visible_number, 2) = 'E-' GROUP BY r.analyte_code;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT r.analyte_code, count(*)
FROM staging.protocol_stats s JOIN staging.result_as_is r USING (lab_order_id)
WHERE s.site_code = 'E' AND left(s.visible_number, 2) = 'E-' GROUP BY r.analyte_code;

-- 3. Dos comparaciones sobre la misma columna: Postgres las junta en un rango
EXPLAIN SELECT count(*) FROM staging.protocol_stats WHERE ordered_on >= '2015-03-10' AND ordered_on < '2015-03-11';
SELECT count(*) FROM staging.protocol_stats WHERE ordered_on >= '2015-03-10' AND ordered_on < '2015-03-11';
