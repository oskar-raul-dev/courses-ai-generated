# rescatado de la sesión 13793b0f, 2026-09-11T03:41:26Z · Final full audit of the course
import re,io,glob,os
def r(p): return io.open(p,encoding='utf-8').read()
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p))
# usado por
bad=sum(1 for a in sorted(glob.glob('a[0-9][0-9]-*.md'))
        if sorted(set(int(x) for x in re.findall(r'Fase\s+(\d+)', re.search(r'Usado por:\s*([^\n·]*)',r(a)).group(1))))
        != sorted(int(p[:2]) for p in fases if (lambda h: h and re.search(r'\b'+a[:3].upper()+r'\b',h.group(1)))(re.search(r'Apéndices de apoyo:([^\n]*)',r(p)))))
print("apéndices con 'Usado por' desajustado:",bad)
# estructura apéndices
falt=[a for a in glob.glob('a[0-9][0-9]-*.md') if not ('🏷️' in r(a) and 'Referencias' in r(a) and 'usar qué' in r(a))]
print("apéndices sin estructura completa:",falt or 0)
# enlaces
mal=0
for p in glob.glob('*.md')+glob.glob('prompts/*.md'):
    s=r(p); b=os.path.dirname(p)
    for m in re.finditer(r'\]\((\.?\.?/?[^)#\s]+\.md)\)', s):
        if not os.path.exists(os.path.normpath(os.path.join(b,m.group(1)))): mal+=1
print("enlaces .md rotos:",mal)
# master indexa
m=r('forense-master.md'); print("piezas sin indexar en el master:",[f for f in glob.glob('forense-fase-*.md') if f not in m] or 0)
