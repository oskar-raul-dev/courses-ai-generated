# rescatado de la sesión 13793b0f, 2026-09-11T04:02:21Z · Verify incident index anchors and completeness
import re,io
s=io.open('cuaderno-incidentes.md',encoding='utf-8').read()
filas=re.findall(r'^\| \[(\d\d)\]\(#([^)]+)\)', s, re.M)
print(f"filas de índice: {len(filas)}")
# ¿las anclas resuelven?
def slug(t):
    t=t.strip().lower(); t=re.sub(r'`|\*\*|\*|__','',t)
    t=''.join(c if (c.isalnum() or c in ' -_') else '' for c in t)
    return t.replace(' ','-')
heads={slug(h) for h in re.findall(r'^#{2,4}\s*(.+?)\s*$', s, re.M)}
rotas=[(i,a) for i,a in filas if a not in heads]
print(f"anclas del índice rotas: {len(rotas)}")
for i,a in rotas[:5]: print("   ",i,"→ #"+a)
# ids únicos y completos
ids=[i for i,_ in filas]
print("ids duplicados:", [x for x in set(ids) if ids.count(x)>1] or 'ninguno')
print("faltan del 01 al 20:", [f'{n:02d}' for n in range(1,21) if f'{n:02d}' not in ids] or 'ninguno')
