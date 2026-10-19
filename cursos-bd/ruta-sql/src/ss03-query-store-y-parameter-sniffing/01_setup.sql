-- sqlserver
-- ss03 · la consulta por sede de la Fase 13, sobre las tablas de la caja, en una base aparte (ss03): aquí se
-- cambian índices, Query Store y el nivel de compatibilidad sin tocar ALAMEDA. Se corre una vez:
--   ../ss01-la-base-en-su-motor-original/sqlcmd.sh -b < 01_setup.sql
IF DB_ID('ss03') IS NOT NULL BEGIN ALTER DATABASE ss03 SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE ss03; END;
CREATE DATABASE ss03;
ALTER DATABASE ss03 SET RECOVERY SIMPLE;
GO
USE ss03;
GO
-- Los protocolos desde 2025 y sus resultados: los de la consulta de la Fase 13.
SELECT IdProtocolo, Sede, Fecha INTO dbo.Protocolos FROM ALAMEDA.dbo.Protocolos WHERE Fecha >= '2025-01-01';
ALTER TABLE dbo.Protocolos ALTER COLUMN IdProtocolo int NOT NULL;
ALTER TABLE dbo.Protocolos ADD CONSTRAINT PK_Protocolos PRIMARY KEY CLUSTERED (IdProtocolo);
CREATE INDEX IX_Protocolos_Sede_Fecha ON dbo.Protocolos (Sede, Fecha);

SELECT r.IdItem, r.IdProtocolo, r.CodDeterminacion, r.Valor INTO dbo.ResultadoItem
FROM ALAMEDA.dbo.ResultadoItem AS r JOIN dbo.Protocolos AS p ON p.IdProtocolo = r.IdProtocolo;
ALTER TABLE dbo.ResultadoItem ALTER COLUMN IdItem int NOT NULL;
ALTER TABLE dbo.ResultadoItem ADD CONSTRAINT PK_ResultadoItem PRIMARY KEY CLUSTERED (IdItem);
-- El índice que la base de Alameda no tiene (la Fase 25 lo encontró por las malas).
CREATE INDEX IX_ResultadoItem_IdProtocolo ON dbo.ResultadoItem (IdProtocolo) INCLUDE (CodDeterminacion);
UPDATE STATISTICS dbo.Protocolos WITH FULLSCAN;
UPDATE STATISTICS dbo.ResultadoItem WITH FULLSCAN;
GO
-- Query Store: en una base nueva de 2022 en adelante ya viene encendido. Para el laboratorio se captura todo
-- (QUERY_CAPTURE_MODE = ALL): el modo por defecto, AUTO, deja afuera las consultas baratas o poco frecuentes.
SELECT actual_state_desc, query_capture_mode_desc FROM sys.database_query_store_options;
ALTER DATABASE ss03 SET QUERY_STORE = ON (OPERATION_MODE = READ_WRITE, QUERY_CAPTURE_MODE = ALL);
GO
-- La consulta por sede, como la escribiría un reporte: un procedimiento con la sede como parámetro.
CREATE OR ALTER PROCEDURE dbo.resultados_por_sede @sede nchar(1), @desde date AS
SELECT r.CodDeterminacion, COUNT(*) AS resultados
FROM dbo.Protocolos AS p JOIN dbo.ResultadoItem AS r ON r.IdProtocolo = p.IdProtocolo
WHERE p.Sede = @sede AND p.Fecha >= @desde
GROUP BY r.CodDeterminacion;
GO
SELECT (SELECT COUNT(*) FROM dbo.Protocolos) AS protocolos, (SELECT COUNT(*) FROM dbo.ResultadoItem) AS resultados,
       (SELECT compatibility_level FROM sys.databases WHERE name = 'ss03') AS nivel,
       (SELECT actual_state_desc FROM sys.database_query_store_options) AS query_store;
GO
