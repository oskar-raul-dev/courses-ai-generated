#!/usr/bin/env python3
"""Vuelca los bloques js (y el <script> de los vue) de los documentos dados a sintaxis/ para `node --check`.
Prueba tres envolturas: como módulo, dentro de una función y dentro de un objeto literal.
Uso: sintaxis.py bloques.json <prefijo-doc> [...]"""
import json, pathlib, re, sys
out = pathlib.Path("sintaxis"); out.mkdir(exist_ok=True)
for f in out.glob("*"): f.unlink()
n = 0
for b in json.load(open(sys.argv[1], encoding="utf-8")):
    nom = b["archivo"].split("/")[-1]
    if not any(nom.startswith(p) for p in sys.argv[2:]): continue
    code = b["codigo"]
    if b["lang"] == "vue":
        m = re.search(r"<script>(.*?)</script>", code, re.S)
        if not m: continue
        code = m.group(1)
    elif b["lang"] not in ("js", "javascript"): continue
    if re.match(r"\s*>", code): continue  # sesión de consola
    base = f"{nom[:-3]}_{b['linea']}"
    code2 = re.sub(r"^\s*import .*$", "", code, flags=re.M)
    code2 = re.sub(r"^\s*export default\s*", "module.exports = ", code2, flags=re.M)
    code2 = re.sub(r"^\s*export (function|var|const)", r"\1", code2, flags=re.M)
    for i, w in enumerate([code2, "function __f(){\n" + code2 + "\n}", "var __o = {\n" + code2 + "\n};", "var __a = [\n" + code2 + "\n];"]):
        (out / f"{base}.{i}.js").write_text(w, encoding="utf-8")
    n += 1
print(n, "bloques")
