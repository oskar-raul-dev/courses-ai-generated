#!/bin/sh
# ss01 · lo primero que uno prueba: devolver la caja con la misma herramienta con que salió. Sedes y Pacientes.
S="docker exec -i alameda-lab-sqlserver-1"
B="/opt/mssql-tools18/bin/bcp"
./sqlcmd.sh -Q "USE prueba; DROP TABLE IF EXISTS dbo.Sedes, dbo.Pacientes; CREATE TABLE dbo.Sedes (CodSede nvarchar(1), Nombre nvarchar(100), Direccion nvarchar(255), FechaApertura datetime); CREATE TABLE dbo.Pacientes (IdPaciente int IDENTITY(1,1) NOT NULL, Nombre nvarchar(255), DNI nvarchar(50), FechaNac datetime, Edad nvarchar(50), Sexo nvarchar(1), Telefono nvarchar(255), Direccion nvarchar(255), ObraSocial nvarchar(255), NroAfiliado nvarchar(50), Sede nvarchar(1), FechaAlta datetime);"
echo "== bcp in Sedes -c -t, (como salió)"
$S $B prueba.dbo.Sedes in /caja/m/tablas/Sedes.csv -S localhost -U sa -P Lab-2026-pass -u -c -t, -r '\r\n' -F 2 -e /tmp/sedes.err 2>&1 | tail -6
$S cat /tmp/sedes.err 2>/dev/null | head -8
echo "== lo que quedó"
./sqlcmd.sh -Q "SELECT CodSede, Nombre, LEFT(Direccion,30) AS Direccion, FechaApertura FROM prueba.dbo.Sedes"
echo "== bcp in Pacientes -c -t, -E"
$S $B prueba.dbo.Pacientes in /caja/m/tablas/Pacientes.csv -S localhost -U sa -P Lab-2026-pass -u -c -t, -r '\r\n' -F 2 -E -m 10 -e /tmp/pac.err 2>&1 | tail -6
$S head -c 1500 /tmp/pac.err 2>/dev/null
