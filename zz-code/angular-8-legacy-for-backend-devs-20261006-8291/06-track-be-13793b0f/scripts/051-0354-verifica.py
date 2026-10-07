# rescatado de la sesión 13793b0f, 2026-09-11T03:54:05Z · Cross-reference audit of the BE track
import re,io,glob
print("═══ 3b. COHERENCIA CRUZADA DEL TRACK BE ═══")
fases=sorted(glob.glob('be0*.md')); aps=sorted(glob.glob('bea-*.md'))
def r(p): return io.open(p,encoding='utf-8').read()
# 'Usado por' de cada apéndice vs 'Apéndices de apoyo' de las fases BE
print(f"  {'ap':8} {'declara':26} {'lo listan las fases':26}")
bad=0
for a in aps:
    code=a[:6]; s=r(a)
    m=re.search(r'Usado por:\s*([^\n·]*)', s)
    dec=sorted(set(re.findall(r'be0\d', m.group(1)))) if m else []
    cab=[]
    for f in fases:
        h=re.search(r'Apéndices de apoyo:([^\n]*)', r(f))
        if h and code in h.group(1): cab.append(f[:4])
    if sorted(dec)!=sorted(cab): bad+=1; print(f"  ⚠ {code:8} {str(dec):26} {str(sorted(cab)):26}")
print(f"  apéndices BE con 'Usado por' desajustado: {bad}")
# bloque tag en fases BE
for f in fases:
    s=r(f)
    if 'be-fase-' not in s or '🏷️' not in s: print("  ⚠ sin bloque 🏷️ o tag:",f)
print("  bloques 🏷️ de fases BE: ok")
# README refleja el estado
rd=r('README.md')
print(f"  README marca ✅ en: {len(re.findall(r'✅', rd))} filas")
