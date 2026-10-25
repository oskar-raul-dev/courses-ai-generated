#!/bin/sh
# F24 §5.5–§8: la saga con el generador de caos entre inventory y replenish.
cd "$(dirname "$0")"; Z=$(pwd); cd mi-lab/src/lab
H='Host: api.localhost'; API=http://127.0.0.1:8080
loan() { curl -s -X POST $API/inventory/loans -H "$H" -H 'Content-Type: application/json' \
  -d "{\"sku\":\"$1\",\"originStore\":\"$2\",\"destinationStore\":\"$3\",\"quantity\":${4:-1}}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])'; }
show() { python3 "$Z/loan-show.py" "$1"; }
status() { curl -s -H "$H" $API/inventory/loans/$1 | python3 -c 'import json,sys; print(json.load(sys.stdin)["status"])'; }
waitfinal() { for i in $(seq 1 ${2:-90}); do s=$(status $1); case $s in COMPLETED|COMPENSATED|BACKORDERED) echo "$s a los ${i} s"; return;; esac; sleep 1; done; echo "sin terminar: $(status $1)"; }
psqli() { kubectl -n data exec postgres-0 -- psql -U postgres -d inventory -tAc "$1"; }
psqlr() { kubectl -n data exec postgres-0 -- psql -U postgres -d replenish -tAc "$1"; }
set_() { task chaos:set -- "$@" > /dev/null 2>&1; }
count() { curl -s -o /dev/null -H "$H" -H 'Content-Type: application/json' -d "{\"type\":\"COUNT\",\"quantity\":$3,\"reference\":\"f24\"}" $API/inventory/stock/$1/$2/movements; }

echo "(el caos ya está entre inventory y replenish)"
kubectl -n apps get deploy inventory -o jsonpath='{.spec.template.spec.containers[0].env[?(@.name=="REPLENISH_URL")].value}{"\n"}'
count DRO-003 SKU-0003 500

echo "## 5.6 · la compensación que también falla: 8 préstamos a DRO-024 (sin precio), replenish al 50 %"
set_ clear; set_ errorPercent=50
IDS=""; for i in 1 2 3 4 5 6 7 8; do IDS="$IDS $(loan SKU-0003 DRO-003 DRO-024)"; done
T0=$(date +%s); prev=""
while [ $(( $(date +%s)-T0 )) -lt 75 ]; do
  for L in $IDS; do st=$(show $L); key="$L=$st"; case "$prev" in *"$key"*) ;; *) echo "+$(( $(date +%s)-T0 ))s $st"; prev="$prev|$key";; esac; done; sleep 1
done

echo "## 5.7 · el orquestador que muere: replenish demorado 1,5 s, el pod borrado sin plazo"
set_ clear; set_ latencyMs=1500 latencyPercent=100
P=$(kubectl -n apps get pods -l app.kubernetes.io/name=inventory,app.kubernetes.io/component=backend --field-selector=status.phase=Running -o name | head -1)
L=$(loan SKU-0003 DRO-003 DRO-007); echo "$(date +%T) $L pedido"; sleep 0.8
kubectl -n apps delete $P --grace-period=0 --force > /dev/null 2>&1; echo "$(date +%T) $P borrado sin plazo"
T0=$(date +%s); last=""
while [ $(( $(date +%s)-T0 )) -lt 90 ]; do st=$(show $L 2>/dev/null); [ -n "$st" ] && [ "$st" != "$last" ] && { echo "+$(( $(date +%s)-T0 ))s $st"; last="$st"; }; case "$st" in *COMPENSATED*|*COMPLETED*) break;; esac; sleep 1; done
curl -s -H "$H" $API/inventory/loans/$L | python3 -c 'import json,sys; d=json.load(sys.stdin); print("failure:", d["failure"], "· orden:", d["replenishmentOrderId"])'
set_ clear
