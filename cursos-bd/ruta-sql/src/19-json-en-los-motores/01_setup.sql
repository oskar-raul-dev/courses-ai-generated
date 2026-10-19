-- Fase 19 · los antibiogramas en tres formas, en staging (Postgres). Se corre una vez, después de cargar truth.

-- La forma larga: una fila por germen, antibiótico y sensibilidad, tal como la verdad del generador.
DROP TABLE IF EXISTS staging.antibiogram_long;
CREATE TABLE staging.antibiogram_long AS SELECT * FROM truth.antibiogram;
ALTER TABLE staging.antibiogram_long ADD PRIMARY KEY (culture_id, antibiotic);
VACUUM ANALYZE staging.antibiogram_long;

-- La forma documental: un cultivo, un documento con todos sus antibióticos.
DROP TABLE IF EXISTS staging.culture_doc;
CREATE TABLE staging.culture_doc AS
SELECT culture_id, person_id, culture_date, germ,
       jsonb_object_agg(antibiotic, sensitivity ORDER BY antibiotic) AS antibiogram
FROM truth.antibiogram
GROUP BY culture_id, person_id, culture_date, germ;
ALTER TABLE staging.culture_doc ADD PRIMARY KEY (culture_id);
VACUUM ANALYZE staging.culture_doc;

SELECT (SELECT count(*) FROM staging.antibiogram_long) AS long_rows,
       (SELECT count(*) FROM staging.culture_doc)      AS cultures,
       pg_size_pretty(pg_relation_size('staging.antibiogram_long')) AS long_size,
       pg_size_pretty(pg_relation_size('staging.culture_doc'))      AS doc_size;
