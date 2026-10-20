#!/usr/bin/env bash
# F03 §5.4 otra vez: seis corridas de traffic + measure contra el mock sin caos, con la base restaurada
# antes de cada una y STEP_DELAY_MS=2. Necesita el worktree de fase-03 con node_modules (regresion.sh).
# Uso: trabajo/f03-medir.sh   → salidas/f03-medicion.txt
Z="$(cd "$(dirname "$0")/.." && pwd)"
W="$Z/etapas/fase-03-mock-api-express-caos"
docker run --rm --label curso=react16 -v "$W":/w -w /w node:14.21.3 bash -c '
  cp mock/db.json /tmp/db.json
  for i in 1 2 3 4 5 6; do
    cp /tmp/db.json mock/db.json
    STEP_DELAY_MS=2 node mock/server.js >/tmp/mock.log 2>&1 & pid=$!
    for s in $(seq 1 50); do node -e "require(\"http\").get(\"http://localhost:3001/stock\",r=>process.exit(0)).on(\"error\",()=>process.exit(1))" && break; sleep 0.2; done
    node scripts/traffic.js >/tmp/traffic.log 2>&1
    echo "corrida $i: $(node scripts/measure.js)"
    kill $pid; wait $pid 2>/dev/null
  done; cp /tmp/db.json mock/db.json' | tee "$Z/salidas/f03-medicion.txt"
