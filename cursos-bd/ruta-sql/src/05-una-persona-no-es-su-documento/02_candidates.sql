-- postgres
-- Los pares candidatos: solo se comparan filas del mismo bloque (misma fecha de nacimiento, o el mismo
-- documento), y de cada par se guarda la similitud por trigramas del nombre normalizado.
DROP TABLE IF EXISTS staging.match_candidate;
CREATE TABLE staging.match_candidate AS
SELECT a.legacy_patient_id AS patient_a,
       b.legacy_patient_id AS patient_b,
       similarity(a.norm_name, b.norm_name) AS name_similarity,
       a.birth_date = b.birth_date AS same_birth_date,
       a.document_digits = b.document_digits AS same_document
FROM staging.patient_clean AS a
JOIN staging.patient_clean AS b
  ON a.legacy_patient_id < b.legacy_patient_id
 AND (a.birth_date = b.birth_date OR a.document_digits = b.document_digits);
ALTER TABLE staging.match_candidate ADD CONSTRAINT match_candidate_pkey PRIMARY KEY (patient_a, patient_b);
