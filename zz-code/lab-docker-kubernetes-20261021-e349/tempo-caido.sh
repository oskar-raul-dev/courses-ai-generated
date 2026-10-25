#!/bin/sh
# F23 §6: sesenta lecturas seguidas por la puerta a cada servicio, con Tempo y con Tempo en cero réplicas; y una venta.
H='Host: api.localhost'; API=http://127.0.0.1:8080
lecturas() { python3 - "$1" <<'PY'
import sys, time, urllib.request, statistics
url = "http://127.0.0.1:8080" + sys.argv[1]; t = []
for _ in range(60):
    s = time.time()
    try: urllib.request.urlopen(urllib.request.Request(url, headers={"Host": "api.localhost"}), timeout=20).read()
    except Exception: pass
    t.append((time.time() - s) * 1000)
print(f"{sys.argv[1]:<34} mediana {statistics.median(t):.1f} ms  máx {max(t):.0f}")
PY
}
venta() { curl -s -o /tmp/tv -w "%{http_code} en %{time_total}s · " -H "$H" -H 'Content-Type: application/json' -d '{"store":"DRO-007","sku":"SKU-0001","quantity":1}' $API/inventory/sales; head -c 160 /tmp/tv; echo; }
run() { lecturas "/pricing/prices?store=DRO-007"; lecturas "/replenish/replenishment-orders"; lecturas "/catalog/products"; venta; }
echo "## con Tempo"; kubectl -n observability top pod -l app.kubernetes.io/name=tempo --no-headers; run
kubectl -n observability scale deploy/tempo --replicas=0 >/dev/null; kubectl -n observability wait --for=delete pod -l app.kubernetes.io/name=tempo --timeout=60s >/dev/null 2>&1; sleep 5
echo "## Tempo en 0"; run
kubectl -n apps logs deploy/catalog -c php-fpm --since=5m 2>/dev/null | grep -o "cURL error [0-9]*: [^(]*" | sort | uniq -c | head -4
kubectl -n observability scale deploy/tempo --replicas=1 >/dev/null; kubectl -n observability rollout status deploy/tempo >/dev/null
