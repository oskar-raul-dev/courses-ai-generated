-- Fase 15 · las tablas de las carreras, en staging (Postgres).
-- Se corre una vez: psql … -f 01_setup.sql. Cada escenario .race deja estas tablas como las encontró.

-- La planilla de pendientes: una muestra por protocolo EN PROCESO, y la toma de cada técnico.
DROP TABLE IF EXISTS staging.specimen_take, staging.specimen;
CREATE TABLE staging.specimen AS
SELECT "IdProtocolo" AS specimen_id, "Sede"::char(1) AS site_code, "Fecha" AS collected_at
FROM legacy."Protocolos"
WHERE "Estado" = 'EN PROCESO';
ALTER TABLE staging.specimen ADD PRIMARY KEY (specimen_id);
-- Quién la tomó, en la misma fila: lo usa la variante que bloquea la muestra (technicians.py).
ALTER TABLE staging.specimen ADD COLUMN taken_by text;

-- Sin restricción de unicidad a propósito: así estaba la planilla de 2020.
CREATE TABLE staging.specimen_take (
    specimen_id integer NOT NULL REFERENCES staging.specimen,
    technician  text    NOT NULL,
    taken_at    timestamp NOT NULL DEFAULT localtimestamp
);
CREATE INDEX specimen_take_specimen_id_idx ON staging.specimen_take (specimen_id);

-- Los deudores de la caja, con el saldo como número (el de la caja es texto).
DROP TABLE IF EXISTS staging.debtor;
CREATE TABLE staging.debtor AS
SELECT "id" AS debtor_id, "Nombre" AS name,
       replace(replace("Importe", '$ ', ''), ',', '.')::numeric(12,2) AS balance
FROM legacy."Deudores";
ALTER TABLE staging.debtor ADD PRIMARY KEY (debtor_id);

-- El cierre de caja: el lote abierto y los cobros de cada lote (la anomalía de solo lectura).
DROP TABLE IF EXISTS staging.cash_batch, staging.cash_receipt;
CREATE TABLE staging.cash_batch (
    id            integer PRIMARY KEY,
    current_batch integer NOT NULL
);
CREATE TABLE staging.cash_receipt (
    batch  integer       NOT NULL,
    amount numeric(12,2) NOT NULL
);

SELECT (SELECT count(*) FROM staging.specimen) AS specimens,
       (SELECT min(specimen_id) FROM staging.specimen
         WHERE collected_at = (SELECT min(collected_at) FROM staging.specimen)) AS first_free,
       (SELECT count(*) FROM staging.debtor) AS debtors,
       (SELECT balance FROM staging.debtor WHERE debtor_id = 1) AS debtor_1;
