#!/usr/bin/env bash
# Regresiones de be-12 y be-18: en su rama (rojo) y en fase-be06 (verde), contra esclusa_test.
# be-12 usa TestSpinRespectsClosing, que ya está en el repo; be-18 agrega free_spin_test.go en internal/http.
Z="$(cd "$(dirname "$0")/../.." && pwd)"
run() { # $1 ref  $2 -run  $3 paquete  $4 archivo extra (opcional)
  rm -rf "$Z/etapas/inc"; git -C "$Z/esclusa-app" worktree prune
  git -C "$Z/esclusa-app" worktree add -q --detach "$Z/etapas/inc" "$1"
  [ -n "${4:-}" ] && cp "$Z/trabajo/incidentes/$4" "$Z/etapas/inc/server/$3/free_spin_test.go"
  docker run --rm --label curso=react16 --network r16t7-net -v "$Z/etapas/inc/server":/src -v r16t7-gomod:/go/pkg/mod -w /src \
    -e TEST_DATABASE_URL="postgres://esclusa:esclusa@pg:5432/esclusa_test?sslmode=disable" golang:1.19.13 \
    sh -c "go test -count=1 -race -run '$2' -v ./$3/ 2>&1 | grep -E '_test.go|^(--- |ok|FAIL)' | head -12"
  git -C "$Z/esclusa-app" worktree remove --force "$Z/etapas/inc"
}
F=fase-be06-hora-dura-y-la-autoridad-del-reloj
echo "### be-12 en incidente/be-12 (rojo)"; run incidente/be-12 TestSpinRespectsClosing internal/spin
echo "### be-12 en $F (verde)";            run $F TestSpinRespectsClosing internal/spin
echo "### be-18 en incidente/be-18 (rojo)"; run incidente/be-18 TestClientClockDoesNotGrantFreeSpins internal/http be18_client_clock_test.go
echo "### be-18 en $F (verde)";            run $F TestClientClockDoesNotGrantFreeSpins internal/http be18_client_clock_test.go
