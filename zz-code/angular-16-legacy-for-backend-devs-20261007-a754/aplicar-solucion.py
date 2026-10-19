#!/usr/bin/env python3
"""Aplica la solución de referencia de un incidente del cuaderno, TAL COMO ESTÁ
PUBLICADA, sobre una copia del árbol extraído de la fase. No reescribe nada.

Dentro de la sección `## Incidente NN` del cuaderno, en orden:
  - ```diff cuya primera línea es `// src/<ruta>`: cada trozo (separados por líneas
    `@@`) es contexto (' '), quitado ('-') y puesto ('+'); el texto viejo tiene que
    aparecer exactamente una vez en el archivo, o se aborta;
  - ```ts cuya cabecera es `// src/<ruta> — lo que añade el fix…`: se agrega al final;
  - ```ts cuya cabecera es `// src/<ruta> — nuevo…`: se escribe como archivo nuevo
    (aborta si ya existía en la fase);
  - el mismo ```diff con cabecera HTML (`<!-- src/<ruta> -->`) para las plantillas;
  - ```ts cuya cabecera es `// src/<ruta>.spec.ts — …`: se escribe como
    `<ruta>.incidente-NN.spec.ts`, para no pisar el spec de la fase.
Lo demás (```js de las conversiones, ```bash) no se toca.

Uso: python3 aplicar-solucion.py CUADERNO NN ARBOL_BASE ARBOL_SALIDA
"""
import re
import shutil
import sys
from pathlib import Path

cuaderno, nn, base, salida = Path(sys.argv[1]), sys.argv[2], Path(sys.argv[3]), Path(sys.argv[4])

texto = cuaderno.read_text(encoding="utf-8")
inicio = re.search(rf"^## Incidente {nn} — .*$", texto, re.M)
if not inicio:
    sys.exit(f"no está el incidente {nn}")
fin = re.search(r"^## ", texto[inicio.end():], re.M)
seccion = texto[inicio.start(): inicio.end() + (fin.start() if fin else len(texto))]
solucion = seccion[seccion.index("Solución de referencia"):]

# Copia archivo por archivo (sin borrar nada: la salida tiene que estar vacía o no existir).
if salida.exists() and any(salida.rglob("*.ts")):
    sys.exit(f"{salida} ya tiene archivos: usa un directorio nuevo")
for f in base.rglob("*"):
    if not f.is_file():
        continue
    destino = salida / f.relative_to(base)
    destino.parent.mkdir(parents=True, exist_ok=True)
    shutil.copyfile(f, destino)

def bloques(t):
    for m in re.finditer(r"^```(\w*)\n(.*?)^```$", t, re.M | re.S):
        yield m.group(1), m.group(2).rstrip("\n").split("\n")

for lenguaje, lineas in bloques(solucion):
    cab = (re.match(r"^// (src/\S+)(?:\s+—\s+(.*))?$", lineas[0])
           or re.match(r"^<!-- (src/\S+) -->$", lineas[0]))
    if not cab:
        continue
    ruta = cab.group(1)
    nota = (cab.group(2) if cab.re.groups > 1 else None) or ""
    destino = salida / ruta
    if lenguaje == "diff":
        actual = destino.read_text(encoding="utf-8")
        trozos, trozo = [], []
        for l in lineas[1:]:
            if l.startswith("@@"):
                trozos.append(trozo); trozo = []
            else:
                trozo.append(l)
        trozos.append(trozo)
        for t in trozos:
            viejo = [l[1:] for l in t if l[:1] in (" ", "-") or l == ""]
            nuevo = [l[1:] for l in t if l[:1] in (" ", "+") or l == ""]
            v, n = "\n".join(viejo), "\n".join(nuevo)
            veces = actual.count(v)
            if veces != 1:
                sys.exit(f"{ruta}: el trozo aparece {veces} veces:\n{v}")
            actual = actual.replace(v, n)
        destino.write_text(actual, encoding="utf-8")
        print(f"diff aplicado  {ruta} ({len(trozos)} trozos)")
    elif lenguaje == "ts" and ruta.endswith(".spec.ts"):
        spec = destino.with_name(destino.name.replace(".spec.ts", f".incidente-{nn}.spec.ts"))
        spec.parent.mkdir(parents=True, exist_ok=True)
        spec.write_text("\n".join(lineas) + "\n", encoding="utf-8")
        print(f"spec escrito   {spec.relative_to(salida)}")
    elif lenguaje == "ts" and re.match(r"nuevo\b", nota):
        if destino.exists():
            sys.exit(f"{ruta}: la solución dice «nuevo» y el archivo ya existe en la fase")
        destino.parent.mkdir(parents=True, exist_ok=True)
        destino.write_text("\n".join(lineas) + "\n", encoding="utf-8")
        print(f"nuevo          {ruta}")
    elif lenguaje == "ts" and re.search(r"lo que añade", nota):
        destino.write_text(destino.read_text(encoding="utf-8") + "\n" + "\n".join(lineas) + "\n", encoding="utf-8")
        print(f"añadido        {ruta}")
