#!/usr/bin/env bash
# Curso 02: POST /comments con el autor del token (unión de V7 corregida). Mongo 4.4 + API en una red,
# sin puertos publicados; las llamadas van con curl desde el contenedor de la API. Uso: ./t-comments.sh
set -uo pipefail
cd "$(dirname "$0")"
BK="$PWD/../vue2-legacy-for-backend-devs-20261014-b44a/backend/tiquetera-backend"
L="--label curso=vue2-legacy --label tanda=comments"; NET=vue2-com-net
docker rm -f -v vue2-com-mongo vue2-com-api >/dev/null 2>&1; docker network create $L $NET >/dev/null 2>&1
docker volume create $L vue2-com-nm >/dev/null
docker run -d --name vue2-com-mongo $L --network $NET mongo:4.4 >/dev/null
docker run -d --name vue2-com-api $L --network $NET -e MONGO_URL=mongodb://vue2-com-mongo:27017/tiquetera -e JWT_SECRET=solo-pruebas \
  -v "$BK":/app -v vue2-com-nm:/app/node_modules -w /app node:14.21.3 \
  bash -c 'npm ci --silent >/dev/null 2>&1; MONGO_URL=mongodb://vue2-com-mongo:27017 node scripts/seed.js >/dev/null && MONGO_URL=mongodb://vue2-com-mongo:27017 node scripts/migrate-passwords.js && node src/server.js' >/dev/null
for i in $(seq 1 60); do docker exec vue2-com-api curl -s -o /dev/null localhost:3000/tickets 2>/dev/null && break; sleep 3; done
docker exec vue2-com-api bash -c '
T=$(curl -s -X POST localhost:3000/auth/login -H "Content-Type: application/json" -d "{\"username\":\"admin\",\"password\":\"admin123\"}" | node -p "JSON.parse(require(\"fs\").readFileSync(0)).token")
TID=$(curl -s localhost:3000/tickets | node -p "JSON.parse(require(\"fs\").readFileSync(0))[0].id")
echo "== sin token"; curl -s -o /dev/null -w "%{http_code}\n" -X POST localhost:3000/comments -H "Content-Type: application/json" -d "{\"ticketId\":\"$TID\",\"body\":\"hola\"}"
echo "== con token, sin author"; curl -s -X POST localhost:3000/comments -H "Content-Type: application/json" -H "Authorization: Bearer $T" -d "{\"ticketId\":\"$TID\",\"body\":\"sin autor\"}"; echo
echo "== con token, author falso"; curl -s -X POST localhost:3000/comments -H "Content-Type: application/json" -H "Authorization: Bearer $T" -d "{\"ticketId\":\"$TID\",\"body\":\"suplantado\",\"author\":\"lmcano\"}"; echo'
docker rm -f -v vue2-com-mongo vue2-com-api >/dev/null; docker network rm $NET >/dev/null; docker volume rm vue2-com-nm >/dev/null
