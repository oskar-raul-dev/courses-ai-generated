#!/usr/bin/env bash
# T0: qué binarios publican node-sass 4.14.1 (ABI 83 = Node 14) y Node 14.21.3, por plataforma.
docker run --rm --label curso=vue2-legacy --label tanda=T0 node:14.21.3 bash -c '
for a in darwin-arm64-83 darwin-x64-83 linux-arm64-83 linux-x64-83; do
  echo "$a $(curl -s -o /dev/null -w "%{http_code}" -L https://github.com/sass/node-sass/releases/download/v4.14.1/${a}_binding.node)"; done
for a in darwin-arm64 darwin-x64; do
  echo "node v14.21.3 $a $(curl -s -o /dev/null -w "%{http_code}" -I https://nodejs.org/dist/v14.21.3/node-v14.21.3-$a.tar.gz)"; done' > salidas/t0/binarios-macos.log
