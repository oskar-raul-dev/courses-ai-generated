#!/bin/sh
# Uso: correr-incidente.sh <archivo-de-prueba> <directorio-del-proyecto> [sin-mock]
# Corre la prueba en node:14.21.3. Con el mock: lo levanta en otro contenedor con la misma red.
set -u
ARCHIVO="$1"; P="$2"; MODO="${3:-}"
mkdir -p "$P/src/__incidentes__"
cp "$(dirname "$0")/incidentes/$ARCHIVO" "$P/src/__incidentes__/$ARCHIVO"
if [ "$MODO" = "sin-mock" ]; then
  docker run --rm --label curso=react16 -v "$P":/app -w /app -e CI=true node:14.21.3 \
    sh -c "npx react-scripts test --watchAll=false --forceExit src/__incidentes__/$ARCHIVO" 2>&1 | grep -E "Tests:|✓|✕|Expected|Received" | head -8
else
  MOCK=$(docker run -d --rm --label curso=react16 -v "$P":/app -w /app -e CHAOS_LEVEL=off node:14.21.3 node mock/server.js)
  sleep 5
  timeout 300 docker run --rm --label curso=react16 --network container:$MOCK -v "$P":/app -w /app -e CI=true node:14.21.3 \
    sh -c "npx react-scripts test --watchAll=false --forceExit src/__incidentes__/$ARCHIVO" 2>&1 | grep -E "Tests:|✓|✕|Expected|Received" | head -8
  docker kill $MOCK >/dev/null 2>&1
fi
