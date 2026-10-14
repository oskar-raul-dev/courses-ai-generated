DROP TABLE IF EXISTS staging.protocol_stats;
CREATE TABLE staging.protocol_stats AS SELECT "IdProtocolo" AS lab_order_id, "Sede" AS site_code, "NroProtocolo" AS visible_number, "Fecha"::date AS ordered_on FROM legacy."Protocolos";
ALTER TABLE staging.protocol_stats ADD PRIMARY KEY (lab_order_id);
ANALYZE staging.protocol_stats;
\echo == sin estadísticas extendidas
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) SELECT count(*) FROM staging.protocol_stats WHERE site_code = 'E' AND left(visible_number, 2) = 'E-';
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) SELECT count(*) FROM staging.protocol_stats p JOIN staging.result_eav r USING (lab_order_id) WHERE p.site_code = 'E' AND left(p.visible_number, 2) = 'E-';
CREATE STATISTICS protocol_stats_site_prefix_stat (dependencies, mcv) ON site_code, (left(visible_number, 2)) FROM staging.protocol_stats;
ANALYZE staging.protocol_stats;
\echo == con estadísticas extendidas
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) SELECT count(*) FROM staging.protocol_stats WHERE site_code = 'E' AND left(visible_number, 2) = 'E-';
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF) SELECT count(*) FROM staging.protocol_stats p JOIN staging.result_eav r USING (lab_order_id) WHERE p.site_code = 'E' AND left(p.visible_number, 2) = 'E-';
