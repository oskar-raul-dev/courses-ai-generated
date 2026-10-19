USE ss05;
SET QUOTED_IDENTIFIER ON;
GO
-- ej11
SELECT COUNT(*) AS amp_r_gen_s FROM staging.culture_doc
WHERE JSON_CONTAINS(antibiogram, 'R', '$.AMPICILINA') = 1 AND JSON_CONTAINS(antibiogram, 'S', '$.GENTAMICINA') = 1;
-- ej12
SELECT COUNT(*) AS filas_largas FROM staging.culture_doc AS c CROSS APPLY OPENJSON(c.antibiogram) AS j;
GO
-- ej16: predicado de bloqueo al insertar un resultado de un protocolo que el médico no derivó
DROP TABLE IF EXISTS alameda.result_nuevo;
CREATE TABLE alameda.result_nuevo (result_id int IDENTITY PRIMARY KEY, lab_order_id int NOT NULL, analyte_code nvarchar(10) NOT NULL, value_text nvarchar(50));
GO
CREATE OR ALTER FUNCTION api.medico_puede_escribir (@lab_order_id int)
RETURNS TABLE WITH SCHEMABINDING AS RETURN
SELECT 1 AS ok FROM alameda.referral AS f
WHERE f.lab_order_id = @lab_order_id
  AND f.physician_id = TRY_CAST(CAST(SESSION_CONTEXT(N'physician_id') AS nvarchar(20)) AS int);
GO
CREATE SECURITY POLICY api.escritura ADD BLOCK PREDICATE api.medico_puede_escribir(lab_order_id) ON alameda.result_nuevo AFTER INSERT WITH (STATE = ON);
GO
DECLARE @suyo int = (SELECT TOP (1) lab_order_id FROM alameda.referral WHERE physician_id = 144);
DECLARE @ajeno int = (SELECT TOP (1) lab_order_id FROM alameda.referral WHERE physician_id <> 144);
EXEC sp_set_session_context N'physician_id', N'144';
INSERT INTO alameda.result_nuevo (lab_order_id, analyte_code, value_text) VALUES (@suyo, N'GLU', N'98');
SELECT COUNT(*) AS insertados_propios FROM alameda.result_nuevo;
INSERT INTO alameda.result_nuevo (lab_order_id, analyte_code, value_text) VALUES (@ajeno, N'GLU', N'98');
GO
DROP SECURITY POLICY api.escritura; DROP FUNCTION api.medico_puede_escribir; DROP TABLE alameda.result_nuevo;
GO
