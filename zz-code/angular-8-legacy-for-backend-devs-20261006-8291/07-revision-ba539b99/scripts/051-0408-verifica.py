# rescatado de la sesión ba539b99, 2026-09-11T04:08:39Z · Fix Java identifiers and scan BE for more
import re,glob
pat=re.compile(r'\b(?:var|let|const|Instant|LocalDate|ZonedDateTime|String|int|long|Document|List<[^>]*>|Date)\s+([a-záéíóúñ][A-Za-záéíóúñ]*)\s*=')
es=re.compile(r'(?i)^(paciente|muestra|orden|resultado|rango|fecha|nombre|estado|ahora|hoy|ayer|inicio|fin|cuenta|total|lista|datos|salida|entrada|respuesta|consulta|error|usuario|clave|valor|texto|conteo|huerfan|nacimiento|bogota)')
for f in sorted(glob.glob('be*.md'))+sorted(glob.glob('bea-*.md'))+['cuaderno-incidentes-be.md']:
    t=open(f,encoding='utf-8').read().split('\n'); infence=False
    for i,l in enumerate(t,1):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        for m in pat.finditer(l):
            if es.match(m.group(1)): print(f'{f}:{i}: {l.strip()[:100]}')
