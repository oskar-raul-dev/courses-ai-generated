# rescatado de la sesión 13793b0f, 2026-09-11T02:31:16Z · Inspect steps missing the discard clause
import re,io
for f,titulo in [('forense-fase-01.md','Paso 4'),('forense-fase-02.md','Paso 4'),('forense-fase-13.md','Paso 4'),('forense-fase-00.md','Paso 5')]:
    s=io.open(f,encoding='utf-8').read()
    bloques=re.split(r'^### ', s, flags=re.M)[1:]
    for b in bloques:
        if b.startswith(titulo):
            lineas=[l for l in b.rstrip().split('\n') if l.strip()]
            print("=== %s / %s" % (f,lineas[0][:70]))
            print('\n'.join(lineas[-4:])[:600]); print()
