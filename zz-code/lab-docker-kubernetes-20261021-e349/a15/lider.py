"""a15: el publicador 47 s; a los 10 s se mata al líder del stream A15 (delete | kill9 | quorum). Al final: fallidas,
el hueco, y si alguna confirmada se perdió o alguna fallida quedó guardada. Uso: lider.py delete|kill9|quorum"""
import json, subprocess, sys, threading, time

mode = sys.argv[1]
K = ["kubectl", "--context", "kind-lab", "-n", "data"]
S = "nats://nats-ha.data.svc.cluster.local:4222"
box = K + ["exec", "a15-nats-box", "--", "nats", "-s", S]


def sh(cmd):
    return subprocess.run(cmd, capture_output=True, text=True).stdout


def info():
    for _ in range(30):
        out = sh(box + ["stream", "info", "A15", "-j"])
        try:
            return json.loads(out)
        except ValueError:
            time.sleep(1)
    return {}


sh(box + ["stream", "purge", "A15", "-f"])
leader = info()["cluster"]["leader"]
pre = f"{mode}-{int(time.time())}"
lines = []


def publish():
    p = subprocess.Popen(K + ["exec", "a15-nats-box", "--", "sh", "/tmp/publicar.sh", "47", pre], stdout=subprocess.PIPE, text=True)
    for l in p.stdout:
        lines.append(l.split())


t = threading.Thread(target=publish)
t.start()
time.sleep(10)
if mode == "delete":
    print(f"+10 s: kubectl delete pod {leader}")
    sh(K + ["delete", "pod", leader, "--wait=false"])
elif mode == "kill9":
    node = sh(K + ["get", "pod", leader, "-o", "jsonpath={.spec.nodeName}"])
    print(f"+10 s: docker exec {node} pkill -9 -f 'server_name {leader}' (líder: {leader})")
    sh(["docker", "exec", node, "pkill", "-9", "-f", f"server_name {leader}"])
else:
    print("+10 s: kubectl scale statefulset nats-ha --replicas=1, 25 s")
    sh(K + ["scale", "statefulset", "nats-ha", "--replicas=1"])
    time.sleep(25)
    print(f"+35 s: nats-ha-0 /healthz: {sh(K + ['exec', 'nats-ha-0', '--', 'wget', '-S', '-qO-', 'http://127.0.0.1:8222/healthz']).strip()[:60] or '503 (wget sin cuerpo)'}")
    sh(K + ["scale", "statefulset", "nats-ha", "--replicas=3"])
t.join()
ok = [l for l in lines if len(l) > 2 and l[2] == "ok"]
bad = [l for l in lines if len(l) > 2 and l[2] != "ok"]
time.sleep(5)
st = info()
stored = st.get("state", {}).get("messages")
print(f"publicaciones: {len(lines)} · confirmadas: {len(ok)} · fallidas: {len(bad)}"
      + (f" (de +{bad[0][0]} a +{bad[-1][0]} s; hueco {float(bad[-1][0]) - float(bad[0][0]):.1f} s)" if bad else ""))
errs = sorted({" ".join(l[3:6]) for l in bad})
if errs:
    print("errores:", " | ".join(errs[:3]))
print(f"en el stream: {stored} · confirmadas perdidas: {max(0, len(ok) - (stored or 0))} · "
      f"guardadas sin confirmar: {max(0, (stored or 0) - len(ok))} · líder nuevo: {st.get('cluster', {}).get('leader')}")
