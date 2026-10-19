"""Agrega entradas a la bitácora (M-NN) y a INSTINTOS.md, con sus índices.
Uso: python3 vivos_add.py bitacora entradas.md   ·   python3 vivos_add.py instintos entradas.md
En la bitácora, cada entrada '### M-NN · FNN · …' se suma a la fila del Bloque III del índice (🔒 si es apuesta sin resolver).
En INSTINTOS, cada '### N · "…"' lleva una línea '<!-- fila: | N | III · La concurrencia | "…" | [Fase NN](…) | -->'."""
import re, sys
ROOT = "/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql/"
def anchor(head):
    t = head.lower(); t = re.sub(r"[^\w\s-]", "", t); return t.strip().replace(" ", "-")
kind, src = sys.argv[1], open(sys.argv[2], encoding="utf-8").read().strip()
if kind == "bitacora":
    p = ROOT + "bitacora-de-medicion.md"; s = open(p, encoding="utf-8").read()
    links = []
    for b in re.split(r"(?m)^(?=### M-)", src):
        if not b.strip(): continue
        head = b.splitlines()[0][4:]; num = head.split(" · ")[0]
        lock = " 🔒" if "apuesta sin resolver" in b else ""
        links.append(f"[{num}](#{anchor(head)}){lock}")
    s = s.rstrip() + "\n\n" + src + "\n"
    row = re.search(r"(?m)^\| III · La concurrencia \| F15–F18 \| (.*) \|$", s)
    cur = row.group(1); new = " · ".join(([] if cur == "—" else [cur]) + links)
    s = s[:row.start(1)] + new + s[row.end(1):]
else:
    p = ROOT + "INSTINTOS.md"; s = open(p, encoding="utf-8").read()
    rows = re.findall(r"<!-- fila: (.*?) -->", src); src = re.sub(r"\n?<!-- fila: .*? -->", "", src)
    last = list(re.finditer(r"(?m)^\| \d+ \| .*\|$", s))[-1]
    s = s[:last.end()] + "\n" + "\n".join(rows) + s[last.end():]
    s = s.rstrip() + "\n\n" + src + "\n"
open(p, "w", encoding="utf-8").write(s); print("ok", kind)
