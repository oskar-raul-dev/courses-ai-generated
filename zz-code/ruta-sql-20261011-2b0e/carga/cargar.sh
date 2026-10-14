#!/usr/bin/env bash
# Loads a profile of the box into one engine of the test lab. Usage: carga/cargar.sh postgres|mysql|oracle [s|m]
# Output: salidas/carga-<engine>-<profile>.log (Oracle times stay in salidas/, never published).
set -uo pipefail
cd "$(dirname "$0")/.."
engine="$1"; perfil="${2:-m}"
C="docker compose -f lab/compose.yaml --profile base --profile contraste --profile oracle"
log="salidas/carga-$engine-$perfil.log"
inicio=$(date +%s)
case "$engine" in
  postgres) $C exec -T postgres psql -U postgres -d alameda -v perfil="$perfil" -f - < carga/postgres.sql ;;
  mysql)    sed "s#/caja/m/#/caja/$perfil/#" carga/mysql.sql | $C exec -T mysql mysql -uroot -plab -t ;;
  oracle)   sed "s#PERFIL#$perfil#g" carga/oracle.sql | $C exec -T oracle sqlplus -s alameda/lab@//localhost/FREEPDB1 ;;
esac > "$log" 2>&1
echo "total_seconds=$(( $(date +%s) - inicio ))" >> "$log"
grep -v '^$' "$log" | tail -25
