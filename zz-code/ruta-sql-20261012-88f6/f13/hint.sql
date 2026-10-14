CREATE INDEX protocol_hist_fecha_idx ON staging.protocol_hist (Fecha);
CREATE INDEX protocol_hist_sede_fecha_idx ON staging.protocol_hist (Sede, Fecha);
ANALYZE TABLE staging.protocol_hist;
EXPLAIN ANALYZE SELECT IdProtocolo, NroProtocolo, Fecha FROM staging.protocol_hist FORCE INDEX (protocol_hist_fecha_idx) WHERE Sede = 'V' ORDER BY Fecha DESC LIMIT 50;
EXPLAIN ANALYZE SELECT IdProtocolo, NroProtocolo, Fecha FROM staging.protocol_hist FORCE INDEX (protocol_hist_fecha_idx) WHERE Sede = 'E' ORDER BY Fecha DESC LIMIT 50;
EXPLAIN ANALYZE SELECT IdProtocolo, NroProtocolo, Fecha FROM staging.protocol_hist WHERE Sede = 'E' ORDER BY Fecha DESC LIMIT 50;
EXPLAIN ANALYZE SELECT IdProtocolo, NroProtocolo, Fecha FROM staging.protocol_hist WHERE Sede = 'V' ORDER BY Fecha DESC LIMIT 50;
