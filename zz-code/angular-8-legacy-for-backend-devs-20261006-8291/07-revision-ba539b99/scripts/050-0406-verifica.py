# rescatado de la sesión ba539b99, 2026-09-11T04:06:55Z · Inventory Spanish identifiers in code blocks
import re,glob
sus=re.compile(r'\b(paciente|pacientes|orden|ordenes|muestra|muestras|resultado|resultados|rango|rangos|entrega|nombre|nombres|apellidos|fecha|fechas|estado|estadoPrevio|accion|accionAjena|activos|huerfan\w*|ordenesHuerfanas|generar\w+|nombreCompleto|fechaNacimiento|usuario|correo|correos)\b')
hits={}
for f in sorted(glob.glob('*.md')):
    t=open(f,encoding='utf-8').read().split('\n')
    infence=False
    for i,l in enumerate(t,1):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        s=l.strip()
        if s.startswith(('//','#','*','>')): continue
        # ignorar texto dentro de comentarios de bloque
        for m in sus.finditer(l):
            # sólo si parece identificador: precedido/seguido por sintaxis de código
            if re.search(r'(?:var|let|const|function|class)\s+'+m.group(0)+r'\b', l) or \
               re.search(r"\b"+m.group(0)+r"\b\s*(?:=|\(|:)", l) or \
               re.search(r"['\"]"+m.group(0)+r"['\"]", l):
                hits.setdefault(f,[]).append((i,s[:110]))
                break
for f,v in hits.items():
    print('==',f)
    for i,s in v: print(f'   {i}: {s}')
