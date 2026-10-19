-- sqlserver
-- ss02 · §5.3. Las dos opciones de versiones de filas, que son de la base y vienen apagadas.
--   ../ss01-la-base-en-su-motor-original/sqlcmd.sh < 02_snapshot.sql
-- READ_COMMITTED_SNAPSHOT cambia lo que significa READ COMMITTED (cada sentencia lee lo último confirmado);
-- ALLOW_SNAPSHOT_ISOLATION habilita un nivel más, SNAPSHOT (toda la transacción lee la foto de su inicio).
SELECT name, is_read_committed_snapshot_on, snapshot_isolation_state_desc, is_accelerated_database_recovery_on
FROM sys.databases WHERE name = 'ss02';
GO
ALTER DATABASE ss02 SET ALLOW_SNAPSHOT_ISOLATION ON;
GO
SELECT name, is_read_committed_snapshot_on, snapshot_isolation_state_desc, is_accelerated_database_recovery_on
FROM sys.databases WHERE name = 'ss02';
GO
