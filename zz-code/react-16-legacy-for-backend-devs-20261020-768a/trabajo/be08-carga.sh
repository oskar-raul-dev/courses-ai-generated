#!/usr/bin/env bash
# be08: el nivel de carga. k6 (giro.js, con sus thresholds) y después las invariantes en SQL (invariantes.sql de
# master), con el código de salida de cada uno. Uso: trabajo/be08-carga.sh <ref> <etiqueta> [RATE|vusN]
set -u
Z="$(cd "$(dirname "$0")/.." && pwd)"
REF="$1"; TAG="$2"; RATE="${3:-vus200}"
SCEN=pico; VUS=100
case "$RATE" in vus*) SCEN=notificacion; VUS="${RATE#vus}" ;; esac
SRC="$Z/etapas/k6"; rm -rf "$SRC"; git -C "$Z/esclusa-app" worktree prune
git -C "$Z/esclusa-app" worktree add -q --detach "$SRC" "$REF"
OUT="$Z/salidas/be08-carga-$TAG.txt"
URL="postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable&timezone=America/Panama"
docker rm -f -v r16t12-api >/dev/null 2>&1
docker run -d --name r16t12-api --label curso=react16 --network r16t12-net --network-alias api \
  -v "$SRC":/app -v r16t12-gomod:/go/pkg/mod -w /app/server \
  -e DATABASE_URL="$URL" -e JWT_SECRET=laboratorio-esclusa-secreto-de-32-bytes-o-mas golang:1.19.13 sh -c '
    M="go run -tags postgres github.com/golang-migrate/migrate/v4/cmd/migrate@v4.15.2"
    $M -path migrations/postgres -database "$DATABASE_URL" drop -f >/dev/null 2>&1
    $M -path migrations/postgres -database "$DATABASE_URL" up 2>&1 | tail -1
    go run ./cmd/seed -file ../mock/db.json 2>&1 | tail -1
    touch /tmp/sembrado
    go build -buildvcs=false -o /tmp/api ./cmd/api && exec /tmp/api' >/dev/null
for i in $(seq 1 120); do docker exec r16t12-api test -f /tmp/sembrado 2>/dev/null && break; sleep 1; done
docker exec -i r16t12-pg psql -q -U esclusa -d esclusa < "$SRC/server/load/rueda-de-medicion.sql"
for i in $(seq 1 120); do docker exec r16t12-api sh -c 'wget -q -O- localhost:3001/health' >/dev/null 2>&1 && break; sleep 1; done
{
  echo "# be08 · nivel de carga · ref=$REF escenario=$SCEN rate=$RATE · $(date -u +%FT%TZ)"
  docker run --rm -i --label curso=react16 --network r16t12-net -e BASE_URL=http://api:3001 -e RATE="${RATE#vus}" \
    -e SCENARIO="$SCEN" -e VUS="$VUS" grafana/k6:1.5.0 run --quiet --summary-trend-stats "med,p(95),max" - \
    < "$SRC/server/load/giro.js" 2>&1 | grep -E "THRESHOLDS|✓|✗|http_req_failed|http_req_duration|level=error"
  echo "k6: código de salida ${PIPESTATUS[0]}"
  docker exec -i r16t12-pg psql -v ON_ERROR_STOP=1 -U esclusa -d esclusa < "$Z/esclusa-app/server/load/invariantes.sql" 2>&1
  echo "invariantes: código de salida $?"
} > "$OUT"
docker rm -f -v r16t12-api >/dev/null 2>&1
git -C "$Z/esclusa-app" worktree remove --force "$SRC"
cat "$OUT"
