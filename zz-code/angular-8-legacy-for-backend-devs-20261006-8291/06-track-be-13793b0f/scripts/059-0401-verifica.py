# rescatado de la sesión 13793b0f, 2026-09-11T04:01:30Z · Audit phase structure, tags and exercise counts
import re,io,glob
def r(p): return io.open(p,encoding='utf-8').read()
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p) and 'convencion' not in p and 'historia' not in p)
print("═══ FASES: plantilla de 9 secciones, tag, ejercicios ═══")
tot_h=tot_e=0
for f in fases:
    s=r(f)
    secs=[h for h in re.findall(r'^## (.+)$', s, re.M)]
    nueve=len([h for h in secs if re.match(r'[^\w]*\d\.', h)])
    tag='🏷️' in s and 'git tag -a' in s
    pend='📌' in s
    m=re.search(r'Ejercicios \((\d+)\)', s)
    n=len(re.findall(r'^\d+\. ', s.split('## 🧪')[1].split('\n## ')[0], re.M)) if '## 🧪' in s else 0
    h=re.search(r'\*\*(\d+) horas?\*\*', s)
    tot_h+=int(h.group(1)) if h else 0; tot_e+=int(m.group(1)) if m else 0
    flags=[]
    if nueve!=9: flags.append(f'{nueve} secciones numeradas')
    if not tag: flags.append('sin bloque 🏷️')
    if not pend: flags.append('sin 📌')
    if m and int(m.group(1))!=n: flags.append(f'ejercicios {m.group(1)}≠{n}')
    if not m: flags.append('sin conteo de ejercicios')
    print(f"  {f[:2]}  {h.group(1)+'h' if h else '—':4} {m.group(1) if m else '—':>3} ej  {'· '.join(flags) if flags else 'ok'}")
print(f"  TOTAL: {tot_h}h · {tot_e} ejercicios")
