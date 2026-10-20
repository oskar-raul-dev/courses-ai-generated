#!/usr/bin/env bash
# Segunda ronda de las rutas VU y Q (20/10/2026): con los anuncios de ticket:created, el idioma y el cortafuegos CSS,
# corren las redes de regresión y el build. Usa los volúmenes de node_modules de la tanda navegador. Uso: ./t-rutas-r2.sh
set -uo pipefail
cd "$(dirname "$0")"
R=../vue2-legacy-for-backend-devs-20261014-b44a/rutas
L="--label curso=vue2-legacy --label tanda=navegador"
docker volume create $L vue2-nav-vu-nm >/dev/null; docker volume create $L vue2-nav-q-nm >/dev/null
echo "== VU"
docker run --rm $L -v "$PWD/$R/vu/tiquetera-legacy":/app -v vue2-nav-vu-nm:/app/node_modules -w /app node:14.21.3 bash -c '
  [ -d node_modules/vuetify ] || npm ci --silent >/dev/null 2>&1
  npx vue-cli-service test:unit 2>&1 | grep -E "^Tests:|^Test Suites:"
  npx vue-cli-service build >/tmp/b.log 2>&1; grep -E "Build complete|ERROR" /tmp/b.log | head -2
  echo "bundle con «Filas por página»: $(grep -l "Filas por página" dist/js/*.js | wc -l)"; rm -rf dist'
echo "== Q"
docker run --rm $L -v "$PWD/$R/q/tiquetera-q":/app -v vue2-nav-q-nm:/app/node_modules -w /app node:14.21.3 bash -c '
  [ -d node_modules/quasar ] || npm ci --silent >/dev/null 2>&1
  npx jest 2>&1 | grep -E "^Tests:|^Test Suites:"
  npx quasar build >/tmp/b.log 2>&1; echo "EXIT_BUILD=$?"
  echo "bundle con «Filas por página»: $(grep -l "Filas por página" dist/spa/js/*.js | wc -l)  título: $(grep -o "<title>[^<]*" dist/spa/index.html)"; rm -rf dist'
