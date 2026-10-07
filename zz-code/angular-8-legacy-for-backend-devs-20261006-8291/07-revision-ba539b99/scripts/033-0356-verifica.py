# rescatado de la sesión ba539b99, 2026-09-11T03:56:55Z · Final section-reference validation
import re,glob
def secs(f):
    s=set()
    for line in open(f,encoding='utf-8'):
        m=re.match(r'^#{2,4}\s+(?:[^\w\s]*\s*)?(\d+(?:\.\d+)*)[.)]?\s',line)
        if m: s.add(m.group(1))
    return s
S={f:secs(f) for f in glob.glob('*.md')}
def resolve(tag):
    tag=tag.lower()
    if tag.startswith('bea'): g=glob.glob('bea-'+tag[-2:]+'-*.md')
    elif tag.startswith('be'): g=glob.glob('be'+tag[-2:]+'-*.md')
    elif tag.startswith('a'): g=glob.glob(tag+'-*.md')
    else: g=glob.glob(tag+'-*.md')
    return g[0] if g else None
pat=re.compile(r'\b(A\d{2}|bea-\d{2}|be\d{2}|Fase\s+\d{1,2})\**\s*§\s*(\d+(?:\.\d+)*)')
bad=0
for f in sorted(glob.glob('*.md')):
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in pat.finditer(l.replace('`','')):
            tag,num=m.group(1),m.group(2)
            t=resolve('%02d'%int(re.search(r'\d+',tag).group())) if tag.lower().startswith('fase') else resolve(tag)
            if not t: continue
            if num not in S[t] and num.split('.')[0] not in S[t]:
                bad+=1; print(f'{f}:{i} {tag} §{num} -> {t}')
print('refs de sección rotas:',bad)
