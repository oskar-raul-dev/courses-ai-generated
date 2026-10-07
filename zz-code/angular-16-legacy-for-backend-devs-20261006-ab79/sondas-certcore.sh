#!/usr/bin/env bash
# Replays the two CertCore probes of session f803daaa (09/09/2026) under today's rules:
# label curso=angular-16-legacy-for-backend-devs, own network, no published port, work copy in salidas/.
#
#   ./sondas-certcore.sh php       PHP 7.4.33 + pdo_pgsql (apt from snapshot.debian.org) against postgres:16
#   ./sondas-certcore.sh compose   the rescued compose stack (php -S + postgres:${POSTGRES_TAG}), queried
#                                  from inside the api container instead of curl localhost:3000
#   ./sondas-certcore.sh limpiar   removes everything this script created, by label and project name
#
# The 09/09 originals published port 3000 and used --link; both changed here, nothing else.
set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
ORIGEN="$AQUI/02-sondas-be-f803daaa/archivos/_tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/f803daaa-f024-4042-af34-b44d49809430/scratchpad"
TRABAJO="$AQUI/salidas/sondas"
CURSO=angular-16-legacy-for-backend-devs
LABEL="curso=$CURSO"
RED=a16-sonda-red
POSTGRES_TAG="${POSTGRES_TAG:-16.9}"

php_probe() {
  mkdir -p "$TRABAJO" && rm -rf "$TRABAJO/phpcheck" && cp -R "$ORIGEN/phpcheck" "$TRABAJO/"
  docker build -q --label "$LABEL" --platform linux/arm64 -t a16-php74check "$TRABAJO/phpcheck"
  docker network create --label "$LABEL" "$RED" >/dev/null
  docker run -d --name a16-pgcheck --label "$LABEL" --network "$RED" --network-alias db --platform linux/arm64 \
    -e POSTGRES_PASSWORD=secret "postgres:$POSTGRES_TAG" >/dev/null
  sleep 6
  echo "### php 7.4 (arm64) -> postgres $POSTGRES_TAG (arm64)"
  docker run --rm --label "$LABEL" --network "$RED" --platform linux/arm64 a16-php74check php -r '
$p = new PDO("pgsql:host=db;dbname=postgres","postgres","secret");
$q = function($s) use ($p){ return $p->query($s)->fetchColumn(); };
echo "  conexion:       OK\n";
echo "  servidor:       PostgreSQL ", $q("SHOW server_version"), "\n";
echo "  password_encr:  ", $q("SHOW password_encryption"), "\n";
echo "  hash del user:  ", substr($q("SELECT rolpassword FROM pg_authid WHERE rolname=\047postgres\047"),0,13), "...\n";
echo "  php:            ", PHP_VERSION, " (", php_uname("m"), ")\n";
$p->exec("CREATE TABLE IF NOT EXISTS t(id serial primary key, n text)");
$s=$p->prepare("INSERT INTO t(n) VALUES (?)"); $s->execute(["hola"]);
echo "  escritura:      ", $q("SELECT n FROM t LIMIT 1"), "\n";
' 2>&1 | sed 's/^/  /'
  docker rm -f a16-pgcheck >/dev/null; docker network rm "$RED" >/dev/null
}

compose_probe() {
  mkdir -p "$TRABAJO" && rm -rf "$TRABAJO/certcore" && cp -R "$ORIGEN/certcore" "$TRABAJO/"
  # .env was left out of the rescue (rule 6); its only line was the database tag
  printf '# La version de la base vive AQUI, fuera del codigo fuente.\nPOSTGRES_TAG=%s\n' "$POSTGRES_TAG" > "$TRABAJO/certcore/.env"
  # override: no published port (needs Compose 2.24+ for !reset) and the course label everywhere
  cat > "$TRABAJO/certcore/compose.override.yaml" <<EOF
services:
  db:
    labels: ["$LABEL"]
  api:
    ports: !reset []
    labels: ["$LABEL"]
    build:
      context: ./docker/php
      labels: ["$LABEL"]
volumes:
  pgdata:
    labels: ["$LABEL"]
EOF
  cd "$TRABAJO/certcore"
  docker compose -p a16-certcore up -d --build 2>&1 | tail -3
  sleep 4
  echo "### GET http://127.0.0.1:3000 desde dentro del contenedor api"
  docker compose -p a16-certcore exec -T api php -r 'echo file_get_contents("http://127.0.0.1:3000/");' | sed 's/^/  /'
  docker compose -p a16-certcore down -v >/dev/null 2>&1
}

limpiar() {
  for p in a16-certcore; do
    [ -f "$TRABAJO/certcore/compose.yaml" ] && (cd "$TRABAJO/certcore" && docker compose -p "$p" down -v --rmi local >/dev/null 2>&1 || true)
  done
  docker ps -aq --filter "label=$LABEL" | xargs -r docker rm -f
  docker network ls -q --filter "label=$LABEL" | xargs -r docker network rm
  docker volume ls -q --filter "label=$LABEL" | xargs -r docker volume rm
  docker images -q --filter "label=$LABEL" | sort -u | xargs -r docker rmi -f
  rm -rf "$TRABAJO"
}

case "${1:-}" in
  php) php_probe ;;
  compose) compose_probe ;;
  limpiar) limpiar ;;
  *) sed -n '2,12p' "$0"; exit 1 ;;
esac
