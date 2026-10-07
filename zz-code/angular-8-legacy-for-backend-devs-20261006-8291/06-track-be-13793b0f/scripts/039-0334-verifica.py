# rescatado de la sesión 13793b0f, 2026-09-11T03:34:34Z · Read full text of the genuinely incomplete steps
import re,io
casos=[('forense-fase-14.md','Paso 2 — El almacén'),('forense-fase-14.md','Paso 3 — El `:latest`'),('forense-fase-02.md','Paso 4 — Dónde va'),('forense-fase-09.md','Paso 2 — Las tres preguntas')]
for f,t in casos:
    s=io.open(f,encoding='utf-8').read()
    for b in re.split(r'^### ', s, flags=re.M)[1:]:
        if b.startswith(t):
            print(f"\n{'='*70}\n{f} / {b.split(chr(10))[0][:70]}\n")
            print(b.rstrip()[:1100]); break
