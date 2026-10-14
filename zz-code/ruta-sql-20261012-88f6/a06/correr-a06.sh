#!/usr/bin/env bash
# Corre un script de a06 con el entorno del curso (uv.lock), en la red del laboratorio.
set -euo pipefail
cd "$(dirname "$0")/.."
SRC=/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql/src
exec docker run --rm -i --label curso=ruta-sql --network alameda-lab_default \
  -v "$SRC":/src -v "$PWD/a06":/a06:ro -v "$PWD/salidas/caja":/caja-host:ro \
  -v "$PWD/salidas/uv-cache":/root/.cache/uv -v "$PWD/salidas/uv-venv":/venv \
  -e UV_PROJECT_ENVIRONMENT=/venv -e UV_LINK_MODE=copy -w /src \
  ghcr.io/astral-sh/uv:0.11.14-python3.13-trixie-slim uv run --locked "$@"
