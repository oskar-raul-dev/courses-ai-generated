#!/usr/bin/env bash
# be-15: la suite contra SQLite y contra Postgres, en la rama y en la fase; y el alta de una rueda con el binario de la rama.
Z="$(cd "$(dirname "$0")/../.." && pwd)"
suite() { # $1 ref
  rm -rf "$Z/etapas/inc"; git -C "$Z/esclusa-app" worktree prune
  git -C "$Z/esclusa-app" worktree add -q --detach "$Z/etapas/inc" "$1"
  docker run --rm --label curso=react16 --network r16t7-net -v "$Z/etapas/inc":/app -v r16t7-gomod:/go/pkg/mod -w /app/server golang:1.19.13 sh -c '
    echo "--- sin TEST_DATABASE_URL (SQLite y lo que se salte)"; go test -count=1 ./... 2>&1 | grep -E "^(ok|FAIL)"
    echo "--- contra Postgres"; TEST_DATABASE_URL="postgres://esclusa:esclusa@pg:5432/esclusa_test?sslmode=disable" go test -count=1 -p 1 ./... 2>&1 | grep -E "^(ok|FAIL)|^--- FAIL|LastInsertId" | head -12'
  git -C "$Z/esclusa-app" worktree remove --force "$Z/etapas/inc"
}
echo "### incidente/be-15"; suite incidente/be-15
echo "### fase-be08"; suite fase-be08-pruebas-y-la-regla-del-motor
echo "### el binario de la rama: crear una rueda"
git -C "$Z/esclusa-app" checkout -q incidente/be-15
"$Z/trabajo/go-reiniciar.sh" >/dev/null 2>&1
"$Z/trabajo/tools.sh" '
B=http://r16t7-go:3011
TOKEN=$(curl -s -X POST $B/login -H "Content-Type: application/json" -d "{\"email\":\"ibatista@esclusa.test\",\"password\":\"esclusa123\"}" | jq -r .token)
SEG=$(curl -s -H "Authorization: Bearer $TOKEN" "$B/segments?wheelId=4" | jq -c "map({segmentId, prizeType, weightBp})")
curl -s -w " → %{http_code}\n" -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d "{\"name\":\"Rueda de prueba\",\"closesAt\":\"2030-12-20T20:00:00-05:00\",\"status\":\"draft\",\"timezone\":\"America/Panama\",\"segments\":$SEG}" $B/wheels'
docker exec r16t7-go grep -a "ERROR" /tmp/api.log | tail -1 | cut -c1-200
git -C "$Z/esclusa-app" checkout -q master
