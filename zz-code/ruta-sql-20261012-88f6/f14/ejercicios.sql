\pset pager off
\echo == ej12 count estimado
SELECT reltuples::bigint FROM pg_class WHERE oid='staging.portal_order'::regclass;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) SELECT reltuples FROM pg_class WHERE oid='staging.portal_order'::regclass;
\echo == ej14 keyset sin el índice compuesto
BEGIN;
DROP INDEX staging.portal_order_newest_idx;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) SELECT * FROM staging.portal_order WHERE (ordered_on, lab_order_id) < ('2020-06-01', 900000) ORDER BY ordered_on DESC, lab_order_id DESC LIMIT 20;
ROLLBACK;
\echo == ej16 cien páginas con OFFSET
SELECT pg_stat_statements_reset() IS NOT NULL;
SELECT format('SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET %s LIMIT 20', 20 * (n - 1)) FROM generate_series(1, 100) n \gexec
SELECT calls, round(total_exec_time::numeric,1) total_ms, round(mean_exec_time::numeric,3) mean_ms, round(min_exec_time::numeric,3) min_ms, round(max_exec_time::numeric,3) max_ms, shared_blks_hit + shared_blks_read AS bloques FROM pg_stat_statements WHERE query LIKE '%portal_order ORDER BY%';
\echo == ej17 dónde rompe con 100 ms
SET statement_timeout = '100ms';
\timing on
SELECT count(*) FROM (SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 499980 LIMIT 20) p25000;
SELECT count(*) FROM (SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 599980 LIMIT 20) p30000;
SELECT count(*) FROM (SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 699980 LIMIT 20) p35000;
SELECT count(*) FROM (SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 799980 LIMIT 20) p40000;
\timing off
RESET statement_timeout;
\echo == ej20 keyset solo por fecha
WITH page1 AS (SELECT * FROM staging.portal_order ORDER BY ordered_on DESC, lab_order_id DESC LIMIT 20),
     last AS (SELECT min(ordered_on) d FROM page1)
SELECT (SELECT count(*) FROM staging.portal_order, last WHERE ordered_on = last.d) AS mismo_dia,
       (SELECT count(*) FROM page1, last WHERE page1.ordered_on = last.d) AS en_la_pagina_1;
