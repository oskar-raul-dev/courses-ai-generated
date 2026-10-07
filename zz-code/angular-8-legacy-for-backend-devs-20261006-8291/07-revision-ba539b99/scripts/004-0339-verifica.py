# rescatado de la sesión ba539b99, 2026-09-11T03:39:38Z · Find steps missing the discard clause
import re,glob
for f in sorted(glob.glob('forense-fase-*.md')):
    t=open(f,encoding='utf-8').read()
    parts=re.split(r'^### (Paso .*)$',t,flags=re.M)
    for i in range(1,len(parts),2):
        head,body=parts[i],parts[i+1]
        if 'Qué descarta' not in body:
            print(f,'|',head[:70])
