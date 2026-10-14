\pset pager off
CREATE TEMP TABLE choice (run int, est_filter bigint, est_join bigint, node text);
DO $$
DECLARE p jsonb;
BEGIN
  FOR i IN 1..10 LOOP
    ANALYZE staging.protocol_stats;
    EXECUTE $q$EXPLAIN (FORMAT JSON) SELECT r.analyte_code, count(*) FROM staging.protocol_stats s JOIN staging.result_eav r USING (lab_order_id) WHERE s.site_code = 'E' AND left(s.visible_number, 2) = 'E-' GROUP BY r.analyte_code$q$ INTO p;
    INSERT INTO choice VALUES (i,
      (jsonb_path_query_first(p, '$[0].Plan.** ? (@."Relation Name" == "protocol_stats")."Plan Rows"') #>> '{}')::numeric::bigint,
      (jsonb_path_query_first(p, '$[0].Plan.** ? (@."Node Type" like_regex "Join|Nested")."Plan Rows"') #>> '{}')::numeric::bigint,
      jsonb_path_query_first(p, '$[0].Plan.** ? (@."Node Type" like_regex "Join|Nested")."Node Type"') #>> '{}');
  END LOOP;
END $$;
SELECT * FROM choice;
\timing on
\echo == nested loop forzado, caliente
SET enable_hashjoin = off; SET enable_mergejoin = off;
SELECT r.analyte_code, count(*) FROM staging.protocol_stats s JOIN staging.result_eav r USING (lab_order_id) WHERE s.site_code = 'E' AND left(s.visible_number, 2) = 'E-' GROUP BY r.analyte_code \g /dev/null
SELECT r.analyte_code, count(*) FROM staging.protocol_stats s JOIN staging.result_eav r USING (lab_order_id) WHERE s.site_code = 'E' AND left(s.visible_number, 2) = 'E-' GROUP BY r.analyte_code \g /dev/null
SELECT r.analyte_code, count(*) FROM staging.protocol_stats s JOIN staging.result_eav r USING (lab_order_id) WHERE s.site_code = 'E' AND left(s.visible_number, 2) = 'E-' GROUP BY r.analyte_code \g /dev/null
SELECT r.analyte_code, count(*) FROM staging.protocol_stats s JOIN staging.result_eav r USING (lab_order_id) WHERE s.site_code = 'E' AND left(s.visible_number, 2) = 'E-' GROUP BY r.analyte_code \g /dev/null
\echo == hash join forzado, caliente
RESET enable_hashjoin; RESET enable_mergejoin; SET enable_nestloop = off;
SELECT r.analyte_code, count(*) FROM staging.protocol_stats s JOIN staging.result_eav r USING (lab_order_id) WHERE s.site_code = 'E' AND left(s.visible_number, 2) = 'E-' GROUP BY r.analyte_code \g /dev/null
SELECT r.analyte_code, count(*) FROM staging.protocol_stats s JOIN staging.result_eav r USING (lab_order_id) WHERE s.site_code = 'E' AND left(s.visible_number, 2) = 'E-' GROUP BY r.analyte_code \g /dev/null
SELECT r.analyte_code, count(*) FROM staging.protocol_stats s JOIN staging.result_eav r USING (lab_order_id) WHERE s.site_code = 'E' AND left(s.visible_number, 2) = 'E-' GROUP BY r.analyte_code \g /dev/null
SELECT r.analyte_code, count(*) FROM staging.protocol_stats s JOIN staging.result_eav r USING (lab_order_id) WHERE s.site_code = 'E' AND left(s.visible_number, 2) = 'E-' GROUP BY r.analyte_code \g /dev/null
