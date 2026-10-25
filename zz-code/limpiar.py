#!/usr/bin/env python3
"""Libera disco en zz-code/ borrando SOLO lo regenerable: dependencias, salidas de build y salidas/ de las pruebas.

Uso:
    python3 zz-code/limpiar.py                                  # vista previa de todo zz-code/: lista y tamaños
    python3 zz-code/limpiar.py --solo a,b,c                     # vista previa solo de esos directorios
    python3 zz-code/limpiar.py --solo ruta-x/prueba-1 --borrar  # borra lo listado, y nada más
    python3 zz-code/limpiar.py <id> [<id> …]                    # igual que --solo, con los ids como argumentos
    python3 zz-code/limpiar.py <id> --conservar-salidas         # todo lo regenerable menos salidas/ (ni lo que hay dentro)

<id> es el nombre de un directorio de zz-code/ o una ruta relativa a zz-code/ (p. ej. `curso/subdirectorio`).

Reglas, que el script hace cumplir:
  - solo actúa dentro de zz-code/, y solo sobre los <id> que existen ahí (zz-code/ entero no se
    acepta como <id>: para recorrerlo, sin --solo);
  - sin --solo ni <id>, recorre todo zz-code/;
  - solo borra directorios cuyo nombre está en REGENERABLE (node_modules, target, .venv…);
  - con --conservar-salidas, salidas/ no se borra ni se recorre;
  - no sigue enlaces simbólicos ni entra en lo que va a borrar;
  - sin --borrar no toca nada.
El código fuente, el MANIFIESTO.md y los datos se quedan. Solo biblioteca estándar.
"""

import argparse
import os
import shutil
import sys

RAIZ = os.path.dirname(os.path.abspath(__file__))

REGENERABLE = {
    "salidas",                      # logs y copias de las pruebas: se rehacen corriéndolas
    "node_modules", ".pnpm-store", ".next", ".nuxt", ".angular", ".parcel-cache",
    "target", ".gradle", "build", "dist", "out",
    ".venv", "venv", "__pycache__", ".pytest_cache", ".mypy_cache", ".ruff_cache", ".tox",
    "bin", "obj",                   # .NET
    "vendor",                       # PHP (composer install) y Go (go mod vendor)
    "coverage", ".nyc_output",
}


def tamano(ruta):
    total = 0
    for base, _, archivos in os.walk(ruta):
        for a in archivos:
            try:
                total += os.lstat(os.path.join(base, a)).st_size
            except OSError:
                pass
    return total


def legible(n):
    for unidad in ("B", "KB", "MB", "GB"):
        if n < 1024:
            return f"{n:.0f} {unidad}"
        n /= 1024
    return f"{n:.1f} TB"


def candidatos(directorio, conservar=frozenset()):
    for base, dirs, _ in os.walk(directorio):
        borrables = [d for d in dirs if d in REGENERABLE and d not in conservar
                     and not os.path.islink(os.path.join(base, d))]
        for d in borrables:
            yield os.path.join(base, d)
        # no se entra en lo que se va a borrar, en lo que se conserva ni en enlaces simbólicos
        dirs[:] = [d for d in dirs if d not in REGENERABLE and not os.path.islink(os.path.join(base, d))]


def main():
    p = argparse.ArgumentParser(description="Borra solo lo regenerable dentro de zz-code/.")
    p.add_argument("ids", nargs="*", help="directorios o rutas relativas de zz-code/ (por defecto, todos)")
    p.add_argument("--solo", default="", metavar="A,B,C",
                   help="lista separada por comas de directorios o rutas relativas de zz-code/")
    p.add_argument("--borrar", action="store_true", help="borra de verdad; sin esto, solo lista")
    p.add_argument("--conservar-salidas", action="store_true",
                   help="no borra salidas/ ni entra en ella (sin esto, salidas/ se borra como regenerable)")
    p.add_argument("--raiz", default=RAIZ, help="otra raíz (solo para pruebas)")
    a = p.parse_args()

    raiz = os.path.realpath(a.raiz)
    conservar = frozenset({"salidas"}) if a.conservar_salidas else frozenset()
    pedidos = a.ids + [x.strip() for x in a.solo.split(",") if x.strip()]
    ids = pedidos or sorted(d for d in os.listdir(raiz)
                            if os.path.isdir(os.path.join(raiz, d)) and not d.startswith("."))
    objetivos = []
    for ident in ids:
        ruta = os.path.realpath(os.path.join(raiz, ident))
        dentro = os.path.commonpath([raiz, ruta]) == raiz and ruta != raiz
        if not dentro or not os.path.isdir(ruta):
            sys.exit(f"No es un directorio de zz-code/: {ident}")
        objetivos.extend(candidatos(ruta, conservar))

    # sin repetir: dos pedidos que se solapan (un padre y un hijo) dan el mismo directorio dos veces
    objetivos = list(dict.fromkeys(os.path.realpath(r) for r in objetivos))

    total = 0
    for ruta in objetivos:
        if os.path.commonpath([raiz, os.path.realpath(ruta)]) != raiz:
            sys.exit(f"Fuera de zz-code/, no se toca: {ruta}")
        t = tamano(ruta)
        total += t
        print(f"{legible(t):>10}  {os.path.relpath(ruta, raiz)}")
    print(f"{legible(total):>10}  en {len(objetivos)} directorios regenerables")

    if not a.borrar:
        print("Vista previa: no se borró nada. Para borrar, repite con --borrar.")
        return
    for ruta in objetivos:
        shutil.rmtree(ruta)
    print(f"Borrados {len(objetivos)} directorios regenerables.")


if __name__ == "__main__":
    main()
