\echo == el informe de septiembre, con las estadísticas de agosto
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT o.site_code, count(*), avg(r.value_numeric)
FROM staging.result_month r JOIN alameda.lab_order o USING (lab_order_id)
WHERE r.recorded_at >= '2026-09-01' AND r.recorded_at < '2026-10-01' AND r.analyte_code = 'GLU'
GROUP BY o.site_code;
ANALYZE staging.result_month;
\echo == después del ANALYZE
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF)
SELECT o.site_code, count(*), avg(r.value_numeric)
FROM staging.result_month r JOIN alameda.lab_order o USING (lab_order_id)
WHERE r.recorded_at >= '2026-09-01' AND r.recorded_at < '2026-10-01' AND r.analyte_code = 'GLU'
GROUP BY o.site_code;
