CREATE INDEX protocol_hint_fecha_idx ON staging.protocol_hint (Fecha);
EXPLAIN ANALYZE SELECT IdProtocolo FROM staging.protocol_hint FORCE INDEX (protocol_hint_fecha_idx) WHERE Sede = 'C' ORDER BY Fecha DESC LIMIT 50;
EXPLAIN ANALYZE SELECT IdProtocolo FROM staging.protocol_hint FORCE INDEX (protocol_hint_fecha_idx) WHERE Sede = 'A' ORDER BY Fecha DESC LIMIT 50;
EXPLAIN ANALYZE SELECT IdProtocolo FROM staging.protocol_hint FORCE INDEX (protocol_hint_fecha_idx) WHERE Sede = 'J' ORDER BY Fecha DESC LIMIT 50;
EXPLAIN ANALYZE SELECT IdProtocolo FROM staging.protocol_hint FORCE INDEX (protocol_hint_fecha_idx) WHERE Sede = 'R' ORDER BY Fecha DESC LIMIT 50;
EXPLAIN ANALYZE SELECT IdProtocolo FROM staging.protocol_hint FORCE INDEX (protocol_hint_fecha_idx) WHERE Sede = 'V' ORDER BY Fecha DESC LIMIT 50;
EXPLAIN ANALYZE SELECT IdProtocolo FROM staging.protocol_hint FORCE INDEX (protocol_hint_fecha_idx) WHERE Sede = 'E' ORDER BY Fecha DESC LIMIT 50;
DROP INDEX protocol_hint_fecha_idx ON staging.protocol_hint;
