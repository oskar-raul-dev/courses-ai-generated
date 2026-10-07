# rescatado de la sesión 13793b0f, 2026-09-11T03:54:22Z · Correctly check prose mentions in the BE phases
import io,glob,re
pares=[('bea-02','be02'),('bea-04','be05'),('bea-04','be06'),('bea-12','be03')]
for ap,fa in pares:
    f=glob.glob(fa+'-*.md')[0]
    s=io.open(f,encoding='utf-8').read()
    hits=[' '.join(l.split())[:120] for l in s.split('\n') if ap in l]
    print(f"\n{ap} declara {fa} → {len(hits)} menciones en {f}")
    for h in hits[:3]: print("   ",h)
