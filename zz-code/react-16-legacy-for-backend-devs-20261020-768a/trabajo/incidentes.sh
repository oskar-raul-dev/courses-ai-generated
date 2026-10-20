#!/usr/bin/env bash
# T12: los incidentes ⭐ y nuevos reproducen su síntoma otra vez (plan §5.1). Cada uno, en su rama (rojo) y
# en la fase que lo arregla (verde). Necesita r16t12-pg y r16t12-net (regresion.sh) y no corre a la par de ella.
# Uso: trabajo/incidentes.sh [fe|be]   → salidas/incidentes-<fe|be>.txt
Z="$(cd "$(dirname "$0")/.." && pwd)"; R="$Z/esclusa-app"; I="$Z/trabajo/incidentes"
DB="postgres://esclusa:esclusa@pg:5432/esclusa_test?sslmode=disable"
wt() { rm -rf "$Z/etapas/inc"; git -C "$R" worktree prune; git -C "$R" worktree add -q --detach "$Z/etapas/inc" "$1"; }
fin() { git -C "$R" worktree remove --force "$Z/etapas/inc"; }
jest1() { # $1 ref  $2 archivo de prueba  $3 destino dentro de src/
  wt "$1"; cp "$I/$2" "$Z/etapas/inc/src/$3"
  docker run --rm --label curso=react16 -v "$Z/etapas/inc":/w -w /w -v r16t12-npm:/root/.npm node:14.21.3 sh -c "
    npm ci --no-audit --no-fund >/dev/null 2>&1; CI=true npx react-scripts test --watchAll=false $3 2>&1 |
    grep -E '✓|✕|Expected|Received|^Tests:' | head -8"; fin; }
gotest() { # $1 ref  $2 -run  $3 paquete  [$4 archivo extra  $5 nombre destino]
  wt "$1"; [ -n "${4:-}" ] && cp "$I/$4" "$Z/etapas/inc/server/$3/$5"
  docker exec r16t12-pg psql -q -U esclusa -d postgres -c 'DROP DATABASE IF EXISTS esclusa_test' -c 'CREATE DATABASE esclusa_test' >/dev/null
  docker run --rm --label curso=react16 --network r16t12-net -v "$Z/etapas/inc/server":/src -v r16t12-gomod:/go/pkg/mod -w /src \
    -e TEST_DATABASE_URL="$DB" golang:1.19.13 sh -c "go test -count=1 -race -run '$2' -v ./$3/ 2>&1 |
    grep -E '_test.go:|^(--- |ok|FAIL)' | head -8"; fin; }

fe() {
  echo "### 11 ⭐ en incidente/11 (rojo)";  jest1 incidente/11 inc11.test.js features/grants/inc11.test.js
  echo "### 11 ⭐ en fase-05 (verde)";      jest1 fase-05-envios-manuales inc11.test.js features/grants/inc11.test.js
  echo "### 14 ⭐ en incidente/14 (rojo)";  jest1 incidente/14 inc14.test.js features/purchases/epics/inc14.test.js
  echo "### 14 ⭐ en fase-07 (verde)";      jest1 fase-07-cierre-polling-compras inc14.test.js features/purchases/epics/inc14.test.js
  echo "### 21 ➕ en fase-09, con la bitácora de la regla vieja y con la nueva"
  wt fase-09-dashboard
  docker run --rm --label curso=react16 -v "$Z/etapas/inc":/w -w /w -v "$I/conteo21.js":/conteo21.js:ro node:14.21.3 sh -c '
    npm ci --no-audit --no-fund >/dev/null 2>&1
    node mock/seed-reconciliation.js --accommodating >/dev/null && echo "regla vieja:" && node /conteo21.js
    node mock/seed-reconciliation.js >/dev/null && echo "regla nueva:" && node /conteo21.js'
  fin
}
be() {
  echo "### be-09 ⭐ en incidente/be-09 (rojo)"; gotest incidente/be-09 TestStockNeverExceeded internal/spin
  echo "### be-09 ⭐ en fase-be05 (verde)";      gotest fase-be05-giro-concurrente TestStockNeverExceeded internal/spin
  echo "### be-17 en incidente/be-17 (rojo)";    gotest incidente/be-17 TestTwoBootsDrawDifferentSequences internal/spin be17_two_boots_test.go random_test.go
  echo "### be-17 en fase-be05 (verde)";         gotest fase-be05-giro-concurrente TestTwoBootsDrawDifferentSequences internal/spin be17_two_boots_test.go random_test.go
  echo "### be-18 en incidente/be-18 (rojo)";    gotest incidente/be-18 TestClientClockDoesNotGrantFreeSpins internal/http be18_client_clock_test.go free_spin_test.go
  echo "### be-18 en fase-be06 (verde)";         gotest fase-be06-hora-dura-y-la-autoridad-del-reloj TestClientClockDoesNotGrantFreeSpins internal/http be18_client_clock_test.go free_spin_test.go
  for ref in incidente/be-15 fase-be08-pruebas-y-la-regla-del-motor; do
    echo "### be-15 ⭐ en $ref: la suite sin base (SQLite) y contra Postgres"; wt "$ref"
    docker exec r16t12-pg psql -q -U esclusa -d postgres -c 'DROP DATABASE IF EXISTS esclusa_test' -c 'CREATE DATABASE esclusa_test' >/dev/null
    docker run --rm --label curso=react16 --network r16t12-net -v "$Z/etapas/inc":/app -v r16t12-gomod:/go/pkg/mod -w /app/server golang:1.19.13 sh -c "
      echo '--- sin TEST_DATABASE_URL'; go test -count=1 ./... 2>&1 | grep -E '^(ok|FAIL)'
      echo '--- contra Postgres'; TEST_DATABASE_URL='$DB' go test -count=1 -p 1 ./... 2>&1 | grep -E '^(ok|FAIL)|^--- FAIL|LastInsertId' | head -12"
    fin
  done
}
mkdir -p "$Z/salidas"
be15() { for ref in incidente/be-15 fase-be08-pruebas-y-la-regla-del-motor; do
    echo "### be-15 ⭐ en $ref: la suite sin base (SQLite) y contra Postgres"; wt "$ref"
    docker exec r16t12-pg psql -q -U esclusa -d postgres -c 'DROP DATABASE IF EXISTS esclusa_test' -c 'CREATE DATABASE esclusa_test' >/dev/null
    docker run --rm --label curso=react16 --network r16t12-net -v "$Z/etapas/inc":/app -v r16t12-gomod:/go/pkg/mod -w /app/server golang:1.19.13 sh -c "
      echo '--- sin TEST_DATABASE_URL'; go test -count=1 ./... 2>&1 | grep -E '^(ok|FAIL)'
      echo '--- contra Postgres'; TEST_DATABASE_URL='$DB' go test -count=1 -p 1 ./... 2>&1 | grep -E '^(ok|FAIL)|^--- FAIL|LastInsertId|TEST_DATABASE_URL' | head -12"
    fin; done; }
case "${1:-fe}" in be15) be15 | tee "$Z/salidas/incidentes-be15.txt" ;; fe) fe | tee "$Z/salidas/incidentes-fe.txt" ;; be) be | tee "$Z/salidas/incidentes-be.txt" ;; esac
