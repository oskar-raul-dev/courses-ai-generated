"""Marca una sección como probada: encabezado y rótulos. Uso: python3 probado.py <seccion.md> [parcial: texto]"""
import pathlib, sys
CARTA = pathlib.Path("/Users/oskar/Developer/Learning/courses-ia-generated/cursos-algoritmos-lenguajes/python-for-java-devs")
p = CARTA / sys.argv[1]
t = p.read_text(encoding="utf-8")
OLD = "> Versiones verificadas contra PyPI el 05/10/2026 · Código escrito sin ejecutar: las salidas\n> rotuladas «Salida esperada, sin correr» no salen de una corrida."
NEW = "> Versiones verificadas contra PyPI el 05/10/2026 · Código probado el 05/10/2026 con Python 3.14.7,\n> en contenedor: las salidas son las de esa corrida."
assert OLD in t, "el encabezado no es el estándar"
t = t.replace(OLD, NEW).replace("Salida esperada, sin correr", "Salida (Python 3.14.7, 05/10/2026)")
p.write_text(t, encoding="utf-8")
print("probado:", p.name)
