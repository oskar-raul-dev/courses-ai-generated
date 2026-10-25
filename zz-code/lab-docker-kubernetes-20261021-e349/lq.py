"""Una consulta instantánea a Loki (port-forward en 13100): lq.py '<logql>' [epoch]"""
import json, sys, urllib.parse, urllib.request
params = {"query": sys.argv[1]}
if len(sys.argv) > 2:
    params["time"] = sys.argv[2] + "000000000"
res = json.load(urllib.request.urlopen("http://127.0.0.1:13100/loki/api/v1/query?" + urllib.parse.urlencode(params)))
out = []
for r in res["data"]["result"]:
    name = r["metric"].get("service", "")
    out.append((name + "=" if name else "") + "%.0f" % float(r["value"][1]))
print(" ".join(out) or 0)
