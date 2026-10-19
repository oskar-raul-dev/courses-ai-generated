-- postgres
-- Una fila limpia por fila de legacy."Pacientes": el nombre sin documentos, números, fechas ni obras
-- sociales; el documento que se pueda leer; y la fecha de nacimiento tal como está. Nada se corrige aquí:
-- solo se separa lo que la Fase 04 dejó identificado.
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;
CREATE EXTENSION IF NOT EXISTS unaccent;

CREATE OR REPLACE FUNCTION staging.normalize_name(raw text) RETURNS text
LANGUAGE sql STABLE AS $$
    SELECT btrim(regexp_replace(
             regexp_replace(
               regexp_replace(
                 regexp_replace(upper(unaccent(coalesce(raw, ''))),
                   '\(.*?\)|\m(RN|DNI|LC|LE|OTRO|PASAP|TEL)\M|D\.N\.I\.|\mP [A-Z]{3}\M', ' ', 'g'),
                 '[0-9][0-9./:]*|[A-Z][0-9]{6,}', ' ', 'g'),
               '\m(' || (SELECT string_agg(DISTINCT upper(replace(written_as, '.', '')), '|')
                         FROM staging.payer_alias) || '|SALUD|MEDICAL|IOSFA|OMINT|MEDIFE|PREVENCION)\M', ' ', 'g'),
             '[^A-Z ]+|\s+', ' ', 'g'))
$$;

DROP TABLE IF EXISTS staging.patient_clean;
CREATE TABLE staging.patient_clean AS
SELECT p."IdPaciente" AS legacy_patient_id,
       staging.normalize_name(replace(p."Nombre", '.', '')) AS norm_name,
       p."FechaNac"::date AS birth_date,
       nullif(coalesce(nullif(regexp_replace(coalesce(p."DNI", ''), '[^0-9]', '', 'g'), ''),
                       nullif(regexp_replace(staging.extract_dni_2016(p."Nombre"), '[^0-9]', '', 'g'), '')), '') AS document_digits,
       p."Sexo" AS sex
FROM legacy."Pacientes" AS p;
ALTER TABLE staging.patient_clean ADD CONSTRAINT patient_clean_pkey PRIMARY KEY (legacy_patient_id);
CREATE INDEX patient_clean_birth_date_idx ON staging.patient_clean (birth_date);
CREATE INDEX patient_clean_document_digits_idx ON staging.patient_clean (document_digits);
ANALYZE staging.patient_clean;
