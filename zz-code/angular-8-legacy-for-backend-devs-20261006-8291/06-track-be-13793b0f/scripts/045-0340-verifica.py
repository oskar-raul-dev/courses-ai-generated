# rescatado de la sesión 13793b0f, 2026-09-11T03:40:52Z · Verify structural integrity after the rewrite
import re,io,glob
# 1. ninguna pieza perdió estructura al reescribirse
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    for e in ['🎫','🧭','🩺','⚰️','🧨','🧠']:
        assert e in s, (f,e)
print("bloques obligatorios y opcionales: intactos en las 15")
# 2. conteo de marcas
d=t=0
for f in glob.glob('forense-fase-*.md'):
    s=io.open(f,encoding='utf-8').read()
    d+=len(re.findall(r'\*\*Qué descarta',s)); t+=len(re.findall(r'\*\*Aquí termina',s))
print(f"marcas: {d} «Qué descarta» · {t} «Aquí termina» · {d+t} pasos cerrados")
# 3. separadores --- no duplicados
for f in glob.glob('forense-fase-*.md'):
    s=io.open(f,encoding='utf-8').read()
    assert '---\n\n---' not in s and '---\n---' not in s, f
print("separadores: sin duplicados")
# 4. enlaces siguen bien
import os
mal=0
for p in glob.glob('*.md')+glob.glob('prompts/*.md'):
    s=io.open(p,encoding='utf-8').read(); b=os.path.dirname(p)
    for m in re.finditer(r'\]\((\.?\.?/?[^)#\s]+\.md)\)', s):
        if not os.path.exists(os.path.normpath(os.path.join(b,m.group(1)))): mal+=1; print("ROTO",p,m.group(1))
print("enlaces .md rotos:",mal)
