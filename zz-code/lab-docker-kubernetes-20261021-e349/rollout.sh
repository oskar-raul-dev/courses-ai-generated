#!/bin/bash
# F16 §5.2: rollout restart de pricing a los 8 s de una carga de 200 req/s por la puerta; 4 casos x 3 corridas.
K="kubectl --context kind-lab -n apps"
URL='http://api.localhost:8080/pricing/prices/SKU-0001?store=DRO-007'
caso() { # tag preStop
  $K set image deployment/pricing pricing=lab/pricing:$1 >/dev/null
  if [ "$2" = 0 ]; then $K patch deployment pricing --type=json -p '[{"op":"remove","path":"/spec/template/spec/containers/0/lifecycle"}]' >/dev/null 2>&1
  else $K patch deployment pricing -p '{"spec":{"template":{"spec":{"containers":[{"name":"pricing","lifecycle":{"preStop":{"sleep":{"seconds":'$2'}}}}]}}}}' >/dev/null; fi
  $K rollout status deployment/pricing --timeout=120s >/dev/null
  for i in 1 2 3; do
    sleep 5
    ( sleep 8; $K rollout restart deployment/pricing >/dev/null ) &
    out=$(k6 run -q -e RATE=200 -e DURATION=20s -e URL="$URL" bench/b16/rate.js 2>&1 | grep 'http_req_failed\|http_reqs' | tr -s ' ' | tr '\n' ' ')
    wait
    echo "pricing:$1 preStop=$2 corrida $i · $out"
    $K rollout status deployment/pricing --timeout=120s >/dev/null
  done
}
caso g4 5; caso g5 5
