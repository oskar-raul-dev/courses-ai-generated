-- Fase 23 · lo que cuesta RLS: el mismo portal, sin política y con política, y la política con y sin índice.
-- Paciente 39 (152 protocolos) y médico 144 (1.114 protocolos derivados; la mediana de los médicos es 986).
-- Las consultas como rol se hacen con SET ROLE y los claims a mano, que es lo que hace PostgREST por dentro.

-- 1. Línea de base, como superusuario (sin RLS): los resultados del paciente 39 con el filtro escrito a mano.
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF)
SELECT count(*) FROM api.resultados WHERE lab_order_id IN (SELECT lab_order_id FROM alameda.lab_order WHERE patient_id = 39);

-- 2. El mismo portal como paciente: la política pone el filtro. Índice de la política: lab_order(patient_id), ya existe.
BEGIN;
SET LOCAL ROLE paciente;
SELECT set_config('request.jwt.claims', '{"role": "paciente", "patient_id": "39"}', true);
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM api.resultados;
SELECT count(*) AS resultados_que_ve_el_paciente FROM api.resultados;
-- Pedir un protocolo que no es suyo: la política lo esconde, no da error.
-- El protocolo -2147402959 es del paciente 12594 (un ID fijo: una subconsulta correría bajo RLS y vería solo lo suyo).
SELECT count(*) AS protocolo_ajeno FROM api.protocolos WHERE lab_order_id = -2147402959;
COMMIT;

-- 3. El médico, sin índice sobre referral(physician_id): la política recorre la tabla de derivaciones entera.
DROP INDEX IF EXISTS alameda.referral_physician_idx;
ANALYZE alameda.referral;
BEGIN;
SET LOCAL ROLE medico;
SELECT set_config('request.jwt.claims', '{"role": "medico", "physician_id": "144"}', true);
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM api.protocolos;
COMMIT;

-- 4. Con el índice de la política.
CREATE INDEX referral_physician_idx ON alameda.referral (physician_id);
ANALYZE alameda.referral;
BEGIN;
SET LOCAL ROLE medico;
SELECT set_config('request.jwt.claims', '{"role": "medico", "physician_id": "144"}', true);
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM api.protocolos;
SELECT count(*) AS protocolos_que_ve_el_medico FROM api.protocolos;
COMMIT;

-- 5. La política que sí usa un índice: el médico como columna de la tabla protegida (copia en staging, para no
--    tocar el modelo). La política es una comparación de columna, y el índice de esa columna la resuelve.
DROP TABLE IF EXISTS staging.f23_lab_order;
CREATE TABLE staging.f23_lab_order AS
SELECT o.lab_order_id, o.patient_id, o.ordered_on, o.site_code, o.payer_code, r.physician_id
FROM alameda.lab_order o JOIN alameda.referral r USING (lab_order_id);
ALTER TABLE staging.f23_lab_order ADD PRIMARY KEY (lab_order_id);
CREATE INDEX f23_lab_order_physician ON staging.f23_lab_order (physician_id);
VACUUM ANALYZE staging.f23_lab_order;
ALTER TABLE staging.f23_lab_order ENABLE ROW LEVEL SECURITY;
CREATE POLICY medico_columna ON staging.f23_lab_order FOR SELECT TO medico
  USING (physician_id = api.claim('physician_id')::integer);
GRANT USAGE ON SCHEMA staging TO medico;
GRANT SELECT ON staging.f23_lab_order TO medico;
BEGIN;
SET LOCAL ROLE medico;
SELECT set_config('request.jwt.claims', '{"role": "medico", "physician_id": "144"}', true);
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF, TIMING OFF) SELECT count(*) FROM staging.f23_lab_order;
COMMIT;

-- 6. La rotura de escritura: el médico 144 carga un resultado en un protocolo que no derivó.
BEGIN;
SET LOCAL ROLE medico;
SELECT set_config('request.jwt.claims', '{"role": "medico", "physician_id": "144"}', true);
INSERT INTO alameda.result (result_id, lab_order_id, analyte_code, value_numeric, recorded_at)
SELECT 999999999, min(lab_order_id), 'GLU', 100, now() FROM alameda.referral WHERE physician_id <> 144;
ROLLBACK;
