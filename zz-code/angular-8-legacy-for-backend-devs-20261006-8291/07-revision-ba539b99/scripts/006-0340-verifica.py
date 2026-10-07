# rescatado de la sesión ba539b99, 2026-09-11T03:40:24Z · Detect unlinked appendix mentions
import re,glob,collections
files=sorted(glob.glob('*.md'))
res=collections.defaultdict(lambda:[0,0])
unlinked=collections.defaultdict(list)
for f in files:
    for i,line in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'(?:Ap[eé]ndice\s+)?\b(A(?:0[1-9]|1[0-3]))\b',line):
            code=m.group(1).lower()
            # is there a link to that appendix file on this line?
            linked = re.search(r'\]\(\.?/?'+code+r'-[^)]*\)',line) is not None
            res[f][0 if linked else 1]+=1
            if not linked: unlinked[f].append((i,code,line.strip()[:100]))
tot_l=sum(v[0] for v in res.values()); tot_u=sum(v[1] for v in res.values())
print('menciones con link:',tot_l,' sin link:',tot_u)
for f in files:
    if res[f][1]:
        print(f'\n{f}: {res[f][1]} sin link, {res[f][0]} con link')
        for i,c,l in unlinked[f][:4]: print('   ',i,c,'|',l)
