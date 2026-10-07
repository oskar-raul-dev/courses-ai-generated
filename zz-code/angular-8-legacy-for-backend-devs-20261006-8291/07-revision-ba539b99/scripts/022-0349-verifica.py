# rescatado de la sesión ba539b99, 2026-09-11T03:49:36Z · List accent fixes needed in appendices and forensics
import re,glob
bad=r'\b(numero|version|codigo|tambien|aqui|asi|despues|sesion|validacion|configuracion|migracion|documentacion|razon|aplicacion|ultimo|ultima|critico|critica|magico|deberia|ademas|dia|dias|mas|habria|seria|estaria|aun|aca|libreria|librerias|arbol|maquina|parecio|salio|estan|sintoma|proposito|pagina|automatico|practica|linea|milimetros)\b'
files=sorted(glob.glob('a[01][0-9]-*.md'))+sorted(glob.glob('bea-*.md'))+sorted(glob.glob('forense-*.md'))
for f in files:
    src=open(f,encoding='utf-8').read().split('\n')
    infence=False
    for i,line in enumerate(src,1):
        if re.match(r'^\s*```',line): infence=not infence; continue
        if not infence: continue
        m=re.search(r'(?://|#)\s*(.+)$',line)
        if not m: continue
        if re.findall(bad,m.group(1).lower()):
            print(f'{f}:{i}: {line.strip()[:130]}')
