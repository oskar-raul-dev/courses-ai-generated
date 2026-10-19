SET search_path = legacy;
\echo == e1
SELECT "IdProtocolo", "NroProtocolo", "Fecha" FROM "Protocolos" ORDER BY "Fecha" DESC, "IdProtocolo" DESC LIMIT 5;
\echo == e2
SELECT count(*) FILTER (WHERE "DNI" = '') AS vacio, count(*) FILTER (WHERE "DNI" IS NULL) AS nulo FROM "Pacientes";
\echo == e3
SELECT count(*) AS total, count(*) FILTER (WHERE "Nombre" || ' ' || "DNI" IS NULL) AS concat_nula,
       count(*) FILTER (WHERE concat_ws(' ', "Nombre", "DNI") IS NULL) AS concat_ws_nula FROM "Pacientes";
\echo == e4
SELECT max("IdProtocolo") AS maximo, 2147483647 - max("IdProtocolo") AS quedan FROM "Protocolos";
\echo == e5
BEGIN;
CREATE TABLE lab.a07_precio (cod_nbu varchar(20) PRIMARY KEY, ub numeric(8,2));
INSERT INTO lab.a07_precio VALUES ('475', 2.00);
INSERT INTO lab.a07_precio (cod_nbu, ub) VALUES ('475', 2.50), ('711', 1.25)
ON CONFLICT (cod_nbu) DO UPDATE SET ub = EXCLUDED.ub;
SELECT * FROM lab.a07_precio ORDER BY 1;
ROLLBACK;
