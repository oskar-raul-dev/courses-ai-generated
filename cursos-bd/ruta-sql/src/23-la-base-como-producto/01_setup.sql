-- Fase 23 · la base como producto: roles de PostgREST, el esquema `api` y la seguridad por fila (RLS).
-- Se corre como superusuario, después de `uv run lab load --profile m --model`. Es repetible.
-- El superusuario ignora RLS: los scripts de las otras fases no cambian de resultado.

-- 1. El médico derivante de cada protocolo: el modelo no lo tenía, la caja sí (legacy.Protocolos.IdMedico).
DROP TABLE IF EXISTS alameda.referral CASCADE;
CREATE TABLE alameda.referral AS
SELECT p."IdProtocolo" AS lab_order_id, p."IdMedico" AS physician_id
FROM legacy."Protocolos" p JOIN alameda.lab_order o ON o.lab_order_id = p."IdProtocolo";
ALTER TABLE alameda.referral ADD PRIMARY KEY (lab_order_id);
-- El índice de la política del médico NO se crea aquí: 02_rls.sql mide con y sin él.
VACUUM ANALYZE alameda.referral;

-- 2. Los roles. `authenticator` es el único que entra; PostgREST cambia al rol que dice el JWT.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticator') THEN
    CREATE ROLE authenticator LOGIN NOINHERIT PASSWORD 'lab';
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'web_anon') THEN CREATE ROLE web_anon NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'paciente') THEN CREATE ROLE paciente NOLOGIN; END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'medico') THEN CREATE ROLE medico NOLOGIN; END IF;
END $$;
GRANT web_anon, paciente, medico TO authenticator;

-- 3. El esquema `api`: vistas que son el contrato, no las tablas. `security_invoker` hace que la vista
--    se lea con los permisos y las políticas de quien la consulta, no de quien la creó.
DROP SCHEMA IF EXISTS api CASCADE;
CREATE SCHEMA api;
-- nullif: tras un set_config en la misma sesión, current_setting(..., true) devuelve '' y no NULL, y ''::json falla.
CREATE FUNCTION api.claim(name text) RETURNS text LANGUAGE sql STABLE AS
  $$ SELECT nullif(current_setting('request.jwt.claims', true), '')::json ->> name $$;

CREATE VIEW api.resultados WITH (security_invoker = true) AS
SELECT o.lab_order_id, o.ordered_on, r.result_id, r.analyte_code, a.name AS analyte, a.unit,
       r.value_numeric, r.qualifier, r.value_text, r.recorded_at
FROM alameda.result r
JOIN alameda.lab_order o ON o.lab_order_id = r.lab_order_id
LEFT JOIN alameda.analyte a ON a.analyte_code = r.analyte_code;

CREATE VIEW api.protocolos WITH (security_invoker = true) AS
SELECT o.lab_order_id, o.ordered_on, o.site_code, o.payer_code FROM alameda.lab_order o;

GRANT USAGE ON SCHEMA api TO web_anon, paciente, medico;
GRANT SELECT ON api.resultados, api.protocolos TO paciente, medico;
GRANT USAGE ON SCHEMA alameda TO paciente, medico;
GRANT SELECT ON alameda.result, alameda.lab_order, alameda.analyte, alameda.referral TO paciente, medico;
GRANT INSERT ON alameda.result TO medico;
-- web_anon no tiene ningún permiso sobre datos: sin token, la API no muestra nada.

-- 4. Seguridad por fila. Las políticas leen los claims del JWT que PostgREST deja en request.jwt.claims.
ALTER TABLE alameda.lab_order ENABLE ROW LEVEL SECURITY;
ALTER TABLE alameda.result ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS paciente_ve_lo_suyo ON alameda.lab_order;
CREATE POLICY paciente_ve_lo_suyo ON alameda.lab_order FOR SELECT TO paciente
  USING (patient_id = api.claim('patient_id')::integer);
DROP POLICY IF EXISTS medico_ve_lo_que_derivo ON alameda.lab_order;
CREATE POLICY medico_ve_lo_que_derivo ON alameda.lab_order FOR SELECT TO medico
  USING (lab_order_id IN (SELECT lab_order_id FROM alameda.referral WHERE physician_id = api.claim('physician_id')::integer));

DROP POLICY IF EXISTS paciente_ve_sus_resultados ON alameda.result;
CREATE POLICY paciente_ve_sus_resultados ON alameda.result FOR SELECT TO paciente
  USING (EXISTS (SELECT 1 FROM alameda.lab_order o WHERE o.lab_order_id = result.lab_order_id
                 AND o.patient_id = api.claim('patient_id')::integer));
DROP POLICY IF EXISTS medico_ve_resultados_derivados ON alameda.result;
CREATE POLICY medico_ve_resultados_derivados ON alameda.result FOR SELECT TO medico
  USING (lab_order_id IN (SELECT lab_order_id FROM alameda.referral WHERE physician_id = api.claim('physician_id')::integer));
DROP POLICY IF EXISTS medico_carga_en_lo_suyo ON alameda.result;
CREATE POLICY medico_carga_en_lo_suyo ON alameda.result FOR INSERT TO medico
  WITH CHECK (lab_order_id IN (SELECT lab_order_id FROM alameda.referral WHERE physician_id = api.claim('physician_id')::integer));

NOTIFY pgrst, 'reload schema';

SELECT (SELECT count(*) FROM alameda.referral) AS protocolos_con_medico,
       (SELECT count(DISTINCT physician_id) FROM alameda.referral) AS medicos,
       (SELECT count(*) FROM pg_policies WHERE schemaname = 'alameda') AS politicas;
