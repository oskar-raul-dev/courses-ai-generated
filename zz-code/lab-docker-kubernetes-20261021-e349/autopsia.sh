#!/bin/sh
# F17 §9: la etiqueta con la ruta cruda. 2.000 SKU distintos a pricing, con el patrón y con METRICS_URI=raw;
# series de pricing, series totales y heap de Prometheus, y otra lectura cinco minutos después.
q() { curl -s -G -H 'Host: prometheus.localhost' http://127.0.0.1:8080/api/v1/query --data-urlencode "query=$1" | python3 -c 'import json,sys; r=json.load(sys.stdin)["data"]["result"]; print(r[0]["value"][1] if r else 0)'; }
read_() { sleep 35; echo "$1 · series de pricing $(q 'count({job="backends",service="pricing"})') · totales $(q prometheus_tsdb_head_series) · heap MiB $(q 'go_memstats_heap_inuse_bytes{job="prometheus"}/1048576')"; }
load() { seq 1 2000 | xargs -P20 -I{} sh -c 'curl -s -o /dev/null -H "Host: api.localhost" "http://127.0.0.1:8080/pricing/prices/SKU-$(printf %04d {})?store=DRO-001"'; }
read_ "antes"
load; read_ "con el patrón"
kubectl -n apps set env deploy/pricing METRICS_URI=raw >/dev/null; kubectl -n apps rollout status deploy/pricing >/dev/null
load; read_ "con la ruta cruda"
sleep 265; read_ "5 min después"
