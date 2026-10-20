#!/usr/bin/env bash
# Regresiones de be-13 y be-14: en su rama (rojo) y en fase-be07 (verde), contra esclusa_test.
# be-13 agrega stale_client_test.go en internal/reconciliation; be-14 usa la prueba que ya está en el repo.
Z="$(cd "$(dirname "$0")/../.." && pwd)"
run() { # $1 ref  $2 -run  $3 paquete  $4 archivo extra (opcional)
  rm -rf "$Z/etapas/inc"; git -C "$Z/esclusa-app" worktree prune
  git -C "$Z/esclusa-app" worktree add -q --detach "$Z/etapas/inc" "$1"
  [ -n "${4:-}" ] && cp "$Z/trabajo/incidentes/$4" "$Z/etapas/inc/server/$3/stale_client_test.go"
  docker run --rm --label curso=react16 --network r16t7-net -v "$Z/etapas/inc/server":/src -v r16t7-gomod:/go/pkg/mod -w /src \
    -e TEST_DATABASE_URL="postgres://esclusa:esclusa@pg:5432/esclusa_test?sslmode=disable" golang:1.19.13 \
    sh -c "go test -count=1 -race -run '$2' -v ./$3/ 2>&1 | grep -E '_test.go|^(--- |ok|FAIL)' | head -12"
  git -C "$Z/esclusa-app" worktree remove --force "$Z/etapas/inc"
}
F=fase-be07-compras-y-conciliacion
echo "### be-13 en incidente/be-13 (rojo)"; run incidente/be-13 TestReconcileIgnoresStaleClient internal/reconciliation be13_stale_client_test.go
echo "### be-13 en $F (verde)";            run $F TestReconcileIgnoresStaleClient internal/reconciliation be13_stale_client_test.go
echo "### be-14 en incidente/be-14 (rojo)"; run incidente/be-14 TestDuplicateNotificationCreditsOnce internal/purchase
echo "### be-14 en $F (verde)";            run $F TestDuplicateNotificationCreditsOnce internal/purchase
