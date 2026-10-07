# rescatado de la sesión ba539b99, 2026-09-11T03:41:28Z · Re-validate anchors with GitHub emoji rules
import re,glob,os
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip())
    h=h.replace('`','')
    h=re.sub(r'\*\*|\*|__|_','',h)
    s=h.lower()
    out=[]
    for c in s:
        if c=='️': out.append(c)
        elif c.isalnum() or c=='-' or c=='_': out.append(c)
        elif c.isspace(): out.append('-')
    return ''.join(out)
files=sorted(glob.glob('*.md'))
heads={}
for f in files:
    hs=set()
    for line in open(f,encoding='utf-8'):
        m=re.match(r'^#{1,6}\s+(.*)$',line)
        if m: hs.add(slug(m.group(1)))
    heads[f]=hs
bad=0
for f in files:
    for i,line in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\]\(([^)\s]*#[^)\s]+)\)',line):
            tgt=m.group(1); path,anc=tgt.split('#',1)
            tf=f if not path else os.path.normpath(os.path.join(os.path.dirname(f),path))
            if tf not in heads: continue
            if anc not in heads[tf]:
                bad+=1; print(f'{f}:{i} -> #{anc}')
print('anclas rotas:',bad)
