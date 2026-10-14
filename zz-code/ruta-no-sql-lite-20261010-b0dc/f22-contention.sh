#!/usr/bin/env bash
# F22: la escalera de contención, en CockroachDB (newsql-global con la base de la autoridad) y en el primario de
# Postgres (sin red: la referencia sin geografía). Una salida por variante en salidas/f22-contention-*.txt.
set -u
cd /Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-no-sql-lite/src
OUT=/Users/oskar/Developer/Learning/courses-ia-generated/zz-code/ruta-no-sql-lite-20261010-b0dc/salidas
C="node 22-newsql-romper-y-medir/contention.ts"
mem() { echo "$(date +%T) $1 $(docker stats --no-stream --format '{{.MemUsage}}' condor-lab-newsql-global-1)" >> $OUT/f22-mem-contention.txt; }
: > $OUT/f22-mem-contention.txt
$C --target global --regions CO,EC,PE --kind rmw    > $OUT/f22-contention-global-rmw-3.txt 2>&1; mem rmw3
$C --target global --regions CO,EC --kind rmw       > $OUT/f22-contention-global-rmw-2.txt 2>&1; mem rmw2
$C --target global --regions CO,EC,PE --kind atomic > $OUT/f22-contention-global-atomic-3.txt 2>&1; mem atomic3
$C --target primario --kind rmw                     > $OUT/f22-contention-pg-rmw.txt 2>&1
$C --target primario --kind rmw --isolation "READ COMMITTED" > $OUT/f22-contention-pg-rmw-rc.txt 2>&1
$C --target primario --kind atomic                  > $OUT/f22-contention-pg-atomic.txt 2>&1
echo "== contención terminada" >> $OUT/f22-mem-contention.txt
