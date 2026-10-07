# rescatado de la sesión 13793b0f, 2026-09-11T02:31:01Z · Find forensic steps missing the discard clause
import re,io,glob
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    # bloques de paso: cualquier ### que abra un paso/rama/sospechoso
    pasos=re.findall(r'^### (.+)$', s, re.M)
    desc=len(re.findall(r'\*\*Qué descarta', s))
    if len(pasos)!=desc:
        print(f"\n{f}  pasos={len(pasos)} descarta={desc}")
        # ver cuál no lo tiene
        bloques=re.split(r'^### ', s, flags=re.M)[1:]
        for b in bloques:
            titulo=b.split('\n')[0][:60]
            if '**Qué descarta' not in b:
                print("   SIN 'Qué descarta' →", titulo)
