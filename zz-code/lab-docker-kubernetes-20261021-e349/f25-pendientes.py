"""F25 §5.7: replenish en cero, diez ventas que piden reposición, /jsz de NATS durante 60 s, replenish de vuelta y
cuánto tardan los pendientes en llegar a cero después de que el pod queda listo."""
import json, subprocess, sys, time, urllib.request

API, H = "http://127.0.0.1:8080", {"Host": "api.localhost"}
K = ["kubectl", "--context", "kind-lab", "-n", "apps"]


def call(method, path, body, ctype="application/json"):
    req = urllib.request.Request(API + path, data=json.dumps(body).encode(), method=method,
                                 headers=H | {"Content-Type": ctype})
    try:
        with urllib.request.urlopen(req, timeout=20) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return e.code


def pending():
    raw = subprocess.run(["kubectl", "--context", "kind-lab", "-n", "data", "exec", "nats-0", "--", "wget", "-qO-",
                          "http://127.0.0.1:8222/jsz?consumers=true"], capture_output=True, text=True).stdout
    for acc in json.loads(raw).get("account_details", []):
        for st in acc.get("stream_detail", []):
            for c in st.get("consumer_detail", []):
                if c["name"] == "replenish-stock-low":
                    return c["num_pending"], c["num_ack_pending"]
    sys.exit("no encontré el consumidor replenish-stock-low en /jsz")


prep = (call("POST", "/inventory/stock/DRO-021/SKU-0002/movements", {"type": "COUNT", "quantity": 500, "reference": "f25"}),
        call("PATCH", "/inventory/stock/DRO-021/SKU-0002", {"reorderThreshold": 1000}, "application/merge-patch+json"))
if any(c >= 300 for c in prep):
    sys.exit(f"la preparación falló: {prep}")
subprocess.run(K + ["scale", "deploy/replenish", "--replicas=0"], capture_output=True)
subprocess.run(K + ["wait", "--for=delete", "pod", "-l", "app.kubernetes.io/name=replenish,app.kubernetes.io/component!=migrate",
                    "--timeout=60s"], capture_output=True)
codes = [call("POST", "/inventory/sales", {"store": "DRO-021", "sku": "SKU-0002", "quantity": 1}) for _ in range(10)]
time.sleep(2)
print(f"10 ventas ({set(codes)}) con replenish en cero; en el stream, pendientes y sin confirmar: {pending()}")
time.sleep(60)
print(f"+60s, pendientes: {pending()}; replenish vuelve")
subprocess.run(K + ["scale", "deploy/replenish", "--replicas=1"], capture_output=True)
subprocess.run(K + ["rollout", "status", "deploy/replenish", "--timeout=120s"], capture_output=True)
ready = time.time()
while pending() != (0, 0):
    time.sleep(0.1)
print(f"pendientes en cero {time.time() - ready:.1f} s después de que replenish quedó listo")
