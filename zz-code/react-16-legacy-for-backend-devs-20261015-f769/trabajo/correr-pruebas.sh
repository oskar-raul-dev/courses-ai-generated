#!/bin/sh
# Uso: [CHAOS_LEVEL=high] [CHAOS_SEED=n] correr-pruebas.sh <directorio-del-proyecto> <prueba>...
#      (las pruebas, en trabajo/ o trabajo/incidentes/)
# Copia las pruebas a src/__pruebas__/, levanta el mock (3001) en un contenedor y corre Jest en otro,
# en serie y en la misma red. Al terminar: mata el mock, devuelve mock/db.json a como estaba antes de
# correr (copia en mock/db.json.antes, no git checkout: así no pisa cambios sin commitear) y borra src/__pruebas__/.
set -u
P="$1"; shift
T="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$P/src/__pruebas__"
for f in "$@"; do
  if [ -f "$T/$f" ]; then cp "$T/$f" "$P/src/__pruebas__/"; else cp "$T/incidentes/$f" "$P/src/__pruebas__/"; fi
done
if [ -f "$P/mock/server.js" ]; then
  # Desde F03 hay mock: se levanta al lado, con el caos que pida la prueba.
  cp "$P/mock/db.json" "$P/mock/db.json.antes"
  MOCK=$(docker run -d --rm --label curso=react16 -v "$P":/app -w /app \
    -e CHAOS_LEVEL="${CHAOS_LEVEL:-off}" -e CHAOS_SEED="${CHAOS_SEED:-0}" node:14.21.3 node mock/server.js)
  PLAY=""
  if [ -f "$P/mock/googlePlay/server.js" ]; then
    # el mock de Google Play (3002) en la misma red, con su propio caos (PLAY_CHAOS_LEVEL)
    PLAY=$(docker run -d --rm --label curso=react16 --network container:$MOCK -v "$P":/app -w /app \
      -e CHAOS_LEVEL="${PLAY_CHAOS_LEVEL:-off}" -e CHAOS_SEED="${CHAOS_SEED:-0}" -e PLAY_PENDING_MS="${PLAY_PENDING_MS:-3000}" \
      node:14.21.3 node mock/googlePlay/server.js)
  fi
  sleep 5
  timeout 600 docker run --rm --label curso=react16 --network container:$MOCK -v "$P":/app -w /app -e CI=true -e TZ="${TZ_PRUEBA:-UTC}" node:14.21.3 \
    sh -c "${PRE:-true} && npx react-scripts test --watchAll=false --forceExit --runInBand src/__pruebas__" 2>&1
  docker logs $MOCK > "$T/../salidas/mock-ultima-corrida.log" 2>&1  # el log del mock: ahí se cuentan las peticiones sin sesión
  if [ -n "$PLAY" ]; then docker logs $PLAY > "$T/../salidas/mock-3002-ultima-corrida.log" 2>&1; docker kill $PLAY >/dev/null 2>&1; fi
  docker kill $MOCK >/dev/null 2>&1
  mv "$P/mock/db.json.antes" "$P/mock/db.json"
else
  # F00–F02: sin mock propio; las pruebas no salen a la red.
  timeout 600 docker run --rm --label curso=react16 -v "$P":/app -w /app -e CI=true -e TZ="${TZ_PRUEBA:-UTC}" node:14.21.3 \
    sh -c "${PRE:-true} && npx react-scripts test --watchAll=false --forceExit --runInBand src/__pruebas__" 2>&1
fi
rm -r "$P/src/__pruebas__"
