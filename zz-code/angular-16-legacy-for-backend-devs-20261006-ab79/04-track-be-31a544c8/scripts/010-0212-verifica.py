# rescatado de la sesión 31a544c8, 2026-09-12T02:12:35Z · Check exercise and hour totals against README claims
import re,glob
def n(f):
    m=re.search(r'^## 🧪.*?\((\d+)\)', open(f).read(), re.M); return int(m.group(1)) if m else 0
base=[f for f in sorted(glob.glob('[0-9][0-9]-*.md')) if not f.startswith('00-conv') and not f.startswith('00-hist')]
oblig=[f for f in base if not f.startswith('14-')]
ap=sorted(glob.glob('a[0-9][0-9]-*.md'))
be=sorted(glob.glob('be0*.md')); bea=sorted(glob.glob('bea-*.md'))
print("obligatorias (14):", sum(map(n,oblig)), "· README dice 410")
print("fase 14:", sum(map(n,[f for f in base if f.startswith('14-')])), "· README dice 15")
print("apéndices base (13):", sum(map(n,ap)), "· README dice 93")
print("fases BE (8):", sum(map(n,be)))
print("apéndices BE (11):", sum(map(n,bea)))
# horas
def horas(f):
    m=re.search(r'\*\*(\d+(?:[.,]\d+)?) horas?\*\*', open(f).read())
    return float(m.group(1).replace(',','.')) if m else None
print("\nhoras fases base:", sum(h for f in oblig if (h:=horas(f))), "· README dice 108")
print("horas apéndices base:", sum(h for f in ap if (h:=horas(f))), "· README dice 33")
print("horas fases BE:", sum(h for f in be if (h:=horas(f))), "· propuesta dice 72")
print("horas apéndices BE:", sum(h for f in bea if (h:=horas(f))))
