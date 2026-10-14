-- postgres
-- Boss II · El portal de 2018 · solución de referencia (no viaja al repositorio público, D42).
-- 1. Cada informe con un token al azar de 122 bits (UUIDv4: el v7 de la Fase 10 deja ver la fecha), único.
-- 2. Los enlaces de 2018 (md5 del número) quedan registrados como vencidos: responden, pero no abren nada.
-- 3. La página del médico, con keyset sobre un índice (doctor_id, ordered_on DESC, lab_order_id DESC), y el total
--    del médico contado en ese índice.
BEGIN;
DROP TABLE IF EXISTS staging.portal_report, staging.portal_expired_link;
CREATE TABLE staging.portal_report AS
SELECT lab_order_id, gen_random_uuid() AS token, doctor_id, ordered_on, visible_number, site_code, patient_name
FROM staging.portal_2018;
ALTER TABLE staging.portal_report ADD PRIMARY KEY (lab_order_id), ALTER COLUMN token SET NOT NULL,
  ADD CONSTRAINT portal_report_token_key UNIQUE (token);
CREATE INDEX portal_report_doctor_newest_idx ON staging.portal_report (doctor_id, ordered_on DESC, lab_order_id DESC);
CREATE TABLE staging.portal_expired_link (url_hash text PRIMARY KEY, expired_on date NOT NULL DEFAULT current_date);
-- los 3.902 NroProtocolo repetidos (Fase 10) dan enlaces repetidos: en 2018, un enlace abría dos informes
INSERT INTO staging.portal_expired_link (url_hash) SELECT DISTINCT url_hash FROM staging.portal_2018;
COMMIT;
VACUUM ANALYZE staging.portal_report;
ANALYZE staging.portal_expired_link;

\echo == criterio 1: el diccionario de la Fase 10 (md5 de todos los números posibles) contra los tokens
SELECT count(*) AS informes_alcanzados
FROM (SELECT md5(s || '-' || lpad(n::text, 7, '0')) AS h
      FROM unnest(ARRAY['A','C','E','J','R','V']) s, generate_series(0, 700000) n) d
JOIN staging.portal_report r ON r.token::text = d.h;
SELECT count(*) AS vecinos_alcanzados
FROM generate_series(118697, 118796) n
JOIN staging.portal_report r ON r.token::text = md5('C-' || lpad(n::text, 7, '0'));

\echo == criterio 2: un informe por su token
SELECT token AS t FROM staging.portal_report WHERE visible_number = 'C-0118696' \gset
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) SELECT * FROM staging.portal_report WHERE token = :'t';

\echo == criterio 3: la página del médico 144, primera y última, con keyset
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF)
SELECT lab_order_id, token, visible_number, ordered_on, patient_name FROM staging.portal_report
WHERE doctor_id = 144 ORDER BY ordered_on DESC, lab_order_id DESC LIMIT 20;
SELECT ordered_on AS last_on, lab_order_id AS last_id FROM staging.portal_report WHERE doctor_id = 144
ORDER BY ordered_on DESC, lab_order_id DESC OFFSET 1099 LIMIT 1 \gset
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF)
SELECT lab_order_id, token, visible_number, ordered_on, patient_name FROM staging.portal_report
WHERE doctor_id = 144 AND (ordered_on, lab_order_id) < (:'last_on', :last_id)
ORDER BY ordered_on DESC, lab_order_id DESC LIMIT 20;

\echo == criterio 4: "página 1 de N" para el médico
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) SELECT count(*) FROM staging.portal_report WHERE doctor_id = 144;

\echo == criterio 5: los enlaces de 2018
SELECT (SELECT count(*) FROM staging.portal_expired_link) AS vencidos,
       (SELECT count(*) FROM staging.portal_expired_link e JOIN staging.portal_report r ON r.token::text = e.url_hash) AS abren_un_informe;
EXPLAIN (ANALYZE, BUFFERS, TIMING OFF, COSTS OFF) SELECT expired_on FROM staging.portal_expired_link WHERE url_hash = md5('C-0118696');
