# rescatado de la sesión 073aaed3, 2026-10-06T00:29:50Z · 
import re,glob
for f in sorted(glob.glob("*.md")):
    for n,l in enumerate(open(f,encoding="utf-8"),1):
        if re.search(r"(?i)(la|esta) gu[ií]a( de estilo)?( §|\b(?! oficial| de `?sqlx| de Redux))",l) and "oficial" not in l:
            print(f,n,l.strip()[:120])
