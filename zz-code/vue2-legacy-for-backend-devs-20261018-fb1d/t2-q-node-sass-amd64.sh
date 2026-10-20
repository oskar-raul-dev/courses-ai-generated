#!/usr/bin/env bash
# T2: el mismo build de la ruta Q con node-sass en amd64, para comparar el CSS con el de Dart Sass.
docker run --rm --name vue2-t2-qnodesass --label curso=vue2-legacy --label tanda=T2 --platform linux/amd64 \
  -v "$PWD/q/tiquetera-q-app1:/src:ro" -v "$PWD/salidas/t2-css:/out" node:14.21.3 bash -c '
cp -r /src /w && cd /w && npm ci --silent >/dev/null 2>&1; echo "EXIT_CI=$?"
npx quasar build > /tmp/b.log 2>&1; echo "EXIT_BUILD=$?"; cp dist/spa/css/*.css /out/node-sass-amd64.css'
