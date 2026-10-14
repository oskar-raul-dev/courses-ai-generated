\pset pager off
PREPARE day_list(char, date, date) AS
SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id)
WHERE o.site_code = $1 AND o.ordered_on >= $2 AND o.ordered_on < $3 GROUP BY r.analyte_code;
EXECUTE day_list('V', '2026-09-01', '2026-09-02') \g /dev/null
EXECUTE day_list('A', '2026-09-02', '2026-09-03') \g /dev/null
EXECUTE day_list('R', '2026-09-03', '2026-09-04') \g /dev/null
EXECUTE day_list('J', '2026-09-04', '2026-09-05') \g /dev/null
EXECUTE day_list('V', '2026-09-07', '2026-09-08') \g /dev/null
SELECT generic_plans, custom_plans FROM pg_prepared_statements;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) EXECUTE day_list('C', '2026-01-01', '2026-10-01');
SELECT generic_plans, custom_plans FROM pg_prepared_statements;
SET plan_cache_mode = force_custom_plan;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) EXECUTE day_list('C', '2026-01-01', '2026-10-01');
