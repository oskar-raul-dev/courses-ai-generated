# rescatado de la sesión 31a544c8, 2026-09-12T02:13:09Z · Validate all internal links and anchors
import re,glob,os
files=sorted(glob.glob('*.md')+glob.glob('prompts/*.md'))
broken=[]
for f in files:
    base=os.path.dirname(f)
    for target,anchor in re.findall(r'\]\(([^)#\s]+\.md)(#[^)\s]*)?\)', open(f).read()):
        if target.startswith('http'): continue
        p=os.path.normpath(os.path.join(base,target))
        if not os.path.exists(p): broken.append((f,target))
print("Enlaces a archivos inexistentes:", len(broken))
for b in broken[:20]: print("  ❌",b[0],"->",b[1])

# anclas internas dentro del mismo archivo
def slug(t):
    t=t.strip().lower(); t=re.sub(r'[^\w\- ]','',t,flags=re.U); return '#'+t.replace(' ','-')
badanchor=[]
for f in files:
    s=open(f).read()
    heads={slug(h) for h in re.findall(r'^#{1,6} (.+)$', s, re.M)}
    for a in re.findall(r'\]\((#[^)\s]+)\)', s):
        if a not in heads: badanchor.append((f,a))
print("\nAnclas internas rotas:", len(badanchor))
for b in badanchor[:25]: print("  ❌",b[0],b[1])
