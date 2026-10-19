-- postgres
-- El paciente en sexta forma normal: un ancla con la clave y una tabla por atributo, cada una con su
-- propio período de validez. Cada atributo puede cambiar por separado y tener su historia; el costo es
-- un join por atributo, cada uno con un predicado de rango.
DROP TABLE IF EXISTS staging.patient_anchor_name, staging.patient_anchor_birth_date, staging.patient_anchor_sex,
                     staging.patient_anchor;
CREATE TABLE staging.patient_anchor AS SELECT patient_id FROM alameda.patient;
ALTER TABLE staging.patient_anchor ADD CONSTRAINT patient_anchor_pkey PRIMARY KEY (patient_id);

CREATE TABLE staging.patient_anchor_name AS
SELECT patient_id, daterange(p."FechaAlta"::date, NULL) AS valid_during, full_name
FROM alameda.patient JOIN legacy."Pacientes" AS p ON p."IdPaciente" = legacy_patient_id;
CREATE TABLE staging.patient_anchor_birth_date AS
SELECT patient_id, daterange(p."FechaAlta"::date, NULL) AS valid_during, birth_date
FROM alameda.patient JOIN legacy."Pacientes" AS p ON p."IdPaciente" = legacy_patient_id WHERE birth_date IS NOT NULL;
CREATE TABLE staging.patient_anchor_sex AS
SELECT patient_id, daterange(p."FechaAlta"::date, NULL) AS valid_during, sex
FROM alameda.patient JOIN legacy."Pacientes" AS p ON p."IdPaciente" = legacy_patient_id WHERE sex IS NOT NULL;

ALTER TABLE staging.patient_anchor_name
    ADD CONSTRAINT patient_anchor_name_pkey PRIMARY KEY (patient_id, valid_during WITHOUT OVERLAPS);
ALTER TABLE staging.patient_anchor_birth_date
    ADD CONSTRAINT patient_anchor_birth_date_pkey PRIMARY KEY (patient_id, valid_during WITHOUT OVERLAPS);
ALTER TABLE staging.patient_anchor_sex
    ADD CONSTRAINT patient_anchor_sex_pkey PRIMARY KEY (patient_id, valid_during WITHOUT OVERLAPS);
ANALYZE staging.patient_anchor, staging.patient_anchor_name, staging.patient_anchor_birth_date, staging.patient_anchor_sex;
