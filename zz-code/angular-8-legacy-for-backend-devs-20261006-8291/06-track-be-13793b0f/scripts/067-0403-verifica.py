# rescatado de la sesión 13793b0f, 2026-09-11T04:03:48Z · Search for template leftovers and open markers
import re,io,glob
print("═══ RESTOS DE PLANTILLA Y MARCADORES ABIERTOS ═══")
pats={'{{placeholder}}':r'\{\{[^}]+\}\}','TODO/FIXME/TBD':r'\b(TODO|FIXME|TBD|XXX)\b',
      'lorem/pendiente de escribir':r'pendiente de escribir|por escribir|sin redactar|falta redactar'}
docs=[p for p in glob.glob('*.md')]
for nombre,pat in pats.items():
    hits=[]
    for p in docs:
        for m in re.finditer(pat, io.open(p,encoding='utf-8').read()):
            hits.append((p,m.group(0)[:40]))
    print(f"  {nombre:28} {len(hits)}")
    for p,t in hits[:5]: print(f"      {p}: {t}")
