# rescatado de la sesión ba539b99, 2026-09-11T04:04:01Z · Cross-check incident reservations against notebook index
import re,glob
# índice del cuaderno base
idx={}
for l in open('cuaderno-incidentes.md',encoding='utf-8'):
    m=re.match(r'\|\s*(\d{2})\s*\|\s*(\d{1,2})\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(🟢|🟡|🟠|🔴)',l)
    if m: idx[m.group(1)]=(m.group(2),m.group(3),m.group(4),m.group(5))
print(len(idx),'incidentes en el índice')
# reservas declaradas en las fases
res={}
for f in sorted(glob.glob('[01][0-9]-*.md')):
    if 'convencion' in f or 'historia' in f: continue
    t=open(f,encoding='utf-8').read()
    m=re.search(r'### Reservas para el cuaderno de incidentes(.*)$',t,re.S)
    if not m: continue
    for mm in re.finditer(r'\*\*(\d{2})\*\*|\|\s*(\d{2})\s*\|',m.group(1)):
        i=mm.group(1) or mm.group(2); res.setdefault(i,f)
print('IDs reservados en fases:',sorted(res))
print('en índice y no reservados:',sorted(set(idx)-set(res)))
print('reservados y no en índice:',sorted(set(res)-set(idx)))
for i in sorted(set(idx)&set(res)):
    fase_idx=idx[i][0]
    if fase_idx.zfill(2)!=res[i][:2]:
        print(f'  ⚠️ {i}: índice dice fase {fase_idx}, lo reserva {res[i][:2]}')
