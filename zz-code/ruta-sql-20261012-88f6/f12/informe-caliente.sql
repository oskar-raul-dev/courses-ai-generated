\pset pager off
-- recrea el estado viejo: borra estadísticas no se puede; se fuerza con la tabla rehecha
\o /dev/null
SELECT count(*) FROM alameda.lab_order;
\o
\echo == después del ANALYZE, caché caliente (3 corridas)
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT o.site_code, count(*), avg(r.value_numeric)
FROM staging.result_month r JOIN alameda.lab_order o USING (lab_order_id)
WHERE r.recorded_at >= '2026-09-01' AND r.recorded_at < '2026-10-01' AND r.analyte_code = 'GLU'
GROUP BY o.site_code;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT o.site_code, count(*), avg(r.value_numeric)
FROM staging.result_month r JOIN alameda.lab_order o USING (lab_order_id)
WHERE r.recorded_at >= '2026-09-01' AND r.recorded_at < '2026-10-01' AND r.analyte_code = 'GLU'
GROUP BY o.site_code;
\echo == forzando el nested loop con estadísticas al día
SET enable_hashjoin = off; SET enable_mergejoin = off;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT o.site_code, count(*), avg(r.value_numeric)
FROM staging.result_month r JOIN alameda.lab_order o USING (lab_order_id)
WHERE r.recorded_at >= '2026-09-01' AND r.recorded_at < '2026-10-01' AND r.analyte_code = 'GLU'
GROUP BY o.site_code;
\echo == informe trimestral jul-sep (más filas)
RESET enable_hashjoin; RESET enable_mergejoin;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT o.site_code, count(*), avg(r.value_numeric)
FROM staging.result_month r JOIN alameda.lab_order o USING (lab_order_id)
WHERE r.recorded_at >= '2026-07-01' AND r.recorded_at < '2026-10-01'
GROUP BY o.site_code;
