-- Fase 22 · CDC por decodificación lógica: lo que el motor escribe en el WAL, leído como cambios de fila.
-- Requiere wal_level = logical (ya lo pone el compose de a02). El plugin es test_decoding, que viene en la imagen:
-- sirve para ver la mecánica; la replicación real usa pgoutput y un cliente (en prosa, §5 de la lección).
-- El slot retiene WAL hasta que se lee o se borra: por eso se borra al final.

SHOW wal_level;

DROP TABLE IF EXISTS staging.f22_cdc_demo;
CREATE TABLE staging.f22_cdc_demo (result_id integer PRIMARY KEY, analyte_code text, value_numeric numeric);
SELECT pg_drop_replication_slot(slot_name) FROM pg_replication_slots WHERE slot_name = 'f22_cdc';
SELECT pg_create_logical_replication_slot('f22_cdc', 'test_decoding');

-- Una transacción con tres cambios: se decodifican en orden, con su inicio y su fin.
BEGIN;
INSERT INTO staging.f22_cdc_demo VALUES (1, 'GLU', 110), (2, 'HB', 13.2);
UPDATE staging.f22_cdc_demo SET value_numeric = 112 WHERE result_id = 1;
COMMIT;

-- Otra transacción que se revierte: no aparece en el flujo.
BEGIN;
INSERT INTO staging.f22_cdc_demo VALUES (3, 'GB', 6.1);
ROLLBACK;

SELECT data FROM pg_logical_slot_get_changes('f22_cdc', NULL, NULL);

-- El retraso del consumidor: cuánto WAL retiene el slot que nadie lee.
SELECT slot_name, active, pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) AS wal_retenido
FROM pg_replication_slots WHERE slot_name = 'f22_cdc';

-- Volumen del día: los 6.651 resultados del 26/12/2025, en una sola transacción, y cuántos cambios decodifica el slot.
SELECT pg_drop_replication_slot('f22_cdc');
SELECT pg_create_logical_replication_slot('f22_cdc', 'test_decoding');
TRUNCATE staging.f22_cdc_demo;
INSERT INTO staging.f22_cdc_demo SELECT r.result_id, r.analyte_code, r.value_numeric
FROM staging.f22_expected e JOIN alameda.result r ON r.result_id = e.result_id;
SELECT count(*) AS cambios_decodificados FROM pg_logical_slot_get_changes('f22_cdc', NULL, NULL);

-- Se borra el slot: sin consumidor, retiene el WAL indefinidamente.
SELECT pg_drop_replication_slot('f22_cdc');
DROP TABLE IF EXISTS staging.f22_cdc_demo;
