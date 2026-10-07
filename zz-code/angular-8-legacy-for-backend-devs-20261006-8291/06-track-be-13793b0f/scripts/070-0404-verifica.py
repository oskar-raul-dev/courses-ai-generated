# rescatado de la sesión 13793b0f, 2026-09-11T04:04:41Z · Check counts declared in governing documents
import re,io,glob
print("═══ DOCUMENTOS RECTORES vs ENTREGA ═══")
real={'fases':15,'apendices':13,'forenses':15,'incidentes':20,'horas':108,'cuaderno_h':14}
for p in sorted(glob.glob('prompts/*.md')):
    s=io.open(p,encoding='utf-8').read()
    hits=[]
    for pat,esp,lbl in [(r'(\d+|catorce|quince|trece|doce|veinte|veintiún|veintiuno)\s+(?:fases)',None,'fases'),
                        (r'(\d+|trece|doce|once)\s+ap[eé]ndices',None,'apéndices'),
                        (r'(\d+|quince|catorce)\s+piezas',None,'piezas'),
                        (r'(\d+|veinte|veintiún)\s+incidentes',None,'incidentes')]:
        for m in re.finditer(pat, s, re.I):
            hits.append(f"{m.group(1)} {lbl}")
    if hits:
        from collections import Counter
        print(f"  {p.split('/')[1][:38]:40} {dict(Counter(hits))}")
