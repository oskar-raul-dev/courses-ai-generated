# rescatado de la sesión 31a544c8, 2026-09-12T02:18:14Z · Check README coverage and incident reservations
import re,glob,os
R=open('README.md').read()
# 1) archivos enlazados desde el README vs archivos reales del curso
linked={t for t in re.findall(r'\]\(([a-z0-9][^)#\s]*\.md)\)', R)}
real={f for f in glob.glob('*.md')} - {'README.md'}
print("1) README ↔ archivos")
print("   enlazados que no existen:", sorted(linked-real) or "✅ ninguno")
print("   archivos del curso no enlazados en el README:", sorted(real-linked) or "✅ ninguno")

# 2) reservas de incidentes en las fases base vs cuaderno
res=set()
for f in sorted(glob.glob('[0-9][0-9]-*.md')):
    s=open(f).read()
    tail=s.split('Reservas para el cuaderno de incidentes')[-1]
    res |= set(re.findall(r'^\|\s*\**(\d{2})\**\s*\|', tail, re.M))
cua={b[:2] for b in re.split(r'^## Incidente ', open('cuaderno-incidentes.md').read(), flags=re.M)[1:]}
print("\n2) Reservas de las fases ↔ cuaderno base")
print("   reservados sin entrada:", sorted(res-cua) or "✅ ninguno")
print("   en el cuaderno sin reserva:", sorted(cua-res) or "✅ ninguno")
print("   total incidentes:", len(cua))
