#!/bin/bash
# La réplica de lectura: la primera vez copia el primario con pg_basebackup (-R la deja como standby que sigue
# su WAL por streaming); las siguientes, arranca con lo que ya tiene.
set -e
D=/var/lib/postgresql/18/docker
if [ ! -s "$D/PG_VERSION" ]; then
  mkdir -p "$D" && chown -R postgres:postgres /var/lib/postgresql && chmod 700 "$D"
  until gosu postgres pg_isready -h primario -U postgres -q; do sleep 1; done
  PGPASSWORD=condor gosu postgres pg_basebackup -h primario -U postgres -D "$D" -R -X stream
fi
exec gosu postgres postgres -D "$D" -c hot_standby=on
