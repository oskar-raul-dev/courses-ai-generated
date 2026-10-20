#!/bin/sh
# El puente de F11 y A8: las mismas pruebas sobre el repo (React 16, RxJS 6) y sobre cada copia descartable.
# Uso: t6-puente.sh <dir-de-la-copia> [VARIABLE=valor ...]   (las pruebas, en trabajo/puente/)
set -u
C="$1"; shift
T="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$C/src/__puente__"
cp "$T"/puente/* "$C/src/__puente__/"
ENVS=""; for e in "$@"; do ENVS="$ENVS -e $e"; done
timeout 600 docker run --rm --label curso=react16 -v "$C":/app -w /app -e CI=true $ENVS node:14.21.3 \
  npx react-scripts test --watchAll=false src/__puente__ src/features/grants/epics src/features/purchases/epics 2>&1
for f in "$T"/puente/*; do mv "$C/src/__puente__/$(basename "$f")" "$T/../salidas/puente-apartado-$(basename "$C")-$(basename "$f")"; done
