CREATE TEMP TABLE verdad AS SELECT a.legacy_patient_id AS pa, b.legacy_patient_id AS pb FROM truth.patient_record a JOIN truth.patient_record b ON a.person_id = b.person_id AND a.legacy_patient_id < b.legacy_patient_id;
CREATE INDEX ON verdad (pa, pb);
SELECT n, daitch_mokotoff(n) FROM unnest(ARRAY['GIMENEZ','JIMENEZ','XIMENEZ','VAZQUEZ','BASQUEZ','LLANOS','YANOS']) n;
SELECT count(*) aceptados, count(*) FILTER (WHERE v.pa IS NULL) falsos, round(100.0*count(*) FILTER (WHERE v.pa IS NULL)/count(*),2) pct_falsos,
       round(100.0*count(*) FILTER (WHERE v.pa IS NOT NULL)/47533,1) exhaustividad
FROM staging.match_candidate c JOIN staging.patient_clean a ON a.legacy_patient_id=c.patient_a JOIN staging.patient_clean b ON b.legacy_patient_id=c.patient_b
LEFT JOIN verdad v ON v.pa=c.patient_a AND v.pb=c.patient_b
WHERE c.same_birth_date AND daitch_mokotoff(split_part(a.norm_name,' ',1)) && daitch_mokotoff(split_part(b.norm_name,' ',1));
