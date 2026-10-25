#!/bin/sh
# F19 §8: la venta con mTLS (inventory → pricing:8443) y sin él (pricing:8080), la misma imagen; tres corridas
# alternadas, y la memoria de cert-manager y trust-manager.
cd "$(dirname "$0")"
run() { k6 run -q k6/ventas.js 2>&1 | awk -v m="$1" -v c="$2" '/http_req_duration/ && !/expected/ {d=$0} /checks_failed/ {f=$0} END {print m " · corrida " c " · " d " · " f}'; }
for c in 1 2 3; do
  kubectl -n apps set env deploy/inventory PRICING_URL=https://pricing.apps.svc.cluster.local:8443 >/dev/null; kubectl -n apps rollout status deploy/inventory >/dev/null; sleep 10; run "con mTLS" $c
  kubectl -n apps set env deploy/inventory PRICING_URL=http://pricing.apps.svc.cluster.local:8080 >/dev/null; kubectl -n apps rollout status deploy/inventory >/dev/null; sleep 10; run "sin mTLS" $c
done
kubectl -n cert-manager top pods
