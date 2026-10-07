# rescatado de la sesión ba539b99, 2026-09-11T03:52:49Z · Verify all phase headers linked and links valid
import re,glob,os
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
bad=0
for f in files:
    t=open(f,encoding='utf-8').read()
    for m in re.finditer(r'\[([^\]]*)\]\(([^)]+)\)',t):
        tgt=m.group(2).strip()
        if tgt.startswith(('http','#','mailto')): continue
        p=tgt.split('#')[0]
        if not p: continue
        full=os.path.normpath(os.path.join(os.path.dirname(f),p))
        if not os.path.exists(full): bad+=1; print(f,'->',tgt)
print('links locales rotos:',bad)
