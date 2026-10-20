#!/usr/bin/env bash
# Corre el devcontainer candidato como lo arma VS Code (bind en /workspace, volumen en node_modules,
# usuario node, postCreateCommand npm ci) y prueba ng build, ng test, ng serve y la recarga.
# Uso: ./t0-devc-run.sh <linux/arm64|linux/amd64> [proyecto] [tag]
set -uo pipefail
cd "$(dirname "$0")"
PLAT=${1:-linux/arm64}; A=${PLAT#linux/}; PROY=${2:-devc/clinical-lab}; TAG=${3:-a8-t0-devc:$A}
CN=a8-t0-devc-$A; VOL=a8-t0-lab-node-modules-$A
L="--label curso=angular-8-legacy --label tanda=AS"
docker rm -f -v "$CN" >/dev/null 2>&1; docker volume rm "$VOL" >/dev/null 2>&1
docker volume create $L "$VOL" >/dev/null
docker run -d --name "$CN" $L --platform "$PLAT" -u node \
  -v "$PWD/$PROY:/workspace" -v "$VOL:/workspace/node_modules" -w /workspace \
  -p 127.0.0.1::4200 "$TAG" sleep infinity >/dev/null
echo "== volumen"; docker exec "$CN" ls -ld node_modules
echo "== postCreateCommand: npm ci"
docker exec "$CN" bash -c 'time npm ci > /tmp/npm-ci.log 2>&1; echo EXIT_NPM_CI=$?; grep -E "node-sass@|Downloading binary|HTTP error|Building|Installed to|Binary|gyp ERR|fsevents|added [0-9]+ packages" /tmp/npm-ci.log | head -30; find node_modules/node-sass/vendor -name binding.node'
echo "== ng build"
docker exec "$CN" bash -c 'time npx ng build > /tmp/build.log 2>&1; echo EXIT_BUILD=$?; tail -12 /tmp/build.log'
echo "== ng test"
docker exec "$CN" bash -c 'time npx ng test --watch=false --browsers=ChromeHeadlessNoSandbox > /tmp/test.log 2>&1; echo EXIT_TEST=$?; grep -E "Executed .* (SUCCESS|FAILED)|TOTAL|ERROR" /tmp/test.log | tail -3'
docker rm -f -v "$CN" >/dev/null
echo "(el volumen $VOL queda para t0-devc-serve.sh)"
