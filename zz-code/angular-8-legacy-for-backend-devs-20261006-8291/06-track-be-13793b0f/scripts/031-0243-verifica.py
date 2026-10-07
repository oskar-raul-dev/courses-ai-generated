# rescatado de la sesión 13793b0f, 2026-09-11T02:43:14Z · Verify Usado por now matches phase headers
import re,io,glob
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p))
def num(x): return int(x[:2])
ok=True
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    base=a[:3].upper(); s=io.open(a,encoding='utf-8').read()
    m=re.search(r'Usado por:\s*([^\n·]*)', s)
    dec=sorted(set(int(x) for x in re.findall(r'Fase\s+(\d+)', m.group(1)))) if m else []
    cab=[]
    for p in fases:
        h=re.search(r'Apéndices de apoyo:([^\n]*)', io.open(p,encoding='utf-8').read())
        if h and re.search(r'\b'+base+r'\b', h.group(1)): cab.append(num(p))
    estado='ok' if dec==sorted(cab) else f'⚠ declara {dec} vs cabeceras {sorted(cab)}'
    if estado!='ok': ok=False
    print(f"  {base}  {estado}")
print("\nTODOS CUADRAN" if ok else "\nQUEDAN DESAJUSTES")
