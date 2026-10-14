CREATE TEMP TABLE verdad AS SELECT a.legacy_patient_id AS pa, b.legacy_patient_id AS pb FROM truth.patient_record a JOIN truth.patient_record b ON a.person_id = b.person_id AND a.legacy_patient_id < b.legacy_patient_id;
CREATE INDEX ON verdad (pa, pb);
CREATE TEMP TABLE f AS
SELECT c.*, v.pa IS NOT NULL AS es_par,
       soundex(split_part(a.norm_name,' ',1)) = soundex(split_part(b.norm_name,' ',1)) AS mismo_soundex_apellido,
       dmetaphone(split_part(a.norm_name,' ',1)) = dmetaphone(split_part(b.norm_name,' ',1)) AS mismo_dmetaphone_apellido,
       dmetaphone(a.norm_name) = dmetaphone(b.norm_name) AS mismo_dmetaphone_nombre,
       levenshtein(a.norm_name, b.norm_name) AS lev
FROM staging.match_candidate c JOIN staging.patient_clean a ON a.legacy_patient_id=c.patient_a JOIN staging.patient_clean b ON b.legacy_patient_id=c.patient_b
LEFT JOIN verdad v ON v.pa=c.patient_a AND v.pb=c.patient_b;
\echo regla | aceptados | falsos | pct_falsos | exhaustividad
SELECT r, count(*) FILTER (WHERE ok), count(*) FILTER (WHERE ok AND NOT es_par),
  round(100.0*count(*) FILTER (WHERE ok AND NOT es_par)/nullif(count(*) FILTER (WHERE ok),0),2),
  round(100.0*count(*) FILTER (WHERE ok AND es_par)/47533,1)
FROM f CROSS JOIN LATERAL (VALUES
 ('combinada 0.6', (same_document AND same_birth_date) OR name_similarity >= 0.6),
 ('misma fecha y dmetaphone del nombre', same_birth_date AND mismo_dmetaphone_nombre),
 ('misma fecha y soundex del apellido', same_birth_date AND mismo_soundex_apellido),
 ('misma fecha y dmetaphone del apellido', same_birth_date AND mismo_dmetaphone_apellido),
 ('combinada 0.6 o (fecha, dmetaphone apellido y trigramas >= 0.4)', (same_document AND same_birth_date) OR name_similarity >= 0.6 OR (same_birth_date AND mismo_dmetaphone_apellido AND name_similarity >= 0.4)),
 ('misma fecha y levenshtein <= 3', same_birth_date AND lev <= 3)
) AS x(r, ok) GROUP BY r ORDER BY r;
