# rescatado de la sesión ba539b99, 2026-09-11T04:03:07Z · Cross-check README hours against phase headers
import re,glob
hdr={}
for f in sorted(glob.glob('[01][0-9]-*.md'))+sorted(glob.glob('be0*.md')):
    if 'convencion' in f or 'historia' in f: continue
    m=re.search(r'\*\*(\d+)\s*horas?\*\*',open(f,encoding='utf-8').read().split('\n')[2])
    hdr[f]=int(m.group(1)) if m else None
bad=0
for l in open('README.md',encoding='utf-8'):
    m=re.search(r'\|\s*\[?`?([a-z0-9][a-z0-9._-]*\.md)`?\]?(?:\([^)]*\))?\s*\|\s*(\d+)h\s*\|',l)
    if m:
        f,h=m.group(1),int(m.group(2))
        if f in hdr and hdr[f]!=h: bad+=1; print('DESAJUSTE',f,'README',h,'cabecera',hdr[f])
print('desajustes de horas README↔fase:',bad)
