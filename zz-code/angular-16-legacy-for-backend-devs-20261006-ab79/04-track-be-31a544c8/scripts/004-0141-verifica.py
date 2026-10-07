# rescatado de la sesión 31a544c8, 2026-09-12T01:41:12Z · Verify notebook anchors
import re,unicodedata
s=open('cuaderno-incidentes-be.md').read()
heads=re.findall(r'^## (Incidente be-\d+ .*)$', s, re.M)
def anchor(t):
    t=t.lower()
    t=t.replace('*','').replace('"','').replace(':','').replace('—','').replace('⭐','').replace('·','')
    t=re.sub(r'[^\w\s-]','',t)
    t=re.sub(r'\s+','-',t.strip())
    return '#'+t
links=re.findall(r'\]\((#incidente-be-[^)]*)\)', s)
computed=[anchor(h) for h in heads]
print("headings:",len(heads),"links:",len(set(links)))
for h,c in zip(heads,computed): print(c)
print("---- links en índice ----")
for l in sorted(set(links)): print(l, "OK" if l in computed else "❌")
