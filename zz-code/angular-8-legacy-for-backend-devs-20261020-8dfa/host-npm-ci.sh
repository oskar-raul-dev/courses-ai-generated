#!/usr/bin/env bash
# H-host (lo corre el autor EN EL MAC, no en un contenedor): npm ci de LabCore con Node 14.21.3 x64 bajo Rosetta.
# Responde dos cosas: si node-sass baja su binario darwin-x64-83 sin compilar, y qué gyp ERR! da fsevents 1.2.13
# (en LabCore el node-gyp de la raíz de node_modules es el 3.8.0 de node-sass, no el 5.1.1 de npm).
# Uso, desde este directorio: ./host-npm-ci.sh        Limpieza: rm -rf host-labcore/node_modules host-labcore/dist
set -uo pipefail
cd "$(dirname "$0")"
OUT="$PWD/salidas/host-npm-ci.log"; mkdir -p salidas
source ~/.nvm/nvm.sh
nvm use 14.21.3 >/dev/null || { echo "Falta Node 14.21.3: arch -x86_64 zsh -c 'source ~/.nvm/nvm.sh && nvm install 14.21.3'"; exit 1; }
{
  echo "== entorno"; date; sw_vers -productVersion; uname -m
  echo "node $(node -v) arch=$(node -p process.arch) npm $(npm -v)"; file "$(which node)"
  echo "python3: $(python3 --version 2>&1)  python2: $(python2 --version 2>&1 | head -1)  python: $(python --version 2>&1 | head -1)"
  [ "$(node -p process.arch)" = x64 ] || { echo "ABORTA: el Node no es x64 (F0 §5.1)"; exit 1; }
  cd host-labcore
  rm -rf node_modules dist
  echo "== npm ci"; S=$(date +%s)
  npm ci > ../salidas/host-npm-ci-completo.log 2>&1; echo "EXIT_NPM_CI=$? $(( $(date +%s)-S )) s"
  grep -E "node-sass@|Downloading binary|Binary (saved|found|is fine)|HTTP error|added [0-9]+ packages|npm ERR!" ../salidas/host-npm-ci-completo.log | head -20
  echo "== fsevents: qué node-gyp y qué error"
  grep -E "gyp (ERR!|info) (cwd|node-gyp -v|find Python|stack)|ValueError|Can't find Python|fsevents@1" ../salidas/host-npm-ci-completo.log | sort | uniq -c | head -30
  echo "== binarios"; ls node_modules/node-sass/vendor; node -p "require('node-sass').info.split('\n')[0]"
  echo "== ng build"; S=$(date +%s)
  npx ng build --extract-css > ../salidas/host-build.log 2>&1; echo "EXIT_BUILD=$? $(( $(date +%s)-S )) s"
  ls -l dist/clinical-lab/styles.css
} 2>&1 | tee "$OUT"
