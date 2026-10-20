#!/usr/bin/env bash
# bea-11, error 2: avalancha de 100 VUs contra el binario recién arrancado (pool vacío), tres corridas.
Z="$(cd "$(dirname "$0")/.." && pwd)"
U="postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable&timezone=America/Panama"
login() { "$Z/trabajo/tools.sh" 'curl -s -X POST http://go:3011/login -H "Content-Type: application/json" -d "{\"email\":\"mdegracia@esclusa.test\",\"password\":\"esclusa123\"}" | jq -r .token' 2>/dev/null; }
docker exec r16t7-go sh -c 'pidof api >/dev/null || (cd /app/server && JWT_SECRET=laboratorio-esclusa-secreto-de-32-bytes-o-mas DATABASE_URL="postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable&timezone=America/Panama" PORT=3011 /tmp/api > /tmp/api.log 2>&1 &); sleep 1'
TOKEN=$(login)
for n in 1 2 3; do
  docker container rm --force --volumes r16t7-api11 >/dev/null 2>&1
  docker run -d --name r16t7-api11 --label curso=react16 --network r16t7-net --network-alias api11 \
    -v "$Z/esclusa-app":/app -v r16t7-gomod:/go/pkg/mod -w /app/server -e DATABASE_URL="$U" \
    -e JWT_SECRET=laboratorio-esclusa-secreto-de-32-bytes-o-mas golang:1.19.13 \
    sh -c 'go build -buildvcs=false -o /tmp/api ./cmd/api && exec /tmp/api' >/dev/null
  for i in $(seq 1 90); do docker exec r16t7-api11 wget -q -O- localhost:3001/health >/dev/null 2>&1 && break; sleep 1; done
  echo "== corrida $n"
  docker run --rm -i --label curso=react16 --network r16t7-net -e BASE_URL=http://api11:3001 -e TOKEN="$TOKEN" \
    grafana/k6:1.5.0 run --summary-trend-stats "med,p(95),max" - < "$Z/trabajo/bea11/calentamiento2.js" 2>&1 | grep -E "\{ fase:|http_reqs"
done
docker container rm --force --volumes r16t7-api11 >/dev/null 2>&1
