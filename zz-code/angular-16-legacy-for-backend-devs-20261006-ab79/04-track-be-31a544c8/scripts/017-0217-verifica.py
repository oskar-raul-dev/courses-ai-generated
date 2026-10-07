# rescatado de la sesión 31a544c8, 2026-09-12T02:17:34Z · Check reciprocity, debt destinations, doc links and sibling-course mentions
import re,glob
def claims(f):
    m=re.search(r'\*\*Incidentes del cuaderno que usan esta ruta:\*\*(.*)', open(f).read())
    if not m: return None
    line=m.group(1)
    if re.match(r'\s*ninguno directamente', line.strip(), re.I): return set()
    line=re.sub(r'forense-fase-\d{2}\.md|\bA\d{2}\b|§\s*\d+','',line)
    return set(re.findall(r'\b(\d{2})\b', line))
C={f:claims(f) for f in sorted(glob.glob('forense-fase-*.md'))}
inc={}
for blk in re.split(r'^## Incidente ', open('cuaderno-incidentes.md').read(), flags=re.M)[1:]:
    inc[blk[:2]]=set(re.findall(r'forense-fase-(\d{2})\.md', blk.split('### 🎫',1)[0]))
prob=[f"inc {n} → f-{r} sin reclamo" for n,rs in inc.items() for r in rs if n not in (C.get(f'forense-fase-{r}.md') or set())]
prob+=[f"f-{f[13:15]} reclama {n} sin vuelta" for f,ids in C.items() if ids for n in ids if f[13:15] not in inc.get(n,set())]
print("1) Reciprocidad forense ↔ cuaderno:", prob or "✅ 0 problemas")
