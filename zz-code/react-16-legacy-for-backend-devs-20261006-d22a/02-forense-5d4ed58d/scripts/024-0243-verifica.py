# rescatado de la sesión 5d4ed58d, 2026-09-10T02:43:44Z · Check remaining uncovered review dimensions
import glob, io, re
faltan=[]
for f in sorted(glob.glob("[0-9A]*.md")+glob.glob("be*.md")):
    if f.startswith(("00-alcance","00-historia","00-convencion")): continue
    s=io.open(f,encoding="utf-8").read()
    if not re.search(r'^#+ .*Referencias', s, re.M): faltan.append(f)
print("  sin sección de Referencias:", faltan or "ninguno")
