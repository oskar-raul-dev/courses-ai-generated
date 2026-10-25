"""Lee los seis paneles del tablero La Vecina · RED con sus mismas consultas, por la API de Prometheus.
Uso: python3 tablero.py   (Prometheus en prometheus.localhost:8080)"""
import json, urllib.parse, urllib.request
F = 'chain=~".*",uri!~"/health.*|/metrics"'
X = f'http_server_requests_seconds_count{{{F}}}'
PANELS = [
    ("Peticiones por segundo", f'sum by (service) (rate({X}[1m]))', "service", "{:.3g} req/s"),
    ("Errores (5xx)", f'(sum by (service) (rate(http_server_requests_seconds_count{{{F},status=~"5.."}}[1m])) or sum by (service) (rate({X}[1m])) * 0) / sum by (service) (rate({X}[1m]))', "service", "{:.0%}"),
    ("Latencia p95", f'histogram_quantile(0.95, sum by (service, le) (rate(http_server_requests_seconds_bucket{{{F}}}[1m]))) * 1000', "service", "{:.3g} ms"),
    ("Ventas por minuto", 'sum by (chain) (rate(lab_sales_total[5m])) * 60', "chain", "{:.3g}"),
    ("Memoria por pod", 'sum by (pod) (container_memory_working_set_bytes{namespace=~"apps|apps-b|observability"}) / 1048576', "pod", "{:.3g} MiB"),
    ("Series en Prometheus", 'prometheus_tsdb_head_series', "job", "{:.0f}"),
]
for title, q, label, fmt in PANELS:
    url = "http://127.0.0.1:8080/api/v1/query?" + urllib.parse.urlencode({"query": q})
    req = urllib.request.Request(url, headers={"Host": "prometheus.localhost"})
    res = json.load(urllib.request.urlopen(req))["data"]["result"]
    vals = sorted(((r["metric"].get(label, ""), float(r["value"][1])) for r in res), key=lambda kv: -kv[1] if kv[1] == kv[1] else 0)
    print(f"{title:<24} " + " · ".join(f"{k} {fmt.format(v)}" for k, v in vals))
