# rescatado de la sesión 13793b0f, 2026-09-11T02:32:53Z · Audit appendix structure, links and incident references
import re,io,glob,os
def r(p): return io.open(p,encoding='utf-8').read()

print("=== APÉNDICES: estructura obligatoria (plantilla de apéndice) ===")
print(f"{'ap':4} {'idx':4}{'cuándo':7}{'refs':5}{'ejs':4}{'🏷️':4} {'versión cubierta'}")
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    s=r(a)
    idx='## Índice' in s or '## 📑' in s or re.search(r'^\s*-\s*\[.+\]\(#', s, re.M)
    cuando=bool(re.search(r'Cuándo usar qué|cuándo usar qué', s))
    refs=bool(re.search(r'## .*Referencias', s))
    m=re.search(r'Ejercicios?\s*\((\d+)[^\)]*\)', s)
    ejs=m.group(1) if m else '—'
    tag='🏷️' in s
    ver=re.search(r'Versi[oó]n(?:es)? cubiertas?:\s*([^\n·]*)', s)
    print(f"{a[:3]:4} {'ok ' if idx else 'NO ':4}{'ok    ' if cuando else 'NO    ':7}{'ok  ' if refs else 'NO  ':5}{ejs:4}{'ok ' if tag else 'NO ':4} {(ver.group(1).strip()[:44] if ver else '(sin línea)')}")

print("\n=== enlaces .md rotos dentro del curso ===")
mal=0
for p in glob.glob('*.md')+glob.glob('prompts/*.md'):
    s=r(p); base=os.path.dirname(p)
    for m in re.finditer(r'\]\((\.?/?[^)#\s]+\.md)\)', s):
        d=m.group(1); full=os.path.normpath(os.path.join(base,d))
        if not os.path.exists(full):
            print("  ROTO", p, "->", d); mal+=1
print("  rotos:",mal)

print("\n=== incidentes citados en forenses vs índice del cuaderno ===")
cu=r('cuaderno-incidentes.md')
ids=set(re.findall(r'^\|\s*(\d{2})\s*\|', cu, re.M))
print("  IDs en el índice del cuaderno:", len(ids), sorted(ids)[:5],'…')
cit=set()
for f in glob.glob('forense-*.md'):
    cit|=set(re.findall(r'\b(?:incidente|incidentes)\s+(\d{2})', r(f), re.I))
    cit|=set(re.findall(r'\*\*(\d{2})\*\*\s*\(', r(f)))
print("  citados en forenses:", sorted(cit))
print("  citados que NO existen:", sorted(cit-ids) or 'ninguno')
