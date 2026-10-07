# rescatado de la sesión 073aaed3, 2026-10-06T00:29:55Z · 
import re,glob
for f in sorted(glob.glob("*.md")):
    for n,l in enumerate(open(f,encoding="utf-8"),1):
        if re.search(r"(?i)gu[ií]a",l) and re.search(r"(?i)(la|esta|de) gu[ií]a|gu[ií]a §",l):
            print(f,n,l.strip()[:130])
