#!/usr/bin/env bash
# La misma secuencia de escrituras contra BASE; imprime status y cuerpo normalizado (sin ids, instantes ni wheelVersion).
B="$BASE"; H='Content-Type: application/json'
norm() { jq -S -c 'walk(if type == "object" then del(.id, .wheelVersion, .createdAt, .reconciledAt, .wheelId) else . end)' 2>/dev/null || cat; }
call() { local label="$1"; shift; local out; out=$(curl -s -w '\n%{http_code}' "$@"); echo "$label → $(echo "$out" | tail -1) $(echo "$out" | sed '$d' | norm)"; }
SEG='[{"segmentId":"sin-premio","prizeType":"none","weightBp":3000},{"segmentId":"vidas-2","prizeType":"lives","weightBp":2000},{"segmentId":"vidas-5","prizeType":"lives","weightBp":1500},{"segmentId":"avatar-comun","prizeType":"avatar","weightBp":1500},{"segmentId":"set-gemas-basico","prizeType":"gemSet","weightBp":1000},{"segmentId":"avatar-raro","prizeType":"avatar","weightBp":800},{"segmentId":"set-gemas-canal","prizeType":"gemSet","weightBp":150},{"segmentId":"esclusa-de-oro","prizeType":"avatar","weightBp":50}]'
SEG2=$(echo "$SEG" | jq -c '.[0].weightBp = 2999 | .[1].weightBp = 2001')
call "alta" -X POST -H "$H" -d "{\"name\":\"Prueba\",\"closesAt\":\"2030-12-20T20:00:00-05:00\",\"segments\":$SEG}" "$B/wheels"
ID=$(curl -s "$B/wheels" | jq '[.[] | select(.name=="Prueba")][0].id')
call "alta 9999" -X POST -H "$H" -d "{\"name\":\"Mala\",\"closesAt\":\"2030-12-20T20:00:00-05:00\",\"segments\":$SEG2,\"status\":\"draft\"}" "$B/wheels" >/dev/null
call "alta suma mala" -X POST -H "$H" -d "{\"name\":\"Mala\",\"closesAt\":\"2030-12-20T20:00:00-05:00\",\"segments\":$(echo "$SEG" | jq -c '.[0].weightBp=1')}" "$B/wheels"
call "alta peso decimal" -X POST -H "$H" -d "{\"name\":\"Mala\",\"closesAt\":\"2030-12-20T20:00:00-05:00\",\"segments\":$(echo "$SEG" | jq -c '.[0].weightBp=2999.5 | .[1].weightBp=2000.5')}" "$B/wheels"
call "editar nombre" -X PUT -H "$H" -d "{\"id\":$ID,\"name\":\"Prueba 2\",\"closesAt\":\"2030-12-20T20:00:00-05:00\",\"status\":\"draft\",\"timezone\":\"America/Panama\",\"segments\":$SEG}" "$B/wheels/$ID"
call "editar pesos en borrador" -X PUT -H "$H" -d "{\"id\":$ID,\"name\":\"Prueba 2\",\"closesAt\":\"2030-12-20T20:00:00-05:00\",\"status\":\"draft\",\"segments\":$SEG2}" "$B/wheels/$ID"
call "pasar a live" -X PUT -H "$H" -d "{\"id\":$ID,\"name\":\"Prueba 2\",\"closesAt\":\"2030-12-20T20:00:00-05:00\",\"status\":\"live\",\"segments\":$SEG2}" "$B/wheels/$ID"
call "pesos en live" -X PUT -H "$H" -d "{\"id\":$ID,\"name\":\"Prueba 2\",\"closesAt\":\"2030-12-20T20:00:00-05:00\",\"status\":\"live\",\"segments\":$SEG}" "$B/wheels/$ID"
call "borrar" -X DELETE "$B/wheels/$ID"
call "borrar otra vez" -X DELETE "$B/wheels/$ID"
call "envío sin motivo" -X POST -H "$H" -d '{"grantId":"g-1","caseId":"C-1","prize":"vidas-5"}' "$B/players/42/grants"
call "envío jugador 9999" -X POST -H "$H" -d '{"grantId":"g-1","caseId":"C-1","prize":"vidas-5","reason":"x"}' "$B/players/9999/grants"
call "envío" -X POST -H "$H" -d '{"grantId":"g-1","caseId":"C-1","prize":"vidas-5","reason":"caída"}' "$B/players/42/grants"
call "envío mismo caso" -X POST -H "$H" -d '{"grantId":"g-2","caseId":"C-1","prize":"vidas-5","reason":"caída"}' "$B/players/42/grants"
call "giro sin clave" -X POST -H "$H" -d '{}' "$B/players/42/spins"
call "giro" -X POST -H "$H" -d '{"idempotencyKey":"k-1"}' "$B/players/42/spins"
call "stock" "$B/stock"
call "conciliar live" -X POST -H "$H" -d '{}' "$B/wheels/1/reconciliation"
call "conciliar 9999" -X POST -H "$H" -d '{}' "$B/wheels/9999/reconciliation"
call "leer conciliación 4" "$B/wheels/4/reconciliation"
call "conciliar 4" -X POST -H "$H" -d '{"spins":3,"counts":[1,1,1],"chi2":1.5,"chi2Alarm":false,"bandAlarms":["sin-premio"],"purchases":{"chargedCents":10,"feeCents":2,"netCents":8,"missingInApi":["tok-x"],"duplicatedInApi":[]}}' "$B/wheels/4/reconciliation"
call "conciliar 4 otra vez" -X POST -H "$H" -d '{"spins":3}' "$B/wheels/4/reconciliation"
call "leer conciliación 4" "$B/wheels/4/reconciliation"
call "ruta desconocida" "$B/nada"
