#!/usr/bin/env bash
# Corre una escena de bea-05: dos (o tres) sesiones de psql a la vez contra la base bea05.
# Uso: trabajo/bea05/escena.sh <nombre>   (lee <nombre>.t1.sql, <nombre>.t2.sql y, si existe, <nombre>.t3.sql)
D="$(cd "$(dirname "$0")" && pwd)"; N="$1"
docker exec r16t7-pg psql -q -U esclusa -d postgres -tc "SELECT 1 FROM pg_database WHERE datname='bea05'" | grep -q 1 || docker exec r16t7-pg createdb -U esclusa bea05
docker exec -i r16t7-pg psql -q -U esclusa -d bea05 < "$D/preparacion.sql" >/dev/null 2>&1
for t in t1 t2 t3; do
  [ -f "$D/$N.$t.sql" ] || continue
  ( docker exec -i r16t7-pg psql -U esclusa -d bea05 -a -v VERBOSITY=${VERBOSITY:-default} < "$D/$N.$t.sql" > "$D/salida-$N.$t.txt" 2>&1 ) &
done
wait
for t in t1 t2 t3; do [ -f "$D/salida-$N.$t.txt" ] && { echo "──── $N · $(echo $t | tr a-z A-Z)"; cat "$D/salida-$N.$t.txt"; }; done
true
