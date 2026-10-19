-- postgres
-- Lo facturado desde 2025, con una clave foránea con período hacia los precios: cada práctica tiene que
-- caer dentro de una vigencia de su obra social. La clave se crea NOT VALID, las filas sin precio van
-- a la tabla de rechazos, y entonces se valida, como con los huérfanos de la Fase 04.
DROP TABLE IF EXISTS alameda.billed_practice;
CREATE TABLE alameda.billed_practice (
    legacy_order_practice_id integer PRIMARY KEY,
    payer_code               varchar(20) NOT NULL,
    practice_id              integer NOT NULL,
    billed_during            daterange NOT NULL
);
INSERT INTO alameda.billed_practice
SELECT x."Id", y.payer_code, c.practice_id, daterange(o."Fecha"::date, o."Fecha"::date + 1)
FROM legacy."ProtocoloPracticas" AS x
JOIN legacy."Protocolos" AS o USING ("IdProtocolo")
JOIN alameda.payer AS y ON y.payer_id = o."IdObraSocial"
JOIN alameda.practice_code AS c ON c.nomenclator_code = x."Nomenclador" AND c.code = x."CodigoPractica"
WHERE o."Fecha" >= '2025-01-01';

ALTER TABLE alameda.billed_practice
    ADD CONSTRAINT billed_practice_agreement_price_fkey
    FOREIGN KEY (payer_code, practice_id, PERIOD billed_during)
    REFERENCES alameda.agreement_price (payer_code, practice_id, PERIOD valid_during) NOT VALID;

INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '07', 'facturacion.practica_sin_precio_vigente', 'ProtocoloPracticas', b.legacy_order_practice_id::text,
       b.payer_code || ' ' || b.practice_id || ' ' || lower(b.billed_during), NULL
FROM alameda.billed_practice AS b
WHERE NOT EXISTS (SELECT 1 FROM alameda.agreement_price AS p
                  WHERE p.payer_code = b.payer_code AND p.practice_id = b.practice_id
                    AND p.valid_during @> lower(b.billed_during));
DELETE FROM alameda.billed_practice AS b
WHERE NOT EXISTS (SELECT 1 FROM alameda.agreement_price AS p
                  WHERE p.payer_code = b.payer_code AND p.practice_id = b.practice_id
                    AND p.valid_during @> lower(b.billed_during));
ALTER TABLE alameda.billed_practice VALIDATE CONSTRAINT billed_practice_agreement_price_fkey;

INSERT INTO staging.rule_baseline (rule, source_rows, truth_rows)
SELECT 'facturacion.practica_sin_precio_vigente', count(*), NULL
FROM legacy."ProtocoloPracticas" AS x JOIN legacy."Protocolos" AS o USING ("IdProtocolo")
WHERE o."Fecha" >= '2025-01-01'
ON CONFLICT (rule) DO UPDATE SET source_rows = EXCLUDED.source_rows;
