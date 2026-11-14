#!/usr/bin/env bash
# Al cierre de cada tanda: golden al día y make fmt vet lint test en verde (o lo que falla).
. /scripts/prep.sh
cd $M
[ -d labs/golden-report ] && (cd labs/golden-report && mkdir -p testdata && go1.13 test -run TestWriteCSV -update . >/dev/null 2>&1)
for t in fmt vet lint test; do make $t > /tmp/$t.log 2>&1 && echo "make $t: ok" || { echo "== make $t falla"; grep -v "^0 issues\|^ok\|no test files\|^?" /tmp/$t.log | head -25; }; done
