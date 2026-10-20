#!/usr/bin/env bash
# bea-11 §4: el mismo giro.js con y sin expectedStatuses(200, 409), 150 claves a 50/s contra be05.
Z="$(cd "$(dirname "$0")/.." && pwd)"
"$Z/trabajo/go-reiniciar.sh" >/dev/null 2>&1
docker exec -i r16t7-pg psql -q -U esclusa -d esclusa < "$Z/esclusa-app/server/load/rueda-de-medicion.sql"
docker exec -i r16t7-pg psql -q -U esclusa -d esclusa -c "UPDATE stock SET remaining = 100 WHERE wheel_id = 900"
for f in "$Z/esclusa-app/server/load/giro.js" "$Z/trabajo/bea11/giro-sin-callback.js"; do
  echo "== $(basename "$f")"
  docker run --rm -i --label curso=react16 --network r16t7-net -e BASE_URL=http://go:3011 -e KEYS=150 -e PLAYERS=10 -e PLAYER_BASE=10000 \
    grafana/k6:1.5.0 run - < "$f" 2>&1 | grep -E "http_req_failed|status:(200|409)|thresholds on"
done
