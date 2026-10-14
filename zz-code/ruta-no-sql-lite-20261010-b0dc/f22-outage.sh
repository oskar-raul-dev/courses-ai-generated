#!/usr/bin/env bash
# F22: la caída de Ecuador, en un demo recién creado, y el reloj de F21 otra vez en el
# mismo demo.
set -u
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-no-sql-lite/src
OUT=/Users/oskar/Developer/Learning/courses-ia-generated/zz-code/ruta-no-sql-lite-20261010-b0dc/salidas
(cd lab && docker compose --profile newsql-global up -d --wait --force-recreate 2>&1 | tail -1)
node 21-newsql-levantar-y-modelar/load.ts --target global --db condor --schema autoridad > $OUT/f22-setup-outage.txt 2>&1
node 21-newsql-levantar-y-modelar/placement.ts --db condor --schema autoridad --keep >> $OUT/f22-setup-outage.txt 2>&1
node 21-newsql-levantar-y-modelar/clock.ts --schema autoridad --runs 5 > $OUT/f22-clock.txt 2>&1
node 22-newsql-romper-y-medir/outage.ts > $OUT/f22-outage.txt 2>&1
echo "== f22-outage terminado $(docker inspect condor-lab-newsql-global-1 --format 'estado={{.State.Status}} OOM={{.State.OOMKilled}}') $(docker stats --no-stream --format '{{.MemUsage}}' condor-lab-newsql-global-1)" >> $OUT/f22-outage.txt
