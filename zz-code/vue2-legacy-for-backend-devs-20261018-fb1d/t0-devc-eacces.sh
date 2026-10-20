#!/usr/bin/env bash
# T0.5: un volumen montado en una ruta que la imagen NO tiene nace de root, y npm ci como 'node' falla.
docker volume create --label curso=vue2-legacy --label tanda=T0 vue2-t0-nm-root >/dev/null
docker run --rm --label curso=vue2-legacy --label tanda=T0 -v "$PWD/devc/eacces:/proj" \
  -v vue2-t0-nm-root:/proj/node_modules -w /proj vue2-t0-devc:arm64 bash -c '
id -un; ls -ld /proj/node_modules; npm ci 2>&1 | grep -m5 "EACCES\|npm ERR! code\|npm ERR! syscall\|npm ERR! path"; echo "EXIT=${PIPESTATUS[0]}"'
docker volume rm vue2-t0-nm-root >/dev/null
