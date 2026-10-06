#!/usr/bin/env python3
"""Dibuja con `mmdc` cada bloque `mermaid` del curso y reporta los que no dibujan (guía §3.2 y §18.3).

Un bloque `mermaid` que GitHub no puede dibujar se ve como código suelto: es un error de la fase,
igual que un enlace roto. Este script lo detecta antes de publicar. Necesita `mmdc` (Mermaid CLI,
probado con 12.0.0, que trae Mermaid 12.1.0: hallazgo H13); si no está, avisa y sale sin error.

Uso, desde la raíz del curso:
    python3 prompts/verificar-diagramas.py                        # todo lo publicado (sin prompts/)
    python3 prompts/verificar-diagramas.py 02-modelo-entidad-relacion.md a10-notaciones-de-diagramas.md
    python3 prompts/verificar-diagramas.py --incluir-prompts      # también los ejemplos de prompts/
    python3 prompts/verificar-diagramas.py --salida DIR           # deja los .mmd y los .svg en DIR

Los bloques con `{{` (huecos de plantilla) se omiten. Sale con 1 si algún bloque no dibuja.
Solo biblioteca estándar.
"""

import os
import re
import shutil
import subprocess
import sys
import tempfile

RAIZ = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FENCE_RE = re.compile(r"^\s*(`{3,}|~{3,})\s*(\S*)")
EXCLUIR = {".git", ".venv", "node_modules", "__pycache__"}


def bloques_mermaid(ruta):
    """[(línea de apertura, texto del bloque)] de los bloques ```mermaid de un archivo."""
    salida, abierto, inicio, cuerpo, es_mermaid = [], None, 0, [], False
    with open(ruta, encoding="utf-8") as f:
        for n, linea in enumerate(f.read().split("\n"), 1):
            m = FENCE_RE.match(linea)
            if m and abierto is None:
                abierto, inicio, cuerpo, es_mermaid = m.group(1), n, [], m.group(2) == "mermaid"
                continue
            if m and abierto and m.group(1)[0] == abierto[0] and linea.strip() == m.group(1):
                if es_mermaid:
                    salida.append((inicio, "\n".join(cuerpo)))
                abierto = None
                continue
            if abierto:
                cuerpo.append(linea)
    return salida


def archivos(argumentos, incluir_prompts):
    if argumentos:
        for a in argumentos:
            ruta = os.path.join(RAIZ, a)
            if os.path.isdir(ruta):
                yield from archivos_de(ruta, True)
            else:
                yield ruta
        return
    yield from archivos_de(RAIZ, incluir_prompts)


def archivos_de(carpeta, incluir_prompts):
    for base, dirs, nombres in os.walk(carpeta):
        dirs[:] = sorted(d for d in dirs if d not in EXCLUIR and (incluir_prompts or d != "prompts"))
        for n in sorted(nombres):
            if n.endswith(".md"):
                yield os.path.join(base, n)


def main():
    args = sys.argv[1:]
    incluir_prompts = "--incluir-prompts" in args
    args = [a for a in args if a != "--incluir-prompts"]
    salida = None
    if "--salida" in args:
        i = args.index("--salida")
        salida = os.path.abspath(args[i + 1])
        del args[i:i + 2]
    mmdc = shutil.which("mmdc")
    if mmdc is None:
        print("aviso     no está mmdc (Mermaid CLI): no se dibujó ningún diagrama")
        return 0
    destino = salida or tempfile.mkdtemp(prefix="mdm-diagramas-")
    os.makedirs(destino, exist_ok=True)
    total, fallas, omitidos = 0, [], 0
    for ruta in archivos(args, incluir_prompts):
        rel = os.path.relpath(ruta, RAIZ)
        for linea, codigo in bloques_mermaid(ruta):
            if "{{" in codigo:
                omitidos += 1
                continue
            total += 1
            base = re.sub(r"[^\w.-]", "_", rel) + f"-L{linea}"
            mmd = os.path.join(destino, base + ".mmd")
            with open(mmd, "w", encoding="utf-8") as f:
                f.write(codigo + "\n")
            r = subprocess.run([mmdc, "-q", "-i", mmd, "-o", os.path.join(destino, base + ".svg")],
                               capture_output=True, text=True)
            if r.returncode != 0:
                error = next((l.strip() for l in (r.stderr + r.stdout).split("\n")
                              if l.strip().startswith(("Error", "Parse error", "Lexical error"))),
                             (r.stderr.strip().split("\n") or ["sin mensaje"])[0])
                fallas.append(f"ERROR MERMAID   {rel}:{linea} → {error[:120]}")
    for f in fallas:
        print(f)
    print(f"— {total} diagramas, {len(fallas)} no dibujan, {omitidos} omitidos por huecos de plantilla"
          f" · SVG en {destino}")
    return 1 if fallas else 0


if __name__ == "__main__":
    sys.exit(main())
