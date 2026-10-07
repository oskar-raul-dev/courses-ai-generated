# rescatado de la sesión 13793b0f, 2026-09-11T02:44:25Z · Add ordering criterion to piece 07 and re-verify properly
import re,io,glob
# criterio: la declaración tiene que estar ANTES del primer ### de la sección de ruta
pat=re.compile(r'barat|m[aá]s caro|cuesta un vistazo|cuesta un clic|cuesta diez segundos|orden no es|lo decide el s[ií]ntoma|regla que ordena|Empieza siempre|misma raz[oó]n', re.I)
falt=[]
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    i=s.find('## 🧭'); j=s.find('###', i)
    intro=s[max(0,i-700):j] if i>=0 else ''
    if not pat.search(intro): falt.append(f)
print("piezas sin criterio de orden en la entrada de la ruta:", falt or "ninguna — 15/15")
