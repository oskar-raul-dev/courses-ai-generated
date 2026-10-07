# rescatado de la sesión ba539b99, 2026-09-11T03:55:48Z · Final integrity validation
import re,glob,os
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip()).replace('`','')
    h=re.sub(r'\*\*|\*','',h); out=[]
    for c in h.lower():
        if c=='️': out.append(c)
        elif c.isalnum() or c in '-_': out.append(c)
        elif c.isspace(): out.append('-')
    return ''.join(out)
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
heads={f:{slug(m.group(1)) for m in (re.match(r'^#{1,6}\s+(.*)$',l) for l in open(f,encoding='utf-8')) if m} for f in files}
b1=b2=0
for f in files:
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\[([^\]]*)\]\(([^)\s]+)\)',l):
            t=m.group(2)
            if t.startswith(('http','mailto')): continue
            p,_,a=t.partition('#')
            if p:
                full=os.path.normpath(os.path.join(os.path.dirname(f),p))
                if not os.path.exists(full): b1+=1; print('LINK',f,i,t)
            tf=f if not p else os.path.normpath(os.path.join(os.path.dirname(f),p))
            if a and tf in heads and a not in heads[tf]: b2+=1; print('ANCLA',f,i,t)
print('links rotos:',b1,'anclas rotas:',b2)
