# rescatado de la sesión 13793b0f, 2026-09-11T02:25:58Z · Verify BE appendix links and check non-markdown references
import os,re,io
mal=0;tot=0
for root,dirs,files in os.walk('.'):
    dirs[:]=[d for d in dirs if d not in ('.git','node_modules')]
    for f in files:
        if not f.endswith('.md'): continue
        p=os.path.join(root,f)
        s=io.open(p,encoding='utf-8',errors='ignore').read()
        for m in re.finditer(r'\]\((\.?/?[^)#\s]*bea-[^)#\s]+\.md)\)', s):
            tot+=1
            if not os.path.exists(os.path.normpath(os.path.join(root,m.group(1)))):
                print("ROTO",p,"->",m.group(1)); mal+=1
print("enlaces a apéndices BE:",tot,"rotos:",mal)
