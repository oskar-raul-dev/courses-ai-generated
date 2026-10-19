-- postgres
-- El EAV de Matías, tal como está, copiado a staging para poder indexarlo (en legacy no se crea nada):
-- una fila por resultado, el valor como texto, la unidad y el rango repetidos.
DROP TABLE IF EXISTS staging.result_eav;
CREATE TABLE staging.result_eav AS
SELECT r."IdItem" AS result_id, r."IdProtocolo" AS lab_order_id, r."CodDeterminacion" AS analyte_code,
       r."Valor" AS value, r."Unidad" AS unit, r."RangoReferencia" AS reference_range, r."Equipo" AS equipment,
       r."FechaCarga" AS recorded_at
FROM legacy."ResultadoItem" AS r
WHERE EXISTS (SELECT 1 FROM alameda.lab_order AS o WHERE o.lab_order_id = r."IdProtocolo");
ALTER TABLE staging.result_eav ADD CONSTRAINT result_eav_pkey PRIMARY KEY (result_id);
CREATE INDEX result_eav_lab_order_id_idx ON staging.result_eav (lab_order_id);
ANALYZE staging.result_eav;
