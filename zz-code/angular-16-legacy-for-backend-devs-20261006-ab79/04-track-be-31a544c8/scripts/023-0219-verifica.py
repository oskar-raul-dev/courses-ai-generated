# rescatado de la sesión 31a544c8, 2026-09-12T02:19:45Z · Final checks on tags, style exercises and preparation forms
import re,glob
print("1) Tags de las fases base")
bad=[]
for f in sorted(glob.glob('[0-9][0-9]-*.md')):
    if f.startswith(('00-conv','00-hist')): continue
    nn=f[:2]
    if f"git tag -a fase-{nn}" not in open(f).read(): bad.append(f)
print("   sin tag correcto:", bad or "✅ ninguna")

print("\n2) Ejercicios de estilo 🧬 (la guía pide ≥2 desde la Fase 5)")
for f in sorted(glob.glob('[0-9][0-9]-*.md')):
    if f.startswith(('00-','01-','02-','03-','04-')): continue
    body=open(f).read().split('## 🧪',1)[-1].split('## 📚',1)[0]
    n=len(re.findall(r'^\d+\..*🧬', body, re.M))
    print(f"   {f:<40} {n}", "" if n>=2 else "⚠️")

print("\n3) Fases BE: comprobación 'el frontend no se toca'")
for f in sorted(glob.glob('be0*.md')):
    ok='git diff fase-10-certificados-vigencia..HEAD -- src/' in open(f).read()
    print(f"   {f:<46}", "OK" if ok else "— (no la menciona)")

print("\n4) Cuaderno BE: forma de preparación declarada por incidente")
s=open('cuaderno-incidentes-be.md').read()
for blk in re.split(r'^## Incidente ', s, flags=re.M)[1:]:
    nid=blk[:5]
    prep=blk.split('### 🔧 Preparación',1)[1].split('---',1)[0] if '### 🔧 Preparación' in blk else ''
    forma = ('rama' if 'git switch -c' in prep else
             'sql'  if 'psql -U postgres certcore <' in prep else
             '.env' if 'POSTGRES_TAG' in prep else
             'caos' if 'CHAOS=' in prep else
             'ninguna' if re.search(r'[Nn]inguna', prep) else '❌ SIN DECLARAR')
    print(f"   {nid}: {forma}")
