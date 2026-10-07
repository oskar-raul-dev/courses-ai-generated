# rescatado de la sesión 13793b0f, 2026-09-11T03:53:15Z · Repo-wide broken link audit by course
import re,io,os,glob
print("═══ 1. ENLACES .md EN TODO EL REPO ═══")
rotos={}
for root,dirs,files in os.walk('.'):
    dirs[:]=[d for d in dirs if d not in ('.git','node_modules')]
    for f in files:
        if not f.endswith('.md'): continue
        p=os.path.join(root,f); s=io.open(p,encoding='utf-8',errors='ignore').read()
        for m in re.finditer(r'\]\((\.{0,2}/?[^)#\s]+\.md)\)', s):
            if not os.path.exists(os.path.normpath(os.path.join(root,m.group(1)))):
                rotos.setdefault(root.split('/')[1] if '/' in root else '(raíz)',[]).append((p,m.group(1)))
for curso,lst in sorted(rotos.items()):
    print(f"  {curso}: {len(lst)}")
    for p,d in lst[:3]: print(f"     {p} -> {d}")
    if len(lst)>3: print(f"     … y {len(lst)-3} más")
if not rotos: print("  ninguno")
