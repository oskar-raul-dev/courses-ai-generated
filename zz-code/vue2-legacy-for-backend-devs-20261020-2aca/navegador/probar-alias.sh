#!/usr/bin/env bash
# Prueba que cada alias de levantar.sh arranque y responda (frontend 200, API, sockets). Uso: ./probar-alias.sh alias…
cd "$(dirname "$0")"
for a in "$@"; do
  ./bajar.sh >/dev/null
  echo "=== $a  $(date +%T)"
  ./levantar.sh "$a" 2>&1
  [ "$a" = inc05 ] && echo "db.json de trabajo con tags en: $(python3 -c "import json;print([t['id'] for t in json.load(open('trabajo/inc05/db.json'))['tickets'] if 'tags' in t])")"
done
./bajar.sh
