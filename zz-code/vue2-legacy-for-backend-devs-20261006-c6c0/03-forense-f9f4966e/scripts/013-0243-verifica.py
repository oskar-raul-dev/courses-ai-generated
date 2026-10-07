# rescatado de la sesión f9f4966e, 2026-09-10T02:43:11Z · Verify phase-ID mapping, appendices and tag namespaces
import io,re,glob,os
for curso,pre in [('01-vue2-legacy',''),('02-complement-mongodb-backend','')]:
    c=io.open(curso+'/cuaderno-incidentes.md',encoding='utf-8').read()
    idx={m.group(1):m.group(2) for m in re.finditer(r'^\| (\d{2}) \| (\d+) \|', c, re.M)}
    for f in sorted(glob.glob(curso+'/*.md')):
        b=os.path.basename(f)
        if b.startswith(('forense','cuaderno','0-','README')): continue
        s=io.open(f,encoding='utf-8').read()
        m=re.search(r'### 📌 Reservas para el cuaderno de incidentes(.*)$', s, re.S)
        if not m: continue
        for r in re.finditer(r'^\| (\d{2}) \|', m.group(1), re.M):
            i=r.group(1); fase=idx.get(i)
            num=re.match(r'(\d+)', b)
            n = str(int(num.group(1))) if num else '?'
            if fase != n: print("MISMATCH", curso, b, "id",i,"índice dice fase",fase)
print("fin")
