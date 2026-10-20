#!/usr/bin/env python3
"""Extrae un bloque de código de un .md por la primera línea de comentario y lo escribe tal cual.

Uso: python3 extraer-bloques.py <archivo.md> <marca de primera línea> <salida>
La marca es el comentario con que abre el bloque (p. ej. '# .devcontainer/Dockerfile').
"""
import re
import sys

md, marca, salida = sys.argv[1:4]
texto = open(md, encoding="utf-8").read()
for m in re.finditer(r"```[a-z]*\n(.*?)```", texto, re.S):
    cuerpo = m.group(1)
    if cuerpo.splitlines()[0].strip() == marca:
        open(salida, "w", encoding="utf-8").write(cuerpo)
        print(f"{salida}: {len(cuerpo.splitlines())} líneas")
        break
else:
    sys.exit(f"no hay bloque que empiece con {marca!r}")
