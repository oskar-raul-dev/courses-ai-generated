-- postgres
-- El modelo de identidad. Un paciente es una fila con clave sustituta; sus documentos son otra tabla,
-- con tipo, país y número; "sin documento" es no tener filas en ella. Un paciente fusionado no se borra:
-- queda apuntando al que lo absorbió, con quién y cuándo.
CREATE SCHEMA IF NOT EXISTS alameda;
DROP TABLE IF EXISTS alameda.patient_merge;
DROP TABLE IF EXISTS alameda.identity_document;
-- CASCADE: las fases siguientes apuntan a alameda.patient (F07, F08), y sus scripts las vuelven a crear.
DROP TABLE IF EXISTS alameda.patient CASCADE;

CREATE TABLE alameda.patient (
    patient_id             integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    legacy_patient_id      integer NOT NULL,
    full_name              varchar(255) NOT NULL,
    birth_date             date,
    sex                    char(1),
    mother_patient_id      integer REFERENCES alameda.patient (patient_id),
    merged_into_patient_id integer REFERENCES alameda.patient (patient_id),
    merged_at              timestamptz,
    merged_by              text,
    CONSTRAINT patient_legacy_patient_id_key UNIQUE (legacy_patient_id),
    CONSTRAINT patient_sex_check CHECK (sex IN ('F', 'M')),
    CONSTRAINT patient_mother_patient_id_check CHECK (mother_patient_id <> patient_id),
    CONSTRAINT patient_merged_into_patient_id_check CHECK (merged_into_patient_id <> patient_id),
    CONSTRAINT patient_merged_check CHECK ((merged_into_patient_id IS NULL) = (merged_at IS NULL)
                                           AND (merged_at IS NULL) = (merged_by IS NULL))
);

-- La fusión nunca borra: un DELETE sobre un paciente es un error, no una opción.
CREATE OR REPLACE FUNCTION alameda.patient_forbid_delete() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'a patient is never deleted: merge % into another patient instead', OLD.patient_id;
END
$$;
CREATE TRIGGER patient_forbid_delete BEFORE DELETE ON alameda.patient
    FOR EACH ROW EXECUTE FUNCTION alameda.patient_forbid_delete();

CREATE TABLE alameda.identity_document (
    identity_document_id integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    patient_id           integer NOT NULL REFERENCES alameda.patient (patient_id),
    document_type        varchar(4) NOT NULL,
    country              char(3) NOT NULL,         -- ISO 3166-1 alfa-3 del emisor
    number               varchar(20) NOT NULL,
    valid_to             date,                     -- NULL: vigente
    CONSTRAINT identity_document_type_check CHECK (document_type IN ('DNI', 'LE', 'LC', 'PAS', 'OTRO')),
    -- El formato depende del tipo: los documentos argentinos son números de siete u ocho cifras; el
    -- pasaporte es extranjero y alfanumérico; OTRO solo exige no estar vacío.
    CONSTRAINT identity_document_number_check CHECK (
        CASE document_type
            WHEN 'DNI' THEN country = 'ARG' AND number ~ '^[0-9]{7,8}$'
            WHEN 'LE'  THEN country = 'ARG' AND number ~ '^[0-9]{6,8}$'
            WHEN 'LC'  THEN country = 'ARG' AND number ~ '^[0-9]{6,8}$'
            WHEN 'PAS' THEN country <> 'ARG' AND number ~ '^[A-Z0-9]{6,12}$'
            ELSE number <> ''
        END),
    CONSTRAINT identity_document_type_country_number_key UNIQUE (document_type, country, number)
);
-- Un paciente tiene a lo sumo un documento vigente de cada tipo; los vencidos no cuentan.
CREATE UNIQUE INDEX identity_document_current_key ON alameda.identity_document (patient_id, document_type)
    WHERE valid_to IS NULL;

CREATE TABLE alameda.patient_merge (
    patient_merge_id  integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    kept_patient_id   integer NOT NULL REFERENCES alameda.patient (patient_id),
    merged_patient_id integer NOT NULL REFERENCES alameda.patient (patient_id),
    reason            text NOT NULL,
    merged_by         text NOT NULL,
    merged_at         timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT patient_merge_merged_patient_id_key UNIQUE (merged_patient_id)
);

-- Una fila por fila de legacy: al principio, nadie es la misma persona que nadie.
INSERT INTO alameda.patient (legacy_patient_id, full_name, birth_date, sex)
SELECT c.legacy_patient_id, c.norm_name,
       CASE WHEN c.birth_date <= p."FechaAlta"::date THEN c.birth_date END,
       nullif(c.sex, '')
FROM staging.patient_clean AS c
JOIN legacy."Pacientes" AS p ON p."IdPaciente" = c.legacy_patient_id
ORDER BY c.legacy_patient_id;
ANALYZE alameda.patient;
