#!/bin/sh
# F24 §7 y §8: Sogamoso con lluvia en replenish con 20 préstamos; el timeout que deja huérfanas; dos réplicas muertas.
cd "$(dirname "$0")"; Z=$(pwd); cd mi-lab/src/lab
H='Host: api.localhost'; API=http://127.0.0.1:8080
loan() { curl -s -X POST $API/inventory/loans -H "$H" -H 'Content-Type: application/json' -d "{\"sku\":\"$1\",\"originStore\":\"$2\",\"destinationStore\":\"$3\",\"quantity\":1}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])'; }
psqli() { kubectl -n data exec postgres-0 -- psql -U postgres -d inventory -tAc "$1"; }
psqlr() { kubectl -n data exec postgres-0 -- psql -U postgres -d replenish -tAc "$1"; }
set_() { task chaos:set -- "$@" > /dev/null 2>&1; }
curl -s -o /dev/null -H "$H" -H 'Content-Type: application/json' -d '{"type":"COUNT","quantity":500,"reference":"f24"}' $API/inventory/stock/DRO-003/SKU-0005/movements

echo "## §7 · Sogamoso con lluvia en replenish, 20 préstamos de Girón (DRO-003) a Chía (DRO-015), SKU-0005"
T=$(date -u +%Y-%m-%dT%H:%M:%S)
set_ clear; task chaos:set -- perfil sogamoso-con-lluvia > /dev/null 2>&1
IDS=""; for i in $(seq 1 20); do IDS="$IDS $(loan SKU-0005 DRO-003 DRO-015)"; done
sleep 90
for L in $IDS; do python3 "$Z/loan-show.py" $L; done | awk '{print $2}' | sort | uniq -c
echo "fallas del DISPATCH: $(for L in $IDS; do curl -s -H "$H" $API/inventory/loans/$L; echo; done | grep -o '"step":"DISPATCH","action":"DO","outcome":"FAILED","detail":"[^"]*' | sed 's/.*detail":"//' | cut -c1-60 | sort | uniq -c)"
echo "órdenes de DRO-003 a DRO-015 desde $T: $(psqlr "SELECT status, count(*) FROM replenishment_orders WHERE origin_store='DRO-003' AND destination_store='DRO-015' AND created_at >= '$T' GROUP BY status")"
echo "préstamos COMPLETED con orden: $(psqli "SELECT count(*) FROM loans WHERE destination_store='DRO-015' AND created_at >= '$T' AND status='COMPLETED'")"
task chaos:set -- show 2>/dev/null | tr -d ' \n' | grep -o '"counts":{[^}]*}'; echo

echo "## §8 · replenish demorado 3 s (más que los 2 s de G9), 5 préstamos"
T=$(date -u +%Y-%m-%dT%H:%M:%S)
set_ clear; set_ latencyMs=3000 latencyPercent=100
for i in 1 2 3 4 5; do L=$(loan SKU-0003 DRO-003 DRO-007); sleep 3; python3 "$Z/loan-show.py" $L; done
sleep 5
echo "órdenes de DRO-003 a DRO-007 desde $T: $(psqlr "SELECT status, count(*) FROM replenishment_orders WHERE origin_store='DRO-003' AND destination_store='DRO-007' AND created_at >= '$T' GROUP BY status")"
echo "Girón: $(curl -s -H "$H" $API/inventory/stock/DRO-003/SKU-0003)"
task chaos:set -- show 2>/dev/null | tr -d ' \n' | grep -o '"counts":{[^}]*}'; echo

echo "## §7 · dos réplicas de inventory y el orquestador muerto"
set_ clear; set_ latencyMs=1800 latencyPercent=100
kubectl -n apps scale deploy/inventory --replicas=2 > /dev/null; kubectl -n apps rollout status deploy/inventory > /dev/null
IDS=""; for i in $(seq 1 10); do IDS="$IDS $(loan SKU-0003 DRO-003 DRO-007)"; done
sleep 0.7; kubectl -n apps delete pod -l app.kubernetes.io/name=inventory,app.kubernetes.io/component=backend --grace-period=0 --force > /dev/null 2>&1
echo "$(date +%T) las dos réplicas borradas sin plazo"
sleep 100
for L in $IDS; do python3 "$Z/loan-show.py" $L; done
REFS=$(for L in $IDS; do printf "'%s'," $L; done | sed 's/,$//')
echo "LOAN_RELEASED por préstamo: $(psqli "SELECT reference || '=' || count(*) FROM stock_movements WHERE reason_code='LOAN_RELEASED' AND reference IN ($REFS) GROUP BY reference ORDER BY reference" | tr '\n' ' ')"
echo "UNDO repetidos: $(psqli "SELECT count(*) FROM (SELECT loan_id, step FROM loan_steps WHERE action='UNDO' AND outcome='OK' GROUP BY loan_id, step HAVING count(*) > 1) x")"
kubectl -n apps logs -l app.kubernetes.io/name=inventory,app.kubernetes.io/component=backend --prefix --since=3m | grep "barrido:" | cut -c1-220
set_ clear
