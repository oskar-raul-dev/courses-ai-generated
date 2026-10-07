# rescatado de la sesión ba539b99, 2026-09-11T03:55:19Z · Check incident coverage by forensic pieces
import re,glob
ids=set()
for f in sorted(glob.glob('forense-fase-*.md')):
    t=open(f,encoding='utf-8').read()
    m=re.search(r'Incidentes del cuaderno que usan esta ruta:\*\*(.*?)(?:\n\*\*|\n\n|$)',t,re.S)
    if m:
        for x in re.findall(r'\*\*(\d{2})\*\*',m.group(1)): ids.add(x)
print('cubiertos:',sorted(ids))
print('sin pieza:',[('%02d'%i) for i in range(1,22) if '%02d'%i not in ids])
