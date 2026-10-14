#!/usr/bin/env python3
"""Scan the course markdown for date/time literals and write fechas/inventario.json.

Usage: CURSO=<course dir> python3 fechas/inventario.py
Each entry: file, line, literal. Skips the disposable plan and the deprecated tutorial.
"""
import json, os, re, sys
CURSO = os.environ.get("CURSO") or sys.exit("set CURSO")
PAT = re.compile(r"20\d\d-\d\d-\d\d(?:T\d\d:\d\d(?::\d\d(?:\.\d+)?)?)?(?:Z|[+-]\d\d:?\d\d)?")
SKIP = ("_desechable", "_deprecado")
out = []
for root, _, files in os.walk(CURSO):
    for f in sorted(files):
        if not f.endswith(".md") or any(s in f for s in SKIP):
            continue
        p = os.path.join(root, f)
        rel = os.path.relpath(p, CURSO)
        for n, line in enumerate(open(p, encoding="utf-8"), 1):
            for m in PAT.finditer(line):
                out.append({"file": rel, "line": n, "literal": m.group(0)})
here = os.path.dirname(os.path.abspath(__file__))
json.dump(out, open(os.path.join(here, "inventario.json"), "w"), indent=1, ensure_ascii=False)
print(len(out), "literals")
