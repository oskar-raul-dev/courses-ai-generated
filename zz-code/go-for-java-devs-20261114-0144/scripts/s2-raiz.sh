#!/usr/bin/env bash
. /scripts/prep.sh
cd $M
p "go1.13 desde la raíz con ./labs/… (GO111MODULE=auto, sin go.mod raíz)"
go1.13 env GO111MODULE
go1.13 test -run '^$' -bench JoinStdlib -benchmem ./labs/text-toolkit 2>&1 | tail -3
go1.13 run ./labs/movement-parser 2>&1 | head -2
go1.13 test -run XXX ./labs/shapes 2>&1 | tail -2
go1.13 test -run XXX ./labs/json-codec 2>&1 | tail -2
cd services/opsreport && go1.13 list -f '{{.GoFiles}} {{.TestGoFiles}}' ./internal/config 2>&1 | head -2
