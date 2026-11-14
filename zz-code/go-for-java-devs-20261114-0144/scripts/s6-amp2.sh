#!/usr/bin/env bash
. /scripts/prep.sh
export GOWORK=off
cd $M/labs/backoff-lab && sed 's/Base: 500 \* time.Millisecond, Max: 30/Base: 2 * time.Second, Max: 30/' amplification_test.go > /tmp/a.go && cp amplification_test.go /tmp/a.bak && cp /tmp/a.go amplification_test.go && go test -count=1 -v . 2>&1 | grep "→"; cp /tmp/a.bak amplification_test.go
