# rescatado de la sesión 13793b0f, 2026-09-11T02:25:46Z · Verify all markdown links resolve
import os,re,io
malos=0; total=0
for root,dirs,files in os.walk('.'):
    dirs[:]=[d for d in dirs if d not in ('.git','node_modules')]
    for f in files:
        if not f.endswith('.md'): continue
        p=os.path.join(root,f)
        s=io.open(p,encoding='utf-8',errors='ignore').read()
        for m in re.finditer(r'\]\((\.?/?[^)#\s]+\.md)\)', s):
            dest=m.group(1); total+=1
            full=os.path.normpath(os.path.join(root,dest))
            if not os.path.exists(full):
                print("ROTO", p, "->", dest); malos+=1
print("enlaces .md revisados:", total, "rotos:", malos)
