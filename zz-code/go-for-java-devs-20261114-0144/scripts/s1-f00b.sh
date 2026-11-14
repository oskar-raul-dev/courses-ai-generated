#!/usr/bin/env bash
set -uo pipefail
export PATH=$PATH:/go/bin
p() { echo; echo "### $*"; }
p "dl: fuente del envoltorio (darwin/arm64 < 1.16)"
f=$(ls -d /go/pkg/mod/golang.org/dl@*/internal/version/version.go | tail -1); echo $f
grep -n -i -B2 -A6 "rosetta\|arm64" $f | head -40
p "golangci-lint: versión de go que exige cada v2"
for v in v2.15.0 v2.12.0 v2.10.0 v2.8.0 v2.6.2 v2.5.0 v2.4.0; do
  echo -n "$v: "; curl -s https://proxy.golang.org/github.com/golangci/golangci-lint/v2/@v/$v.mod | grep -E "^go |^toolchain" | tr '\n' ' '; echo
done
curl -s https://proxy.golang.org/github.com/golangci/golangci-lint/v2/@v/list | sort -V | tail -25 | tr '\n' ' '; echo
p "golangci-lint @latest con GOTOOLCHAIN=auto (lo que le pasa al lector)"
GOTOOLCHAIN=auto go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest 2>&1 | tail -3; ls -la /go/bin
p "API posterior sin genéricos: strings.Cut (1.18) con go.mod en 1.13"
rm -rf /tmp/cut && mkdir /tmp/cut && cd /tmp/cut && go mod init cut >/dev/null 2>&1 && go mod edit -go=1.13
cat > main.go <<'GO'
package main

import (
	"fmt"
	"strings"
)

func main() {
	before, after, _ := strings.Cut("ST-014|SALE", "|")
	fmt.Println(before, after)
}
GO
go build . ; echo "go build exit $?"
go vet . ; echo "go vet exit $?"
go1.13 build . ; echo "go1.13 build exit $?"
