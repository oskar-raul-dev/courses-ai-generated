#!/usr/bin/env python3
"""Inserta (o reemplaza) '### Resultados de REF-1 (fecha)' antes del '### Veredicto' de una entrada.
Uso: python3 ref1.py B-02 archivo-con-el-texto.md"""
import re, sys
B = "../../cursos-algoritmos-lenguajes/go-for-java-devs/BENCHMARKS.md"
ent, src = sys.argv[1], sys.argv[2]
s = open(B, encoding="utf-8").read()
a = s.index(f"## {ent} ")
nxt = s.find("\n## B-", a + 5); nxt = len(s) if nxt < 0 else nxt
sec = s[a:nxt]
sec = re.sub(r"### Resultados de REF-1.*?(?=### )", "", sec, flags=re.S)
body = open(src, encoding="utf-8").read().strip() + "\n\n"
i = sec.index("### Veredicto")
sec = sec[:i] + "### Resultados de REF-1 (14/11/2026)\n\n" + body + sec[i:]
open(B, "w", encoding="utf-8").write(s[:a] + sec + s[nxt:])
print("ok", ent)
