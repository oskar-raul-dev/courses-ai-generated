#!/usr/bin/env bash
# T2 (a6 §3, opción C): ruta Q en arm64 sin build tools, con sass (Dart) en vez de node-sass.
# 1) npm ci --ignore-scripts y build tal cual (node-sass sin binding) 2) sass@1.32.13 + implementation.
docker run --rm --name vue2-t2-qsass --label curso=vue2-legacy --label tanda=T2 --platform linux/arm64 \
  -v "$PWD/q/tiquetera-q-app1:/src:ro" -v "$PWD/salidas/t2-css:/out" node:14.21.3-bullseye-slim bash -c '
cp -r /src /w && cd /w && node -p "process.version + \" \" + process.arch"
npm ci --ignore-scripts --silent >/dev/null 2>&1; echo "EXIT_CI=$?"
echo "## build con node-sass sin binding"
npx quasar build > /tmp/b1.log 2>&1; echo "EXIT_BUILD1=$?"; sed "s/\x1b\[[0-9;]*m//g" /tmp/b1.log | tr -s " " | grep -m3 "Node Sass\|supported\|releases/tag"
echo "## cambio"
npm install --save-dev --save-exact --ignore-scripts sass@1.32.13 2>&1 | tail -2; grep "\"sass\"" package.json
sed -i "s#      vueRouterMode: .hash.,.*#&\n\n      // node-sass no tiene binario arm64: Dart Sass compila en JavaScript\n      // y no conoce el estilo \"nested\" que Quasar 1 pone por defecto\n      scssLoaderOptions: { implementation: require(\"sass\"), sassOptions: { outputStyle: \"expanded\" } },\n      sassLoaderOptions: { implementation: require(\"sass\"), sassOptions: { outputStyle: \"expanded\" } },#" quasar.conf.js
sed -n 46,52p quasar.conf.js
echo "## build con sass"
(time npx quasar build) > /tmp/b2.log 2>&1; echo "EXIT_BUILD2=$?"; sed "s/\x1b\[[0-9;]*m//g" /tmp/b2.log | grep -v "^\s*$" | grep -B2 -A12 -m2 "Error" | head -60; grep -E "^real" /tmp/b2.log
ls dist/spa | head; ls dist/spa/css; cp dist/spa/css/*.css /out/dart-arm64.css'
