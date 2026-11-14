#!/usr/bin/env bash
set -uo pipefail
. /scripts/prep.sh
cd $M && rm -f go.work go.work.sum
for d in services/opsreport services/eventrelay labs/text-toolkit labs/movement-parser; do (cd $d && go mod edit -go=1.25.1); done
go work init ./services/opsreport ./services/eventrelay && go work use ./labs/text-toolkit
p "un lab fuera del workspace"; (cd labs/log-grep && go build . 2>&1 | head -2)
p "go work use -r ."; go work use -r . && cat go.work | head -12; echo ...; (cd labs/log-grep && go build . && echo "log-grep compila")
p "F08 fuzz 30 s"
cd $M/labs/movement-parser && rm -rf testdata/fuzz && go test -run '^$' -fuzz FuzzParseMovement -fuzztime 30s . 2>&1 | tail -10
ls testdata/fuzz/FuzzParseMovement 2>/dev/null | head -3
p "F08 loopvar=2"; go build -gcflags=all=-d=loopvar=2 . 2>&1 | head -4; echo "exit $?"
p "slices.Chunk corregido"
rm -rf /tmp/epoch-demo && mkdir /tmp/epoch-demo && cd /tmp/epoch-demo && GOWORK=off go mod init epochdemo >/dev/null 2>&1
cat > main.go <<'GO'
// main.go
package main

import (
	"fmt"
	"slices"
)

func main() {
	for chunk := range slices.Chunk([]int{1, 2, 3, 4, 5}, 2) {
		fmt.Println(chunk)
	}
}
GO
export GOWORK=off; cat go.mod; go build . && ./epochdemo; go mod edit -go=1.21 && go build . ; echo "exit $?"; go vet . ; echo "vet exit $?"
