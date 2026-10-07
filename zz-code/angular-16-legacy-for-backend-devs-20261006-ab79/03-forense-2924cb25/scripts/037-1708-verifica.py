# rescatado de la sesión 2924cb25, 2026-09-11T17:08:10Z · Final verification of the BE prompt files
import re
fase=open('prompts/prompts-backend-fase.md').read(); ap=open('prompts/prompts-backend-apendice.md').read()
f2a={};cur=None
for l in fase.split('\n'):
    m=re.match(r'^## # Fase (be\d\d)',l)
    if m: cur=m.group(1)
    if cur and l.startswith('- Apéndices de apoyo:'): f2a[cur]=set(re.findall(r'bea-\d\d',l)); coll=True
    elif cur and f2a.get(cur) is not None and l.startswith('  ') and 'bea-' in l: f2a[cur]|=set(re.findall(r'bea-\d\d',l))
a2f={};cur=None
for l in ap.split('\n'):
    m=re.match(r'^## # Apéndice (bea-\d\d)',l)
    if m: cur=m.group(1)
    if cur and l.startswith('- Usado por:'): a2f[cur]=set(re.findall(r'be\d\d',l))
bad=[(a,f) for a,fs in a2f.items() for f in fs if a not in f2a.get(f,set())]
bad+=[(f,a) for f,as_ in f2a.items() for a in as_ if f not in a2f.get(a,set())]
print('asimetrías fase↔apéndice:', bad or 'ninguna')
print('incidentes reservados:', sorted(set(re.findall(r'be-\d\d', fase))))
