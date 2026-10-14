#!/usr/bin/env bash
# Corre un script de a06 desde /src con las variables de la red del laboratorio.
set -euo pipefail
cd /src
export LAB_POSTGRES_HOST=postgres POSTGRES_PORT=5432 LAB_MYSQL_HOST=mysql MYSQL_PORT=3306
export LAB_ORACLE_HOST=oracle ORACLE_PORT=1521
exec python "$@"
