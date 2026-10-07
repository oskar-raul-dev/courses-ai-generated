# rescatado de la sesión 13793b0f, 2026-09-11T02:45:30Z · Final verification of all fixes
import re,io,glob,os
def r(p): return io.open(p,encoding='utf-8').read()
# enlaces relativos
mal=0
for p in glob.glob('*.md')+glob.glob('prompts/*.md'):
    s=r(p); base=os.path.dirname(p)
    for m in re.finditer(r'\]\((\.?\.?/?[^)#\s]+\.md)\)', s):
        if not os.path.exists(os.path.normpath(os.path.join(base,m.group(1)))): print("ROTO",p,m.group(1)); mal+=1
print("enlaces .md rotos:",mal)
# usado por
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p))
bad=0
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    base=a[:3].upper(); m=re.search(r'Usado por:\s*([^\n·]*)', r(a))
    dec=sorted(set(int(x) for x in re.findall(r'Fase\s+(\d+)', m.group(1)))) if m else []
    cab=[int(p[:2]) for p in fases if (lambda h: h and re.search(r'\b'+base+r'\b',h.group(1)))(re.search(r'Apéndices de apoyo:([^\n]*)', r(p)))]
    if dec!=sorted(cab): print("DESAJUSTE",base,dec,sorted(cab)); bad+=1
print("apéndices con 'Usado por' desajustado:",bad)
# promesas 📄
for i in range(15):
    fs=[p for p in glob.glob('%02d-*.md'%i) if 'convencion' not in p and 'historia' not in p]
    if not fs: continue
    m=re.search(r'[^\n]*forense-fase-%02d\.md[^\n]*'%i, r(fs[0]))
    pieza=r('forense-fase-%02d.md'%i)
    t=len(re.findall(r'^\*\*Reportado por', pieza, re.M))
    prom=m.group(0)
    num = 'dos' if t==2 else ('tres' if t==3 else 'un/el')
    if t>1 and 'los dos' not in prom and 'los tres' not in prom and 'los tickets' not in prom:
        print(f"  ⚠ Fase {i}: pieza con {t} tickets y la promesa dice: {prom[:90]}")
print("promesas 📄 revisadas")
