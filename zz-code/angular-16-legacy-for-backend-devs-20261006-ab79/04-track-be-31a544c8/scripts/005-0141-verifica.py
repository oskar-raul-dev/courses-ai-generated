# rescatado de la sesión 31a544c8, 2026-09-12T01:41:32Z · Recompute anchors GitHub-style
import re
s=open('cuaderno-incidentes-be.md').read()
def gh(t):
    t=t.strip().lower()
    t=re.sub(r'[^\w\- ]','',t, flags=re.U)   # quita puntuación y emojis, deja letras/números/_/-/espacio
    return '#'+t.replace(' ','-')
heads=re.findall(r'^## (Incidente be-\d+ .*)$', s, re.M)
computed=[gh(h) for h in heads]
for h,c in zip(heads,computed): print(repr(h[:40]),'->',c)
links=sorted(set(re.findall(r'\]\((#incidente-be-[^)]*)\)', s)))
print('\n--- links ---')
for l in links: print(l, 'OK' if l in computed else '❌')
