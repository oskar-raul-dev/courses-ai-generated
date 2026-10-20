#!/usr/bin/env bash
# be-14 con el binario: la compra de trabajo/be07-compra.sh (dos avisos del juego y la notificación duplicada) sobre <ref>.
# Uso: trabajo/incidentes/be14-binario.sh <ref>   (cambia el árbol de esclusa-app a <ref> y vuelve a master)
Z="$(cd "$(dirname "$0")/../.." && pwd)"
git -C "$Z/esclusa-app" checkout -q "$1"
echo "# be-14 · $1 · $(date -u +%FT%TZ)"
"$Z/trabajo/be07-compra.sh"
echo "== log"; docker exec r16t7-go grep -a "ERROR" /tmp/api.log | tail -3 | cut -c1-220
git -C "$Z/esclusa-app" checkout -q master
