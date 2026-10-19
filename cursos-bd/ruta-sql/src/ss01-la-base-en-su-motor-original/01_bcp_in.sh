#!/bin/sh
# ss01 · §4. Lo primero que uno prueba: devolver la caja a SQL Server con la misma herramienta con que
# salió. Dos tablas, en una base de pruebas aparte (ss01_pruebas), para no tocar ALAMEDA.
#   ./01_bcp_in.sh            (perfil m; PERFIL=s ./01_bcp_in.sh para el chico)
P=${PERFIL:-m}
LAB=$(cd "$(dirname "$0")/../lab" && pwd)
C="${LAB_COMPOSE:-docker compose} -f $LAB/compose.yaml exec -T sqlserver"
BCP="/opt/mssql-tools18/bin/bcp"
AUTH="-S localhost -U sa -P ${SQLSERVER_PASSWORD:-Lab-2026-pass} -u"
cd "$(dirname "$0")"
./sqlcmd.sh -b <<'SQL'
IF DB_ID('ss01_pruebas') IS NULL CREATE DATABASE ss01_pruebas;
GO
USE ss01_pruebas;
DROP TABLE IF EXISTS dbo.Sedes, dbo.Pacientes;
CREATE TABLE dbo.Sedes (CodSede nvarchar(1), Nombre nvarchar(100), Direccion nvarchar(255), FechaApertura datetime);
CREATE TABLE dbo.Pacientes (IdPaciente int IDENTITY(1,1) NOT NULL, Nombre nvarchar(255), DNI nvarchar(50),
    FechaNac datetime, Edad nvarchar(50), Sexo nvarchar(1), Telefono nvarchar(255), Direccion nvarchar(255),
    ObraSocial nvarchar(255), NroAfiliado nvarchar(50), Sede nvarchar(1), FechaAlta datetime);
SQL
echo "== bcp in de Sedes: texto (-c), separador coma, salteando el encabezado (-F 2)"
$C $BCP ss01_pruebas.dbo.Sedes in /caja/$P/tablas/Sedes.csv $AUTH -c -t, -r '\r\n' -F 2 -e /tmp/sedes.err \
  | grep -v "Clock Time\|Network packet"
$C head -4 /tmp/sedes.err
echo "== bcp in de Pacientes, conservando la identidad (-E)"
$C $BCP ss01_pruebas.dbo.Pacientes in /caja/$P/tablas/Pacientes.csv $AUTH -c -t, -r '\r\n' -F 2 -E -m 10 \
  -e /tmp/pacientes.err | grep -v "Clock Time\|Network packet"
$C head -4 /tmp/pacientes.err
