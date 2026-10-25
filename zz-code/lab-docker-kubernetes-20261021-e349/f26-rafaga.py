"""F26 §4 y §8.1: ráfaga de 16 clientes durante 10 s en una droguería con el umbral por encima de la existencia (cada
venta pide reposición), y un kill -9 desde el nodo a los 4 s. Al final cruza las dos bases: ventas confirmadas en
inventory contra órdenes creadas por evento en replenish.
Uso: f26-rafaga.py replenish|inventory|nada [DRO-0xx]"""
import collections, datetime, json, subprocess, sys, threading, time, urllib.request

API, H = "http://127.0.0.1:8080", {"Host": "api.localhost"}
K = ["kubectl", "--context", "kind-lab"]
PATTERN = {"replenish": "dist/main", "inventory": "inventory-0.0.1-SNAPSHOT.jar"}
target = sys.argv[1]
store = sys.argv[2] if len(sys.argv) > 2 else "DRO-031"


def call(method, path, body, ctype="application/json"):
    req = urllib.request.Request(API + path, data=json.dumps(body).encode(), method=method,
                                 headers=H | {"Content-Type": ctype})
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return e.code
    except Exception:
        return "sin respuesta"


def psql(db, sql):
    out = subprocess.run(K + ["-n", "data", "exec", "postgres-0", "--", "psql", "-U", "postgres", "-d", db, "-tA", "-c", sql],
                         capture_output=True, text=True)
    return out.stdout.strip()


prep = (call("PUT", "/pricing/prices/SKU-0002", {"store": store, "price": 15000}),
        call("POST", f"/inventory/stock/{store}/SKU-0002/movements", {"type": "COUNT", "quantity": 100000, "reference": "f26"}),
        call("PATCH", f"/inventory/stock/{store}/SKU-0002", {"reorderThreshold": 1000000}, "application/merge-patch+json"))
if any(c != 200 and c != 201 for c in prep):
    sys.exit(f"la preparación falló: {prep}")
since = datetime.datetime.now(datetime.UTC).strftime("%Y-%m-%dT%H:%M:%S")
t0 = time.time()
codes = collections.Counter()
lock = threading.Lock()


def client():
    while time.time() - t0 < 10:
        c = call("POST", "/inventory/sales", {"store": store, "sku": "SKU-0002", "quantity": 1})
        with lock:
            codes[c] += 1


def kill():
    time.sleep(4)
    pod = subprocess.run(K + ["-n", "apps", "get", "pods", "-l", f"app.kubernetes.io/name={target},app.kubernetes.io/component=backend",
                              "-o", "jsonpath={.items[0].spec.nodeName}"], capture_output=True, text=True).stdout
    r = subprocess.run(["docker", "exec", pod, "pkill", "-9", "-f", PATTERN[target]], capture_output=True, text=True)
    print(f"+ {time.time() - t0:.1f}s $ docker exec {pod} pkill -9 -f {PATTERN[target]} → {r.returncode}", flush=True)


threads = [threading.Thread(target=client) for _ in range(16)]
if target in PATTERN:
    threads.append(threading.Thread(target=kill))
for t in threads:
    t.start()
for t in threads:
    t.join()
# El ack_wait es de 30 s: lo que quedó sin confirmar vuelve después de eso. Y un proceso que reinicia con back-off
# tarda en vaciar lo pendiente: se espera a que el consumidor no tenga nada por entregar ni por confirmar.
def pending():
    raw = subprocess.run(K + ["-n", "data", "exec", "nats-0", "--", "wget", "-qO-", "http://127.0.0.1:8222/jsz?consumers=true"],
                         capture_output=True, text=True).stdout
    for acc in json.loads(raw or "{}").get("account_details", []):
        for st in acc.get("stream_detail", []):
            for c in st.get("consumer_detail", []):
                if c["name"] == "replenish-stock-low":
                    return c["num_pending"], c["num_ack_pending"]
    return None


time.sleep(40)
deadline = time.time() + 240
while pending() not in ((0, 0), None) and time.time() < deadline:
    time.sleep(2)
print(f"consumidor (pendientes, sin confirmar): {pending()} a los {time.time() - t0:.0f} s")
sales = int(psql("inventory", f"SELECT count(*) FROM sales WHERE store = '{store}' AND sku = 'SKU-0002' AND created_at >= '{since}'"))
rows = psql("replenish", f"SELECT source_event_id FROM replenishment_orders WHERE destination_store = '{store}' "
                         f"AND sku = 'SKU-0002' AND created_at >= '{since}' AND source_event_id IS NOT NULL").splitlines()
events = collections.Counter(rows)
print(f"respuestas al cliente: {dict(codes)}")
print(f"ventas confirmadas en la base: {sales} · órdenes: {len(rows)} · eventos distintos: {len(events)} · "
      f"ventas sin orden: {sales - len(events)} · órdenes repetidas: {len(rows) - len(events)}")
for ev, n in events.items():
    if n > 1:
        print(f"  repetido: {ev} ({n} órdenes)")
