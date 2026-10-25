"""a15: una venta con su Nats-Msg-Id; kill -9 al líder; la misma venta otra vez con el líder nuevo."""
import json, subprocess, time

K = ["kubectl", "--context", "kind-lab", "-n", "data"]
box = K + ["exec", "a15-nats-box", "--", "nats", "-s", "nats://nats-ha.data.svc.cluster.local:4222"]
sh = lambda c: subprocess.run(c, capture_output=True, text=True)


def info():
    for _ in range(60):
        try:
            return json.loads(sh(box + ["stream", "info", "A15", "-j"]).stdout)
        except ValueError:
            time.sleep(1)


sh(box + ["stream", "purge", "A15", "-f"])
mid = f"venta-dedup-{int(time.time())}"
pub = lambda: (lambda r: (r.stdout + r.stderr).strip().splitlines()[-1])(sh(box + ["pub", "-J", "-H", f"Nats-Msg-Id:{mid}", "a15.ventas", "venta de Chapinero"]))
leader = info()["cluster"]["leader"]
print(f"con {leader} de líder: {pub()}")
node = sh(K + ["get", "pod", leader, "-o", "jsonpath={.spec.nodeName}"]).stdout
sh(["docker", "exec", node, "pkill", "-9", "-f", f"server_name {leader}"])
print(f"kill -9 a {leader} ({time.strftime('%H:%M:%S')})")
time.sleep(3)
while True:
    i = info() or {}
    new = i.get("cluster", {}).get("leader")
    if new:
        break
    time.sleep(0.5)
print(f"líder: {new} ({time.strftime('%H:%M:%S')})")
print(f"la misma venta, otra vez: {pub()}")
print(f"mensajes en el stream: {info()['state']['messages']}")
