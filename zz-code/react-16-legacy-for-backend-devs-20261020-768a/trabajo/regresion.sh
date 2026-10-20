#!/usr/bin/env bash
# Regresión de T12 (plan §5.1): en cada tag de cierre, npm ci y la suite de Jest (o el build, si el tag
# todavía no tiene pruebas) en node:14.21.3; desde be04, además go test ./... -race contra postgres:13.
# -p 1: los paquetes migran la misma base de pruebas (be06 §5); sin él, se pisan. SOLO_GO=1 salta el frontend.
# Uso, desde el directorio de la tanda: trabajo/regresion.sh [tag ...]   → salidas/regresion/<tag>.log
Z="$(cd "$(dirname "$0")/.." && pwd)"
REPO="$Z/esclusa-app"; OUT="$Z/salidas/regresion"; mkdir -p "$OUT" "$Z/etapas"
TAGS=("$@")
[ ${#TAGS[@]} -eq 0 ] && TAGS=(fase-02-autenticacion-minima fase-03-mock-api-express-caos fase-05-envios-manuales
  fase-07-cierre-polling-compras fase-08-conciliacion fase-11-cierre-puente-react-moderno
  fase-be04-identidad-real-jwt-y-un-cve fase-be05-giro-concurrente fase-be07-compras-y-conciliacion
  fase-be09-empaquetado-ambientes-y-pipeline)

docker network inspect r16t12-net >/dev/null 2>&1 || docker network create --label curso=react16 r16t12-net >/dev/null
if ! docker inspect r16t12-pg >/dev/null 2>&1; then
  docker run -d --name r16t12-pg --label curso=react16 --network r16t12-net --network-alias pg \
    -e POSTGRES_USER=esclusa -e POSTGRES_PASSWORD=esclusa -e POSTGRES_DB=esclusa_test postgres:13 >/dev/null
fi
for i in $(seq 1 30); do docker exec r16t12-pg pg_isready -U esclusa >/dev/null 2>&1 && break; sleep 1; done
DB="postgres://esclusa:esclusa@pg:5432/esclusa_test?sslmode=disable"

for t in "${TAGS[@]}"; do
  W="$Z/etapas/$t"; L="$OUT/$t.log"
  [ -d "$W" ] || git -C "$REPO" worktree add -q --detach "$W" "$t"
  echo "== $t ($(date '+%F %T'))" | tee "$L"
  if git -C "$W" ls-files | grep -q '\.test\.js$'; then FE='CI=true npm test -- --watchAll=false 2>&1 | grep -E "^(Tests|Test Suites):|✕"'
  else FE='CI=true npm run build 2>&1 | grep -E "Compiled|Failed"'; fi
  [ -z "${SOLO_GO:-}" ] && docker run --rm --label curso=react16 -v "$W":/w -w /w -v r16t12-npm:/root/.npm node:14.21.3 sh -c "
    s=\$(date +%s); npm ci --no-audit --no-fund >/tmp/ci 2>&1; echo \"npm ci → código \$? en \$((\$(date +%s)-s)) s\"; tail -1 /tmp/ci
    $FE; echo \"front → fin\"" 2>&1 | tee -a "$L"
  if [ -d "$W/server" ]; then
    TAGSGO=""; grep -q 'sqlite' "$W/server/go.mod" && TAGSGO="-tags sqlite"
    docker exec r16t12-pg psql -q -U esclusa -d postgres -c 'DROP DATABASE IF EXISTS esclusa_test' -c 'CREATE DATABASE esclusa_test' >/dev/null
    docker run --rm --label curso=react16 --network r16t12-net -v "$W":/repo:ro -v r16t12-gomod:/go/pkg/mod \
      -e TEST_DATABASE_URL="$DB" golang:1.19.13 sh -c "mkdir /w && tar -C /repo --exclude=node_modules -cf - . | tar -C /w -xf - && cd /w/server && gofmt -l . && go vet $TAGSGO ./... &&
        go test $TAGSGO -race -count=1 -p 1 ./... >/tmp/gt 2>&1; rc=\$?; grep -E '^(ok|FAIL|--- FAIL|--- SKIP|panic)' /tmp/gt; echo \"go test → código \$rc\"" 2>&1 | tee -a "$L"
  fi
done
