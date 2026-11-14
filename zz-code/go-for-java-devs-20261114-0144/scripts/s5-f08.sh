#!/usr/bin/env bash
set -uo pipefail
. /scripts/prep.sh
cd $M
p "F08:L164 go get go@1.25.1 (en un lab del Bloque A)"
cd labs/movement-parser && cat go.mod && go get go@1.25.1 && cat go.mod
p "F08:L169 go work init + use + cat go.work"
cd $M && rm -f go.work go.work.sum && (cd services/opsreport && go mod edit -go=1.25.1) && (cd services/eventrelay && go mod edit -go=1.25.1) && (cd labs/text-toolkit && go mod edit -go=1.25.1)
go work init ./services/opsreport ./services/eventrelay && go work use ./labs/text-toolkit && cat go.work
go list -m -f '{{.Path}} {{.GoVersion}}' all
p "F08:L179 modernize@latest"
cd $M/labs/text-toolkit && GOFLAGS= timeout 300 go run golang.org/x/tools/gopls/internal/analysis/modernize/cmd/modernize@latest ./... 2>&1 | tail -6
p "F08:L203 -d=loopvar=2"
cd $M/labs/movement-parser && go build -gcflags=all=-d=loopvar=2 . 2>&1 | head -5; echo "exit $?"
p "F08:L187 fuzz 30 s"
cd $M/labs/movement-parser && go test -run '^$' -fuzz FuzzParseMovement -fuzztime 30s . 2>&1 | tail -12
ls testdata/fuzz/FuzzParseMovement 2>/dev/null | head -3
p "F08:L1346 slices.Chunk con go 1.21"
rm -rf /tmp/epoch-demo && mkdir /tmp/epoch-demo && cd /tmp/epoch-demo && go mod init epochdemo >/dev/null 2>&1
cat > main.go <<'GO'
// main.go
package main

import (
	"fmt"
	"slices"
)

func main() {
	for _, chunk := range slices.Chunk([]int{1, 2, 3, 4, 5}, 2) {
		fmt.Println(chunk)
	}
}
GO
go build . && ./epochdemo; go mod edit -go=1.21 && go build . ; echo "exit $?"
p "go test -shuffle=on (labs que tienen tests)"
cd $M/labs/text-toolkit && go test -shuffle=on . 2>&1 | tail -2
