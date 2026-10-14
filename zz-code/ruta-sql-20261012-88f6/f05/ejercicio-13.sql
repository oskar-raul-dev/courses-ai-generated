-- la primera versión: OTRO solo se buscaba en el nombre
SELECT count(*) AS pasaporte_sin_pais, count(*) FILTER (WHERE t.document_type = 'OTRO') AS no_son_pasaportes
FROM legacy."Pacientes" AS l
JOIN truth.patient_record AS r ON r.legacy_patient_id = l."IdPaciente" JOIN truth.person AS t USING (person_id)
WHERE l."Nombre" !~ '^RN ' AND l."Nombre" !~ '\mOTRO\M' AND l."DNI" ~ '^[A-Za-z]';
SELECT l."Nombre", l."DNI" FROM legacy."Pacientes" AS l
WHERE l."Nombre" !~ '^RN ' AND l."Nombre" !~ '\mOTRO\M' AND l."DNI" ~ '^OTRO' ORDER BY l."IdPaciente" LIMIT 3;
