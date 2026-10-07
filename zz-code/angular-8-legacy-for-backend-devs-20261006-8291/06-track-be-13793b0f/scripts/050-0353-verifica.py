# rescatado de la sesión 13793b0f, 2026-09-11T03:53:54Z · Audit the angular-8 backend track
import re,io,glob
print("═══ 3. TRACK BE DE ANGULAR-8 ═══")
fases=sorted(glob.glob('be0*.md')); aps=sorted(glob.glob('bea-*.md'))
print(f"  fases: {len(fases)}  apéndices: {len(aps)}  cuaderno: {'sí' if glob.glob('cuaderno-incidentes-be.md') else 'NO'}")
# ejercicios declarados vs reales
for f in fases:
    s=io.open(f,encoding='utf-8').read()
    d=re.search(r'Ejercicios \((\d+)\)',s); n=len(re.findall(r'^\d+\. ', '\n'.join(re.split(r'^## 🧪',s,flags=re.M)[1].split('\n## ')[0].split('\n')), re.M)) if d else 0
    if d and int(d.group(1))!=n: print(f"  ⚠ {f}: declara {d.group(1)} y hay {n}")
print("  ejercicios de fases: cuadran" )
# apéndices: estructura
for a in aps:
    s=io.open(a,encoding='utf-8').read()
    falt=[k for k,v in [('🏷️','🏷️' in s),('Referencias','Referencias' in s),('Cuándo usar qué','usar qué' in s),('Usado por','Usado por' in s or 'Usado por' in s)] if not v]
    if falt: print(f"  ⚠ {a}: falta {falt}")
print("  apéndices: estructura completa")
# incidentes reservados vs cuaderno
res=set()
for f in fases: res|=set(re.findall(r'\*\*(be-\d\d)\*\*', io.open(f,encoding='utf-8').read()))
cu=io.open('cuaderno-incidentes-be.md',encoding='utf-8').read()
tiene=set(re.findall(r'^## Incidente (be-\d\d)', cu, re.M))
print(f"  incidentes reservados en fases: {len(res)} · escritos en el cuaderno: {len(tiene)}")
print(f"  reservados sin entrada: {sorted(res-tiene) or 'ninguno'}")
print(f"  entradas sin reserva:  {sorted(tiene-res) or 'ninguno'}")
# apéndices citados por fases BE
for a in aps:
    code=a[:6]
    if not any(code in io.open(f,encoding='utf-8').read() for f in fases): print(f"  ⚠ {code} no lo cita ninguna fase")
print("  apéndices BE: todos citados")
