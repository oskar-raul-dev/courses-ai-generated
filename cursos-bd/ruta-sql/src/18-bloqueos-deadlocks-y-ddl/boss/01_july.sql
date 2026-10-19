-- 💀 Boss del Bloque III · "Una tarde de julio" · el estado de partida (Postgres). Se corre antes de cada tarde.
-- Requiere 16-el-folio-sin-huecos/01_setup.sql (el organismo simulado, esquema fiscal).

-- La numeración, como la dejó Matías en 2015: una fila por punto de venta y tipo.
DROP TABLE IF EXISTS staging.july_invoice, staging.july_counter;
CREATE TABLE staging.july_counter (point_of_sale integer, kind char(1), last_number integer);
INSERT INTO staging.july_counter
SELECT "PuntoVenta", "TipoComprobante", "Ultimo" FROM legacy."UltimoNumero" WHERE "PuntoVenta" = 1 AND "TipoComprobante" = 'B';
CREATE TABLE staging.july_invoice (
    invoice_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    number     integer,
    cae        char(14),
    till       text NOT NULL
);

-- La planilla de pendientes y la toma, sin restricción, como en 2020.
DROP TABLE IF EXISTS staging.july_hemogram, staging.july_specimen_take, staging.july_specimen;
CREATE TABLE staging.july_specimen AS
SELECT "IdProtocolo" AS specimen_id, "Fecha" AS collected_at, NULL::text AS taken_by
FROM legacy."Protocolos" WHERE "Estado" = 'EN PROCESO';
ALTER TABLE staging.july_specimen ADD PRIMARY KEY (specimen_id);
CREATE TABLE staging.july_specimen_take (
    specimen_id integer NOT NULL REFERENCES staging.july_specimen,
    technician  text    NOT NULL,
    taken_at    timestamp NOT NULL DEFAULT localtimestamp
);

-- Los hemogramas del día: uno por muestra, vacío hasta que el técnico lo carga.
CREATE TABLE staging.july_hemogram (
    specimen_id integer PRIMARY KEY REFERENCES staging.july_specimen,
    hematocrit  varchar(10),
    loaded_by   text,
    version     integer NOT NULL DEFAULT 1
);
INSERT INTO staging.july_hemogram (specimen_id) SELECT specimen_id FROM staging.july_specimen;
