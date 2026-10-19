USE ss05;
SET QUOTED_IDENTIFIER ON;
SELECT COUNT(*) FROM staging.culture_doc AS c CROSS APPLY OPENJSON(c.antibiogram) AS j;
SELECT COUNT(*) FROM staging.culture_doc WHERE JSON_CONTAINS(antibiogram, 'R', '$.AMPICILINA') = 1 AND JSON_CONTAINS(antibiogram, 'S', '$.GENTAMICINA') = 1;
SELECT TOP (5) r.analyte_code, COUNT(*) FROM alameda.result r GROUP BY r.analyte_code ORDER BY 2 DESC;
GO
