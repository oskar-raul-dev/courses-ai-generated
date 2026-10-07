# rescatado de la sesión 13793b0f, 2026-09-11T02:35:09Z · Find non-terminal steps missing the discard marker
import re,io,glob
print("Pasos SIN '**Qué descarta**' que NO son el último de su bloque (posible hueco real):")
total_gap=0
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    # trocear por secciones ## y dentro por pasos ###
    secciones=re.split(r'^(## .+)$', s, flags=re.M)
    gaps=[]
    for i in range(1,len(secciones),2):
        cab, cuerpo = secciones[i], secciones[i+1]
        pasos=re.split(r'^### ', cuerpo, flags=re.M)[1:]
        for j,b in enumerate(pasos):
            titulo=b.split('\n')[0].strip()
            ultimo = (j==len(pasos)-1)
            if '**Qué descarta' not in b and not ultimo:
                gaps.append(titulo[:64])
    if gaps:
        total_gap+=len(gaps)
        print(f"\n  {f}")
        for g in gaps: print("    -", g)
print(f"\n  TOTAL pasos intermedios sin la marca: {total_gap}")
