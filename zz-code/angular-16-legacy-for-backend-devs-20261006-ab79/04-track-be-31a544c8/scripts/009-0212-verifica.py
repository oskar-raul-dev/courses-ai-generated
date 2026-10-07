# rescatado de la sesión 31a544c8, 2026-09-12T02:12:19Z · Verify exercise counts across all course files
import re,glob,os
def last_num(path, start=r'^## 🧪'):
    s=open(path).read()
    m=re.search(start+r'.*?\((\d+)\)', s, re.M)
    declared=int(m.group(1)) if m else None
    body=s.split('## 🧪',1)[-1]
    body=re.split(r'^## 📚|^## 🏷|^---\n\n> 🏷', body, flags=re.M)[0]
    nums=[int(x) for x in re.findall(r'^(\d+)\.', body, re.M)]
    return declared, (max(nums) if nums else None), len(set(nums))
print(f"{'archivo':<46}{'declara':>8}{'último':>8}{'únicos':>8}  estado")
bad=[]
for f in sorted(glob.glob('[0-9][0-9]-*.md')+glob.glob('a[0-9][0-9]-*.md')+glob.glob('be0*.md')+glob.glob('bea-*.md')):
    d,l,u=last_num(f)
    ok = d is not None and d==l==u
    if not ok: bad.append(f)
    print(f"{f:<46}{str(d):>8}{str(l):>8}{str(u):>8}  {'OK' if ok else '⚠️'}")
print("\nCon problema:", bad or "ninguno")
