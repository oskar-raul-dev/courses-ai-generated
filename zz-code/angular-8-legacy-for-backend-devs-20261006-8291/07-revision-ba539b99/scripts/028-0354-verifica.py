# rescatado de la sesión ba539b99, 2026-09-11T03:54:04Z · Final link validation
import re,glob,os
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
bad=0
for f in files:
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\[([^\]]*)\]\(([^)]+)\)',l):
            tgt=m.group(2).strip()
            if tgt.startswith(('http','#','mailto')): continue
            p=tgt.split('#')[0]
            if not p: continue
            if not os.path.exists(os.path.normpath(os.path.join(os.path.dirname(f),p))):
                bad+=1; print(f'{f}:{i} -> {tgt}')
print('links rotos:',bad)
