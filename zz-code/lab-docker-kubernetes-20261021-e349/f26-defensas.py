"""F26 §8.2: las dos defensas, a propósito, en la base de inventory. 1) el mismo evento otra vez con otro id de outbox
(JetStream no puede reconocerlo: lo frena processed_events); 2) un evento ya publicado, marcado como pendiente (el
relay "murió antes de anotarlo": lo frena el Nats-Msg-Id)."""
import json, subprocess, time

K = ["kubectl", "--context", "kind-lab"]


def psql(sql):
    return subprocess.run(K + ["-n", "data", "exec", "postgres-0", "--", "psql", "-U", "postgres", "-d", "inventory", "-tA",
                               "-c", sql], capture_output=True, text=True).stdout.strip().splitlines()[0]


a = psql("SELECT id FROM outbox WHERE published_at IS NOT NULL ORDER BY created_at DESC LIMIT 1 OFFSET 5")
b = psql("SELECT id FROM outbox WHERE published_at IS NOT NULL ORDER BY created_at DESC LIMIT 1 OFFSET 9")
print("-- 1. el mismo evento, otra vez, con otro id de outbox:")
print(" ", psql(f"INSERT INTO outbox (id, subject, payload, created_at) SELECT 'copia-' || id, subject, payload, "
                f"to_char(now() at time zone 'utc', 'YYYY-MM-DD\"T\"HH24:MI:SS.MS\"Z\"') FROM outbox WHERE id = '{a}' RETURNING id"))
print("-- 2. un evento ya publicado, marcado como pendiente:")
print(" ", psql(f"UPDATE outbox SET published_at = NULL WHERE id = '{b}' RETURNING id"))
time.sleep(5)
for c, sel in (("outbox-relay", "inventory"), ("replenish", "replenish")):
    out = subprocess.run(K + ["-n", "apps", "logs", f"deploy/{sel}", "-c", c, "--since=15s"], capture_output=True, text=True).stdout
    for line in out.splitlines():
        if a in line or b in line or "publicados" in line:
            d = json.loads(line)
            keep = {k: d[k] for k in ("component", "service", "msg", "eventId", "count", "saleId", "deliveryCount") if k in d}
            print(json.dumps(keep, ensure_ascii=False))
