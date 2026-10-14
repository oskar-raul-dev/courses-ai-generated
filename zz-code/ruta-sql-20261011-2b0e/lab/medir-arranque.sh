#!/usr/bin/env bash
# Starts one service of the test lab, times it until healthy, waits, and records its memory at rest.
# Usage: lab/medir-arranque.sh <profile> <service> [wait-seconds]   (from the session directory)
# Appends a row to salidas/arranque-darwin-arm64.tsv; logs go to salidas/logs/<service>.log
set -uo pipefail
cd "$(dirname "$0")/.."
profile="$1"; service="$2"; wait="${3:-60}"
C="docker compose -f lab/compose.yaml --profile $profile"
mkdir -p salidas/logs
start=$(date +%s)
$C up -d "$service" >/dev/null 2>&1
cid=$($C ps -q "$service")
status=""
for _ in $(seq 1 900); do
  state=$(docker inspect -f '{{.State.Status}}' "$cid" 2>/dev/null)
  status=$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}' "$cid" 2>/dev/null)
  [ "$status" = "healthy" ] && break
  [ "$status" = "running" ] && break   # no healthcheck: running is all we can know
  [ "$state" = "exited" ] && { status="exited"; break; }
  sleep 1
done
ready=$(( $(date +%s) - start ))
sleep "$wait"
mem=$(docker stats --no-stream --format '{{.MemUsage}}' "$cid" | cut -d/ -f1 | xargs)
image=$(docker inspect -f '{{.Config.Image}}' "$cid")
arch=$(docker image inspect -f '{{.Architecture}}' "$image")
docker logs "$cid" > "salidas/logs/$service.log" 2>&1
printf '%s\t%s\t%s\t%s\t%ss\t%s\t%s\n' "$(date +%F)" "$service" "$image" "$arch" "$ready" "$status" "$mem" \
  | tee -a salidas/arranque-darwin-arm64.tsv
