USE ss04;
SET QUOTED_IDENTIFIER ON;
GO
-- ej9: traer la historia de antes, con un período que se superpone
ALTER TABLE dbo.resultado SET (SYSTEM_VERSIONING = OFF);
GO
INSERT INTO dbo.resultado_historia (IdItem, IdProtocolo, CodDeterminacion, Valor, ModificadoPor, ValidoDesde, ValidoHasta)
SELECT IdItem, IdProtocolo, CodDeterminacion, N'160', N'equipo-legacy', '2026-10-09 10:00', '2030-01-01'
FROM dbo.resultado WHERE IdItem = 12123358;
GO
ALTER TABLE dbo.resultado SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.resultado_historia, DATA_CONSISTENCY_CHECK = ON));
GO
DELETE FROM dbo.resultado_historia WHERE ModificadoPor = N'equipo-legacy';
GO
INSERT INTO dbo.resultado_historia (IdItem, IdProtocolo, CodDeterminacion, Valor, ModificadoPor, ValidoDesde, ValidoHasta)
SELECT IdItem, IdProtocolo, CodDeterminacion, N'160', N'equipo-legacy', '2026-10-09 10:00', '2026-10-10 08:00'
FROM dbo.resultado WHERE IdItem = 12123358;
GO
ALTER TABLE dbo.resultado SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.resultado_historia, DATA_CONSISTENCY_CHECK = ON));
GO
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
