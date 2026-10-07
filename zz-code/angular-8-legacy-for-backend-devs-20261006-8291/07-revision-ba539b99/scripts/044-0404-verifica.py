# rescatado de la sesión ba539b99, 2026-09-11T04:04:20Z · Check reservation subsections per phase
import re,glob
for f in sorted(glob.glob('[01][0-9]-*.md')):
    if 'convencion' in f or 'historia' in f: continue
    t=open(f,encoding='utf-8').read()
    head='\n'.join(t.split('\n')[:8])
    m=re.search(r'Incidentes asociados\]?\([^)]*\)?:([^\n]*)',head)
    ids=re.findall(r'\b\d{2}\b',m.group(1)) if m else []
    has=('Reservas para el cuaderno' in t)
    pend=('📌 Pendientes' in t)
    print(f'{f[:2]}  ids={ids or "—"}  reservas={"sí" if has else "NO"}  pendientes={"sí" if pend else "NO"}')
