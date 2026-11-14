#!/usr/bin/env bash
. /scripts/prep.sh
export GOWORK=off
for m in labs/benchstat-lab labs/escape-lab labs/pool-vs-alloc; do (cd $M/$m && go mod edit -go=1.25.1 && go mod tidy >/dev/null 2>&1); done
bash /scripts/compila.sh go labs/benchstat-lab labs/escape-lab labs/pool-vs-alloc
p "escape-lab -gcflags=-m"; (cd $M/labs/escape-lab && go build -gcflags='-m' . 2>&1 | grep -E "escape|moved to heap|does not escape" | head -20)
p "pool-vs-alloc"; (cd $M/labs/pool-vs-alloc && go test -run '^$' -bench . -benchmem -count=5 . 2>&1 | grep Benchmark)
