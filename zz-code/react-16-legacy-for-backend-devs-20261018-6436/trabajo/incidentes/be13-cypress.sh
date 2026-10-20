#!/usr/bin/env bash
# be-13 en la consola: el binario de <ref> en el 3001, la base sembrada de nuevo, y la conciliación con datos viejos.
# Uso: trabajo/incidentes/be13-cypress.sh <ref>
Z="$(cd "$(dirname "$0")/../.." && pwd)"
"$Z/trabajo/go-reiniciar.sh" >/dev/null 2>&1
"$Z/trabajo/levantar-go-3001.sh" "$1" | tail -1
echo "# be-13 · $1"
docker run --rm --label curso=react16 --network container:r16t7-app -v "$Z/trabajo/recorrido":/e2e -w /e2e \
  cypress/included:10.11.0 --spec cypress/e2e/be13-conciliacion.cy.js 2>&1 | grep -E "passing|failing|Error"
echo "guardado: $(cat "$Z/trabajo/recorrido/salida/be13.json" | tr -d '\n ')"
docker logs r16t7-go3001 2>&1 | grep -a "difiere" | tail -1 | cut -c1-400
