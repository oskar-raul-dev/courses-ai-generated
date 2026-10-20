#!/usr/bin/env python3
"""Extrae los bloques de código de los .md del paquete: archivo, línea, lenguaje, contenido.

Uso: extraer-bloques.py <raíz-del-paquete> [--json salida.json] [--conteo]
--conteo recalcula el inventario de §4 del plan (líneas por documento en los lenguajes contados).
"""
import json, pathlib, re, sys

CONTADOS = {"js", "javascript", "vue", "html", "json", "yaml", "yml", "sql", "css", "dockerfile", "md"}
CERCA = re.compile(r"^(\s*)(```+|~~~+)\s*([\w+-]*)")

def bloques(md):
    lineas = md.read_text(encoding="utf-8").splitlines()
    i = 0
    while i < len(lineas):
        m = CERCA.match(lineas[i])
        if m:
            sangria, cerca, lang = m.group(1), m.group(2), m.group(3).lower()
            ini = i + 1
            j = ini
            while j < len(lineas) and not lineas[j].strip().startswith(cerca[0] * len(cerca)):
                j += 1
            cuerpo = [l[len(sangria):] if l.startswith(sangria) else l for l in lineas[ini:j]]
            yield {"archivo": str(md), "linea": ini, "lang": lang, "codigo": "\n".join(cuerpo)}
            i = j + 1
        else:
            i += 1

def main():
    raiz = pathlib.Path(sys.argv[1])
    todos = []
    for md in sorted(raiz.rglob("*.md")):
        if "prompts" in md.parts or md.name.startswith("_desechable"):
            continue
        todos.extend(bloques(md))
    if "--json" in sys.argv:
        pathlib.Path(sys.argv[sys.argv.index("--json") + 1]).write_text(
            json.dumps(todos, ensure_ascii=False, indent=1), encoding="utf-8")
    if "--conteo" in sys.argv:
        por = {}
        for b in todos:
            if b["lang"] in CONTADOS:
                por[b["archivo"]] = por.get(b["archivo"], 0) + b["codigo"].count("\n") + 1
        for f, n in sorted(por.items(), key=lambda x: -x[1]):
            print(f"{n:6}  {f}")
        print(f"{sum(por.values()):6}  TOTAL ({len(todos)} bloques)")

if __name__ == "__main__":
    main()
