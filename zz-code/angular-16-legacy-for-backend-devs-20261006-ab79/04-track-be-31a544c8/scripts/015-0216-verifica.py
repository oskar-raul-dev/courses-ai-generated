# rescatado de la sesión 31a544c8, 2026-09-12T02:16:26Z · Recheck reciprocity with precise extraction
import re,glob
claims={}
for f in sorted(glob.glob('forense-fase-*.md')):
    s=open(f).read()
    m=re.search(r'\*\*Incidentes del cuaderno que usan esta ruta:\*\*(.*)', s)
    if not m: print("⚠️ sin sección:", f); continue
    line=m.group(1)
    line=re.sub(r'forense-fase-\d{2}\.md','',line)     # nombres de archivo
    line=re.sub(r'\bA\d{2}\b|§\s*\d+','',line)          # apéndices y secciones
    line=re.sub(r'\bFase \d+\b','',line, flags=re.I)
    ids=set(re.findall(r'\b(\d{2})\b', line))
    claims[f]=ids
s=open('cuaderno-incidentes.md').read()
inc={}
for blk in re.split(r'^## Incidente ', s, flags=re.M)[1:]:
    nid=blk[:2]
    head=blk.split('### 🎫',1)[0]
    inc[nid]=set(re.findall(r'forense-fase-(\d{2})\.md', head))
prob=[]
for nid,rutas in inc.items():
    for r in rutas:
        f=f'forense-fase-{r}.md'
        if nid not in claims.get(f,set()): prob.append(f"incidente {nid} → {f}: la pieza NO lo reclama")
for f,ids in claims.items():
    r=f[13:15]
    for nid in ids:
        if r not in inc.get(nid,set()): prob.append(f"{f} reclama {nid}: el incidente NO la enlaza")
print("Reciprocidad — problemas:", len(prob))
for x in sorted(prob): print("  ❌",x)
print("\nReclamos por pieza:")
for f in sorted(claims): print(f"  {f}: {sorted(claims[f]) or '—'}")
