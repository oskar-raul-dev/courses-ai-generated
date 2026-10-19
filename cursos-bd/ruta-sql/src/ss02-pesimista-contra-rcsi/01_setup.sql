-- sqlserver
-- ss02 · las tablas de las carreras, en una base aparte (ss02), copiadas de ALAMEDA. Se corre una vez:
--   ../ss01-la-base-en-su-motor-original/sqlcmd.sh -b < 01_setup.sql
-- Aparte, porque las carreras encienden y apagan READ_COMMITTED_SNAPSHOT y ALLOW_SNAPSHOT_ISOLATION, que son
-- opciones de toda la base, y ALAMEDA tiene que quedar como la dejó el script de SSMS.
IF DB_ID('ss02') IS NOT NULL BEGIN ALTER DATABASE ss02 SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE ss02; END;
CREATE DATABASE ss02;
GO
USE ss02;
GO
-- El formulario de hemograma (Fase 18): la tabla de 1997–2008, con una versión por fila para la escritura optimista.
SELECT Id AS hemogram_id, IdProtocolo AS lab_order_id, Fecha AS taken_on, Hemoglobina AS hemoglobin,
       Hematocrito AS hematocrit, Obs AS notes, 1 AS version
INTO dbo.hemogram FROM ALAMEDA.dbo.Hemograma;
ALTER TABLE dbo.hemogram ALTER COLUMN hemogram_id int NOT NULL;
ALTER TABLE dbo.hemogram ADD CONSTRAINT hemogram_pk PRIMARY KEY (hemogram_id);

-- La planilla de pendientes (Fase 15): una muestra por protocolo EN PROCESO, y la toma de cada técnico.
SELECT IdProtocolo AS specimen_id, CAST(Sede AS char(1)) AS site_code, Fecha AS collected_at
INTO dbo.specimen FROM ALAMEDA.dbo.Protocolos WHERE Estado = N'EN PROCESO';
ALTER TABLE dbo.specimen ADD CONSTRAINT specimen_pk PRIMARY KEY (specimen_id);
-- Sin restricción de unicidad a propósito: así estaba la planilla de 2020.
CREATE TABLE dbo.specimen_take (
    specimen_id int          NOT NULL REFERENCES dbo.specimen,
    technician  nvarchar(20) NOT NULL,
    taken_at    datetime2(3) NOT NULL DEFAULT sysdatetime()
);
CREATE INDEX specimen_take_specimen_id_idx ON dbo.specimen_take (specimen_id);

-- Los deudores de la caja, con el saldo como número (el de la caja es texto).
SELECT id AS debtor_id, Nombre AS name,
       CAST(REPLACE(REPLACE(Importe, N'$ ', N''), N',', N'.') AS decimal(12, 2)) AS balance
INTO dbo.debtor FROM ALAMEDA.dbo.Deudores;
ALTER TABLE dbo.debtor ALTER COLUMN debtor_id int NOT NULL;
ALTER TABLE dbo.debtor ADD CONSTRAINT debtor_pk PRIMARY KEY (debtor_id);
GO
SELECT (SELECT COUNT(*) FROM dbo.hemogram) AS hemograms, (SELECT MIN(hemogram_id) FROM dbo.hemogram) AS first_hemogram,
       (SELECT COUNT(*) FROM dbo.specimen) AS specimens, (SELECT COUNT(*) FROM dbo.debtor) AS debtors,
       (SELECT is_read_committed_snapshot_on FROM sys.databases WHERE name = 'ss02') AS rcsi,
       (SELECT snapshot_isolation_state_desc FROM sys.databases WHERE name = 'ss02') AS snapshot_isolation;
GO
