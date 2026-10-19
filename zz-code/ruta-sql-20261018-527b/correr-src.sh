#!/usr/bin/env bash
# Corre algo de src/ con el entorno del curso y el extra del track, en la red del laboratorio
# (uv en contenedor; nada instalado en la máquina). Uso:
#   ./correr-src.sh python ss01-…/01_carga.py      ./correr-src.sh lab load --engine sqlserver --profile m
#   UV_CMD=lock ./correr-src.sh                     (rehace uv.lock)
set -euo pipefail
cd "$(dirname "$0")"
SRC=/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql/src
CAJA=/Users/oskar/Developer/Learning/courses-ia-generated/zz-code/ruta-sql-20261014-d471/salidas/caja-t9
mkdir -p salidas/uv-cache salidas/uv-venv
if [ "${UV_CMD:-}" = lock ]; then set -- ; CMD=(uv lock); else CMD=(uv run --locked --extra sqlserver "$@"); fi
exec docker run --rm -i --label curso=ruta-sql --network alameda-lab_default \
  -v "$SRC":/src -v "$PWD":/sesion -v "$CAJA":/caja:ro \
  -v "$PWD/salidas/uv-cache":/root/.cache/uv -v "$PWD/salidas/uv-venv":/venv \
  -e UV_PROJECT_ENVIRONMENT=/venv -e UV_LINK_MODE=copy -e LAB_CAJA=/caja \
  -e LAB_POSTGRES_HOST=postgres -e POSTGRES_PORT=5432 -e LAB_MYSQL_HOST=mysql -e MYSQL_PORT=3306 \
  -e LAB_ORACLE_HOST=oracle -e ORACLE_PORT=1521 -e LAB_SQLSERVER_HOST=sqlserver -e SQLSERVER_PORT=1433 -e API_HOST=api -e API_PORT=3000 -e DAB_HOST=dab -e DAB_PORT=5000 -w /src \
  ruta-sql-uv-mssql:t13 "${CMD[@]}"   # imagen-uv/Dockerfile
