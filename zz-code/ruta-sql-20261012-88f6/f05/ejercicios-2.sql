\echo == ej13
SELECT count(*) AS pasaporte_sin_pais,
       count(*) FILTER (WHERE l."DNI" ~ '^OTRO') AS empiezan_con_otro
FROM legacy."Pacientes" AS l
WHERE l."Nombre" !~ '^RN ' AND l."DNI" ~ '^[A-Za-z]';
SELECT t.document_type, count(*) FROM legacy."Pacientes" AS l JOIN truth.patient_record r ON r.legacy_patient_id = l."IdPaciente" JOIN truth.person t USING (person_id)
WHERE l."Nombre" !~ '^RN ' AND l."DNI" ~ '^[A-Za-z]' GROUP BY 1;
\echo == ej14
SELECT j.value, l."Nombre", staging.extract_dni_2016(l."Nombre") AS parser_2016
FROM staging.rejection AS j JOIN legacy."Pacientes" AS l ON l."IdPaciente" = j.source_key::int
WHERE j.rule = 'pacientes.numero_fuera_de_formato' ORDER BY j.source_key::int;
\echo == ej19
SELECT count(*) AS filas_lis,
       count(DISTINCT coalesce(p.merged_into_patient_id, p.patient_id)) AS pacientes_tras_la_fusion,
       count(DISTINCT r.person_id) AS personas
FROM legacy."MIG_LIS_PACIENTES" AS m
JOIN alameda.patient AS p ON p.legacy_patient_id = m."ORIGEN_ID"
JOIN truth.patient_record AS r ON r.legacy_patient_id = m."ORIGEN_ID";
SELECT count(*) AS grupos_con_dos_personas FROM (
  SELECT coalesce(p.merged_into_patient_id, p.patient_id) FROM legacy."MIG_LIS_PACIENTES" AS m
  JOIN alameda.patient AS p ON p.legacy_patient_id = m."ORIGEN_ID" JOIN truth.patient_record AS r ON r.legacy_patient_id = m."ORIGEN_ID"
  GROUP BY 1 HAVING count(DISTINCT r.person_id) > 1) x;
