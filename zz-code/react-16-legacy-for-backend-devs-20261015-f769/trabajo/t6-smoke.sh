#!/bin/sh
# F10: el smoke de Cypress. Mocks 3001 y 3002 + npm start + cypress/included:10.11.0, todos en la misma red
# y sin puertos publicados. db.json se restaura al terminar (la prueba no lo modifica, pero por las dudas).
set -u
P="$1"
cp "$P/mock/db.json" "$P/mock/db.json.antes"
M=$(docker run -d --rm --label curso=react16 -v "$P":/app -w /app node:14.21.3 node mock/server.js)
docker run -d --rm --label curso=react16 --network container:$M -v "$P":/app -w /app node:14.21.3 node mock/googlePlay/server.js >/dev/null
DEV=$(docker run -d --rm --label curso=react16 --network container:$M -v "$P":/app -w /app -e BROWSER=none node:14.21.3 npm start)
for i in $(seq 1 120); do docker logs "$DEV" 2>&1 | grep -q "Compiled" && break; sleep 2; done
timeout 900 docker run --rm --label curso=react16 --network container:$M -v "$P":/e2e -w /e2e cypress/included:10.11.0 --browser electron 2>&1 | tail -25
docker ps -q --filter label=curso=react16 | xargs -r docker kill >/dev/null 2>&1
mv "$P/mock/db.json.antes" "$P/mock/db.json"
