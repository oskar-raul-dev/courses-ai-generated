#!/usr/bin/env bash
# be-10: el proceso muere mientras el juego recibe el premio. Uso: trabajo/be05-corte.sh <ref>
Z="$(cd "$(dirname "$0")/.." && pwd)"
REF="$1"
git -C "$Z/esclusa-app" checkout -q "$REF" || exit 1
"$Z/trabajo/go-reiniciar.sh" >/dev/null 2>&1
docker exec r16t7-pg psql -q -U esclusa -d esclusa -c "UPDATE players SET free_spins = 5 WHERE id = 42"
start() {
  docker exec r16t7-go sh -c 'kill -9 $(pidof api) 2>/dev/null; sleep 0.5; cd /app/server && (SPIN_DELIVERY_MS=5000 JWT_SECRET=laboratorio-esclusa-secreto-de-32-bytes-o-mas DATABASE_URL="postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable&timezone=America/Panama" PORT=3011 /tmp/api >> /tmp/api.log 2>&1 &); sleep 1'
}
spin() { "$Z/trabajo/tools.sh" 'curl -s -m 8 -w " %{http_code}\n" -X POST -d "{\"idempotencyKey\":\"corte-1\"}" http://go:3011/players/42/spins'; }
q() { docker exec r16t7-pg psql -U esclusa -d esclusa -At -c "$1"; }
echo "## $REF · $(date -u +%FT%TZ)"
start
( spin > "$Z/salidas/be10-primer-intento.txt" & ) ; sleep 2
docker exec r16t7-go sh -c 'kill -9 $(pidof api)'; echo "kill -9 a los 2 s de la entrega"
sleep 1; echo "primer intento: $(cat "$Z/salidas/be10-primer-intento.txt")"
echo "pedido: $(q "SELECT status, coalesce(processing_until::text, 'NULL') FROM spin_requests WHERE idempotency_key = 'corte-1'")"
echo "bitácora: $(q "SELECT count(*) FROM spin_log WHERE idempotency_key = 'corte-1'") fila(s) · saldo: $(q "SELECT free_spins FROM players WHERE id = 42")"
start
echo "reintento al reiniciar: $(spin)"
sleep 40
echo "runbook a los 40 s: $(q "SELECT count(*) FROM spin_requests WHERE status = 'processing' AND processing_until < now()") vencido(s) · pedido: $(q "SELECT status FROM spin_requests WHERE idempotency_key = 'corte-1'")"
echo "reintento a los 40 s: $(spin)"
echo "barrido en el log: $(docker exec r16t7-go grep -c '\[barrido\]' /tmp/api.log)"
docker exec r16t7-go grep '\[barrido\]' /tmp/api.log | tail -2
git -C "$Z/esclusa-app" checkout -q master
