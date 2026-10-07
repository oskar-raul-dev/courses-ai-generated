# rescatado de la sesión 31a544c8, 2026-09-12T02:17:00Z · Fix incident 03 reciprocity and re-verify
import re,glob
claims={}
for f in sorted(glob.glob('forense-fase-*.md')):
    m=re.search(r'\*\*Incidentes del cuaderno que usan esta ruta:\*\*(.*)', open(f).read())
    line=m.group(1) if m else ''
    if 'ninguno' in line.lower(): claims[f]=set(); continue
    line=re.sub(r'forense-fase-\d{2}\.md|\bA\d{2}\b|§\s*\d+','',line)
    claims[f]=set(re.findall(r'\b(\d{2})\b', line))
inc={}
for blk in re.split(r'^## Incidente ', open('cuaderno-incidentes.md').read(), flags=re.M)[1:]:
    inc[blk[:2]]=set(re.findall(r'forense-fase-(\d{2})\.md', blk.split('### 🎫',1)[0]))
prob=[f"incidente {n} → forense-fase-{r}.md no lo reclama" for n,rs in inc.items() for r in rs if n not in claims.get(f'forense-fase-{r}.md',set())]
prob+=[f"forense-fase-{f[13:15]}.md reclama {n} sin reciprocidad" for f,ids in claims.items() for n in ids if f[13:15] not in inc.get(n,set())]
print("Reciprocidad forense ↔ cuaderno:", prob or "0 problemas")
