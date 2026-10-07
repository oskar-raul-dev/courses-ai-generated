# rescatado de la sesión 5d4ed58d, 2026-09-10T02:40:50Z · Final verification sweep with fresh numbers
import re, io, glob, os, unicodedata
files=[f for f in sorted(glob.glob("*.md")+glob.glob("prompts/*.md")) if f!="completado_cuaderno_incidentes.md"]
def gh(h):
    o=[]
    for c in h.strip().lower():
        if c==' ': o.append('-')
        elif c in '-_': o.append(c)
        elif unicodedata.category(c)[0] in ('L','N'): o.append(c)
    return ''.join(o)
cache={}
def heads(p):
    if p not in cache:
        seen={};res=set()
        for h in re.findall(r'^#+ (.+)$', io.open(p,encoding="utf-8").read(), re.M):
            s=gh(h);n=seen.get(s,0);seen[s]=n+1;res.add(s if n==0 else f"{s}-{n}")
        cache[p]=res
    return cache[p]
bad=0
for f in files:
    for m in re.finditer(r'\[[^\]]*\]\(([^)]+)\)', io.open(f,encoding="utf-8").read()):
        t=m.group(1)
        if t.startswith(('http','mailto:')): continue
        path,_,a=t.partition('#')
        p=os.path.normpath(os.path.join(os.path.dirname(f),path)) if path else f
        if not os.path.exists(p) or (a and a.lower() not in heads(p)): bad+=1
s=io.open("cuaderno-incidentes.md",encoding="utf-8").read()
be=io.open("cuaderno-incidentes-be.md",encoding="utf-8").read()
pat=re.compile(r'(?:^|[ (>*«"])(Mirá|Fijate|Tenés|Podés|Querés|Hacé|Andá|Dejá|Anotá|Compará|Revisá|Poné|Corré|Buscá|Probá|Usá|Acordate|Elegí|Cerrá|Volvé|Sabés|Agregá|Cambiá)(?=[ ,.;:!?)]|$)')
fases=[f for f in sorted(glob.glob("0[0-9]-*.md")+glob.glob("1[01]-*.md")+glob.glob("be0*.md")) if not f.startswith(("00-alcance","00-historia","00-convencion"))]
mal=[f for f in fases if set(range(1,10))-{int(m.group(1)) for m in re.finditer(r'^## .*?(\d)\.', io.open(f,encoding="utf-8").read(), re.M)} or "ieza forense" not in io.open(f,encoding="utf-8").read()]
print(f"archivos revisados .............. {len(files)}")
print(f"enlaces + anclas rotos .......... {bad}")
print(f"incidentes base ................. {len(re.findall(r'^## Incidente ',s,re.M))}   orden por ID: {[int(x) for x in re.findall(r'^## Incidente (\d{2})',s,re.M)]==list(range(1,21))}")
print(f"incidentes BE ................... {len(re.findall(r'^## Incidente be-',be,re.M))}")
print(f"<details> base .................. {s.count('<details>')}/{s.count('</details>')}")
print(f"hermanos marcados ............... {len(re.findall(r'Hermano del incidente `be-',s))}")
print(f"placeholders {{{{ }}}} fuera de investigación  {len(re.findall(r'^## Incidente .*\{\{', s, re.M))}")
print(f"voseo (todo el curso) ........... {sum(len(pat.findall(io.open(f,encoding='utf-8').read())) for f in files)}")
print(f"fases que incumplen plantilla ... {len(mal)} de {len(fases)}")
print(f"líneas cuaderno base / BE ....... {len(s.splitlines())} / {len(be.splitlines())}")
