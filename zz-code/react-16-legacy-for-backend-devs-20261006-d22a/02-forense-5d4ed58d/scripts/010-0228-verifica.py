# rescatado de la sesión 5d4ed58d, 2026-09-10T02:28:16Z · Anchor check with GitHub's real slug algorithm
import re, io, glob, os, unicodedata
def gh_slug(h):
    h = h.strip().lower()
    out=[]
    for c in h:
        if c in ' -_' : out.append('-' if c==' ' else c)
        elif unicodedata.category(c)[0] in ('L','N') or c=='_': out.append(c)
    return ''.join(out)
cache={}
def heads(p):
    if p not in cache:
        seen={}; res=set()
        for h in re.findall(r'^#+ (.+)$', io.open(p,encoding="utf-8").read(), re.M):
            s=gh_slug(h); n=seen.get(s,0); seen[s]=n+1
            res.add(s if n==0 else f"{s}-{n}")
        cache[p]=res
    return cache[p]
bad=[]
for f in sorted(glob.glob("*.md")+glob.glob("prompts/*.md")):
    if f=="completado_cuaderno_incidentes.md": continue
    for m in re.finditer(r'\]\(([^)]*#[^)]+)\)', io.open(f,encoding="utf-8").read()):
        path, anchor = m.group(1).split('#',1)
        if path.startswith('http'): continue
        p = os.path.normpath(os.path.join(os.path.dirname(f), path)) if path else f
        if not os.path.exists(p): bad.append((f,m.group(1),"destino inexistente")); continue
        if anchor.lower() not in heads(p):
            cand=[h for h in heads(p) if anchor.lower()[:20] in h or h[:20] in anchor.lower()]
            bad.append((f,'#'+anchor, f"¿'#{cand[0]}'?" if cand else "sin candidato"))
for f,a,s in bad: print(f"  {f}: {a}  → {s}")
print(f"\n  anclas realmente rotas: {len(bad)}")
