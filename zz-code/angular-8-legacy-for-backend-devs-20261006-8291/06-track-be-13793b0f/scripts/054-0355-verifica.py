# rescatado de la sesión 13793b0f, 2026-09-11T03:55:08Z · Audit react-16 after the rename
import re,io,glob,os
print("═══ 4. REACT-16 TRAS EL RENOMBRADO ═══")
aps=sorted(glob.glob('bea-*.md')); fases=sorted(glob.glob('be0*.md'))
print(f"  apéndices bea-: {len(aps)} · fases be0*: {len(fases)}")
rd=io.open('README.md',encoding='utf-8').read()
falt=[a for a in aps if a not in rd]
print(f"  apéndices no listados en el README: {falt or 'ninguno'}")
# enlaces
mal=0
for p in glob.glob('*.md')+glob.glob('prompts/*.md'):
    s=io.open(p,encoding='utf-8').read(); b=os.path.dirname(p)
    for m in re.finditer(r'\]\((\.{0,2}/?[^)#\s]+\.md)\)', s):
        if not os.path.exists(os.path.normpath(os.path.join(b,m.group(1)))): mal+=1; print("   ROTO",p,m.group(1))
print(f"  enlaces .md rotos: {mal}")
# cuadernos
print(f"  cuadernos: {[f for f in glob.glob('cuaderno-*.md')]}")
# 'Usado por'
for a in aps:
    s=io.open(a,encoding='utf-8').read()
    if 'Usado por' not in s: print("   ⚠ sin línea 'Usado por':",a)
print("  líneas 'Usado por': presentes")
