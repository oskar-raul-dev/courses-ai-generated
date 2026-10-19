\pset pager off
\echo == tamaños
SELECT pg_size_pretty(sum(bytes)) AS archivos,
       pg_size_pretty(sum(bytes) FILTER (WHERE file_type = 'INFORME_PDF')) AS pdf,
       pg_size_pretty(sum(bytes) FILTER (WHERE file_type = 'ORDEN_ESCANEADA')) AS ordenes FROM staging.file_listing;
SELECT pg_size_pretty(sum(pg_total_relation_size(c.oid))) AS legacy
FROM pg_class AS c JOIN pg_namespace AS n ON n.oid = c.relnamespace WHERE n.nspname = 'legacy' AND c.relkind = 'r';
\echo == orden de columnas
SELECT pg_table_size('staging.result_as_is') / 8192 AS como_esta, pg_table_size('staging.result_reordered') / 8192 AS reordenada,
       pg_table_size('staging.align_bad') / 8192 AS align_bad, pg_table_size('staging.align_good') / 8192 AS align_good;
\echo == pdf
SELECT pg_size_pretty(pg_total_relation_size('staging.report_pdf_bytea')) AS bytea,
       pg_size_pretty(pg_total_relation_size('pg_largeobject')) AS objeto_grande,
       pg_size_pretty(pg_total_relation_size('staging.report_file')) AS ruta_y_hash;
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT lab_order_id, created_on FROM staging.report_pdf_bytea WHERE created_on = '2026-10-02';
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT sum(length(pdf || ''::bytea)) FROM staging.report_pdf_bytea WHERE created_on = '2026-10-02';
\echo == pruning
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_as_is WHERE recorded_at >= '2024-10-01' AND recorded_at < '2024-11-01' AND analyte_code = 'GLU';
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM staging.result_by_month WHERE recorded_at >= '2024-10-01' AND recorded_at < '2024-11-01' AND analyte_code = 'GLU';
\echo == sacar un mes, dentro de transacciones que se deshacen
CHECKPOINT;
SELECT pg_current_wal_insert_lsn() AS antes \gset
BEGIN;
DELETE FROM staging.result_as_is WHERE recorded_at >= '2025-01-01' AND recorded_at < '2025-02-01';
SELECT pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_insert_lsn(), :'antes')) AS wal_delete;
ROLLBACK;
CHECKPOINT;
SELECT pg_current_wal_insert_lsn() AS antes \gset
BEGIN;
ALTER TABLE staging.result_by_month DETACH PARTITION staging.result_2025_01;
DROP TABLE staging.result_2025_01;
SELECT pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_insert_lsn(), :'antes')) AS wal_detach;
ROLLBACK;
