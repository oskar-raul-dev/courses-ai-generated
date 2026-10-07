# rescatado de la sesión ba539b99, 2026-09-11T03:44:58Z · Find English code comments
import re,glob
eng=set('the this is are for with from that and not you your when where what have has get set return if else true false value name list new of to in on it as by be we'.split())
sp=set('el la los las de que no se es un una con para por del al en y o si como lo su sus este esta eso más pero porque cuando donde qué'.split())
for f in sorted(glob.glob('*.md')):
    t=open(f,encoding='utf-8').read()
    for block in re.findall(r'```[a-zA-Z]*\n(.*?)```',t,re.S):
        for line in block.split('\n'):
            m=re.search(r'(?://|#|\*)\s+(.+)$',line.strip())
            if not m: continue
            c=m.group(1)
            w=set(re.findall(r"[a-záéíóúñ]+",c.lower()))
            if len(w)>=4 and len(w&eng)>=2 and not (w&sp):
                print(f'{f}: {line.strip()[:110]}')
