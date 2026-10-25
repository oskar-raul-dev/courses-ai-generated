"""a08: listo (primer 200 en /health/ready), la memoria de docker stats 10 s después, y otra vez después de 1.000
peticiones (500 movimientos y 500 lecturas). Tres corridas por imagen, sin base (SQLite de G1), sin el agente de
OpenTelemetry y sin límite de memoria. Uso: medir.py <imagen> [<imagen> …]"""
import json, statistics, subprocess, sys, time, urllib.request

PORT = 18097


def call(method, path, body=None):
    req = urllib.request.Request(f"http://127.0.0.1:{PORT}{path}", data=json.dumps(body).encode() if body else None,
                                 method=method, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=5) as r:
        return r.status


def mem(cid):
    out = subprocess.run(["docker", "stats", "--no-stream", "--format", "{{.MemUsage}}", cid], capture_output=True, text=True).stdout
    v = out.split("/")[0].strip()
    return float(v[:-3]) * (1024 if v.endswith("GiB") else 1)


def run(image):
    t0 = time.time()
    cid = subprocess.run(["docker", "run", "-d", "--rm", "-p", f"127.0.0.1:{PORT}:8080", "-e", "OTEL_JAVAAGENT_ENABLED=false",
                          image], capture_output=True, text=True).stdout.strip()
    try:
        while True:
            try:
                if call("GET", "/health/ready") == 200:
                    ready = time.time() - t0
                    break
            except Exception:
                time.sleep(0.01)
        time.sleep(10)
        rest = mem(cid)
        for i in range(500):
            call("POST", "/stock/DRO-001/SKU-0001/movements", {"type": "RESTOCK", "quantity": 1, "reference": f"a08-{i}"})
            call("GET", "/stock/DRO-001/SKU-0001")
        return ready, rest, mem(cid)
    finally:
        subprocess.run(["docker", "rm", "-f", cid], capture_output=True)
        time.sleep(1)


fmt = lambda xs, f: f"{f(statistics.median(xs))} ({f(min(xs))}–{f(max(xs))})"
for image in sys.argv[1:]:
    rs = [run(image) for _ in range(3)]
    print(f"{image}: listo {fmt([r[0] for r in rs], lambda v: f'{v:.2f} s')} · reposo "
          f"{fmt([r[1] for r in rs], lambda v: f'{v:.0f} MiB')} · después de 1.000 {fmt([r[2] for r in rs], lambda v: f'{v:.0f} MiB')}",
          flush=True)
