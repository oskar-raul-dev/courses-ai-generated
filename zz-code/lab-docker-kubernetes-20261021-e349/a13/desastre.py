"""a13: se borra la base de pricing, y se restaura con el Job. A +8 s y al terminar: el precio y una venta por la puerta."""
import json, pathlib, subprocess, time, urllib.request

K = ["kubectl", "--context", "kind-lab"]
H = {"Host": "api.localhost", "Content-Type": "application/json"}


def get(method, path, body=None):
    req = urllib.request.Request("http://127.0.0.1:8080" + path, data=json.dumps(body).encode() if body else None, method=method, headers=H)
    try:
        with urllib.request.urlopen(req, timeout=5) as r:
            return r.status, r.read().decode()[:80]
    except urllib.error.HTTPError as e:
        return e.code, ""


def state(t0):
    p = get("GET", "/pricing/prices/SKU-0001?store=DRO-001")
    s = get("POST", "/inventory/sales", {"store": "DRO-001", "sku": "SKU-0001", "quantity": 1})
    ready = subprocess.run(K + ["-n", "apps", "get", "deploy", "pricing", "-o", "jsonpath={.status.readyReplicas}/{.spec.replicas}"],
                           capture_output=True, text=True).stdout
    return f"+{time.time() - t0:.0f} s · precio por la puerta: {p[0]} {p[1] if p[0] == 200 else ''}· venta: {s[0]} · pricing: {ready or '0/1'}"


t0 = time.time()
print(subprocess.run(K + ["-n", "data", "exec", "postgres-0", "--", "psql", "-U", "postgres", "-c", "DROP DATABASE pricing WITH (FORCE)"],
                     capture_output=True, text=True).stdout.strip())
time.sleep(8)
print(state(t0))
manifest = str(pathlib.Path(__file__).parent / "restore-pricing.yaml")
subprocess.run(K + ["apply", "-f", manifest], capture_output=True)
subprocess.run(K + ["-n", "data", "wait", "--for=condition=complete", "job/postgres-restore-pricing", "--timeout=120s"], capture_output=True)
print(subprocess.run(K + ["-n", "data", "logs", "job/postgres-restore-pricing"], capture_output=True, text=True).stdout.strip())
while get("POST", "/inventory/sales", {"store": "DRO-001", "sku": "SKU-0001", "quantity": 1})[0] != 201:
    time.sleep(0.5)
print(state(t0))
