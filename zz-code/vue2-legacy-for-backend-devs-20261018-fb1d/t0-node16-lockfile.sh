#!/usr/bin/env bash
# T0.4: ¿npm 8 (Node 16.20.2) reescribe el lockfile v1 de F11? Primero npm ci, luego npm install.
docker run --rm --name vue2-t0-node16 --label curso=vue2-legacy --label tanda=T0 \
  -v "$PWD/f11/tiquetera-legacy:/src:ro" node:16.20.2 bash -c '
  cp -r /src /w && cd /w && node -v && npm -v
  cp package-lock.json /tmp/lock.orig
  echo "## npm ci"; npm ci 2>&1 | grep -v "^npm timing" | tail -25; echo "EXIT_CI=${PIPESTATUS[0]}"
  echo "## despues de npm ci"; grep -m1 lockfileVersion package-lock.json; cmp -s package-lock.json /tmp/lock.orig && echo "lockfile IGUAL" || echo "lockfile CAMBIO"
  echo "## npm install"; npm install 2>&1 | grep -v "^npm timing" | tail -15; echo "EXIT_INSTALL=${PIPESTATUS[0]}"
  echo "## despues de npm install"; grep -m1 lockfileVersion package-lock.json; cmp -s package-lock.json /tmp/lock.orig && echo "lockfile IGUAL" || echo "lockfile CAMBIO"
  git diff --no-index --stat /tmp/lock.orig package-lock.json | tail -1
'
