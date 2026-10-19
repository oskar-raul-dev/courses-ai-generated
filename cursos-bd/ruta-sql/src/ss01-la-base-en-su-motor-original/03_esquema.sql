-- sqlserver
-- ss01 · §5.1. Lo que el script de SSMS dejó en ALAMEDA, leído del catálogo. Solo lee.
--   ./sqlcmd.sh < 03_esquema.sql
USE ALAMEDA;
GO
-- La intercalación de la base: decide cómo se comparan y ordenan los textos (CI: sin mayúsculas; AS: con acentos).
SELECT DATABASEPROPERTYEX('ALAMEDA', 'Collation') AS intercalacion,
       (SELECT compatibility_level FROM sys.databases WHERE name = 'ALAMEDA') AS nivel_de_compatibilidad;

-- Cuántas tablas, cuántas con clave primaria, y de esas cuántas agrupadas (clustered): la tabla ES el índice.
-- (T-SQL no acepta un EXISTS dentro de un SUM, Msg 130: se cuenta cada cosa con su subconsulta.)
SELECT (SELECT COUNT(*) FROM sys.tables WHERE schema_id = SCHEMA_ID('dbo')) AS tablas,
       (SELECT COUNT(*) FROM sys.key_constraints WHERE type = 'PK') AS con_pk,
       (SELECT COUNT(*) FROM sys.indexes AS i JOIN sys.tables AS t ON t.object_id = i.object_id
         WHERE i.type = 1) AS agrupadas,
       (SELECT COUNT(*) FROM sys.identity_columns AS c JOIN sys.tables AS t ON t.object_id = c.object_id
         WHERE t.is_ms_shipped = 0) AS con_identity;

-- Las tres columnas IDENTITY de 2011 que se llaman id, ID e Id: con CI, el motor no las distingue.
-- (sys.identity_columns trae también dos tablas internas del motor: se cruza con sys.tables, sin las del sistema.)
SELECT t.name AS tabla, c.name AS columna
FROM sys.identity_columns AS c JOIN sys.tables AS t ON t.object_id = c.object_id
WHERE c.name = N'id' AND t.is_ms_shipped = 0 ORDER BY CASE c.name COLLATE Latin1_General_BIN2
    WHEN N'id' THEN 1 WHEN N'ID' THEN 2 ELSE 3 END, t.name;

-- Las claves foráneas de 2011: WITH NOCHECK y deshabilitadas. El optimizador no puede confiar en ellas.
SELECT name, OBJECT_NAME(parent_object_id) AS tabla, OBJECT_NAME(referenced_object_id) AS referencia,
       is_disabled, is_not_trusted
FROM sys.foreign_keys ORDER BY name;

-- Las columnas de tipos que SQL Server desaconseja desde 2005: image y, en otro sentido, datetime.
SELECT TYPE_NAME(c.user_type_id) AS tipo, COUNT(*) AS columnas
FROM sys.columns AS c JOIN sys.tables AS t ON t.object_id = c.object_id
WHERE TYPE_NAME(c.user_type_id) IN (N'image', N'text', N'ntext', N'datetime', N'money')
GROUP BY TYPE_NAME(c.user_type_id) ORDER BY tipo;
GO
