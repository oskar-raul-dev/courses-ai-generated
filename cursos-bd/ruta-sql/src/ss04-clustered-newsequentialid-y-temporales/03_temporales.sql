-- sqlserver
-- ss04 · §5.3. La pregunta de Norma con una tabla versionada por el sistema: los resultados del 9 de octubre de 2026,
-- como en la Fase 07, y la misma corrección de la glucemia 12123358. Va sin -b: dos lotes fallan a propósito.
--   ../ss01-la-base-en-su-motor-original/sqlcmd.sh < 03_temporales.sql
USE ss04;
IF OBJECT_ID('dbo.resultado') IS NOT NULL AND OBJECTPROPERTY(OBJECT_ID('dbo.resultado'), 'TableTemporalType') = 2
    ALTER TABLE dbo.resultado SET (SYSTEM_VERSIONING = OFF);
DROP TABLE IF EXISTS dbo.resultado, dbo.resultado_historia;
CREATE TABLE dbo.resultado (
    IdItem           int           NOT NULL CONSTRAINT resultado_pk PRIMARY KEY CLUSTERED,
    IdProtocolo      int           NOT NULL,
    CodDeterminacion nvarchar(10)  NOT NULL,
    Valor            nvarchar(50)  NULL,
    -- Quién: la tabla temporal no lo guarda. Lo escribe cada UPDATE, desde el contexto de la sesión.
    ModificadoPor    nvarchar(50)  NOT NULL CONSTRAINT resultado_modificado_por DEFAULT N'carga-legacy',
    ValidoDesde      datetime2(3)  GENERATED ALWAYS AS ROW START NOT NULL,
    ValidoHasta      datetime2(3)  GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (ValidoDesde, ValidoHasta)
) WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.resultado_historia));
INSERT INTO dbo.resultado (IdItem, IdProtocolo, CodDeterminacion, Valor)
SELECT IdItem, IdProtocolo, CodDeterminacion, Valor FROM ALAMEDA.dbo.ResultadoItem
WHERE FechaCarga >= '2026-10-09' AND FechaCarga < '2026-10-10';
SELECT COUNT(*) AS resultados_del_9_de_octubre FROM dbo.resultado;
GO
-- La corrección: Lucía cambia 165 por 156, y Norma la deja como estaba. Cada sesión dice quién es.
EXEC sp_set_session_context @key = N'usuario', @value = N'lucia2';
UPDATE dbo.resultado SET Valor = N'156', ModificadoPor = CAST(SESSION_CONTEXT(N'usuario') AS nvarchar(50)) WHERE IdItem = 12123358;
GO
EXEC sp_set_session_context @key = N'usuario', @value = N'norma';
UPDATE dbo.resultado SET Valor = N'165', ModificadoPor = CAST(SESSION_CONTEXT(N'usuario') AS nvarchar(50)) WHERE IdItem = 12123358;
GO
-- La pregunta de Norma, como consulta: todas las versiones de la fila, sin ninguna tabla que escribir a mano.
SELECT Valor AS decia, ModificadoPor AS lo_escribio, ValidoDesde AS desde, ValidoHasta AS hasta
FROM dbo.resultado FOR SYSTEM_TIME ALL WHERE IdItem = 12123358 ORDER BY ValidoDesde;
-- La tabla de historia la escribe el motor: tiene la versión de la carga y la de Lucía.
SELECT COUNT(*) AS versiones_en_la_historia FROM dbo.resultado_historia;
GO
-- La historia no se toca a mano mientras el versionado está encendido.
UPDATE dbo.resultado_historia SET Valor = N'999' WHERE IdItem = 12123358;
GO
TRUNCATE TABLE dbo.resultado;
GO
