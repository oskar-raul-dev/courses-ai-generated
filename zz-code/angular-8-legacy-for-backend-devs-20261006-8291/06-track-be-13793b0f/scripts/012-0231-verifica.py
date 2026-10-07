# rescatado de la sesión 13793b0f, 2026-09-11T02:31:55Z · Precise scan of which phases cite each appendix
import re,io,glob
def r(p): return io.open(p,encoding='utf-8').read()
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p))
print(f"{'ap':4} {'declara Usado por':52} | citan de verdad")
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    base=a[:3]
    s=r(a)
    m2=re.search(r'Usado por:\s*([^\n·]*)', s)
    declara=(m2.group(1).strip() if m2 else '(SIN línea)')
    reales=[]
    for p in fases:
        t=r(p)
        if a in t or re.search(r'[`\[]'+base+r'[`\]\s]', t, re.I) or re.search(r'\bAp[ée]ndice\s+'+base+r'\b', t, re.I):
            reales.append(p[:2])
    print(f"{base:4} {declara[:52]:52} | {','.join(reales)}")
