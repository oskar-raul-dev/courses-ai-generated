#!/bin/sh
# F19: los incidentes 18 a 24, cada uno con task inc:break, su síntoma, task inc:fix y la comprobación.
cd "$(dirname "$0")/mi-lab/src/lab" || exit 1
URL='https://api.localhost:8443/pricing/prices?store=DRO-007'
https() { curl -sS -o /dev/null -w "%{http_code}\n" --cacert .secrets/tls/ca.crt "$URL" 2>&1 | head -1; }
s_client() { echo | openssl s_client -connect 127.0.0.1:8443 -servername "${1:-api.localhost}" -CAfile .secrets/tls/ca.crt 2>&1 | grep -E "Verify return code|notAfter" | head -2; }
listener() { kubectl -n gateway get gateway lab -o jsonpath='{range .status.listeners[?(@.name=="https")].conditions[*]}{.type}={.status} {end}{"\n"}'; }
sale() { curl -s -H 'Host: api.localhost' -H 'Content-Type: application/json' -d '{"store":"DRO-007","sku":"SKU-0001","quantity":1}' http://127.0.0.1:8080/inventory/sales | cut -c1-260; echo; }
fix() { task inc:fix PROFILE=minimo CLUSTER=lab -- $1 > /dev/null 2>&1; echo "fix $1: $?"; }
brk() { echo "=== incidente $1"; task inc:break PROFILE=minimo CLUSTER=lab -- $1 > /dev/null 2>&1; echo "break $1: $?"; }

brk 18; echo "recién puesto: $(https)"; sleep 130; echo "a los 130 s: $(https)"; s_client; kubectl -n gateway get certificate lab-tls 2>&1; listener; fix 18; sleep 3; echo "después: $(https)"
brk 19; sleep 5; echo "$(https)"; fix 19; sleep 3; echo "después: $(https)"
brk 20; sleep 5; echo "api: $(https)"; curl -sS -o /dev/null --cacert .secrets/tls/ca.crt https://storefront.localhost:8443/ 2>&1 | head -1; fix 20; sleep 3; echo "después: $(https)"
brk 21; sleep 8; echo "$(https)"; listener; kubectl -n gateway get gateway lab -o jsonpath='{range .status.listeners[?(@.name=="https")].conditions[*]}{.message}{"\n"}{end}' | grep -i key | head -2; fix 21; sleep 5; echo "después: $(https)"
brk 22; sleep 40; kubectl -n gateway get certificate lab-tls; kubectl -n apps get certificate; kubectl -n apps get pods -l app.kubernetes.io/name=pricing,app.kubernetes.io/component=backend; kubectl -n apps describe certificate pricing-tls | grep -A3 "Message" | head -4; fix 22; sleep 20; kubectl -n apps get certificate; kubectl -n apps get pods -l app.kubernetes.io/name=pricing,app.kubernetes.io/component=backend
brk 23; kubectl -n apps rollout status deploy/inventory > /dev/null; sleep 5; sale; kubectl -n apps logs deploy/inventory --since=30s 2>/dev/null | grep -m1 -o 'pricing no contesta[^"]*' | cut -c1-260; fix 23; sleep 5; sale
brk 24; sleep 40; kubectl -n apps get pods -l app.kubernetes.io/name=pricing,app.kubernetes.io/component=backend; kubectl -n apps describe pods -l app.kubernetes.io/name=pricing,app.kubernetes.io/component=backend | grep -m1 -o 'tls: failed to verify certificate: x509: [a-z ]*'; fix 24; sleep 25; kubectl -n apps get pods -l app.kubernetes.io/name=pricing,app.kubernetes.io/component=backend
