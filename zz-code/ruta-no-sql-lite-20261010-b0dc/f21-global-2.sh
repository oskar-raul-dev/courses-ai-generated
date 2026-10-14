#!/usr/bin/env bash
# F21, segunda pasada: las tres corridas otra vez, con placement.ts esperando a los leaseholders y
# regions.ts contando el quórum. Las tres corridas de newsql-global, cada una con el demo recién creado (los datos viven en memoria y
# dos bases a la vez rozan el límite de la VM). Deja una salida por corrida en salidas/f21-global-*.txt y la
# memoria del contenedor cada 15 s en salidas/f21-mem-global.txt.
set -u
SRC=/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-no-sql-lite/src
OUT=/Users/oskar/Developer/Learning/courses-ia-generated/zz-code/ruta-no-sql-lite-20261010-b0dc/salidas
cd "$SRC"
mem() { echo "$(date +%T) $1 $(docker stats --no-stream --format '{{.MemUsage}}' condor-lab-newsql-global-1)" >> "$OUT/f21-mem-global.txt"; }
fresh() { (cd lab && docker compose --profile newsql-global up -d --wait --force-recreate 2>&1 | tail -1); mem "fresco"; }
echo "== segunda pasada" >> "$OUT/f21-mem-global.txt"

run() {  # $1 = nombre, $2 = base, $3 = esquema, $4… = pasos extra
  local name=$1 db=$2 schema=$3; shift 3
  local log="$OUT/f21-global-$name.txt"
  : > "$log"
  fresh
  node 21-newsql-levantar-y-modelar/load.ts --target global --db "$db" --schema "$schema" >> "$log" 2>&1; mem "cargado $name"
  node 21-newsql-levantar-y-modelar/placement.ts --db "$db" --schema "$schema" --keep >> "$log" 2>&1; mem "placement $name"
  node 21-newsql-levantar-y-modelar/regions.ts --db "$db" --schema "$schema" >> "$log" 2>&1; mem "regions $name"
  for step in "$@"; do eval "$step" >> "$log" 2>&1; mem "$step"; done
  echo "== $name terminado" >> "$log"
}

run copia condor_copia copy "node 21-newsql-levantar-y-modelar/ranges.ts --target global --db condor_copia"
run regional condor regional "node 21-newsql-levantar-y-modelar/ranges.ts --target global --db condor"
run autoridad condor autoridad "node 21-newsql-levantar-y-modelar/ranges.ts --target global --db condor" "node 21-newsql-levantar-y-modelar/clock.ts --schema autoridad --runs 5"
docker inspect condor-lab-newsql-global-1 --format 'estado {{.State.Status}} OOM={{.State.OOMKilled}}' >> "$OUT/f21-mem-global.txt"
echo "== segunda pasada terminada" >> "$OUT/f21-mem-global.txt"
