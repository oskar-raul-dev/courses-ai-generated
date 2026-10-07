# rescatado de la sesión babb5b75, 2026-09-07T01:39:33Z · Verify index anchors
import re, pathlib, unicodedata
t = pathlib.Path('cuaderno-incidentes.md').read_text()

def anchor(h):
    s = h.strip().lower()
    s = s.replace('`','')
    # quitar todo lo que no sea alfanumérico unicode, espacio o guion
    s = ''.join(c for c in s if c.isalnum() or c in ' -_')
    return s.replace(' ', '-')

heads = re.findall(r'^## (Incidente \d+ .*)$', t, re.M)
links = re.findall(r'\]\(#(incidente-[^)]*)\)', t)
gen = [anchor(h) for h in heads]

bad = [l for l in links if l not in gen]
print(f"encabezados: {len(heads)}  enlaces: {len(links)}  rotos: {len(bad)}")
for b in bad[:5]:
    print("  ROTO:", b)
if not bad:
    print("todos los enlaces del índice resuelven")
