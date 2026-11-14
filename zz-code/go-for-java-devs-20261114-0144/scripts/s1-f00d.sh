#!/usr/bin/env bash
# F00 §7 Rompe a propósito, versión corregida: strings.Cut con go.mod en 1.13.
set -uo pipefail
export PATH=$PATH:/go/bin
p() { echo; echo "### $*"; }
rm -rf /tmp/epoch-test && mkdir -p /tmp/epoch-test && cd /tmp/epoch-test
go mod init epochtest
go mod edit -go=1.13
cat go.mod
cat > main.go <<'GO'
// main.go — usa strings.Cut, que llegó en Go 1.18
package main

import (
	"fmt"
	"strings"
)

func main() {
	store, kind, _ := strings.Cut("ST-014|SALE", "|")
	fmt.Println(store, kind)
}
GO
p "go build . && ./epochtest"
go build . && ./epochtest; echo "exit $?"
p "go vet ."
go vet . ; echo "exit $?"
p "go1.13 build ."
go1.13 build . ; echo "exit $?"
