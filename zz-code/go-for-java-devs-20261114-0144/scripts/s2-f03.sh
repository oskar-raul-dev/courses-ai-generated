#!/usr/bin/env bash
# S2 · F03 con go1.13.
set -uo pipefail
. /scripts/prep.sh
p() { echo; echo "### $*"; }
M=/root/dev/meridian; cd $M
for l in error-chain config-loader json-codec; do (cd labs/$l && [ -f go.mod ] || go1.13 mod init github.com/meridian/labs/$l >/dev/null 2>&1); done
p "gofmt -l"; gofmt -l labs/error-chain labs/config-loader labs/json-codec services/eventrelay services/opsreport/internal/opsreport services/opsreport/internal/workitem/errors.go
p "vet + build"
for m in labs/error-chain labs/config-loader labs/json-codec services/opsreport services/eventrelay; do echo "-- $m"; (cd $m && go1.13 vet ./... && go1.13 build ./... && echo ok); done
p "F03:L405 Inspect"
cd $M/labs/error-chain && cat > zz_test.go <<'GO'
package chain

import (
	"errors"
	"fmt"
	"testing"
)

type storeError struct {
	sentinel error
	cause    error
}

func (e *storeError) Error() string        { return fmt.Sprintf("%v: %v", e.sentinel, e.cause) }
func (e *storeError) Is(target error) bool { return target == e.sentinel }
func (e *storeError) Unwrap() error        { return e.cause }

func TestZZ(t *testing.T) {
	Inspect()
	err := handleRequest("req-8821", "WI-0007")
	fmt.Println("L430 errors.Is:", errors.Is(err, ErrRowNotFound))
	var de *DriverError
	errors.As(err, &de)
	err2 := fmt.Errorf("petición: %w", &storeError{sentinel: ErrRowNotFound, cause: de})
	var de2 *DriverError
	fmt.Println("L459 errors.Is:", errors.Is(err2, ErrRowNotFound), "errors.As:", errors.As(err2, &de2))
}
GO
go1.13 test -run TestZZ -v . 2>&1 | grep -v "^=== RUN\|^--- PASS\|^PASS\|^ok"; rm zz_test.go
p "F03:L632 prueba de fuego: tres campos inválidos"
cd $M/services/opsreport && mkdir -p cmd/zz && cat > cmd/zz/main.go <<'GO'
package main

import (
	"errors"
	"fmt"

	"github.com/meridian/opsreport/internal/workitem"
)

func main() {
	err := workitem.WorkItem{Priority: 12, Kind: "nope"}.Validate()
	fmt.Println(err)
	var verr *workitem.ValidationError
	if errors.As(err, &verr) {
		for _, f := range verr.Fields {
			fmt.Printf("  %+v\n", f)
		}
	}
}
GO
go1.13 run ./cmd/zz 2>&1; rm -r cmd/zz
p "F03 defer: ~0s, LIFO"
mkdir -p /tmp/d && cd /tmp/d && rm -f go.mod && go1.13 mod init d >/dev/null 2>&1 && cat > main.go <<'GO'
package main

import (
	"fmt"
	"time"
)

func demo() {
	start := time.Now()
	defer fmt.Println("tardó", time.Since(start))
	time.Sleep(200 * time.Millisecond)
}

func demo2() {
	start := time.Now()
	defer func() { fmt.Println("tardó", time.Since(start).Round(time.Millisecond)) }()
	time.Sleep(200 * time.Millisecond)
}

type ValidationError struct{ Fields []string }

func (e *ValidationError) Error() string { return fmt.Sprint(len(e.Fields)) }

func main() {
	demo()
	demo2()
	for i := 1; i <= 3; i++ {
		defer fmt.Println(i)
	}
	var p *ValidationError = nil
	var err error = p
	fmt.Println(p == nil)
	fmt.Println(err == nil)
	fmt.Printf("%T %v\n", err, err)
	var data map[string]interface{}
	_ = jsonUnmarshal(&data)
	n := int(data["count"].(float64))
	fmt.Println("count", n)
	func() {
		defer func() { fmt.Println("recover:", recover()) }()
		_ = data["count"].(int)
	}()
}
GO
cat > j.go <<'GO'
package main

import "encoding/json"

func jsonUnmarshal(v interface{}) error { return json.Unmarshal([]byte(`{"count": 3}`), v) }
GO
go1.13 run . 2>&1
p "F03:L786 ciclo de imports"
rm -rf /tmp/cyc && cp -r $M/services/opsreport /tmp/cyc && cd /tmp/cyc
sed -i 's#^import (#import (\n\t_ "github.com/meridian/opsreport/internal/opsreport"#' internal/memstore/store.go
grep -q '"github.com/meridian/opsreport/internal/memstore"' internal/opsreport/*.go || sed -i 's#^import (#import (\n\t_ "github.com/meridian/opsreport/internal/memstore"#' internal/opsreport/service.go
go1.13 build ./... 2>&1 | head -6
go build ./... 2>&1 | head -6
p "F03:L307 golangci-lint errcheck en opsreport"
cd $M/services/opsreport && golangci-lint run --enable-only errcheck ./... ; echo "exit $?"
go1.13 list -f '{{.GoFiles}} {{.TestGoFiles}}' ./internal/... 
p "B-06 una pasada"
cd $M/labs/json-codec && go1.13 test -run '^$' -bench . -benchmem -count=1 . 2>&1 | tail -6
p "F03 json: omitempty, no exportados, time"
mkdir -p /tmp/js && cd /tmp/js && rm -f go.mod && go1.13 mod init js >/dev/null 2>&1 && cat > main.go <<'GO'
package main

import (
	"encoding/json"
	"fmt"
	"time"
)

type Filter struct {
	Status  string `json:"status,omitempty"`
	MinPrio int    `json:"min_priority,omitempty"`
	Active  bool   `json:"active,omitempty"`
}

type broken struct {
	id   string
	Name string
}

func main() {
	b, _ := json.Marshal(Filter{Status: "queued", MinPrio: 0, Active: false})
	fmt.Println(string(b))
	b, _ = json.Marshal(broken{id: "x", Name: "y"})
	fmt.Println(string(b))
	t := time.Date(2026, 9, 11, 8, 0, 0, 0, time.FixedZone("COT", -5*3600))
	b, _ = json.Marshal(t)
	fmt.Println(string(b))
}
GO
go1.13 run .
p "F04 adelantado: errors.Is servicio + almacén"
cd $M/services/opsreport && mkdir -p cmd/zz && cat > cmd/zz/main.go <<'GO'
package main

import (
	"errors"
	"fmt"
	"time"

	"github.com/meridian/opsreport/internal/memstore"
	"github.com/meridian/opsreport/internal/opsreport"
)

type clk struct{}

func (clk) Now() time.Time { return time.Now() }

type ids struct{}

func (ids) NewID() string { return "WI-1" }

func main() {
	svc := opsreport.New(memstore.New(), clk{}, ids{})
	_, err := svc.Start("WI-NO-EXISTE")
	fmt.Println(err)
	fmt.Println(errors.Is(err, opsreport.ErrNotFound), errors.Is(err, memstore.ErrNotFound))
}
GO
go1.13 run ./cmd/zz 2>&1; rm -r cmd/zz
