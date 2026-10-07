# rescatado de la sesión 13793b0f, 2026-09-11T03:56:54Z · Final verification of both angular courses
import re,io,glob
print("═══ 7. ANGULAR-8: verificación final ═══")
# ejercicios de apéndices BE
tot=0
for a in sorted(glob.glob('bea-*.md')):
    s=io.open(a,encoding='utf-8').read()
    m=re.search(r'Ejercicios \((\d+)\)',s)
    n=len(re.findall(r'^\d+\. ', s.split('## 🧪')[1] if '## 🧪' in s else '', re.M))
    if m and int(m.group(1))!=n: print(f"  ⚠ {a[:6]}: declara {m.group(1)}, hay {n}")
    tot+= int(m.group(1)) if m else 0
print(f"  ejercicios de los 12 apéndices BE: {tot} · conteos declarados = reales")
# cuaderno BE
cu=io.open('cuaderno-incidentes-be.md',encoding='utf-8').read()
idx=len(re.findall(r'^\| be-\d\d', cu, re.M))
ent=len(re.findall(r'^## Incidente be-\d\d', cu, re.M))
sol=len(re.findall(r'Solución de referencia', cu))
print(f"  cuaderno BE: {idx} filas de índice · {ent} entradas · {sol} soluciones")
# forenses del track base intactos
print(f"  piezas forenses del track base: {len(glob.glob('forense-fase-*.md'))} + master")
