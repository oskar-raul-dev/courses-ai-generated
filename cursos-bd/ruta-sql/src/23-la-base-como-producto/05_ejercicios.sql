-- Fase 23 · soluciones ejecutables de los ejercicios 1–16. Corre después de 01_setup.sql y 02_rls.sql.
-- Lo que escribe se revierte o se borra. Las consultas como rol usan SET LOCAL ROLE dentro de una transacción.
\set ON_ERROR_STOP 0

-- 1. Los roles de la API y quién puede cambiar a cuál.
SELECT r.rolname AS rol, m.rolname AS miembro_de
FROM pg_auth_members am JOIN pg_roles r ON r.oid = am.member JOIN pg_roles m ON m.oid = am.roleid
WHERE r.rolname = 'authenticator' ORDER BY m.rolname;

-- 2. Lo que ve el rol anónimo: nada.
BEGIN; SET LOCAL ROLE web_anon; SELECT count(*) FROM api.resultados; ROLLBACK;

-- 3. El claim, leído como lo lee la política.
BEGIN;
SELECT set_config('request.jwt.claims', '{"role": "paciente", "patient_id": "39"}', true);
SELECT api.claim('patient_id') AS patient_id, api.claim('role') AS rol, api.claim('no_existe') AS ausente;
ROLLBACK;

-- 4 y 5. El paciente 39: sus resultados, y el protocolo de otro paciente.
BEGIN; SET LOCAL ROLE paciente;
SELECT set_config('request.jwt.claims', '{"patient_id": "39"}', true);
SELECT count(*) AS resultados_propios FROM api.resultados;
SELECT count(*) AS protocolo_ajeno FROM api.protocolos WHERE lab_order_id = -2147402959;
ROLLBACK;

-- 6. El médico 144: lo que derivó.
BEGIN; SET LOCAL ROLE medico;
SELECT set_config('request.jwt.claims', '{"physician_id": "144"}', true);
SELECT count(*) AS protocolos_derivados FROM api.protocolos;
ROLLBACK;

-- 7. Las políticas, como las ve el catálogo.
SELECT tablename, policyname, cmd, roles FROM pg_policies WHERE schemaname = 'alameda' ORDER BY tablename, policyname;

-- 8. El plan del paciente: la política usa el índice de lab_order(patient_id).
BEGIN; SET LOCAL ROLE paciente;
SELECT set_config('request.jwt.claims', '{"patient_id": "39"}', true);
EXPLAIN (COSTS OFF) SELECT count(*) FROM api.protocolos;
ROLLBACK;

-- 9. Una vista sin security_invoker se lee con los permisos de su dueño, y el dueño no pasa por RLS.
CREATE VIEW api.ej9_sin_invoker AS SELECT o.lab_order_id, o.patient_id FROM alameda.lab_order o;
GRANT SELECT ON api.ej9_sin_invoker TO paciente;
BEGIN; SET LOCAL ROLE paciente;
SELECT set_config('request.jwt.claims', '{"patient_id": "39"}', true);
SELECT count(DISTINCT patient_id) AS pacientes_distintos_en_1000_filas FROM (SELECT patient_id FROM api.ej9_sin_invoker LIMIT 1000) x;
ROLLBACK;
DROP VIEW api.ej9_sin_invoker;

-- 10. El médico carga un resultado en un protocolo que no derivó: la política lo rechaza.
BEGIN; SET LOCAL ROLE medico;
SELECT set_config('request.jwt.claims', '{"physician_id": "144"}', true);
INSERT INTO alameda.result (result_id, lab_order_id, analyte_code, value_numeric, recorded_at)
SELECT 999999998, min(lab_order_id), 'GLU', 100, now() FROM alameda.referral WHERE physician_id <> 144;
ROLLBACK;

-- 11. Y en uno que sí derivó: entra.
BEGIN; SET LOCAL ROLE medico;
SELECT set_config('request.jwt.claims', '{"physician_id": "144"}', true);
INSERT INTO alameda.result (result_id, lab_order_id, analyte_code, value_numeric, recorded_at)
SELECT 999999997, min(lab_order_id), 'GLU', 100, now() FROM alameda.referral WHERE physician_id = 144;
ROLLBACK;

-- 12. El MD5 del número visible: el hash de una URL del portal se encuentra calculando el MD5 del número.
SELECT p.lab_order_id, p.visible_number, p.url_hash = md5(p.visible_number) AS coincide
FROM staging.portal_2018 p WHERE p.visible_number = 'C-0048213';

-- 13. La política del médico con el índice de referral: sigue recorriendo lab_order.
BEGIN; SET LOCAL ROLE medico;
SELECT set_config('request.jwt.claims', '{"physician_id": "144"}', true);
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM api.protocolos;
ROLLBACK;

-- 14. La política sobre una columna de la tabla protegida, con su índice.
BEGIN; SET LOCAL ROLE medico;
SELECT set_config('request.jwt.claims', '{"physician_id": "144"}', true);
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.f23_lab_order;
ROLLBACK;

-- 15. Quién no pasa por RLS: el superusuario y los roles con BYPASSRLS.
SELECT rolname, rolsuper, rolbypassrls FROM pg_roles WHERE rolname IN ('postgres', 'authenticator', 'paciente', 'medico', 'web_anon') ORDER BY rolname;

-- 16. Un paciente sin claim: la política compara con NULL y no muestra nada, sin error.
BEGIN; SET LOCAL ROLE paciente;
SELECT count(*) AS sin_claim FROM api.protocolos;
ROLLBACK;
