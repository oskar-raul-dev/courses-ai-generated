SET @q = 'EXPLAIN FORMAT=TREE SELECT count(*) FROM staging.protocolos_en_orden WHERE Sede = ? AND Fecha >= ''2026-09-01''';
PREPARE s FROM @q;
SET @sede = 'C'; EXECUTE s USING @sede;
SET @sede = 'V'; EXECUTE s USING @sede;
SET @sede = 'E'; EXECUTE s USING @sede;
DEALLOCATE PREPARE s;
SELECT Sede, count(*) FROM staging.protocolos_en_orden WHERE Fecha >= '2026-09-01' GROUP BY Sede;
EXPLAIN FORMAT=TREE SELECT /*+ NO_INDEX(p protocolos_en_orden_sede_fecha_idx) */ count(*) FROM staging.protocolos_en_orden p WHERE Sede = 'V' AND Fecha >= '2026-09-01';
EXPLAIN FORMAT=TREE SELECT count(*) FROM staging.protocolos_en_orden p FORCE INDEX (protocolos_en_orden_idpaciente_idx) WHERE Sede = 'V' AND Fecha >= '2026-09-01';
