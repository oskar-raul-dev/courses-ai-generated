#!/bin/sh
# Uso: correr-medicion.sh <directorio-del-proyecto>
# Levanta el servidor de desarrollo de la fase (npm start) en un contenedor y corre la medición
# del tablero con cypress/included:10.11.0 (Electron, headless) en la misma red. La media de cada
# variante la calcula la propia especificación (meanMs). Resultados: trabajo/cypress-bench/resultados/.
set -u
P="$1"
T="$(cd "$(dirname "$0")/.." && pwd)"
DEV=$(docker run -d --rm --label curso=react16 -v "$P":/app -w /app -e BROWSER=none node:14.21.3 npm start)
for i in $(seq 1 120); do
  docker logs "$DEV" 2>&1 | grep -q "Compiled" && break
  sleep 2
done
timeout 900 docker run --rm --label curso=react16 --network container:"$DEV" -v "$T":/e2e -w /e2e \
  cypress/included:10.11.0 --config-file cypress-bench/cypress.config.js --browser electron 2>&1 | tail -25
docker kill "$DEV" >/dev/null 2>&1
