#!/usr/bin/env bash
# Levanta la consola (npm start, 3000) y lo que haga falta detrás, en un solo contenedor
# para que el navegador de Cypress vea localhost:3000/3001/3002 (--network container:r16t7-app).
# Uso: trabajo/levantar-app.sh mocks   -> mocks 3001 y 3002 + consola
#      trabajo/levantar-app.sh go      -> solo 3002 + consola (el 3001 lo da Go, que comparte este espacio de red)
Z="$(cd "$(dirname "$0")/.." && pwd)"
MODE="${1:-mocks}"
docker rm -f -v r16t7-app >/dev/null 2>&1
if [ "$MODE" = mocks ]; then CMD='npm run mock:all & BROWSER=none npm start'; else CMD='npm run mock:googleplay & BROWSER=none npm start'; fi
docker run -d --name r16t7-app --label curso=react16 --network r16t7-net --network-alias app \
  -v "$Z/esclusa-app":/app -w /app -e CHAOS_LEVEL=off -e CI=true node:14.21.3 sh -c "$CMD" >/dev/null
for i in $(seq 1 90); do
  docker exec r16t7-app sh -c 'curl -s -o /dev/null localhost:3000 && curl -s -o /dev/null localhost:3002/earnings' 2>/dev/null && { echo "app lista en ${i}x2 s"; exit 0; }
  sleep 2
done
echo "la app no levantó"; docker logs --tail 30 r16t7-app; exit 1
