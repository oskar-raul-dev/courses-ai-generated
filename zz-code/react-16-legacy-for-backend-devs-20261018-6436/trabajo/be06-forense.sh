#!/usr/bin/env bash
# be06: el reloj del servidor de punta a punta. Rehace la base, arranca el binario con el barrido de cierre
# cada 5 s y corre los pasos de la pieza forense con curl y psql. Uso: trabajo/be06-forense.sh
Z="$(cd "$(dirname "$0")/.." && pwd)"
"$Z/trabajo/go-reiniciar.sh" "postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable" >/dev/null
docker exec r16t7-go sh -c 'kill $(pidof api); sleep 0.5; cd /app/server && (WHEEL_CLOSE_EVERY=5s JWT_SECRET=laboratorio-esclusa-secreto-de-32-bytes-o-mas DATABASE_URL="postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable" PORT=3011 /tmp/api > /tmp/api.log 2>&1 &); sleep 1'
PSQL="docker exec r16t7-pg psql -U esclusa -d esclusa -Atc"
"$Z/trabajo/tools.sh" '
B=http://r16t7-go:3011
TOKEN=$(curl -s -X POST $B/login -H "Content-Type: application/json" -d "{\"email\":\"ybatista@esclusa.test\",\"password\":\"esclusa123\"}" | jq -r .token)
[ "$TOKEN" = null ] && TOKEN=$(curl -s -X POST $B/login -H "Content-Type: application/json" -d "{\"email\":\"ibatista@esclusa.test\",\"password\":\"esclusa123\"}" | jq -r .token)
echo "== 1. El giro gratis de María R. (Chile), dos veces"
curl -s -w " → %{http_code}\n" -X POST $B/players/43/free-spins
curl -s -w " → %{http_code}\n" -X POST $B/players/43/free-spins
echo "== 2. Lo gasta"
curl -s -w " → %{http_code}\n" -X POST -d "{\"idempotencyKey\":\"forense-be06-1\"}" $B/players/43/spins
echo "== 3. X-Server-Time contra el reloj del contenedor"
curl -s -D - -o /dev/null $B/health | grep -i "^x-server-time\|^date"; date -u +"date -u: %Y-%m-%dT%H:%M:%SZ"
'
$PSQL "UPDATE players SET free_spins = 5 WHERE id = 42; UPDATE wheels SET closes_at = now() + interval '8 seconds' WHERE id = 1; SELECT 'closes_at = ' || closes_at FROM wheels WHERE id = 1"
"$Z/trabajo/tools.sh" '
B=http://r16t7-go:3011
echo "== 4. Antes del cierre"; curl -s -w " → %{http_code}\n" -X POST -d "{\"idempotencyKey\":\"forense-be06-antes\"}" $B/players/42/spins
sleep 9
echo "== 5. Pasado el cierre (el barrido todavía puede no haber pasado)"; curl -s -w " → %{http_code}\n" -X POST -d "{\"idempotencyKey\":\"forense-be06-despues\"}" $B/players/42/spins
'
$PSQL "SELECT 'status ahora = ' || status FROM wheels WHERE id = 1"
sleep 6
$PSQL "SELECT 'status después del barrido = ' || status FROM wheels WHERE id = 1"
"$Z/trabajo/tools.sh" '
B=http://r16t7-go:3011
TOKEN=$(curl -s -X POST $B/login -H "Content-Type: application/json" -d "{\"email\":\"ibatista@esclusa.test\",\"password\":\"esclusa123\"}" | jq -r .token)
echo "== 6. Un envío de giro de la rueda 1, ya cerrada"
curl -s -w " → %{http_code}\n" -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" -d "{\"grantId\":\"g-f1\",\"caseId\":\"C-F06\",\"prize\":\"spin:1\",\"reason\":\"forense\"}" $B/players/42/grants
'
echo "== log del binario"; docker exec r16t7-go grep -E "cierre|free-spins|spins|grants" /tmp/api.log | tail -12
