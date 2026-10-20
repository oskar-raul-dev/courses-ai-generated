#!/usr/bin/env bash
# bea-11: el script mínimo y los tres errores que dan números falsos, contra el binario de be05.
Z="$(cd "$(dirname "$0")/.." && pwd)"
PORT=${PORT:-44227}
U="postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable&timezone=America/Panama"
k6() { docker run --rm -i --label curso=react16 --network r16t7-net "$@"; }
arrancar() { # $1 SPIN_DELIVERY_MS
  docker rm -f -v r16t7-api11 >/dev/null 2>&1
  docker run -d --name r16t7-api11 --label curso=react16 --network r16t7-net --network-alias api11 -p 127.0.0.1:$PORT:3001 \
    -v "$Z/esclusa-app":/app -v r16t7-gomod:/go/pkg/mod -w /app/server -e DATABASE_URL="$U" \
    -e JWT_SECRET=laboratorio-esclusa-secreto-de-32-bytes-o-mas -e SPIN_DELIVERY_MS="$1" golang:1.19.13 \
    sh -c 'go build -buildvcs=false -o /tmp/api ./cmd/api && exec /tmp/api' >/dev/null
  for i in $(seq 1 90); do docker exec r16t7-api11 sh -c 'wget -q -O- localhost:3001/health' >/dev/null 2>&1 && return; sleep 1; done
  echo "no levantó"; exit 1
}
git -C "$Z/esclusa-app" checkout -q master
"$Z/trabajo/go-reiniciar.sh" >/dev/null 2>&1
docker exec -i r16t7-pg psql -q -U esclusa -d esclusa < "$Z/esclusa-app/server/load/rueda-de-medicion.sql"
docker exec r16t7-go sh -c 'kill $(pidof api)'
TOKEN=$("$Z/trabajo/tools.sh" 'curl -s -X POST http://go:3011/login -H "Content-Type: application/json" -d "{\"email\":\"mdegracia@esclusa.test\",\"password\":\"esclusa123\"}" | jq -r .token' 2>/dev/null)
echo "## minimo"; arrancar 0
k6 -e BASE_URL=http://api11:3001 grafana/k6:1.5.0 run - < "$Z/trabajo/bea11/minimo.js" 2>&1 | sed -n '/TOTAL RESULTS/,$p'
echo "## error 1: medir el generador"; arrancar 100
k6 -e BASE_URL=http://api11:3001 -e RATE=200 -e VUS=5 grafana/k6:1.5.0 run - < "$Z/trabajo/bea11/generador.js" 2>&1 | grep -E "Insufficient|http_req_duration|http_reqs|iterations|dropped|vus_max" 
echo "## error 2: el calentamiento"; arrancar 0
k6 -e BASE_URL=http://api11:3001 -e TOKEN="$TOKEN" grafana/k6:1.5.0 run --summary-trend-stats "med,p(95),max" - < "$Z/trabajo/bea11/calentamiento.js" 2>&1 | grep -E "fase:|http_req_duration|http_reqs"
echo "## error 3: la red"; arrancar 0
echo "--- por la red de Docker (api11:3001)"
k6 -e BASE_URL=http://api11:3001 grafana/k6:1.5.0 run --summary-trend-stats "med,p(95),max" - < "$Z/trabajo/bea11/red.js" 2>&1 | grep -E "http_req_duration|http_reqs"
echo "--- por el puerto publicado en el host (host.docker.internal:$PORT)"
k6 -e BASE_URL=http://host.docker.internal:$PORT grafana/k6:1.5.0 run --summary-trend-stats "med,p(95),max" - < "$Z/trabajo/bea11/red.js" 2>&1 | grep -E "http_req_duration|http_reqs"
echo "--- localhost desde el contenedor de k6"
k6 -e BASE_URL=http://localhost:3001 grafana/k6:1.5.0 run --quiet - < "$Z/trabajo/bea11/minimo.js" 2>&1 | grep -E "connection refused|http_req_failed|checks_failed" | head -3
docker rm -f -v r16t7-api11 >/dev/null
