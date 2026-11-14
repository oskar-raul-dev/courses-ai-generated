#!/usr/bin/env bash
# F00 §6.8 — el compose del curso, en el host, sin puertos y con etiqueta. Se corre desde la raíz del directorio.
set -uo pipefail
cd "$(dirname "$0")/.."
DC="docker compose -p gfjd -f lector/compose.yaml -f scripts/compose.prueba.yaml"
echo "### F00:L802 make up (docker compose up -d --wait)"
$DC up -d --wait --quiet-pull 2>&1 | tail -5
$DC ps --format 'table {{.Name}}\t{{.Image}}\t{{.Status}}'
echo "### F00:L810 perfil rs"
$DC --profile rs up -d --wait --quiet-pull mongo-rs 2>&1 | tail -3
$DC --profile rs ps --format 'table {{.Name}}\t{{.Status}}'
docker exec meridian-mongo-rs mongosh --quiet --eval 'rs.status().set + " " + rs.status().members[0].stateStr'
docker exec meridian-mongo mongosh --quiet --eval 'db.version()'
docker exec meridian-postgres psql -U meridian -tAc 'select version()'
docker exec meridian-valkey valkey-cli info server | grep valkey_version
echo "### make down"
$DC --profile rs down -v 2>&1 | tail -3
