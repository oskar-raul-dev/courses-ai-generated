#!/usr/bin/env bash
# Worst case for the RAM table: every profile up at once (M loaded in the three engines), after a scan.
set -uo pipefail
cd "$(dirname "$0")/.."
C="docker compose -f lab/compose.yaml --profile base --profile contraste --profile oracle --profile mongo --profile api --profile puente --profile sqlserver"
MONGO_IMAGE=mongo:8.0.20 $C up -d --wait postgres mysql oracle mongo api broker sqlserver >/dev/null 2>&1
lab/medir-ram-cargado.sh >/dev/null
sleep 30
docker stats --no-stream --format '{{.Name}}\t{{.MemUsage}}' $($C ps -q) | sed "s#^#$(date +%F)\ttodo arriba\t#" | tee -a salidas/ram-cargado-darwin-arm64.tsv
