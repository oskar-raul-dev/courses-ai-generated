-- postgres
-- Solución de referencia del boss del Bloque I (D42: no viaja al repositorio público).
-- Sobre el modelo de `lab load --profile m --model`. Todo en una transacción: o la señora queda entera, o nada.
BEGIN;

-- 1. La persona: la ficha del DNI (2009) se fusiona en la de la libreta (1999), con quién y por qué.
INSERT INTO alameda.patient_merge (kept_patient_id, merged_patient_id, reason, merged_by)
VALUES (678, 11073, 'boss I: libreta cívica y DNI con el mismo número 4563218, misma fecha de nacimiento; confirmado por la directora técnica', 'norma');
UPDATE alameda.patient AS p
SET merged_into_patient_id = g.kept_patient_id, merged_at = g.merged_at, merged_by = g.merged_by
FROM alameda.patient_merge AS g
WHERE g.merged_patient_id = p.patient_id AND p.patient_id = 11073;
-- sus dos documentos pasan a la persona que sobrevive: la libreta y el DNI que la reemplazó
UPDATE alameda.identity_document SET patient_id = 678 WHERE patient_id = 11073;

-- 2. El protocolo de la señora cargado sobre la ficha del nieto pasa a ella, y queda registrado.
CREATE TABLE IF NOT EXISTS alameda.lab_order_reassignment (
    lab_order_reassignment_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    lab_order_id    integer NOT NULL REFERENCES alameda.lab_order (lab_order_id),
    from_patient_id integer NOT NULL REFERENCES alameda.patient (patient_id),
    to_patient_id   integer NOT NULL REFERENCES alameda.patient (patient_id),
    reason          text NOT NULL,
    reassigned_by   text NOT NULL,
    reassigned_at   timestamptz NOT NULL DEFAULT now()
);
INSERT INTO alameda.lab_order_reassignment (lab_order_id, from_patient_id, to_patient_id, reason, reassigned_by)
SELECT o.lab_order_id, o.patient_id, 678, 'boss I: control de diabetes (CREA, GLU, HBA1C) de la abuela cargado en la ficha RN del nieto', 'norma'
FROM alameda.lab_order AS o
WHERE o.patient_id = 49860
  AND EXISTS (SELECT 1 FROM alameda.result AS r WHERE r.lab_order_id = o.lab_order_id AND r.analyte_code = 'HBA1C');
UPDATE alameda.lab_order AS o SET patient_id = a.to_patient_id
FROM alameda.lab_order_reassignment AS a WHERE a.lab_order_id = o.lab_order_id AND o.patient_id = 49860;

-- 3. La historia unificada: las tablas anchas hasta marzo de 2008 y el modelo tipado después, con el
-- mismo parser y la ficha que sobrevivió a la fusión.
CREATE OR REPLACE VIEW alameda.patient_result_history AS
WITH parsed_wide AS (
    SELECT o."IdProtocolo" AS lab_order_id, w.analyte_code,
           regexp_replace(btrim(w.value), '^([<>])\s+', '\1') AS v
    FROM legacy."Protocolos" AS o
    JOIN legacy."Quimica" AS q ON q."IdProtocolo" = o."IdProtocolo"
    CROSS JOIN LATERAL (VALUES ('GLU', q."Glucemia"), ('CREA', q."Creatinina"), ('UREA', q."Urea"),
                               ('URIC', q."Uricemia"), ('COL', q."Colesterol")) AS w (analyte_code, value)
    WHERE w.value IS NOT NULL
    UNION ALL
    SELECT o."IdProtocolo", 'HBA1C', regexp_replace(btrim(h."HbA1c"), '^([<>])\s+', '\1')
    FROM legacy."Protocolos" AS o
    JOIN legacy."HemoglobinaGlicosilada" AS h ON h."IdProtocolo" = o."IdProtocolo"
    WHERE h."HbA1c" IS NOT NULL
)
SELECT coalesce(p.merged_into_patient_id, p.patient_id) AS patient_id, o.ordered_on, x.analyte_code,
       x.value_numeric, x.qualifier, x.value_text, x.sample_flag, x.source
FROM (
    SELECT lab_order_id, analyte_code,
           CASE WHEN v ~ '^[<>]?[0-9]+([.,][0-9]+)?$' THEN replace(ltrim(v, '<>'), ',', '.')::numeric END AS value_numeric,
           CASE WHEN v ~ '^[<>]' THEN left(v, 1) END AS qualifier,
           CASE WHEN v IN ('DETECTABLE', 'NO DETECTABLE') THEN v END AS value_text,
           CASE WHEN v IN ('HEMOLIZADA', 'REPETIR', 'MUESTRA INSUFICIENTE') THEN v END AS sample_flag,
           'tabla ancha' AS source
    FROM parsed_wide
    UNION ALL
    SELECT lab_order_id, analyte_code, value_numeric, qualifier, value_text, sample_flag, 'resultado'
    FROM alameda.result
) AS x
JOIN alameda.lab_order AS o ON o.lab_order_id = x.lab_order_id
JOIN alameda.patient AS p ON p.patient_id = o.patient_id;

COMMIT;

-- Lo que se entrega
SELECT p.patient_id, p.full_name, p.merged_into_patient_id, p.merged_by,
       (SELECT string_agg(d.document_type || ' ' || d.number, ', ' ORDER BY d.document_type) FROM alameda.identity_document d WHERE d.patient_id = p.patient_id) documentos
FROM alameda.patient p WHERE p.patient_id IN (678, 11073, 49860) ORDER BY 1;
SELECT * FROM alameda.lab_order_reassignment;
SELECT analyte_code, source, count(*) valores, count(value_numeric) numericos, count(sample_flag) muestras_observadas, min(ordered_on), max(ordered_on)
FROM alameda.patient_result_history WHERE patient_id = 678 AND analyte_code IN ('GLU', 'HBA1C', 'CREA')
GROUP BY 1, 2 ORDER BY 1, 2;
SELECT count(*) resultados_del_nieto_en_la_historia FROM alameda.patient_result_history h WHERE h.patient_id = 678 AND h.analyte_code IN ('HB','HTO','GR','GB','PLAQ');
-- contra la verdad: los protocolos de la persona 200001 son exactamente los de la historia
SELECT (SELECT count(DISTINCT o."IdProtocolo") FROM legacy."Protocolos" o JOIN truth.order_payer t ON t.legacy_protocol_id = o."IdProtocolo" WHERE t.person_id = 200001) segun_la_verdad,
       (SELECT count(*) FROM alameda.lab_order o JOIN alameda.patient p ON p.patient_id = o.patient_id WHERE coalesce(p.merged_into_patient_id, p.patient_id) = 678) en_el_modelo;
