#!/usr/bin/env bash
. /scripts/prep.sh
bash /scripts/compila.sh go1.13 labs/cancellable-worker labs/timeout-client labs/graceful-server labs/leak-detector
for m in labs/cancellable-worker labs/timeout-client labs/graceful-server labs/leak-detector; do (cd $M/$m && go1.13 test -race -count=1 ./... 2>&1 | tail -3); done
p "F07 graceful-server: SIGTERM con una petición en curso"
cd $M/labs/graceful-server && go1.13 build -o /tmp/gs . && (/tmp/gs > /tmp/gs.log 2>&1 &) ; sleep 0.5
(curl -s -w 'curl: %{http_code} en %{time_total}s\n' localhost:8080/slow > /tmp/curl.out &) ; sleep 0.5
pkill -TERM -f /tmp/gs; sleep 3.5; cat /tmp/curl.out; cat /tmp/gs.log
