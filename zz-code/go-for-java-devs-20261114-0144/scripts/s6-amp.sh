#!/usr/bin/env bash
. /scripts/prep.sh
export GOWORK=off
cd $M/labs/backoff-lab && go mod edit -go=1.25.1 && go vet . 2>&1 | head -5; go test -count=1 -v -run . . 2>&1 | grep -v "^=== RUN" | head -20
