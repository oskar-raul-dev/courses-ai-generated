-- Fase 21 · las extensiones y las tablas de trabajo, en staging (Postgres). Se corre una vez.
-- Los nombres de la caja son en mayúsculas y con los acentos que la recepción tipea o no tipea.

CREATE EXTENSION IF NOT EXISTS unaccent;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS vector;

-- unaccent() no es IMMUTABLE en Postgres, así que un índice sobre ella necesita un envoltorio que lo sea.
CREATE OR REPLACE FUNCTION staging.f21_unaccent(text) RETURNS text
  LANGUAGE sql IMMUTABLE PARALLEL SAFE AS $$ SELECT public.unaccent('public.unaccent', $1) $$;

-- Los pacientes para buscar: el nombre tal como está, sin acentos, en mayúsculas, y el texto de búsqueda en español.
DROP TABLE IF EXISTS staging.patient_name;
CREATE TABLE staging.patient_name AS
SELECT patient_id, full_name,
       staging.f21_unaccent(upper(full_name)) AS name_norm,
       to_tsvector('spanish', staging.f21_unaccent(full_name)) AS name_tsv
FROM alameda.patient
WHERE merged_into_patient_id IS NULL;
ALTER TABLE staging.patient_name ADD PRIMARY KEY (patient_id);
VACUUM ANALYZE staging.patient_name;

SELECT count(*) AS pacientes, count(DISTINCT name_norm) AS nombres_distintos FROM staging.patient_name;
