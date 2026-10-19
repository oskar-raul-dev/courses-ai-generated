#!/usr/bin/env python3
"""Reconstruye los archivos de src/ que las fases del track base publican, tal como
quedan en el markdown. No reescribe nada: copia los bloques.

Reglas, por fase en orden (00 → 14):
  - un bloque ```ts cuya primera línea es `// src/<ruta>` sin nota es el archivo
    entero y reemplaza lo anterior;
  - si la nota dice "lo que se añade" (`// src/<ruta> — lo que se AÑADE`), se agrega
    al final de lo que había;
  - cualquier otra nota ("LA VERSIÓN QUE FALLA", "los dos casos…") es una variante y
    no entra al árbol; se lista en el informe.

Uso: python3 extraer.py [--curso RUTA] [--salida DIR] [--prefijo src/app/core/time/ ...]
Por defecto extrae core/models, core/domain, core/time y core/pdf: las funciones puras.
Con --specs suma los .spec.ts de esas carpetas (F12), para compilarlos con @types/jasmine.
"""
import argparse
import re
import sys
from pathlib import Path

AQUI = Path(__file__).resolve().parent
CURSO_POR_DEFECTO = AQUI.parents[1] / "cursos-legacy/angular-16-legacy-for-backend-devs"

CABECERA = re.compile(r"^// (src/\S+\.ts)(?:\s+—\s+(.*))?$")
FASE = re.compile(r"^\d\d-.*\.md$")


def bloques(texto):
    """Devuelve (línea_de_inicio, lenguaje, líneas) por cada bloque cercado."""
    lineas = texto.split("\n")
    i = 0
    while i < len(lineas):
        m = re.match(r"^```(\w*)\s*$", lineas[i])
        if m:
            inicio, lenguaje, cuerpo = i + 1, m.group(1), []
            i += 1
            while i < len(lineas) and not lineas[i].startswith("```"):
                cuerpo.append(lineas[i])
                i += 1
            yield inicio, lenguaje, cuerpo
        i += 1


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--curso", type=Path, default=CURSO_POR_DEFECTO)
    p.add_argument("--salida", type=Path, default=AQUI / "salidas" / "src-extraido")
    p.add_argument("--prefijo", nargs="+", default=[
        "src/app/core/models/", "src/app/core/domain/", "src/app/core/time/", "src/app/core/pdf/"])
    p.add_argument("--specs", action="store_true",
                   help="incluye los .spec.ts; en un spec, una nota cualquiera es el archivo entero")
    a = p.parse_args()

    arbol, origen, variantes = {}, {}, []
    fases = sorted(f for f in a.curso.iterdir() if FASE.match(f.name) and f.name != "00-historia-del-sistema.md")
    for fase in fases:
        for inicio, lenguaje, cuerpo in bloques(fase.read_text(encoding="utf-8")):
            if lenguaje != "ts" or not cuerpo:
                continue
            m = CABECERA.match(cuerpo[0])
            if not m or not m.group(1).startswith(tuple(a.prefijo)) or (m.group(1).endswith(".spec.ts") and not a.specs):
                continue
            ruta, nota = m.group(1), m.group(2)
            contenido = "\n".join(cuerpo) + "\n"
            sitio = f"{fase.name}:{inicio + 1}"
            if nota is None or (a.specs and ruta.endswith(".spec.ts")):
                arbol[ruta] = contenido
                origen[ruta] = [sitio]
            elif re.search(r"lo que se a[ñn]ade", nota, re.IGNORECASE):
                if ruta not in arbol:
                    variantes.append(f"{sitio} {ruta} — {nota} (sin archivo base)")
                    continue
                arbol[ruta] += "\n" + contenido
                origen[ruta].append(sitio)
            else:
                variantes.append(f"{sitio} {ruta} — {nota}")

    # Los .ts que una corrida anterior dejó y esta ya no genera se borran, uno por uno y solo
    # dentro de --salida: si no, tsc compilaría restos (pasó en T2b con core/api/).
    if a.salida.exists():
        for viejo in sorted(a.salida.rglob("*.ts")):
            if viejo.relative_to(a.salida).as_posix() not in arbol:
                viejo.unlink()
                print(f"(resto borrado) {viejo.relative_to(a.salida)}")
    for ruta, contenido in arbol.items():
        destino = a.salida / ruta
        destino.parent.mkdir(parents=True, exist_ok=True)
        destino.write_text(contenido, encoding="utf-8")
    for ruta in sorted(arbol):
        print(f"{ruta}  ←  {' + '.join(origen[ruta])}")
    for v in variantes:
        print(f"(variante, fuera del árbol) {v}")
    print(f"{len(arbol)} archivos en {a.salida}")


if __name__ == "__main__":
    main()
