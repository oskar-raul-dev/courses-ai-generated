#!/usr/bin/env bash
# Validación del cierre del Bloque II: corre en orden los scripts de src/09 a src/14 sobre una carga nueva con
# --model, y deja cada salida en validacion-t6/. Los que usan \ir se copian al contenedor y corren desde ahí.
set -uo pipefail
cd "$(dirname "$0")/.."
SRC=../../cursos-bd/ruta-sql/src
OUT=validacion-t6
PG=(docker exec -i alameda-lab-postgres-1 psql -v ON_ERROR_STOP=0 -U postgres -d alameda)
MY=(docker exec -i alameda-lab-mysql-1 mysql -uroot -plab --raw --force)
pg() { echo "== $1"; "${PG[@]}" < "$SRC/$1" > "$OUT/$(echo "$1" | tr '/' '_').txt" 2>&1; }
my() { echo "== $1"; "${MY[@]}" < "$SRC/$1" > "$OUT/$(echo "$1" | tr '/' '_').txt" 2>&1; }
py() { echo "== $1"; ./correr-python.sh "/src/$1" > "$OUT/$(echo "$1" | tr '/' '_').txt" 2>&1; }
for f in 01_file_listing 02_report_files 03_alignment 04_result_by_month 05_compression; do pg 09-el-tamano-de-las-cosas/$f.sql; done
for f in 01_postgres_keys 02_load_keys 03_sequence_behind 04_what_ids_leak; do pg 10-identificadores/$f.sql; done
py 10-identificadores/mysql_keys.py
docker cp "$SRC/11-indices-y-lo-que-cuestan" alameda-lab-postgres-1:/tmp/ >/dev/null
for f in 01_write_cost 02_hot_updates 03_index_kinds 04_free_text_index; do
  echo "== 11/$f"
  docker exec -w /tmp/11-indices-y-lo-que-cuestan alameda-lab-postgres-1 psql -U postgres -d alameda -f $f.sql \
    > "$OUT/11_$f.txt" 2>&1
done
for f in 01_text_and_correlation 02_stale_statistics 03_plan_cliff; do pg 12-estadisticas-y-cardinalidad/$f.sql; done
my 12-estadisticas-y-cardinalidad/04_mysql_histograms.sql
for f in 01_generic_plans 02_join_methods 05_fixed_plan_over_time; do pg 13-el-optimizador-en-tres-motores/$f.sql; done
my 13-el-optimizador-en-tres-motores/03_mysql_prepared.sql
my 13-el-optimizador-en-tres-motores/04_the_hint.sql
py 13-el-optimizador-en-tres-motores/psycopg_prepare.py
my 14-la-base-no-estaba-lenta/01_autoindex_copy.sql
py 14-la-base-no-estaba-lenta/front.py
pg 14-la-base-no-estaba-lenta/02_portal_paging.sql
pg 14-la-base-no-estaba-lenta/03_stat_statements.sql
docker exec alameda-lab-postgres-1 mkdir -p /tmp/f14
docker cp "$SRC/14-la-base-no-estaba-lenta/portal_offset.pgbench" alameda-lab-postgres-1:/tmp/f14/ >/dev/null
docker cp "$SRC/14-la-base-no-estaba-lenta/portal_keyset.pgbench" alameda-lab-postgres-1:/tmp/f14/ >/dev/null
for s in offset keyset; do
  echo "== pgbench $s"
  docker exec -w /tmp/f14 alameda-lab-postgres-1 sh -c "rm -f lat_$s*; pgbench -U postgres -n -c 8 -j 4 -T 30 \
    -f portal_$s.pgbench --log --log-prefix=lat_$s alameda 2>&1 | grep -E 'actually|latency average|tps'; \
    cat lat_$s* | awk '{n++; if (\$3/1000 > 100) o++} END {printf \"n=%d >100ms=%d (%.1f%%)\\n\", n, o, 100*o/n}'" \
    > "$OUT/14_pgbench_$s.txt" 2>&1
done
pg 14-la-base-no-estaba-lenta/boss/01_portal_2018.sql
echo "== listo"
