-- Loads profile M of the box into MySQL (database legacy). mysql < carga/mysql.sql
DROP DATABASE IF EXISTS legacy; CREATE DATABASE legacy CHARACTER SET utf8mb4;
USE legacy;
CREATE TABLE `Pacientes` (`IdPaciente` int, `Nombre` varchar(120), `DNI` varchar(20), `FechaNac` date,
  `Sexo` char(1), `Telefono` varchar(60), `ObraSocial` varchar(40), `NroAfiliado` varchar(20));
CREATE TABLE `Protocolos` (`IdProtocolo` int, `NroProtocolo` varchar(20), `IdPaciente` int, `Fecha` date,
  `Sede` char(1), `ObraSocialTexto` varchar(40));
CREATE TABLE `ResultadoItem` (`IdItem` int, `IdProtocolo` int, `CodAnalito` varchar(10), `Valor` varchar(40), `Unidad` varchar(10));
SET @t=NOW(6);
LOAD DATA INFILE '/caja/m/Pacientes.csv' INTO TABLE `Pacientes` CHARACTER SET latin1 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
SELECT 'Pacientes', TIMESTAMPDIFF(MICROSECOND,@t,NOW(6))/1e6 AS s; SET @t=NOW(6);
LOAD DATA INFILE '/caja/m/Protocolos.csv' INTO TABLE `Protocolos` CHARACTER SET utf8mb4 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
SELECT 'Protocolos', TIMESTAMPDIFF(MICROSECOND,@t,NOW(6))/1e6 AS s; SET @t=NOW(6);
LOAD DATA INFILE '/caja/m/ResultadoItem.csv' INTO TABLE `ResultadoItem` CHARACTER SET utf8mb4 FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 LINES;
SELECT 'ResultadoItem', TIMESTAMPDIFF(MICROSECOND,@t,NOW(6))/1e6 AS s;
SELECT table_name, table_rows, ROUND((data_length+index_length)/1048576) AS mb FROM information_schema.tables WHERE table_schema='legacy';
SELECT `Nombre` FROM `Pacientes` WHERE `Nombre` LIKE '%Ñ%' LIMIT 2;
