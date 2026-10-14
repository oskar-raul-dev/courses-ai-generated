-- Checks the SQL Server features of the track (structure only; nothing here is a performance number).
SET NOCOUNT ON;
SELECT @@VERSION AS version, SERVERPROPERTY('Edition') AS edition;
CREATE DATABASE p8; 
GO
USE p8;
ALTER DATABASE p8 SET READ_COMMITTED_SNAPSHOT ON;
SELECT is_read_committed_snapshot_on, is_query_store_on FROM sys.databases WHERE name = 'p8';
CREATE TABLE doc (id int PRIMARY KEY, body json);
INSERT INTO doc VALUES (1, '{"name":"PEREZ PEDRO"}');
SELECT JSON_VALUE(body, '$.name') AS name FROM doc;
CREATE TABLE patient (id uniqueidentifier DEFAULT NEWSEQUENTIALID() PRIMARY KEY CLUSTERED, full_name nvarchar(100),
  valid_from datetime2 GENERATED ALWAYS AS ROW START, valid_to datetime2 GENERATED ALWAYS AS ROW END,
  PERIOD FOR SYSTEM_TIME (valid_from, valid_to)) WITH (SYSTEM_VERSIONING = ON);
INSERT INTO patient (full_name) VALUES ('PEREZ PEDRO');
SELECT COUNT(*) AS temporal_rows FROM patient FOR SYSTEM_TIME ALL;
GO
USE master; ALTER TABLE p8.dbo.patient SET (SYSTEM_VERSIONING = OFF); DROP DATABASE p8;
