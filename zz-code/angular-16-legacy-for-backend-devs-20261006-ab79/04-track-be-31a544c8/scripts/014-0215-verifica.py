# rescatado de la sesión 31a544c8, 2026-09-12T02:15:56Z · Check forensic-notebook bidirectional references
import re,glob
# 1) Cada pieza forense declara qué incidentes usan su ruta
claims={}
for f in sorted(glob.glob('forense-fase-*.md')):
    s=open(f).read()
    m=re.search(r'Incidentes del cuaderno que usan esta ruta(.{0,600})', s, re.S)
    ids=set(re.findall(r'\b(?:incidente[s]?\s*)?(\d{2})\b', m.group(1))) if m else set()
    claims[f]=(m is not None, ids)
    if not m: print("⚠️ sin sección de incidentes:", f)
# 2) Cada incidente del cuaderno declara su ruta forense
s=open('cuaderno-incidentes.md').read()
inc={}
for blk in re.split(r'^## Incidente ', s, flags=re.M)[1:]:
    nid=blk[:2]
    rutas=set(re.findall(r'forense-fase-(\d{2})\.md', blk[:600]))
    inc[nid]=rutas
print(f"\nIncidentes en el cuaderno base: {len(inc)}")
sin=[k for k,v in inc.items() if not v]
print("Incidentes sin ruta forense declarada:", sin or "ninguno")
# 3) reciprocidad
prob=[]
for nid,rutas in inc.items():
    for r in rutas:
        f=f'forense-fase-{r}.md'
        if f in claims and nid not in claims[f][1]:
            prob.append(f"incidente {nid} enlaza {f} pero la pieza no lo reclama")
for f,(ok,ids) in claims.items():
    r=f[13:15]
    for nid in ids:
        if nid in inc and r not in inc[nid]:
            prob.append(f"{f} reclama el incidente {nid} pero el incidente no la enlaza")
print("\nProblemas de reciprocidad:", len(prob))
for x in prob: print("  ❌",x)
