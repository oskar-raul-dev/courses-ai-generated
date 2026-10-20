#!/usr/bin/env bash
# be07: la conciliación del servidor contra la de la consola, sobre la misma bitácora sembrada.
# Rehace la base, levanta el binario en el 3011 (con PLAY_URL=http://app:3002) y concilia la Rueda de fin de mes
# mandando el cuerpo que calculó la consola (salidas/be07-consola-ref.json, de trabajo/be07/consola-ref.test.js).
# Uso: trabajo/be07-conciliacion.sh [cuerpo.json]   (por defecto, el de la consola)
Z="$(cd "$(dirname "$0")/.." && pwd)"
BODY="${1:-$Z/salidas/be07-consola-ref.json}"
"$Z/trabajo/go-reiniciar.sh" >/dev/null 2>&1
cp "$BODY" "$Z/esclusa-app/.cuerpo-conciliacion.json"
"$Z/trabajo/tools.sh" '
B=http://r16t7-go:3011
TOKEN=$(curl -s -X POST $B/login -H "Content-Type: application/json" -d "{\"email\":\"mdegracia@esclusa.test\",\"password\":\"esclusa123\"}" | jq -r .token)
echo "== GET /wheels/4/audit"
curl -s -H "Authorization: Bearer $TOKEN" $B/wheels/4/audit | jq -c ".[] | {wheelVersion, spins, counts: [.segments[].landed], chi2, chi2Alarm, bandAlarms}"
echo "== POST /wheels/4/reconciliation"
curl -s -w "\n→ %{http_code}\n" -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d @.cuerpo-conciliacion.json $B/wheels/4/reconciliation | sed "s/,\"wheel\":{[^}]*}//"'
rm -f "$Z/esclusa-app/.cuerpo-conciliacion.json"
echo "== log"; docker exec r16t7-go grep -a "reconciliation\|difiere" /tmp/api.log | tail -3
