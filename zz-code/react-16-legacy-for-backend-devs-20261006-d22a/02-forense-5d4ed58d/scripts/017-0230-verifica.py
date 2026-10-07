# rescatado de la sesión 5d4ed58d, 2026-09-10T02:30:59Z · Check BE phases link their incidents from section 6
import re, io, glob
s=io.open("cuaderno-incidentes-be.md",encoding="utf-8").read()
mapa={}
for m in re.finditer(r'^\| (be-\d\d) \| (be\d\d) \|', s, re.M): mapa.setdefault(m.group(2),[]).append(m.group(1))
for f in sorted(glob.glob("be0*.md")):
    fase=f[:4]
    txt=io.open(f,encoding="utf-8").read()
    m=re.search(r'^## ⚠️ 6\..*?(?=^## 🧪 7\.)', txt, re.M|re.S); sec6=m.group(0) if m else ""
    ids=mapa.get(fase,[])
    falt=[i for i in ids if i not in sec6]
    print(f"  {f}: produce {ids or '—'}" + (f"  ⚠️ §6 no menciona {falt}" if falt else "  ✓"))
