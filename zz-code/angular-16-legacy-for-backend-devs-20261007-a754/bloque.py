#!/usr/bin/env python3
"""Copia un bloque cercado del markdown, tal cual, a un archivo. El bloque se busca
por su primera línea exacta (la cabecera `// src/…`). Con --antes, antepone el
contenido de otro archivo (los import que un bloque-fragmento no trae); con --despues,
lo agrega al final. Uso: python3 bloque.py MD "CABECERA" DESTINO [--antes F] [--despues F]"""
import argparse
import re
from pathlib import Path

p = argparse.ArgumentParser()
p.add_argument("md", type=Path); p.add_argument("cabecera"); p.add_argument("destino", type=Path)
p.add_argument("--antes", type=Path); p.add_argument("--despues", type=Path)
a = p.parse_args()
texto = a.md.read_text(encoding="utf-8")
m = re.search(r"^```\w*\n" + re.escape(a.cabecera) + r"\n(.*?)^```$", texto, re.M | re.S)
if not m:
    raise SystemExit(f"no está el bloque «{a.cabecera}» en {a.md}")
cuerpo = a.cabecera + "\n" + m.group(1)
if a.antes:
    cuerpo = a.antes.read_text(encoding="utf-8") + cuerpo
if a.despues:
    cuerpo = cuerpo + a.despues.read_text(encoding="utf-8")
a.destino.parent.mkdir(parents=True, exist_ok=True)
a.destino.write_text(cuerpo, encoding="utf-8")
print(f"bloque «{a.cabecera[:70]}» → {a.destino}")
