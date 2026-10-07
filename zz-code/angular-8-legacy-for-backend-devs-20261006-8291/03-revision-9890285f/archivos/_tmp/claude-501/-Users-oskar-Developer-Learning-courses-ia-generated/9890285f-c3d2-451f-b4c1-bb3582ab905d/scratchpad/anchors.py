import re,os,glob,unicodedata,collections
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
def slug(t):
    t=re.sub(r'`','',t)
    t=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',t)   # links -> text
    t=re.sub(r'[*_]','',t)
    t=t.strip().lower()
    out=''.join(c for c in t if c.isalnum() or c in ' -_' or unicodedata.category(c).startswith('M'))
    return out.replace(' ','-')
def anchors(f):
    c=collections.Counter(); s=set()
    incode=False
    for l in open(f,encoding='utf-8'):
        if l.lstrip().startswith('```') or l.lstrip().startswith('````'): incode=not incode; continue
        if incode: continue
        m=re.match(r'(#{1,6})\s+(.*?)\s*$',l)
        if m:
            a=slug(m.group(2)); n=c[a]; c[a]+=1
            s.add(a if n==0 else f"{a}-{n}")
    return s
inv={}
for f in glob.glob('*.md')+glob.glob('prompts/*.md'): inv[f]=anchors(f)
bad=[];tot=0
for f in sorted(inv):
    s=open(f,encoding='utf-8').read()
    for m in re.finditer(r'\[[^\]]*\]\(([^)]*#[^)]+)\)',s):
        t=m.group(1)
        if t.startswith('http'): continue
        path,anc=t.split('#',1); tot+=1
        tgt=f if path in ('','./') else os.path.normpath(os.path.join(os.path.dirname(f),path))
        if tgt not in inv: bad.append((f,t,'archivo no encontrado')); continue
        if anc not in inv[tgt]: bad.append((f,t,'ancla inexistente'))
print("anclas revisadas:",tot,"| rotas:",len(bad))
for b in bad[:60]: print("  ✗",b[0],"->",b[1],"|",b[2])
