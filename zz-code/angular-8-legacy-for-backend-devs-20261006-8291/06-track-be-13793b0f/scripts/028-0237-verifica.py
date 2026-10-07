# rescatado de la sesión 13793b0f, 2026-09-11T02:37:33Z · Compare phase hooks against forensic piece tickets
import re,io,glob
print("=== lo que la §6 de cada fase promete vs lo que la pieza entrega (tickets) ===")
for i in range(15):
    fs=[p for p in glob.glob('%02d-*.md'%i) if 'convencion' not in p and 'historia' not in p]
    if not fs: continue
    t=io.open(fs[0],encoding='utf-8').read()
    m=re.search(r'([^\n]*forense-fase-%02d\.md[^\n]*)'%i, t)
    promesa=' '.join(m.group(1).split())[:150] if m else '(sin gancho)'
    p=io.open('forense-fase-%02d.md'%i,encoding='utf-8').read()
    tickets=len(re.findall(r'^> \*\*(?:Ticket|El ticket)', p, re.M)) or len(re.findall(r'^\*\*Reportado por', p, re.M))
    print(f"\n  Fase {i:2} tickets en la pieza: {tickets}")
    print(f"     {promesa}")
