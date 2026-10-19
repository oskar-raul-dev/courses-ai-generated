set -e
mkdir -p /work && cp /src/servidor.js /src/db.json /work/ && cd /work
npm install --no-audit --no-fund json-server@0.16.3 express@4.17.1 >/dev/null 2>&1
node -p "'json-server ' + require('json-server/package.json').version + ' express ' + require('express/package.json').version"
(DEMORA_MS=3000 node servidor.js > /work/servidor.log 2>&1 &)
sleep 3
for i in 1 2 3 4; do curl -s localhost:3002/purchases/tok-efectivo; echo; sleep 1; done
sleep 3; curl -s localhost:3002/purchases/tok-efectivo; echo
cat /work/servidor.log
