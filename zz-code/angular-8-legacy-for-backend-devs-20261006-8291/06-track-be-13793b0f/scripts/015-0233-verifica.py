# rescatado de la sesión 13793b0f, 2026-09-11T02:33:14Z · Check incident-forensic bidirectional links
import re,io,glob
cit={}
for f in sorted(glob.glob('forense-*.md')):
    s=io.open(f,encoding='utf-8').read()
    m=re.search(r'Incidentes? del cuaderno[^\n]*\n?([^\n]*)', s)
    linea=m.group(0) if m else ''
    ids=set(re.findall(r'\b(\d{2})\b', linea))
    if ids: cit[f]=sorted(ids)
    print(f"{f:22} {sorted(ids) if ids else '—'}   {linea[:80]}")
todos=set()
for v in cit.values(): todos|=set(v)
print("\ncubiertos:", sorted(todos))
print("sin ruta forense:", sorted(set('%02d'%i for i in range(1,21))-todos))
