SHOW SESSION STATUS LIKE 'Bytes_sent';
SELECT IdProtocolo FROM staging.protocolos WHERE Fecha >= '2026-09-01' ORDER BY IdProtocolo DESC;
SHOW SESSION STATUS LIKE 'Bytes_sent';
SHOW SESSION STATUS LIKE 'Bytes_sent';
EXPLAIN ANALYZE SELECT * FROM staging.protocolos ORDER BY Fecha DESC, IdProtocolo DESC LIMIT 999980, 20;
EXPLAIN ANALYZE SELECT * FROM staging.protocolos WHERE (Fecha, IdProtocolo) < ('2001-06-01', 2147483647) ORDER BY Fecha DESC, IdProtocolo DESC LIMIT 20;
EXPLAIN ANALYZE SELECT * FROM staging.protocolos WHERE Fecha < '2001-06-01' OR (Fecha = '2001-06-01' AND IdProtocolo < 2147483647) ORDER BY Fecha DESC, IdProtocolo DESC LIMIT 20;
