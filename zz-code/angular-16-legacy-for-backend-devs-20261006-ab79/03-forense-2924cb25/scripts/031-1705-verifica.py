# rescatado de la sesión 2924cb25, 2026-09-11T17:05:59Z · Verify bidirectional phase-appendix consistency
import re
fase=open('prompts/prompts-backend-fase.md').read()
ap=open('prompts/prompts-backend-apendice.md').read()
# fase -> apéndices
f2a={}
cur=None
for l in fase.split('\n'):
    m=re.match(r'^## # Fase (be\d\d)',l)
    if m: cur=m.group(1); buf=[]
    if cur and l.startswith('- Apéndices de apoyo:'): f2a[cur]=set(re.findall(r'bea-\d\d',l))
    elif cur and cur in f2a and l.startswith('  ') and 'bea-' in l: f2a[cur]|=set(re.findall(r'bea-\d\d',l))
a2f={}
cur=None
for l in ap.split('\n'):
    m=re.match(r'^## # Apéndice (bea-\d\d)',l)
    if m: cur=m.group(1)
    if cur and l.startswith('- Usado por:'): a2f[cur]=set(re.findall(r'be\d\d',l))
bad=0
for a,fs in sorted(a2f.items()):
    for f in fs:
        if a not in f2a.get(f,set()):
            print(f'⚠️ {a} dice «usado por {f}» y {f} no lo lista'); bad+=1
for f,as_ in sorted(f2a.items()):
    for a in as_:
        if f not in a2f.get(a,set()):
            print(f'⚠️ {f} lista {a} y {a} no lo reclama'); bad+=1
print('asimetrías:',bad)
