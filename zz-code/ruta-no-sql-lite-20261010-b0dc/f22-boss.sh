#!/usr/bin/env bash
# F22: la forma partida y las tres roturas del Bloque IV para la solución privada del boss IV, en secuencia (H13:
# no caben juntas). Salidas en salidas/f22-contention-global-split-3.txt y salidas/f22-boss-*.txt.
set -u
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-no-sql-lite/src
OUT=/Users/oskar/Developer/Learning/courses-ia-generated/zz-code/ruta-no-sql-lite-20261010-b0dc/salidas
DC="docker compose -f lab/compose.yaml"
# 1 · NewSQL: la forma partida, y la contención alta con su mensaje literal
(cd lab && docker compose --profile newsql-global up -d --wait --force-recreate 2>&1 | tail -1)
node 21-newsql-levantar-y-modelar/load.ts --target global --db condor --schema autoridad > $OUT/f22-boss-setup.txt 2>&1
node 21-newsql-levantar-y-modelar/placement.ts --db condor --schema autoridad --keep >> $OUT/f22-boss-setup.txt 2>&1
node 22-newsql-romper-y-medir/contention.ts --target global --kind split > $OUT/f22-contention-global-split-3.txt 2>&1
node 22-newsql-romper-y-medir/contention.ts --target global --kind rmw --steps 16 > $OUT/f22-boss-newsql.txt 2>&1
echo "== newsql $(docker inspect condor-lab-newsql-global-1 --format 'estado={{.State.Status}} OOM={{.State.OOMKilled}}')" >> $OUT/f22-boss-newsql.txt
(cd lab && docker compose --profile newsql-global stop 2>&1 | tail -1)
# 2 · columnar ancha: la partición sin cota de F18, hasta los 2 M
$DC --profile columnar up -d --wait 2>&1 | tail -1
node 18-columnar-romper-y-medir/unbounded.ts --steps 1,2 > $OUT/f22-boss-columnar.txt 2>&1
$DC restart columnar 2>&1 | tail -1
until $DC exec -T columnar cqlsh -e "DROP TABLE IF EXISTS condor.reading_unbounded" >/dev/null 2>&1; do sleep 10; done
$DC exec -T columnar sh -c 'ls /var/log/cassandra/*.hprof 2>/dev/null; rm -f /var/log/cassandra/*.hprof' >> $OUT/f22-boss-columnar.txt 2>&1
$DC --profile columnar stop 2>&1 | tail -1
# 3 · offline-first: la sincronización que no converge, tres rondas
$DC --profile offline up -d --wait 2>&1 | tail -1
node 20-offline-romper-y-medir/pingpong.ts --rounds 3 > $OUT/f22-boss-offline.txt 2>&1
$DC --profile offline stop 2>&1 | tail -1
echo "== boss terminado" >> $OUT/f22-boss-offline.txt
