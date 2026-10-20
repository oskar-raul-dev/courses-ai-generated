#!/usr/bin/env bash
# be05 §6, paso 2: el giro de la API esperando un bloqueo, visto en pg_stat_activity; y el círculo del X-Request-Id.
Z="$(cd "$(dirname "$0")/.." && pwd)"
git -C "$Z/esclusa-app" checkout -q master
"$Z/trabajo/go-reiniciar.sh" >/dev/null 2>&1
docker exec -i r16t7-pg psql -q -U esclusa -d esclusa < "$Z/esclusa-app/server/load/rueda-de-medicion.sql"
docker exec r16t7-go sh -c 'kill $(pidof api); sleep 0.5; cd /app/server && (SPIN_DELIVERY_MS=2000 JWT_SECRET=laboratorio-esclusa-secreto-de-32-bytes-o-mas DATABASE_URL="postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable&timezone=America/Panama" PORT=3011 /tmp/api > /tmp/api.log 2>&1 &); sleep 1'
cat > "$Z/salidas/be05-forense-t1.sql" <<'SQL'
BEGIN;
SELECT remaining FROM stock WHERE wheel_id = 900 FOR UPDATE;
SELECT pg_sleep(3);
COMMIT;
SQL
cat > "$Z/salidas/be05-forense-t3.sql" <<'SQL'
SELECT pid, state, wait_event_type, wait_event, left(regexp_replace(query, '\s+', ' ', 'g'), 60) AS consulta
FROM pg_stat_activity
WHERE datname = 'esclusa' AND state <> 'idle' AND pid <> pg_backend_pid()
ORDER BY xact_start;
SELECT blocked.pid AS bloqueado, blocking.pid AS bloqueante,
       left(regexp_replace(blocked.query, '\s+', ' ', 'g'), 45) AS espera,
       left(regexp_replace(blocking.query, '\s+', ' ', 'g'), 45) AS culpable
FROM pg_stat_activity blocked
JOIN pg_stat_activity blocking ON blocking.pid = ANY(pg_blocking_pids(blocked.pid));
SQL
( docker exec -i r16t7-pg psql -U esclusa -d esclusa -a < "$Z/salidas/be05-forense-t1.sql" > "$Z/salidas/be05-forense-t1.txt" 2>&1 & )
sleep 0.5
( "$Z/trabajo/tools.sh" 'curl -s -D - -w "\n%{http_code} en %{time_total}s\n" -X POST -d "{\"idempotencyKey\":\"forense-1\"}" http://go:3011/players/10001/spins' > "$Z/salidas/be05-forense-a.txt" 2>&1 & )
sleep 0.5
( "$Z/trabajo/tools.sh" 'curl -s -D - -w "\n%{http_code} en %{time_total}s\n" -X POST -d "{\"idempotencyKey\":\"forense-1\"}" http://go:3011/players/10001/spins' > "$Z/salidas/be05-forense-b.txt" 2>&1 & )
sleep 1
docker exec -i r16t7-pg psql -U esclusa -d esclusa -a < "$Z/salidas/be05-forense-t3.sql" > "$Z/salidas/be05-forense-t3.txt" 2>&1
sleep 6
for f in t1 a b t3; do echo "──── $f"; cat "$Z/salidas/be05-forense-$f.txt"; done
echo "──── log del backend"; docker exec r16t7-go grep -E "POST /players/10001" /tmp/api.log
