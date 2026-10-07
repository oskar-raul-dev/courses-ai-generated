# rescatado de la sesión 5d4ed58d, 2026-09-10T02:26:52Z · Check wide tables, voseo and regionalisms
import re, io, glob
files = sorted(glob.glob("*.md")+glob.glob("prompts/*.md"))
files = [f for f in files if f!="completado_cuaderno_incidentes.md"]

print("== 8. TABLAS DE MÁS DE 4 COLUMNAS (§3 de la guía) ==")
for f in files:
    for i,l in enumerate(io.open(f,encoding="utf-8"),1):
        if l.strip().startswith('|') and re.match(r'^\|[\s:\-|]+\|$', l.strip()):
            n = l.strip().strip('|').count('|')+1
            if n>4: print(f"  {f}:{i} → {n} columnas")

print("\n== 9. VOSEO (imperativos, sin \\b) ==")
pat = re.compile(r'(?:^|[ (>*«"])(Mirá|Fijate|Tenés|Podés|Querés|Hacé|Andá|Dejá|Anotá|Escribí|Compará|Revisá|Poné|Abrí|Corré|Buscá|Leé|Probá|Usá|Acordate|Tomá|Elegí|Seguí|Cerrá|Volvé|Sabés|Vení|Pedí|Contá|Agregá|Quitá|Cambiá|Guardá)(?=[ ,.;:!?)]|$)')
hits=0
for f in files:
    for i,l in enumerate(io.open(f,encoding="utf-8"),1):
        for m in pat.finditer(l):
            print(f"  {f}:{i} → {m.group(1)}"); hits+=1
print("  ninguno" if not hits else f"  ({hits})")

print("\n== 10. ESPAÑA / REGIONALISMOS ==")
pat2 = re.compile(r'\b(ordenador|vosotros|vale\b|móvil|fichero|ratón|zumo|coger el)\b', re.I)
h2=0
for f in files:
    for i,l in enumerate(io.open(f,encoding="utf-8"),1):
        for m in pat2.finditer(l):
            print(f"  {f}:{i} → {m.group(0)}"); h2+=1
print("  ninguno" if not h2 else f"  ({h2})")
