# rescatado de la sesión 2924cb25, 2026-09-11T16:31:18Z · Re-verify forensic pieces and check links
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
        foot=[x for x in open(p) if x.startswith('**Incidentes del cuaderno')]
        if not foot or not re.search(r'\b0*%d\b'%num, foot[0]): bad.append((num,p))
print('asimetrías:',bad or 'ninguna')
