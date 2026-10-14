#!/usr/bin/env bash
# Capturas de a01 con el proyecto real (alameda-lab) y los puertos del curso, sin el override de
# pruebas: el ciclo, conectarse antes de tiempo, puerto ocupado y Oracle sin memoria.
# Empieza y termina con `lab down -v`: solo toca recursos con la etiqueta curso=ruta-sql.
set -uo pipefail
cd "$(dirname "$0")"
Z=$PWD
SRC=/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql/src
lab() { LAB_COMPOSE_OVERRIDE=/nonexistent LAB_CAJA="$Z/salidas/caja" python3 -I -c \
  "import sys; sys.path.insert(0, '$SRC'); from lab.cli import main; sys.exit(main(sys.argv[1:]))" "$@"; }
dc() { (cd "$SRC/lab" && LAB_CAJA="$Z/salidas/caja" docker compose -f compose.yaml "$@"); }
say() { printf '\n$ %s\n' "$*"; }

echo "=== 0 · limpieza"; lab down -v 2>&1 | tail -3

echo "=== ej2 · el ciclo"
say uv run lab up; lab up 2>&1
say "docker compose exec postgres psql -U postgres -d alameda -tAc 'SELECT version()'"
dc exec -T postgres psql -U postgres -d alameda -tAc 'SELECT version()'
say uv run lab down; lab down 2>&1
say docker volume ls --filter label=curso=ruta-sql; docker volume ls --filter label=curso=ruta-sql
say uv run lab down -v; lab down -v 2>&1
say docker volume ls --filter label=curso=ruta-sql; docker volume ls --filter label=curso=ruta-sql

echo "=== ej3 · conectarse antes de tiempo"
say docker compose --profile oracle up -d; dc --profile oracle up -d 2>&1
say "docker compose exec oracle sqlplus -s -L system/lab@FREEPDB1"
echo "SELECT 'conecta' AS estado FROM dual;" | dc exec -T oracle sqlplus -s -L system/lab@FREEPDB1 2>&1
say docker compose ps; dc ps --format 'table {{.Service}}\t{{.Status}}'
start=$(date +%s)
until dc ps --format '{{.Status}}' oracle | grep -q '(healthy)'; do sleep 1; done
echo "healthy a los $(( $(date +%s) - start )) s de la primera consulta"
say docker compose ps; dc ps --format 'table {{.Service}}\t{{.Status}}'
say "docker compose exec oracle sqlplus -s -L system/lab@FREEPDB1"
echo "SELECT 'conecta' AS estado FROM dual;" | dc exec -T oracle sqlplus -s -L system/lab@FREEPDB1 2>&1
lab down -v >/dev/null 2>&1

echo "=== ej4 · puerto ocupado"
docker run -d --rm --name otro-postgres --label curso=ruta-sql -e POSTGRES_PASSWORD=x \
  -p 127.0.0.1:25432:5432 pgvector/pgvector:0.8.7-pg18 >/dev/null
sleep 2
say uv run lab up; lab up 2>&1
say "docker ps --filter publish=25432 --format 'table {{.Names}}\t{{.Ports}}'"
docker ps --filter publish=25432 --format 'table {{.Names}}\t{{.Ports}}'
say POSTGRES_PORT=25433 uv run lab up; POSTGRES_PORT=25433 lab up 2>&1
say uv run lab ps; POSTGRES_PORT=25433 lab ps 2>&1
docker stop otro-postgres >/dev/null
lab down -v >/dev/null 2>&1

echo "=== ej5 · Oracle sin memoria"
say ORACLE_MEMORY=1536m uv run lab up oracle; ORACLE_MEMORY=1536m lab up oracle 2>&1
say "docker compose ps -a --format '{{.Service}} {{.Status}}'"; dc ps -a --format '{{.Service}} {{.Status}}'
say "docker inspect alameda-lab-oracle-1 --format 'oom={{.State.OOMKilled}} exit={{.State.ExitCode}}'"
docker inspect alameda-lab-oracle-1 --format 'oom={{.State.OOMKilled}} exit={{.State.ExitCode}}'
say "docker compose logs --no-log-prefix oracle | head -5"; dc logs --no-log-prefix oracle 2>&1 | head -5
say "docker compose logs --no-log-prefix oracle | grep -A3 'Database mounted'"; dc logs --no-log-prefix oracle 2>&1 | grep -A3 'Database mounted'

echo "=== fin · limpieza"; lab down -v 2>&1 | tail -3
