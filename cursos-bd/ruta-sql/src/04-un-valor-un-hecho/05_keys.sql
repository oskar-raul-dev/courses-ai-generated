-- postgres
-- La rotura del bloque: una clave foránea entre los resultados y los protocolos de la caja. Se arma
-- sobre copias en staging, con solo las columnas de la relación; legacy no se toca.
DROP TABLE IF EXISTS staging.result_item;
DROP TABLE IF EXISTS staging.lab_order;

CREATE TABLE staging.lab_order AS
SELECT "IdProtocolo" AS lab_order_id FROM legacy."Protocolos";
ALTER TABLE staging.lab_order ADD CONSTRAINT lab_order_pkey PRIMARY KEY (lab_order_id);

CREATE TABLE staging.result_item AS
SELECT "IdItem" AS result_item_id, "IdProtocolo" AS lab_order_id FROM legacy."ResultadoItem";
ALTER TABLE staging.result_item ADD CONSTRAINT result_item_pkey PRIMARY KEY (result_item_id);
