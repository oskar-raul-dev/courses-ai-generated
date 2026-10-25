"""Veinte reposiciones de 1 unidad a la vez por la puerta; compara la existencia final con 20."""
import json, sys, urllib.request
from concurrent.futures import ThreadPoolExecutor
B = "http://api.localhost:8080/inventory"
def call(method, path, body=None):
    req = urllib.request.Request(B + path, method=method, data=json.dumps(body).encode() if body else None,
                                 headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req) as r: return r.status, json.loads(r.read())
    except urllib.error.HTTPError as e: return e.code, None
store, sku = sys.argv[1], sys.argv[2]
call("POST", f"/stock/{store}/{sku}/movements", {"type": "COUNT", "quantity": 0, "reference": "carrera"})
with ThreadPoolExecutor(20) as ex:
    codes = list(ex.map(lambda _: call("POST", f"/stock/{store}/{sku}/movements", {"type": "RESTOCK", "quantity": 1})[0], range(20)))
q = call("GET", f"/stock/{store}/{sku}")[1]["quantity"]
print(f"respuestas: { {str(c): codes.count(c) for c in set(codes)} }; después: {q} (se esperaban 20)")
