# rescatado de la sesión 073aaed3, 2026-10-06T00:25:31Z · 
import re,glob
for f in sorted(glob.glob("*.md")):
    for n,l in enumerate(open(f,encoding="utf-8"),1):
        for m in re.finditer(r"(?i)gu[ií]a",l):
            s=l[max(0,m.start()-90):m.end()+70].strip()
            if re.search(r"(?i)(la|esta|de) gu[ií]a|gu[ií]a §|\(gu[ií]a|Gu[ií]a de Estilo",s):
                print(f"{f}:{n}: …{s}…")
