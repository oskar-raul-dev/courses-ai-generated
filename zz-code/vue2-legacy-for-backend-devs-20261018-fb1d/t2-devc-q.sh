#!/usr/bin/env bash
# T2/T3: la ruta Q (node-sass 4.14.1, node-gyp 3.8.0) dentro de la imagen del devcontainer, arm64.
img=${1:-vue2-t0-devc:arm64}
docker run --rm --label curso=vue2-legacy --label tanda=T2 -v "$PWD/q/tiquetera-q-app1:/src:ro" "$img" bash -c '
cp -r /src /tmp/w && cd /tmp/w && (time npm ci) > /tmp/ci.log 2>&1; e=$?
grep -m6 "gyp ERR! stack Error\|gyp ERR! configure\|Python\|python2\|Installed to\|Binary found" /tmp/ci.log; grep "^real" /tmp/ci.log; echo "EXIT=$e"'
