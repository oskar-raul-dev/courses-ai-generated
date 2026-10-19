-- Fase 16 · el folio sin huecos: el registro del organismo, el contador y los comprobantes (Postgres).
-- Se corre una vez: psql … -f 01_setup.sql. Los scripts de la fase vuelven todo a este punto.

-- Lo que sabe el organismo recaudador: cada comprobante autorizado, por punto de venta y tipo.
-- Es "la base de AFIP" del simulador (fiscal.py): la caja no la toca, solo la consulta por el servicio.
CREATE SCHEMA IF NOT EXISTS fiscal;
DROP TABLE IF EXISTS fiscal.authorized;
CREATE TABLE fiscal.authorized (
    point_of_sale integer     NOT NULL,
    kind          char(1)     NOT NULL,
    number        integer     NOT NULL,
    cae           char(14)    NOT NULL,
    authorized_at timestamptz NOT NULL DEFAULT now(),
    PRIMARY KEY (point_of_sale, kind, number)
);
-- El punto de partida: el último autorizado de cada punto de venta, según la caja.
DROP TABLE IF EXISTS fiscal.start;
CREATE TABLE fiscal.start AS
SELECT "PuntoVenta" AS point_of_sale, "TipoComprobante"::char(1) AS kind, max("Numero") AS last_number
FROM legacy."Comprobantes" GROUP BY 1, 2;

-- El contador de la caja (la tabla UltimoNumero, con nombres del curso) y los comprobantes.
DROP TABLE IF EXISTS staging.invoice, staging.invoice_counter;
CREATE TABLE staging.invoice_counter (
    point_of_sale integer NOT NULL,
    kind          char(1) NOT NULL,
    last_number   integer NOT NULL,
    PRIMARY KEY (point_of_sale, kind)
);
CREATE TABLE staging.invoice (
    invoice_id    integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    point_of_sale integer NOT NULL,
    kind          char(1) NOT NULL,
    number        integer,               -- NULL hasta que se autoriza (el diseño de la sección 5.5)
    cae           char(14),
    till          text    NOT NULL,      -- qué caja lo emitió
    created_at    timestamptz NOT NULL DEFAULT now()
);
-- La secuencia, para la sección 5.2.
DROP SEQUENCE IF EXISTS staging.invoice_number_seq;
CREATE SEQUENCE staging.invoice_number_seq;

SELECT * FROM fiscal.start ORDER BY 1, 2;
SELECT * FROM legacy."UltimoNumero" ORDER BY 1, 2;
