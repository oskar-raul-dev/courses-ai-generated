#!/usr/bin/env bash
. /scripts/prep.sh
export GOWORK=off
cd /spring/contract && CLEARINGHOUSE_URL=${URL:-http://gfjd-chj:8081} go test -count=1 -v . 2>&1 | grep -E "^\s*--- (PASS|FAIL)|contract_test.go|^(ok|FAIL)" | head -50
