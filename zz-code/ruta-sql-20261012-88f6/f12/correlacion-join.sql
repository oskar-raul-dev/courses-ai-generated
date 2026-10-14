\pset pager off
\set q 'SELECT r.analyte_code, count(*) FROM staging.protocol_stats s JOIN staging.result_as_is r USING (lab_order_id) WHERE s.site_code = ''E'' AND left(s.visible_number, 2) = ''E-'' GROUP BY r.analyte_code'
\di staging.result_as_is*
DROP STATISTICS IF EXISTS public.protocol_stats_site_prefix_stat;
DROP STATISTICS IF EXISTS staging.protocol_stats_site_prefix_stat;
ANALYZE staging.protocol_stats;
\echo == sin estadísticas extendidas
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) :q;
CREATE STATISTICS staging.protocol_stats_site_prefix_stat (dependencies, mcv) ON site_code, (left(visible_number, 2)) FROM staging.protocol_stats;
ANALYZE staging.protocol_stats;
\echo == con estadísticas extendidas
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) :q;
