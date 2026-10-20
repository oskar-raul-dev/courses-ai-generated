#!/usr/bin/env bash
# T0.5: la suite de F11 dentro del devcontainer, con node_modules en el volumen.
docker run --rm --label curso=vue2-legacy --label tanda=T0 -v "$PWD/devc/tiquetera-legacy:/workspace" \
  -v tiquetera-node-modules:/workspace/node_modules vue2-t0-devc:arm64 bash -c '
node -p "process.arch"; ls node_modules/deasync/bin | grep linux-arm64; npm run test:unit 2>&1 | grep -E "^Tests:|^Test Suites:"'
