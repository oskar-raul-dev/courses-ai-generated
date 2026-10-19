-- sqlserver
-- ss04 · §8. NEWSEQUENTIALID después de reiniciar el servidor. Primera parte: 1.000 filas y el máximo.
--   ../ss01-la-base-en-su-motor-original/sqlcmd.sh < 02_reinicio.sql
--   docker compose -f ../lab/compose.yaml restart sqlserver      (y esperar a que esté healthy)
--   ../ss01-la-base-en-su-motor-original/sqlcmd.sh < 02_reinicio_despues.sql
USE ss04;
DROP TABLE IF EXISTS dbo.seq_restart;
CREATE TABLE dbo.seq_restart (id uniqueidentifier NOT NULL DEFAULT NEWSEQUENTIALID() PRIMARY KEY CLUSTERED,
                              tanda int NOT NULL, creado datetime2(3) NOT NULL DEFAULT sysdatetime());
INSERT INTO dbo.seq_restart (tanda) SELECT TOP (1000) 1 FROM sys.all_objects;
SELECT tanda, COUNT(*) AS filas, MIN(id) AS menor, MAX(id) AS mayor FROM dbo.seq_restart GROUP BY tanda;
GO
-- Y la función, fuera de un DEFAULT:
SELECT NEWSEQUENTIALID() AS sin_default;
GO
