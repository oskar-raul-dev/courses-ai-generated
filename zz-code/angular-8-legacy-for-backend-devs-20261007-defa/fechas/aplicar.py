#!/usr/bin/env python3
"""Apply the old -> new literal mapping from tabla.json to the given course files, in place.

Usage: CURSO=<course dir> python3 fechas/aplicar.py <relative file> [...]
Replaces only exact literals listed in tabla.json (longest first), and prints a count per file.
"""
import json, os, re, sys
CURSO = os.environ.get("CURSO") or sys.exit("set CURSO")
here = os.path.dirname(os.path.abspath(__file__))
pairs = {r["viejo"]: r["nuevo"] for r in json.load(open(os.path.join(here, "tabla.json"))) if r["viejo"] != r["nuevo"]}
keys = sorted(pairs, key=len, reverse=True)
pat = re.compile("|".join(re.escape(k) + r"(?![\d:.T])" for k in keys))
for rel in sys.argv[1:]:
    p = os.path.join(CURSO, rel)
    s = open(p, encoding="utf-8").read()
    n = len(pat.findall(s))
    s = pat.sub(lambda m: pairs[m.group(0)], s)
    open(p, "w", encoding="utf-8").write(s)
    print(f"{n:3d}  {rel}")
