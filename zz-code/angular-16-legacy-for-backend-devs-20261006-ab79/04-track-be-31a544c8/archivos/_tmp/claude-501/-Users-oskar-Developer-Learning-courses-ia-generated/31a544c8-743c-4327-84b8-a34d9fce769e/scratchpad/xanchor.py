import re, glob, os, unicodedata
def keep(c): return c.isalnum() or c in ' -_' or unicodedata.category(c)=='Mn'
def slug(t): return '#'+''.join(c for c in t.strip().lower() if keep(c)).replace(' ','-')
def heads(path):
    return {slug(h) for h in re.findall(r'^#{1,6} (.+?)\s*$', open(path).read(), re.M)}
cache={}
bad=[]
for f in sorted(glob.glob('*.md')+glob.glob('prompts/*.md')):
    d=os.path.dirname(f)
    for tgt,anc in re.findall(r'\]\(([^)#\s]+\.md)(#[^)\s]+)\)', open(f).read()):
        p=os.path.normpath(os.path.join(d,tgt))
        if not os.path.exists(p): bad.append((f,tgt+anc,'archivo')); continue
        if p not in cache: cache[p]=heads(p)
        if anc not in cache[p]: bad.append((f,tgt+anc,'ancla'))
print("Anclas entre archivos rotas:", len(bad))
for f,a,k in bad: print("  X",f,"->",a,f"({k})")
