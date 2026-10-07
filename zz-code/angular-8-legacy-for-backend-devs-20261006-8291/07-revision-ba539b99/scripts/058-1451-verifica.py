# rescatado de la sesión ba539b99, 2026-09-11T14:51:07Z · Cross-check index against written statements
import re
t=open('cuaderno-incidentes.md',encoding='utf-8').read()
# índice
idx={}
for l in t.split('\n'):
    m=re.match(r'\|\s*(\d{2})\s*\|\s*(\d{1,2})\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(🟢|🟡|🟠|🔴)\s*\|',l)
    if m: idx[m.group(1)]=(m.group(2),m.group(3).strip(),m.group(4).strip().lower(),m.group(5))
# enunciados
enu={}
for m in re.finditer(r'^## Incidente (\d{2}) — (.+)$\n\n> \*\*Fase:\*\* (\d{1,2}) · \*\*Categoría:\*\* ([^·]+) · \*\*Dificultad:\*\* (🟢|🟡|🟠|🔴)',t,re.M):
    enu[m.group(1)]=(m.group(3),m.group(2).strip(),m.group(4).strip().lower(),m.group(5))
print('índice:',len(idx),'enunciados:',len(enu))
bad=0
for i in sorted(idx):
    if i not in enu: print('SIN ENUNCIADO',i); bad+=1; continue
    a,b=idx[i],enu[i]
    for campo,x,y in zip(['fase','título','categoría','dif'],a,b):
        if x.lower()!=y.lower(): print(f'⚠️ {i} {campo}: índice "{x}" vs enunciado "{y}"'); bad+=1
print('discrepancias:',bad)
# escala
from collections import Counter
c=Counter(v[3] for v in idx.values())
print('escala:',dict(c),'  esperado 2🟢 8🟡 9🟠 2🔴')
# reparto semanal
sem={'1':[],'2':[],'3':[],'4':[]}
for i,v in idx.items():
    f=int(v[0])
    k='1' if f<=4 else '2' if f<=8 else '3' if f<=11 else '4'
    sem[k].append(i)
print({k:len(v) for k,v in sem.items()},' esperado 7/7/4/3')
print('22 dado de alta:', '22' in idx or '## Incidente 22' in t)
