-- sqlserver
-- ss04 · §8. Lo que una tabla temporal no deja hacer, y la hora en que guarda los períodos. Después de 03_temporales.sql.
--   ../ss01-la-base-en-su-motor-original/sqlcmd.sh < 04_temporales_roturas.sql
USE ss04;
GO
-- 1. La historia de antes del versionado: el período no se escribe a mano.
INSERT INTO dbo.resultado (IdItem, IdProtocolo, CodDeterminacion, Valor, ValidoDesde, ValidoHasta)
VALUES (1, 1, N'GLU', N'90', '2019-03-01', '9999-12-31');
GO
-- 2. ¿En qué hora están los períodos? Contra el reloj del servidor, en UTC y en hora local.
SELECT TOP (1) ValidoDesde, SYSUTCDATETIME() AS ahora_utc, SYSDATETIME() AS ahora_servidor,
       SYSDATETIMEOFFSET() AS con_zona FROM dbo.resultado WHERE IdItem = 12123358;
GO
-- 3. "¿Qué decía a tal hora?" con la hora de Córdoba, convertida a la de los períodos (UTC).
DECLARE @local datetime2(3) = (SELECT DATEADD(HOUR, -3, MAX(ValidoDesde)) FROM dbo.resultado FOR SYSTEM_TIME ALL
                               WHERE IdItem = 12123358 AND ModificadoPor = N'lucia2');  -- el momento en que Lucía guardó, en hora de Córdoba
DECLARE @utc datetime2(3) = CAST((@local AT TIME ZONE 'Argentina Standard Time') AT TIME ZONE 'UTC' AS datetime2(3));
SELECT @local AS hora_de_cordoba, @utc AS en_utc,
       (SELECT Valor FROM dbo.resultado FOR SYSTEM_TIME AS OF @local WHERE IdItem = 12123358) AS as_of_con_la_hora_local,
       (SELECT Valor FROM dbo.resultado FOR SYSTEM_TIME AS OF @utc WHERE IdItem = 12123358) AS as_of_en_utc;
GO
-- 4. Borrar la tabla con el versionado encendido.
DROP TABLE dbo.resultado;
GO
