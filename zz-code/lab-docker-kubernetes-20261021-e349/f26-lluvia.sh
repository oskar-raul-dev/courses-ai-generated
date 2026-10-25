#!/bin/sh
# F26 apuesta 4 y §8.3: Sogamoso con lluvia en replenish con 20 préstamos, con G13. Con la lluvia parada, se espera a
# que ninguno quede compensando, y se cuentan las huérfanas por la clave: una orden PENDING cuyo préstamo no terminó
# COMPLETED. Requiere task chaos:on TARGET=replenish antes.
cd "$(dirname "$0")"; Z=$(pwd); cd mi-lab/src/lab
H='Host: api.localhost'; API=http://127.0.0.1:8080
K="kubectl --context kind-lab"
loan() { curl -s -X POST $API/inventory/loans -H "$H" -H 'Content-Type: application/json' -d "{\"sku\":\"$1\",\"originStore\":\"$2\",\"destinationStore\":\"$3\",\"quantity\":1}" | python3 -c 'import json,sys; print(json.load(sys.stdin)["id"])'; }
psqli() { $K -n data exec postgres-0 -- psql -U postgres -d inventory -tAc "$1"; }
psqlr() { $K -n data exec postgres-0 -- psql -U postgres -d replenish -tAc "$1"; }
curl -s -o /dev/null -H "$H" -H 'Content-Type: application/json' -d '{"type":"COUNT","quantity":500,"reference":"f26"}' $API/inventory/stock/DRO-003/SKU-0005/movements

echo "## Sogamoso con lluvia en replenish, 20 préstamos de Girón (DRO-003) a Chía (DRO-015), SKU-0005, con G13"
T=$(date -u +%Y-%m-%dT%H:%M:%S)
task chaos:set -- clear > /dev/null 2>&1; task chaos:set -- perfil sogamoso-con-lluvia > /dev/null 2>&1
IDS=""; for i in $(seq 1 20); do IDS="$IDS $(loan SKU-0005 DRO-003 DRO-015)"; done
sleep 90
echo "a los 90 s, con lluvia:"; for L in $IDS; do python3 "$Z/loan-show.py" $L; done | awk '{print $2}' | sort | uniq -c
task chaos:set -- show 2>/dev/null | tr -d ' \n' | grep -o '"counts":{[^}]*}'; echo
task chaos:set -- clear > /dev/null 2>&1
echo "$(date +%T) lluvia parada; se espera a que ninguno quede compensando (hasta 10 min)"
i=0; while [ $i -lt 60 ]; do
  N=$(psqli "SELECT count(*) FROM loans WHERE destination_store='DRO-015' AND created_at >= '$T' AND status NOT IN ('COMPLETED','COMPENSATED','BACKORDERED')")
  [ "$N" = 0 ] && break; sleep 10; i=$((i+1))
done
echo "$(date +%T) sin terminar: $N"
for L in $IDS; do python3 "$Z/loan-show.py" $L; done | awk '{print $2}' | sort | uniq -c
echo "pasos por préstamo, el más largo: $(psqli "SELECT max(n) FROM (SELECT count(*) n FROM loan_steps s JOIN loans l ON l.id = s.loan_id WHERE l.destination_store='DRO-015' AND l.created_at >= '$T' GROUP BY s.loan_id) x")"
echo "UNDO de DISPATCH fallidos, por motivo:"; psqli "SELECT left(detail, 90), count(*) FROM loan_steps s JOIN loans l ON l.id = s.loan_id WHERE l.destination_store='DRO-015' AND l.created_at >= '$T' AND s.step='DISPATCH' AND s.action='UNDO' AND s.outcome='FAILED' GROUP BY 1"
OK=$(psqli "SELECT string_agg('''' || 'LOAN-' || lpad(id::text, 6, '0') || '''', ',') FROM loans WHERE destination_store='DRO-015' AND created_at >= '$T' AND status = 'COMPLETED'")
echo "órdenes de los préstamos, por estado: $(psqlr "SELECT status, count(*) FROM replenishment_orders WHERE origin_store='DRO-003' AND destination_store='DRO-015' AND created_at >= '$T' GROUP BY status" | tr '\n' ' ')"
echo "huérfanas (PENDING con préstamo que no terminó COMPLETED): $(psqlr "SELECT count(*) FROM replenishment_orders WHERE origin_store='DRO-003' AND destination_store='DRO-015' AND created_at >= '$T' AND status = 'PENDING' AND idempotency_key NOT IN (${OK:-''''})")"
