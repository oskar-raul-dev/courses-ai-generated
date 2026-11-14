#!/usr/bin/env bash
. /scripts/prep.sh
export GOWORK=off
go install golang.org/x/perf/cmd/benchstat@v0.0.0-20260112171951-5abaabe9f1bd >/dev/null 2>&1
nproc; cat /proc/meminfo | head -1
cd $M
p "B-01"; (cd labs/crossbuild && go clean -cache && ( time ./build-all.sh ) 2>&1 | grep -E "real|M "; for t in darwin/arm64 linux/amd64; do o=${t%/*}; a=${t#*/}; GOOS=$o GOARCH=$a CGO_ENABLED=0 go build -o /tmp/full-$o-$a . ; ls -l /tmp/full-$o-$a | awk '{print "sin -s -w '$t':", $5}'; done)
for b in "B-02 labs/text-toolkit" "B-05 labs/shapes" "B-06 labs/json-codec"; do set -- $b; p "$1 (go1.13, -count=10)"; (cd $2 && go1.13 test -run '^$' -bench . -benchmem -count=10 . > /tmp/$1.txt 2>&1; benchstat /tmp/$1.txt | sed -n '1,40p'); done
