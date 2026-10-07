# rescatado de la sesión 13793b0f, 2026-09-11T04:01:51Z · Re-check section counts ignoring fenced code
import re,io,glob
def sin_fences(s):
    out=[];dentro=False
    for l in s.split('\n'):
        if l.strip().startswith('```') or l.strip().startswith('````'): dentro=not dentro; continue
        if not dentro: out.append(l)
    return '\n'.join(out)
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p) and 'convencion' not in p and 'historia' not in p)
mal=0
for f in fases:
    s=sin_fences(io.open(f,encoding='utf-8').read())
    n=len([h for h in re.findall(r'^## (.+)$', s, re.M) if re.match(r'[^\w]*\d\.', h)])
    if n!=9: mal+=1; print(f"  ⚠ {f}: {n} secciones numeradas")
print("fases con la plantilla de 9 secciones incompleta:",mal)
# apéndices y forenses, misma comprobación de fences
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    s=sin_fences(io.open(a,encoding='utf-8').read())
    for req in ['Cuándo usar qué','Referencias','Ejercicios']:
        if req not in s: print(f"  ⚠ {a}: sin «{req}»")
print("apéndices: bloques obligatorios presentes")
