# rescatado de la sesión ba539b99, 2026-09-11T04:03:48Z · Validate deferral targets in section 3
import re,glob
pat=re.compile(r'(?:Fase|fase)\s+(\d{1,2})\b')
bad=0; tot=0
for f in sorted(glob.glob('[01][0-9]-*.md')):
    if 'convencion' in f or 'historia' in f: continue
    t=open(f,encoding='utf-8').read()
    m=re.search(r'## 🚫 3\..*?(?=\n## )',t,re.S)
    if not m: print('SIN SECCIÓN 3:',f); continue
    ns={int(x) for x in pat.findall(m.group(0))}
    cur=int(f[:2])
    for n in sorted(ns):
        tot+=1
        if n>14: bad+=1; print(f'{f}: difiere a Fase {n} (no existe)')
        elif n<cur and n!=cur: print(f'  ⓘ {f}: menciona Fase {n} (anterior) en §3')
print('referencias de diferimiento revisadas:',tot,'inválidas:',bad)
