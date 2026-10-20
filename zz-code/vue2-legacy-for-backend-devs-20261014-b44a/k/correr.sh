#!/bin/sh
# Build + lint (sin --fix) de una instantánea del repo del alumno, en node:14.21.3.
# Uso: k/correr.sh <dir-instantánea-con-package.json> <tanda> [build|lint|test|todo]
# Reusa los node_modules de repo/tiquetera-legacy (superconjunto de las dependencias de F0–F11).
set -e
SNAP=$(cd "$1" && pwd); TANDA=$2; QUE=${3:-todo}
BASE=$(cd "$(dirname "$0")/.." && pwd)
docker run --rm --label curso=vue2-legacy --label tanda="$TANDA" \
  -v "$SNAP:/snap:ro" -v "$BASE/repo/tiquetera-legacy/node_modules:/w/node_modules:ro" node:14.21.3 sh -c "
    cd /w && tar -C /snap --exclude=./node_modules -cf - . | tar -xf -
    if [ $QUE = build ] || [ $QUE = todo ]; then npx vue-cli-service build 2>&1 | grep -E 'DONE|ERROR|error|Failed|warning  in' | head -20; fi
    if [ $QUE = lint ] || [ $QUE = todo ]; then npx vue-cli-service lint --no-fix 2>&1 | tail -40; fi
    if [ $QUE = test ]; then npx vue-cli-service test:unit 2>&1 | tail -15; fi
  "
