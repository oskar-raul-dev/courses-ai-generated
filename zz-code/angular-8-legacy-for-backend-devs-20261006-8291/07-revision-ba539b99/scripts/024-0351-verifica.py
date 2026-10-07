# rescatado de la sesión ba539b99, 2026-09-11T03:51:40Z · Dry run accent fixes on phases
import re,glob
MAP={'numero':'número','version':'versión','codigo':'código','tambien':'también','aqui':'aquí','asi':'así',
'Asi':'Así','despues':'después','sesion':'sesión','razon':'razón','ultimo':'último','ultima':'última',
'deberia':'debería','ademas':'además','dia':'día','dias':'días','mas':'más','habria':'habría','seria':'sería',
'aca':'acá','arbol':'árbol','maquina':'máquina','estan':'están','sintoma':'síntoma','proposito':'propósito',
'pagina':'página','linea':'línea','lineas':'líneas','rapida':'rápida','contradiccion':'contradicción','indices':'índices'}
def fixcion(w):
    lw=w.lower()
    return w[:-2]+'ó'+w[-1] if len(lw)>6 and lw.endswith(('cion','sion','xion')) else w
files=[f for f in sorted(glob.glob('[01][0-9]-*.md'))+sorted(glob.glob('be0*.md'))+['cuaderno-incidentes.md','cuaderno-incidentes-be.md']]
for f in files:
    src=open(f,encoding='utf-8').read().split('\n'); infence=False
    for i,l in enumerate(src):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        m=re.search(r'((?://|#)\s*)(.+)$',l)
        if not m: continue
        b=m.group(2)
        n=re.sub(r'\b[A-Za-zÁÉÍÓÚáéíóúñÑ]+\b',lambda w:MAP.get(w.group(0),fixcion(w.group(0))),b)
        if n!=b: print(f'{f}:{i+1}\n   - {b.strip()[:110]}\n   + {n.strip()[:110]}')
