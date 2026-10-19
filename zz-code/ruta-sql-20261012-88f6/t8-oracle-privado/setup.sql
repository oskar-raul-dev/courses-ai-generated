-- PRIVADO · no se publica nada de aquí salvo los mensajes de error. Como SYSTEM en FREEPDB1.
SET ECHO ON
SELECT property_value FROM database_properties WHERE property_name = 'LOCAL_UNDO_ENABLED';
CREATE UNDO TABLESPACE undo_small DATAFILE '/opt/oracle/oradata/FREE/FREEPDB1/undo_small01.dbf' SIZE 2M AUTOEXTEND OFF;
ALTER SYSTEM SET undo_tablespace = undo_small;
ALTER SYSTEM SET undo_retention = 1;
SHOW PARAMETER undo
EXIT
