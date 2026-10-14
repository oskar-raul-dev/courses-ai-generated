#!/usr/bin/env bash
# Corre un script de Python de esta sesión con el entorno del curso (uv.lock), en la red del laboratorio.
# Uso: ./correr-python.sh f09/paquete.py   (el directorio de la sesión se monta en /sesion)
set -euo pipefail
cd "$(dirname "$0")"
SRC=/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql/src
exec docker run --rm -i --label curso=ruta-sql --network alameda-lab_default \
  -v "$SRC":/src -v "$PWD":/sesion:ro \
  -v "$PWD/salidas/uv-cache":/root/.cache/uv -v "$PWD/salidas/uv-venv":/venv \
  -e UV_PROJECT_ENVIRONMENT=/venv -e UV_LINK_MODE=copy -e LAB_MYSQL_HOST=mysql -e MYSQL_PORT=3306 \
  -e LAB_POSTGRES_HOST=postgres -e POSTGRES_PORT=5432 -w /src \
  ghcr.io/astral-sh/uv:0.11.14-python3.13-trixie-slim uv run --locked python "$( [[ $1 == /* ]] && echo "$1" || echo "/sesion/$1" )"
