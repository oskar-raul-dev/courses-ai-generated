USE ss04;
SET QUOTED_IDENTIFIER ON;
GO
-- ej2: tres GUID que difieren en un byte (el primero, el octavo, el último)
DROP TABLE IF EXISTS #g;
CREATE TABLE #g (etiqueta varchar(10), g uniqueidentifier);
INSERT INTO #g VALUES ('byte 0',  '01000000-0000-0000-0000-000000000000'),
                      ('byte 8',  '00000000-0000-0000-0100-000000000000'),
                      ('byte 15', '00000000-0000-0000-0000-000000000001');
SELECT etiqueta, g FROM #g ORDER BY g;
GO
-- ej3: NEWSEQUENTIALID envuelta en un DEFAULT
CREATE TABLE dbo.seq_mala (id uniqueidentifier DEFAULT CAST(NEWSEQUENTIALID() AS uniqueidentifier));
GO
-- ej7: tres UPDATE que no cambian nada
DECLARE @antes int = (SELECT COUNT(*) FROM dbo.resultado_historia WHERE IdItem = 12123358);
UPDATE dbo.resultado SET Valor = Valor WHERE IdItem = 12123358;
UPDATE dbo.resultado SET Valor = Valor WHERE IdItem = 12123358;
UPDATE dbo.resultado SET Valor = Valor WHERE IdItem = 12123358;
SELECT @antes AS versiones_antes, (SELECT COUNT(*) FROM dbo.resultado_historia WHERE IdItem = 12123358) AS versiones_despues;
GO
-- ej8: el quién olvidado
UPDATE dbo.resultado SET Valor = N'157' WHERE IdItem = 12123358;
SELECT TOP (2) Valor, ModificadoPor FROM dbo.resultado FOR SYSTEM_TIME ALL WHERE IdItem = 12123358 ORDER BY ValidoDesde DESC;
UPDATE dbo.resultado SET Valor = N'165', ModificadoPor = N'norma' WHERE IdItem = 12123358;
GO
-- ej9: traer la historia de antes, con un período que se superpone
ALTER TABLE dbo.resultado SET (SYSTEM_VERSIONING = OFF);
INSERT INTO dbo.resultado_historia (IdItem, IdProtocolo, CodDeterminacion, Valor, ModificadoPor, ValidoDesde, ValidoHasta)
SELECT IdItem, IdProtocolo, CodDeterminacion, N'160', N'equipo-legacy', '2026-10-09 10:00', '2030-01-01'
FROM dbo.resultado WHERE IdItem = 12123358;
GO
ALTER TABLE dbo.resultado SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.resultado_historia, DATA_CONSISTENCY_CHECK = ON));
GO
DELETE FROM dbo.resultado_historia WHERE ModificadoPor = N'equipo-legacy';
INSERT INTO dbo.resultado_historia (IdItem, IdProtocolo, CodDeterminacion, Valor, ModificadoPor, ValidoDesde, ValidoHasta)
SELECT IdItem, IdProtocolo, CodDeterminacion, N'160', N'equipo-legacy', '2026-10-09 10:00', '2026-10-10 08:00'
FROM dbo.resultado WHERE IdItem = 12123358;
ALTER TABLE dbo.resultado SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.resultado_historia, DATA_CONSISTENCY_CHECK = ON));
SELECT OBJECTPROPERTY(OBJECT_ID('dbo.resultado'), 'TableTemporalType') AS tipo_temporal;
GO
-- ej17: retención de seis meses
ALTER TABLE dbo.resultado SET (SYSTEM_VERSIONING = ON (HISTORY_RETENTION_PERIOD = 6 MONTHS));
SELECT name, history_retention_period, history_retention_period_unit_desc FROM sys.tables WHERE name = 'resultado';
SELECT is_temporal_history_retention_enabled FROM sys.databases WHERE name = 'ss04';
ALTER TABLE dbo.resultado SET (SYSTEM_VERSIONING = ON (HISTORY_RETENTION_PERIOD = INFINITE));
GO
-- 🔥1: ledger
DROP TABLE IF EXISTS dbo.resultado_ledger;
CREATE TABLE dbo.resultado_ledger (IdItem int NOT NULL PRIMARY KEY, Valor nvarchar(50) NULL)
WITH (SYSTEM_VERSIONING = ON, LEDGER = ON);
INSERT INTO dbo.resultado_ledger VALUES (12123358, N'165');
UPDATE dbo.resultado_ledger SET Valor = N'156' WHERE IdItem = 12123358;
SELECT name, ledger_type_desc FROM sys.tables WHERE name LIKE 'resultado_ledger%' OR name LIKE 'MSSQL_LedgerHistoryFor%';
GO
EXECUTE sys.sp_generate_database_ledger_digest;
GO
