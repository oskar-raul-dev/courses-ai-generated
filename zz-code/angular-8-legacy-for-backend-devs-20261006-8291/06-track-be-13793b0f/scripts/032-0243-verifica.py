# rescatado de la sesión 13793b0f, 2026-09-11T02:43:58Z · Add ordering criteria to four forensic pieces
import re,io,glob
pat=re.compile(r'barat|m[aá]s caro|cuesta un vistazo|cuesta un clic|cuesta diez segundos|orden no es|lo decide el s[ií]ntoma|regla que ordena|Empieza siempre', re.I)
falt=[f for f in sorted(glob.glob('forense-fase-*.md')) if not pat.search(io.open(f,encoding='utf-8').read())]
print("piezas sin criterio de orden declarado:", falt or "ninguna")
