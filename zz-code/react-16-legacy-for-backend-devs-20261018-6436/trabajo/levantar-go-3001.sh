#!/usr/bin/env bash
# 🪦 Reemplazo: la consola y el mock de Google Play en r16t7-app, y el binario de Go en el 3001 del mismo espacio de red.
# Uso: trabajo/levantar-go-3001.sh [ref]   (ref: rama o tag para el binario; por defecto, el árbol de trabajo)
Z="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$Z/esclusa-app"
if [ -n "${1:-}" ]; then rm -rf "$Z/etapas/go3001"; git -C "$Z/esclusa-app" worktree prune; git -C "$Z/esclusa-app" worktree add -q --detach "$Z/etapas/go3001" "$1" && SRC="$Z/etapas/go3001"; fi
"$Z/trabajo/levantar-app.sh" go >/dev/null
docker rm -f -v r16t7-go3001 >/dev/null 2>&1
docker run -d --name r16t7-go3001 --label curso=react16 --network container:r16t7-app -v "$SRC":/app -v r16t7-gomod:/go/pkg/mod -w /app/server \
  -e DATABASE_URL="${DATABASE_URL:-postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable&timezone=America/Panama}" \
  -e GRANT_DELIVERY_MS="${GRANT_DELIVERY_MS:-800}" -e JWT_SECRET="${JWT_SECRET:-laboratorio-esclusa-secreto-de-32-bytes-o-mas}" -e JWT_TTL="${JWT_TTL:-12h}" golang:1.19.13 go run ./cmd/api >/dev/null
for i in $(seq 1 60); do docker exec r16t7-app curl -s -o /dev/null localhost:3001/health 2>/dev/null && { echo "Go en el 3001"; exit 0; }; sleep 2; done
echo "Go no levantó"; docker logs --tail 20 r16t7-go3001; exit 1
