#!/usr/bin/env python3
"""T1 closing check: every date literal in the base track is in tabla.json (new side), is the kept v1 start,
or is one of the deliberate UTC borders of incident 07. Usage: CURSO=<course> python3 fechas/cierre-t1.py"""
import json, os, re, sys
CURSO = os.environ["CURSO"]
here = os.path.dirname(os.path.abspath(__file__))
ok = {r["nuevo"] for r in json.load(open(os.path.join(here, "tabla.json")))}
ok |= {"2021-12-31T23:59:59Z", "2022-01-01T00:00:00Z",          # incident 07: the borders loaded in UTC
       "2021-12-31T18:59:00-05:00", "2021-12-31T19:00:00-05:00",   # incident 07 regression spec
       "2022-01-15", "2021-12-15"}
PAT = re.compile(r"20(?:19|2[0-2])-\d\d-\d\d(?:T\d\d:\d\d(?::\d\d(?:\.\d+)?)?)?(?:Z|[+-]\d\d:?\d\d)?")
bad = 0
for root, _, files in os.walk(CURSO):
    for f in sorted(files):
        rel = os.path.relpath(os.path.join(root, f), CURSO)
        if not f.endswith(".md") or "_desechable" in f or "_deprecado" in f or re.match(r"(be\d|bea-|cuaderno-incidentes-be)", f):
            continue
        for n, line in enumerate(open(os.path.join(root, f), encoding="utf-8"), 1):
            for m in PAT.finditer(line):
                lit = m.group(0)
                # incident 22 (T4): the DST week of March 2021, summer marks with -05:00 on purpose;
                # they are checked by sondas/angular8/inc22/verificar.js, not by this table.
                if lit[:10] in ("2021-03-12", "2021-03-15"):
                    continue
                if lit not in ok and lit[:10] not in ok and lit != "2019-11-08T14:22:31.104Z":
                    print(f"FUERA DE TABLA {rel}:{n} {lit}"); bad += 1
print("base track:", bad, "fuera de tabla")
