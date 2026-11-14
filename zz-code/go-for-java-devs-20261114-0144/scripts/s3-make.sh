#!/usr/bin/env bash
. /scripts/prep.sh
cd $M && make cover; echo "cover exit $?"; for t in fmt vet lint test; do make $t > /tmp/$t.log 2>&1 || { echo "== $t falla"; grep -v "^0 issues\|^ok\|no test files" /tmp/$t.log | head -15; }; done; echo fin
