\pset pager off
PREPARE by_month(char, date) AS SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id) WHERE o.site_code = $1 AND o.ordered_on >= $2 AND o.ordered_on < $2 + 31 GROUP BY r.analyte_code;
\timing on
SET plan_cache_mode = force_generic_plan;
EXECUTE by_month('C','2025-12-01') \g /dev/null
EXECUTE by_month('C','2025-12-01') \g /dev/null
EXECUTE by_month('C','2025-12-01') \g /dev/null
EXECUTE by_month('C','2025-12-01') \g /dev/null
SET plan_cache_mode = force_custom_plan;
EXECUTE by_month('C','2025-12-01') \g /dev/null
EXECUTE by_month('C','2025-12-01') \g /dev/null
EXECUTE by_month('C','2025-12-01') \g /dev/null
EXECUTE by_month('C','2025-12-01') \g /dev/null
