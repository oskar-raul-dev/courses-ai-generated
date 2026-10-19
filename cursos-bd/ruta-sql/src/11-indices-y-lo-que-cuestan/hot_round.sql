-- postgres
-- Una vuelta de 02_hot_updates.sql: :variant, :fillfactor y :extra_index vienen de afuera.
DROP TABLE IF EXISTS staging.hot_result;
CREATE TABLE staging.hot_result (LIKE alameda.result) WITH (fillfactor = :fillfactor);
INSERT INTO staging.hot_result SELECT * FROM alameda.result WHERE recorded_at >= '2025-01-01' ORDER BY recorded_at, result_id LIMIT 200000;
ALTER TABLE staging.hot_result ADD PRIMARY KEY (result_id);
CREATE INDEX hot_result_lab_order_id_idx ON staging.hot_result (lab_order_id);
CREATE INDEX hot_result_analyte_code_idx ON staging.hot_result (analyte_code);
:extra_index
VACUUM ANALYZE staging.hot_result;
SELECT pg_stat_reset_single_table_counters('staging.hot_result'::regclass);
CHECKPOINT;
SELECT pg_current_wal_insert_lsn() AS before_lsn \gset
UPDATE staging.hot_result SET value_numeric = value_numeric + 1
WHERE result_id IN (SELECT result_id FROM staging.hot_result WHERE value_numeric IS NOT NULL AND result_id % 20 = 0
                    ORDER BY result_id LIMIT 10000);   -- dispersas, como las correcciones de verdad: una de cada veinte
SELECT pg_stat_force_next_flush();
SELECT pg_current_wal_insert_lsn() AS after_lsn \gset
SELECT pg_sleep(1);
INSERT INTO staging.hot_report
SELECT :'variant', n_tup_upd, n_tup_hot_upd, pg_wal_lsn_diff(:'after_lsn', :'before_lsn')
FROM pg_stat_user_tables WHERE relid = 'staging.hot_result'::regclass;
