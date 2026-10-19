-- postgres
-- Los tipos de índice de la fase, sobre una copia de los resultados de 2024 y 2025 ordenada por fecha de
-- carga (como crece una tabla que solo recibe filas nuevas) y sobre la copia del EAV de la Fase 08.
DROP TABLE IF EXISTS staging.result_recent;
CREATE TABLE staging.result_recent AS
SELECT * FROM alameda.result WHERE recorded_at >= '2024-01-01' AND recorded_at < '2026-01-01' ORDER BY recorded_at, result_id;
ALTER TABLE staging.result_recent ADD PRIMARY KEY (result_id);

-- el orden de las columnas en un compuesto
CREATE INDEX result_recent_analyte_code_recorded_at_idx ON staging.result_recent (analyte_code, recorded_at);
CREATE INDEX result_recent_recorded_at_analyte_code_idx ON staging.result_recent (recorded_at, analyte_code);
-- parcial: solo las glucemias, con su valor
CREATE INDEX result_recent_glu_value_idx ON staging.result_recent (value_numeric) WHERE analyte_code = 'GLU';
-- BRIN sobre la fecha de una tabla que solo crece
CREATE INDEX result_recent_recorded_at_brin ON staging.result_recent USING brin (recorded_at);
-- INCLUDE: el protocolo con el valor, para no ir a la tabla
CREATE INDEX result_recent_lab_order_id_incl_idx ON staging.result_recent (lab_order_id) INCLUDE (analyte_code, value_numeric);
VACUUM ANALYZE staging.result_recent;

-- de expresión, sobre el EAV: el valor ya convertido, solo para las glucemias
CREATE INDEX IF NOT EXISTS result_eav_glu_parsed_idx ON staging.result_eav
    ((CASE WHEN value ~ '^[0-9]+([.,][0-9]+)?$' THEN replace(value, ',', '.')::numeric END))
    WHERE analyte_code = 'GLU';
ANALYZE staging.result_eav;

-- GIN con trigramas sobre el nombre normalizado de la Fase 05
CREATE INDEX IF NOT EXISTS patient_clean_norm_name_trgm_idx ON staging.patient_clean USING gin (norm_name gin_trgm_ops);
ANALYZE staging.patient_clean;
