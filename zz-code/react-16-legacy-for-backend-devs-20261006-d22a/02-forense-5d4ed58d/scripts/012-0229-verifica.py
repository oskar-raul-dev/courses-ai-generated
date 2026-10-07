# rescatado de la sesión 5d4ed58d, 2026-09-10T02:29:23Z · Verify no double prefixes and re-check all links and anchors
import re, io, glob, os, unicodedata
def gh(h):
    h=h.strip().lower(); o=[]
    for c in h:
        if c==' ': o.append('-')
        elif c in '-_': o.append(c)
        elif unicodedata.category(c)[0] in ('L','N'): o.append(c)
    return ''.join(o)
cache={}
def heads(p):
    if p not in cache:
        seen={};res=set()
        for h in re.findall(r'^#+ (.+)$', io.open(p,encoding="utf-8").read(), re.M):
            s=gh(h);n=seen.get(s,0);seen[s]=n+1;res.add(s if n==0 else f"{s}-{n}")
        cache[p]=res
    return cache[p]
bad=0
for f in [x for x in sorted(glob.glob("*.md")+glob.glob("prompts/*.md")) if x!="completado_cuaderno_incidentes.md"]:
    txt=io.open(f,encoding="utf-8").read()
    for m in re.finditer(r'\[([^\]]*)\]\(([^)]+)\)', txt):
        t=m.group(2)
        if t.startswith(('http','mailto:')): continue
        path,_,anchor = t.partition('#')
        p = os.path.normpath(os.path.join(os.path.dirname(f), path)) if path else f
        if not os.path.exists(p): print(f"  ROTO {f} -> {t}"); bad+=1; continue
        if anchor and anchor.lower() not in heads(p): print(f"  ANCLA {f} -> {t}"); bad+=1
print(f"  enlaces/anclas rotos: {bad}")
