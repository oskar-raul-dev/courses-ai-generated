"""F27 criterio 6: la readiness de notify en una ruta que no existe, desplegada con task deploy (--rollback-on-failure)
mientras dos clientes piden /notify/notifications por la puerta. Cuenta las respuestas y mide hasta el rollback."""
import collections, os, pathlib, subprocess, threading, time, urllib.request

LAB = pathlib.Path(__file__).parent / "mi-lab/src/lab"
VALUES = LAB / "charts/platform/charts/notify/values.yaml"
done = threading.Event()
codes = collections.Counter()
lock = threading.Lock()


def client():
    while not done.is_set():
        req = urllib.request.Request("http://127.0.0.1:8080/notify/notifications", headers={"Host": "api.localhost"})
        try:
            with urllib.request.urlopen(req, timeout=5) as r:
                c = r.status
        except urllib.error.HTTPError as e:
            c = e.code
        except Exception as e:
            c = type(e).__name__
        with lock:
            codes[c] += 1
        time.sleep(0.05)


original = VALUES.read_text()
VALUES.write_text(original.replace("readiness: {path: /health/ready,", "readiness: {path: /health/readyz,"))
threads = [threading.Thread(target=client) for _ in range(2)]
for t in threads:
    t.start()
t0 = time.time()
try:
    out = subprocess.run(["task", "deploy", "FORCE=true", "CLUSTER=lab", "--", "minimo"], cwd=LAB, capture_output=True, text=True)
finally:
    VALUES.write_text(original)
elapsed = time.time() - t0
done.set()
for t in threads:
    t.join()
lines = [l for l in (out.stdout + out.stderr).splitlines() if "symbolic link" not in l]
print("\n".join(lines[-6:]))
print(f"task deploy terminó en {int(elapsed // 60)} min {int(elapsed % 60)} s, código {out.returncode}")
print(f"respuestas durante el incidente: {dict(codes)}")
ev = subprocess.run(["kubectl", "--context", "kind-lab", "-n", "apps", "get", "events", "--sort-by=.lastTimestamp",
                     "--field-selector", "involvedObject.kind=Pod"], capture_output=True, text=True).stdout
print("\n".join(l for l in ev.splitlines() if "notify" in l and "Readiness" in l)[-3:] or "")
print(subprocess.run(["helm", "--kube-context", "kind-lab", "-n", "apps", "history", "lab", "--max", "3"],
                     capture_output=True, text=True).stdout)
