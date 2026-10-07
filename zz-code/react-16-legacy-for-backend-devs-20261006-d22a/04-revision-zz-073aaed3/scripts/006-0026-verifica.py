# rescatado de la sesión 073aaed3, 2026-10-06T00:26:09Z · 
import re,glob
for f in sorted(glob.glob("*.md")):
    t=open(f,encoding="utf-8").read()
    for m in re.finditer(r"(?i)(§\s?\d+(\.\d+)?\s+de\s+la\s*\n?\s*>?\s*gu[ií]a|gu[ií]a\s*\n?\s*>?\s*(de estilo|§)|de la\s*\n\s*>?\s*gu[ií]a)",t):
        n=t.count("\n",0,m.start())+1
        print(f,n,repr(t[m.start()-80:m.end()+40]))
