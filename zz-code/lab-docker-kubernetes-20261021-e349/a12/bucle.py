"""a12: 1) se borra el Secret que cert-manager produjo, y cuánto tarda en reponerlo; 2) el proxy de la puerta a cero
réplicas: ¿lo devuelve Envoy Gateway? (60 s mirando), y cuánto tarda la puerta en contestar al devolverle la réplica."""
import subprocess, time, urllib.request

K = ["kubectl", "--context", "kind-lab"]


def sh(*a):
    return subprocess.run(list(a), capture_output=True, text=True).stdout.strip()


sh(*K, "-n", "default", "delete", "secret", "a12-prueba-tls")
t0 = time.time()
while not sh(*K, "-n", "default", "get", "secret", "a12-prueba-tls", "-o", "name", "--ignore-not-found"):
    time.sleep(0.05)
print(f"cert-manager lo repuso en {time.time() - t0:.1f} s")
ev = sh(*K, "-n", "default", "get", "events", "--field-selector", "involvedObject.name=a12-prueba", "--sort-by=.lastTimestamp",
        "-o", "custom-columns=R:.reason,M:.message", "--no-headers")
print("\n".join(ev.splitlines()[-3:]))


def door():
    try:
        req = urllib.request.Request("http://127.0.0.1:8080/pricing/health/live", headers={"Host": "api.localhost"})
        with urllib.request.urlopen(req, timeout=1) as r:
            return r.status
    except Exception:
        return None


proxy = sh(*K, "-n", "gateway", "get", "deploy", "-l", "gateway.envoyproxy.io/owning-gateway-name=lab", "-o", "name")
print(f"$ kubectl -n gateway scale {proxy} --replicas=0")
sh(*K, "-n", "gateway", "scale", proxy, "--replicas=0")
time.sleep(60)
print(f"a los 60 s: réplicas {sh(*K, '-n', 'gateway', 'get', proxy, '-o', 'jsonpath={.spec.replicas}')}, la puerta {door()}")
managers = sh(*K, "-n", "gateway", "get", proxy, "-o", "jsonpath={range .metadata.managedFields[*]}{.manager} {.operation} "
              "{.subresource}{'\\n'}{end}")
print("dueños de campos:\n" + managers)
replicas_owner = sh(*K, "-n", "gateway", "get", proxy, "-o", "json", "--show-managed-fields")
print("¿envoy-gateway declara spec.replicas?", '"f:replicas"' in replicas_owner.split('"manager": "envoy-gateway"')[0][-4000:])
sh(*K, "-n", "gateway", "scale", proxy, "--replicas=1")
t0 = time.time()
while door() != 200:
    time.sleep(0.1)
print(f"devuelta la réplica a mano: la puerta contestó a los {time.time() - t0:.1f} s")
