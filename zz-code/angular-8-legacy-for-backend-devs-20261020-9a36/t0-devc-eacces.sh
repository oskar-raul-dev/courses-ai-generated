#!/usr/bin/env bash
# El EACCES de A13 §5: volumen nuevo montado en una ruta que la imagen no tiene (/proj/node_modules)
# nace de root, y npm ci como 'node' falla. Uso: ./t0-devc-eacces.sh
set -uo pipefail
cd "$(dirname "$0")"
L="--label curso=angular-8-legacy --label tanda=AS"; VOL=a8-t0-nm-eacces
docker volume rm "$VOL" >/dev/null 2>&1; docker volume create $L "$VOL" >/dev/null
docker run --rm $L -u node -v "$PWD/devc/clinical-lab:/proj" -v "$VOL:/proj/node_modules" -w /proj a8-t0-devc:arm64 \
  bash -c 'ls -ld node_modules; npm ci 2>&1 | grep -E "^npm ERR! (code|syscall|path|Error)" | head -6'
docker volume rm "$VOL" >/dev/null
