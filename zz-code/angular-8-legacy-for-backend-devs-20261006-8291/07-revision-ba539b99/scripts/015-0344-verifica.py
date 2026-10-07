# rescatado de la sesión ba539b99, 2026-09-11T03:44:20Z · Check BE appendix/phase reciprocity
import re,glob
fase_ap={}
for f in sorted(glob.glob('be0*.md')):
    n=f[:4]
    head=''.join(open(f,encoding='utf-8').read().split('\n')[:8])
    m=re.search(r'Apéndices de apoyo:(.*?)(?:Incidentes|$)',head)
    fase_ap[n]=set(re.findall(r'bea-\d{2}',m.group(1))) if m else set()
ap_fase={}
for f in sorted(glob.glob('bea-*.md')):
    code=f[:6]
    head=''.join(open(f,encoding='utf-8').read().split('\n')[:6])
    m=re.search(r'Usado por:(.*?)·',head+'·')
    ap_fase[code]=set(re.findall(r'be0\d',m.group(1))) if m else set()
for n,v in fase_ap.items(): print(n,sorted(v))
print()
for a,v in ap_fase.items(): print(a,sorted(v))
print('--- apéndice dice usado por X pero X no lo lista:')
for a,fs in sorted(ap_fase.items()):
    for n in sorted(fs):
        if a not in fase_ap.get(n,set()): print(f'   {a} dice {n}; {n} no lo lista en su cabecera')
print('--- fase lista apéndice que no la nombra:')
for n,aps in sorted(fase_ap.items()):
    for a in sorted(aps):
        if n not in ap_fase.get(a,set()): print(f'   {n} lista {a}; {a} no lo nombra')
