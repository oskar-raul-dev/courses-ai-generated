#!/usr/bin/env bash
. /scripts/prep.sh
cd $M && rm -f go.work && for d in labs/movement-parser; do (cd $d && go mod edit -go=1.25.1); done
cd labs/movement-parser && rm -rf testdata/fuzz && GOWORK=off go test -run '^$' -fuzz FuzzParseMovement -fuzztime 30s . 2>&1 | head -14
cd $M/labs/movement-parser && GOWORK=off go build -gcflags=-d=loopvar=2 . 2>&1 | head; echo "exit $?"
