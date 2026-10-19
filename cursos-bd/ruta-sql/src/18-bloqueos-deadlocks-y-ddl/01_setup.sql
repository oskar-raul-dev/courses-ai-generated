-- Fase 18 · las tablas de los bloqueos, en staging (Postgres). Se corre una vez.

-- El formulario de hemograma: una copia de la tabla de 1997–2008, con una versión por fila para la escritura optimista.
DROP TABLE IF EXISTS staging.hemogram;
CREATE TABLE staging.hemogram AS
SELECT "Id" AS hemogram_id, "IdProtocolo" AS lab_order_id, "Fecha" AS taken_on, "Hemoglobina" AS hemoglobin,
       "Hematocrito" AS hematocrit, "GlobRojos" AS red_cells, "GlobBlancos" AS white_cells, "Plaquetas" AS platelets,
       "Obs" AS notes, 1 AS version
FROM legacy."Hemograma";
ALTER TABLE staging.hemogram ADD PRIMARY KEY (hemogram_id);

-- La tabla del ALTER de las diez de la mañana: una copia de los resultados, para no tocar el modelo.
DROP TABLE IF EXISTS staging.result_ddl;
CREATE TABLE staging.result_ddl AS SELECT * FROM alameda.result;
ALTER TABLE staging.result_ddl ADD PRIMARY KEY (result_id);
VACUUM ANALYZE staging.result_ddl;

SELECT (SELECT count(*) FROM staging.hemogram) AS hemograms,
       (SELECT min(hemogram_id) FROM staging.hemogram) AS first_hemogram,
       pg_size_pretty(pg_relation_size('staging.result_ddl')) AS result_ddl;
