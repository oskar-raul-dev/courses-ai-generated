#!/usr/bin/env bash
set -uo pipefail
. /scripts/prep.sh
cd $M
p "gofmt + vet + test por módulo (F05)"
for m in labs/tiny-router labs/middleware-chain labs/httptest-lab services/opsreport services/eventrelay; do echo "-- $m"; (cd $m && gofmt -l . ; go1.13 vet ./... && go1.13 test -count=1 ./... 2>&1 | tail -6); done
