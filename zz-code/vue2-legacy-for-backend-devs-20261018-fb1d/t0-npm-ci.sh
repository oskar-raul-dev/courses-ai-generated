#!/usr/bin/env bash
# T0.1–T0.4: npm ci de un árbol dentro de un contenedor, con el log literal.
# Uso: t0-npm-ci.sh <nombre> <imagen> <plataforma> <dir-origen> [extra docker args...]
set -u
name=$1; image=$2; platform=$3; src=$4; shift 4
out=salidas/t0/$name.log
docker run --rm --name "vue2-t0-$name" --label curso=vue2-legacy --label tanda=T0 \
  --platform "$platform" -v "$PWD/$src:/src:ro" "$@" "$image" \
  bash -c 'cp -r /src /w && cd /w && node -p "process.version + \" \" + process.arch" && npm -v \
    && (time npm ci --loglevel=info) 2>&1; echo "EXIT=$?"; \
    echo "## binding.gyp"; find node_modules -name binding.gyp -not -path "*/node-gyp/*" | sort; \
    echo "## .node"; find node_modules -name "*.node" | sort; \
    echo "## lockfileVersion"; grep -m1 lockfileVersion package-lock.json' > "$out" 2>&1
echo "$name -> $(grep -E '^EXIT=' $out)"
