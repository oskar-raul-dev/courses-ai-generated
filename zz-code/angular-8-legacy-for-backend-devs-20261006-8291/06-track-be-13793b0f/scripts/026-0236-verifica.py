# rescatado de la sesión 13793b0f, 2026-09-11T02:36:47Z · Re-check internal anchors with correct slug algorithm
import re,io,glob
def slug(t):
    t=t.strip().lower()
    t=re.sub(r'`|\*\*|\*|__','',t)
    # GitHub: quita todo lo que no sea alfanumérico, guion, guion bajo o espacio (los emoji caen y dejan el espacio)
    t=''.join(c if (c.isalnum() or c in ' -_') else '' for c in t)
    return t.replace(' ','-')
mal=0; tot=0
for f in sorted(glob.glob('a[0-9][0-9]-*.md'))+sorted(glob.glob('forense-*.md'))+['README.md','cuaderno-incidentes.md']:
    s=io.open(f,encoding='utf-8').read()
    heads={slug(h) for h in re.findall(r'^#{2,4}\s*(.+?)\s*$', s, re.M)}
    for m in re.finditer(r'\]\(#([^)]+)\)', s):
        tot+=1
        if m.group(1) not in heads:
            print(f"  ROTA {f}: #{m.group(1)}"); mal+=1
print(f"anclas internas revisadas: {tot}  rotas: {mal}")
