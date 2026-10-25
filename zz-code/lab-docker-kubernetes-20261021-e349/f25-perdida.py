"""F25 §4, §5.5 y §8: treinta ventas, una por segundo, en DRO-021 con el umbral por encima de la existencia (cada
venta pide reposición); a los 5 s, la acción que se pida sobre replenish. Después: órdenes nuevas, eventos distintos,
repetidos, y cómo salió cada aviso según el log de inventory.
Uso: f25-perdida.py kill|rollout|nada"""
import collections, datetime, json, subprocess, sys, threading, time, urllib.request

API, H = "http://127.0.0.1:8080", {"Host": "api.localhost", "Content-Type": "application/json"}
K = ["kubectl", "--context", "kind-lab", "-n", "apps"]


def call(method, path, body=None, ctype="application/json"):
    req = urllib.request.Request(API + path, data=json.dumps(body).encode() if body else None, method=method,
                                 headers=H | {"Content-Type": ctype})
    try:
        with urllib.request.urlopen(req, timeout=20) as r:
            return r.status
    except urllib.error.HTTPError as e:
        return e.code


def psql(db, sql):
    return subprocess.run(["kubectl", "--context", "kind-lab", "-n", "data", "exec", "postgres-0", "--", "psql", "-U", "postgres",
                           "-d", db, "-tAF", "|", "-c", sql], capture_output=True, text=True).stdout.strip()


action = sys.argv[1]
prep = (call("POST", "/inventory/stock/DRO-021/SKU-0002/movements", {"type": "COUNT", "quantity": 500, "reference": "f25"}),
        call("PATCH", "/inventory/stock/DRO-021/SKU-0002", {"reorderThreshold": 1000}, "application/merge-patch+json"))
if any(c >= 300 for c in prep):
    sys.exit(f"la preparación falló: conteo y umbral respondieron {prep}")
since = datetime.datetime.now(datetime.UTC).strftime("%Y-%m-%dT%H:%M:%S")
t0 = time.time()


def act():
    time.sleep(5)
    cmd = {"kill": K + ["exec", "deploy/replenish", "--", "kill", "1"],
           "rollout": K + ["rollout", "restart", "deploy/replenish"]}.get(action)
    if cmd:
        print(f"+ {time.time() - t0:.1f}s $ {' '.join(cmd)}", flush=True)
        subprocess.run(cmd, capture_output=True)


threading.Thread(target=act).start()
codes = collections.Counter()
for i in range(30):
    codes[call("POST", "/inventory/sales", {"store": "DRO-021", "sku": "SKU-0002", "quantity": 1})] += 1
    time.sleep(max(0, (i + 1) - (time.time() - t0)))
time.sleep(20)
rows = psql("replenish", f"SELECT coalesce(source_event_id, '-') FROM replenishment_orders WHERE destination_store = 'DRO-021' "
                         f"AND sku = 'SKU-0002' AND created_at >= '{since}'").splitlines()
events = [r for r in rows if r != "-"]
print(f"ventas: 30 · respuestas: {dict(codes)}")
print(f"órdenes nuevas: {len(rows)} · eventos distintos: {len(set(events))} · repetidos: {len(events) - len(set(events))}")
logs = subprocess.run(K + ["logs", "-l", "app.kubernetes.io/name=inventory,app.kubernetes.io/component=backend", f"--since-time={since}Z",
                           "--tail=-1"], capture_output=True, text=True).stdout
subs = collections.Counter()
for line in logs.splitlines():
    if "DRO-021" not in line and "SALE-" not in line:
        continue
    if "suscriptores" in line:
        subs[line.split(" a ")[-1].split(" suscriptores")[0]] += 1
lost = [l for l in logs.splitlines() if "perdido" in l or "aviso a replenish falló" in l]
if subs:
    print(f"avisos publicados, por suscriptores: {dict(subs)}")
print(f"avisos perdidos: {len(lost)}")
for l in lost[:2]:
    print("  ", json.loads(l)["msg"][:160] if l.startswith("{") else l[:160])
