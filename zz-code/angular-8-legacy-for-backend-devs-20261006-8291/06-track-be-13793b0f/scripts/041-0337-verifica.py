# rescatado de la sesión 13793b0f, 2026-09-11T03:37:58Z · Get exact endings of the ten group-A steps
import re,io
casos=[('forense-fase-01.md','Paso 4 — Dentro'),('forense-fase-06.md','Paso 3 — Si es `PENDING`'),
('forense-fase-07.md','Paso 2 — ⭐'),('forense-fase-08.md','Paso 2 — Y la comprobación gemela'),
('forense-fase-09.md','Paso 2 — Las tres preguntas'),('forense-fase-09.md','Paso 1 — ¿El dato está'),
('forense-fase-12.md','Sospechoso 3'),('forense-fase-13.md','Paso 4 — ¿Y la ruta'),
('forense-fase-14.md','Paso 1 — El estado ya'),('forense-fase-14.md','Paso 3 — El caso sin logs')]
for f,t in casos:
    s=io.open(f,encoding='utf-8').read()
    for b in re.split(r'^### ', s, flags=re.M)[1:]:
        if b.startswith(t):
            l=b.rstrip().split('\n')
            print(f"\n█ {f} · {l[0][:60]}")
            print(repr('\n'.join(l[-3:]))[:330]); break
