#!/usr/bin/env python3
"""Inventario medido del recorrido de Cypress: una línea por forma de petición (como el jq del HAR)."""
import json, sys
log = json.load(open(sys.argv[1]))
seen = {}
for e in log:
    k = (e["port"], e["method"], e["path"], e["query"], e["body"], e["status"])
    seen.setdefault(k, [0, e])[0] += 1
print(f"# {len(log)} peticiones, {len(seen)} formas")
for (port, m, p, q, b, s), (n, e) in sorted(seen.items()):
    print(f"{port}\t{m}\t{s}\t{p}\tquery=[{q}]\tbody=[{b}]\tauth={'sí' if e['auth'] else 'no'}\trequestId={'sí' if e['requestId'] else 'no'}\tx{n}")
