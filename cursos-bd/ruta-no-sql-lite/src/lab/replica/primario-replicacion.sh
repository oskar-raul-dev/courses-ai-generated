#!/bin/bash
# Se ejecuta una sola vez, al crear el primario: deja entrar a la réplica por el protocolo de replicación.
set -e
echo "host replication all all scram-sha-256" >> "$PGDATA/pg_hba.conf"
