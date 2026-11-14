#!/usr/bin/env bash
# S1 · F01 — los bloques de la fase, con go1.13, dentro del contenedor.
set -uo pipefail
export PATH=$PATH:/go/bin
p() { echo; echo "### $*"; }
M=/root/dev/meridian
cd $M

p "gofmt -l sobre lo que entrega la F01"
gofmt -l labs/movement-parser labs/text-toolkit labs/log-grep services/opsreport

p "F01:L911 opsreport: go mod init (el comando literal, con go moderno)"
cd $M/services/opsreport && go mod init github.com/meridian/opsreport && cat go.mod
p "variante: go1.13 mod init"
rm go.mod && go1.13 mod init github.com/meridian/opsreport && cat go.mod

p "labs: un módulo por lab, con go1.13 mod init"
for l in movement-parser text-toolkit log-grep; do (cd $M/labs/$l && rm -f go.mod && go1.13 mod init github.com/meridian/labs/$l >/dev/null 2>&1 && head -3 go.mod | tr '\n' ' '; echo); done

p "F01:L552 movement-parser (stderr y stdout juntos, en orden)"
cd $M/labs/movement-parser && go1.13 run . 2>&1
p "F01 prueba de fuego: monto de veinte dígitos"
cp testdata/movements.txt /tmp/mv.bak
echo "ST-014|2026-09-11T08:22:00Z|SALE|99999999999999999999|COP" >> testdata/movements.txt
go1.13 run . 2>&1 | head -3; cp /tmp/mv.bak testdata/movements.txt
p "go1.13 vet movement-parser"
go1.13 vet . ; echo "exit $?"

p "F01:L742 text-toolkit: benchmarks (una pasada; las cifras van a B-02)"
cd $M/labs/text-toolkit && go1.13 vet . && go1.13 test -run '^$' -bench . -benchmem -count=1 . 2>&1

p "F01:L813 TruncateBytesBroken con 12 y con 11"
mkdir -p /tmp/trunc && cd /tmp/trunc && rm -f go.mod && go1.13 mod init trunc >/dev/null 2>&1
cat > main.go <<'GO'
package main

import "fmt"

func TruncateBytesBroken(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n] + "…"
}

func main() {
	fmt.Println(TruncateBytesBroken("conciliación nocturna", 12))
	fmt.Println(TruncateBytesBroken("conciliación nocturna", 11))
	fmt.Printf("%q\n", TruncateBytesBroken("conciliación nocturna", 11))
}
GO
go1.13 run . | cat -v; go1.13 run .

p "F01:L874 log-grep con un relay.log de prueba"
cd $M/labs/log-grep && mkdir -p testdata && cat > testdata/relay.log <<'LOG'
2026-09-11T08:14:02Z INFO endpoint=EP-0042 status=200 latency_ms=81
2026-09-11T08:14:03Z WARN endpoint=EP-0107 status=503 latency_ms=2003
2026-09-11T08:14:03Z DEBUG retry scheduled for EP-0107
2026-09-11T08:14:09Z INFO endpoint=EP-0107 status=200 latency_ms=96
LOG
cat testdata/relay.log | go1.13 run .
go1.13 vet . ; echo "vet exit $?"

p "F01:L1150 opsreport"
cd $M/services/opsreport && go1.13 vet ./... && go1.13 run ./cmd/opsreport 2>&1
p "prueba de fuego: -4 → -6"
sed -i 's/now.AddDate(0, 0, -4)/now.AddDate(0, 0, -6)/' cmd/opsreport/main.go
go1.13 run ./cmd/opsreport 2>&1
sed -i 's/now.AddDate(0, 0, -6)/now.AddDate(0, 0, -4)/' cmd/opsreport/main.go

p "F01 conceptos: fragmentos con salida en comentario"
mkdir -p /tmp/conc && cd /tmp/conc && rm -f go.mod && go1.13 mod init conc >/dev/null 2>&1
cat > main.go <<'GO'
package main

import "fmt"

type Priority int
type Status string
type WorkItem struct {
	ID       string
	Priority Priority
}

func main() {
	var s string
	fmt.Println(len(s), s == "") // L87

	movements := []string{"SALE", "REFUND", "VOID", "DEPOSIT"}
	firstTwo := movements[:2]
	fmt.Println(firstTwo) // L194
	firstTwo = append(firstTwo, "PATCHED")
	fmt.Println(movements) // L199

	movements = []string{"SALE", "REFUND", "VOID", "DEPOSIT"}
	firstTwo = movements[:2:2]
	firstTwo = append(firstTwo, "PATCHED")
	fmt.Println(movements) // L228

	ñ := "ñandú"
	fmt.Println(len(ñ))         // L296
	fmt.Println(len([]rune(ñ))) // L297
	for i, r := range ñ {
		fmt.Printf("%d: %c (%d)\n", i, r, r) // L313
	}
	fmt.Println(ñ[0])        // L324
	fmt.Printf("%c\n", ñ[0]) // L325

	item := WorkItem{ID: "WI-1"}
	p := &item
	p.Priority = 7
	fmt.Println(item.Priority) // L344

	var counts map[string]int
	fmt.Println(counts == nil)  // L257
	fmt.Println(len(counts))    // L258
	fmt.Println(counts["SALE"]) // L259
	counts["SALE"] = 1          // L260
}
GO
go1.13 run . 2>&1 | head -20

p "F01:L108 cannot use p (go1.13 y go1.25.1)"
cat > main.go <<'GO'
package main

import "fmt"

type Priority int

func main() {
	var p Priority = 5
	var n int = p
	fmt.Println(n)
}
GO
go1.13 build . ; go build . 2>&1 | grep -v '^#'

p "F01 error común 5: comparar structs con slices"
cat > main.go <<'GO'
package main

import "fmt"

type Batch struct{ Refs []string }

func main() {
	a, b := Batch{}, Batch{}
	fmt.Println(a == b)
}
GO
go1.13 build . ; go build . 2>&1 | grep -v '^#'

p "F01:L399 CLI de la fase"
cd $M/labs/text-toolkit
go1.13 doc strings.Builder | head -5
go1.13 doc strconv.Atoi
go1.13 build -gcflags='-m' . 2>&1 | head -12
cd $M/labs/movement-parser && gofmt -d main.go | head -20

p "F01 rompe a propósito: FirstLineLeaky frente a FirstLineSafe (10 MB)"
cd $M/labs/text-toolkit && cat > retain_test.go <<'GO'
package toolkit

import (
	"io/ioutil"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"testing"
)

var keep [][]byte

func retained(t *testing.T, f func(string) ([]byte, error), path string) uint64 {
	keep = nil
	runtime.GC()
	var before, after runtime.MemStats
	runtime.ReadMemStats(&before)
	line, err := f(path)
	if err != nil {
		t.Fatal(err)
	}
	keep = append(keep, line)
	runtime.GC()
	runtime.ReadMemStats(&after)
	return after.HeapAlloc - before.HeapAlloc
}

func TestRetain(t *testing.T) {
	dir, _ := ioutil.TempDir("", "retain")
	defer os.RemoveAll(dir)
	path := filepath.Join(dir, "big.txt")
	body := "ST-014|2026-09-11T08:14:02Z|SALE|145900|COP\n" + strings.Repeat("x", 10<<20)
	ioutil.WriteFile(path, []byte(body), 0o644)
	t.Logf("FirstLineLeaky retiene %d bytes", retained(t, FirstLineLeaky, path))
	t.Logf("FirstLineSafe  retiene %d bytes", retained(t, FirstLineSafe, path))
}
GO
go1.13 test -run TestRetain -v . 2>&1 | grep -E "retiene|ok|FAIL"
rm retain_test.go
