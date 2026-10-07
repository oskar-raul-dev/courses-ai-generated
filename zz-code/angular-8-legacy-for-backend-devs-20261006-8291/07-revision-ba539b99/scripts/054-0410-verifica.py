# rescatado de la sesión ba539b99, 2026-09-11T04:10:31Z · Final sweep for Spanish identifiers
import re,glob
pat=re.compile(r'\b(?:var|let|const|function|class|public\s+\w+|private\s+\w+|Instant|LocalDate|ZonedDateTime|String|int|long)\s+([A-Za-z_][\w]*)')
es=re.compile(r'(?i)(pacient|orden(?!e?r)|muestra|resultad|rango|fecha|nombre|apellid|estado|accion|vacio|forma(?!t)|huerfan|correo|conteo|hace[A-Z]|clave|guion|prueba|salida|entrada|consulta|detectaO)')
n=0
for f in sorted(glob.glob('*.md')):
    lines=open(f,encoding='utf-8').read().split('\n'); infence=False
    for i,l in enumerate(lines,1):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        if l.strip().startswith(('//','#','*','<!--')): continue
        for m in pat.finditer(l):
            if es.search(m.group(1)): n+=1; print(f'{f}:{i}: {l.strip()[:95]}')
print('restantes:',n)
