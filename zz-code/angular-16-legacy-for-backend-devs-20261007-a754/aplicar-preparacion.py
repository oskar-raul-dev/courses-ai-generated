#!/usr/bin/env python3
"""Aplica el primer ```diff de la receta `### `incidente/NN`` de preparaciones, tal
como está publicado, a un archivo de una copia del árbol. Las líneas ' ' son
contexto, '-' se quitan y '+' se ponen; el texto viejo debe aparecer una sola vez.
Uso: python3 aplicar-preparacion.py PREPARACIONES NN RUTA ARBOL_BASE ARBOL_SALIDA"""
import re
import shutil
import sys
from pathlib import Path

prep, nn, ruta, base, salida = Path(sys.argv[1]), sys.argv[2], sys.argv[3], Path(sys.argv[4]), Path(sys.argv[5])
texto = prep.read_text(encoding="utf-8")
i = texto.index(f"### `incidente/{nn}`")
fin = texto.find("\n### ", i + 1)
m = re.search(r"^```diff\n(.*?)^```$", texto[i:fin], re.M | re.S)
lineas = m.group(1).rstrip("\n").split("\n")
viejo = "\n".join(l[1:] for l in lineas if l[:1] in (" ", "-"))
nuevo = "\n".join(l[1:] for l in lineas if l[:1] in (" ", "+"))
if salida.exists() and any(salida.rglob("*.ts")):
    sys.exit(f"{salida} ya tiene archivos")
for f in base.rglob("*"):
    if f.is_file():
        d = salida / f.relative_to(base); d.parent.mkdir(parents=True, exist_ok=True); shutil.copyfile(f, d)
archivo = salida / ruta
actual = archivo.read_text(encoding="utf-8")
if actual.count(viejo) != 1:
    sys.exit(f"{ruta}: el diff de la receta {nn} aparece {actual.count(viejo)} veces")
archivo.write_text(actual.replace(viejo, nuevo), encoding="utf-8")
print(f"preparación {nn} aplicada a {ruta}")
