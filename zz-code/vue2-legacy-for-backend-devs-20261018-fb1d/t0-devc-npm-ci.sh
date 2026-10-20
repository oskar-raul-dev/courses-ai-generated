#!/usr/bin/env bash
# T0.5: npm ci dentro del devcontainer, node_modules en volumen con nombre vs en el bind mount.
docker run --rm --label curso=vue2-legacy --label tanda=T0 -v "$PWD/devc/tiquetera-legacy:/workspace" \
  -v tiquetera-node-modules:/workspace/node_modules vue2-t0-devc:arm64 bash -c 'time npm ci --silent >/dev/null 2>&1; echo EXIT=$?' > salidas/t0/devc-npm-ci-volumen.log 2>&1
docker run --rm --label curso=vue2-legacy --label tanda=T0 -v "$PWD/devc/bind-copy:/workspace" \
  vue2-t0-devc:arm64 bash -c 'time npm ci --silent >/dev/null 2>&1; echo EXIT=$?' > salidas/t0/devc-npm-ci-bind.log 2>&1
