#!/usr/bin/env python3
"""Compara dos styles.css de ng build (p. ej. node-sass frente a Dart Sass) y el CSS del componente.

Normaliza lo que es solo forma (comentarios, espacios, ceros a la izquierda, ';' final) y lista lo
que queda distinto, regla por regla. Uso: python3 -I t0-css-compara.py <dist A> <dist B>
"""
import re
import sys


def norm(s):
    s = re.sub(r"/\*.*?\*/", "", s, flags=re.S)
    s = re.sub(r"\s+", " ", s)
    s = re.sub(r"\s*([{};:,>])\s*", r"\1", s)
    s = re.sub(r"(?<![\w.])0\.(\d)", r".\1", s)
    s = re.sub(r'\[([\w-]+)([~^$*|]?=)"([\w-]+)"\]', r"[\1\2\3]", s)
    s = s.replace(";}", "}")
    return s


def reglas(s):
    return [r + "}" for r in norm(s).split("}") if r.strip()]


def componente(dist):
    js = open(f"{dist}/main-es2015.js", encoding="utf-8").read()
    m = re.search(r'"([^"]*patient-form-footer[^"]*)"', js)
    css = m.group(1).replace("\\n", "\n") if m else ""
    return re.sub(r"/\*# sourceMappingURL.*?\*/", "", css)


a, b = sys.argv[1], sys.argv[2]
ca, cb = (open(f"{d}/styles.css", encoding="utf-8").read() for d in (a, b))
print(f"bytes: {len(ca)} / {len(cb)}")
ra, rb = reglas(ca), reglas(cb)
print(f"reglas: {len(ra)} / {len(rb)} · normalizado idéntico: {norm(ca) == norm(cb)}")
sa, sb = set(ra), set(rb)
print(f"solo en A: {len(sa - sb)} · solo en B: {len(sb - sa)}")
sel = lambda r: r.split("{")[0]
ia = {sel(r): r for r in sa - sb}
ib = {sel(r): r for r in sb - sa}
for k in sorted(set(ia) | set(ib)):
    print("A", ia.get(k, "(no está)")[:300])
    print("B", ib.get(k, "(no está)")[:300])
na, nb = norm(componente(a)), norm(componente(b))
print(f"componente: {len(na)} / {len(nb)} · normalizado idéntico: {na == nb}")
if na != nb:
    print("A", na[:400]); print("B", nb[:400])
