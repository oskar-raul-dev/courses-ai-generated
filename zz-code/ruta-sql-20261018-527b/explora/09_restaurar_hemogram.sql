-- El formulario de hemograma: una copia de la tabla de 1997–2008, con una versión por fila para la escritura optimista.
DROP TABLE IF EXISTS staging.hemogram;
CREATE TABLE staging.hemogram AS
SELECT "Id" AS hemogram_id, "IdProtocolo" AS lab_order_id, "Fecha" AS taken_on, "Hemoglobina" AS hemoglobin,
       "Hematocrito" AS hematocrit, "GlobRojos" AS red_cells, "GlobBlancos" AS white_cells, "Plaquetas" AS platelets,
       "Obs" AS notes, 1 AS version
FROM legacy."Hemograma";
ALTER TABLE staging.hemogram ADD PRIMARY KEY (hemogram_id);

