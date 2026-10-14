\pset pager off
PREPARE by_site(char) AS
SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id)
WHERE o.site_code = $1 AND o.ordered_on >= '2026-09-01' GROUP BY r.analyte_code;
SET plan_cache_mode = force_generic_plan;
EXPLAIN EXECUTE by_site('V');
RESET plan_cache_mode;
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
SELECT generic_plans, custom_plans FROM pg_prepared_statements;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) EXECUTE by_site('V');
SELECT generic_plans, custom_plans FROM pg_prepared_statements;
