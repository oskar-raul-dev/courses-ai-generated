"""El préstamo en una línea: id, estado y pasos. Uso: loan-show.py LOAN-000001"""
import json, sys, urllib.request
req = urllib.request.Request("http://127.0.0.1:8080/inventory/loans/" + sys.argv[1], headers={"Host": "api.localhost"})
d = json.load(urllib.request.urlopen(req))
steps = "; ".join("{} {} {}".format(s["step"], s["action"], s["outcome"]) for s in d["steps"])
print(d["id"], d["status"], steps)
