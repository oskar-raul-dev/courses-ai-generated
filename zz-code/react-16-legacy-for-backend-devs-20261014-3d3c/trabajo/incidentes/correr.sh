#!/bin/sh
# Uso: correr.sh <archivo-de-prueba> <directorio-del-proyecto>
# Copia la prueba a src/__incidentes__ (excluido de git) y la corre en node:14.21.3.
set -u
ARCHIVO="$1"
P="$2"
mkdir -p "$P/src/__incidentes__"
cp "$(dirname "$0")/$ARCHIVO" "$P/src/__incidentes__/$ARCHIVO"
docker run --rm --label curso=react16 -v "$P":/app -w /app -e CI=true node:14.21.3 \
  sh -c "npx react-scripts test --watchAll=false src/__incidentes__/$ARCHIVO" 2>&1 \
  | grep -E "Tests:|✓|✕|Expected|Received" | head -8
