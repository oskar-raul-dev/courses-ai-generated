#!/usr/bin/env python3
"""Reemplaza en A13 el cuerpo de §6 (desde el primer bloque ```dockerfile hasta el bullet de la "ruta corta")
por a13-s6-borrador.md, con el Dockerfile y el devcontainer.json probados insertados byte a byte.
Uso: python3 -I t2-armar-a13.py <a13-docker-colima.md>
"""
import os
import sys

aqui = os.path.dirname(os.path.abspath(__file__))
md = sys.argv[1]
texto = open(md, encoding="utf-8").read()
devc = os.path.join(aqui, "devc/clinical-lab/.devcontainer")
nuevo = open(os.path.join(aqui, "a13-s6-borrador.md"), encoding="utf-8").read()
nuevo = nuevo.replace("@@DOCKERFILE@@", open(f"{devc}/Dockerfile", encoding="utf-8").read())
nuevo = nuevo.replace("@@DEVCONTAINER@@", open(f"{devc}/devcontainer.json", encoding="utf-8").read())
s6 = texto.index("## 6. Un devcontainer")
ini = texto.index("```dockerfile\n# .devcontainer/Dockerfile", s6)
fin_marca = "si quieres trabajar, esto es lo que hay.\n"
fin = texto.index(fin_marca, ini) + len(fin_marca)
open(md, "w", encoding="utf-8").write(texto[:ini] + nuevo + texto[fin:])
print(f"§6: reemplazados {texto[ini:fin].count(chr(10))} renglones por {nuevo.count(chr(10))}")
