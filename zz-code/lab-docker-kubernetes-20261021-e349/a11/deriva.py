"""a11: kubectl scale a 3 sobre lo que Argo CD gestiona, y cuánto tarda en volver a 1 (selfHeal). Tres corridas."""
import subprocess, time

K = ["kubectl", "--context", "kind-lab", "-n", "a11-guestbook"]
for i in range(3):
    subprocess.run(K + ["scale", "deploy/guestbook-ui", "--replicas=3"], capture_output=True)
    t0 = time.time()
    while True:
        r = subprocess.run(K + ["get", "deploy/guestbook-ui", "-o", "jsonpath={.spec.replicas}"], capture_output=True, text=True).stdout
        if r == "1":
            break
        time.sleep(0.05)
    print(f"Argo CD devolvió replicas a 1 en {time.time() - t0:.1f} s", flush=True)
    time.sleep(3)
