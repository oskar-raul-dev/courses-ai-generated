#!/usr/bin/env python3
"""Compara las medidas del banco de Q3. Dentro de Quasar, C tiene que ser igual a A (sin Bootstrap); en el grid de
Bootstrap, C tiene que ser igual a B. Uso: python3 -I q-banco-compara.py <dir de salidas/qbanco>
"""
import json
import os
import sys

d = sys.argv[1]  # --visual: solo márgenes, rellenos, wrap y display
M = {v: json.load(open(os.path.join(d, v + ".json"))) for v in "ABC"}

def difs(x, y, zona):
    out = []
    for a, b in zip(M[x][zona], M[y][zona]):
        assert a["cls"] == b["cls"] and a["tag"] == b["tag"], (a["cls"], b["cls"])
        ps = [p for p in a if p not in ("i", "tag", "cls") and a[p] != b[p]]
        if ps:
            out.append((a["tag"], a["cls"], {p: (a[p], b[p]) for p in ps}))
    return out

for x, y, zona, titulo in [("A", "B", "quasar", "Quasar: lo que Bootstrap cambia (A→B)"),
                           ("A", "C", "quasar", "Quasar: lo que queda distinto con el cortafuegos (A→C)"),
                           ("B", "C", "bootstrap", "Grid de Bootstrap: lo que el cortafuegos toca (B→C)")]:
    r = difs(x, y, zona)
    if "--visual" in sys.argv:
        VIS = {"margin-left", "margin-right", "margin-top", "margin-bottom", "padding-left", "padding-right",
               "padding-top", "padding-bottom", "flex-wrap", "display"}
        r = [(t, c, {p: v for p, v in ps.items() if p in VIS}) for t, c, ps in r]
        r = [x for x in r if x[2]]
    print(f"== {titulo}: {len(r)} elementos")
    for tag, cls, ps in r:
        print(f"  <{tag} class=\"{cls[:70]}\">  " + "; ".join(f"{p}: {v[0]} → {v[1]}" for p, v in ps.items()))
