# rescatado de la sesión ba539b99, 2026-09-11T04:05:50Z · Normalize subsection name and cross-check reservations
import re,glob
idx={}
for l in open('cuaderno-incidentes.md',encoding='utf-8'):
    m=re.match(r'\|\s*(\d{2})\s*\|\s*(\d{1,2})\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(🟢|🟡|🟠|🔴)',l)
    if m: idx[m.group(1)]=(m.group(2),m.group(3).strip(),m.group(4).strip().lower(),m.group(5))
res={}
for f in sorted(glob.glob('[01][0-9]-*.md')):
    t=open(f,encoding='utf-8').read()
    m=re.search(r'### Reservas para el cuaderno de incidentes(.*)$',t,re.S)
    if not m: continue
    for mm in re.finditer(r'^- \*\*(\d{2})\*\* · Fase (\d{1,2}) · \*"([^"]+)"\* · Categoría: ([^·]+) · Dificultad (🟢|🟡|🟠|🔴)',m.group(1),re.M):
        i=mm.group(1); res[i]=(mm.group(2),mm.group(3),mm.group(4).strip().lower(),mm.group(5),f)
print('reservas formales:',len(res))
print('sin reserva formal:',sorted(set(idx)-set(res)))
for i in sorted(set(idx)&set(res)):
    fi,ti,ci,di=idx[i]; fr,tr,cr,dr,f=res[i]
    if fi!=fr: print(f'⚠️ {i} fase: índice {fi} vs fase {fr} ({f})')
    if ti.lower()!=tr.lower(): print(f'⚠️ {i} título:\n     índice: {ti}\n     fase  : {tr}')
    if ci!=cr: print(f'⚠️ {i} categoría: índice "{ci}" vs fase "{cr}"')
    if di!=dr: print(f'⚠️ {i} dificultad: índice {di} vs fase {dr}')
