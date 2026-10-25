"""F27 criterio 4: tráfico continuo por la puerta a /notify/notifications (4 clientes) mientras corre
kubectl rollout restart deploy/notify, y 10 s más después de que el rollout termina. Cuenta las respuestas."""
import collections, subprocess, threading, time, urllib.request

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


threads = [threading.Thread(target=client) for _ in range(4)]
for t in threads:
    t.start()
time.sleep(3)
K = ["kubectl", "--context", "kind-lab", "-n", "apps"]
t0 = time.time()
subprocess.run(K + ["rollout", "restart", "deploy/notify"], capture_output=True)
subprocess.run(K + ["rollout", "status", "deploy/notify", "--timeout=120s"], capture_output=True)
print(f"rollout: {time.time() - t0:.1f} s")
time.sleep(10)
done.set()
for t in threads:
    t.join()
print(f"respuestas durante el rollout: {dict(codes)}")
