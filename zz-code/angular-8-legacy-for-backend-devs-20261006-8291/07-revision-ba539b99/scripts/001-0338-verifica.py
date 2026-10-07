# rescatado de la sesión ba539b99, 2026-09-11T03:38:55Z · Check broken relative markdown links
import re,os,glob
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
missing={}
for f in files:
    t=open(f,encoding='utf-8').read()
    for m in re.finditer(r'\[([^\]]*)\]\(([^)]+)\)',t):
        tgt=m.group(2).strip()
        if tgt.startswith(('http://','https://','#','mailto:')): continue
        path=tgt.split('#')[0]
        if not path: continue
        base=os.path.dirname(f)
        full=os.path.normpath(os.path.join(base,path))
        if not os.path.exists(full):
            missing.setdefault(f,[]).append((m.group(1),tgt))
for f,v in missing.items():
    print(f)
    for a,b in v: print('   ',b,' <-- ',a[:60])
print('TOTAL archivos con links rotos:',len(missing))
