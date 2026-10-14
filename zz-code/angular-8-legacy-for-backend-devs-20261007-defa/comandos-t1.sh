#!/usr/bin/env bash
# T1 probes. Run from this directory: bash comandos-t1.sh <step>
set -euo pipefail
cd "$(dirname "$0")"
: "${CURSO:?set CURSO to the course directory}"; export CURSO
NODE=node:14.21.3
run() { docker run --rm --label curso=angular8 -v "$PWD/sondas/angular8:/w" -w /w "$@"; }
case "${1:-}" in
  install) run $NODE npm install --no-audit --no-fund --loglevel=error ;;
  datepipe)
    for tz in UTC Asia/Tokyo America/Toronto; do run -e TZ=$tz $NODE node datepipe-iana.js; done ;;
  fechas)
    # CURSO must be the ORIGINAL course (before the edit), e.g. git archive HEAD exported to
    # salidas/head-original/…: the table maps old literals, and the edited course has none left.
    python3 fechas/inventario.py
    for tz in America/Toronto UTC Asia/Tokyo; do
      docker run --rm --label curso=angular8 -e TZ=$tz -v "$PWD/fechas:/w" -w /w $NODE node tabla.js > salidas/t1-fechas-$(echo $tz | tr / -).txt
    done
    diff <(tail -n +2 salidas/t1-fechas-America-Toronto.txt) <(tail -n +2 salidas/t1-fechas-UTC.txt) && \
    diff <(tail -n +2 salidas/t1-fechas-America-Toronto.txt) <(tail -n +2 salidas/t1-fechas-Asia-Tokyo.txt) && echo "same table in the three host zones" ;;
  *) echo "usage: $0 install|datepipe|fechas"; exit 1 ;;
esac
