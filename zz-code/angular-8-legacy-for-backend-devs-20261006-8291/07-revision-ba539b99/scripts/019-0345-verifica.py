# rescatado de la sesión ba539b99, 2026-09-11T03:45:10Z · Find Spanish comments missing accents
import re,glob
pats=r'\b(esta|estan|numero|version|codigo|solo|tambien|mas|aqui|asi|despues|aun|sesion|validacion|configuracion|migracion|documentacion|razon|esta?|aplicacion|aparecera|aparecio|aqui|aun|aunque|electronico|automatico|ultimo|ultima|aleatorio|practica|critico|critica|aritmetica|logica|magico|aun|porque|aunque)\b'
bad=r'\b(numero|version|codigo|tambien|aqui|asi|despues|sesion|validacion|configuracion|migracion|documentacion|razon|aplicacion|ultimo|ultima|critico|critica|magico|deberia|aqui|ademas|dia|dias|mas\b|habria|seria|estaria|aun\b|aca|mia|aun)\b'
for f in sorted(glob.glob('*.md')):
    t=open(f,encoding='utf-8').read()
    for block in re.findall(r'```[a-zA-Z]*\n(.*?)```',t,re.S):
        for line in block.split('\n'):
            m=re.search(r'(?://|#)\s*(.+)$',line)
            if not m: continue
            c=m.group(1)
            hits=re.findall(bad,c.lower())
            if hits: print(f'{f}: {line.strip()[:120]}   -> {set(hits)}')
