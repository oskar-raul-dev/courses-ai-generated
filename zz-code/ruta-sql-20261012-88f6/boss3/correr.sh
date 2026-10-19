#!/usr/bin/env bash
# Boss III · corre la tarde con la solución de referencia: el tills.py de aquí en lugar del de src/, y 02_fix.sql.
set -euo pipefail
cd "$(dirname "$0")/.."
SRC=/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql/src
docker exec -i alameda-lab-postgres-1 psql -U postgres -d alameda -q < "$SRC/18-bloqueos-deadlocks-y-ddl/boss/01_july.sql" 2>/dev/null
docker exec -i alameda-lab-postgres-1 psql -U postgres -d alameda -q < boss3/02_fix.sql
exec docker run --rm -i --label curso=ruta-sql --network alameda-lab_default \
  -v "$SRC":/src -v "$PWD/boss3/tills.py":/src/18-bloqueos-deadlocks-y-ddl/boss/tills.py:ro \
  -v "$PWD/salidas/uv-cache":/root/.cache/uv -v "$PWD/salidas/uv-venv":/venv \
  -e UV_PROJECT_ENVIRONMENT=/venv -e UV_LINK_MODE=copy -e LAB_POSTGRES_HOST=postgres -e POSTGRES_PORT=5432 -w /src \
  ghcr.io/astral-sh/uv:0.11.14-python3.13-trixie-slim uv run --locked python 18-bloqueos-deadlocks-y-ddl/boss/afternoon.py
