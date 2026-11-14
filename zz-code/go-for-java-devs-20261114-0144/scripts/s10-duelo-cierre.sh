#!/usr/bin/env bash
# S10 · B-24 (cierre de un millón) y la prueba de asientos idénticos. Corre en el host.
set -uo pipefail
cd "$(dirname "$0")/.."
SP=$(cd ../../cursos-algoritmos-lenguajes/go-for-java-devs/src/clearinghouse-spring && pwd)
L="--label curso=go-for-java-devs --network gfjd-net"
LIM="--cpus=4 --memory=2g"
DAY=2026-09-11; CHUNK=${CHUNK:-5000}; N=${N:-1000000}
SQL() { docker exec gfjd-pg psql -U meridian -d chduel -qAt -c "$1"; }
GOENV="-e DATABASE_URL=postgres://meridian:meridian@gfjd-pg:5432/chduel?sslmode=disable"
JENV="-e DATABASE_URL=jdbc:postgresql://gfjd-pg:5432/chduel -e SPRING_FLYWAY_BASELINE_ON_MIGRATE=true -e SPRING_FLYWAY_BASELINE_VERSION=2"
TUNED="-XX:+UseG1GC -XX:MaxRAMPercentage=75.0 -XX:InitialRAMPercentage=50.0 -XX:MaxGCPauseMillis=100 -XX:+UseStringDeduplication -XX:+TieredCompilation -XX:+AlwaysPreTouch -Xss512k -XX:+ExitOnOutOfMemoryError"

echo "### binario Go"
docker run --rm $L -v gfjd-gopath:/go -v "$PWD/ch-go":/ch -w /ch -e GOWORK=off -e CGO_ENABLED=0 golang:1.25.1-bookworm \
  go build -trimpath -ldflags "-s -w" -o /ch/bin/clearinghouse . && ls -l ch-go/bin/clearinghouse | awk '{print "tamaño:", $5}'
if [ -z "${SOLO_SPRING:-}" ]; then
echo "### base y semilla ($N movimientos)"
docker exec gfjd-pg psql -U meridian -qc "DROP DATABASE IF EXISTS chduel" -c "CREATE DATABASE chduel"
for f in V1__clearinghouse V2__stores; do docker exec -i gfjd-pg psql -U meridian -d chduel -q -v ON_ERROR_STOP=1 < "$SP/src/main/resources/db/migration/$f.sql"; done
time docker run --rm $L $GOENV -v "$PWD/ch-go/bin":/b debian:bookworm-slim /b/clearinghouse seed --movements $N --seed 42
SQL "VACUUM ANALYZE movements"
SQL "SELECT type, count(*) FROM movements GROUP BY 1 ORDER BY 1" | tr '\n' ' '; echo
fi
HASH="SELECT count(*) || ' ' || md5(string_agg(movement_id||'|'||account||'|'||amount_minor||'|'||currency||'|'||batch_id, ',' ORDER BY movement_id, account)) FROM ledger_entries"
reset() { SQL "TRUNCATE ledger_entries, batches"; SQL "UPDATE movements SET status='received'"; SQL "VACUUM ANALYZE movements"; }

[ -z "${SOLO_SPRING:-}" ] && for i in 1 2 3; do
  reset; echo "### Go, corrida $i"
  /usr/bin/time -p docker run --rm $L $LIM $GOENV -v "$PWD/ch-go/bin":/b debian:bookworm-slim \
    sh -c "/b/clearinghouse close --day $DAY --chunk-size $CHUNK && echo memory.peak=\$(cat /sys/fs/cgroup/memory.peak)" 2>&1 | grep -E "cierre|peak|real"
  [ $i = 1 ] && echo "asientos Go: $(SQL "$HASH")" && echo "estados Go: $(SQL "SELECT status, count(*) FROM movements GROUP BY 1 ORDER BY 1" | tr '\n' ' ')"
done
for cfg in defecto ajustada; do
  for i in 1 2 3; do
    reset; echo "### Spring Boot ($cfg), corrida $i"
    opts=""; [ $cfg = ajustada ] && opts="$TUNED"
    /usr/bin/time -p docker run --rm $L $LIM $JENV -v "$SP/target":/app eclipse-temurin:21-jre \
      sh -c "java $opts -jar /app/clearinghouse.jar --batch --day=$DAY --chunk-size=$CHUNK 2>&1 | grep -E 'cierre|ERROR|Exception' ; echo memory.peak=\$(cat /sys/fs/cgroup/memory.peak)" 2>&1 | grep -E "cierre|peak|real|ERROR|Exception"
    [ $i = 1 ] && [ $cfg = defecto ] && echo "asientos Spring: $(SQL "$HASH")" && echo "estados Spring: $(SQL "SELECT status, count(*) FROM movements GROUP BY 1 ORDER BY 1" | tr '\n' ' ')"
  done
done
