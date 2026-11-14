#!/usr/bin/env bash
# S10 · native-image: contrato, arranque, memoria, carga y cierre de un millón.
set -uo pipefail
cd "$(dirname "$0")/.."
L="--label curso=go-for-java-devs --network gfjd-net"; LIM="--cpus=4 --memory=2g"
NB="-v $PWD/salidas/native/target:/n"
FLY="-e SPRING_FLYWAY_BASELINE_ON_MIGRATE=true -e SPRING_FLYWAY_BASELINE_VERSION=2"
echo "### contrato"
docker exec gfjd-pg psql -U meridian -qc "DROP DATABASE IF EXISTS chtw" -c "CREATE DATABASE chtw"
docker run -d --name gfjd-chj $L $NB -e DATABASE_URL=jdbc:postgresql://gfjd-pg:5432/chtw debian:bookworm-slim /n/clearinghouse >/dev/null
until docker logs gfjd-chj 2>&1 | grep -q "Started\|FAILED\|Exception"; do sleep 0.5; done; docker logs gfjd-chj 2>&1 | grep -E "Started|ERROR" | head -3
NET=gfjd-net scripts/correr.sh scripts/s10-contract.sh corridas/s10-contract-native.log | grep -E "^(ok|FAIL)|--- FAIL|contract_test" | head -8
docker rm -f gfjd-chj >/dev/null
echo "### arranque en frío y RSS en reposo"
JE="-e DATABASE_URL=jdbc:postgresql://gfjd-pg:5432/chduel $FLY"
for i in 1 2 3 4 5; do docker run --rm $L $LIM $JE $NB -v "$PWD/scripts":/s:ro debian:bookworm-slim bash /s/cold-start.sh 8081 /n/clearinghouse | tr '\n' ' '; echo " ← native"; done
echo "### bajo carga"
docker run -d --name gfjd-chsp $L $LIM $JE $NB debian:bookworm-slim /n/clearinghouse >/dev/null; sleep 3
echo "GET http://gfjd-chsp:8081/movements?store=ST-001&limit=50&cursor=ST-001-R00050000" > salidas/targets-nat.txt
VEG() { docker run --rm $L -v gfjd-gopath:/go -v "$PWD/salidas":/out golang:1.25.1-bookworm sh -c "$1"; }
VEG "vegeta attack -targets=/out/targets-nat.txt -rate=200 -duration=30s > /dev/null"
c0=$(docker exec gfjd-chsp cat /sys/fs/cgroup/cpu.stat | awk '/usage_usec/{print $2}')
VEG "vegeta attack -targets=/out/targets-nat.txt -rate=500 -duration=60s > /out/res-nat.bin && vegeta report /out/res-nat.bin | sed -n '1,8p'"
c1=$(docker exec gfjd-chsp cat /sys/fs/cgroup/cpu.stat | awk '/usage_usec/{print $2}')
echo "CPU por petición: $(( (c1-c0)/30000 )) µs   memoria bajo carga: $(docker exec gfjd-chsp cat /sys/fs/cgroup/memory.current | awk '{printf "%.0f MB", $1/1048576}')"
docker rm -f gfjd-chsp >/dev/null
echo "### cierre de un millón (3 corridas)"
SQL() { docker exec gfjd-pg psql -U meridian -d chduel -qAt -c "$1"; }
for i in 1 2 3; do
  SQL "TRUNCATE ledger_entries, batches"; SQL "UPDATE movements SET status='received'"; SQL "VACUUM ANALYZE movements"
  docker run --rm $L $LIM $JE $NB debian:bookworm-slim sh -c "/n/clearinghouse --batch --day=2026-09-11 --chunk-size=5000 2>&1 | grep -E 'cierre|ERROR'; echo memory.peak=\$(cat /sys/fs/cgroup/memory.peak)" | tr '\n' ' '; echo
done
SQL "SELECT count(*) || ' ' || md5(string_agg(movement_id||'|'||account||'|'||amount_minor||'|'||currency||'|'||batch_id, ',' ORDER BY movement_id, account)) FROM ledger_entries"
