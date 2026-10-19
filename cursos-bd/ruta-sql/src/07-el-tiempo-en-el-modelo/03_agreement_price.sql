-- postgres
-- Los precios por obra social desde 2025. La tabla de Matías guarda solo VigenciaDesde: el fin de cada
-- vigencia es el comienzo de la siguiente, y aquí se calcula. Dos vigencias del mismo día para la
-- misma práctica y obra social no dicen cuál vale; las dos van a la tabla de rechazos, y ese período
-- queda sin precio, que es lo que de verdad se sabe.
DROP TABLE IF EXISTS alameda.agreement_price CASCADE;
CREATE TABLE alameda.agreement_price (
    payer_code   varchar(20) NOT NULL REFERENCES alameda.payer (payer_code),
    practice_id  integer NOT NULL REFERENCES alameda.practice (practice_id),
    valid_during daterange NOT NULL,
    amount       numeric(19, 4) NOT NULL,
    CONSTRAINT agreement_price_pkey PRIMARY KEY (payer_code, practice_id, valid_during WITHOUT OVERLAPS)
);

DROP TABLE IF EXISTS staging.price_2025;
CREATE TABLE staging.price_2025 AS
SELECT x."Id" AS legacy_price_id, y.payer_code, c.practice_id, x."VigenciaDesde"::date AS valid_from,
       lead(x."VigenciaDesde"::date) OVER w AS valid_to, x."Valor" AS amount,
       count(*) OVER (PARTITION BY x."IdObraSocial", x."CodPractica", x."VigenciaDesde") AS same_day
FROM legacy."Precios" AS x
JOIN alameda.payer AS y ON y.payer_id = x."IdObraSocial"
JOIN alameda.practice_code AS c ON c.nomenclator_code = 'NBU2012' AND c.code = x."CodPractica"
WINDOW w AS (PARTITION BY x."IdObraSocial", x."CodPractica" ORDER BY x."VigenciaDesde", x."Id");

INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '07', 'precios.vigencia_duplicada', 'Precios', legacy_price_id::text, amount::text,
       'otra vigencia de ' || payer_code || ' para la misma práctica empieza el ' || valid_from
FROM staging.price_2025 WHERE same_day > 1;

-- El fin de la vigencia anterior a un día duplicado es ese día; el día queda sin precio hasta la
-- vigencia siguiente a las duplicadas.
INSERT INTO alameda.agreement_price (payer_code, practice_id, valid_during, amount)
SELECT payer_code, practice_id, daterange(valid_from, valid_to), amount
FROM staging.price_2025 WHERE same_day = 1;

INSERT INTO staging.rule_baseline (rule, source_rows, truth_rows)
VALUES ('precios.vigencia_duplicada', (SELECT count(*) FROM legacy."Precios"), NULL)
ON CONFLICT (rule) DO UPDATE SET source_rows = EXCLUDED.source_rows;
