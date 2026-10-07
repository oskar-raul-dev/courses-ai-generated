# rescatado de la sesión 2924cb25, 2026-09-11T16:31:00Z · Verify reciprocal forensic links again
import re,os
lines=open('cuaderno-incidentes.md').read().split('\n')
cur=None; pairs=[]
for l in lines:
    m=re.match(r'^## Incidente (\d+)',l)
    if m: cur=int(m.group(1))
    if l.startswith('> **Tiempo sugerido:**') and cur:
        pairs.append((cur, re.findall(r'forense-fase-(\d+)\.md\)', l)))
bad=[]
for num,fs in pairs:
    for f in fs:
        p=f'forense-fase-{f}.md'
        if not os.path.exists(p): bad.append((num,p,'no existe')); continue
        foot=[x for x in open(p) if x.startswith('**Incidentes del cuaderno')]
        if not foot: bad.append((num,p,'sin pie recíproco')); continue
        if not re.search(r'\b0*%d\b'%num, foot[0]): bad.append((num,p,foot[0].strip()[:80]))
print(len(pairs),'incidentes con Ruta forense'); [print(' ⚠️',b) for b in bad] or print('recíprocos OK')
