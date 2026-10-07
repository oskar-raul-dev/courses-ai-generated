# rescatado de la sesión ba539b99, 2026-09-11T03:48:02Z · Build appendix usage matrix
import re,glob,collections
m=collections.defaultdict(set)
for f in sorted(glob.glob('be0*.md')):
    t=open(f,encoding='utf-8').read()
    for a in set(re.findall(r'bea-\d{2}',t)): m[a].add(f[:4])
for a in sorted(m): print(a, sorted(m[a]))
