#!/usr/bin/env bash
# be09 de punta a punta: el compose del repo (con trabajo/be09/compose-lab.yml), la siembra, smoke.sh, el recorrido de
# Cypress y la smoke de F10 con la consola de T6. Para el Go del 3001 de los scripts anteriores mientras corre.
# Uso: trabajo/be09-compose.sh [ref]   (por defecto, el árbol de trabajo)
Z="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$Z/esclusa-app"
if [ -n "${1:-}" ]; then rm -rf "$Z/etapas/compose"; git -C "$SRC" worktree prune; git -C "$SRC" worktree add -q --detach "$Z/etapas/compose" "$1"; SRC="$Z/etapas/compose"; fi
docker stop r16t7-go3001 >/dev/null 2>&1
C="docker compose -p r16t10 -f $SRC/server/docker-compose.yml -f $Z/trabajo/be09/compose-lab.yml"
$C up -d --build 2>&1 | tail -4
for i in $(seq 1 60); do docker exec r16t7-app curl -s -o /dev/null localhost:3001/health && break; sleep 2; done
echo "== estado"; $C ps --format '{{.Service}} {{.State}} {{.Status}}'
echo "== migraciones"; $C logs migrate 2>&1 | tail -1
echo "== siembra"
docker exec r16t7-go sh -c 'cd /app/server && DATABASE_URL="postgres://esclusa:esclusa@db:5432/esclusa?sslmode=disable" go run ./cmd/seed -file ../mock/db.json 2>&1 | tail -1'
echo "== smoke.sh"; "$Z/trabajo/tools.sh" 'BASE_URL=http://app:3001 bash server/smoke.sh' 2>&1 | tail -2
echo "== recorrido de Cypress"
docker run --rm --label curso=react16 --network container:r16t7-app -v "$Z/trabajo/recorrido":/e2e -w /e2e cypress/included:10.11.0 --spec cypress/e2e/recorrido.cy.js 2>&1 | grep -E "passing|failing"
echo "== smoke de F10"
docker run --rm --label curso=react16 --network container:r16t7-app -v "$SRC":/app -w /app cypress/included:10.11.0 2>&1 | grep -E "passing|failing"
echo "== la regla del track"; git -C "$SRC" diff --stat pre-backend-go..HEAD -- . ':!server' ':!src/api/authService.js' ':!.github' | tail -1; echo "(vacío si no hay nada arriba)"
