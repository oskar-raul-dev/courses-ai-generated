-- sqlserver
-- ss03 · §8 y §9. Dos maneras de fijar un plan que dejan de servir cuando cambian los índices.
--   ../ss01-la-base-en-su-motor-original/sqlcmd.sh < 05_roturas.sql
-- Va sin -b: el segundo lote falla a propósito.
USE ss03;
GO
-- 1. La pantalla de la sede (Fase 13, autopsia): sus últimos 50 protocolos, sobre todos los protocolos de la caja,
--    con el índice por fecha de 2012 y el compuesto que llegó después. El hint de 2012 nombra el de la fecha.
DROP TABLE IF EXISTS dbo.protocol_hint;
SELECT IdProtocolo, Sede, Fecha INTO dbo.protocol_hint FROM ALAMEDA.dbo.Protocolos;
ALTER TABLE dbo.protocol_hint ALTER COLUMN IdProtocolo int NOT NULL;
ALTER TABLE dbo.protocol_hint ADD CONSTRAINT PK_protocol_hint PRIMARY KEY (IdProtocolo);
CREATE INDEX protocol_hint_fecha_idx ON dbo.protocol_hint (Fecha);
CREATE INDEX protocol_hint_sede_fecha_idx ON dbo.protocol_hint (Sede, Fecha);
SELECT Sede, COUNT(*) AS protocolos, MAX(Fecha) AS ultimo FROM dbo.protocol_hint GROUP BY Sede ORDER BY Sede;
GO
-- La consulta con el hint de 2012; lab measure --engine sqlserver muestra su plan (estructura, sin ejecutar).
SELECT TOP (50) IdProtocolo, Fecha FROM dbo.protocol_hint WITH (INDEX (protocol_hint_fecha_idx))
WHERE Sede = N'E' ORDER BY Fecha DESC;
GO
-- 2. El índice que el hint nombra deja de existir.
DROP INDEX protocol_hint_fecha_idx ON dbo.protocol_hint;
GO
SELECT TOP (50) IdProtocolo, Fecha FROM dbo.protocol_hint WITH (INDEX (protocol_hint_fecha_idx))
WHERE Sede = N'E' ORDER BY Fecha DESC;
GO
-- 3. Un plan forzado en Query Store cuyo índice deja de existir. Se compila para V (nested loops con el seek sobre
--    IX_ResultadoItem_IdProtocolo), se fuerza ese plan, se borra el índice y se ejecuta para C.
ALTER DATABASE ss03 SET QUERY_STORE CLEAR;
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
EXEC dbo.resultados_por_sede @sede = N'V', @desde = '2026-09-01';
EXEC sp_query_store_flush_db;
DECLARE @q bigint, @p bigint;
SELECT TOP (1) @q = q.query_id, @p = p.plan_id FROM sys.query_store_query AS q
JOIN sys.query_store_plan AS p ON p.query_id = q.query_id WHERE q.object_id = OBJECT_ID('dbo.resultados_por_sede');
EXEC sp_query_store_force_plan @query_id = @q, @plan_id = @p;
GO
DROP INDEX IX_ResultadoItem_IdProtocolo ON dbo.ResultadoItem;
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
EXEC dbo.resultados_por_sede @sede = N'C', @desde = '2026-09-01';
EXEC sp_query_store_flush_db;
GO
SELECT plan_id, is_forced_plan, force_failure_count, last_force_failure_reason_desc
FROM sys.query_store_plan WHERE is_forced_plan = 1;
GO
-- Se deja como estaba: el índice de vuelta, sin forzados.
CREATE INDEX IX_ResultadoItem_IdProtocolo ON dbo.ResultadoItem (IdProtocolo) INCLUDE (CodDeterminacion);
DECLARE @q bigint, @p bigint;
SELECT TOP (1) @q = query_id, @p = plan_id FROM sys.query_store_plan WHERE is_forced_plan = 1;
IF @p IS NOT NULL EXEC sp_query_store_unforce_plan @query_id = @q, @plan_id = @p;
SELECT COUNT(*) AS forzados FROM sys.query_store_plan WHERE is_forced_plan = 1;
GO
