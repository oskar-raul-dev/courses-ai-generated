-- Fase 15 · las tablas de las carreras, en staging (MySQL).
-- Antes: uv run lab load --profile m --engine mysql --tables Protocolos,Deudores
CREATE DATABASE IF NOT EXISTS staging;

DROP TABLE IF EXISTS staging.specimen_take, staging.specimen;
CREATE TABLE staging.specimen (
    specimen_id  int     NOT NULL PRIMARY KEY,
    site_code    char(1) NOT NULL,
    collected_at datetime NOT NULL
);
INSERT INTO staging.specimen
SELECT IdProtocolo, Sede, Fecha FROM legacy.Protocolos WHERE Estado = 'EN PROCESO';

CREATE TABLE staging.specimen_take (
    specimen_id int          NOT NULL,
    technician  varchar(30)  NOT NULL,
    taken_at    datetime     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY specimen_take_specimen_id_idx (specimen_id),
    FOREIGN KEY (specimen_id) REFERENCES staging.specimen (specimen_id)
);

DROP TABLE IF EXISTS staging.debtor;
CREATE TABLE staging.debtor (
    debtor_id int           NOT NULL PRIMARY KEY,
    name      varchar(255)  NOT NULL,
    balance   decimal(12,2) NOT NULL
);
INSERT INTO staging.debtor
SELECT id, Nombre, CAST(REPLACE(REPLACE(Importe, '$ ', ''), ',', '.') AS decimal(12,2)) FROM legacy.Deudores;

DROP TABLE IF EXISTS staging.cash_batch, staging.cash_receipt;
CREATE TABLE staging.cash_batch (id int NOT NULL PRIMARY KEY, current_batch int NOT NULL);
CREATE TABLE staging.cash_receipt (batch int NOT NULL, amount decimal(12,2) NOT NULL, KEY (batch));

SELECT (SELECT count(*) FROM staging.specimen) AS specimens,
       (SELECT count(*) FROM staging.debtor) AS debtors,
       (SELECT balance FROM staging.debtor WHERE debtor_id = 1) AS debtor_1;
