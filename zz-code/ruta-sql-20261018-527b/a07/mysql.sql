USE legacy;
SELECT '== e1';
SELECT IdProtocolo, NroProtocolo, Fecha FROM Protocolos ORDER BY Fecha DESC, IdProtocolo DESC LIMIT 5;
SELECT '== e2';
SELECT SUM(Edad = '') AS vacio, SUM(Edad IS NULL) AS nulo, SUM(DNI = '') AS dni_vacio, SUM(DNI IS NULL) AS dni_nulo FROM Pacientes;
SELECT '== e3';
SELECT COUNT(*) AS total, SUM(CONCAT(Nombre, ' ', DNI) IS NULL) AS concat_nula, SUM(CONCAT_WS(' ', Nombre, DNI) IS NULL) AS concat_ws_nula, SUM((Nombre || ' ' || DNI) IS NULL) AS pipes_nula FROM Pacientes;
SELECT Nombre || ' ' || DNI AS con_pipes FROM Pacientes ORDER BY IdPaciente LIMIT 2;
SELECT '== e4';
SELECT MAX(IdProtocolo) AS maximo, 2147483647 - MAX(IdProtocolo) AS quedan FROM Protocolos;
SELECT '== e5';
CREATE TABLE lab.a07_precio (cod_nbu varchar(20) PRIMARY KEY, ub decimal(8,2));
INSERT INTO lab.a07_precio VALUES ('475', 2.00);
INSERT INTO lab.a07_precio (cod_nbu, ub) VALUES ('475', 2.50), ('711', 1.25) AS n
ON DUPLICATE KEY UPDATE ub = n.ub;
SELECT * FROM lab.a07_precio ORDER BY 1;
DROP TABLE lab.a07_precio;
