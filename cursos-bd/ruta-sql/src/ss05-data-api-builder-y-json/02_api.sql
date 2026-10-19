-- sqlserver
-- ss05 · §5.1 y §6. El contrato de la Fase 23 en SQL Server: el esquema api con dos vistas, un login propio para
-- Data API builder y la seguridad por fila con SESSION_CONTEXT. Después de 01_modelo.py. Es repetible.
--   ../ss01-la-base-en-su-motor-original/sqlcmd.sh -b < 02_api.sql
USE ss05;
GO
IF EXISTS (SELECT 1 FROM sys.security_policies WHERE name = 'portal') DROP SECURITY POLICY api.portal;
DROP VIEW IF EXISTS api.resultados, api.protocolos;
DROP FUNCTION IF EXISTS api.puede_ver_resultado, api.puede_ver;
IF SCHEMA_ID('api') IS NULL EXEC ('CREATE SCHEMA api');
GO
-- 1. Las vistas: el contrato, no las tablas (como en la Fase 23).
CREATE VIEW api.resultados AS
SELECT o.lab_order_id, o.ordered_on, r.result_id, r.analyte_code, a.name AS analyte, a.unit,
       r.value_numeric, r.qualifier, r.value_text, r.recorded_at
FROM alameda.result AS r
JOIN alameda.lab_order AS o ON o.lab_order_id = r.lab_order_id
LEFT JOIN alameda.analyte AS a ON a.analyte_code = r.analyte_code;
GO
CREATE VIEW api.protocolos AS
SELECT o.lab_order_id, o.ordered_on, o.site_code, o.payer_code FROM alameda.lab_order AS o;
GO
-- 2. El login de DAB: lee las vistas y nada más. No es sa, y no es dueño de nada.
IF SUSER_ID('dab_api') IS NULL CREATE LOGIN dab_api WITH PASSWORD = 'Dab-API-2026-lab', CHECK_POLICY = OFF;
IF USER_ID('dab_api') IS NULL CREATE USER dab_api FOR LOGIN dab_api;
GRANT SELECT ON SCHEMA::api TO dab_api;
GO
-- 3. La seguridad por fila. Un predicado: el paciente ve sus protocolos; el médico, los que derivó. Los claims
--    llegan en SESSION_CONTEXT, que DAB llena en cada pedido con set-session-context (uno por claim).
CREATE FUNCTION api.puede_ver (@lab_order_id int, @patient_id int)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT 1 AS ok
WHERE (CAST(SESSION_CONTEXT(N'roles') AS nvarchar(20)) = N'paciente'
       AND @patient_id = TRY_CAST(CAST(SESSION_CONTEXT(N'patient_id') AS nvarchar(20)) AS int))
   OR (CAST(SESSION_CONTEXT(N'roles') AS nvarchar(20)) = N'medico'
       AND EXISTS (SELECT 1 FROM alameda.referral AS f
                   WHERE f.lab_order_id = @lab_order_id
                     AND f.physician_id = TRY_CAST(CAST(SESSION_CONTEXT(N'physician_id') AS nvarchar(20)) AS int)))
   OR IS_SRVROLEMEMBER(N'sysadmin') = 1;      -- el laboratorio administra con sa: ve todo (ver la sección 6)
GO
CREATE FUNCTION api.puede_ver_resultado (@lab_order_id int)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT 1 AS ok FROM alameda.lab_order AS o
CROSS APPLY api.puede_ver(o.lab_order_id, o.patient_id)
WHERE o.lab_order_id = @lab_order_id;
GO
CREATE SECURITY POLICY api.portal
ADD FILTER PREDICATE api.puede_ver(lab_order_id, patient_id) ON alameda.lab_order,
ADD FILTER PREDICATE api.puede_ver_resultado(lab_order_id) ON alameda.result
WITH (STATE = ON);
GO
SELECT name, is_enabled FROM sys.security_policies;
GO
