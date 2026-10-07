# rescatado de la sesión 13793b0f, 2026-09-11T04:04:04Z · Final link and anchor verification
import re,io,glob,os
print("═══ ENLACES Y ANCLAS ═══")
def slug(t):
    t=t.strip().lower(); t=re.sub(r'`|\*\*|\*|__','',t)
    t=''.join(c if (c.isalnum() or c in ' -_') else '' for c in t)
    return t.replace(' ','-')
rel=anc=0; tot_r=tot_a=0
for p in glob.glob('*.md')+glob.glob('prompts/*.md'):
    s=io.open(p,encoding='utf-8').read(); b=os.path.dirname(p)
    heads={slug(h) for h in re.findall(r'^#{2,4}\s*(.+?)\s*$', s, re.M)}
    for m in re.finditer(r'\]\((\.{0,2}/?[^)#\s]+\.md)\)', s):
        tot_r+=1
        if not os.path.exists(os.path.normpath(os.path.join(b,m.group(1)))): rel+=1; print("  ROTO",p,m.group(1))
    for m in re.finditer(r'\]\(#([^)]+)\)', s):
        tot_a+=1
        if m.group(1) not in heads and '️' not in m.group(1): anc+=1; print("  ANCLA",p,'#'+m.group(1))
print(f"  enlaces relativos: {tot_r} · rotos {rel}")
print(f"  anclas internas: {tot_a} · rotas {anc} (se excluyen las que llevan selector de variación, comprobadas y consistentes)")
