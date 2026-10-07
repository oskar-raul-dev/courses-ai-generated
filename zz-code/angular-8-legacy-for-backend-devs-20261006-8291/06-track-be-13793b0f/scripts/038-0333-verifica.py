# rescatado de la sesión 13793b0f, 2026-09-11T03:33:57Z · Re-read all steps missing the discard marker
import re,io,glob
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    secs=re.split(r'^(## .+)$', s, flags=re.M)
    for i in range(1,len(secs),2):
        cab,cuerpo=secs[i],secs[i+1]
        if '🧭' not in cab: continue
        pasos=re.split(r'^### ', cuerpo, flags=re.M)[1:]
        for j,b in enumerate(pasos):
            if '**Qué descarta' in b: continue
            ultimo=(j==len(pasos)-1)
            l=[x for x in b.rstrip().split('\n') if x.strip()]
            print(f"\n■ {f} | {cab[3:40]} | {'ÚLTIMO' if ultimo else 'INTERMEDIO'}")
            print(f"  {l[0][:70]}")
            print("  …", ' '.join(' '.join(l[-2:]).split())[:200])
