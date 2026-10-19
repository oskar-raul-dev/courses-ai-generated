-- postgres
-- Fase 25 · las 71 tablas anchas de antes de 2008, al modelo tipado. Es una tanda de migración que se
-- puede deshacer: cada resultado nuevo queda anotado en staging.wide_result con la celda de donde vino,
-- y 08_deshacer.sql los borra por esa tabla.
--
-- Antes: el modelo de la Fase 08 (`lab load --model`) y, si ya corriste la Fase 23, su 01_setup.sql.
-- El superusuario no pasa por la seguridad por fila de la Fase 23, así que la carga ve todo.
DELETE FROM staging.rejection WHERE phase = '25';
DROP TABLE IF EXISTS staging.wide_column, staging.wide_cell, staging.wide_result, staging.wide_unmapped;

-- 1. El mapa de columnas. Las 15 tablas de las prácticas de siempre tienen un parámetro por columna, y
--    cada uno ya es un analito del modelo: el mapa se escribe a mano, como lo diría Norma.
CREATE TABLE staging.wide_column (
    source_table  text NOT NULL,
    source_column text NOT NULL,
    analyte_code  varchar(10) NOT NULL,
    typed         boolean NOT NULL,            -- true: el valor es un número del analito; false: texto tal cual
    CONSTRAINT wide_column_pkey PRIMARY KEY (source_table, source_column)
);
INSERT INTO staging.wide_column VALUES
    ('Hemograma', 'Hemoglobina', 'HB', true), ('Hemograma', 'Hematocrito', 'HTO', true),
    ('Hemograma', 'GlobRojos', 'GR', true), ('Hemograma', 'GlobBlancos', 'GB', true),
    ('Hemograma', 'Plaquetas', 'PLAQ', true),
    ('Quimica', 'Glucemia', 'GLU', true), ('Quimica', 'Urea', 'UREA', true), ('Quimica', 'Creatinina', 'CREA', true),
    ('Quimica', 'Uricemia', 'URIC', true), ('Quimica', 'Colesterol', 'COL', true),
    ('Lipidograma', 'ColTotal', 'COL', true), ('Lipidograma', 'HDL', 'HDL', true), ('Lipidograma', 'LDL', 'LDL', true),
    ('Lipidograma', 'Trigliceridos', 'TG', true),
    ('Tiroideo', 'TSH', 'TSH', true), ('Tiroideo', 'T4Libre', 'T4L', true),
    ('Ionograma', 'Sodio', 'NA', true), ('Ionograma', 'Potasio', 'K', true), ('Ionograma', 'Cloro', 'CL', true),
    ('Hepatograma', 'GOT', 'GOT', true), ('Hepatograma', 'GPT', 'GPT', true), ('Hepatograma', 'FAL', 'FAL', true),
    ('Hepatograma', 'BilTotal', 'BT', true),
    ('Coagulograma', 'TiempoProt', 'TP', true), ('Coagulograma', 'KPTT', 'KPTT', true),
    ('Eritrosedimentacion', 'VSG1h', 'VSG', true), ('HemoglobinaGlicosilada', 'HbA1c', 'HBA1C', true),
    ('ProteinaCReactiva', 'PCR', 'PCR', true), ('Ferritina', 'Ferritina', 'FERR', true),
    ('VitaminaB12', 'B12', 'B12', true), ('PSA', 'PSATotal', 'PSA', true),
    ('Calcemia', 'Calcio', 'CA', true), ('Magnesemia', 'Magnesio', 'MG', true);

-- Las otras 56 son los exámenes que Rubén fue sumando de a uno. Su forma no la conoce nadie más que su
-- columna: cada columna pasa a ser un analito nuevo de su práctica (por el nombre de la tabla), y el
-- valor entra como texto, tal cual. Tiparlos es trabajo de bioquímica, no de la migración.
-- Otro1–Otro4 y Obs no son de ningún analito: van a staging.wide_unmapped, enteras y con su origen.
INSERT INTO staging.wide_column
SELECT c.relname, a.attname, 'N' || right(pc.code, 3) || '.' || upper(left(a.attname, 5)), false
FROM pg_class AS c
JOIN pg_attribute AS a ON a.attrelid = c.oid AND a.attnum > 0 AND NOT a.attisdropped
JOIN alameda.practice AS p ON upper(replace(p.description, ' ', '')) = upper(c.relname)
JOIN alameda.practice_code AS pc ON pc.practice_id = p.practice_id AND pc.nomenclator_code = 'NBU2012'
WHERE c.relnamespace = 'legacy'::regnamespace AND c.relkind = 'r'
  AND c.relname NOT IN (SELECT source_table FROM staging.wide_column)
  AND EXISTS (SELECT 1 FROM pg_attribute AS o WHERE o.attrelid = c.oid AND o.attname = 'Obs')
  AND a.attname NOT IN ('Id', 'IdProtocolo', 'Fecha', 'Obs') AND a.attname NOT LIKE 'Otro_';

INSERT INTO alameda.analyte (analyte_code, name, unit, reference_range, practice_id)
SELECT w.analyte_code, w.source_table || ' · ' || w.source_column, NULL, NULL, pc.practice_id
FROM staging.wide_column AS w
JOIN alameda.practice_code AS pc ON pc.nomenclator_code = 'NBU2012' AND pc.code = '660' || substr(w.analyte_code, 2, 3)
WHERE NOT w.typed
ON CONFLICT (analyte_code) DO NOTHING;

-- 2. Las celdas: una fila por (tabla, protocolo, columna) con algo escrito. Vacío y NULL no son un
--    resultado: en la tabla ancha, la columna de la determinación que no se pidió queda vacía.
CREATE TABLE staging.wide_cell (
    source_table  text NOT NULL,
    lab_order_id  integer NOT NULL,
    source_column text NOT NULL,
    raw_value     text NOT NULL,
    recorded_at   timestamp NOT NULL
);
CREATE TABLE staging.wide_unmapped (
    source_table  text NOT NULL,
    lab_order_id  integer NOT NULL,
    source_column text NOT NULL,
    raw_value     text NOT NULL
);
DO $$
DECLARE t text; cols text; extra text;
BEGIN
    FOR t IN SELECT DISTINCT source_table FROM staging.wide_column LOOP
        SELECT string_agg(format('(%L, %I)', source_column, source_column), ', ') INTO cols
        FROM staging.wide_column WHERE source_table = t;
        EXECUTE format($q$INSERT INTO staging.wide_cell
            SELECT %L, w."IdProtocolo", v.col, v.val, w."Fecha"
            FROM legacy.%I AS w CROSS JOIN LATERAL (VALUES %s) AS v (col, val)
            WHERE nullif(btrim(v.val), '') IS NOT NULL$q$, t, t, cols);
        SELECT string_agg(format('(%L, %I)', a.attname, a.attname), ', ') INTO extra
        FROM pg_attribute AS a
        WHERE a.attrelid = format('legacy.%I', t)::regclass AND a.attnum > 0 AND NOT a.attisdropped
          AND (a.attname = 'Obs' OR a.attname LIKE 'Otro_');
        EXECUTE format($q$INSERT INTO staging.wide_unmapped
            SELECT %L, w."IdProtocolo", v.col, v.val
            FROM legacy.%I AS w CROSS JOIN LATERAL (VALUES %s) AS v (col, val)
            WHERE nullif(btrim(v.val), '') IS NOT NULL$q$, t, t, extra);
    END LOOP;
END
$$;

-- 3. Lo que no entra, a la tabla de rechazos con la celda de origen. Tres reglas:
--    el protocolo no existe en el modelo (se borró, Fase 04); el valor de un analito tipado no es un
--    número; y la misma celda dos veces (dos filas del mismo protocolo en una tabla sin clave).
INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '25', 'anchas.protocolo_inexistente', c.source_table, c.lab_order_id || '.' || c.source_column, c.raw_value, NULL
FROM staging.wide_cell AS c
WHERE NOT EXISTS (SELECT 1 FROM alameda.lab_order AS o WHERE o.lab_order_id = c.lab_order_id);

INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '25', 'anchas.valor_no_numerico', c.source_table, c.lab_order_id || '.' || c.source_column, c.raw_value, NULL
FROM staging.wide_cell AS c
JOIN staging.wide_column AS w USING (source_table, source_column)
WHERE w.typed AND btrim(c.raw_value) !~ '^[<>]?\s*[0-9]+([.,][0-9]+)?$'
  AND EXISTS (SELECT 1 FROM alameda.lab_order AS o WHERE o.lab_order_id = c.lab_order_id);

INSERT INTO staging.rejection (phase, rule, source_table, source_key, value, detail)
SELECT '25', 'anchas.celda_repetida', source_table, lab_order_id || '.' || source_column, min(raw_value),
       count(*) || ' filas del mismo protocolo'
FROM staging.wide_cell
GROUP BY source_table, lab_order_id, source_column HAVING count(*) > 1;

-- 4. Los resultados. Las claves nuevas salen de una secuencia propia que empieza en mil millones: mientras
--    legacy viva, el espacio de claves de ResultadoItem es de legacy, y su IDENTITY sigue contando desde
--    el último IdItem. (La primera versión de este script arrancaba justo después del último IdItem, y la
--    convivencia de 05_convivencia.py pisó 3.321 resultados migrados: sección 5.3 de la lección.)
--    El mapa celda → resultado es lo que hace posible reconciliar y deshacer.
CREATE TABLE staging.wide_result (
    result_id     integer PRIMARY KEY,
    source_table  text NOT NULL,
    lab_order_id  integer NOT NULL,
    source_column text NOT NULL,
    CONSTRAINT wide_result_source_key UNIQUE (source_table, lab_order_id, source_column)
);
DROP SEQUENCE IF EXISTS staging.wide_result_id_seq;
CREATE SEQUENCE staging.wide_result_id_seq AS integer;
SELECT setval('staging.wide_result_id_seq', 1000000000, false);

CREATE TEMP TABLE wide_ok AS
SELECT nextval('staging.wide_result_id_seq')::integer AS result_id, c.*, w.analyte_code, w.typed,
       regexp_replace(btrim(c.raw_value), '^([<>])\s+', '\1') AS v
FROM staging.wide_cell AS c
JOIN staging.wide_column AS w USING (source_table, source_column)
WHERE EXISTS (SELECT 1 FROM alameda.lab_order AS o WHERE o.lab_order_id = c.lab_order_id)
  AND (NOT w.typed OR btrim(c.raw_value) ~ '^[<>]?\s*[0-9]+([.,][0-9]+)?$')
  AND (c.source_table, c.lab_order_id, c.source_column) NOT IN (
      SELECT source_table, lab_order_id, source_column FROM staging.wide_cell
      GROUP BY 1, 2, 3 HAVING count(*) > 1);

INSERT INTO alameda.result (result_id, lab_order_id, analyte_code, value_numeric, qualifier, value_text,
                            sample_flag, recorded_at)
SELECT result_id, lab_order_id, analyte_code,
       CASE WHEN typed THEN replace(ltrim(v, '<>'), ',', '.')::numeric END,
       CASE WHEN typed AND v ~ '^[<>]' THEN left(v, 1) END,
       CASE WHEN NOT typed THEN left(v, 50) END,
       NULL, recorded_at
FROM wide_ok;
INSERT INTO staging.wide_result SELECT result_id, source_table, lab_order_id, source_column FROM wide_ok;
ANALYZE alameda.result, staging.wide_cell, staging.wide_result;

-- Lo que quedó, en una línea por destino.
SELECT 'celdas con valor' AS "Destino", count(*) AS "Filas" FROM staging.wide_cell
UNION ALL SELECT 'resultados nuevos', count(*) FROM staging.wide_result
UNION ALL SELECT 'rechazos: ' || rule, count(*) FROM staging.rejection WHERE phase = '25' GROUP BY rule
UNION ALL SELECT 'sin analito (Obs y Otro1–4)', count(*) FROM staging.wide_unmapped
UNION ALL SELECT 'analitos nuevos', count(*) FROM staging.wide_column WHERE NOT typed;
