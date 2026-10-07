# rescatado de la sesión 2924cb25, 2026-09-11T16:37:57Z · Cross-check reservation tables against the index
import glob,re
idx={}
for l in open('cuaderno-incidentes.md'):
    m=re.match(r'^\| \[(\d+)\]\(#[^)]*\) \| \d+ \| (.*?) \| (.*?) \| (.*?) \| ⬜ \|', l)
    if m: idx[int(m.group(1))]=(m.group(2).strip(), m.group(3).strip(), m.group(4).strip())
res={}
for f in sorted(glob.glob('[01][0-9]-*.md')):
    for l in open(f):
        m=re.match(r'^\| (\d+) \| (.*?) \| (.*?) \| (.*?) \|\s*$', l)
        if m: res[int(m.group(1))]=(f, m.group(2).strip(), m.group(3).strip(), m.group(4).strip())
print('índice:',len(idx),'reservas:',len(res))
for k in sorted(set(idx)|set(res)):
    if k not in idx: print(' ⚠️ reservado sin fila en el índice:',k,res[k]); continue
    if k not in res: print(' ⚠️ en el índice y sin reserva:',k,idx[k]); continue
    f,t,c,d=res[k]; ti,ci,di=idx[k]
    if (t,c,d)!=(ti,ci,di): print(f' ⚠️ {k} ({f}) difiere:\n    reserva: {t} | {c} | {d}\n    índice : {ti} | {ci} | {di}')
