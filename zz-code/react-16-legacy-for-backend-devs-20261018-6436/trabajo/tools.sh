#!/usr/bin/env bash
# Corre un comando con bash, curl y jq dentro de alpine:3.20, en la red de la tanda.
# Uso: trabajo/tools.sh '<comando>'   (el repo de prueba montado en /repo)
Z="$(cd "$(dirname "$0")/.." && pwd)"
exec docker run --rm -i --label curso=react16 --network r16t7-net -v "$Z/esclusa-app":/repo -w /repo \
  -v "$Z/salidas/apk-cache":/etc/apk/cache alpine:3.20 sh -c "apk add -q bash curl jq >/dev/null 2>&1 && bash -c \"\$0\"" "$1"
