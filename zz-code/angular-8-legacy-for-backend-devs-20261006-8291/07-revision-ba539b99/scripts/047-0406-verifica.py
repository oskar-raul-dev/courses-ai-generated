# rescatado de la sesión ba539b99, 2026-09-11T04:06:00Z · Cross-check BE incident reservations
import re,glob
idx={}
for l in open('cuaderno-incidentes-be.md',encoding='utf-8'):
    m=re.match(r'\|\s*(be-\d{2})\s*(?:⭐)?\s*\|\s*(be\d{2})\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(🟢|🟡|🟠|🔴)',l)
    if m: idx[m.group(1)]=(m.group(2),m.group(3).strip(),m.group(4).strip().lower(),m.group(5))
print('índice BE:',len(idx))
res={}
for f in sorted(glob.glob('be0*.md')):
    t=open(f,encoding='utf-8').read()
    m=re.search(r'### Reservas para el cuaderno de incidentes(.*)$',t,re.S)
    if not m: continue
    for mm in re.finditer(r'\*\*(be-\d{2})\*\*',m.group(1)): res.setdefault(mm.group(1),f[:4])
print('reservados en fases:',len(res))
print('en índice sin reserva:',sorted(set(idx)-set(res)))
print('reservados sin índice:',sorted(set(res)-set(idx)))
for i in sorted(set(idx)&set(res)):
    if idx[i][0]!=res[i]: print(f'⚠️ {i}: índice {idx[i][0]} vs fase {res[i]}')
