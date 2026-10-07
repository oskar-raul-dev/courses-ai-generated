# rescatado de la sesión 70a2da9f, 2026-09-10T22:06:53Z · Check dangling section refs and broken internal links
import re,os
bad=[]
for root,d,fs in os.walk('.'):
    if '.git' in root: continue
    for f in fs:
        if not f.endswith('.md'): continue
        p=os.path.join(root,f)
        for i,l in enumerate(open(p),1):
            for m in re.findall(r'\]\(([^)#\s]+\.md)[^)]*\)', l):
                t=os.path.normpath(os.path.join(root,m))
                if not os.path.exists(t): bad.append(f"{p}:{i} -> {m}")
print('\n'.join(bad) if bad else "(ninguno)")
