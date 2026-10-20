#!/usr/bin/env bash
# T12: la smoke de F10 y la spec de R19 contra la consola de fase-11 con los dos mocks, en un solo espacio de red.
Z="$(cd "$(dirname "$0")/.." && pwd)"; W="$Z/etapas/fase-11-cierre-puente-react-moderno"
cp "$Z/trabajo/e2e/spin-log.cy.js" "$W/cypress/e2e/"
docker rm -f -v r16t12-app >/dev/null 2>&1
docker run -d --name r16t12-app --label curso=react16 -v "$W":/app -w /app -e CHAOS_LEVEL=off -e CI=true \
  node:14.21.3 sh -c 'npm run mock:all & BROWSER=none npm start' >/dev/null
for i in $(seq 1 90); do docker exec r16t12-app sh -c 'curl -s -o /dev/null localhost:3000 && curl -s -o /dev/null localhost:3002/earnings' 2>/dev/null && break; sleep 2; done
docker run --rm --label curso=react16 --network container:r16t12-app -v "$W":/e2e -w /e2e cypress/included:10.11.0 \
  --spec cypress/e2e/smoke.cy.js,cypress/e2e/spin-log.cy.js 2>&1 | grep -E "✓|✖|[0-9]+\) |Passing|Failing|All specs|failed" 
docker rm -f -v r16t12-app >/dev/null 2>&1
rm "$W/cypress/e2e/spin-log.cy.js"; git -C "$W" checkout -q -- mock/db.json mock/googlePlay 2>/dev/null; git -C "$W" status --short
