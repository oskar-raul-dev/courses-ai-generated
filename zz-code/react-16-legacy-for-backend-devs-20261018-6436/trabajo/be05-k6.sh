#!/usr/bin/env bash
# Mide el giro con k6 (grafana/k6:1.5.0) en una base limpia, y cuenta en SQL lo que quedó.
# Uso: trabajo/be05-k6.sh <variante> [RATE] [etiqueta]
#   naive        -> el giro de 2019 (fase-be04-…), sobre el esquema de be04 (sin el UNIQUE)
#   pessimistic  -> be05, árbol de trabajo, SPIN_LOCKING=pessimistic
#   optimistic   -> be05, árbol de trabajo, SPIN_LOCKING=optimistic
#   <ref>:<locking> -> una rama o tag cualquiera (p. ej. incidente/be-09:pessimistic)
# Salida: salidas/be05-k6-<etiqueta>.txt (resumen de k6 y conteo SQL)
set -u
Z="$(cd "$(dirname "$0")/.." && pwd)"
VAR="$1"; RATE="${2:-50}"; TAG="${3:-$VAR-$RATE}"
# RATE puede ser "vusN": escenario notificacion con N usuarios virtuales a la vez.
SCEN=pico; VUS=100
case "$RATE" in vus*) SCEN=notificacion; VUS="${RATE#vus}" ;; esac
TAG="${TAG//\//-}"
REF=""; LOCKING="pessimistic"
case "$VAR" in
  naive) REF="fase-be04-identidad-real-jwt-y-un-cve" ;;
  pessimistic|optimistic) LOCKING="$VAR" ;;
  *:*) REF="${VAR%%:*}"; LOCKING="${VAR##*:}" ;;
esac
SRC="$Z/esclusa-app"
if [ -n "$REF" ]; then
  rm -rf "$Z/etapas/k6"; git -C "$SRC" worktree prune
  git -C "$SRC" worktree add -q --detach "$Z/etapas/k6" "$REF" && SRC="$Z/etapas/k6"
fi
OUT="$Z/salidas/be05-k6-$TAG.txt"
URL="postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable&timezone=America/Panama"
docker rm -f -v r16t7-api >/dev/null 2>&1
docker run -d --name r16t7-api --label curso=react16 --network r16t7-net --network-alias api \
  -v "$SRC":/app -v r16t7-gomod:/go/pkg/mod -w /app/server \
  -e DATABASE_URL="$URL" -e JWT_SECRET=laboratorio-esclusa-secreto-de-32-bytes-o-mas \
  -e SPIN_LOCKING="$LOCKING" golang:1.19.13 sh -c '
    M="go run -tags postgres github.com/golang-migrate/migrate/v4/cmd/migrate@v4.15.2"
    $M -path migrations/postgres -database "$DATABASE_URL" drop -f >/dev/null 2>&1
    $M -path migrations/postgres -database "$DATABASE_URL" up 2>&1 | tail -1
    go run ./cmd/seed -file ../mock/db.json 2>&1 | tail -1
    touch /tmp/sembrado
    go build -buildvcs=false -o /tmp/api ./cmd/api && exec /tmp/api' >/dev/null
for i in $(seq 1 120); do docker exec r16t7-api test -f /tmp/sembrado 2>/dev/null && break; sleep 1; done
if [ -f "$SRC/server/load/rueda-de-medicion.sql" ] && [ "$VAR" != naive ]; then
  docker exec -i r16t7-pg psql -q -U esclusa -d esclusa < "$SRC/server/load/rueda-de-medicion.sql"
fi
UP=no
for i in $(seq 1 120); do docker exec r16t7-api sh -c 'wget -q -O- localhost:3001/health' >/dev/null 2>&1 && { UP=si; break; }; sleep 1; done
if [ "$UP" != si ]; then
  echo "el binario no levantó: no se mide nada"; docker logs --tail 20 r16t7-api 2>&1
  docker rm -f -v r16t7-api >/dev/null 2>&1; exit 1
fi
{
  echo "# be05 · k6 · variante=$VAR ref=${REF:-árbol de trabajo} locking=$LOCKING escenario=$SCEN rate=$RATE · $(date -u +%FT%TZ)"
  docker logs r16t7-api 2>&1 | tail -4
  docker run --rm -i --label curso=react16 --network r16t7-net -e BASE_URL=http://api:3001 -e RATE="${RATE#vus}" -e SCENARIO="$SCEN" -e VUS="$VUS" \
    grafana/k6:1.5.0 run --quiet --summary-trend-stats "med,p(95),p(99),max" - < "$Z/esclusa-app/server/load/giro.js" 2>&1
  echo "## SQL"
  docker exec -i r16t7-pg psql -U esclusa -d esclusa < "$Z/esclusa-app/server/load/medicion.sql"
} > "$OUT"
docker rm -f -v r16t7-api >/dev/null 2>&1
[ -n "$REF" ] && { git -C "$Z/esclusa-app" worktree remove --force "$Z/etapas/k6"; }
grep -E "respuestas\{|http_req_duration\{|esclusas|^ +[0-9-]+ +\|" "$OUT"
