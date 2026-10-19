#!/bin/sh
# Mide el giro ingenuo y el transaccional con k6 en una red privada de Docker.
# Sin puertos publicados. Solo borra lo que crea (etiqueta curso=react16).
set -eu
MODO="$1"                     # ingenuo | transaccional
DIR="$(cd "$(dirname "$0")" && pwd)"
SAL="$DIR/../../salidas"
NET=r16p7-net
PG=r16p7-pg
APP=r16p7-app-$MODO
L="--label curso=react16"

docker network create $L $NET >/dev/null 2>&1 || true
if ! docker ps --format '{{.Names}}' | grep -qx $PG; then
  docker run -d $L --name $PG --network $NET -e POSTGRES_PASSWORD=lab -e POSTGRES_DB=esclusa postgres:13 >/dev/null
  until docker exec $PG pg_isready -U postgres >/dev/null 2>&1; do sleep 1; done
fi
# Esquema limpio para cada modo.
docker exec -i $PG psql -U postgres -d esclusa -q -c 'DROP TABLE IF EXISTS spin_log; DROP TABLE IF EXISTS stock;' >/dev/null
docker exec -i $PG psql -U postgres -d esclusa -q < "$DIR/schema.sql"
if [ "$MODO" = transaccional ]; then
  docker exec $PG psql -U postgres -d esclusa -q -c "CREATE UNIQUE INDEX spin_log_key_uniq ON spin_log (key);"
fi

docker rm -f $APP >/dev/null 2>&1 || true
docker run -d $L --name $APP --network $NET -e MODO=$MODO \
  -e DATABASE_URL=postgres://postgres:lab@$PG:5432/esclusa \
  -v "$DIR":/src:ro node:14.21.3 sh -c \
  'mkdir -p /app && cp /src/servidor.js /app/ && cd /app && npm install --no-audit --no-fund express@4.17.1 pg@8.7.3 >/dev/null 2>&1 && node servidor.js' >/dev/null
until docker logs $APP 2>&1 | grep -q escuchando; do sleep 2; done

docker run --rm $L --network $NET -v "$DIR":/src:ro -v "$SAL":/out -e BASE=http://$APP:3000 \
  grafana/k6:1.5.0 run --summary-export=/out/k6-giro-$MODO.json /src/giro-k6.js > "$SAL/k6-giro-$MODO.txt" 2>&1 || true

docker exec $PG psql -U postgres -d esclusa -At -c "
  SELECT 'filas_spin_log=' || count(*) FROM spin_log
  UNION ALL SELECT 'claves_distintas=' || count(DISTINCT key) FROM spin_log
  UNION ALL SELECT 'claves_con_mas_de_un_premio=' || count(*) FROM (SELECT key FROM spin_log GROUP BY key HAVING count(*) > 1) d
  UNION ALL SELECT 'premios_esclusa_de_oro=' || count(*) FROM spin_log WHERE landed_segment='esclusa-de-oro'
  UNION ALL SELECT 'stock_restante=' || remaining FROM stock
  UNION ALL SELECT 'stock_excedido=' || GREATEST(0, (SELECT count(*) FROM spin_log WHERE landed_segment='esclusa-de-oro') - 1000);" \
  > "$SAL/sql-giro-$MODO.txt"
cat "$SAL/sql-giro-$MODO.txt"
docker logs $APP > "$SAL/app-giro-$MODO.log" 2>&1 || true
docker rm -f -v $APP >/dev/null
