-- mysql
-- El hint que sobrevivió a la sede que cerró. "Los últimos 50 protocolos de la sede", con el índice por fecha
-- forzado como en 2012, cuando era el único índice útil; después llegó el índice (Sede, Fecha), y el hint siguió
-- mandando. Una copia de Protocolos en staging, rehecha cada vez. Se corre con el cliente mysql (con --force, porque
-- la última sentencia falla a propósito).
DROP TABLE IF EXISTS staging.protocol_hint;
CREATE TABLE staging.protocol_hint LIKE legacy.Protocolos;
INSERT INTO staging.protocol_hint SELECT * FROM legacy.Protocolos;
CREATE INDEX protocol_hint_fecha_idx ON staging.protocol_hint (Fecha);
CREATE INDEX protocol_hint_sede_fecha_idx ON staging.protocol_hint (Sede, Fecha);
ANALYZE TABLE staging.protocol_hint;

SELECT 'con el hint' AS caso;
EXPLAIN ANALYZE SELECT IdProtocolo, NroProtocolo, Fecha
FROM staging.protocol_hint FORCE INDEX (protocol_hint_fecha_idx)
WHERE Sede = 'V' ORDER BY Fecha DESC LIMIT 50;
EXPLAIN ANALYZE SELECT IdProtocolo, NroProtocolo, Fecha
FROM staging.protocol_hint FORCE INDEX (protocol_hint_fecha_idx)
WHERE Sede = 'E' ORDER BY Fecha DESC LIMIT 50;

SELECT 'sin el hint' AS caso;
EXPLAIN ANALYZE SELECT IdProtocolo, NroProtocolo, Fecha
FROM staging.protocol_hint WHERE Sede = 'V' ORDER BY Fecha DESC LIMIT 50;
EXPLAIN ANALYZE SELECT IdProtocolo, NroProtocolo, Fecha
FROM staging.protocol_hint WHERE Sede = 'E' ORDER BY Fecha DESC LIMIT 50;

SELECT 'el mismo hint, en la sintaxis de los hints del optimizador' AS caso;
EXPLAIN ANALYZE SELECT /*+ INDEX(p protocol_hint_fecha_idx) */ IdProtocolo, NroProtocolo, Fecha
FROM staging.protocol_hint p WHERE Sede = 'E' ORDER BY Fecha DESC LIMIT 50;

SELECT 'un hint que nombra un índice que ya no existe' AS caso;
SELECT /*+ INDEX(p protocol_hint_gone_idx) */ IdProtocolo FROM staging.protocol_hint p
WHERE Sede = 'E' ORDER BY Fecha DESC LIMIT 1;
SHOW WARNINGS;
DROP INDEX protocol_hint_fecha_idx ON staging.protocol_hint;
SELECT IdProtocolo FROM staging.protocol_hint FORCE INDEX (protocol_hint_fecha_idx)
WHERE Sede = 'E' ORDER BY Fecha DESC LIMIT 1;
