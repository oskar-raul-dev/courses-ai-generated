#!/usr/bin/env bash
# Levanta el anillo, mide arranque y memoria, prueba QUORUM con un nodo caído y lo borra con sus volúmenes.
set -uo pipefail
cd "$(dirname "$0")"
S=../salidas; mkdir -p "$S"
t0=$(date +%s)
docker compose up -d --wait 2>&1 | tail -3
echo "arranque_total_s=$(( $(date +%s) - t0 ))"
docker compose exec -T c1 nodetool status
sleep 20
docker stats --no-stream --format '{{.Name}} {{.MemUsage}}' | grep anillo
docker compose exec -T c1 cqlsh -e "
CREATE KEYSPACE IF NOT EXISTS sondeo WITH replication = {'class':'NetworkTopologyStrategy','datacenter1':3};
CREATE TABLE IF NOT EXISTS sondeo.t (k int PRIMARY KEY, v text);
CONSISTENCY QUORUM; INSERT INTO sondeo.t (k,v) VALUES (1,'a'); SELECT * FROM sondeo.t WHERE k=1;"
docker compose stop c3
docker compose exec -T c1 cqlsh -e "CONSISTENCY QUORUM; SELECT * FROM sondeo.t WHERE k=1;"
docker compose stop c2
docker compose exec -T c1 cqlsh -e "CONSISTENCY QUORUM; SELECT * FROM sondeo.t WHERE k=1;"
docker compose exec -T c1 cqlsh -e "CONSISTENCY ONE; SELECT * FROM sondeo.t WHERE k=1;"
docker compose down -v
