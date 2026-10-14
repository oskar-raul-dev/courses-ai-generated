-- Mediciones de F05 contra truth (perfil M). Se corre después de los siete scripts del curso.
\timing off
CREATE TEMP TABLE verdad AS SELECT a.legacy_patient_id AS pa, b.legacy_patient_id AS pb FROM truth.patient_record a JOIN truth.patient_record b ON a.person_id = b.person_id AND a.legacy_patient_id < b.legacy_patient_id;
CREATE INDEX ON verdad (pa, pb);
\echo == 1 duplicados según la verdad
SELECT count(*) filas, count(DISTINCT person_id) personas, count(*)-count(DISTINCT person_id) sobrantes, round(100.0*(count(*)-count(DISTINCT person_id))/count(*),1) pct FROM truth.patient_record;
SELECT count(*) pares_verdaderos FROM verdad;
\echo == 2 cobertura del bloqueo
SELECT count(*) FILTER (WHERE ca.birth_date = cb.birth_date) misma_fecha,
       count(*) FILTER (WHERE ca.birth_date = cb.birth_date OR ca.document_digits = cb.document_digits) fecha_o_documento,
       count(*) total
FROM verdad v JOIN staging.patient_clean ca ON ca.legacy_patient_id=v.pa JOIN staging.patient_clean cb ON cb.legacy_patient_id=v.pb;
SELECT count(*) candidatos FROM staging.match_candidate;
\echo == 3 solo trigramas, por umbral
SELECT t umbral, count(*) aceptados, count(*) FILTER (WHERE v.pa IS NULL) falsos,
       round(100.0*count(*) FILTER (WHERE v.pa IS NULL)/nullif(count(*),0),2) pct_falsos,
       round(100.0*count(*) FILTER (WHERE v.pa IS NOT NULL)/(SELECT count(*) FROM verdad),1) exhaustividad
FROM unnest(ARRAY[0.4,0.5,0.6,0.7,0.8]) t JOIN staging.match_candidate c ON c.name_similarity >= t
LEFT JOIN verdad v ON v.pa=c.patient_a AND v.pb=c.patient_b GROUP BY t ORDER BY t;
\echo == 4 regla combinada: (mismo documento y misma fecha) o trigramas >= t
SELECT t umbral, count(*) aceptados, count(*) FILTER (WHERE v.pa IS NULL) falsos,
       round(100.0*count(*) FILTER (WHERE v.pa IS NULL)/nullif(count(*),0),2) pct_falsos,
       round(100.0*count(*) FILTER (WHERE v.pa IS NOT NULL)/(SELECT count(*) FROM verdad),1) exhaustividad
FROM unnest(ARRAY[0.5,0.6,0.7]) t JOIN staging.match_candidate c ON (c.same_document AND c.same_birth_date) OR c.name_similarity >= t
LEFT JOIN verdad v ON v.pa=c.patient_a AND v.pb=c.patient_b GROUP BY t ORDER BY t;
SELECT count(*) doc_y_fecha, count(*) FILTER (WHERE v.pa IS NULL) falsos FROM staging.match_candidate c LEFT JOIN verdad v ON v.pa=c.patient_a AND v.pb=c.patient_b WHERE c.same_document AND c.same_birth_date;
\echo == 5 niveles
SELECT CASE WHEN c.same_document AND c.same_birth_date AND c.name_similarity >= 0.8 THEN '1 automático'
            WHEN (c.same_document AND c.same_birth_date) OR c.name_similarity >= 0.4 THEN '2 revisión humana'
            ELSE '3 descartado' END AS nivel,
       count(*) AS pares, count(*) FILTER (WHERE v.pa IS NOT NULL) AS misma_persona, count(*) FILTER (WHERE v.pa IS NULL) AS personas_distintas
FROM staging.match_candidate c LEFT JOIN verdad v ON v.pa = c.patient_a AND v.pb = c.patient_b GROUP BY 1 ORDER BY 1;
SELECT count(*) pares_verdaderos_fuera_del_bloqueo FROM verdad v WHERE NOT EXISTS (SELECT 1 FROM staging.match_candidate c WHERE c.patient_a=v.pa AND c.patient_b=v.pb);
\echo == 6 fusión contra la verdad
WITH g AS (SELECT coalesce(p.merged_into_patient_id,p.patient_id) grp, r.person_id FROM alameda.patient p JOIN truth.patient_record r ON r.legacy_patient_id=p.legacy_patient_id)
SELECT count(DISTINCT grp) pacientes_vivos, count(DISTINCT person_id) personas,
 (SELECT count(*) FROM (SELECT grp FROM g GROUP BY grp HAVING count(DISTINCT person_id)>1) x) grupos_con_dos_personas FROM g;
SELECT count(*) fusionados, count(*) FILTER (WHERE merged_by IS NOT NULL) con_firma FROM alameda.patient WHERE merged_into_patient_id IS NOT NULL;
\echo == 7 informe
SELECT * FROM staging.rejection_report;
\echo == 8 documento de otro paciente: misma persona o no
WITH j AS (SELECT j.source_key::int lid, split_part(j.value,' ',1) ty, split_part(j.value,' ',2) num FROM staging.rejection j WHERE rule='pacientes.documento_de_otro_paciente'),
o AS (SELECT r1.person_id rechazado, r2.person_id duenio FROM j JOIN alameda.identity_document d ON d.document_type=j.ty AND d.country='ARG' AND d.number=j.num
 JOIN alameda.patient pd ON pd.patient_id=d.patient_id JOIN truth.patient_record r2 ON r2.legacy_patient_id=pd.legacy_patient_id
 JOIN truth.patient_record r1 ON r1.legacy_patient_id=j.lid)
SELECT count(*) total, count(*) FILTER (WHERE rechazado=duenio) misma_persona, count(*) FILTER (WHERE rechazado<>duenio) otra_persona FROM o;
\echo == 9 madres
SELECT count(*) recien_nacidos FROM staging.document_candidate WHERE document_type='RN';
SELECT count(*) enlazados, count(*) FILTER (WHERE rm.person_id = t.mother_person_id) correctos, count(*) FILTER (WHERE rm.person_id IS DISTINCT FROM t.mother_person_id) incorrectos
FROM alameda.patient n JOIN truth.patient_record rn ON rn.legacy_patient_id=n.legacy_patient_id JOIN truth.person t ON t.person_id=rn.person_id
JOIN alameda.patient m ON m.patient_id=n.mother_patient_id JOIN truth.patient_record rm ON rm.legacy_patient_id=m.legacy_patient_id;
\echo == 10 documentos
SELECT document_type, count(*) FROM alameda.identity_document GROUP BY 1 ORDER BY 2 DESC;
SELECT count(*) vivos_sin_documento FROM alameda.patient p WHERE merged_into_patient_id IS NULL AND NOT EXISTS (SELECT 1 FROM alameda.identity_document d WHERE d.patient_id=p.patient_id);
\echo == 11 el DNI como clave
ALTER TABLE staging.patient_clean ADD CONSTRAINT patient_clean_document_digits_key UNIQUE (document_digits);
SELECT count(*) FILTER (WHERE document_digits IS NULL) sin_documento, count(DISTINCT document_digits) documentos, count(*) filas FROM staging.patient_clean;
SELECT count(*) documentos_de_varias_personas, sum(personas) personas_afectadas FROM (
 SELECT c.document_digits, count(DISTINCT r.person_id) personas FROM staging.patient_clean c JOIN truth.patient_record r ON r.legacy_patient_id=c.legacy_patient_id
 WHERE c.document_digits IS NOT NULL GROUP BY 1 HAVING count(DISTINCT r.person_id)>1) x;
WITH d AS (SELECT c.document_digits FROM staging.patient_clean c JOIN truth.patient_record r ON r.legacy_patient_id=c.legacy_patient_id
 WHERE c.document_digits IS NOT NULL GROUP BY 1 HAVING count(DISTINCT r.person_id)>1)
SELECT count(*) FILTER (WHERE EXISTS (SELECT 1 FROM staging.patient_clean c JOIN legacy."Pacientes" p ON p."IdPaciente"=c.legacy_patient_id WHERE c.document_digits=d.document_digits AND p."Nombre" ~ '^RN ')) por_recien_nacido,
       count(*) FILTER (WHERE EXISTS (SELECT 1 FROM staging.patient_clean c JOIN legacy."Pacientes" p ON p."IdPaciente"=c.legacy_patient_id WHERE c.document_digits=d.document_digits AND p."DNI" ~ '^[A-Za-z]')) por_pasaporte_sin_letra
FROM d;
SELECT count(*) personas_con_varios_documentos FROM (
 SELECT r.person_id FROM staging.patient_clean c JOIN truth.patient_record r ON r.legacy_patient_id=c.legacy_patient_id
 WHERE c.document_digits IS NOT NULL GROUP BY 1 HAVING count(DISTINCT c.document_digits)>1) x;
\echo == 12 el LIS
SELECT count(*) filas_lis, count(DISTINCT "ORIGEN_ID") filas_de_origen, count(DISTINCT r.person_id) personas FROM legacy."MIG_LIS_PACIENTES" m JOIN truth.patient_record r ON r.legacy_patient_id=m."ORIGEN_ID";
\echo == 13 la fusión nunca borra
DELETE FROM alameda.patient WHERE patient_id = 1;
