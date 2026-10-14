#!/usr/bin/env bash
# El CLI del curso en el host, solo para up/down/ps (biblioteca estándar), con el override de pruebas.
# Uso: ./lab.sh up base contraste oracle | ./lab.sh down -v | ./lab.sh ps
set -euo pipefail
cd "$(dirname "$0")"
export LAB_COMPOSE_OVERRIDE="$PWD/compose.pruebas.yaml" LAB_CAJA="$PWD/salidas/caja"
SRC=/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql/src
exec python3 -I -c "import sys; sys.path.insert(0, '$SRC'); from lab.cli import main; sys.exit(main(sys.argv[1:]))" "$@"
