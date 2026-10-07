# rescatado de la sesión 13793b0f, 2026-09-11T04:05:49Z · Final consolidated verification
import re,io,glob,os
def r(p): return io.open(p,encoding='utf-8').read()
mal=sum(1 for p in glob.glob('*.md')+glob.glob('prompts/*.md') for m in re.finditer(r'\]\((\.{0,2}/?[^)#\s]+\.md)\)', r(p)) if not os.path.exists(os.path.normpath(os.path.join(os.path.dirname(p),m.group(1)))))
print(f"enlaces .md rotos: {mal}")
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p) and 'convencion' not in p and 'historia' not in p)
bad=0
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    base=a[:3].upper(); m=re.search(r'Usado por:\s*([^\n·]*)', r(a))
    dec=sorted(set(int(x) for x in re.findall(r'Fase\s+(\d+)', m.group(1))))
    cab=sorted(int(p[:2]) for p in fases if (lambda h: h and re.search(r'\b'+base+r'\b',h.group(1)))(re.search(r'Apéndices de apoyo:([^\n]*)', r(p))))
    if dec!=cab: bad+=1
print(f"apéndices con 'Usado por' desajustado: {bad}")
print(f"incidentes: {len(re.findall(r'^## Incidente ', r('cuaderno-incidentes.md'), re.M))} · índice: {len(re.findall(r'^\| \[', r('cuaderno-incidentes.md'), re.M))}")
print(f"⚠️ sin cerrar en la propuesta BE: {len(re.findall(r'### 10.2 ⚠️', r('prompts/propuesta-fases-backend.md')))}")
