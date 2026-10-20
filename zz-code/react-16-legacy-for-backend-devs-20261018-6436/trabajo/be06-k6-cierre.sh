#!/usr/bin/env bash
# be06 / be-12: giros con k6 mientras la rueda de medición cierra. La rueda 900 cierra a los 5 s de empezar la carga;
# el barrido de cierre pasa cada WHEEL_CLOSE_EVERY (por defecto 10 s). Cuenta en SQL los giros de la 900 anotados
# después de su cierre.
# Uso: trabajo/be06-k6-cierre.sh <ref> <etiqueta> [RATE] [KEYS]
set -u
Z="$(cd "$(dirname "$0")/.." && pwd)"
REF="$1"; TAG="$2"; RATE="${3:-20}"; KEYS="${4:-200}"
SRC="$Z/etapas/k6"
rm -rf "$SRC"; git -C "$Z/esclusa-app" worktree prune
git -C "$Z/esclusa-app" worktree add -q --detach "$SRC" "$REF"
OUT="$Z/salidas/be06/k6-cierre-$TAG.txt"
URL="postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable&timezone=America/Panama"
docker rm -f -v r16t7-api >/dev/null 2>&1
docker run -d --name r16t7-api --label curso=react16 --network r16t7-net --network-alias api \
  -v "$SRC":/app -v r16t7-gomod:/go/pkg/mod -w /app/server \
  -e DATABASE_URL="$URL" -e JWT_SECRET=laboratorio-esclusa-secreto-de-32-bytes-o-mas golang:1.19.13 sh -c '
    M="go run -tags postgres github.com/golang-migrate/migrate/v4/cmd/migrate@v4.15.2"
    $M -path migrations/postgres -database "$DATABASE_URL" drop -f >/dev/null 2>&1
    $M -path migrations/postgres -database "$DATABASE_URL" up 2>&1 | tail -1
    go run ./cmd/seed -file ../mock/db.json 2>&1 | tail -1
    touch /tmp/sembrado
    go build -buildvcs=false -o /tmp/api ./cmd/api && exec /tmp/api' >/dev/null
for i in $(seq 1 120); do docker exec r16t7-api test -f /tmp/sembrado 2>/dev/null && break; sleep 1; done
docker exec -i r16t7-pg psql -q -U esclusa -d esclusa < "$SRC/server/load/rueda-de-medicion.sql"
UP=no
for i in $(seq 1 120); do docker exec r16t7-api sh -c 'wget -q -O- localhost:3001/health' >/dev/null 2>&1 && { UP=si; break; }; sleep 1; done
[ "$UP" = si ] || { echo "el binario no levantó"; docker logs --tail 20 r16t7-api; exit 1; }
PSQL="docker exec r16t7-pg psql -U esclusa -d esclusa -Atc"
{
  echo "# be06 · k6 con cierre · ref=$REF rate=$RATE keys=$KEYS · $(date -u +%FT%TZ)"
  $PSQL "UPDATE wheels SET closes_at = now() + interval '5 seconds' WHERE id = 900 RETURNING 'la 900 cierra a las ' || closes_at"
  docker run --rm -i --label curso=react16 --network r16t7-net -e BASE_URL=http://api:3001 -e RATE="$RATE" -e KEYS="$KEYS" \
    grafana/k6:1.5.0 run --quiet --summary-trend-stats "med,p(95),max" - < "$Z/esclusa-app/server/load/giro.js" 2>&1 | grep -A1 -E "respuestas\{" | grep -v "^--"
  echo "## SQL"
  $PSQL "SELECT 'giros de la 900 antes del cierre: ' || count(*) FILTER (WHERE l.created_at <  w.closes_at)
              || ' · después: ' || count(*) FILTER (WHERE l.created_at >= w.closes_at)
              || ' · el último, ' || coalesce(round(extract(epoch FROM max(l.created_at) - w.closes_at)::numeric, 2)::text, '-') || ' s después'
         FROM spin_log l JOIN wheels w ON w.id = l.wheel_id WHERE l.wheel_id = 900 GROUP BY w.closes_at"
  $PSQL "SELECT 'giros en la rueda ' || wheel_id || ': ' || count(*) FROM spin_log WHERE idempotency_key LIKE 'k6-%' GROUP BY wheel_id ORDER BY wheel_id"
  $PSQL "SELECT 'estado de la 900: ' || status FROM wheels WHERE id = 900"
  docker logs r16t7-api 2>&1 | grep -a cierre
} > "$OUT"
docker rm -f -v r16t7-api >/dev/null 2>&1
git -C "$Z/esclusa-app" worktree remove --force "$SRC"
cat "$OUT"
