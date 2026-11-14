#!/usr/bin/env bash
set -uo pipefail
. /scripts/prep.sh
cd $M
p "gofmt + vet + test por módulo (F04)"
(cd labs/golden-report && mkdir -p testdata && go1.13 test -run TestWriteCSV -update . >/dev/null 2>&1; head -3 testdata/*.golden)
for m in labs/fake-clock labs/golden-report services/opsreport services/eventrelay; do echo "-- $m"; (cd $m && gofmt -l . ; go1.13 vet ./... && go1.13 test ./... 2>&1 | tail -6); done
p "F04:L189 go1.13 test -v -run TestEffectivePriority ./internal/workitem"
cd $M/services/opsreport && go1.13 test -count=1 -v -run TestEffectivePriority ./internal/workitem
p "F04:L466 go1.13 test -v ./internal/workitem (cabeza)"
go1.13 test -count=1 -v ./internal/workitem 2>&1 | head -5
p "F04:L511 go1.13 test -list"
go1.13 test -list '.*' ./internal/opsreport
p "F04:L1230 cobertura"
go1.13 test -race -covermode=atomic -coverprofile=cover.out ./... 2>&1 | tail -5
go1.13 tool cover -func=cover.out | tail -n 1
go1.13 test -race -covermode=atomic -coverprofile=cover.out ./internal/... >/dev/null && go1.13 tool cover -func=cover.out | tail -n 1
p "F04 -run sobre subtest"
go1.13 test -count=1 -run 'TestEffectivePriority/nunca_supera' -v ./internal/workitem 2>&1 | head -4
