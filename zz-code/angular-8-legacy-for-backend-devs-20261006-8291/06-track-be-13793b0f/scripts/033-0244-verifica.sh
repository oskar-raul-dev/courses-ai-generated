# rescatado de la sesión 13793b0f, 2026-09-11T02:44:10Z · Locate the ordering match in piece 07
python3 -c "
import re,io
s=io.open('forense-fase-07.md',encoding='utf-8').read()
pat=re.compile(r'barat|m[aá]s caro|cuesta un vistazo|cuesta un clic|cuesta diez segundos|orden no es|lo decide el s[ií]ntoma|regla que ordena|Empieza siempre', re.I)
for m in pat.finditer(s): print(repr(s[max(0,m.start()-90):m.end()+60]))
"
