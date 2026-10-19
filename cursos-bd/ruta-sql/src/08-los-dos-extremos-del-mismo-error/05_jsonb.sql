-- postgres
-- El documento: una fila por protocolo y sus resultados en jsonb, con el número como número JSON cuando
-- lo es y el texto como texto. Es la propuesta de Florencia aplicada al resultado.
DROP TABLE IF EXISTS staging.result_document;
CREATE TABLE staging.result_document AS
SELECT lab_order_id,
       jsonb_object_agg(lower(analyte_code),
                        CASE WHEN value_numeric IS NOT NULL AND qualifier IS NULL THEN to_jsonb(value_numeric)
                             ELSE to_jsonb(coalesce(qualifier || value_numeric::text, value_text, sample_flag)) END) AS results
FROM alameda.result
GROUP BY lab_order_id;
ALTER TABLE staging.result_document ADD CONSTRAINT result_document_pkey PRIMARY KEY (lab_order_id);
ANALYZE staging.result_document;
