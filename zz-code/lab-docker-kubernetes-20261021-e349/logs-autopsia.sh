#!/bin/sh
# F18 §9: request_id como etiqueta de Loki. Cinco minutos a 5 visitas/s con la etiqueta; flujos, memoria de
# Loki, errores de Fluent Bit, y las peticiones de los últimos siete minutos contadas en Prometheus y en Loki.
streams() { curl -s -G http://127.0.0.1:13100/loki/api/v1/series --data-urlencode 'match[]={job="fluent-bit"}' --data-urlencode "start=$(($(date +%s)-300))000000000" | python3 -c 'import json,sys; print(len(json.load(sys.stdin)["data"]))'; }
fberr() { for p in $(kubectl -n observability get pods -l app.kubernetes.io/name=fluent-bit -o name); do printf '%s ' "$(kubectl -n observability logs $p --since=10m | grep -c '\[error\]')"; done; }
Z=$(pwd)
lq() { python3 "$Z/lq.py" "$1"; }
pq() { python3 "$Z/pq.py" "$1"; }
cd mi-lab/src/lab
echo "antes: flujos $(streams) · loki $(kubectl -n observability top pod -l app.kubernetes.io/name=loki --no-headers | awk '{print $3}') · errores de fluent-bit $(fberr)"
helm upgrade lab charts/platform -n apps --kube-context kind-lab --reuse-values --set-string "fluent-bit.labels=job=fluent-bit\, namespace=\$kubernetes['namespace_name']\, service=\$kubernetes['labels']['app.kubernetes.io/name']\, container=\$kubernetes['container_name']\, request_id=\$request_id" --wait > /dev/null
kubectl -n observability rollout status ds/fluent-bit > /dev/null
kubectl -n observability get cm fluent-bit -o yaml | grep -o 'request_id=[^ ,]*' | head -1
k6 run -q -e RATE=5 -e DURATION=5m bench/trafico/la-vecina.js > /dev/null 2>&1
echo "después de 5 min: flujos $(streams) · loki $(kubectl -n observability top pod -l app.kubernetes.io/name=loki --no-headers | awk '{print $3}') · errores de fluent-bit $(fberr)"
kubectl -n observability logs -l app.kubernetes.io/name=fluent-bit --since=10m | grep -m2 'stream limit\|cannot be retried' | cut -c1-300
echo "prometheus: $(pq 'sum by (service) (increase(http_server_requests_seconds_count{uri!~"/health.*|/metrics"}[7m]))')"
echo "loki:       $(lq 'sum by (service) (count_over_time({job="fluent-bit",container!="nginx"} | json | msg="request" | uri!~"/health.*|/metrics" [7m]))')"
