#!/usr/bin/env python3
"""Cross-check the cuaderno index with each incident header: phase, category, difficulty, title; weeks and scale."""
import os, re, collections
C = os.path.join(os.environ["CURSO"], "cuaderno-incidentes.md")
s = open(C, encoding="utf-8").read()
idx = {m[0]: m[1:] for m in re.findall(r"^\| (\d\d) \| (\d+) \| (.+?) \| (.+?) \| (\S+) \| ⬜ \|$", s, re.M)}
heads = {}
for m in re.finditer(r"^## Incidente (\d\d) — (.+)\n\n> \*\*Fase:\*\* (\d+) · \*\*Categoría:\*\* (.+?) · \*\*Dificultad:\*\* (\S+)", s, re.M):
    heads[m.group(1)] = (m.group(3), m.group(2), m.group(4), m.group(5))
bad = 0
for k in sorted(set(idx) | set(heads)):
    a, b = idx.get(k), heads.get(k)
    if a != b:
        print("DIFIERE", k, a, b); bad += 1
week = lambda f: 1 if f <= 4 else 2 if f <= 8 else 3 if f <= 11 else 4
print("incidentes:", len(idx), "| encabezados:", len(heads), "| diferencias:", bad)
print("escala:", dict(collections.Counter(v[3] for v in idx.values())))
print("semanas:", dict(sorted(collections.Counter(week(int(v[0])) for v in idx.values()).items())))
