#!/usr/bin/env bash
set -uo pipefail
. /scripts/prep.sh
cd $M/services/opsreport
go1.13 build -o /tmp/opsreport ./cmd/opsreport && (/tmp/opsreport > /tmp/ops.log 2>&1 &) ; sleep 1
p "F05:L237 /health"; curl -si localhost:8080/health
p "F05:L240 POST"; curl -si -X POST localhost:8080/work-items -H 'Content-Type: application/json' -d '{"external_reference":"SAP-2026-000123","kind":"import","priority":3}'
p "F05:L245 jq"; curl -s localhost:8080/work-items | jq '.items[] | {id, status, priority}'
p "F05:L249 -w"; curl -s -o /dev/null -w 'status=%{http_code} tiempo=%{time_total}s\n' localhost:8080/work-items
p "F05:L255 /slow en 8080"; curl -s --max-time 2 -o /dev/null -w '%{http_code}\n' localhost:8080/slow
p "F05:L258 -v"; curl -sv localhost:8080/work-items/WI-0001 2>&1 | grep -E "^< |^\{" 
p "F05 405 y 404"; curl -si -X PUT localhost:8080/work-items | head -4; curl -si localhost:8080/work-items/WI-1/extra | head -1; curl -si localhost:8080/work-items/ | head -1
p "F05 400 json"; curl -s -X POST localhost:8080/work-items -d '{"prioriti":3}'; echo; curl -s -X POST localhost:8080/work-items -d '{"external_reference":"","kind":"x","priority":0}'; echo
p "F05 cuerpo > 1 MiB"; head -c 1100000 /dev/zero | tr '\0' 'a' | sed 's/^/{"description":"/; s/$/"}/' | curl -s -X POST localhost:8080/work-items --data-binary @- ; echo
p "log del servidor"; head -8 /tmp/ops.log
cd $M/services/eventrelay && go1.13 build -o /tmp/fc ./cmd/fakeconsumer && (/tmp/fc -addr :9100 -slow-delay 8s > /tmp/fc.log 2>&1 &); sleep 1
p "F05:L1155 fakeconsumer"; curl -si -X POST localhost:9100/ok -d '{"type":"order.created"}'; echo; curl -si localhost:9100/fail/503; echo; curl -si localhost:9100/fail/429; echo; curl -s localhost:9100/stats | jq
p "F05:L1123 /slow con --max-time 2"; time curl -s --max-time 2 localhost:9100/slow; echo "curl exit $?"
p "F05 slowloris (con y sin ReadHeaderTimeout)"
cd $M/labs/httptest-lab && go1.13 test -count=1 -v . 2>&1 | grep -E "goroutines|ok|FAIL"
sed 's/\/\/ ReadHeaderTimeout: 0 .*/ReadHeaderTimeout: 2 * time.Second,/' slowloris_test.go > /tmp/sl.go && cp slowloris_test.go /tmp/sl.bak && cp /tmp/sl.go slowloris_test.go && go1.13 test -count=1 -v . 2>&1 | grep -E "goroutines|ok|FAIL"; cp /tmp/sl.bak slowloris_test.go
