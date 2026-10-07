# rescatado de la sesión ba539b99, 2026-09-11T04:06:14Z · Validate pending-item destinations
import re,glob
# pendientes 📌 abiertos que apuntan a un destino inexistente o que quedaron sin dueño
pat=re.compile(r'→\s*\*{0,2}(Fase\s+\d{1,2}|Apéndice\s+A\d{2}|A\d{2}|apéndice\s+\*{0,2}A\d{2}|bea-\d{2}|be\d{2})')
faltan=0
for f in sorted(glob.glob('*.md')):
    t=open(f,encoding='utf-8').read()
    m=re.search(r'## 📌 Pendientes sugeridos(.*)$',t,re.S)
    if not m: continue
    for d in set(pat.findall(m.group(1))):
        d2=d.replace('Apéndice ','').replace('apéndice ','').replace('**','').strip()
        if d2.lower().startswith('fase'):
            n=int(re.search(r'\d+',d2).group()); ok=bool(glob.glob('%02d-*.md'%n))
        elif d2.lower().startswith('bea'): ok=bool(glob.glob('bea-'+d2[-2:]+'-*.md'))
        elif d2.lower().startswith('be'): ok=bool(glob.glob('be'+d2[-2:]+'-*.md'))
        else: ok=bool(glob.glob(d2.lower()+'-*.md'))
        if not ok: faltan+=1; print('DESTINO INEXISTENTE',f,'->',d)
print('destinos de pendientes inválidos:',faltan)
