#!/usr/bin/env bash
# El CLI del curso (`uv run lab …`) dentro del contenedor de uv, en la red del laboratorio, para no
# instalar nada en la máquina. El entorno virtual vive en salidas/uv-venv; la caja, montada.
# Uso: ./lab-en-contenedor.sh load --profile m | ./lab-en-contenedor.sh measure -c "…"
set -euo pipefail
cd "$(dirname "$0")"
SRC=/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql/src
mkdir -p salidas/uv-cache salidas/uv-venv
exec docker run --rm -i --label curso=ruta-sql --network alameda-lab_default \
  -v "$SRC":/src -v "$PWD/salidas/caja":/caja-host:ro \
  -v "$PWD/salidas/uv-cache":/root/.cache/uv -v "$PWD/salidas/uv-venv":/venv \
  -e UV_PROJECT_ENVIRONMENT=/venv -e UV_LINK_MODE=copy -e LAB_CAJA=/caja-host \
  -e LAB_POSTGRES_HOST=postgres -e POSTGRES_PORT=5432 -e LAB_MYSQL_HOST=mysql -e MYSQL_PORT=3306 \
  -e LAB_ORACLE_HOST=oracle -e ORACLE_PORT=1521 -w /src \
  ghcr.io/astral-sh/uv:0.11.14-python3.13-trixie-slim uv run --locked lab "$@"
