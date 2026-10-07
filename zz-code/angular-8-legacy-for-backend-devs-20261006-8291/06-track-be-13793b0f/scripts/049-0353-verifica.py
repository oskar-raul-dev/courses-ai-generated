# rescatado de la sesión 13793b0f, 2026-09-11T03:53:31Z · Verify the bea- rename left no loose ends
import re,io,os,glob
print("═══ 2. RENOMBRADO bea- ═══")
restos=[]
for root,dirs,files in os.walk('.'):
    dirs[:]=[d for d in dirs if d not in ('.git','node_modules')]
    for f in files:
        if not f.endswith('.md'): continue
        p=os.path.join(root,f); s=io.open(p,encoding='utf-8',errors='ignore').read()
        for m in re.finditer(r'be-a-\S*', s):
            ctx=s[max(0,m.start()-120):m.start()]
            documentado = ('🪦' in ctx or 'Renombrad' in ctx or 'used to be' in ctx or 'era `be-a' in ctx or 'convención era' in ctx)
            restos.append((p,m.group(0)[:22],documentado))
doc=[r for r in restos if r[2]]; sin=[r for r in restos if not r[2]]
print(f"  ocurrencias de 'be-a-': {len(restos)} → {len(doc)} en notas 🪦 documentadas, {len(sin)} sin documentar")
for p,t,_ in sin[:8]: print("     ⚠",p,t)
print(f"  archivos bea-*.md: {len(glob.glob('*/bea-*.md'))}")
mal=0
for root,dirs,files in os.walk('.'):
    dirs[:]=[d for d in dirs if d not in ('.git','node_modules')]
    for f in files:
        if not f.endswith('.md'): continue
        p=os.path.join(root,f); s=io.open(p,encoding='utf-8',errors='ignore').read()
        for m in re.finditer(r'\]\(([^)#\s]*bea-[^)#\s]+\.md)\)', s):
            if not os.path.exists(os.path.normpath(os.path.join(root,m.group(1)))): print("     ROTO",p,m.group(1)); mal+=1
print(f"  enlaces a apéndices bea- rotos: {mal}")
