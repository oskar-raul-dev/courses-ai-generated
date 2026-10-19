-- Fase 22 · soluciones ejecutables de los ejercicios 1–16. Corre después de 01_setup.sql, 02 y 03 (o 06 para el 14).
-- Lo que escribe se hace sobre tablas de prueba propias y se borra al final. No modifica staging.f22_result.

-- 1. La verdad del día: cuántos resultados, y cuántos protocolos.
SELECT count(*) AS resultados, count(DISTINCT r.lab_order_id) AS protocolos
FROM staging.f22_expected e JOIN alameda.result r ON r.result_id = e.result_id;

-- 2. La marca de agua de una corrida: el máximo de lo que se exportaría de un solo golpe.
SELECT max(recorded_at) AS marca_si_todo_estuviera_confirmado FROM staging.f22_result_source;

-- 3. El span de un protocolo: la diferencia entre su primer y su último resultado (en minutos).
SELECT round(avg(extract(epoch FROM (mx - mn)) / 60)::numeric, 1) AS span_medio_min, max(extract(epoch FROM (mx - mn)) / 60) AS span_max_min
FROM (SELECT lab_order_id, min(recorded_at) AS mn, max(recorded_at) AS mx FROM staging.f22_result_source GROUP BY lab_order_id) x;

-- 4. Los empates: instantes distintos, instantes compartidos por dos o más protocolos, y protocolos con empate.
SELECT count(*) AS instantes, count(*) FILTER (WHERE p > 1) AS instantes_con_varios_protocolos,
       sum(p) FILTER (WHERE p > 1) AS protocolos_con_empate
FROM (SELECT recorded_at, count(DISTINCT lab_order_id) AS p FROM staging.f22_result_source GROUP BY recorded_at) x;

-- 5. El segundo en cero: qué fracción de la fecha de registro cae exactamente en el minuto.
SELECT round(100.0 * count(*) FILTER (WHERE extract(second FROM recorded_at) = 0) / count(*), 1) AS pct_en_el_minuto
FROM staging.f22_result_source;

-- 6. Cuántas filas re-leería la ventana de una hora en un ciclo, si la marca estuviera a la mitad del día.
WITH marca AS (SELECT percentile_cont(0.5) WITHIN GROUP (ORDER BY extract(epoch FROM recorded_at)) AS m FROM staging.f22_result_source)
SELECT count(*) AS filas_en_la_ventana_de_1h
FROM staging.f22_result_source, marca
WHERE extract(epoch FROM recorded_at) > marca.m - 3600 AND extract(epoch FROM recorded_at) <= marca.m;

-- 7. Cuánto tarda en reloj una demora lenta de 0,3 a 0,6 s, con el día de 30 s: en minutos del día.
SELECT round(0.3 * 86400 / 30 / 60, 1) AS minimo_min_del_dia, round(0.6 * 86400 / 30 / 60, 1) AS maximo_min_del_dia;

-- 8. El slot que nadie consume retiene WAL: se crea, se escribe y se mide.
SELECT pg_drop_replication_slot(slot_name) FROM pg_replication_slots WHERE slot_name = 'f22_ej8';
SELECT pg_create_logical_replication_slot('f22_ej8', 'test_decoding');
CREATE TABLE staging.ej8 (x int);
INSERT INTO staging.ej8 SELECT generate_series(1, 20000);
SELECT pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) AS wal_retenido FROM pg_replication_slots WHERE slot_name = 'f22_ej8';
SELECT pg_drop_replication_slot('f22_ej8');

-- 9. Una transacción revertida no aparece en el flujo de cambios.
SELECT pg_drop_replication_slot(slot_name) FROM pg_replication_slots WHERE slot_name = 'f22_ej9';
SELECT pg_create_logical_replication_slot('f22_ej9', 'test_decoding');
CREATE TABLE staging.ej9 (x int);
BEGIN; INSERT INTO staging.ej9 VALUES (1); ROLLBACK;
BEGIN; INSERT INTO staging.ej9 VALUES (2); COMMIT;
SELECT count(*) AS lineas_de_datos FROM pg_logical_slot_get_changes('f22_ej9', NULL, NULL) WHERE data LIKE 'table %';
SELECT pg_drop_replication_slot('f22_ej9');

-- 10. Un UPDATE se decodifica con la fila completa, no solo la columna cambiada.
SELECT pg_drop_replication_slot(slot_name) FROM pg_replication_slots WHERE slot_name = 'f22_ej10';
SELECT pg_create_logical_replication_slot('f22_ej10', 'test_decoding');
CREATE TABLE staging.ej10 (id int PRIMARY KEY, a text, b text);
INSERT INTO staging.ej10 VALUES (1, 'x', 'y');
UPDATE staging.ej10 SET b = 'z' WHERE id = 1;
SELECT data FROM pg_logical_slot_get_changes('f22_ej10', NULL, NULL) WHERE data LIKE 'table %UPDATE%';
SELECT pg_drop_replication_slot('f22_ej10');

-- 11. La clave única de la bandeja: un segundo mensaje con el mismo identificador no entra.
CREATE TEMP TABLE ej11 (message_id text PRIMARY KEY, payload jsonb);
INSERT INTO ej11 VALUES ('m-1', '{}') ON CONFLICT (message_id) DO NOTHING;
INSERT INTO ej11 VALUES ('m-1', '{}') ON CONFLICT (message_id) DO NOTHING;
SELECT count(*) AS filas_tras_dos_envios FROM ej11;

-- 12. El número de versión: la corrección vieja que llega tarde no pisa a la nueva.
CREATE TEMP TABLE ej12 (message_id text PRIMARY KEY, version int, payload text);
INSERT INTO ej12 VALUES ('r-1', 2, 'nueva');
INSERT INTO ej12 VALUES ('r-1', 1, 'vieja') ON CONFLICT (message_id) DO UPDATE SET version = excluded.version, payload = excluded.payload
  WHERE excluded.version > ej12.version;
SELECT version, payload FROM ej12 WHERE message_id = 'r-1';

-- 13. El mensaje veneno: cuántos intentos pasan antes de descartarlo, y en qué tabla queda.
SELECT count(*) AS en_descartes, string_agg(DISTINCT reason, '; ') AS motivo FROM staging.f22_dead;

-- 14. El outbox: después del relevador, no queda ningún mensaje pendiente.
SELECT count(*) AS pendientes_en_outbox FROM staging.f22_outbox WHERE sent_at IS NULL;

-- 15. La cola: cuántos mensajes quedan pendientes, y cuántos se marcaron como hechos por cada consumidor.
SELECT done_by, count(*) AS procesados FROM staging.f22_queue WHERE status = 'done' GROUP BY done_by ORDER BY done_by;

-- 16. Tras la última corrida (procesamiento transaccional), identificadores repetidos en el destino.
SELECT count(*) AS identificadores_repetidos FROM (SELECT message_id FROM staging.f22_destination GROUP BY message_id HAVING count(*) > 1) x;

-- Limpieza de las tablas de prueba del CDC (las temporales no se decodifican: por eso no se usan aquí).
DROP TABLE IF EXISTS staging.ej8, staging.ej9, staging.ej10;
