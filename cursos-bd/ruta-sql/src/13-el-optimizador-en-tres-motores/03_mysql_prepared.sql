-- mysql
-- MySQL no guarda planes: una sentencia preparada se optimiza de nuevo en cada EXECUTE, con el valor del
-- parámetro. EXPLAIN se puede preparar, y así se ve la estimación de cada ejecución. Se corre con el cliente
-- mysql después de las fases 09 a 11, que dejan staging.protocolos_en_orden con su índice (Sede, Fecha).
SET @q = 'EXPLAIN FORMAT=TREE SELECT count(*) FROM staging.protocolos_en_orden WHERE Sede = ? AND Fecha >= ''2026-09-01''';
PREPARE by_site FROM @q;
SET @site = 'C'; EXECUTE by_site USING @site;
SET @site = 'V'; EXECUTE by_site USING @site;
SET @site = 'E'; EXECUTE by_site USING @site;
DEALLOCATE PREPARE by_site;
SELECT Sede, count(*) FROM staging.protocolos_en_orden WHERE Fecha >= '2026-09-01' GROUP BY Sede ORDER BY Sede;
