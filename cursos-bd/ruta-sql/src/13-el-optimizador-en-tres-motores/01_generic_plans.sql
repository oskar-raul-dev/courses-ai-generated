-- postgres
-- Planes genéricos y personalizados. La consulta por sede de los resultados de septiembre, preparada con la sede
-- como parámetro, en dos sesiones: una que empieza el día con los centros chicos y otra que lo empieza con el
-- laboratorio central. Después de cinco ejecuciones, Postgres compara el costo del plan genérico con el promedio
-- de los personalizados, y se queda con el genérico si no es más caro. Se corre con psql.
DROP TABLE IF EXISTS staging.order_site;
CREATE TABLE staging.order_site AS SELECT * FROM alameda.lab_order;
ALTER TABLE staging.order_site ADD PRIMARY KEY (lab_order_id);
CREATE INDEX order_site_site_ordered_idx ON staging.order_site (site_code, ordered_on);
ANALYZE staging.order_site;

\set by_site 'SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id) WHERE o.site_code = $1 AND o.ordered_on >= ''2026-09-01'' GROUP BY r.analyte_code'

\echo == 1. el día empieza en los centros chicos
PREPARE by_site(char) AS :by_site;
EXECUTE by_site('V') \g /dev/null
EXECUTE by_site('A') \g /dev/null
EXECUTE by_site('R') \g /dev/null
EXECUTE by_site('J') \g /dev/null
EXECUTE by_site('V') \g /dev/null
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) EXECUTE by_site('C');
SELECT generic_plans, custom_plans FROM pg_prepared_statements WHERE name = 'by_site';
DEALLOCATE by_site;

\echo == 2. el día empieza en el central
PREPARE by_site(char) AS :by_site;
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) EXECUTE by_site('V');
SELECT generic_plans, custom_plans FROM pg_prepared_statements WHERE name = 'by_site';
DEALLOCATE by_site;

\echo == 3. el centro V con cada plan, caché caliente
PREPARE by_site(char) AS :by_site;
SET plan_cache_mode = force_custom_plan;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) EXECUTE by_site('V');
\timing on
EXECUTE by_site('V') \g /dev/null
EXECUTE by_site('V') \g /dev/null
EXECUTE by_site('V') \g /dev/null
EXECUTE by_site('V') \g /dev/null
EXECUTE by_site('V') \g /dev/null
\timing off
SET plan_cache_mode = force_generic_plan;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) EXECUTE by_site('V');
\timing on
EXECUTE by_site('V') \g /dev/null
EXECUTE by_site('V') \g /dev/null
EXECUTE by_site('V') \g /dev/null
EXECUTE by_site('V') \g /dev/null
EXECUTE by_site('V') \g /dev/null
\timing off
RESET plan_cache_mode;
DEALLOCATE by_site;
