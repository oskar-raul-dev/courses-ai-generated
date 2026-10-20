#!/usr/bin/env bash
# be-17: dos arranques del binario, N giros cada uno sobre la Esclusa de Oro (rueda 1), y la
# comparación de las dos secuencias. Uso: trabajo/be05-reinicios.sh <ref> [N]
Z="$(cd "$(dirname "$0")/.." && pwd)"
REF="$1"; N="${2:-2000}"
git -C "$Z/esclusa-app" checkout -q "$REF" || exit 1
"$Z/trabajo/go-reiniciar.sh" >/dev/null 2>&1
docker exec r16t7-pg psql -q -U esclusa -d esclusa -c "UPDATE players SET free_spins = 2 * $N WHERE id = 42"
boot() { # $1 número de arranque
  docker exec r16t7-go sh -c 'kill $(pidof api) 2>/dev/null; sleep 0.5; cd /app/server && (JWT_SECRET=laboratorio-esclusa-secreto-de-32-bytes-o-mas DATABASE_URL="postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable&timezone=America/Panama" PORT=3011 /tmp/api > /tmp/api.log 2>&1 &); sleep 1'
  "$Z/trabajo/tools.sh" "for i in \$(seq 1 $N); do curl -s -X POST -d \"{\\\"idempotencyKey\\\":\\\"arranque$1-\$i\\\"}\" http://go:3011/players/42/spins | jq -r .landedSegment; done" > "$Z/salidas/be17-arranque$1.txt"
}
boot 1; boot 2
echo "## $REF · $N giros por arranque · $(date -u +%FT%TZ)"
echo "primeros diez, arranque 1: $(head -10 "$Z/salidas/be17-arranque1.txt" | tr '\n' ' ')"
echo "primeros diez, arranque 2: $(head -10 "$Z/salidas/be17-arranque2.txt" | tr '\n' ' ')"
echo "posiciones iguales: $(paste "$Z/salidas/be17-arranque1.txt" "$Z/salidas/be17-arranque2.txt" | awk '$1==$2' | wc -l | tr -d ' ') de $N"
docker exec -i r16t7-pg psql -U esclusa -d esclusa <<SQL
-- χ² de cada arranque contra los pesos publicados (8 segmentos, 7 grados de libertad; 14,07 al 5 %)
WITH w AS (SELECT s.segment_id, s.weight_bp FROM wheel_segments s JOIN wheel_versions v ON v.id = s.wheel_version_id WHERE v.wheel_id = 1),
     obs AS (SELECT split_part(idempotency_key, '-', 1) AS arranque, landed_segment, count(*) AS n
             FROM spin_log WHERE idempotency_key LIKE 'arranque%' GROUP BY 1, 2)
SELECT a.arranque, round(sum(power(coalesce(o.n, 0) - $N * w.weight_bp / 10000.0, 2) / ($N * w.weight_bp / 10000.0)), 2) AS chi2
FROM w CROSS JOIN (SELECT DISTINCT arranque FROM obs) a
LEFT JOIN obs o ON o.arranque = a.arranque AND o.landed_segment = w.segment_id
GROUP BY a.arranque ORDER BY 1;
SQL
git -C "$Z/esclusa-app" checkout -q master
