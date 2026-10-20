"""C0.2: drop the inc/ tag route from each "Cómo llegar." line of the incident notebook.

Usage: python3 cuaderno_sin_tags.py <cuaderno-incidentes.md> [--write]
Without --write it prints what would change and the count.
"""
import re
import sys

path = sys.argv[1]
text = open(path, encoding="utf-8").read()
# `git switch --detach inc/NN/<slug>-roto` · o <next>   (the separator may wrap to the next line)
pattern = re.compile(r"`git switch --detach inc/(\d{2})/[a-z0-9-]+-roto`\s*·\s*o\s+")
matches = pattern.findall(text)
new = pattern.sub("", text)
print(f"entradas cambiadas: {len(matches)} ({', '.join(matches)})")
left = re.findall(r"inc/\d{2}/", new)
print(f"referencias inc/NN/ que quedan: {len(left)}")
if "--write" in sys.argv:
    open(path, "w", encoding="utf-8").write(new)
    print("escrito")
