# rescatado de la sesión ba539b99, 2026-09-11T03:47:07Z · Re-validate all anchors
import re,glob,os
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip()).replace('`','')
    h=re.sub(r'\*\*|\*','',h)
    out=[]
    for c in h.lower():
        if c=='️': out.append(c)
        elif c.isalnum() or c in '-_': out.append(c)
        elif c.isspace(): out.append('-')
    return ''.join(out)
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
heads={f:{slug(m.group(1)) for m in (re.match(r'^#{1,6}\s+(.*)$',l) for l in open(f,encoding='utf-8')) if m} for f in files}
bad=0
for f in files:
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\]\(([^)\s]*#[^)\s]+)\)',l):
            p,a=m.group(1).split('#',1)
            tf=f if not p else os.path.normpath(os.path.join(os.path.dirname(f),p))
            if tf in heads and a not in heads[tf]:
                bad+=1;print(f'{f}:{i} -> {m.group(1)}')
print('anclas rotas:',bad)
