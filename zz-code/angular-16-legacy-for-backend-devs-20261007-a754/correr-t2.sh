#!/usr/bin/env bash
# T2: extrae del markdown core/{models,domain,time,pdf}, compila con tsc 5.1.6 en
# node:18.18.2-alpine y saca la línea base de tiempo. Corre desde cualquier sitio.
set -euo pipefail
AQUI="$(cd "$(dirname "$0")" && pwd)"
CURSO="${CURSO:-$AQUI/../../cursos-legacy/angular-16-legacy-for-backend-devs}"
IMAGEN="node:18.18.2-alpine"
mkdir -p "$AQUI/salidas"

python3 "$AQUI/extraer.py" --curso "$CURSO" | tee "$AQUI/salidas/extraccion.txt"

corre() {
  docker run --rm --label curso=angular16 -e NPM_CONFIG_UPDATE_NOTIFIER=false -v "$AQUI":/w -w /w "$IMAGEN" sh -c "$1"
}

[ -d "$AQUI/node_modules" ] || corre "npm install --no-audit --no-fund --loglevel=error"

# 1. Los bloques que T2 tocó (tsconfig.tocados.json), con sus dependencias: tsc sigue los import.
corre "npx tsc -p tsconfig.tocados.json" \
  > "$AQUI/salidas/tsc-tocados.txt" 2>&1 && echo "tsc tocados: OK" || { echo "tsc tocados: FALLA"; cat "$AQUI/salidas/tsc-tocados.txt"; }

# 2. Todo core/ extraído (tsconfig.core.json), para ver qué más no compila (informativo).
corre "npx tsc -p tsconfig.core.json" \
  > "$AQUI/salidas/tsc-core-completo.txt" 2>&1 && echo "tsc core completo: OK" || echo "tsc core completo: con errores (ver salidas/tsc-core-completo.txt)"

# 3. La línea base.
corre "npx tsc -p tsconfig.run.json && node salidas/js/pruebas/linea-base.js" > "$AQUI/salidas/linea-base.json" 2> "$AQUI/salidas/linea-base.err"
echo "línea base: salidas/linea-base.json"
