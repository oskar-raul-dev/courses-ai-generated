# rescatado de la sesión 31a544c8, 2026-09-12T02:19:13Z · Measure diagnostic exercise ratio per phase
import re,glob
print("Ejercicios de diagnóstico (la guía pide ≥ 1/3)")
bad=[]
for f in sorted(glob.glob('[0-9][0-9]-*.md')+glob.glob('be0*.md')):
    s=open(f).read()
    m=re.search(r'^## 🧪.*?\((\d+)\)', s, re.M)
    if not m: continue
    tot=int(m.group(1))
    body=s.split('## 🧪',1)[1].split('## 📚',1)[0]
    diag=len(re.findall(r'^\d+\.\s*\*\*Diagnóstico', body, re.M))
    ratio=diag/tot
    flag='' if ratio>=1/3 else '  ⚠️ por debajo de 1/3'
    if flag: bad.append(f)
    print(f"  {f:<46} {diag:>3}/{tot:<3} = {ratio:.0%}{flag}")
print("\nPor debajo del tercio:", bad or "✅ ninguna")
