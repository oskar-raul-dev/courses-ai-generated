#!/usr/bin/env bash
# be-18 con el binario: reclamar, girar, adelantar el "celular" cuatro horas, reclamar y girar otra vez.
# Uso: trabajo/incidentes/be18-binario.sh <ref>   (cambia el árbol de esclusa-app a <ref> y vuelve a master)
Z="$(cd "$(dirname "$0")/../.." && pwd)"
git -C "$Z/esclusa-app" checkout -q "$1"
"$Z/trabajo/go-reiniciar.sh" >/dev/null 2>&1
echo "# be-18 · $1 · $(date -u +%FT%TZ)"
"$Z/trabajo/tools.sh" '
B=http://r16t7-go:3011
echo "== reclama y gira"
curl -s -w " → %{http_code}\n" -X POST $B/players/43/free-spins
curl -s -w " → %{http_code}\n" -X POST -d "{\"idempotencyKey\":\"be18-1\"}" $B/players/43/spins
ADELANTE=$(date -u -d "@$(( $(date -u +%s) + 4*3600 + 60 ))" +%Y-%m-%dT%H:%M:%SZ)
echo "== el celular, cuatro horas y un minuto adelante: X-Client-Now: $ADELANTE"
curl -s -w " → %{http_code}\n" -X POST -H "X-Client-Now: $ADELANTE" $B/players/43/free-spins
curl -s -w " → %{http_code}\n" -X POST -d "{\"idempotencyKey\":\"be18-2\"}" $B/players/43/spins'
echo "== spin_log"
docker exec r16t7-pg psql -U esclusa -d esclusa -Atc "SELECT idempotency_key, origin, to_char(created_at AT TIME ZONE 'UTC', 'HH24:MI:SS.MS') FROM spin_log WHERE player_id = 43 AND idempotency_key LIKE 'be18-%' ORDER BY id"
echo "== la consulta que los encuentra"
docker exec r16t7-pg psql -U esclusa -d esclusa -Atc "SELECT id, name, to_char(next_free_spin_at AT TIME ZONE 'UTC', 'HH24:MI:SS'), to_char(now() AT TIME ZONE 'UTC', 'HH24:MI:SS') FROM players WHERE next_free_spin_at > now() + interval '4 hours'"
git -C "$Z/esclusa-app" checkout -q master
