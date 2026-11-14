#!/usr/bin/env bash
# Lista todos los errores de compilación (incluidos tests) de cada módulo. Uso: compila.sh go1.13 dir…
. /scripts/prep.sh
T=$1; shift
for m in "$@"; do echo "-- $m"; (cd $M/$m && $T test -count=1 -run XXX -gcflags=-e ./... 2>&1 | grep -v "^#\|^ok\|no test files\|^FAIL\|^?" | sort -u | head -40); done
