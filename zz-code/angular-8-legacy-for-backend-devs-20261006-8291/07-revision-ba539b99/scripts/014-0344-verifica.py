# rescatado de la sesión ba539b99, 2026-09-11T03:44:09Z · Check appendix/phase reciprocity
import re,glob
# fase -> apéndices declarados en cabecera
fase_ap={}
for f in sorted(glob.glob('[01][0-9]-*.md')):
    if 'convencion' in f or 'historia' in f: continue
    n=f[:2]
    head=''.join(open(f,encoding='utf-8').read().split('\n')[:8])
    m=re.search(r'Apéndices de apoyo:([^·]*(?:·[^·]*)*?)(?:Incidentes|$)',head)
    aps=set(x.upper() for x in re.findall(r'\bA(0[1-9]|1[0-3])\b',m.group(1))) if m else set()
    fase_ap[n]=set('A'+a for a in aps)
ap_fase={}
for f in sorted(glob.glob('a[01][0-9]-*.md')):
    code=f[:3].upper()
    head=''.join(open(f,encoding='utf-8').read().split('\n')[:6])
    m=re.search(r'Usado por:([^·]*)',head)
    ns=re.findall(r'\d+',m.group(1)) if m else []
    ap_fase[code]=set('%02d'%int(x) for x in ns)
print('--- apéndice dice "usado por fase X" pero la fase no lo lista:')
for a,fs in sorted(ap_fase.items()):
    for n in sorted(fs):
        if n in fase_ap and a not in fase_ap[n]: print(f'   {a} dice Fase {n}; la fase {n} no lo lista')
print('--- fase lista apéndice que no la declara:')
for n,aps in sorted(fase_ap.items()):
    for a in sorted(aps):
        if a in ap_fase and n not in ap_fase[a]: print(f'   Fase {n} lista {a}; {a} no la nombra')
