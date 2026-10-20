#!/usr/bin/env python3
"""Compara cada bloque de código de un documento con una o más instantáneas del repo del alumno.

Uso: comparar.py bloques.json <sufijo-del-documento> <dir-instantánea> [<dir2> ...]
Por bloque: el archivo del repo que más líneas comparte y las líneas que no aparecen en él.
Se ignoran líneas vacías, elisiones (`...`, `…`) y llaves sueltas. Bloques bash/text/sin lenguaje: fuera.
"""
import json, pathlib, re, sys

CODIGO = {"js", "javascript", "vue", "html", "json", "css", "yaml", "yml"}
EXT = {".js", ".vue", ".json", ".html", ".css"}
TRIVIAL = re.compile(r"^[\s{}()\[\];,]*$|^(\}\)|\]\)|\);?|<\/?template>|<\/?script>|<\/?style.*>|<\/div>|export default \{)$")

SIN_COMENTARIO = False

def norm(l):
    if SIN_COMENTARIO:
        l = re.sub(r"\s//\s.*$|\s/\*.*\*/\s*$|\s<!--.*-->\s*$", "", l)
    l = l.replace("'", '"') if SIN_COMENTARIO else l
    return re.sub(r"\s+", " ", l.strip()).rstrip(",;")

def utiles(codigo):
    for l in codigo.splitlines():
        n = norm(l)
        if not n or "..." in n or "…" in n or TRIVIAL.match(n):
            continue
        yield n

def indice(dirs):
    archivos = {}
    for d in dirs:
        for f in pathlib.Path(d).rglob("*"):
            if f.is_file() and (f.suffix in EXT or f.suffix in {".yml", ".yaml"} or f.name in {".prettierrc", ".editorconfig", ".nvmrc", ".eslintrc"}) and "node_modules" not in f.parts and "dist" not in f.parts \
               and f.name != "package-lock.json":
                try:
                    archivos[f"{d}:{f.relative_to(d)}"] = {norm(l) for l in f.read_text(encoding="utf-8").splitlines()}
                except UnicodeDecodeError:
                    pass
    return archivos

def main():
    global SIN_COMENTARIO
    if "--sin-comentarios" in sys.argv:
        sys.argv.remove("--sin-comentarios"); SIN_COMENTARIO = True
    desde, hasta = 0, 10**9
    if "--lineas" in sys.argv:
        i = sys.argv.index("--lineas"); desde, hasta = map(int, sys.argv[i + 1].split("-")); del sys.argv[i:i + 2]
    bl = json.load(open(sys.argv[1], encoding="utf-8"))
    doc = sys.argv[2]
    arch = indice(sys.argv[3:])
    todas = set().union(*arch.values()) if arch else set()
    tot = ok = 0
    for b in bl:
        if not b["archivo"].endswith(doc) or b["lang"] not in CODIGO or not desde <= b["linea"] <= hasta:
            continue
        ls = list(utiles(b["codigo"]))
        if not ls:
            continue
        tot += 1
        mejor = max(arch, key=lambda k: sum(l in arch[k] for l in ls))
        faltan = [l for l in ls if l not in arch[mejor]]
        if not faltan:
            ok += 1
            continue
        en_otro = [l for l in faltan if l in todas]
        print(f"\n== {doc}:{b['linea']} [{b['lang']}] → {mejor.split(':',1)[1]}  ({len(ls)-len(faltan)}/{len(ls)})")
        for l in faltan:
            print(("   ~ " if l in en_otro else "   - ") + l[:150])
    print(f"\n{doc}: {ok}/{tot} bloques coinciden enteros  (~ = la línea existe en otro archivo)")

if __name__ == "__main__":
    main()
