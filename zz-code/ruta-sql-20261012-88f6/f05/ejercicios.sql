\echo == ej4
SELECT n AS nombre, staging.normalize_name(replace(n, '.', '')) AS normalizado
FROM unnest(ARRAY['GONZALEZ MARIA ESTHER DNI 11222333 OSDE 210', 'RN GONZALEZ MARIA DNI 11222333',
                  'LOPEZ JUAN CARLOS (EL HIJO) DNI 30111222', 'SILVA ROSA - PAMI 150123456789/00',
                  'PEÑA LAURA CARMEN OTRO 9242/22']) AS n;
\echo == ej5
SELECT a, b, round(similarity(a, b)::numeric, 2) AS trigramas
FROM (VALUES ('GONZALEZ MARIA ESTHER', 'GONZALEZ MARIA'), ('GIMENEZ ROSA', 'JIMENEZ ROSA'),
             ('OLMOS PAEZ', 'OLMOS RAUL'), ('PEREZ PEDRO', 'PERES PEDRO')) AS t (a, b);
\echo == ej6
BEGIN;
INSERT INTO alameda.identity_document (patient_id, document_type, country, number) VALUES (1, 'DNI', 'ARG', '123456');
ROLLBACK;
BEGIN;
INSERT INTO alameda.identity_document (patient_id, document_type, country, number) VALUES (1, 'PAS', 'ARG', 'A1234567');
ROLLBACK;
BEGIN;
INSERT INTO alameda.identity_document (patient_id, document_type, country, number) VALUES (1, 'PAS', 'BOL', 'A1234567');
ROLLBACK;
\echo == ej17
SELECT count(*) AS rechazos,
       count(*) FILTER (WHERE q.tier = 'automatic') AS ya_fusionados_por_otro_par,
       count(*) FILTER (WHERE q.tier = 'review') AS en_la_cola,
       count(*) FILTER (WHERE q.patient_a IS NULL) AS fuera_de_la_cola
FROM staging.rejection AS j
JOIN alameda.patient AS p ON p.legacy_patient_id = j.source_key::int
JOIN alameda.identity_document AS d ON d.document_type = split_part(j.value, ' ', 1) AND d.country = 'ARG'
                                    AND d.number = split_part(j.value, ' ', 2)
JOIN alameda.patient AS o ON o.patient_id = d.patient_id
LEFT JOIN staging.match_review AS q ON q.patient_a = least(p.legacy_patient_id, o.legacy_patient_id)
                                   AND q.patient_b = greatest(p.legacy_patient_id, o.legacy_patient_id)
WHERE j.rule = 'pacientes.documento_de_otro_paciente';
\echo == ej21
CREATE TEMP TABLE verdad AS SELECT a.legacy_patient_id AS pa, b.legacy_patient_id AS pb FROM truth.patient_record a JOIN truth.patient_record b ON a.person_id = b.person_id AND a.legacy_patient_id < b.legacy_patient_id;
CREATE INDEX ON verdad (pa, pb);
-- el recién nacido (RN APELLIDO1 APELLIDO2), su madre enlazada, y un candidato posterior: misma fecha,
-- empieza con el primer apellido del RN, y no es el RN
WITH rn AS (
    SELECT n.legacy_patient_id AS rn_id, n.birth_date, split_part(n.full_name, ' ', 1) AS surname
    FROM alameda.patient AS n WHERE n.mother_patient_id IS NOT NULL
),
candidate AS (
    SELECT rn.rn_id, c.legacy_patient_id AS later_id
    FROM rn JOIN staging.patient_clean AS c ON c.birth_date = rn.birth_date
                                         AND split_part(c.norm_name, ' ', 1) = rn.surname
                                         AND c.legacy_patient_id <> rn.rn_id
    JOIN legacy."Pacientes" AS l ON l."IdPaciente" = c.legacy_patient_id AND l."Nombre" !~ '^RN '
)
SELECT count(*) AS propuestos,
       count(*) FILTER (WHERE v.pa IS NOT NULL) AS misma_persona,
       count(*) FILTER (WHERE v.pa IS NULL) AS personas_distintas,
       (SELECT count(*) FROM verdad v2 JOIN alameda.patient n ON n.legacy_patient_id IN (v2.pa, v2.pb) AND n.mother_patient_id IS NOT NULL) AS pares_verdaderos_con_rn_enlazado
FROM candidate AS k
LEFT JOIN verdad AS v ON v.pa = least(k.rn_id, k.later_id) AND v.pb = greatest(k.rn_id, k.later_id);
\echo == ej22
BEGIN;
SELECT patient_id, merged_into_patient_id, merged_by FROM alameda.patient WHERE patient_id = (SELECT min(merged_patient_id) FROM alameda.patient_merge);
UPDATE alameda.patient SET merged_into_patient_id = NULL, merged_at = NULL, merged_by = NULL
WHERE patient_id = (SELECT min(merged_patient_id) FROM alameda.patient_merge);
UPDATE alameda.patient SET merged_at = now() WHERE patient_id = (SELECT min(merged_patient_id) FROM alameda.patient_merge);
ROLLBACK;
