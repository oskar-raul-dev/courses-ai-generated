"""a06: el primer 200 en /health/live desde docker run, tres corridas por imagen. Sin base de datos: pricing e
inventory con el SQLite de G1. Uso: arranque.py <imagen> [<imagen> …] [-e VAR=valor …]"""
import os, subprocess, sys, time, urllib.request

images = [a for a in sys.argv[1:] if not a.startswith("-e") and "=" not in a]
env = sum((["-e", a] for a in sys.argv[1:] if "=" in a), [])
PORT = 18095


def first_200(image):
    t0 = time.time()
    cid = subprocess.run(["docker", "run", "-d", "--rm", "-p", f"127.0.0.1:{PORT}:8080", *env, image],
                         capture_output=True, text=True).stdout.strip()
    try:
        while time.time() - t0 < 90:
            try:
                with urllib.request.urlopen(f"http://127.0.0.1:{PORT}" + os.environ.get("HEALTH", "/health/live"), timeout=1) as r:
                    if r.status == 200:
                        return time.time() - t0
            except Exception:
                time.sleep(0.02)
        return float("nan")
    finally:
        subprocess.run(["docker", "rm", "-f", cid], capture_output=True)
        time.sleep(1)


for image in images:
    arch = subprocess.run(["docker", "image", "inspect", image, "--format", "{{.Os}}/{{.Architecture}}"],
                          capture_output=True, text=True).stdout.strip()
    runs = sorted(first_200(image) for _ in range(3))
    print(f"{image} ({arch}): {runs[1]:.2f} s ({runs[0]:.2f}–{runs[2]:.2f})", flush=True)
