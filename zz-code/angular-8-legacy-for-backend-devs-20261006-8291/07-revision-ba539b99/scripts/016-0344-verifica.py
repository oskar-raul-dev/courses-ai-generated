# rescatado de la sesión ba539b99, 2026-09-11T03:44:31Z · Check incident ID reservation coherence
import re,glob
claim={}
for f in sorted(glob.glob('[01][0-9]-*.md')):
    if 'convencion' in f or 'historia' in f: continue
    head=''.join(open(f,encoding='utf-8').read().split('\n')[:8])
    m=re.search(r'Incidentes asociados:([^\n]*)',head)
    ids=re.findall(r'\b(\d{2})\b',m.group(1)) if m else []
    claim[f[:2]]=ids
allc=[i for v in claim.values() for i in v]
print('IDs reclamados por fases:',sorted(allc))
import collections
d=[k for k,v in collections.Counter(allc).items() if v>1]
print('IDs duplicados entre fases:',d)
print('faltan de 01..21:',[('%02d'%i) for i in range(1,22) if '%02d'%i not in allc])
for k,v in claim.items(): print(k,v)
