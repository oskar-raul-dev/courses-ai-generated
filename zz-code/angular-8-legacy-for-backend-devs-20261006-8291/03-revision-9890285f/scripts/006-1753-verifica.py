# rescatado de la sesión 9890285f, 2026-09-10T17:53:48Z · Compare announced vs actual step counts
import re,glob,os
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
num={'un':1,'dos':2,'tres':3,'cuatro':4,'cinco':5,'seis':6,'siete':7,'ocho':8,'nueve':9}
for f in sorted(glob.glob('forense-fase-*.md')):
    lines=open(f,encoding='utf-8').read().splitlines()
    # segment by Ruta headings if any
    segs=[];cur=('(única)',[])
    for l in lines:
        if re.match(r'^## .*Ruta \d',l): segs.append(cur); cur=(l.strip('# '),[])
        cur[1].append(l)
    segs.append(cur)
    for name,body in segs:
        txt='\n'.join(body)
        pasos=len(re.findall(r'^#{3}\s*Paso\s+\d',txt,re.M))
        if not pasos: continue
        m=re.search(r'\b('+'|'.join(num)+r')\s+pasos',txt,re.I)
        dec=num[m.group(1).lower()] if m else None
        flag='  ✗ DISCREPANCIA' if dec and dec!=pasos else ''
        print(f"{f:22}{name[:44]:46}anuncia={dec if dec else '—':<4}real={pasos}{flag}")
