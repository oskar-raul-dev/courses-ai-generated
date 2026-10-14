\pset pager off
\set by_site 'SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id) WHERE o.site_code = $1 AND o.ordered_on >= ''2026-09-01'' GROUP BY r.analyte_code'
\echo == ej3
SET random_page_cost = 1.1;
EXPLAIN SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id) WHERE o.site_code = 'C' AND o.ordered_on >= '2026-09-01' GROUP BY r.analyte_code;
RESET random_page_cost;
\echo == ej8
SELECT reltuples::bigint FROM pg_class WHERE oid = 'staging.order_site'::regclass;
SELECT n_distinct, most_common_freqs FROM pg_stats WHERE schemaname='staging' AND tablename='order_site' AND attname='site_code';
EXPLAIN SELECT * FROM staging.order_site WHERE ordered_on >= '2026-09-01';
\echo == ej9
EXPLAIN (ANALYZE, SUMMARY ON, TIMING OFF, COSTS OFF) SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id) WHERE o.site_code = 'V' AND o.ordered_on >= '2026-09-01' GROUP BY r.analyte_code;
\echo == ej10
SET plan_cache_mode = force_custom_plan;
PREPARE by_site(char) AS :by_site;
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) EXECUTE by_site('V');
SELECT generic_plans, custom_plans FROM pg_prepared_statements WHERE name='by_site';
DEALLOCATE by_site; RESET plan_cache_mode;
\echo == ej12
SET random_page_cost = 1.1;
PREPARE by_site(char) AS :by_site;
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXECUTE by_site('C') \g /dev/null
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) EXECUTE by_site('V');
SELECT generic_plans, custom_plans FROM pg_prepared_statements WHERE name='by_site';
DEALLOCATE by_site; RESET random_page_cost;
\echo == ej18
PREPARE by_month(char, date) AS SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id) WHERE o.site_code = $1 AND o.ordered_on >= $2 AND o.ordered_on < $2 + 31 GROUP BY r.analyte_code;
EXECUTE by_month('C','2025-01-01') \g /dev/null
EXECUTE by_month('C','2025-02-01') \g /dev/null
EXECUTE by_month('C','2025-03-01') \g /dev/null
EXECUTE by_month('C','2025-04-01') \g /dev/null
EXECUTE by_month('C','2025-05-01') \g /dev/null
EXECUTE by_month('C','2025-06-01') \g /dev/null
EXECUTE by_month('C','2025-07-01') \g /dev/null
EXECUTE by_month('C','2025-08-01') \g /dev/null
EXECUTE by_month('C','2025-09-01') \g /dev/null
EXECUTE by_month('C','2025-10-01') \g /dev/null
EXECUTE by_month('C','2025-11-01') \g /dev/null
EXPLAIN (COSTS OFF) EXECUTE by_month('C','2025-12-01');
SELECT generic_plans, custom_plans FROM pg_prepared_statements WHERE name='by_month';
SET plan_cache_mode = force_generic_plan;
EXPLAIN EXECUTE by_month('C','2025-12-01');
RESET plan_cache_mode;
SET plan_cache_mode = force_custom_plan;
EXPLAIN EXECUTE by_month('C','2025-12-01');
RESET plan_cache_mode;
DEALLOCATE by_month;
\echo == ej19
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) SELECT lab_order_id, ordered_on FROM staging.order_site WHERE site_code = 'E' ORDER BY ordered_on DESC LIMIT 50;
BEGIN;
DROP INDEX staging.order_site_site_ordered_idx;
CREATE INDEX order_site_ordered_idx ON staging.order_site (ordered_on);
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) SELECT lab_order_id, ordered_on FROM staging.order_site WHERE site_code = 'E' ORDER BY ordered_on DESC LIMIT 50;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) SELECT lab_order_id, ordered_on FROM staging.order_site WHERE site_code = 'V' ORDER BY ordered_on DESC LIMIT 50;
ROLLBACK;
