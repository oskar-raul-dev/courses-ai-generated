-- postgres
-- Los documentos, con tipo, país y número, para cada paciente que sobrevivió a la fusión. Lo que el
-- modelo no puede aceptar va a la tabla de rechazos con su regla: el pasaporte sin país, el recién
-- nacido con el documento de otro, y el documento que ya es de otro paciente.
DELETE FROM staging.rejection WHERE phase = '05';

DROP TABLE IF EXISTS staging.document_candidate;
CREATE TABLE staging.document_candidate AS
SELECT c.legacy_patient_id,
       coalesce(p.merged_into_patient_id, p.patient_id) AS patient_id,
       d.document_type,
       CASE WHEN d.document_type = 'PAS' THEN NULL ELSE 'ARG' END AS country,   -- la caja no guardó el país
       CASE d.document_type
           WHEN 'OTRO' THEN substring(l."Nombre" || ' ' || coalesce(l."DNI", '') from '\mOTRO\M\s*(\S+)')
           WHEN 'PAS'  THEN upper(l."DNI")
           ELSE c.document_digits
       END AS number
FROM staging.patient_clean AS c
JOIN legacy."Pacientes" AS l ON l."IdPaciente" = c.legacy_patient_id
JOIN alameda.patient AS p ON p.legacy_patient_id = c.legacy_patient_id
CROSS JOIN LATERAL (
    SELECT CASE WHEN l."Nombre" ~ '^RN ' THEN 'RN'
                WHEN l."Nombre" ~ '\mOTRO\M' OR l."DNI" ~ '^OTRO' THEN 'OTRO'
                WHEN l."DNI" ~ '^[A-Za-z]' THEN 'PAS'
                WHEN l."Nombre" ~ '\mLE\M' THEN 'LE'
                WHEN l."Nombre" ~ '\mLC\M' THEN 'LC'
                WHEN c.document_digits ~ '^[0-9]{7,8}$' THEN 'DNI'
           END AS document_type) AS d
WHERE d.document_type IS NOT NULL;

INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '05', 'pacientes.pasaporte_sin_pais', 'Pacientes', legacy_patient_id::text, number,
       'el pasaporte exige país emisor y la caja no lo guardó'
FROM staging.document_candidate WHERE document_type = 'PAS';

INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '05', 'pacientes.recien_nacido_con_documento_ajeno', 'Pacientes', legacy_patient_id::text, number,
       'RN: el número es de la madre; el recién nacido queda sin documento'
FROM staging.document_candidate WHERE document_type = 'RN' AND number IS NOT NULL;

-- El número que no cumple el formato de su tipo: el CHECK lo rechazaría, así que se rechaza antes.
INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '05', 'pacientes.numero_fuera_de_formato', 'Pacientes', legacy_patient_id::text,
       document_type || ' ' || coalesce(number, ''), 'no cumple identity_document_number_check'
FROM staging.document_candidate
WHERE document_type IN ('LE', 'LC', 'OTRO')
  AND NOT coalesce(CASE document_type WHEN 'OTRO' THEN number <> '' ELSE number ~ '^[0-9]{6,8}$' END, false);
DELETE FROM staging.document_candidate
WHERE document_type IN ('LE', 'LC', 'OTRO')
  AND NOT coalesce(CASE document_type WHEN 'OTRO' THEN number <> '' ELSE number ~ '^[0-9]{6,8}$' END, false);

-- Un documento que aparece en dos pacientes sobrevivientes: se queda con el más antiguo, y los demás
-- se rechazan. Cada rechazo de esta regla es un par que el matcher no fusionó.
WITH ranked AS (
    SELECT d.*, dense_rank() OVER (PARTITION BY document_type, country, number ORDER BY patient_id) AS owner_rank
    FROM staging.document_candidate AS d
    WHERE document_type IN ('DNI', 'LE', 'LC', 'OTRO')
)
INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '05', 'pacientes.documento_de_otro_paciente', 'Pacientes', legacy_patient_id::text,
       document_type || ' ' || number, 'ya es de otro paciente sobreviviente'
FROM ranked WHERE owner_rank > 1;

INSERT INTO alameda.identity_document (patient_id, document_type, country, number)
SELECT DISTINCT ON (document_type, country, number) patient_id, document_type, country, number
FROM staging.document_candidate
WHERE document_type IN ('DNI', 'LE', 'LC', 'OTRO')
ORDER BY document_type, country, number, patient_id;

INSERT INTO staging.rule_baseline (rule, source_rows, truth_rows)
SELECT r.rule, (SELECT count(*) FROM legacy."Pacientes"), t.truth_rows
FROM (VALUES ('pacientes.pasaporte_sin_pais'), ('pacientes.recien_nacido_con_documento_ajeno'),
             ('pacientes.numero_fuera_de_formato'), ('pacientes.documento_de_otro_paciente')) AS r (rule)
LEFT JOIN (VALUES ('pacientes.pasaporte_sin_pais', (SELECT count(*) FROM truth.patient_record
                                                     WHERE 'passport_in_dni' = ANY (dirt))),
                  ('pacientes.recien_nacido_con_documento_ajeno', (SELECT count(*) FROM truth.patient_record
                                                     WHERE 'newborn_mother_dni' = ANY (dirt)
                                                        OR 'newborn_other_dni' = ANY (dirt)))) AS t (rule, truth_rows)
       ON t.rule = r.rule
ON CONFLICT (rule) DO UPDATE SET source_rows = EXCLUDED.source_rows, truth_rows = EXCLUDED.truth_rows;
