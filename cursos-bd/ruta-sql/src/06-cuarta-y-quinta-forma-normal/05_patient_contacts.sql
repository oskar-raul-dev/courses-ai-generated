-- postgres
-- Dos hechos independientes del paciente: sus teléfonos y sus médicos derivantes. Cada uno en su
-- tabla (cuarta forma normal). La tabla combinada, una fila por cada teléfono con cada médico, se
-- arma solo para medir lo que costaría.
DROP TABLE IF EXISTS staging.patient_contact_combined, staging.patient_phone, staging.patient_physician;

CREATE TABLE staging.patient_phone AS
SELECT DISTINCT p."IdPaciente" AS legacy_patient_id, btrim(t.phone) AS phone
FROM legacy."Pacientes" AS p
CROSS JOIN LATERAL string_to_table(p."Telefono", ' / ') AS t (phone)
WHERE btrim(t.phone) <> '';
ALTER TABLE staging.patient_phone ADD CONSTRAINT patient_phone_pkey PRIMARY KEY (legacy_patient_id, phone);

CREATE TABLE staging.patient_physician AS
SELECT DISTINCT "IdPaciente" AS legacy_patient_id, "IdMedico" AS physician_id
FROM legacy."Protocolos"
WHERE "IdPaciente" IS NOT NULL AND "IdMedico" IS NOT NULL;
ALTER TABLE staging.patient_physician ADD CONSTRAINT patient_physician_pkey PRIMARY KEY (legacy_patient_id, physician_id);

CREATE TABLE staging.patient_contact_combined AS
SELECT f.legacy_patient_id, f.phone, m.physician_id
FROM staging.patient_phone AS f
JOIN staging.patient_physician AS m USING (legacy_patient_id);
ALTER TABLE staging.patient_contact_combined
    ADD CONSTRAINT patient_contact_combined_pkey PRIMARY KEY (legacy_patient_id, phone, physician_id);
