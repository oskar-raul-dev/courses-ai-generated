-- mysql
-- La base de 2011 tal como la dejó el asistente: ResultadoItem con el índice por IdProtocolo que puso el AutoIndex
-- de Access (Fase 11). La caja no trae índices; esta copia en staging los repone para que el frontal simulado
-- encuentre lo que encontraba. Tarda unos minutos.
DROP TABLE IF EXISTS staging.resultado_item;
CREATE TABLE staging.resultado_item LIKE legacy.ResultadoItem;
ALTER TABLE staging.resultado_item ADD INDEX resultado_item_idprotocolo_idx (IdProtocolo);
INSERT INTO staging.resultado_item SELECT * FROM legacy.ResultadoItem;
DROP TABLE IF EXISTS staging.protocolos;
CREATE TABLE staging.protocolos LIKE legacy.Protocolos;
ALTER TABLE staging.protocolos ADD INDEX protocolos_idpaciente_idx (IdPaciente), ADD INDEX protocolos_fecha_idx (Fecha);
INSERT INTO staging.protocolos SELECT * FROM legacy.Protocolos;
ANALYZE TABLE staging.resultado_item, staging.protocolos;
