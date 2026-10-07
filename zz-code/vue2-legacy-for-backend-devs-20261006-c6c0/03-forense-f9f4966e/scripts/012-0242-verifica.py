# rescatado de la sesión f9f4966e, 2026-09-10T02:42:58Z · Cross-check reserved IDs against notebooks
import io,re,glob,os
for curso in ['01-vue2-legacy','02-complement-mongodb-backend']:
    # IDs reservados por fases
    res={}
    for f in sorted(glob.glob(curso+'/*.md')):
        if os.path.basename(f).startswith(('forense','cuaderno','0-','README')): continue
        s=io.open(f,encoding='utf-8').read()
        m=re.search(r'### 📌 Reservas para el cuaderno de incidentes(.*)$', s, re.S)
        if not m: continue
        for r in re.finditer(r'^\| (\d{2}) \|', m.group(1), re.M):
            res.setdefault(r.group(1),[]).append(os.path.basename(f))
    # IDs en el indice del cuaderno
    c=io.open(curso+'/cuaderno-incidentes.md',encoding='utf-8').read()
    idx=set(re.findall(r'^\| (\d{2}) \| \d+ \|', c, re.M))
    inc=set(re.findall(r'^## Incidente (\d{2}) —', c, re.M))
    print(curso)
    print("  reservados:", sorted(res), len(res))
    print("  índice    :", sorted(idx), len(idx))
    print("  escritos  :", sorted(inc), len(inc))
    print("  huérfanos reserva->índice:", sorted(set(res)-idx))
    print("  huérfanos índice->reserva:", sorted(idx-set(res)))
    print("  duplicados:", {k:v for k,v in res.items() if len(v)>1})
