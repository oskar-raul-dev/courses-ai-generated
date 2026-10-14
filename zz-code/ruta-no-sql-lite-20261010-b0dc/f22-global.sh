#!/usr/bin/env bash
# F22: dos corridas de newsql-global, cada una con el demo recién creado: la latencia con el esquema copiado, y la
# caída de Ecuador con la autoridad en la clave y la ubicación restringida.
set -u
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-no-sql-lite/src
OUT=/Users/oskar/Developer/Learning/courses-ia-generated/zz-code/ruta-no-sql-lite-20261010-b0dc/salidas
fresh() { (cd lab && docker compose --profile newsql-global up -d --wait --force-recreate 2>&1 | tail -1); }
fresh
node 21-newsql-levantar-y-modelar/load.ts --target global --db condor_copia > $OUT/f22-setup-copia.txt 2>&1
node 22-newsql-romper-y-medir/latency.ts --db condor_copia --schema copy > $OUT/f22-latency-copia.txt 2>&1
fresh
node 21-newsql-levantar-y-modelar/load.ts --target global --db condor --schema autoridad > $OUT/f22-setup-outage.txt 2>&1
node 21-newsql-levantar-y-modelar/placement.ts --db condor --schema autoridad --keep >> $OUT/f22-setup-outage.txt 2>&1
node 22-newsql-romper-y-medir/outage.ts > $OUT/f22-outage.txt 2>&1
echo "== f22-global terminado $(docker inspect condor-lab-newsql-global-1 --format 'estado={{.State.Status}} OOM={{.State.OOMKilled}}')" >> $OUT/f22-outage.txt
