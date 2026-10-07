# rescatado de la sesión ba539b99, 2026-09-11T03:44:45Z · Check BE incident reciprocity
import re,glob
for f in sorted(glob.glob('be0*.md')):
    head=''.join(open(f,encoding='utf-8').read().split('\n')[:8])
    m=re.search(r'Incidentes asociados:([^\n]*)',head)
    print(f[:4], m.group(1).strip() if m else 'NO DECLARA')
