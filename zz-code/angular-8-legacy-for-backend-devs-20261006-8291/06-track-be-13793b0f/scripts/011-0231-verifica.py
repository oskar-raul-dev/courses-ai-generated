# rescatado de la sesión 13793b0f, 2026-09-11T02:31:40Z · Audit cross-references between phases, appendices and forensics
import re,io,glob,os
def r(p): return io.open(p,encoding='utf-8').read()

print("=== 1. forense-master: ¿indexa las 15 piezas? ===")
m=r('forense-master.md')
for i in range(15):
    f='forense-fase-%02d.md'%i
    if f not in m: print("  NO INDEXADA:", f)
print("  (silencio = todas indexadas)")

print("\n=== 2. ¿Cada fase enlaza su pieza forense? ===")
for i in range(15):
    fase=glob.glob('%02d-*.md'%i)
    if not fase: print("  sin fase", i); continue
    s=r(fase[0]); f='forense-fase-%02d.md'%i
    if f not in s: print("  Fase %02d (%s) NO enlaza %s"%(i,fase[0],f))
print("  (silencio = todas enlazan)")

print("\n=== 3. ¿Cada apéndice está referenciado por alguna fase? ===")
fases=[p for p in glob.glob('*.md') if re.match(r'^\d\d-',p)]
cuerpo=' '.join(r(p) for p in fases)
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    base=a[:3]
    if a not in cuerpo and base.upper() not in cuerpo and base not in cuerpo:
        print("  HUÉRFANO:", a)
print("  (silencio = todos referenciados)")

print("\n=== 4. 'Usado por' de cada apéndice vs quién lo referencia de verdad ===")
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    s=r(a); base=a[:3]
    m2=re.search(r'Usado por:\s*([^\n·]*)', s)
    declara=m2.group(1).strip() if m2 else '(sin línea "Usado por")'
    reales=sorted(p[:2] for p in fases if (a in r(p) or re.search(r'\b%s\b'%base, r(p), re.I)))
    print(f"  {base}  declara: {declara[:60]:60} | lo citan fases: {','.join(reales)}")
