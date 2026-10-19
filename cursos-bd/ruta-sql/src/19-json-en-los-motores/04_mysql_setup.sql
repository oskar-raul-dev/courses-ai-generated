-- Fase 19 · el mismo antibiograma en MySQL: la forma larga, el JSON binario y la columna generada indexada.
-- Antes, desde src/lab/, copiar el CSV de la verdad (la caja está montada en /caja) a /tmp del contenedor:
--   docker compose exec mysql cp /caja/m/truth/antibiogram.csv /tmp/
-- y correr esto en la base staging.

DROP TABLE IF EXISTS staging.antibiogram_long;
CREATE TABLE staging.antibiogram_long (
  culture_id   INT NOT NULL,
  person_id    INT NOT NULL,
  culture_date DATE NOT NULL,
  germ         VARCHAR(40) NOT NULL,
  antibiotic   VARCHAR(40) NOT NULL,
  sensitivity  CHAR(1) NOT NULL,
  PRIMARY KEY (culture_id, antibiotic)
) ENGINE=InnoDB;

LOAD DATA INFILE '/tmp/antibiogram.csv' INTO TABLE staging.antibiogram_long
  CHARACTER SET utf8mb4 FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;

-- La forma documental: un JSON binario por cultivo, con el antibiograma como objeto.
DROP TABLE IF EXISTS staging.culture_doc;
CREATE TABLE staging.culture_doc (
  culture_id   INT PRIMARY KEY,
  person_id    INT NOT NULL,
  culture_date DATE NOT NULL,
  germ         VARCHAR(40) NOT NULL,
  antibiogram  JSON NOT NULL
) ENGINE=InnoDB;

INSERT INTO staging.culture_doc (culture_id, person_id, culture_date, germ, antibiogram)
SELECT culture_id, MIN(person_id), MIN(culture_date), MIN(germ),
       JSON_OBJECTAGG(antibiotic, sensitivity)
FROM staging.antibiogram_long
GROUP BY culture_id;

-- Una columna generada sobre la ruta del meropenem, indexada: la vía de acceso para F19 (sección 4 del tema).
ALTER TABLE staging.culture_doc
  ADD COLUMN meropenem CHAR(1) GENERATED ALWAYS AS (JSON_UNQUOTE(JSON_EXTRACT(antibiogram, '$.MEROPENEM'))) VIRTUAL,
  ADD INDEX culture_doc_meropenem (meropenem);

SELECT (SELECT COUNT(*) FROM staging.antibiogram_long) AS long_rows,
       (SELECT COUNT(*) FROM staging.culture_doc)      AS cultures;
