#!/usr/bin/env bash
# Regresiones de be-09, be-10 y be-17: en su rama (rojo) y en fase-be05 (verde), contra esclusa_test.
# be-09 usa la prueba que ya está en el repo; be-10 agrega processing_test.go y be-17, random_test.go.
Z="$(cd "$(dirname "$0")/../.." && pwd)"
run() { # $1 ref  $2 -run  $3 archivo extra (opcional)
  rm -rf "$Z/etapas/inc"; git -C "$Z/esclusa-app" worktree prune
  git -C "$Z/esclusa-app" worktree add -q --detach "$Z/etapas/inc" "$1"
  [ -n "${3:-}" ] && cp "$Z/trabajo/incidentes/$3" "$Z/etapas/inc/server/internal/spin/${4:-processing_test.go}"
  docker run --rm --label curso=react16 --network r16t7-net -v "$Z/etapas/inc/server":/src -v r16t7-gomod:/go/pkg/mod -w /src \
    -e TEST_DATABASE_URL="postgres://esclusa:esclusa@pg:5432/esclusa_test?sslmode=disable" golang:1.19.13 \
    sh -c "go test -count=1 -race -run '$2' -v ./internal/spin/ 2>&1 | grep -E '_test.go|^(--- |ok|FAIL)' | head -8"
  git -C "$Z/esclusa-app" worktree remove --force "$Z/etapas/inc"
}
echo "### be-09 en incidente/be-09 (rojo)"; run incidente/be-09 'TestStockNeverExceeded'
echo "### be-09 en fase-be05 (verde)";     run fase-be05-giro-concurrente 'TestStockNeverExceeded'
echo "### be-10 en incidente/be-10 (rojo)"; run incidente/be-10 'TestSpinCutDuringDeliveryRecovers' be10_processing_test.go
echo "### be-10 en fase-be05 (verde)";     run fase-be05-giro-concurrente 'TestSpinCutDuringDeliveryRecovers' be10_processing_test.go
echo "### be-17 en incidente/be-17 (rojo)"; run incidente/be-17 'TestTwoBootsDrawDifferentSequences' be17_two_boots_test.go random_test.go
echo "### be-17 en fase-be05 (verde)";     run fase-be05-giro-concurrente 'TestTwoBootsDrawDifferentSequences' be17_two_boots_test.go random_test.go
