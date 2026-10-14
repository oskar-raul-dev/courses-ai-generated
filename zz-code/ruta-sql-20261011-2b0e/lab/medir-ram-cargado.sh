#!/usr/bin/env bash
# Memory of the three engines with profile M loaded, after one full scan of ResultadoItem in each.
# Usage: lab/medir-ram-cargado.sh   Output: salidas/ram-cargado-darwin-arm64.tsv
set -uo pipefail
cd "$(dirname "$0")/.."
C="docker compose -f lab/compose.yaml --profile base --profile contraste --profile oracle"
$C exec -T postgres psql -U postgres -d alameda -Atc 'SELECT count(*), count(DISTINCT "CodAnalito") FROM legacy."ResultadoItem"' >/dev/null
$C exec -T mysql mysql -uroot -plab -N -e 'SELECT count(*), count(DISTINCT CodAnalito) FROM legacy.ResultadoItem' 2>/dev/null >/dev/null
echo 'SELECT COUNT(*), COUNT(DISTINCT "CodAnalito") FROM "ResultadoItem";' | $C exec -T oracle sqlplus -s alameda/lab@//localhost/FREEPDB1 >/dev/null
sleep 30
docker stats --no-stream --format '{{.Name}}\t{{.MemUsage}}' $($C ps -q) \
  | sed "s#^#$(date +%F)\tM cargado, tras un recorrido\t#" | tee -a salidas/ram-cargado-darwin-arm64.tsv
docker info --format 'VM: {{.MemTotal}} bytes, {{.NCPU}} CPU, kernel {{.KernelVersion}}' | tee -a salidas/ram-cargado-darwin-arm64.tsv
