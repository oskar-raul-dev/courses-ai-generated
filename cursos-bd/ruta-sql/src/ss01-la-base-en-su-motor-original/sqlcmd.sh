#!/bin/sh
# El sqlcmd del contenedor de SQL Server, contra el laboratorio del curso. Todo el track lo usa:
#   ./sqlcmd.sh < 03_esquema.sql           un archivo, con sus GO
#   ./sqlcmd.sh -Q "SELECT @@VERSION"      una consulta
#   ./sqlcmd.sh -b < 04_parser_2016.sql   -b: corta en el primer error (sin -b sigue con el lote siguiente)
# -C confía en el certificado autofirmado del contenedor; -W, sin relleno de columnas.
LAB=$(cd "$(dirname "$0")/../lab" && pwd)
exec ${LAB_COMPOSE:-docker compose} -f "$LAB/compose.yaml" exec -T sqlserver \
  /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P "${SQLSERVER_PASSWORD:-Lab-2026-pass}" -W "$@"
