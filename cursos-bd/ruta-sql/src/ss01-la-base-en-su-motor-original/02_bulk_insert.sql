-- sqlserver
-- ss01 · §4. El segundo intento: BULK INSERT, que desde SQL Server 2017 entiende CSV con comillas
-- (FORMAT = 'CSV'). Lee el archivo del lado del servidor, en /caja. Tres pruebas, en ss01_pruebas.
--   ./sqlcmd.sh < 02_bulk_insert.sql
-- Cada prueba es un lote: la que falla no corta a las demás (por eso va sin -b).
USE ss01_pruebas;
DROP TABLE IF EXISTS dbo.Sedes, dbo.Pacientes, dbo.Protocolos;
CREATE TABLE dbo.Sedes (CodSede nvarchar(1), Nombre nvarchar(100), Direccion nvarchar(255), FechaApertura datetime);
CREATE TABLE dbo.Pacientes (IdPaciente int IDENTITY(1,1) NOT NULL, Nombre nvarchar(255), DNI nvarchar(50),
    FechaNac datetime, Edad nvarchar(50), Sexo nvarchar(1), Telefono nvarchar(255), Direccion nvarchar(255),
    ObraSocial nvarchar(255), NroAfiliado nvarchar(50), Sede nvarchar(1), FechaAlta datetime);
CREATE TABLE dbo.Protocolos (IdProtocolo int NOT NULL, NroProtocolo nvarchar(20), IdPaciente int, Fecha datetime,
    Sede nvarchar(1), ObraSocial nvarchar(255), IdObraSocial int, IdMedico int, Coseguro money, Estado nvarchar(20));
GO
-- 1. Sedes, en UTF-8, diciéndole la página de códigos como se haría en Windows.
BULK INSERT dbo.Sedes FROM '/caja/m/tablas/Sedes.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0d0a', CODEPAGE = '65001');
GO
-- 2. Lo mismo sin CODEPAGE: en Linux, BULK INSERT lee UTF-8.
BULK INSERT dbo.Sedes FROM '/caja/m/tablas/Sedes.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0d0a');
SELECT CodSede, Nombre FROM dbo.Sedes;
GO
-- 3. Pacientes, que salió en Latin-1 "porque así salió" (el LEEME de la caja).
BULK INSERT dbo.Pacientes FROM '/caja/m/tablas/Pacientes.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0d0a', KEEPNULLS, KEEPIDENTITY);
GO
-- 4. Protocolos, en UTF-8, sin las dos columnas binarias que la caja no trae. Entra. ¿Entra igual?
--    El LEEME avisa: "Los NULL quedan vacios y sin comillas; un texto vacio queda "" (no es lo mismo, ojo)".
BULK INSERT dbo.Protocolos FROM '/caja/m/tablas/Protocolos.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, ROWTERMINATOR = '0x0d0a', KEEPNULLS);
SELECT SUM(CASE WHEN ObraSocial IS NULL THEN 1 ELSE 0 END) AS obra_social_null,
       SUM(CASE WHEN ObraSocial = N'' THEN 1 ELSE 0 END) AS obra_social_vacia
FROM dbo.Protocolos;
GO
