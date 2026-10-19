-- Ejercicios 1 y 15 de F16.
SELECT "PuntoVenta", count(*) FILTER (WHERE "Fecha" < '2015-08-01') AS julio_2015, count(*) AS total
FROM legacy."ComprobantesRechazados" GROUP BY 1 ORDER BY 1;
SELECT "PuntoVenta", count(*) AS comprobantes_julio_2015 FROM legacy."Comprobantes" WHERE "Fecha" < '2015-08-01' GROUP BY 1 ORDER BY 1;
-- 15: los números de protocolo repetidos, y la restricción que el protocolo sí necesita
SELECT count(*) AS numeros_repetidos FROM (SELECT "NroProtocolo" FROM legacy."Protocolos" GROUP BY 1 HAVING count(*) > 1) d;
DROP TABLE IF EXISTS staging.protocol_number;
CREATE TABLE staging.protocol_number AS SELECT "IdProtocolo" AS protocol_id, "NroProtocolo" AS protocol_number FROM legacy."Protocolos";
ALTER TABLE staging.protocol_number ADD CONSTRAINT protocol_number_unique UNIQUE (protocol_number);
