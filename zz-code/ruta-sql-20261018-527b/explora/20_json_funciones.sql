USE tempdb;
SET QUOTED_IDENTIFIER ON;
DROP TABLE IF EXISTS dbo.jdoc;
CREATE TABLE dbo.jdoc (id int PRIMARY KEY, d json NOT NULL);
INSERT INTO dbo.jdoc VALUES (1, '{"AMPICILINA": "R", "CIPROFLOXACINA": "S"}'), (2, '{"MEROPENEM": "R"}');
SELECT id, JSON_VALUE(d, '$.MEROPENEM') AS mero, DATALENGTH(d) AS bytes, d FROM dbo.jdoc;
GO
SELECT id FROM dbo.jdoc WHERE JSON_CONTAINS(d, 'R', '$.MEROPENEM') = 1;
GO
SELECT JSON_OBJECTAGG(k:v) FROM (VALUES ('A','R'),('B','S')) AS t(k,v);
GO
SELECT JSON_ARRAYAGG(id) FROM dbo.jdoc;
GO
CREATE JSON INDEX jdoc_ji ON dbo.jdoc (d) FOR ('$');
GO
UPDATE dbo.jdoc SET d.modify('$.MEROPENEM', 'S') WHERE id = 2;
SELECT d FROM dbo.jdoc WHERE id = 2;
GO
INSERT INTO dbo.jdoc VALUES (3, '{"MEROPENEM": "R",}');
GO
SELECT d.MEROPENEM FROM dbo.jdoc;
GO
SELECT ISJSON('{"a":1}', OBJECT) AS es_objeto;
GO
DROP TABLE dbo.jdoc;
GO
