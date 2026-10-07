# rescatado de la sesión ba539b99, 2026-09-11T04:09:21Z · Verify no Spanish identifiers remain in bea-12
import re
f='bea-12-datos-de-prueba-y-volumen.md'
infence=False
for i,l in enumerate(open(f,encoding='utf-8'),1):
    if re.match(r'^\s*```',l): infence=not infence; continue
    if not infence: continue
    s=l.strip()
    if s.startswith(('//','#','echo','check')): continue
    for m in re.finditer(r'\b(?:var|function|let|const)\s+([A-Za-z_][\w]*)',l):
        w=m.group(1)
        if re.search(r'(?i)(pacient|orden|muestra|resultad|fecha|nombre|vacio|forma|huerfan|correo|conteo)',w):
            print(f'{i}: {s[:90]}')
