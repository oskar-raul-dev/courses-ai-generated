#!/usr/bin/env bash
# Corre un script de src/ con el entorno del curso, en la red del laboratorio (uv en contenedor; nada instalado).
# Uso: ./correr-src.sh 25-la-migracion-sin-parar/03_convivencia.py [args]
set -euo pipefail
cd "$(dirname "$0")"
SRC=/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql/src
mkdir -p salidas/uv-cache salidas/uv-venv
exec docker run --rm -i --label curso=ruta-sql --network alameda-lab_default \
  -v "$SRC":/src -v "$PWD":/sesion \
  -v "$PWD/salidas/uv-cache":/root/.cache/uv -v "$PWD/salidas/uv-venv":/venv \
  -e UV_PROJECT_ENVIRONMENT=/venv -e UV_LINK_MODE=copy -e LAB_MYSQL_HOST=mysql -e MYSQL_PORT=3306 \
  -e LAB_POSTGRES_HOST=postgres -e POSTGRES_PORT=5432 -e API_HOST=api -e API_PORT=3000 -w /src \
  ghcr.io/astral-sh/uv:0.11.14-python3.13-trixie-slim uv run --locked python "$@"
