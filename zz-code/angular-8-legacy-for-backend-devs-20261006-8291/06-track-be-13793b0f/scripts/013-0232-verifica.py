# rescatado de la sesión 13793b0f, 2026-09-11T02:32:13Z · Compare declared usage against phase headers
import re,io,glob
def r(p): return io.open(p,encoding='utf-8').read()
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p))
def num(x): return int(re.search(r'\d+',x).group())
print(f"{'ap':4} | declara            | citan (cualquier sitio) | lo listan en 'Apéndices de apoyo'")
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    base=a[:3].upper()
    s=r(a)
    m2=re.search(r'Usado por:\s*([^\n·]*)', s)
    dec=re.findall(r'Fase\s+(\d+)', m2.group(1)) if m2 else []
    dec=sorted(set(int(x) for x in dec))
    citan=[]; apoyo=[]
    for p in fases:
        t=r(p)
        if re.search(r'\b'+base+r'\b', t): citan.append(num(p))
        h=re.search(r'Apéndices de apoyo:([^\n]*)', t)
        if h and re.search(r'\b'+base+r'\b', h.group(1)): apoyo.append(num(p))
    falta=[x for x in dec if x not in apoyo]
    sobra=[x for x in apoyo if x not in dec]
    flag=''
    if falta: flag+=f"  ⚠ declara {falta} y NO están en su cabecera"
    if sobra: flag+=f"  ⚠ cabecera de {sobra} lo lista y el apéndice no lo declara"
    print(f"{base:4} | {str(dec):18} | {str(sorted(set(citan))):23} | {sorted(set(apoyo))}{flag}")
