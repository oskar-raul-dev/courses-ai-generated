# rescatado de la sesión 5d4ed58d, 2026-09-10T02:27:53Z · Re-run anchor check with correct unicode slugifier
import re, io, glob, os, unicodedata, collections
def slug(h):
    h = h.strip()
    h = ''.join(c for c in h if unicodedata.category(c)[0] in 'LNZ' or c in '- _')
    h = h.lower().strip().replace(' ', '-')
    return re.sub(r'-+','-',h).strip('-')
cache={}
def heads(p):
    if p not in cache:
        cache[p]=collections.Counter(slug(h) for h in re.findall(r'^#+ (.+)$', io.open(p,encoding="utf-8").read(), re.M))
    return cache[p]
bad=0
for f in sorted(glob.glob("*.md")+glob.glob("prompts/*.md")):
    if f=="completado_cuaderno_incidentes.md": continue
    for m in re.finditer(r'\]\(([^)]*#[^)]+)\)', io.open(f,encoding="utf-8").read()):
        path, anchor = m.group(1).split('#',1)
        if path.startswith('http'): continue
        p = os.path.normpath(os.path.join(os.path.dirname(f), path)) if path else f
        if not os.path.exists(p): print(f"  {f}: destino inexistente {m.group(1)}"); bad+=1; continue
        a = anchor.lower()
        hs = heads(p)
        if a not in hs:
            near = [h for h in hs if a[:18] in h or h[:18] in a]
            print(f"  {f}: ancla rota '#{anchor}' en {os.path.basename(p)}" + (f"  ¿será '#{near[0]}'?" if near else "")); bad+=1
print(f"\n  anclas rotas: {bad}")
