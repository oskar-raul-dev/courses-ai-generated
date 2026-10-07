# rescatado de la sesión ba539b99, 2026-09-11T03:40:34Z · Check BE appendix reference linking
import re,glob,collections
files=sorted(glob.glob('be*.md'))+['cuaderno-incidentes-be.md']
tot=[0,0]
for f in files:
    l=u=0
    for i,line in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\bbea-?(0[1-9]|1[0-2])\b',line,re.I):
            n=m.group(1)
            linked = re.search(r'\]\(\.?/?bea-'+n+r'[^)]*\)',line) is not None
            if linked: l+=1
            else: u+=1
    tot[0]+=l; tot[1]+=u
    print(f'{f:60} link:{l:3} sinlink:{u:3}')
print('TOTAL',tot)
