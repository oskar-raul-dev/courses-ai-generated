#!/usr/bin/env bash
# Banco del cortafuegos CSS de la ruta Q: build de qcss/ (copia del árbol Q con /css-prueba), servido
# por http-server y fotografiado con Chromium headless. Uso: ./t-qcss.sh <nombre de la captura>
set -uo pipefail
cd "$(dirname "$0")"
N=${1:-antes}; L="--label curso=vue2-legacy --label tanda=qcss"; NET=vue2-qcss-net
docker network create $L $NET >/dev/null 2>&1
docker volume create $L vue2-qcss-nm >/dev/null
docker run --rm $L -v "$PWD/qcss":/app -v vue2-qcss-nm:/app/node_modules -w /app node:14.21.3 \
  bash -c '[ -d node_modules/quasar ] || npm ci --silent >/tmp/ci.log 2>&1; npx quasar build > /tmp/b.log 2>&1; echo EXIT_BUILD=$?; grep -i -E "error" /tmp/b.log | head -3'
docker rm -f vue2-qcss-web >/dev/null 2>&1
docker run -d --name vue2-qcss-web $L --network $NET -v "$PWD/qcss/dist/spa":/srv -w /srv node:14.21.3 npx -p http-server@14.1.1 http-server -p 8080 -s --proxy "http://localhost:8080?" >/dev/null
sleep 12
docker run --rm $L --network $NET -v "$PWD/salidas/qcss":/out zenika/alpine-chrome:124 \
  --no-sandbox --hide-scrollbars --virtual-time-budget=4000 --window-size=600,420 --screenshot=/out/$N.png "http://vue2-qcss-web:8080/css-prueba" 2>&1 | grep -v -i -E 'dbus|fontconfig|^$' | tail -2
docker rm -f vue2-qcss-web >/dev/null
ls -l salidas/qcss/$N.png
