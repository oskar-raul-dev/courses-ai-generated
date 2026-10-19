-- postgres · ss03 ej19: plan_cache_mode fijado para el rol del reporte, con la sesión que empieza en el central.
\set by_site 'SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id) WHERE o.site_code = $1 AND o.ordered_on >= ''2026-09-01'' GROUP BY r.analyte_code'
SELECT current_user, current_setting('plan_cache_mode') AS plan_cache_mode;
PREPARE by_site(char) AS :by_site;
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) EXECUTE by_site('V');
SELECT generic_plans, custom_plans FROM pg_prepared_statements WHERE name = 'by_site';
