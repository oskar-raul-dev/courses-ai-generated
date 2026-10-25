#!/bin/sh
# F18 §8: lo que cuestan los logs. Diez minutos de tráfico a 2 visitas/s; memoria de Fluent Bit, Loki,
# Grafana y Prometheus; líneas, bytes y flujos que entraron a Loki en esos diez minutos. Después, dos
# minutos de reposo: cuántas líneas, y de quién. Loki por port-forward en 13100.
lq() { curl -s -G http://127.0.0.1:13100/loki/api/v1/query --data-urlencode "query=$1" | python3 -c 'import json,sys; r=json.load(sys.stdin)["data"]["result"]; print(" ".join(f"{x[\"metric\"]}={float(x[\"value\"][1]):.0f}" if x["metric"] else f"{float(x[\"value\"][1]):.0f}" for x in r) or 0)'; }
cd mi-lab/src/lab
k6 run -q -e RATE=2 -e DURATION=10m bench/trafico/la-vecina.js > /dev/null 2>&1
echo "== a los 10 min de tráfico ($(date +%T))"
kubectl -n observability top pods --no-headers
echo "líneas: $(lq 'sum(count_over_time({job="fluent-bit"}[10m]))') · bytes: $(lq 'sum(bytes_over_time({job="fluent-bit"}[10m]))') · flujos: $(lq 'count(count_over_time({job="fluent-bit"}[10m]))')"
sleep 120
echo "== dos minutos de reposo"
echo "líneas: $(lq 'sum(count_over_time({job="fluent-bit"}[2m]))') · bytes: $(lq 'sum(bytes_over_time({job="fluent-bit"}[2m]))')"
echo "sondas: $(lq 'sum(count_over_time({job="fluent-bit"} | json | uri=~"/health.*" [2m]))') · scrapes de /metrics: $(lq 'sum(count_over_time({job="fluent-bit"} | json | uri="/metrics" [2m]))')"
echo "por servicio: $(lq 'sum by (service) (count_over_time({job="fluent-bit"}[2m]))')"
