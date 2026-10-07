# rescatado de la sesión 13793b0f, 2026-09-11T02:36:14Z · Check whether phases mention the appendices that claim them
import re,io,glob
def r(p): return io.open(p,encoding='utf-8').read()
pares=[('A01',[7,8,10]),('A03',[12]),('A05',[0,2]),('A07',[6]),('A12',[12])]
for ap,fases in pares:
    for n in fases:
        f=glob.glob('%02d-*.md'%n)
        f=[x for x in f if 'convencion' not in x and 'historia' not in x]
        t=r(f[0])
        hits=re.findall(r'[^\n]*\b'+ap+r'\b[^\n]*', t)
        print(f"{ap} declara Fase {n} ({f[0][:22]}): {len(hits)} menciones")
        for h in hits[:2]: print("     ", ' '.join(h.split())[:110])
