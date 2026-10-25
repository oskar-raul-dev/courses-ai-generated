"""F27 criterio 5: una venta bajo el umbral llega a notify, y una entrega repetida (el mismo evento con otro id de
outbox, que JetStream no puede reconocer) no lo duplica."""
import json, subprocess, time, urllib.request

K = ["kubectl", "--context", "kind-lab"]
H = {"Host": "api.localhost", "Content-Type": "application/json"}


def http(method, path, body=None):
    req = urllib.request.Request("http://127.0.0.1:8080" + path, data=json.dumps(body).encode() if body else None,
                                 method=method, headers=H)
    with urllib.request.urlopen(req, timeout=10) as r:
        return json.load(r)


def psql(sql):
    return subprocess.run(K + ["-n", "data", "exec", "postgres-0", "--", "psql", "-U", "postgres", "-d", "inventory", "-tA",
                               "-c", sql], capture_output=True, text=True).stdout.strip()


sale = http("POST", "/inventory/sales", {"store": "DRO-028", "sku": "SKU-0002", "quantity": 1})["id"]
time.sleep(3)
print(f"venta {sale}: avisos en notify = {len(http('GET', f'/notify/notifications?saleId={sale}'))}")
event = psql(f"SELECT id FROM outbox WHERE payload LIKE '%\"saleId\":\"{sale}\"%'")
copy = psql(f"INSERT INTO outbox (id, subject, payload, created_at) SELECT 'copia-' || id, subject, payload, "
            f"to_char(now() at time zone 'utc', 'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') FROM outbox WHERE id = '{event}' RETURNING id")
print(f"el evento {event}, otra vez en el outbox como {copy.splitlines()[0]}")
time.sleep(4)
print(f"venta {sale}: avisos en notify = {len(http('GET', f'/notify/notifications?saleId={sale}'))}")
logs = subprocess.run(K + ["-n", "apps", "logs", "deploy/notify", "--since=20s"], capture_output=True, text=True).stdout
for line in logs.splitlines():
    if event in line:
        d = json.loads(line)
        print(json.dumps({k: d[k] for k in ("msg", "eventId", "saleId", "delivery")}, ensure_ascii=False))
