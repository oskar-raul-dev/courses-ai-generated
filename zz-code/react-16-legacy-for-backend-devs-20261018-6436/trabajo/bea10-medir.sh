#!/usr/bin/env bash
# bea-10: semilla fija, semilla distinta, una llamada de más, ANALYZE y el borrado del volumen.
Z="$(cd "$(dirname "$0")/.." && pwd)"
U="postgres://esclusa:esclusa@pg:5432/esclusa?sslmode=disable"
q() { docker exec r16t7-pg psql -U esclusa -d esclusa -At -c "$1"; }
huella() { q "SELECT md5(string_agg(id || name || coalesce(country,'') || free_spins || paid_spins, ',' ORDER BY id)) || ' · inventario ' || (SELECT md5(string_agg(player_id || prize, ',' ORDER BY player_id, prize)) FROM player_inventory WHERE player_id >= 100000) FROM players WHERE id >= 100000"; }
reset() { "$Z/trabajo/go-reiniciar.sh" >/dev/null 2>&1; }
vol() { docker exec r16t7-go sh -c "cd /app/server && DATABASE_URL='$U' go run ./cmd/seed -volume -players 10000 -seed $1 2>&1 | tail -1"; }
echo "## 1. Misma semilla dos veces, y otra semilla"
reset; vol 42; echo "seed 42, corrida 1: $(huella)"
q "SELECT id, name, country, free_spins, paid_spins FROM players WHERE id >= 100000 ORDER BY id LIMIT 3"
reset; vol 42; echo "seed 42, corrida 2: $(huella)"
reset; vol 43; echo "seed 43:           $(huella)"
echo "## 2. Una llamada de más al generador, misma semilla y misma versión"
cp "$Z/esclusa-app/server/internal/seed/fake.go" /tmp/fake.go.bak 2>/dev/null
docker exec r16t7-go sh -c "cd /app/server && cp internal/seed/fake.go /tmp/fake.orig && sed -i 's|	faker := gofakeit.New(seed)|	faker := gofakeit.New(seed)\n	_ = faker.Bool() // una llamada de más, antes de todo|' internal/seed/fake.go"
reset; vol 42; echo "seed 42 con una llamada de más: $(huella)"
q "SELECT id, name, country, free_spins, paid_spins FROM players WHERE id >= 100000 ORDER BY id LIMIT 3"
docker exec r16t7-go sh -c "cd /app/server && cp /tmp/fake.orig internal/seed/fake.go"
echo "## 3. ANALYZE"
reset; q "ALTER TABLE players SET (autovacuum_enabled = false)"; vol 42
docker exec r16t7-pg psql -U esclusa -d esclusa -c "EXPLAIN SELECT * FROM players WHERE country = 'Chile'"
q "SELECT count(*) AS reales FROM players WHERE country = 'Chile'"
q "ANALYZE players"
docker exec r16t7-pg psql -U esclusa -d esclusa -c "EXPLAIN SELECT * FROM players WHERE country = 'Chile'"
q "ALTER TABLE players RESET (autovacuum_enabled)"
echo "## 4. Girar con el volumen, y después borrarlo"
for p in 100000 100001 100002 100003 100004; do
  "$Z/trabajo/tools.sh" "curl -s -o /dev/null -w '%{http_code} ' -X POST -d '{\"idempotencyKey\":\"vol-$p\"}' http://go:3011/players/$p/spins"
done; echo
q "SELECT count(*) || ' giros del volumen en la bitácora' FROM spin_log WHERE player_id >= 100000"
docker exec r16t7-pg psql -U esclusa -d esclusa -v VERBOSITY=verbose -c "DELETE FROM players WHERE id >= 100000" 2>&1 | head -3
docker exec r16t7-pg psql -U esclusa -d esclusa -c "DELETE FROM spin_log WHERE player_id >= 100000" 2>&1 | head -1
