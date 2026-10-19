-- ¿Cómo lee BULK INSERT en Linux un CSV UTF-8 y uno Latin-1 sin CODEPAGE? Medicos es Latin-1, Sedes UTF-8.
IF DB_ID('prueba') IS NULL CREATE DATABASE prueba;
GO
USE prueba;
DROP TABLE IF EXISTS m1, s1, s2, m2;
CREATE TABLE m1 (IdMedico int, Nombre nvarchar(255), Matricula nvarchar(20), Especialidad nvarchar(100), Telefono nvarchar(100));
CREATE TABLE s1 (CodSede nvarchar(1), Nombre nvarchar(100), Direccion nvarchar(255), FechaApertura datetime);
CREATE TABLE m2 (IdMedico int, Nombre nvarchar(255) COLLATE Latin1_General_100_CI_AS_SC_UTF8, Matricula nvarchar(20), Especialidad nvarchar(100), Telefono nvarchar(100));
GO
BULK INSERT s1 FROM '/caja/m/tablas/Sedes.csv' WITH (FORMAT='CSV', FIRSTROW=2, ROWTERMINATOR='0x0d0a');
BULK INSERT m1 FROM '/caja/m/tablas/Medicos.csv' WITH (FORMAT='CSV', FIRSTROW=2, ROWTERMINATOR='0x0d0a');
GO
SELECT Nombre, Direccion FROM s1;
SELECT TOP 5 Nombre, Especialidad FROM m1 WHERE Nombre LIKE N'%[^A-Z ,.]%';
GO
BULK INSERT s1 FROM '/caja/m/tablas/Sedes.csv' WITH (FORMAT='CSV', FIRSTROW=2, ROWTERMINATOR='0x0d0a', CODEPAGE='65001');
GO
