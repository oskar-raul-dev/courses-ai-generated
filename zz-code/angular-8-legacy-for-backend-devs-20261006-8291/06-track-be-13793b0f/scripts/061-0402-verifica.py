# rescatado de la sesión 13793b0f, 2026-09-11T04:02:05Z · Audit the incident notebook
import re,io
print("═══ CUADERNO DE INCIDENTES ═══")
s=io.open('cuaderno-incidentes.md',encoding='utf-8').read()
ent=re.findall(r'^## Incidente (\d\d) — (.+)$', s, re.M)
print(f"  entradas: {len(ent)} ({ent[0][0]}–{ent[-1][0]})")
idx=re.findall(r'^\|\s*(\d\d)\s*\|', s, re.M)
print(f"  filas de índice: {len(idx)}")
falt=[i for i,_ in ent if i not in idx]; sobra=[i for i in idx if i not in [e[0] for e in ent]]
print(f"  en el índice sin entrada: {sobra or 'ninguno'} · con entrada sin índice: {falt or 'ninguno'}")
for bloque,nombre in [('🎫 El ticket','ticket'),('🎯 Qué se te pide','qué se pide'),('🔧 Preparación','preparación'),('Pista 1','pista 1'),('Pista 2','pista 2'),('Pista 3','pista 3'),('📝 Tu investigación','investigación'),('Solución de referencia','solución')]:
    n=s.count(bloque)
    print(f"  {nombre:16} {n:3} {'ok' if n>=20 else '⚠ faltan '+str(20-n)}")
for cierre in ['Retrospectiva','Pendientes que salieron','cuaderno hermano']:
    print(f"  cierre «{cierre}»: {'ok' if cierre in s else '⚠ FALTA'}")
# dificultades y categorías
difs=re.findall(r'\*\*Dificultad:\*\* (🟢|🟡|🟠|🔴)', s)
from collections import Counter
print("  escala:", dict(Counter(difs)))
