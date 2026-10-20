#!/bin/sh
# Corre un comando en una copia de una instantánea de ruta, con los node_modules de otro repo.
# Uso: k/correr-ruta.sh <dir-instantánea> <dir-con-node_modules> <tanda> "<comando>"
SNAP=$(cd "$1" && pwd); NM=$(cd "$2" && pwd)/node_modules; TANDA=$3; CMD=$4
docker run --rm --label curso=vue2-legacy --label tanda="$TANDA" \
  -v "$SNAP:/snap:ro" -v "$NM:/w/node_modules:ro" node:14.21.3 sh -c "
    cd /w && tar -C /snap --exclude=./node_modules -cf - . | tar -xf - && $CMD"
