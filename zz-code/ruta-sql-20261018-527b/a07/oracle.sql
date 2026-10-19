SET LINESIZE 200
SET FEEDBACK OFF
ALTER SESSION SET CURRENT_SCHEMA = LEGACY;
PROMPT == e1
SELECT "IdProtocolo", "NroProtocolo", "Fecha" FROM "Protocolos" ORDER BY "Fecha" DESC, "IdProtocolo" DESC FETCH FIRST 5 ROWS ONLY;
PROMPT == e2
SELECT COUNT(CASE WHEN "DNI" = '' THEN 1 END) AS vacio, COUNT(CASE WHEN "DNI" IS NULL THEN 1 END) AS nulo FROM "Pacientes";
PROMPT == e3
SELECT COUNT(*) AS total, COUNT(CASE WHEN "Nombre" || ' ' || "DNI" IS NULL THEN 1 END) AS concat_nula FROM "Pacientes";
PROMPT == e4
SELECT MAX("IdProtocolo") AS maximo, 2147483647 - MAX("IdProtocolo") AS quedan FROM "Protocolos";
PROMPT == e5
CREATE TABLE a07_precio (cod_nbu VARCHAR2(20) PRIMARY KEY, ub NUMBER(8,2));
INSERT INTO a07_precio VALUES ('475', 2.00);
MERGE INTO a07_precio p
USING (SELECT '475' AS cod_nbu, 2.50 AS ub FROM dual UNION ALL SELECT '711', 1.25 FROM dual) n
ON (p.cod_nbu = n.cod_nbu)
WHEN MATCHED THEN UPDATE SET p.ub = n.ub
WHEN NOT MATCHED THEN INSERT (cod_nbu, ub) VALUES (n.cod_nbu, n.ub);
SELECT * FROM a07_precio ORDER BY 1;
DROP TABLE a07_precio PURGE;
