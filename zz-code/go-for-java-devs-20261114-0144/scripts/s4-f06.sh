#!/usr/bin/env bash
set -uo pipefail
. /scripts/prep.sh
cd $M/labs/race-counter
p "F06:L569 TestUnsafe -v (tres corridas)"
for i in 1 2 3; do go1.13 test -count=1 -run TestUnsafe -v . 2>&1 | grep "perdieron"; done
p "F06:L572 -race"
go1.13 test -count=1 -race -run TestUnsafe . 2>&1 | head -16
p "F06:L434 -cpu=1,4,8 (una pasada)"
go1.13 test -run '^$' -bench . -benchmem -cpu=1,4,8 . 2>&1 | grep Benchmark
p "F06 deadlocks: un main por caso"
mkdir -p /tmp/dl && cd /tmp/dl && rm -f go.mod && go1.13 mod init dl >/dev/null 2>&1 && cp $M/labs/deadlock-lab/deadlock.go . && sed -i 's/^package deadlock/package main/' deadlock.go
cat > main.go <<'GO'
package main

import (
	"os"
	"time"
)

func main() {
	switch os.Args[1] {
	case "1":
		UnbufferedNoReceiver()
	case "2":
		WaitGroupMismatch()
	case "3":
		a, b := &Account{id: 1}, &Account{id: 2}
		go TransferDeadlock(a, b, 1)
		go TransferDeadlock(b, a, 1)
		go func() { for { time.Sleep(time.Second) } }() // otra goroutine viva, como un servidor
		time.Sleep(time.Hour)
	case "4":
		r := &Registry{items: map[string]int{}}
		r.Add("x")
	}
}
GO
go1.13 build -o dl . || exit 1
for c in 1 2; do echo "-- caso $c"; ./dl $c 2>&1 | head -6; done
echo "-- caso 3 con SIGQUIT"; ./dl 3 > /tmp/dl3.log 2>&1 & pid=$!; sleep 1; kill -QUIT $pid; sleep 0.5; grep -A3 "semacquire" /tmp/dl3.log | head -12
echo "-- caso 4 (mutex no reentrante)"; timeout 3 ./dl 4 2>&1 | head -6; echo "exit $?"
p "F06:L833 fuga de goroutines"
cd $M/labs/leak-lab && go1.13 test -count=1 -v . 2>&1 | grep -E "goroutines|ok|FAIL"
p "SpawnN(100000): memoria"
mkdir -p /tmp/sp && cd /tmp/sp && rm -f go.mod && go1.13 mod init sp >/dev/null 2>&1 && cp $M/labs/race-counter/scale.go . && sed -i 's/^package counter/package main/' scale.go && cat > main.go <<'GO'
package main

import (
	"fmt"
	"runtime"
	"sync"
	"time"
)

func main() {
	var before, peak runtime.MemStats
	runtime.ReadMemStats(&before)
	var wg sync.WaitGroup
	wg.Add(1)
	go func() { defer wg.Done(); SpawnN(100000) }()
	time.Sleep(5 * time.Millisecond)
	runtime.ReadMemStats(&peak)
	n := runtime.NumGoroutine()
	wg.Wait()
	fmt.Printf("goroutines≈%d  StackInuse=%.0f MB  Sys=%.0f MB  (%.1f KB por goroutine)\n", n, float64(peak.StackInuse)/1e6, float64(peak.Sys)/1e6, float64(peak.StackInuse)/float64(n)/1024)
}
GO
go1.13 run .
p "servicios con -race"
for m in services/opsreport services/eventrelay; do (cd $M/$m && go1.13 test -race -count=1 ./... 2>&1 | grep -v "no test files"); done
