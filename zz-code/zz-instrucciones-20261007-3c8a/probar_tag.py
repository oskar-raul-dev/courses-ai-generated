#!/usr/bin/env python3
"""Prueba TAG_DE_FASE en un curso plano y en uno con bloques (cada uno en su carpeta)."""
import os, sys
AQUI = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(AQUI, "..", "..", "zz-instrucciones", "herramientas"))
from verificador_base import Verificador  # noqa: E402

ENC = "# T\n\n> **Vigencia:** 2026-10-07.\n\n"
CURSOS = {
    "curso-plano": {
        "00-setup.md": ENC + "> 🏷️ `git tag -a fase-00-setup -m \"…\"`\n",          # bien
        "01-sin-tag.md": ENC + "sin bloque de cierre\n",                             # TAG
        "02-corto.md": ENC + "`git tag -a fase-02-corto-largo`\n",                   # TAG: otro tag
        "a01-apendice.md": ENC + "un apéndice no es capítulo\n",                     # se ignora
    },
    "curso-bloques": {
        "01-datos/01-indices.md": ENC + "`git tag -a fase-01-01-indices`\n",         # bien
        "01-datos/02-joins.md": ENC + "`git tag -a fase-02-joins`\n",                # TAG: sin bloque
    },
}
for curso, archivos in CURSOS.items():
    for rel, texto in archivos.items():
        ruta = os.path.join(AQUI, curso, rel)
        os.makedirs(os.path.dirname(ruta), exist_ok=True)
        with open(ruta, "w", encoding="utf-8") as f:
            f.write(texto)

class Plano(Verificador):
    TAG_DE_FASE = "fase-{slug}"
class ConBloques(Verificador):
    TAG_DE_FASE = "fase-{bloque}-{slug}"

for clase, curso in ((Plano, "curso-plano"), (ConBloques, "curso-bloques")):
    print(f"== {clase.__name__} sobre {curso}")
    clase(os.path.join(AQUI, curso)).correr()
