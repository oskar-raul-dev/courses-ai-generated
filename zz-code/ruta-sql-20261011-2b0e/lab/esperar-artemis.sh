#!/usr/bin/env bash
# Artemis has no healthcheck in the test compose: time from container start to "AMQ221007: Server is now active".
set -uo pipefail
cd "$(dirname "$0")/.."
cid=$(docker compose -f lab/compose.yaml --profile puente ps -q broker)
t0=$(date -d "$(docker inspect -f '{{.State.StartedAt}}' "$cid")" +%s 2>/dev/null || python3 -c "import datetime,sys;print(int(datetime.datetime.fromisoformat(sys.argv[1][:26]+'+00:00').timestamp()))" "$(docker inspect -f '{{.State.StartedAt}}' "$cid")")
for _ in $(seq 1 300); do docker logs "$cid" 2>&1 | grep -q "AMQ221007" && break; sleep 1; done
echo "broker activo a los $(( $(date +%s) - t0 ))s · $(docker stats --no-stream --format '{{.MemUsage}}' "$cid")"
docker logs "$cid" 2>&1 | grep -m1 "AMQ221007\|AMQ221001"
