\pset pager off
\echo == ej1
SELECT n_distinct, most_common_vals, most_common_freqs, correlation FROM pg_stats WHERE schemaname='alameda' AND tablename='lab_order' AND attname='site_code';
\echo == ej8
SELECT statistics_name, dependencies FROM pg_stats_ext WHERE statistics_name='protocol_stats_site_prefix_stat';
SELECT m.values, m.frequency FROM pg_statistic_ext s JOIN pg_statistic_ext_data d ON d.stxoid = s.oid, pg_mcv_list_items(d.stxdmcv) m WHERE s.stxname='protocol_stats_site_prefix_stat' ORDER BY m.frequency DESC LIMIT 8;
\echo == ej9
BEGIN;
DROP STATISTICS staging.protocol_stats_site_prefix_stat;
CREATE STATISTICS staging.protocol_stats_dep_only (dependencies) ON site_code, (left(visible_number, 2)) FROM staging.protocol_stats;
ANALYZE staging.protocol_stats;
SELECT dependencies FROM pg_stats_ext WHERE statistics_name='protocol_stats_dep_only';
EXPLAIN SELECT count(*) FROM staging.protocol_stats WHERE site_code = 'E' AND left(visible_number, 2) = 'E-';
EXPLAIN SELECT count(*) FROM staging.protocol_stats WHERE site_code = 'C' AND left(visible_number, 2) = '00';
SELECT count(*) FROM staging.protocol_stats WHERE site_code = 'C' AND left(visible_number, 2) = '00';
ROLLBACK;
ANALYZE staging.protocol_stats;
EXPLAIN SELECT count(*) FROM staging.protocol_stats WHERE site_code = 'C' AND left(visible_number, 2) = '00';
\echo == ej21
SELECT date_trunc('week', recorded_at)::date AS semana, count(*) FROM alameda.result WHERE recorded_at >= '2026-08-01' AND recorded_at < '2026-10-01' GROUP BY 1 ORDER BY 1;
SELECT count(*) AS filas FROM alameda.result;
