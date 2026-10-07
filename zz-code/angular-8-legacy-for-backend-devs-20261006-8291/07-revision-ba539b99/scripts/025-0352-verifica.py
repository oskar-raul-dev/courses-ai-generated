# rescatado de la sesión ba539b99, 2026-09-11T03:52:04Z · Final accent cleanup and verification
import re,glob
bad=r'\b(numero|version|codigo|tambien|aqui|asi|despues|sesion|razon|ultimo|ultima|deberia|ademas|dia|dias|mas|habria|seria|aca|arbol|maquina|estan|sintoma|proposito|pagina|linea|peticion|segun|unica|unico|vivia|imagenes)\b'
n=0
for f in sorted(glob.glob('*.md')):
    src=open(f,encoding='utf-8').read().split('\n'); infence=False
    for i,l in enumerate(src,1):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        m=re.search(r'(?://|#)\s*(.+)$',l)
        if m and re.findall(bad,m.group(1).lower()): n+=1; print(f'{f}:{i}: {l.strip()[:100]}')
print('restantes:',n)
