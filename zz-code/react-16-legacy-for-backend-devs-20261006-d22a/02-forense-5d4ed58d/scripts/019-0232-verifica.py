# rescatado de la sesión 5d4ed58d, 2026-09-10T02:32:02Z · Final complete verification sweep
import re, io, glob, os, unicodedata, collections
files=[f for f in sorted(glob.glob("*.md")+glob.glob("prompts/*.md")) if f!="completado_cuaderno_incidentes.md"]
def gh(h):
    h=h.strip().lower(); o=[]
    for c in h:
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

r=collections.OrderedDict()
# enlaces + anclas
bad=0
for f in files:
    for m in re.finditer(r'\[[^\]]*\]\(([^)]+)\)', io.open(f,encoding="utf-8").read()):
        t=m.group(1)
        if t.startswith(('http','mailto:')): continue
        path,_,a = t.partition('#')
        p=os.path.normpath(os.path.join(os.path.dirname(f),path)) if path else f
        if not os.path.exists(p) or (a and a.lower() not in heads(p)): print(f"  ROTO {f} -> {t}"); bad+=1
r["enlaces y anclas rotos"]=bad
# cuaderno base
s=io.open("cuaderno-incidentes.md",encoding="utf-8").read()
r["incidentes en el cuaderno base"]=len(re.findall(r'^## Incidente ',s,re.M))
r["orden por ID correcto"]= [int(x) for x in re.findall(r'^## Incidente (\d{2})',s,re.M)]==list(range(1,21))
r["<details> balanceados"]= s.count("<details>")==s.count("</details>")==80
r["hermanos marcados"]=len(re.findall(r'Hermano del incidente `be-\d\d`',s))
r["índice de síntomas 🩺"]= "## 🩺 Entrar por el síntoma" in s and "## 🩺 Entrar por el síntoma" in io.open("cuaderno-incidentes-be.md",encoding="utf-8").read()
# voseo
pat=re.compile(r'(?:^|[ (>*«"])(Mirá|Fijate|Tenés|Podés|Querés|Hacé|Andá|Dejá|Anotá|Compará|Revisá|Poné|Corré|Buscá|Probá|Usá|Acordate|Elegí|Cerrá|Volvé|Sabés|Agregá|Cambiá)(?=[ ,.;:!?)]|$)')
r["voseo"]=sum(len(pat.findall(io.open(f,encoding="utf-8").read())) for f in files)
# plantilla
falt=[]
for f in sorted(glob.glob("0[0-9]-*.md")+glob.glob("1[01]-*.md")+glob.glob("be0*.md")):
    if f.startswith(("00-alcance","00-historia","00-convencion")): continue
    txt=io.open(f,encoding="utf-8").read()
    got={int(m.group(1)) for m in re.finditer(r'^## .*?(\d)\.', txt, re.M)}
    if set(range(1,10))-got or "ieza forense" not in txt: falt.append(f)
r["fases que incumplen la plantilla de 9 secciones"]=falt or 0
for k,v in r.items(): print(f"  {k}: {v}")
