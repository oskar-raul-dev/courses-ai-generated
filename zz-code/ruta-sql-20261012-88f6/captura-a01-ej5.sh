#!/usr/bin/env bash
# a01 ej5 con el proyecto real: Oracle con 512 MB, hasta tres intentos; se anotan todos.
set -uo pipefail
cd "$(dirname "$0")"
Z=$PWD
SRC=/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql/src
lab() { LAB_COMPOSE_OVERRIDE=/nonexistent LAB_CAJA="$Z/salidas/caja" python3 -I -c \
  "import sys; sys.path.insert(0, '$SRC'); from lab.cli import main; sys.exit(main(sys.argv[1:]))" "$@"; }
dc() { (cd "$SRC/lab" && LAB_CAJA="$Z/salidas/caja" docker compose -f compose.yaml "$@"); }
say() { printf '\n$ %s\n' "$*"; }
for i in 1 2 3; do
  echo "=== intento $i"
  say ORACLE_MEMORY=512m uv run lab up oracle; ORACLE_MEMORY=512m lab up oracle 2>&1 | tail -3
  say "docker compose ps -a --format '{{.Service}} {{.Status}}'"; dc ps -a --format '{{.Service}} {{.Status}}'
  say "docker inspect alameda-lab-oracle-1 --format 'oom={{.State.OOMKilled}} exit={{.State.ExitCode}}'"
  docker inspect alameda-lab-oracle-1 --format 'oom={{.State.OOMKilled}} exit={{.State.ExitCode}}'
  say "docker compose logs --no-log-prefix oracle | grep -B1 -A4 'Database mounted'"
  dc logs --no-log-prefix oracle 2>&1 | grep -B1 -A4 'Database mounted'
  lab down -v >/dev/null 2>&1
done
