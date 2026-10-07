# rescatado de la sesión 5d4ed58d, 2026-09-10T02:44:19Z · Sum declared hours per phase against the stated totals
import glob, io, re
def suma(pat, excl=()):
    t=0; det=[]
    for f in sorted(glob.glob(pat)):
        if f.startswith(excl): continue
        m=re.search(r'^\*\*(\d+) horas\*\*', io.open(f,encoding="utf-8").read(), re.M)
        if m: t+=int(m.group(1)); det.append(f"{f[:4]}={m.group(1)}")
        else: det.append(f"{f[:4]}=SIN")
    return t, det
b,db = suma("[01][0-9]-*.md", ("00-alcance","00-historia","00-convencion"))
e,de = suma("be0*.md")
print("BASE:", " ".join(db)); print(f"  suma = {b} h   (declarado: 96)  {'✅' if b==96 else '❌ NO CUADRA'}")
print("BE  :", " ".join(de)); print(f"  suma = {e} h   (declarado: 84)  {'✅' if e==84 else '❌ NO CUADRA'}")
