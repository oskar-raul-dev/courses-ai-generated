#!/usr/bin/env python3
"""Pone (o reemplaza) la línea fechada de la regla 5 del plan antes de '## 💻 6.' de una fase.
Uso: python3 nota-fechada.py FASE.md "texto de la nota (sin el > inicial)" """
import re, sys, textwrap
p, texto = sys.argv[1], sys.argv[2]
s = open(p, encoding="utf-8").read()
nota = "\n".join("> " + l for l in textwrap.wrap("📝 " + texto, 80)) + "\n\n"
s = re.sub(r"> 📝 \*\*Las salidas de esta fase se corrieron.*?\n\n", "", s, flags=re.S)
i = s.index("---\n\n## 💻 6.")
s = s[:i] + nota + s[i:]
open(p, "w", encoding="utf-8").write(s)
