# rescatado de la sesión 073aaed3, 2026-10-06T00:04:31Z · 
import re,glob
R=re.compile(r"[┌┐┘└▼↓▲→←│─]")
tot=0
for f in sorted(glob.glob("*.md")+glob.glob("prompts/*.md")):
    t=open(f,encoding="utf-8").read().split("\n")
    blk=None
    for n,l in enumerate(t,1):
        m=re.match(r"^\s*```(\w*)",l)
        if m and blk is None: blk=(n,m.group(1),[]); continue
        if blk is not None and l.strip().startswith("```"):
            n0,lang,b=blk
            k=sum(1 for x in b if re.search(r"[┌┐┘▼↓]",x))
            k2=sum(1 for x in b if R.search(x))
            if k>=2 or (k2>=3 and lang in("","text")):
                tot+=1;print(f"{f}:{n0} [{lang}] box/vert={k} any={k2} :: {b[0][:70]!r}")
            blk=None; continue
        if blk is not None: blk[2].append(l)
print(tot)
