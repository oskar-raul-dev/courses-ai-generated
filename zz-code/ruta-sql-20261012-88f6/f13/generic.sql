\pset pager off
PREPARE by_site(char, date) AS
SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id)
WHERE o.site_code = $1 AND o.ordered_on >= $2 GROUP BY r.analyte_code;
SET plan_cache_mode = force_generic_plan;
EXPLAIN EXECUTE by_site('V', '2026-09-01');
SET plan_cache_mode = force_custom_plan;
EXPLAIN EXECUTE by_site('V', '2026-09-01');
EXPLAIN EXECUTE by_site('V', '2026-10-01');
EXPLAIN EXECUTE by_site('C', '2026-09-01');
