# rescatado de la sesión 13793b0f, 2026-09-11T02:35:19Z · Sample steps to see whether they discard in substance
import re,io
casos=[('forense-fase-12.md','Sospechoso 1'),('forense-fase-14.md','Paso 2 — El almacén'),
       ('forense-fase-07.md','Paso 2 —'),('forense-fase-09.md','Paso 2 — Las tres')]
for f,t in casos:
    s=io.open(f,encoding='utf-8').read()
    for b in re.split(r'^### ', s, flags=re.M)[1:]:
        if b.startswith(t):
            l=[x for x in b.rstrip().split('\n') if x.strip()]
            print(f"\n===== {f} / {l[0][:60]}")
            print('\n'.join(l[-3:])[:450])
            break
