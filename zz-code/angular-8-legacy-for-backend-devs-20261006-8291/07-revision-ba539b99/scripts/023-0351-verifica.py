# rescatado de la sesión ba539b99, 2026-09-11T03:51:25Z · Re-scan for remaining accent issues
import re,glob
bad=r'\b(numero|version|codigo|tambien|aqui|asi|despues|sesion|validacion|configuracion|migracion|documentacion|razon|aplicacion|ultimo|ultima|critico|critica|deberia|ademas|dia|dias|mas|habria|seria|estaria|aca|libreria|librerias|arbol|maquina|estan|sintoma|proposito|pagina|linea|peticion|traduccion|produccion|proteccion|comprobacion|decision|situacion|coleccion|suscripcion|edicion|confirmacion|comparacion|discusion)\b'
files=sorted(glob.glob('a[01][0-9]-*.md'))+sorted(glob.glob('bea-*.md'))+sorted(glob.glob('forense-*.md'))
n=0
for f in files:
    src=open(f,encoding='utf-8').read().split('\n'); infence=False
    for i,l in enumerate(src,1):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        m=re.search(r'(?://|#)\s*(.+)$',l)
        if m and re.findall(bad,m.group(1).lower()):
            n+=1; print(f'{f}:{i}: {l.strip()[:110]}')
print('restantes:',n)
