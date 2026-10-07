# rescatado de la sesión 13793b0f, 2026-09-11T03:38:51Z · Get exact ending of piece 02 step 4
import re,io
s=io.open('forense-fase-02.md',encoding='utf-8').read()
for b in re.split(r'^### ', s, flags=re.M)[1:]:
    if b.startswith('Paso 4 — Dónde va'):
        l=b.rstrip().split('\n'); print(repr('\n'.join(l[-4:])))
