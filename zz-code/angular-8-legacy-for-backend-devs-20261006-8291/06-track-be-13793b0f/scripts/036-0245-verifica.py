# rescatado de la sesión 13793b0f, 2026-09-11T02:45:05Z · Add ordering criterion to piece 12 and verify all fifteen
import re,io,glob
pat=re.compile(r'barat|m[aá]s caro|cuesta un vistazo|cuesta un clic|cuesta diez segundos|cuesta segundos|cuesta un comando|orden no es|lo decide el s[ií]ntoma|regla que ordena|Empieza siempre|misma raz[oó]n|El orden es la lecci[oó]n', re.I)
falt=[]
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    i=s.find('## 🧭'); j=s.find('###', i)
    if not pat.search(s[max(0,i-700):j]): falt.append(f)
print("sin criterio de orden en la entrada:", falt or "ninguna — 15/15 ✅")
