-- postgres
-- El modelo tipado: una fila por resultado, con el número como número, el calificador aparte, el texto
-- de los cualitativos y la bandera de la muestra. Un CHECK dice qué combinaciones existen. La unidad y
-- el rango de referencia son de la determinación (Fase 04), no del resultado.
DROP TABLE IF EXISTS staging.result_document;
DROP TABLE IF EXISTS alameda.result, alameda.analyte;
CREATE TABLE alameda.analyte (
    analyte_code    varchar(10) PRIMARY KEY,
    name            varchar(100) NOT NULL,
    unit            varchar(20),
    reference_range varchar(255),
    practice_id     integer NOT NULL REFERENCES alameda.practice (practice_id)
);
INSERT INTO alameda.analyte
SELECT d."CodDeterminacion", d."Nombre", d."Unidad", d."RangoReferencia", c.practice_id
FROM legacy."Determinaciones" AS d
JOIN alameda.practice_code AS c ON c.nomenclator_code = 'NBU2012' AND c.code = d."CodPractica";

CREATE TABLE alameda.result (
    result_id     integer PRIMARY KEY,                  -- el IdItem de la caja
    lab_order_id  integer NOT NULL REFERENCES alameda.lab_order (lab_order_id),
    analyte_code  varchar(10) NOT NULL REFERENCES alameda.analyte (analyte_code),
    value_numeric numeric(14, 4),
    qualifier     char(1),
    value_text    varchar(50),
    sample_flag   varchar(30),
    recorded_at   timestamp NOT NULL,
    CONSTRAINT result_qualifier_check CHECK (qualifier IN ('<', '>')),
    CONSTRAINT result_sample_flag_check CHECK (sample_flag IN ('HEMOLIZADA', 'REPETIR', 'MUESTRA INSUFICIENTE')),
    -- un resultado es un número (con o sin calificador), un texto, una muestra observada o nada
    CONSTRAINT result_value_check CHECK (
        (qualifier IS NULL OR value_numeric IS NOT NULL)
        AND num_nonnulls(value_numeric, value_text, sample_flag) <= 1)
);

-- El parser del valor: lo que la caja escribió, en las columnas que corresponden. Los resultados de
-- protocolos borrados (Fase 04) no entran: no tienen protocolo al que apuntar.
INSERT INTO alameda.result (result_id, lab_order_id, analyte_code, value_numeric, qualifier, value_text,
                            sample_flag, recorded_at)
SELECT r."IdItem", r."IdProtocolo", r."CodDeterminacion",
       CASE WHEN v ~ '^[<>]?[0-9]+([.,][0-9]+)?$' THEN replace(ltrim(v, '<>'), ',', '.')::numeric END,
       CASE WHEN v ~ '^[<>]' THEN left(v, 1) END,
       CASE WHEN v IN ('DETECTABLE', 'NO DETECTABLE') THEN v END,
       CASE WHEN v IN ('HEMOLIZADA', 'REPETIR', 'MUESTRA INSUFICIENTE') THEN v END,
       r."FechaCarga"
FROM legacy."ResultadoItem" AS r
CROSS JOIN LATERAL (SELECT regexp_replace(btrim(r."Valor"), '^([<>])\s+', '\1') AS v) AS x  -- '< 0,5' es '<0,5'
WHERE EXISTS (SELECT 1 FROM alameda.lab_order AS o WHERE o.lab_order_id = r."IdProtocolo");
CREATE INDEX result_lab_order_id_idx ON alameda.result (lab_order_id);
ANALYZE alameda.result;
