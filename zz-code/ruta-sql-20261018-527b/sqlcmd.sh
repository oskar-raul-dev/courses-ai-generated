#!/bin/sh
# sqlcmd del laboratorio, dentro del contenedor de SQL Server: lee T-SQL de stdin (con GO) o -Q.
exec docker exec -i alameda-lab-sqlserver-1 /opt/mssql-tools18/bin/sqlcmd -C -S localhost -U sa -P Lab-2026-pass -b -W "$@"
