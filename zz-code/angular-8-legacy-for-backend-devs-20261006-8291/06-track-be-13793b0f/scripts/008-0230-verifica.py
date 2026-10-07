# rescatado de la sesión 13793b0f, 2026-09-11T02:30:34Z · Audit forensic pieces structure
import re,io,glob,os
def r(p): return io.open(p,encoding='utf-8').read()

print("=== FORENSES: bloques obligatorios ===")
req={'🎫':'ticket','🧭':'ruta','🩺':'diagnóstico','🧠':'patrón'}
for f in sorted(glob.glob('forense-fase-*.md')):
    s=r(f); falta=[k for k in req if k not in s]
    pasos=len(re.findall(r'^### Paso \d', s, re.M))
    desc=len(re.findall(r'\*\*Qué descarta', s))
    callej='⚰️' in s; desh='🧨' in s
    inc=sorted(set(re.findall(r'incidente\s+(\d{1,2})', s, re.I)))
    flags=[]
    if falta: flags.append('FALTA '+','.join(falta))
    if pasos!=desc: flags.append(f'pasos={pasos} descarta={desc}')
    if not callej: flags.append('sin ⚰️')
    if not desh: flags.append('sin 🧨')
    if not inc: flags.append('sin incidentes citados')
    print(f"{f:22} pasos={pasos:2} {'  '.join(flags) if flags else 'ok'}  inc={inc}")
