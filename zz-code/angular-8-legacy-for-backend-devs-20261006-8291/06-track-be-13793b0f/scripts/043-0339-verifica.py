# rescatado de la sesión 13793b0f, 2026-09-11T03:39:55Z · Read endings of the fifteen final steps
import re,io,glob
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    secs=re.split(r'^(## .+)$', s, flags=re.M)
    for i in range(1,len(secs),2):
        if '🧭' not in secs[i]: continue
        for b in re.split(r'^### ', secs[i+1], flags=re.M)[1:]:
            if re.search(r'\*\*Qué descarta|\*\*Aquí termina', b): continue
            l=[x for x in b.rstrip().split('\n') if x.strip()]
            print(f"\n█ {f} · {l[0][:58]}")
            print(repr(l[-1])[:300])
