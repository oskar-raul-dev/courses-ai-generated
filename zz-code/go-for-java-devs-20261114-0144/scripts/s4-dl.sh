#!/usr/bin/env bash
. /scripts/prep.sh
mkdir -p $M/labs/deadlock-lab/cmd/demo && cd $M/labs/deadlock-lab
cp $M/labs/deadlock-lab/deadlock.go /tmp/ 
mkdir -p /tmp/dlm && cd /tmp/dlm && rm -f go.mod *.go && go1.13 mod init dl >/dev/null 2>&1 && sed 's/^package deadlock/package main/' /tmp/deadlock.go > deadlock.go
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
	case "3":
		a, b := &Account{id: 1}, &Account{id: 2}
		go TransferDeadlock(a, b, 1)
		go TransferDeadlock(b, a, 1)
		time.Sleep(time.Hour)
	}
}
GO
go1.13 build -o dl . && ./dl 1 2>&1 | head -8
./dl 3 > /tmp/dl3.log 2>&1 & pid=$!; sleep 1; kill -QUIT $pid; sleep 0.5; grep -B1 -A8 "^goroutine [0-9]* \[semacquire\]" /tmp/dl3.log | head -24
rm -r $M/labs/deadlock-lab/cmd
