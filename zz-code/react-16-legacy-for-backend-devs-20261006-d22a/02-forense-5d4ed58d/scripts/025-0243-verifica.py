# rescatado de la sesión 5d4ed58d, 2026-09-10T02:43:44Z · Check remaining uncovered review dimensions
import glob, io, re
for f in sorted(glob.glob("A[0-9]*.md")+glob.glob("be-a-*.md")):
    s=io.open(f,encoding="utf-8").read()
    m=re.search(r'^#+ .*Ejercicios[^\n]*\((\d+)\)', s, re.M)
    print(f"  {f}: {m.group(1) if m else 'SIN conteo'}")
