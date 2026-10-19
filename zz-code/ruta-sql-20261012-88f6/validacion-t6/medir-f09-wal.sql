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
