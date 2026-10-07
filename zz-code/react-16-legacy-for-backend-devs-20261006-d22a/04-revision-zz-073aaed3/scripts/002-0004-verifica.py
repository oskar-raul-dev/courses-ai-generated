# rescatado de la sesión 073aaed3, 2026-10-06T00:04:43Z · 
import re,glob
for f in sorted(glob.glob("*.md")):
    t=open(f,encoding="utf-8").read().split("\n")
    blk=None
    for n,l in enumerate(t,1):
        m=re.match(r"^\s*```(\w*)",l)
        if m and blk is None: blk=(n,m.group(1),[]); continue
        if blk is not None and l.strip().startswith("```"):
            n0,lang,b=blk
            if lang in("","text","txt"):
                k=sum(1 for x in b if re.search(r"(-->|==>|\+--|--\+|\|\s{2,}\||►|▶|⟶|↳|^\s*\|\s*$|^\s*v\s*$)",x))
                if k>=2: print(f"{f}:{n0} [{lang}] {k} :: {b[0][:70]!r}")
            blk=None; continue
        if blk is not None: blk[2].append(l)
