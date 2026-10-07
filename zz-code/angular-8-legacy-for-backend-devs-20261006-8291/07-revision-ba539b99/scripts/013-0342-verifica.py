# rescatado de la sesión ba539b99, 2026-09-11T03:42:23Z · Validate section-number cross references
import re,glob,os
files=sorted(glob.glob('*.md'))
# map doc -> set of section numbers from headings
def secs(f):
    s=set()
    for line in open(f,encoding='utf-8'):
        m=re.match(r'^#{2,4}\s+(?:[^\w\s]*\s*)?(\d+(?:\.\d+)*)[.)]?\s',line)
        if m: s.add(m.group(1))
    return s
S={f:secs(f) for f in files}
def resolve(tag):
    tag=tag.lower()
    if tag.startswith('a') and len(tag)==3:
        g=glob.glob(tag+'-*.md')
    elif tag.startswith('bea'):
        g=glob.glob('bea-'+tag[-2:]+'-*.md')
    elif tag.startswith('be'):
        g=glob.glob('be'+tag[-2:]+'-*.md')
    else:
        g=glob.glob(tag+'-*.md')
    return g[0] if g else None
bad=0
pat=re.compile(r'\b(A\d{2}|bea-\d{2}|be\d{2}|Fase\s+\d{1,2})\**\s*§\s*(\d+(?:\.\d+)*)')
for f in files:
    for i,line in enumerate(open(f,encoding='utf-8'),1):
        for m in pat.finditer(line.replace('`','')):
            tag,num=m.group(1),m.group(2)
            if tag.lower().startswith('fase'):
                n=int(re.search(r'\d+',tag).group()); t=resolve('%02d'%n)
            else: t=resolve(tag)
            if not t: continue
            top=num.split('.')[0]
            if num not in S[t] and top not in S[t]:
                bad+=1; print(f'{f}:{i}  {tag} §{num}  -> {t} (no tiene esa sección)')
print('refs de sección no resolubles:',bad)
