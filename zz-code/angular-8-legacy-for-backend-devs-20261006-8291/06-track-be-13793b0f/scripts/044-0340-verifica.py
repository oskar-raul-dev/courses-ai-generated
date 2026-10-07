# rescatado de la sesión 13793b0f, 2026-09-11T03:40:03Z · Read substantive endings of the final steps
import re,io,glob
# Para escribir un cierre fiel necesito la penúltima frase real de cada bloque
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    secs=re.split(r'^(## .+)$', s, flags=re.M)
    for i in range(1,len(secs),2):
        if '🧭' not in secs[i]: continue
        for b in re.split(r'^### ', secs[i+1], flags=re.M)[1:]:
            if re.search(r'\*\*Qué descarta|\*\*Aquí termina', b): continue
            l=[x for x in b.rstrip().split('\n') if x.strip() and x.strip()!='---']
            print(f"\n█ {f} · {l[0][:56]}")
            print(' '.join(' '.join(l[-2:]).split())[:270])
