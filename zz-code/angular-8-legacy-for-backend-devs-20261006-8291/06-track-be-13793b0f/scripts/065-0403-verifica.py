# rescatado de la sesión 13793b0f, 2026-09-11T04:03:11Z · Verify the BE track framing additions
import re,io,os
def r(p): return io.open(p,encoding='utf-8').read()
print("═══ §10.1 — las siete adiciones de encuadre del track BE ═══")
chk=[('README.md',['Track BE','be00','be07'],'sección del track BE'),
     ('prompts/guia-de-estilo-y-convenciones.md',['bea-NN','beNN'],'convención + anexo PHP'),
     ('prompts/alcance-del-proyecto.md',['track BE','Track BE'],'alcance con opcionalidad'),
     ('00-convencion-de-git-y-tags.md',['be-fase-'],'namespace de tags'),
     ('prompts/propuesta-fases-y-alcance.md',['propuesta-fases-backend'],'línea que apunta a la propuesta'),
     ('cuaderno-incidentes.md',['cuaderno-incidentes-be','hermano'],'nota del cuaderno hermano'),
     ('prompts/formato-cuaderno-incidentes.md',['cuaderno-incidentes-be','be-01'],'formato extendido al BE'),
     ('../CLAUDE.md',['bea-NN'],'convención registrada en la raíz')]
for f,keys,desc in chk:
    s=r(f) if os.path.exists(f) else ''
    ok=any(k in s for k in keys)
    print(f"  {'✅' if ok else '❌'} {f:48} {desc}")
print()
print("═══ §10.2 — la que toca la ficción publicada ═══")
for f in ['README.md','00-historia-del-sistema.md']:
    s=r(f)
    a2021='2021' in s; era0=('2016' in s or 'Era 0' in s)
    print(f"  {f:34} menciona 2021: {a2021} · menciona 2016/Era 0: {era0}")
