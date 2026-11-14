#!/usr/bin/env bash
. /scripts/prep.sh
export GOWORK=off
rm -rf /tmp/lv && mkdir /tmp/lv && cd /tmp/lv && go mod init lv >/dev/null 2>&1
cat > loopvar.go <<'GO'
// loopvar.go
package main

import "fmt"

func main() {
	var fns []func()
	for _, v := range []int{1, 2, 3} {
		fns = append(fns, func() { fmt.Print(v, " ") })
	}
	for _, f := range fns {
		f()
	}
}
GO
go mod edit -go=1.21 && go run . ; echo
go mod edit -go=1.22 && go run . ; echo
