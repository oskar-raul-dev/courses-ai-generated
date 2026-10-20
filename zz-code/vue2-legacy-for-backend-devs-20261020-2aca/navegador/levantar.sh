#!/usr/bin/env bash
# Levanta un árbol validado del paquete Vue 2 para probarlo en el navegador del Mac.
# Uso: ./levantar.sh <alias>     alias: f00 f03 f07 inc05 f09 f11 q vu nx backend
# Todo corre en contenedores (node:14.21.3, mongo:4.4) con --label curso=vue2-legacy --label tanda=navegador.
# El frontend tiene fijos http://localhost:3000 (Mock API o Express) y http://localhost:4000 (sockets): esos dos
# puertos se publican tal cual en 127.0.0.1, solo si están libres. El del dev server sale aleatorio.
# Un alias a la vez: ./bajar.sh antes de levantar otro.
set -uo pipefail
cd "$(dirname "$0")"
A=${1:?alias}; B=../../vue2-legacy-for-backend-devs-20261014-b44a; Z=..
L="--label curso=vue2-legacy --label tanda=navegador --label alias=$A"
IMG=node:14.21.3; W="$PWD/trabajo/$A"; CN=vue2-nav-$A; VOL=vue2-nav-$A-nm
MOCK="npx json-server --watch db.json --port 3000 --host 0.0.0.0"
SOCK="node server/socket-server.js"; SERVE="npx vue-cli-service serve --port 8080"
FUENTE=""; CMD=""; P34="-p 127.0.0.1:3000:3000 -p 127.0.0.1:4000:4000"
case "$A" in
  f00)   FUENTE=$B/k/snap/00-setup-hola-mundo/tiquetera-legacy; CMD="npx stubby -d stubby.yml -s 8888 & $SERVE"; P34="-p 127.0.0.1:8888:8888" ;;
  f03)   FUENTE=$B/k/snap/03-mock-api-minima/tiquetera-legacy; CMD="$MOCK & $SERVE" ;;
  f07)   FUENTE=$B/k/snap/07-metricas-minimas-estado-final/tiquetera-legacy; CMD="$MOCK & $SERVE" ;;
  inc05) FUENTE=$Z/tiquetera-legacy; CMD="$MOCK & $SERVE" ;;
  f09)   FUENTE=$B/k/snap/09-panel-soporte/tiquetera-legacy; CMD="$MOCK & $SOCK & $SERVE" ;;
  f11)   FUENTE=$B/k/snap/11-testing-minimo/tiquetera-legacy; CMD="$MOCK & $SOCK & $SERVE" ;;
  q)     FUENTE=$B/rutas/q/tiquetera-q; CMD="$MOCK & $SOCK & npx quasar dev --hostname 0.0.0.0 --port 8080" ;;
  vu)    FUENTE=$B/rutas/vu/tiquetera-legacy; CMD="$MOCK & $SOCK & $SERVE" ;;
  nx)    FUENTE=$B/rutas/nx1/tiquetera-nx; MOCK="npx -p json-server@0.16.3 json-server --watch db.json --port 3000 --host 0.0.0.0"; CMD="$MOCK & $SOCK & HOST=0.0.0.0 PORT=8080 npx nuxt" ;;
  backend) FUENTE=$B/k/snap/11-testing-minimo/tiquetera-legacy; CMD="$SERVE"; P34="" ;;
  *) echo "alias desconocido: $A"; exit 2 ;;
esac
for p in 3000 4000 8888; do
  if lsof -nP -iTCP:$p -sTCP:LISTEN >/dev/null 2>&1; then echo "El puerto $p está ocupado en el Mac: libéralo (o ./bajar.sh) y repite."; exit 1; fi
done
mkdir -p trabajo
rsync -a --delete --exclude node_modules --exclude dist --exclude .nuxt --exclude .quasar "$FUENTE/" "$W/"
if [ "$A" = backend ]; then
  python3 -I "$PWD/login-real.py" "$W" >/dev/null   # el frontend entra con POST /auth/login real (F11 del Curso 02, ej. 9)
fi
if [ "$A" = inc05 ]; then
  python3 -I "$Z/rama-incidente-05.py" "$W" >/dev/null && cp "$W/mock/db.incidente-05.json" "$W/db.json"
fi
docker rm -f -v "$CN" >/dev/null 2>&1
docker volume create $L "$VOL" >/dev/null
if [ "$A" = backend ]; then
  BK=$B/backend/tiquetera-backend; WB="$PWD/trabajo/backend-api"
  rsync -a --delete --exclude node_modules --exclude mongo-data --exclude backups "$BK/" "$WB/"
  docker network create $L vue2-nav-net >/dev/null 2>&1
  docker rm -f -v vue2-nav-mongo vue2-nav-api >/dev/null 2>&1
  docker run -d --name vue2-nav-mongo $L --network vue2-nav-net mongo:4.4 mongod --replSet rs0 --bind_ip_all >/dev/null
  for i in $(seq 1 30); do docker exec vue2-nav-mongo mongo --quiet --eval 'db.adminCommand("ping").ok' 2>/dev/null | grep -q 1 && break; sleep 1; done
  docker exec vue2-nav-mongo mongo --quiet --eval 'rs.initiate({_id:"rs0",members:[{_id:0,host:"localhost:27017"}]}).ok'
  docker volume create $L vue2-nav-api-nm >/dev/null
  docker run -d --name vue2-nav-api $L --network vue2-nav-net -p 127.0.0.1:3000:3000 -p 127.0.0.1:4000:4000 \
    -e MONGO_URL=mongodb://vue2-nav-mongo:27017/tiquetera -e JWT_SECRET=solo-para-pruebas-locales \
    -v "$WB":/app -v vue2-nav-api-nm:/app/node_modules -w /app $IMG \
    bash -c 'npm ci --silent >/tmp/ci.log 2>&1 && MONGO_URL=mongodb://vue2-nav-mongo:27017 node scripts/seed.js && MONGO_URL=mongodb://vue2-nav-mongo:27017 node scripts/migrate-passwords.js && node src/server.js' >/dev/null
fi
docker run -d --name "$CN" $L -p 127.0.0.1::8080 $P34 -v "$W":/app -v "$VOL":/app/node_modules -w /app $IMG \
  bash -c "npm ci --silent >/tmp/ci.log 2>&1; echo NPM_CI=\$?; $CMD; wait" >/dev/null
PORT=$(docker port "$CN" 8080/tcp | head -1 | sed 's/.*://')
echo "Instalando y arrancando $A (la primera vez tarda unos minutos)…"
for i in $(seq 1 120); do
  c=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$PORT/" 2>/dev/null)
  [ "$c" = 200 ] && break; sleep 5
done
echo "Frontend:  http://127.0.0.1:$PORT/   (HTTP $c)"
echo "API:       http://localhost:3000/   (HTTP $(curl -s -o /dev/null -w '%{http_code}' http://localhost:3000/tickets 2>/dev/null) en /tickets)"
echo "Sockets:   http://localhost:4000/   (HTTP $(curl -s -o /dev/null -w '%{http_code}' 'http://localhost:4000/socket.io/?EIO=3&transport=polling' 2>/dev/null))"
echo "Logs:      docker logs $CN"
