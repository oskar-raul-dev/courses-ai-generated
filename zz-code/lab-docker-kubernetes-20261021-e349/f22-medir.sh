#!/bin/sh
# F22: las mediciones de las secciones 5.3 a 8 con inventory:g9 y el generador entre inventory y catalog.
cd "$(dirname "$0")"; Z=$(pwd); cd mi-lab/src/lab
set_() { task chaos:set -- "$@" > /dev/null 2>&1; }
received() { task chaos:set -- show 2>/dev/null | python3 -c 'import json,sys; t=sys.stdin.read(); d=json.loads(t[t.index("{"):]); print(d["counts"]["received"])'; }
ventas() { k6 run -q "$Z/k6/ventas.js" 2>&1 | awk '/http_req_duration/ && !/expected/ {d=$0} /checks_failed/ {f=$0} END {sub(/^ +/,"",d); sub(/^ +/,"",f); print d " · " f}'; }
resilience() { kubectl -n apps set env deploy/inventory "$@" > /dev/null; kubectl -n apps rollout status deploy/inventory > /dev/null; sleep 8; }
por_venta() { r=$(received); echo "catalog recibió $r peticiones"; }

echo "## 5.3 · ingenuo: 4 intentos, sin espera, sin circuito · 50 % de errores"
resilience LAB_RESILIENCE_MAX_ATTEMPTS=4 LAB_RESILIENCE_BACKOFF_MS=0 LAB_RESILIENCE_CIRCUIT_ENABLED=false
set_ errorPercent=50; ventas; por_venta
echo "## 5.3 · sin reintentos (1 intento), sin circuito"
resilience LAB_RESILIENCE_MAX_ATTEMPTS=1
set_ errorPercent=50; ventas; por_venta
echo "## 8 · G9 tal cual · 50 % de errores"
resilience LAB_RESILIENCE_MAX_ATTEMPTS- LAB_RESILIENCE_BACKOFF_MS- LAB_RESILIENCE_CIRCUIT_ENABLED-
set_ errorPercent=50; ventas; por_venta
echo "## 8 · G9 · perfil sogamoso-con-lluvia"
sleep 12; task chaos:set -- perfil sogamoso-con-lluvia > /dev/null 2>&1; ventas; por_venta
echo "## 5.4 · G9 · 100 % de errores, la cuenta cada dos segundos"
sleep 12; set_ errorPercent=100
( k6 run -q "$Z/k6/ventas.js" > /tmp/f22-circuito.txt 2>&1 ) & K=$!
prev=0; t0=$(date +%s); while kill -0 $K 2>/dev/null; do r=$(received); st=$(curl -s -H 'Host: api.localhost' http://127.0.0.1:8080/inventory/metrics | grep 'resilience4j_circuitbreaker_state{.*name="catalog".*state="\(open\|closed\|half_open\)"} 1' | grep -o 'state="[a-z_]*"'); echo "$(( $(date +%s)-t0 )) s  catalog recibió $((r-prev))  $st"; prev=$r; sleep 2; done
awk '/http_req_duration/ && !/expected/ {d=$0} /checks_failed/ {f=$0} END {print d " · " f}' /tmp/f22-circuito.txt
echo "## 5.5 · la cascada con G9: 5 s de latencia, 50 ventas/s y 10 lecturas/s"
sleep 12; set_ clear; sleep 3; set_ latencyMs=5000 latencyPercent=100
k6 run -q -e SALES=50 -e READS=10 -e DURATION=60s bench/f22/cascada.js 2>&1 | grep -E "\{ scenario:(ventas|existencias) \}"
por_venta
echo "## 5.6 · malformada al 100 %"
sleep 12; set_ malformedPercent=100
curl -s -o /tmp/f22-v -w "%{http_code} en %{time_total}s · " -H 'Host: api.localhost' -H 'Content-Type: application/json' -d '{"store":"DRO-007","sku":"SKU-0001","quantity":1}' http://127.0.0.1:8080/inventory/sales; cat /tmp/f22-v; echo; task chaos:set -- show 2>/dev/null | tr -d ' \n' | grep -o '"malformed":[0-9]*,"passed":[0-9]*,"received":[0-9]*'; echo
echo "## 5.6 · colgado al 100 %"
set_ hangPercent=100
curl -s -o /tmp/f22-v -w "%{http_code} en %{time_total}s · " -H 'Host: api.localhost' -H 'Content-Type: application/json' -d '{"store":"DRO-007","sku":"SKU-0001","quantity":1}' http://127.0.0.1:8080/inventory/sales; cat /tmp/f22-v; echo; task chaos:set -- show 2>/dev/null | tr -d ' \n' | grep -o '"hung":[0-9]*'; echo
set_ clear
