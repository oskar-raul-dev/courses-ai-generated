#!/usr/bin/env bash
# El cierre de un millón en native-image, por HTTP (el modo --batch no funciona en nativo).
cd "$(dirname "$0")/.."
S(){ docker exec gfjd-pg psql -U meridian -d chduel -qAt -c "$1"; }
C="docker run --rm --label curso=go-for-java-devs --network gfjd-net curlimages/curl:8.11.1 -s"
for i in 1 2 3; do
  S "TRUNCATE ledger_entries, batches"; S "UPDATE movements SET status='received'"; S "VACUUM ANALYZE movements"
  docker run -d --name gfjd-nat --label curso=go-for-java-devs --network gfjd-net --cpus=4 --memory=2g -e DATABASE_URL=jdbc:postgresql://gfjd-pg:5432/chduel -v "$PWD/salidas/native/target":/n debian:bookworm-slim /n/clearinghouse >/dev/null
  until docker logs gfjd-nat 2>&1 | grep -q Started; do sleep 0.3; done
  t0=$(date +%s.%N); $C -X POST -H 'Content-Type: application/json' -d '{"day":"2026-09-11","chunk_size":5000}' http://gfjd-nat:8081/runs >/dev/null
  until [ "$(S "SELECT status FROM batches WHERE id='b-2026-09-11'")" != running ]; do sleep 0.5; done
  t1=$(date +%s.%N)
  echo "native corrida $i: $(S "SELECT status FROM batches WHERE id='b-2026-09-11'") en $(echo "$t1 - $t0" | bc) s, memory.peak=$(docker exec gfjd-nat cat /sys/fs/cgroup/memory.peak)"
  docker rm -f gfjd-nat >/dev/null
done
S "SELECT count(*) || ' ' || md5(string_agg(movement_id||'|'||account||'|'||amount_minor||'|'||currency||'|'||batch_id, ',' ORDER BY movement_id, account)) FROM ledger_entries"
