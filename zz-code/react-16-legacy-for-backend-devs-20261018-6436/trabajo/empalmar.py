#!/usr/bin/env python3
"""Reemplaza en el cuaderno la sección de un incidente por el archivo dado.
Uso: empalmar.py <cuaderno.md> <id> <archivo.md>
La sección va desde '## Incidente <id> ' hasta el siguiente '## Incidente ' (o un título '# ' de nivel 1),
sin contar lo que está dentro de bloques de código."""
import re, sys
cuaderno, ident, archivo = sys.argv[1:4]
lines = open(cuaderno, encoding="utf-8").read().split("\n")
nuevo = open(archivo, encoding="utf-8").read().rstrip("\n").split("\n")
inicio = fin = None
fence = False
for i, l in enumerate(lines):
    if l.startswith("```"):
        fence = not fence
        continue
    if fence:
        continue
    if inicio is None and re.match(r"## Incidente " + re.escape(ident) + r"\b", l):
        inicio = i
    elif inicio is not None and (l.startswith("## Incidente ") or re.match(r"# \S", l)):
        fin = i
        break
if inicio is None: sys.exit(f"no encontré la sección de {ident}")
fin = fin if fin is not None else len(lines)
lines[inicio:fin] = nuevo + [""]
open(cuaderno, "w", encoding="utf-8").write("\n".join(lines))
print(f"{ident}: líneas {inicio+1}–{fin} → {len(nuevo)} líneas")
