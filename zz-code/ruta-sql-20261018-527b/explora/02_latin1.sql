USE prueba;
DROP TABLE IF EXISTS p1;
CREATE TABLE p1 (IdPaciente int, Nombre nvarchar(255), DNI nvarchar(50), FechaNac datetime, Edad nvarchar(50), Sexo nvarchar(1),
  Telefono nvarchar(255), Direccion nvarchar(255), ObraSocial nvarchar(255), NroAfiliado nvarchar(50), Sede nvarchar(1), FechaAlta datetime);
GO
BULK INSERT p1 FROM '/caja/m/tablas/Pacientes.csv' WITH (FORMAT='CSV', FIRSTROW=2, ROWTERMINATOR='0x0d0a', KEEPNULLS);
GO
SELECT TOP 3 IdPaciente, Nombre, CAST(Nombre AS varbinary(40)) AS bytes FROM p1 WHERE Nombre LIKE N'%' + NCHAR(0xFFFD) + N'%' OR Nombre LIKE N'%MU%OZ%' ORDER BY IdPaciente;
SELECT COUNT(*) AS con_reemplazo FROM p1 WHERE CHARINDEX(NCHAR(0xFFFD), Nombre) > 0;
GO
