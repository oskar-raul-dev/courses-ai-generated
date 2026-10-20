#!/usr/bin/env bash
# node-sass sigue en el manifiesto pero sin compilar (npm ci --ignore-scripts) en arm64 sin python2:
# ¿build-angular cae solo en Dart Sass? Proyecto: devc/clinical-lab-sass. Uso: ./t0-ignore-scripts.sh
set -uo pipefail
cd "$(dirname "$0")"
TAG=a8-t0-devc-sinpy2:arm64; VOL=a8-t0-nm-ignore; L="--label curso=angular-8-legacy --label tanda=AS"
docker volume rm "$VOL" >/dev/null 2>&1; docker volume create $L "$VOL" >/dev/null
docker run --rm $L -u node -v "$PWD/devc/clinical-lab-sass:/workspace" -v "$VOL:/workspace/node_modules" -w /workspace $TAG \
  bash -c 'time npm ci --ignore-scripts > /tmp/ci.log 2>&1; echo EXIT_NPM_CI=$?; tail -1 /tmp/ci.log; ls node_modules/node-sass/vendor 2>&1'
./t0-sass-build.sh linux/arm64 $TAG $VOL ignore-scripts-arm64
docker volume rm "$VOL" >/dev/null
