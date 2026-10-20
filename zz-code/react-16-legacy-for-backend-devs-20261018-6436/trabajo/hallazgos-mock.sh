#!/usr/bin/env bash
# Hallazgos de be00 contra el mock (3001), con curl. Corre dentro de trabajo/tools.sh.
B=http://mock:3001
H='Content-Type: application/json'
echo "== login válido / inválido"
curl -s "$B/users?email=ibatista@esclusa.test&password=esclusa123" | jq -c 'length, (.[0]|keys)'
curl -s -o /tmp/r -w '%{http_code} ' "$B/users?email=nadie@esclusa.test&password=x"; cat /tmp/r; echo
echo "== ruedas con _embed: tipos"
curl -s "$B/wheels?_embed=segments" | jq -c '.[0] | {id:(.id|type), closesAt, status, segs:(.segments|length), seg0:.segments[0]}'
echo "== 404 de json-server vs 404 de ruta propia"
curl -s -o /tmp/r -w '%{http_code} ' "$B/wheels/9999"; cat /tmp/r; echo
curl -s -o /tmp/r -w '%{http_code} ' -X PUT -H "$H" -d '{"segments":[]}' "$B/wheels/9999"; cat /tmp/r; echo
curl -s -o /tmp/r -w '%{http_code} ' -X DELETE "$B/wheels/9999"; cat /tmp/r; echo
echo "== 409 al cambiar pesos de una rueda live; 422 con suma mala"
W=$(curl -s "$B/wheels?_embed=segments" | jq -c '.[0] | .segments |= map({segmentId,prizeType,weightBp})')
echo "$W" | jq -c '.segments[0].weightBp = 2999 | .segments[1].weightBp = 2001' | curl -s -o /tmp/r -w '%{http_code} ' -X PUT -H "$H" -d @- "$B/wheels/1"; cat /tmp/r; echo
echo "$W" | jq -c '.status="draft" | .id=null | .segments[0].weightBp = 1' | curl -s -o /tmp/r -w '%{http_code} ' -X POST -H "$H" -d @- "$B/wheels"; cat /tmp/r; echo
echo "== jugadores: sin filtro y con name_like"
curl -s "$B/players" | jq -c 'length, .[0]'
curl -s "$B/players?name_like=ju" | jq -c 'map(.name)'
echo "== el dialecto que nadie usa: _page/_limit y X-Total-Count"
curl -s -D - -o /dev/null "$B/spinLog?_page=1&_limit=2" | grep -i 'x-total-count'
echo "== envío: 422 sin motivo, 404 sin jugador"
curl -s -o /tmp/r -w '%{http_code} ' -X POST -H "$H" -d '{"grantId":"g-1","caseId":"C-1","prize":"lives-5"}' "$B/players/42/grants"; cat /tmp/r; echo
curl -s -o /tmp/r -w '%{http_code} ' -X POST -H "$H" -d '{"grantId":"g-1","caseId":"C-1","prize":"lives-5","reason":"caída"}' "$B/players/9999/grants"; cat /tmp/r; echo
echo "== envío: el mismo caso dos veces a la vez (chequeo no atómico)"
for i in 1 2; do curl -s -o /dev/null -w "%{http_code}\n" -X POST -H "$H" -d "{\"grantId\":\"g-$i\",\"caseId\":\"C-7001\",\"prize\":\"lives-5\",\"reason\":\"caída\"}" "$B/players/42/grants" & done; wait
curl -s "$B/grants?caseId=C-7001" | jq -c 'length'
echo "== envío: el mismo caso después (secuencial) -> 409"
curl -s -o /tmp/r -w '%{http_code} ' -X POST -H "$H" -d '{"grantId":"g-3","caseId":"C-7001","prize":"lives-5","reason":"caída"}' "$B/players/42/grants"; cat /tmp/r; echo
echo "== giro de 2019: la misma clave dos veces"
for i in 1 2; do curl -s -o /dev/null -w "%{http_code}\n" -X POST -H "$H" -d '{"idempotencyKey":"k-demo-1"}' "$B/players/42/spins" & done; wait
curl -s "$B/spinLog?idempotencyKey=k-demo-1" | jq -c 'length, .[0]'
echo "== la fila del giro de 2019 no tiene wheelId: el tablero de la rueda 1 no la ve"
curl -s "$B/spinLog?wheelId=1" | jq -c 'length'
curl -s "$B/stock" | jq -c '.[0]'
echo "== conciliación: 409 en una rueda live; en la rueda 4 (ended) se guarda lo que mande el navegador"
curl -s -o /tmp/r -w '%{http_code} ' -X POST -H "$H" -d '{}' "$B/wheels/1/reconciliation"; cat /tmp/r; echo
curl -s -o /tmp/r -w '%{http_code} ' -X POST -H "$H" -d '{"spins":3,"counts":[1,1,1],"chi2":0,"chi2Alarm":false,"bandAlarms":[]}' "$B/wheels/4/reconciliation"; jq -c '.reconciliation' /tmp/r
echo "== CORS: preflight con Authorization y header expuesto en la respuesta real"
curl -s -D - -o /dev/null -X OPTIONS "$B/wheels" -H 'Origin: http://localhost:3000' -H 'Access-Control-Request-Method: GET' -H 'Access-Control-Request-Headers: authorization' | grep -i '^access-control\|^HTTP\|^x-request'
curl -s -D - -o /dev/null "$B/wheels" -H 'Origin: http://localhost:3000' | grep -i '^access-control-expose\|^x-request'
