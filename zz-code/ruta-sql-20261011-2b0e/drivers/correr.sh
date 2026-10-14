#!/usr/bin/env bash
# Runs drivers/prueba.py with uv inside the test lab network. Output: salidas/drivers.log
set -uo pipefail
cd "$(dirname "$0")/.."
docker run --rm --label curso=ruta-sql --network ruta-sql-p8_default -v "$PWD":/w -v "$PWD/salidas/caja":/caja:ro -w /w \
  -e UV_CACHE_DIR=/w/salidas/uv-cache ghcr.io/astral-sh/uv:0.11.14-python3.13-trixie-slim \
  uv run --quiet drivers/prueba.py 2>&1 | tee salidas/drivers.log
