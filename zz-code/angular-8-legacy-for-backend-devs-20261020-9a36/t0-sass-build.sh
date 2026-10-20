#!/usr/bin/env bash
# ng build con CSS extraído sobre un proyecto con Sass, con el node_modules de un volumen ya lleno,
# e informa qué compilador de Sass resuelve build-angular (node-sass o, si no carga, sass).
# Uso: ./t0-sass-build.sh <plataforma> <tag> <volumen> <nombre de salida> [proyecto]
set -uo pipefail
cd "$(dirname "$0")"
PLAT=$1; TAG=$2; VOL=$3; OUT=$4; PROY=${5:-devc/clinical-lab-sass}
docker run --rm --label curso=angular-8-legacy --label tanda=AS --platform "$PLAT" -u node \
  -v "$PWD/$PROY:/workspace" -v "$VOL:/workspace/node_modules" -w /workspace "$TAG" bash -c "
  node -e \"try { require('node-sass'); console.log('COMPILADOR=node-sass ' + require('node-sass').info.split('\\n')[0]) } catch (e) { console.log('COMPILADOR=sass ' + require('sass').info.split('\\n')[0].replace(/\\t/g, ' ') + ' | node-sass no carga: ' + e.message.split('\\n')[0]) }\"
  time npx ng build --extract-css --output-path dist/$OUT > /tmp/b.log 2>&1; echo EXIT_BUILD=\$?
  grep -E 'ERROR|Warning|WARNING|styles' /tmp/b.log | head -8
  ls -l dist/$OUT/styles.css"
