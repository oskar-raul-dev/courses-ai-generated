# rescatado de la sesión 13793b0f, 2026-09-11T04:02:36Z · Check README against actual course content
import re,io,glob
def r(p): return io.open(p,encoding='utf-8').read()
print("═══ README vs REALIDAD ═══")
rd=r('README.md')
# fases
tab=re.findall(r'^\|\s*(?:[^|]*?)\[?`?(\d\d)-[^|]*\|\s*(\d+)h', rd, re.M)
print(f"  filas de fase en el README: {len(tab)}")
for n,h in tab:
    f=glob.glob(n+'-*.md')
    if not f: print(f"   ⚠ el README lista la fase {n} y no hay archivo"); continue
    m=re.search(r'\*\*(\d+) horas?\*\*', r(f[0]))
    if not m or m.group(1)!=h: print(f"   ⚠ fase {n}: README {h}h · archivo {m.group(1)+'h' if m else 'sin horas'}")
print("  horas de fases: cuadran" )
# cifras declaradas
for cifra in re.findall(r'\*\*(\d+)h\*\*|\*\*(\d+) ejercicios', rd):
    pass
print("  cifras del README:", re.findall(r'\*\*\d+h\*\*|\*\*\d+ ejercicios[^*]*\*\*|\*\*\d+ horas\*\*', rd)[:8])
# ficheros enlazados desde el README que no existen
import os
mal=[m.group(1) for m in re.finditer(r'\]\(([^)#\s]+\.md)\)', rd) if not os.path.exists(m.group(1))]
print("  enlaces del README rotos:", mal or 'ninguno')
# ¿el README lista las 15 piezas forenses?
falt=[f for f in sorted(glob.glob('forense-*.md')) if f not in rd]
print("  piezas forenses no mencionadas en el README:", falt or 'ninguna')
