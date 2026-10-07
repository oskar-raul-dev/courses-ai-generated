# rescatado de la sesión ba539b99, 2026-09-11T14:51:31Z · Full link validation after adding incidents
import re,glob,os
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip()).replace('`','')
    h=re.sub(r'\*\*|\*','',h); out=[]
    for c in h.lower():
        if c=='️': out.append(c)
        elif c.isalnum() or c in '-_': out.append(c)
        elif c.isspace(): out.append('-')
    return ''.join(out)
heads={f:{slug(m.group(1)) for m in (re.match(r'^#{1,6}\s+(.*)$',l) for l in open(f,encoding='utf-8')) if m} for f in files}
bl=ba=0;tot=0
for f in files:
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\[([^\]]*)\]\(([^)\s]+)\)',l):
            t=m.group(2);tot+=1
            if t.startswith(('http','mailto')):continue
            p,_,a=t.partition('#')
            tf=f if not p else os.path.normpath(os.path.join(os.path.dirname(f),p))
            if p and not os.path.exists(tf): bl+=1;print('LINK',f,i,t)
            if a and tf in heads and a not in heads[tf]: ba+=1;print('ANCLA',f,i,t)
print(f'{tot} enlaces | rotos {bl} | anclas rotas {ba}')
