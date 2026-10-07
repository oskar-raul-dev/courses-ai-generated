# rescatado de la sesión ba539b99, 2026-09-11T04:02:57Z · Sum declared hours per phase
import re,glob
tot=0
for f in sorted(glob.glob('[01][0-9]-*.md')):
    if 'convencion' in f or 'historia' in f: continue
    h=open(f,encoding='utf-8').read().split('\n')[2]
    m=re.search(r'\*\*(\d+)\s*horas?\*\*',h)
    v=int(m.group(1)) if m else 0
    print(f[:2],v,'' if m else '  <-- sin horas en cabecera')
    tot+=v
print('TOTAL base:',tot)
tb=0
for f in sorted(glob.glob('be0*.md')):
    h=open(f,encoding='utf-8').read().split('\n')[2]
    m=re.search(r'\*\*(\d+)\s*horas?\*\*',h); v=int(m.group(1)) if m else 0
    print(f[:4],v); tb+=v
print('TOTAL BE:',tb)
