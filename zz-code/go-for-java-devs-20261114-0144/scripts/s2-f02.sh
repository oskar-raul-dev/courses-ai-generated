#!/usr/bin/env bash
# S2 · F02 con go1.13.
set -uo pipefail
export PATH=$PATH:/go/bin
p() { echo; echo "### $*"; }
M=/root/dev/meridian; cd $M
p "módulos nuevos con go1.13 mod init"
for l in shapes store-registry notifier; do (cd labs/$l && [ -f go.mod ] && continue; rm -f go.mod && go1.13 mod init github.com/meridian/labs/$l >/dev/null 2>&1); done
(cd services/eventrelay && [ -f go.mod ] || go1.13 mod init github.com/meridian/eventrelay >/dev/null 2>&1)
p "gofmt -l"
gofmt -l labs/shapes labs/store-registry labs/notifier services/opsreport services/eventrelay
p "go1.13 vet + build por módulo"
for m in labs/shapes labs/store-registry labs/notifier services/opsreport services/eventrelay; do echo "-- $m"; (cd $m && go1.13 vet ./... && go1.13 build ./... && echo ok); done
p "F02:L431 go1.13 list imports (opsreport)"
cd $M/services/opsreport
go1.13 list -f '{{.ImportPath}} imports {{.Imports}}' ./internal/...
go1.13 list -deps ./internal/opsreport | grep meridian
go1.13 doc ./internal/opsreport | head -15
go1.13 doc ./internal/opsreport Service | head -8
go1.13 doc ./internal/workitem WorkItem.CanTransitionTo
p "opsreport run"
go1.13 run ./cmd/opsreport 2>&1 | head -20
p "eventrelay tests/build"
cd $M/services/eventrelay && go1.13 test ./... 2>&1 | tail -5
p "F02:L494 Describe (javastyle) y L1606 Demo (shapes)"
cd $M/labs/shapes/javastyle && cat > zz_test.go <<'GO'
package javastyle

import (
	"fmt"
	"testing"
)

func TestZZ(t *testing.T) {
	r := &Rectangle{AbstractShape: AbstractShape{name: "rect"}, Width: 3, Height: 4}
	fmt.Println(r.Area())
	fmt.Println(r.Describe())
}
GO
go1.13 test -run TestZZ -v . 2>&1 | head -4; rm zz_test.go
cd $M/labs/shapes && cat > zz_test.go <<'GO'
package shapes

import "testing"

func TestZZ(t *testing.T) { Demo() }
GO
go1.13 test -run TestZZ -v . 2>&1 | head -4; rm zz_test.go
p "B-05 una pasada"
go1.13 test -run '^$' -bench . -benchmem -count=1 . 2>&1 | tail -8
p "L115 receptor por puntero (go1.13)"
mkdir -p /tmp/ptr && cd /tmp/ptr && rm -f go.mod && go1.13 mod init ptr >/dev/null 2>&1 && cat > main.go <<'GO'
package main

type Notifier interface {
	Notify(message string) error
}

type EmailNotifier struct{ sent int }

func (n *EmailNotifier) Notify(message string) error {
	n.sent++
	return nil
}

func main() {
	var n Notifier
	n = &EmailNotifier{}
	n = EmailNotifier{}
	_ = n
}
GO
go1.13 build . 2>&1
