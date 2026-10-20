#!/usr/bin/env bash
# T0.6: suite de F13 (Curso 02) con mongodb-memory-server 6.9.6 en una plataforma dada.
plat=$1
docker run --rm --name "vue2-t0-mms-${plat#linux/}" --label curso=vue2-legacy --label tanda=T0 --platform "$plat" \
  -v "$PWD/backend/tiquetera-backend:/src:ro" node:14.21.3 bash -c '
  cp -r /src /w && cd /w && node -p "process.version + \" \" + process.arch"
  npm ci --silent >/dev/null 2>&1; echo "EXIT_CI=$?"
  (time node node_modules/.bin/jest --runInBand --ci) 2>&1 | tail -40; echo "EXIT_JEST=${PIPESTATUS[0]}"'
