"""Agrega entradas a a08: el texto al final (antes del cierre 🏷️), el índice por motor y el conteo del encabezado.
Uso: python3 a08_add.py entradas.md  — cada entrada empieza con '### E-NN · título' y una línea '<!-- motor: postgres|mysql|oracle|lab -->'."""
import re, sys, unicodedata
P = "/Users/oskar/Developer/Learning/courses-ia-generated/cursos-bd/ruta-sql/a08-catalogo-de-errores.md"
def anchor(title):
    t = title.lower()
    t = re.sub(r"[^\w\s-]", "", t)          # quita puntuación y emoji; conserva letras con tilde
    return t.strip().replace(" ", "-")
s = open(P, encoding="utf-8").read()
new = open(sys.argv[1], encoding="utf-8").read().strip()
blocks = re.split(r"(?m)^(?=### E-)", new)
labels = {"postgres": "- **PostgreSQL** —", "mysql": "- **MySQL** —", "oracle": "- **Oracle** —", "lab": "- **El laboratorio**"}
texts = []
for b in blocks:
    if not b.strip(): continue
    head = b.splitlines()[0]; engine = re.search(r"<!-- motor: (\w+) -->", b).group(1)
    b = re.sub(r"\n?<!-- motor: \w+ -->\n?", "\n", b).strip()
    num, title = re.match(r"### (E-\d+) · (.*)", head).groups()
    link = f"[{num}](#{anchor(head[4:])})"
    # agrega al final de la línea del motor en el índice (la línea puede continuar en las siguientes)
    lines = s.split("\n"); i = next(k for k, l in enumerate(lines) if l.startswith(labels[engine]))
    j = i
    while j + 1 < len(lines) and lines[j + 1].startswith("  "): j += 1
    lines[j] = lines[j] + " · " + link
    s = "\n".join(lines); texts.append(b)
closing = "\n---\n\n> 🏷️ **Este apéndice no lleva tag propio.**"
k = s.rindex(closing)
s = s[:k].rstrip() + "\n\n" + "\n\n".join(texts) + "\n" + s[k:]
total = len(re.findall(r"(?m)^### E-\d+ ·", s))
s = re.sub(r"\*\*Entradas:\*\* \d+,", f"**Entradas:** {total},", s)
open(P, "w", encoding="utf-8").write(s)
print("entradas:", total)
