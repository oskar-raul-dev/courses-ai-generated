-- postgres
-- Una vuelta de 01_write_cost.sql: vacía la tabla, mide el WAL de cargar las 200.000 filas y lo anota.
TRUNCATE staging.result_write;
CHECKPOINT;
SELECT pg_current_wal_insert_lsn() AS before_lsn \gset
INSERT INTO staging.result_write SELECT * FROM staging.write_source;
INSERT INTO staging.write_cost
SELECT :n, :'idx', pg_wal_lsn_diff(pg_current_wal_insert_lsn(), :'before_lsn'),
       round(pg_wal_lsn_diff(pg_current_wal_insert_lsn(), :'before_lsn') / 200000.0, 1);
