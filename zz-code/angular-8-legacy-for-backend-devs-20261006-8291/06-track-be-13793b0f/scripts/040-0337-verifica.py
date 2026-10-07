# rescatado de la sesión 13793b0f, 2026-09-11T03:37:17Z · Read endings of the seven terminal steps
import re,io
casos=[('forense-fase-05.md','Paso 2 — Si dice'),('forense-fase-05.md','Paso 3 — Si dice'),
       ('forense-fase-07.md','Paso 4 (ticket 1)'),('forense-fase-07.md','Paso 5 (ticket 2)'),
       ('forense-fase-12.md','Sospechoso 1'),('forense-fase-12.md','Sospechoso 2'),('forense-fase-12.md','Sospechoso 4')]
for f,t in casos:
    s=io.open(f,encoding='utf-8').read()
    for b in re.split(r'^### ', s, flags=re.M)[1:]:
        if b.startswith(t):
            l=[x for x in b.rstrip().split('\n')]
            print(f"\n{'─'*72}\n{f} · {l[0][:64]}")
            print('\n'.join(l[-6:])[:520]); break
