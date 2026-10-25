#!/bin/sh
# F21 §4, caso 3: catalog en cero réplicas, con las NetworkPolicy de la F20. La venta por la puerta; catalog vuelve a
# los 150 s; y la línea de inventory de esa venta.
kubectl -n apps scale deploy/catalog --replicas=0 >/dev/null; kubectl -n apps wait --for=delete pod -l app.kubernetes.io/name=catalog,app.kubernetes.io/component=backend --timeout=90s >/dev/null 2>&1
T=$(date -u +%Y-%m-%dT%H:%M:%SZ)
curl -s -o /tmp/caso3 -w "venta: %{http_code} a los %{time_total} s\n" -H 'Host: api.localhost' -H 'Content-Type: application/json' -d '{"store":"DRO-009","sku":"SKU-0002","quantity":1}' http://127.0.0.1:8080/inventory/sales; cat /tmp/caso3; echo
sleep 135
kubectl -n apps scale deploy/catalog --replicas=1 >/dev/null; kubectl -n apps rollout status deploy/catalog >/dev/null
sleep 20
kubectl -n apps logs deploy/inventory --since-time=$T 2>/dev/null | grep '"uri":"/sales"' | cut -c1-260
