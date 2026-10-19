#!/usr/bin/env bash
# E-69: la consulta original con paralelismo forzado (4 workers), por work_mem, con el /dev/shm que tenga
# el contenedor ahora. Uso: ./matriz.sh  (lee consulta-original.sql de este directorio)
cd "$(dirname "$0")"
echo "/dev/shm: $(docker exec alameda-lab-postgres-1 df -h /dev/shm | awk 'NR==2{print $2}')"
for wm in 4MB 16MB 32MB 64MB; do
  out=$( { echo "SET max_parallel_workers_per_gather=4; SET parallel_setup_cost=0; SET parallel_tuple_cost=0; SET work_mem='$wm';"; tail -n +3 consulta-original.sql; } | ../psql.sh 2>&1 | grep -E "ERROR|^ +[0-9]" | head -1)
  echo "work_mem=$wm → ${out:0:90}"
done
echo "con los valores por defecto (2 workers, 4MB): $(tail -n +3 consulta-original.sql | ../psql.sh 2>&1 | grep -E 'ERROR|^ +[0-9]' | head -1 | cut -c1-90)"
