#!/bin/sh
# ss01 · §5.2. El T-SQL de Matías tal cual: tsql/fn_ExtraerDNI.sql de la caja, sin tocar una línea,
# con el sqlcmd del contenedor (que lee la caja en /caja). Después, una muestra de lo que devuelve.
#   ./04_parser_2016.sh          (perfil m)
P=${PERFIL:-m}
LAB=$(cd "$(dirname "$0")/../lab" && pwd)
cd "$(dirname "$0")"
./sqlcmd.sh -Q "USE ALAMEDA; DROP FUNCTION IF EXISTS dbo.fn_ExtraerDNI, dbo.fn_ExtraerFecha;"
${LAB_COMPOSE:-docker compose} -f "$LAB/compose.yaml" exec -T sqlserver /opt/mssql-tools18/bin/sqlcmd -C \
  -S localhost -U sa -P "${SQLSERVER_PASSWORD:-Lab-2026-pass}" -b -i /caja/$P/tsql/fn_ExtraerDNI.sql
./sqlcmd.sh <<'SQL'
USE ALAMEDA;
SELECT TOP 5 IdPaciente, Nombre, dbo.fn_ExtraerDNI(Nombre) AS dni_2016, dbo.fn_ExtraerFecha(Nombre) AS fecha_2016
FROM dbo.Pacientes WHERE Nombre LIKE N'%[0-9]/[0-9]%' ORDER BY IdPaciente;
SQL
