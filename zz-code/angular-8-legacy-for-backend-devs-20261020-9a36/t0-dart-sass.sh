#!/usr/bin/env bash
# D4: quitar node-sass del manifiesto (npm uninstall) en la imagen SIN python2, y desde el lock
# resultante: npm ci limpio, ng build con CSS extraído y ng test. Proyecto: devc/clinical-lab-dart.
# Uso: ./t0-dart-sass.sh [plataforma] [tag]
set -uo pipefail
cd "$(dirname "$0")"
PLAT=${1:-linux/arm64}; TAG=${2:-a8-t0-devc-sinpy2:arm64}; A=${PLAT#linux/}
VOL=a8-t0-nm-dart-$A; PROY=devc/clinical-lab-dart
L="--label curso=angular-8-legacy --label tanda=AS"
docker volume rm "$VOL" >/dev/null 2>&1; docker volume create $L "$VOL" >/dev/null
R="docker run --rm $L --platform $PLAT -u node -v $PWD/$PROY:/workspace -v $VOL:/workspace/node_modules -w /workspace $TAG"
echo "== npm uninstall node-sass"
$R bash -c 'time npm uninstall node-sass > /tmp/u.log 2>&1; echo EXIT_UNINSTALL=$?; tail -3 /tmp/u.log'
echo "== lo que cambió en el manifiesto y el lock"
diff <(git show HEAD:/dev/null 2>/dev/null) /dev/null >/dev/null
diff devc/clinical-lab-sass/package.json $PROY/package.json
diff devc/clinical-lab-sass/package-lock.json $PROY/package-lock.json | grep -c '^[<>]' | sed 's/^/líneas de diff en el lock: /'
grep -n '"node-sass"\|"node-gyp"\|"sass": {' $PROY/package-lock.json | head
echo "== npm ci limpio desde el lock nuevo"
$R bash -c 'rm -rf node_modules/* node_modules/.[!.]* 2>/dev/null; time npm ci > /tmp/ci.log 2>&1; echo EXIT_NPM_CI=$?; grep -E "gyp|added [0-9]+ packages|ERR" /tmp/ci.log | head -5; find node_modules -name "*.node" | head'
echo "== compilador y build"
./t0-sass-build.sh "$PLAT" "$TAG" "$VOL" dart-$A "$PROY"
echo "== ng test"
$R bash -c 'time npx ng test --watch=false --browsers=ChromeHeadlessNoSandbox > /tmp/t.log 2>&1; echo EXIT_TEST=$?; grep -E "TOTAL|ERROR" /tmp/t.log | tail -2'
