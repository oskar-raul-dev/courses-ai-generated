# rescatado de la sesión 2924cb25, 2026-09-11T16:30:52Z · Verify reciprocal forensic links
import re,os
# comprueba que cada enlace forense del cuaderno existe y que la pieza reclama el incidente
txt=open('cuaderno-incidentes.md').read()
inc=re.findall(r'^## Incidente (\d+) .*?\n>.*?\n>.*?\n> \*\*Tiempo sugerido:\*\*(.*)$', txt, re.M)
bad=[]
for num,meta in inc:
    files=re.findall(r'forense-fase-(\d+)\.md\)', meta)
    for f in files:
        p=f'forense-fase-{f}.md'
        if not os.path.exists(p): bad.append((num,p,'no existe')); continue
        foot=[l for l in open(p) if l.startswith('**Incidentes del cuaderno')]
        if foot and re.search(r'\b0?%d\b'%int(num), foot[0]) is None:
            bad.append((num,p,'la pieza no lo reclama: '+foot[0].strip()[:90]))
print(len(inc),'incidentes con Ruta forense')
for b in bad: print(' ⚠️',b)
