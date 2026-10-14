CHECKPOINT;
SELECT pg_current_wal_lsn() AS a \gset
INSERT INTO staging.order_bigint (patient_id, ordered_on, site_code) SELECT patient_id, ordered_on, site_code FROM alameda.lab_order ORDER BY ordered_on, lab_order_id;
SELECT 'bigint' clave, pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), :'a')) wal \gset r_
CHECKPOINT;
SELECT pg_current_wal_lsn() AS a \gset
INSERT INTO staging.order_uuid4 (patient_id, ordered_on, site_code) SELECT patient_id, ordered_on, site_code FROM alameda.lab_order ORDER BY ordered_on, lab_order_id;
SELECT pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), :'a')) AS wal_uuid4 \gset
CHECKPOINT;
SELECT pg_current_wal_lsn() AS a \gset
INSERT INTO staging.order_uuid7 (order_id, patient_id, ordered_on, site_code)
SELECT uuidv7(ordered_on - now()), patient_id, ordered_on, site_code FROM alameda.lab_order ORDER BY ordered_on, lab_order_id;
SELECT pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), :'a')) AS wal_uuid7 \gset
SELECT :'r_wal' AS wal_bigint, :'wal_uuid4' AS wal_uuid4, :'wal_uuid7' AS wal_uuid7;
SELECT c.relname, pg_size_pretty(pg_relation_size(c.oid)) FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='staging' AND c.relname ~ '^order_(bigint|uuid4|uuid7)' ORDER BY 1;
SELECT order_id, uuid_extract_version(order_id) version, uuid_extract_timestamp(order_id), ordered_on FROM staging.order_uuid7 ORDER BY order_id DESC LIMIT 2;
SELECT order_id, uuid_extract_version(order_id), uuid_extract_timestamp(order_id) FROM staging.order_uuid4 LIMIT 1;
