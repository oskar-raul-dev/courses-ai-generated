\pset pager off
DROP TABLE IF EXISTS staging.order_site;
CREATE TABLE staging.order_site AS SELECT * FROM alameda.lab_order;
ALTER TABLE staging.order_site ADD PRIMARY KEY (lab_order_id);
CREATE INDEX order_site_site_ordered_idx ON staging.order_site (site_code, ordered_on);
ANALYZE staging.order_site;
PREPARE by_site(char) AS
SELECT r.analyte_code, count(*) FROM staging.order_site o JOIN alameda.result r USING (lab_order_id)
WHERE o.site_code = $1 AND o.ordered_on >= '2026-09-01' GROUP BY r.analyte_code;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, SUMMARY ON) EXECUTE by_site('V');
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) EXECUTE by_site('C');
EXECUTE by_site('V') \g /dev/null
EXECUTE by_site('V') \g /dev/null
EXECUTE by_site('V') \g /dev/null
EXECUTE by_site('V') \g /dev/null
SELECT name, generic_plans, custom_plans FROM pg_prepared_statements;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) EXECUTE by_site('C');
SELECT name, generic_plans, custom_plans FROM pg_prepared_statements;
