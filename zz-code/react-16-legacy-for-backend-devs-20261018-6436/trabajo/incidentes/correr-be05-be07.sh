#!/usr/bin/env bash
# Pruebas de regresión de be-05, be-06 y be-07: en su rama (rojo) y en fase-be03 (verde), contra esclusa_test migrada.
Z="$(cd "$(dirname "$0")/../.." && pwd)"
run() { # $1 ref  $2 paquete  $3 archivo
  rm -rf "$Z/etapas/inc"; git -C "$Z/esclusa-app" worktree prune
  git -C "$Z/esclusa-app" worktree add -q --detach "$Z/etapas/inc" "$1"
  cp "$Z/trabajo/incidentes/$3" "$Z/etapas/inc/server/internal/$2/"
  docker run --rm --label curso=react16 --network r16t7-net -v "$Z/etapas/inc/server":/src -v r16t7-gomod:/go/pkg/mod -w /src \
    -e TEST_DATABASE_URL="postgres://esclusa:esclusa@pg:5432/esclusa_test?sslmode=disable" golang:1.19.13 sh -c '
    go run -tags postgres github.com/golang-migrate/migrate/v4/cmd/migrate@v4.15.2 -path migrations/postgres -database "$TEST_DATABASE_URL" drop -f >/dev/null 2>&1
    go run -tags postgres github.com/golang-migrate/migrate/v4/cmd/migrate@v4.15.2 -path migrations/postgres -database "$TEST_DATABASE_URL" up >/dev/null 2>&1
    go test -count=1 ./internal/'"$2"'/ 2>&1 | grep -E "^(ok|FAIL|---|    )" | head -6'
  git -C "$Z/esclusa-app" worktree remove --force "$Z/etapas/inc"
}
for spec in "be-05 player be05_pool_test.go" "be-06 spin be06_origin_test.go" "be-07 reconciliation be07_reconciliation_test.go"; do
  set -- $spec
  echo "### $1 en incidente/$1 (rojo)"; run "incidente/$1" "$2" "$3"
  echo "### $1 en fase-be03 (verde)"; run fase-be03-crud-y-el-reemplazo "$2" "$3"
done
