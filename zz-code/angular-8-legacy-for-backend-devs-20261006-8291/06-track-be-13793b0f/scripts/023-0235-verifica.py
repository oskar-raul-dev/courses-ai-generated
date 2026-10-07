# rescatado de la sesión 13793b0f, 2026-09-11T02:35:47Z · Check tag blocks and section cross-references
import re,io,glob
print("=== bloque 🏷️ de cada apéndice: ¿variante negativa y prefijo correcto? ===")
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    s=io.open(a,encoding='utf-8').read()
    i=s.find('🏷️')
    blk=s[i:i+420].replace('\n',' ')
    neg='no lleva tag propio' in blk or 'no lleva tag' in blk
    pref=bool(re.search(r'fase \d+:|f\d\d:|`fase', blk))
    enlace='00-convencion-de-git-y-tags.md' in blk
    print(f"  {a[:3]}  {'negativa ok' if neg else '⚠ NO dice que no lleva tag':28} {'prefijo ok' if pref else '⚠ sin prefijo de commit':24} {'enlace ok' if enlace else '⚠ sin enlace a la convención'}")

print("\n=== ¿existen las secciones citadas tipo 'A03 §7' ? ===")
refs=set()
for p in glob.glob('*.md'):
    for m in re.finditer(r'\b(A\d\d)\s*§\s*(\d+)', io.open(p,encoding='utf-8').read()):
        refs.add((m.group(1),m.group(2),p))
for ap,sec,orig in sorted(refs):
    f=glob.glob(ap.lower()+'-*.md')
    if not f: print(f"  {ap} §{sec} citado en {orig}: NO EXISTE el apéndice"); continue
    s=io.open(f[0],encoding='utf-8').read()
    hay=bool(re.search(r'^##\s*'+sec+r'[\.\s]', s, re.M)) or bool(re.search(r'^##\s*[^\n]*\b'+sec+r'\b', s, re.M))
    if not hay: print(f"  ⚠ {ap} §{sec} citado en {orig} — no encuentro esa sección")
print("  (silencio = todas resuelven)")
