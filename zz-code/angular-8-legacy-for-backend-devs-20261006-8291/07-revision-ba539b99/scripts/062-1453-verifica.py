# rescatado de la sesión ba539b99, 2026-09-11T14:53:30Z · Identify incidents without a code fix
import re
t=open('cuaderno-incidentes.md',encoding='utf-8').read()
bloques=re.split(r'^## Incidente (\d{2})',t,flags=re.M)
sinfix=[]
for i in range(1,len(bloques),2):
    nn=bloques[i]; b=bloques[i+1]
    m=re.search(r'\*\*Parche mínimo\*\*\n\n(.{0,120})',b,re.S)
    head=m.group(1).replace('\n',' ') if m else ''
    if re.search(r'(?i)^\s*(\*\*)?(ninguno|no hay|\*\*no hay)',head) or 'no termina en fix' in b.lower():
        sinfix.append(nn)
print('sin fix de código:',sinfix,len(sinfix))
