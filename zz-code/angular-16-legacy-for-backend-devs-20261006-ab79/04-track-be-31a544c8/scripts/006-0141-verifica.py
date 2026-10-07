# rescatado de la sesión 31a544c8, 2026-09-12T01:41:47Z · Fix be-06 anchor and re-verify
import re
s=open('cuaderno-incidentes-be.md').read()
def gh(t):
    t=t.strip().lower(); t=re.sub(r'[^\w\- ]','',t,flags=re.U); return '#'+t.replace(' ','-')
heads=[gh(h) for h in re.findall(r'^## (Incidente be-\d+ .*)$', s, re.M)]
bad=[l for l in set(re.findall(r'\]\((#incidente-be-[^)]*)\)', s)) if l not in heads]
print("enlaces rotos:", bad or "ninguno")
print("incidentes:", len(heads))
