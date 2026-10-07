# rescatado de la sesión ba539b99, 2026-09-11T04:02:41Z · Check phase dependency chains
import re,glob
print('=== BASE ===')
for f in sorted(glob.glob('[01][0-9]-*.md')):
    if 'convencion' in f or 'historia' in f: continue
    h='\n'.join(open(f,encoding='utf-8').read().split('\n')[:8])
    d=re.search(r'Depende de:([^\n·]*)',h); hab=re.search(r'Habilita:([^\n]*)',h)
    print(f'{f[:2]}  dep={d.group(1).strip()[:52]:<52} hab={hab.group(1).strip()[:55] if hab else "—"}')
print('\n=== BE ===')
for f in sorted(glob.glob('be0*.md')):
    h='\n'.join(open(f,encoding='utf-8').read().split('\n')[:8])
    d=re.search(r'Depende de:([^\n]*)',h); hab=re.search(r'Habilita:([^\n]*)',h)
    print(f'{f[:4]} dep={d.group(1).strip()[:56]:<56} hab={hab.group(1).strip()[:35] if hab else "—"}')
