-- Fase 20 · el mismo protocolo como documento jsonb, dentro de Postgres (el tercer diseño).
-- Corre después de 01_muestra.sql. Es el mismo documento que 02_cargar_mongo.py carga en Mongo: resultados embebidos,
-- correcciones embebidas en cada resultado. Los índices son los que tiene Mongo, para comparar lo mismo con lo mismo:
-- la clave, el pagador, y la expresión que el cruce y la auditoría leen.

DROP TABLE IF EXISTS staging.f20_doc_jsonb;
DROP TABLE IF EXISTS staging.f20_result_doc;
DROP TABLE IF EXISTS staging.f20_correction_doc;
CREATE INDEX IF NOT EXISTS f20_correction_result ON staging.f20_correction (result_id);

-- Paso 1: cada resultado con sus correcciones, como objeto jsonb.
CREATE TABLE staging.f20_correction_doc AS
SELECT k.result_id,
       jsonb_agg(jsonb_build_object('changed_at', k.changed_at, 'by', k.changed_by,
                                    'old_value', k.old_value, 'reason', k.reason) ORDER BY k.changed_at) AS items
FROM staging.f20_correction k GROUP BY k.result_id;
ALTER TABLE staging.f20_correction_doc ADD PRIMARY KEY (result_id);

-- Paso 2: cada resultado como objeto jsonb, con sus correcciones si las tiene.
CREATE TABLE staging.f20_result_doc AS
SELECT r.lab_order_id, r.result_id,
       jsonb_strip_nulls(jsonb_build_object(
         'result_id', r.result_id, 'analyte', r.analyte_code, 'name', r.analyte_name, 'unit', r.unit,
         'range', r.reference_range, 'value', r.value_numeric, 'qualifier', r.qualifier, 'text', r.value_text,
         'flag', r.sample_flag, 'recorded_at', r.recorded_at, 'corrections', c.items)) AS item
FROM staging.f20_result r
LEFT JOIN staging.f20_correction_doc c ON c.result_id = r.result_id;
CREATE INDEX f20_result_doc_order ON staging.f20_result_doc (lab_order_id, result_id);
ANALYZE staging.f20_result_doc;

-- Paso 3: un documento por protocolo, con sus resultados en orden.
CREATE TABLE staging.f20_doc_jsonb AS
SELECT o.lab_order_id,
       jsonb_build_object(
         'ordered_on', o.ordered_on,
         'site', trim(o.site_code),
         'payer', jsonb_build_object('code', o.payer_code),
         'patient', jsonb_build_object('id', o.patient_id, 'sex', nullif(trim(o.sex), ''), 'birth_date', o.birth_date),
         'results', coalesce(rs.items, '[]'::jsonb)
       ) AS doc
FROM staging.f20_order o
LEFT JOIN (
  SELECT lab_order_id, jsonb_agg(item ORDER BY result_id) AS items
  FROM staging.f20_result_doc GROUP BY lab_order_id
) rs ON rs.lab_order_id = o.lab_order_id;

ALTER TABLE staging.f20_doc_jsonb ADD PRIMARY KEY (lab_order_id);
CREATE INDEX f20_doc_payer ON staging.f20_doc_jsonb ((doc -> 'payer' ->> 'code'));
VACUUM ANALYZE staging.f20_doc_jsonb;
DROP TABLE staging.f20_result_doc;
DROP TABLE staging.f20_correction_doc;

-- Los índices de la forma relacional, para que la comparación sea justa.
CREATE INDEX IF NOT EXISTS f20_order_payer ON staging.f20_order (payer_code, ordered_on);
CREATE INDEX IF NOT EXISTS f20_result_analyte ON staging.f20_result (analyte_code);
VACUUM ANALYZE staging.f20_order;
VACUUM ANALYZE staging.f20_result;

SELECT count(*) AS documentos, pg_size_pretty(pg_relation_size('staging.f20_doc_jsonb')) AS tamaño_tabla,
       round(avg(pg_column_size(doc))) AS bytes_medio_documento
FROM staging.f20_doc_jsonb;
