"""Una consulta instantánea a Prometheus por la puerta: pq.py '<promql>'"""
import json, sys, urllib.parse, urllib.request
req = urllib.request.Request("http://127.0.0.1:8080/api/v1/query?" + urllib.parse.urlencode({"query": sys.argv[1]}),
                             headers={"Host": "prometheus.localhost"})
res = json.load(urllib.request.urlopen(req))
print(" ".join((r["metric"].get("service", "") + "=" if r["metric"].get("service") else "") + "%.2f" % float(r["value"][1])
               for r in res["data"]["result"]) or 0)
