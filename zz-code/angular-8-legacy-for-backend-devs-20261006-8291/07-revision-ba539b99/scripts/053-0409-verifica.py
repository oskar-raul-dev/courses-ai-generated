# rescatado de la sesión ba539b99, 2026-09-11T04:09:58Z · Scan for Spanish strings in logging calls
import re,glob
es=re.compile(r"(?i)\b(antes|despues|después|accion|acción|error de|guardado|cargando|pacientes?|ordenes?|órdenes?|muestras?|resultado|fallo|exito|éxito|aviso|alerta|clave|sin traducción|sin traduccion)\b")
for f in sorted(glob.glob('*.md')):
    lines=open(f,encoding='utf-8').read().split('\n'); infence=False
    for i,l in enumerate(lines,1):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        s=l.strip()
        if s.startswith(('//','#','*','<!--','|')): continue
        for m in re.finditer(r"(?:console\.(?:log|warn|error|count|info)|print|System\.out\.println|throw new \w+)\s*\(\s*['\"]([^'\"]{4,})['\"]",l):
            if es.search(m.group(1)): print(f'{f}:{i}: {s[:110]}')
