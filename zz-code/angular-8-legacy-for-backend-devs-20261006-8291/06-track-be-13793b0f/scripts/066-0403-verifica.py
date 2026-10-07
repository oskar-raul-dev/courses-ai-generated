# rescatado de la sesión 13793b0f, 2026-09-11T04:03:34Z · Check pending items reference existing artifacts
import re,io,glob
print("═══ PENDIENTES 📌 DE LAS FASES: ¿apuntan a algo que existe? ═══")
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p) and 'convencion' not in p and 'historia' not in p)
import os
refs=set()
for f in fases:
    s=io.open(f,encoding='utf-8').read()
    bloque=s.split('📌')[-1] if '📌' in s else ''
    for m in re.finditer(r'`([a-z0-9][a-z0-9._-]*\.(?:md|json|ts|js|sh|py|yaml|yml))`', bloque):
        refs.add((f,m.group(1)))
faltan=[(f,d) for f,d in refs if not os.path.exists(d) and not d.startswith('db.') and 'HOTFIX' not in d]
print(f"  archivos citados en 📌 que no existen: {len(faltan)}")
for f,d in sorted(faltan)[:12]: print(f"    {f} → {d}")
