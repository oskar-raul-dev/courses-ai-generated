# rescatado de la sesión ba539b99, 2026-09-11T04:03:37Z · Compare phase hooks with forensic pieces
import re,glob
for n in ['%02d'%i for i in range(15)]:
    ph=[f for f in glob.glob(f'{n}-*.md') if 'convencion' not in f and 'historia' not in f][0]
    t=open(ph,encoding='utf-8').read()
    m=re.search(r'### Pieza forense de esta fase(.*?)(?=\n## )',t,re.S)
    hook=' '.join(m.group(1).split()) if m else '??'
    print(f'--- Fase {n} ({ph})')
    print('  GANCHO:',hook[:400])
    p=open(f'forense-fase-{n}.md',encoding='utf-8').read()
    tk=re.findall(r'^### .*$',p,re.M)
    tickets=re.findall(r'^## 🎫(.*)$',p,re.M)
    print('  PIEZA 🎫:',(tickets[0].strip() if tickets else '??')[:120])
    print('  RUTAS:',re.findall(r'^## 🧭 (.*)$',p,re.M))
