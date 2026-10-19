-- sqlserver
-- ss05 · §5.3 y §5.4. Los antibiogramas de la Fase 19 con el tipo json de SQL Server 2025: la búsqueda por un
-- resultado sin índice, con el índice JSON y con una columna calculada, la corrección de un antibiótico y la
-- validación. Después de 01_modelo.py. Va sin -b: el último lote falla a propósito.
--   ../ss01-la-base-en-su-motor-original/sqlcmd.sh < 04_json.sql
-- Las consultas de búsqueda se miden con lab measure --engine sqlserver (estructura del plan; --private, el resto).
USE ss05;
SET QUOTED_IDENTIFIER ON;          -- los métodos del tipo json lo exigen, y sqlcmd lo trae apagado (a08, E-87)
GO
-- 1. Lo que hay: 60.001 cultivos, un documento cada uno. Las mismas cuentas que la Fase 19.
SELECT COUNT(*) AS cultivos,
       SUM(CASE WHEN JSON_VALUE(antibiogram, '$.MEROPENEM') = 'R' THEN 1 ELSE 0 END) AS meropenem_r,
       SUM(CASE WHEN JSON_VALUE(antibiogram, '$.CIPROFLOXACINA') = 'R' THEN 1 ELSE 0 END) AS ciprofloxacina_r
FROM staging.culture_doc;
GO
-- 2. Las dos formas de la pregunta: JSON_VALUE (el valor en una ruta) y JSON_CONTAINS (2025: ¿contiene este valor?).
SELECT COUNT(*) AS con_json_value FROM staging.culture_doc WHERE JSON_VALUE(antibiogram, '$.MEROPENEM') = 'R';
SELECT COUNT(*) AS con_json_contains FROM staging.culture_doc WHERE JSON_CONTAINS(antibiogram, 'R', '$.MEROPENEM') = 1;
GO
-- 3. El índice JSON de 2025: indexa todas las rutas del documento. Exige clave agrupada (la tiene: culture_id).
DROP INDEX IF EXISTS culture_doc_ji ON staging.culture_doc;
CREATE JSON INDEX culture_doc_ji ON staging.culture_doc (antibiogram) FOR ('$');
SELECT name, type_desc FROM sys.indexes WHERE object_id = OBJECT_ID('staging.culture_doc');
GO
-- 4. La salida clásica, la de antes de 2025: una columna calculada con la ruta, y un índice común sobre ella.
IF COL_LENGTH('staging.culture_doc', 'meropenem') IS NULL
    ALTER TABLE staging.culture_doc ADD meropenem AS CAST(JSON_VALUE(antibiogram, '$.MEROPENEM') AS char(1));
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'culture_doc_meropenem_idx')
    CREATE INDEX culture_doc_meropenem_idx ON staging.culture_doc (meropenem);
GO
-- 5. Corregir un antibiótico de un cultivo: el método modify del tipo json, sin reescribir el documento a mano.
DECLARE @id int = (SELECT MIN(culture_id) FROM staging.culture_doc WHERE JSON_VALUE(antibiogram, '$.MEROPENEM') = 'R');
SELECT @id AS cultivo, JSON_VALUE(antibiogram, '$.MEROPENEM') AS antes FROM staging.culture_doc WHERE culture_id = @id;
UPDATE staging.culture_doc SET antibiogram.modify('$.MEROPENEM', 'I') WHERE culture_id = @id;
SELECT JSON_VALUE(antibiogram, '$.MEROPENEM') AS despues FROM staging.culture_doc WHERE culture_id = @id;
UPDATE staging.culture_doc SET antibiogram.modify('$.MEROPENEM', 'R') WHERE culture_id = @id;
GO
-- 6. Armar el documento desde filas, como jsonb_object_agg en la Fase 19: JSON_OBJECTAGG (2025).
SELECT TOP (1) culture_id, (SELECT JSON_OBJECTAGG(j.[key]:j.[value]) FROM OPENJSON(antibiogram) AS j) AS rearmado
FROM staging.culture_doc ORDER BY culture_id;
GO
-- 7. El tipo valida: un documento roto no entra.
INSERT INTO staging.culture_doc (culture_id, person_id, culture_date, germ, antibiogram)
VALUES (-1, 1, '2026-10-18', N'ESCHERICHIA COLI', '{"MEROPENEM": "R",}');
GO
