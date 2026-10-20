#!/usr/bin/env python3
"""Identificadores entre backticks en la sección de ejercicios que no aparecen ni en el repo ni en el código del documento.
Uso: ejercicios-ids.py bloques.json <doc.md> <dir-repo> [...]"""
import json, pathlib, re, sys
bl = json.load(open(sys.argv[1], encoding="utf-8")); doc = pathlib.Path(sys.argv[2])
corpus = "\n".join(b["codigo"] for b in bl if b["archivo"].endswith(doc.name))
for d in sys.argv[3:]:
    for f in pathlib.Path(d).rglob("*"):
        if f.is_file() and f.suffix in {".js", ".vue", ".json"} and "node_modules" not in f.parts and "dist" not in f.parts:
            corpus += "\n" + f.name + "\n" + f.read_text(encoding="utf-8", errors="ignore")
txt = doc.read_text(encoding="utf-8")
i = txt.find("## 🧪 Ejercicios")
if i < 0: sys.exit()
ej = txt[i:]
j = re.search(r"\n## (?!🧪)", ej); ej = ej[: j.start()] if j else ej
vistos = set()
for m in re.finditer(r"`([A-Za-z_$][\w$]*(?:\.(?:vue|js))?)(?:\(\))?`", ej):
    t = m.group(1)
    if t in vistos or len(t) < 5 or not (re.search(r"[a-z][A-Z]", t) or t.endswith((".vue", ".js"))): continue
    vistos.add(t)
    if t not in corpus:
        print(f"{doc.name}: `{t}`")
