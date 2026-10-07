# Comandos Bash de la sesión ba539b99-1109-4792-8e3e-93ac9d2547da, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-11T03:37:14 · Read course README and list prompts
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs && ls prompts && echo "=== README ===" && cat README.md

# --- 2026-09-11T03:37:18 · Count lines of all course docs
wc -l *.md prompts/*.md | sort -n | tail -50

# --- 2026-09-11T03:37:20 · Read course style guide
cat prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-11T03:37:23 · Read style guide body
sed -n '60,500p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-11T03:37:25 · Read rest of style guide
sed -n '500,828p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-11T03:37:29 · Check incident notebook and git status
wc -l cuaderno-incidentes.md; head -60 cuaderno-incidentes.md; echo "=== git status ==="; cd .. && git status --short -- angular-8-legacy-for-backend-devs | head -40

# --- 2026-09-11T03:38:55 · Check broken relative markdown links
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs && python3 - <<'EOF'
import re,os,glob
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
missing={}
for f in files:
    t=open(f,encoding='utf-8').read()
    for m in re.finditer(r'\[([^\]]*)\]\(([^)]+)\)',t):
        tgt=m.group(2).strip()
        if tgt.startswith(('http://','https://','#','mailto:')): continue
        path=tgt.split('#')[0]
        if not path: continue
        base=os.path.dirname(f)
        full=os.path.normpath(os.path.join(base,path))
        if not os.path.exists(full):
            missing.setdefault(f,[]).append((m.group(1),tgt))
for f,v in missing.items():
    print(f)
    for a,b in v: print('   ',b,' <-- ',a[:60])
print('TOTAL archivos con links rotos:',len(missing))
EOF

# --- 2026-09-11T03:39:02 · Search for stale backend filename conventions
echo "=== be-a- leftovers ==="; grep -rn "be-a-[0-9]" . || echo none; echo "=== beaNN sin guion ==="; grep -rEn "bea[0-9]{2}" . || echo none; echo "=== forense-be ==="; grep -rn "forense-be" . || echo none

# --- 2026-09-11T03:39:08 · Find mentions of nonexistent md files
python3 - <<'EOF'
import re,os,glob,collections
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
exist=set(os.path.basename(p) for p in glob.glob('*.md'))|set(os.path.basename(p) for p in glob.glob('prompts/*.md'))
bad=collections.defaultdict(list)
for f in files:
    for i,line in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'`([A-Za-z0-9_./-]+\.md)`',line):
            name=os.path.basename(m.group(1))
            if name not in exist and not re.search(r'NN|<|\*',name):
                bad[m.group(1)].append(f'{f}:{i}')
for k,v in sorted(bad.items()):
    print(k, '->', ', '.join(v[:6]), '' if len(v)<=6 else f'(+{len(v)-6})')
EOF

# --- 2026-09-11T03:39:18 · Check tag block and exercise headers in appendices/forensics
for f in forense-master.md forense-fase-*.md a0*.md a1*.md bea-*.md; do n=$(grep -c "🏷️" "$f"); ej=$(grep -oE "Ejercicios \(([0-9]+)\)" "$f" | head -1); echo "$f | tag:$n | $ej"; done

# --- 2026-09-11T03:39:23 · Read forensic pieces format spec
cat prompts/formato-piezas-forenses.md

# --- 2026-09-11T03:39:29 · Structural check of forensic pieces
for f in forense-fase-*.md; do
 l=$(wc -l < "$f"); pasos=$(grep -cE "^### Paso " "$f"); tk=$(grep -c "🎫" "$f"); diag=$(grep -c "🩺" "$f"); cal=$(grep -c "⚰️" "$f"); des=$(grep -c "🧨" "$f"); pat=$(grep -c "🧠" "$f"); desc=$(grep -c "Qué descarta" "$f");
 printf "%-20s lin:%4s pasos:%s descarta:%s 🎫%s 🩺%s ⚰️%s 🧨%s 🧠%s\n" "$f" "$l" "$pasos" "$desc" "$tk" "$diag" "$cal" "$des" "$pat"; done

# --- 2026-09-11T03:39:38 · Find steps missing the discard clause
python3 - <<'EOF'
import re,glob
for f in sorted(glob.glob('forense-fase-*.md')):
    t=open(f,encoding='utf-8').read()
    parts=re.split(r'^### (Paso .*)$',t,flags=re.M)
    for i in range(1,len(parts),2):
        head,body=parts[i],parts[i+1]
        if 'Qué descarta' not in body:
            print(f,'|',head[:70])
EOF

# --- 2026-09-11T03:39:45 · Inspect steps lacking discard clause
echo "##### F02"; sed -n '/^### Paso 5/,/^### Paso 6/p' forense-fase-02.md; echo "##### F07 p6"; sed -n '/^### Paso 6/,/^## /p' forense-fase-07.md | head -40

# --- 2026-09-11T03:39:54 · Check bidirectional links phases vs forensic pieces
echo "=== fase -> su pieza ==="; for n in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do f=$(ls ${n}-*.md 2>/dev/null); c=$(grep -c "forense-fase-$n.md" "$f"); echo "$f -> forense-fase-$n: $c"; done
echo "=== master indexa piezas ==="; for n in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do printf "%s:%s " $n $(grep -c "forense-fase-$n.md" forense-master.md); done; echo
echo "=== pieza -> su fase y master ==="; for n in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do ph=$(ls ${n}-*.md); echo "forense-fase-$n: fase=$(grep -c "$ph" forense-fase-$n.md) master=$(grep -c "forense-master.md" forense-fase-$n.md)"; done

# --- 2026-09-11T03:39:59 · Check phase 0 forensic link
grep -n "forense" 00-setup-hola-mundo.md | head; echo "---- historia"; grep -n "forense" 00-historia-del-sistema.md | head

# --- 2026-09-11T03:40:06 · Inbound references to each base appendix
echo "=== quién referencia cada apéndice base ==="; for a in a0*.md a1*.md; do echo "$a <= $(grep -l "$a" *.md | grep -v "^$a$" | tr '\n' ' ')"; done

# --- 2026-09-11T03:40:14 · Count appendix mentions per phase
grep -rnoE "Ap[eé]ndice [ -]?A[0-9]+|\*\*A[0-9]{2}\*\*|A0[1-9]\b|A1[0-3]\b" [01]*-*.md | awk -F: '{print $1}' | sort | uniq -c

# --- 2026-09-11T03:40:24 · Detect unlinked appendix mentions
python3 - <<'EOF'
import re,glob,collections
files=sorted(glob.glob('*.md'))
res=collections.defaultdict(lambda:[0,0])
unlinked=collections.defaultdict(list)
for f in files:
    for i,line in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'(?:Ap[eé]ndice\s+)?\b(A(?:0[1-9]|1[0-3]))\b',line):
            code=m.group(1).lower()
            # is there a link to that appendix file on this line?
            linked = re.search(r'\]\(\.?/?'+code+r'-[^)]*\)',line) is not None
            res[f][0 if linked else 1]+=1
            if not linked: unlinked[f].append((i,code,line.strip()[:100]))
tot_l=sum(v[0] for v in res.values()); tot_u=sum(v[1] for v in res.values())
print('menciones con link:',tot_l,' sin link:',tot_u)
for f in files:
    if res[f][1]:
        print(f'\n{f}: {res[f][1]} sin link, {res[f][0]} con link')
        for i,c,l in unlinked[f][:4]: print('   ',i,c,'|',l)
EOF

# --- 2026-09-11T03:40:34 · Check BE appendix reference linking
python3 - <<'EOF'
import re,glob,collections
files=sorted(glob.glob('be*.md'))+['cuaderno-incidentes-be.md']
tot=[0,0]
for f in files:
    l=u=0
    for i,line in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\bbea-?(0[1-9]|1[0-2])\b',line,re.I):
            n=m.group(1)
            linked = re.search(r'\]\(\.?/?bea-'+n+r'[^)]*\)',line) is not None
            if linked: l+=1
            else: u+=1
    tot[0]+=l; tot[1]+=u
    print(f'{f:60} link:{l:3} sinlink:{u:3}')
print('TOTAL',tot)
EOF
echo "=== ejemplo cabecera be03 ==="; sed -n '1,12p' be03-la-costura-y-el-reemplazo.md

# --- 2026-09-11T03:40:45 · Check cross-track references
echo "== quién referencia 00-historia-del-sistema.md =="; grep -ln "00-historia-del-sistema" *.md prompts/*.md
echo; echo "== quién referencia el track BE desde el track base =="; grep -ln "be0[0-8]\|bea-" [0-9]*.md a*.md forense*.md cuaderno-incidentes.md 2>/dev/null
echo; echo "== quién referencia cuaderno-incidentes.md =="; grep -lc "cuaderno-incidentes.md" *.md | head -40

# --- 2026-09-11T03:40:49 · Inspect history doc and README mentions
head -30 00-historia-del-sistema.md; echo "=== menciones en README ==="; grep -n "historia-del-sistema\|00-historia" README.md

# --- 2026-09-11T03:40:55 · Check appendix section conformance
for f in a0*.md a1*.md bea-*.md; do printf "%-58s" "$f"; for k in "Qué queda fuera" "Cuándo usar qué\|cuándo usar qué\|Guía de decisión\|cuándo usar" "Ejercicios" "🏷️" "Referencias"; do if grep -q "$k" "$f"; then printf " ✓"; else printf " ✗"; fi; done; echo "  [fuera|cuando|ej|tag|ref]"; done

# --- 2026-09-11T03:41:01 · Inspect appendix section gaps
echo "== a12 'cuándo usar' =="; grep -nE "^## " a12-arm64-m1.md; echo; echo "== bea-09 'qué queda fuera' =="; sed -n '1,25p' bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md; echo; echo "== bea-11 referencias =="; grep -nE "^## " bea-11-mapa-de-deuda-del-track-be.md

# --- 2026-09-11T03:41:12 · Validate in-document anchor links
python3 - <<'EOF'
import re,glob,unicodedata,os
def slug(h):
    h=h.strip()
    h=re.sub(r'`','',h)
    h=re.sub(r'\*\*|\*|_','',h)
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h)
    s=h.lower()
    s=''.join(c for c in s if c.isalnum() or c in ' -_̀-ͯ' or unicodedata.category(c)=='Mn' or ord(c)>127)
    # github: remove punctuation, spaces->-
    s=re.sub(r'[^\w\s-]','',s,flags=re.U)
    s=re.sub(r'\s','-',s)
    return s
files=sorted(glob.glob('*.md'))
heads={}
for f in files:
    hs=set()
    for line in open(f,encoding='utf-8'):
        m=re.match(r'^#{1,6}\s+(.*)$',line)
        if m: hs.add(slug(m.group(1)))
    heads[f]=hs
bad=0
for f in files:
    for i,line in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\]\(([^)]*#[^)]+)\)',line):
            tgt=m.group(1)
            path,anc=tgt.split('#',1)
            tf = f if not path else os.path.normpath(os.path.join(os.path.dirname(f),path))
            if tf not in heads: continue
            if anc not in heads[tf]:
                bad+=1
                print(f'{f}:{i}  ->  {tgt}')
print('anclas rotas:',bad)
EOF

# --- 2026-09-11T03:41:28 · Re-validate anchors with GitHub emoji rules
python3 - <<'EOF'
import re,glob,os
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip())
    h=h.replace('`','')
    h=re.sub(r'\*\*|\*|__|_','',h)
    s=h.lower()
    out=[]
    for c in s:
        if c=='️': out.append(c)
        elif c.isalnum() or c=='-' or c=='_': out.append(c)
        elif c.isspace(): out.append('-')
    return ''.join(out)
files=sorted(glob.glob('*.md'))
heads={}
for f in files:
    hs=set()
    for line in open(f,encoding='utf-8'):
        m=re.match(r'^#{1,6}\s+(.*)$',line)
        if m: hs.add(slug(m.group(1)))
    heads[f]=hs
bad=0
for f in files:
    for i,line in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\]\(([^)\s]*#[^)\s]+)\)',line):
            tgt=m.group(1); path,anc=tgt.split('#',1)
            tf=f if not path else os.path.normpath(os.path.join(os.path.dirname(f),path))
            if tf not in heads: continue
            if anc not in heads[tf]:
                bad+=1; print(f'{f}:{i} -> #{anc}')
print('anclas rotas:',bad)
EOF

# --- 2026-09-11T03:41:36 · Confirm heading texts for broken anchors
grep -n "Advertencias" a01-material.md a02-bootstrap-sass.md a03-node-npm.md a04-webpack-oculto.md | grep "^.*:##"; echo ---; grep -nE "^## 6\.|^## 5\." a07-i18n.md a13-docker-colima.md; echo ---; grep -n "Ejercicios (" bea-01*.md bea-11*.md | grep "##"

# --- 2026-09-11T03:41:43 · Byte-level inspect anchor mismatches
sed -n '22p' a07-i18n.md | cat -A | head -2; echo ---; sed -n '275p' a07-i18n.md | cat -A; echo ---; sed -n '38p' a13-docker-colima.md | cat -A; echo ---; sed -n '151p' a13-docker-colima.md | cat -A

# --- 2026-09-11T03:41:46 · Inspect raw lines for anchor mismatch
python3 - <<'EOF'
import unicodedata
def show(f,n):
    l=open(f,encoding='utf-8').read().split('\n')[n-1]
    print(f,n,repr(l))
show('a07-i18n.md',22); show('a07-i18n.md',275)
show('a13-docker-colima.md',38); show('a13-docker-colima.md',151)
EOF

# --- 2026-09-11T03:41:54 · Debug slug function
python3 - <<'EOF'
import re
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip()); h=h.replace('`','')
    h=re.sub(r'\*\*|\*|__|_','',h)
    s=h.lower(); out=[]
    for c in s:
        if c=='️': out.append(c)
        elif c.isalnum() or c in '-_': out.append(c)
        elif c.isspace(): out.append('-')
    return ''.join(out)
print(slug('6. Locales y formatos: `LOCALE_ID`, fechas, números y zona horaria'))
EOF

# --- 2026-09-11T03:42:04 · Inspect a01 index and bea-11 tail
sed -n '/^## Índice/,/^---/p' a01-material.md; echo "=== bea-11 final ==="; tail -25 bea-11-mapa-de-deuda-del-track-be.md

# --- 2026-09-11T03:42:23 · Validate section-number cross references
python3 - <<'EOF'
import re,glob,os
files=sorted(glob.glob('*.md'))
# map doc -> set of section numbers from headings
def secs(f):
    s=set()
    for line in open(f,encoding='utf-8'):
        m=re.match(r'^#{2,4}\s+(?:[^\w\s]*\s*)?(\d+(?:\.\d+)*)[.)]?\s',line)
        if m: s.add(m.group(1))
    return s
S={f:secs(f) for f in files}
def resolve(tag):
    tag=tag.lower()
    if tag.startswith('a') and len(tag)==3:
        g=glob.glob(tag+'-*.md')
    elif tag.startswith('bea'):
        g=glob.glob('bea-'+tag[-2:]+'-*.md')
    elif tag.startswith('be'):
        g=glob.glob('be'+tag[-2:]+'-*.md')
    else:
        g=glob.glob(tag+'-*.md')
    return g[0] if g else None
bad=0
pat=re.compile(r'\b(A\d{2}|bea-\d{2}|be\d{2}|Fase\s+\d{1,2})\**\s*§\s*(\d+(?:\.\d+)*)')
for f in files:
    for i,line in enumerate(open(f,encoding='utf-8'),1):
        for m in pat.finditer(line.replace('`','')):
            tag,num=m.group(1),m.group(2)
            if tag.lower().startswith('fase'):
                n=int(re.search(r'\d+',tag).group()); t=resolve('%02d'%n)
            else: t=resolve(tag)
            if not t: continue
            top=num.split('.')[0]
            if num not in S[t] and top not in S[t]:
                bad+=1; print(f'{f}:{i}  {tag} §{num}  -> {t} (no tiene esa sección)')
print('refs de sección no resolubles:',bad)
EOF

# --- 2026-09-11T03:42:29 · Check a03 section numbering vs references
grep -nE "^## " a03-node-npm.md; echo "=== refs a A03 §N ==="; grep -rhoE "A03 §[0-9.]+" *.md prompts/*.md | sort | uniq -c

# --- 2026-09-11T03:42:33 · Inspect a03 subsections and A03 §9 references
grep -nE "^### " a03-node-npm.md; echo "=== contextos de A03 §9 ==="; grep -rn "A03 §9" *.md | sed 's/\(.\{170\}\).*/\1…/'

# --- 2026-09-11T03:42:40 · Locate node_modules sharing rule in a03
grep -n "no se comparte\|nunca se comparte\|entre máquinas\|entre maquinas" a03-node-npm.md | head -20

# --- 2026-09-11T03:42:46 · List BE appendix headings
for f in bea-06-jsonschema-sobre-datos-sucios.md bea-12-datos-de-prueba-y-volumen.md bea-11-mapa-de-deuda-del-track-be.md bea-03-modelar-documentos-embeber-o-referenciar.md bea-04-agregaciones-como-instrumento-de-medida.md; do echo "### $f"; grep -nE "^## " "$f"; done

# --- 2026-09-11T03:42:56 · Count section refs in BE appendices
echo "=== refs §N dentro de bea-* (auto-referencias) ==="; grep -c "§" bea-*.md; echo; echo "=== ejemplos ==="; grep -hoE "(el |del |su |ver |en )?§[0-9.]+" bea-*.md | head -30; echo "=== refs a bea desde be fases ==="; grep -rhoE "bea-[0-9]{2}[^ ]* §[0-9.]+" be0*.md cuaderno-incidentes-be.md | sort | uniq -c

# --- 2026-09-11T03:43:00 · Context of section refs in bea-11
grep -noE ".{45}§[0-9.]+" bea-11-mapa-de-deuda-del-track-be.md | head -30

# --- 2026-09-11T03:43:07 · Find self-referencing section numbers in BE appendices
for f in bea-12-datos-de-prueba-y-volumen.md bea-06-jsonschema-sobre-datos-sucios.md bea-05-indices-y-explain-en-mongodb.md bea-03-modelar-documentos-embeber-o-referenciar.md bea-04-agregaciones-como-instrumento-de-medida.md bea-01-java-8-y-spring-para-quien-no-escribe-java.md bea-07-transacciones-replica-sets-y-el-standalone.md bea-08-tiempo-zonas-y-fechas-en-mongo.md bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md bea-10-riesgo-de-licencia-sspl.md bea-02-receta-de-imagen-y-compose.md; do echo "## $f"; grep -oE ".{30}§[0-9.]+" "$f" | grep -viE "be0[0-9].{0,3}§|convencion|guia|A0[0-9]|fase [0-9]" ; done

# --- 2026-09-11T03:43:18 · List headings of remaining BE appendices
for f in bea-07* bea-08* bea-09* bea-10* bea-05*; do echo "## $f"; grep -nE "^## " "$f"; echo; done

# --- 2026-09-11T03:43:36 · Inspect ambiguous section refs
grep -n "del §6" bea-03*.md; grep -n "§1\b" bea-03*.md; echo ---; grep -n "§4\|§1" bea-06*.md; echo "--- cuaderno be bea-06 §4"; grep -n "bea-06\` §4" cuaderno-incidentes-be.md

# --- 2026-09-11T03:43:44 · Check BE appendix authoring spec
grep -n "numerad\|§\|Índice\|encabezado\|secciones" prompts/prompts-backend-apendice.md | head -40

# --- 2026-09-11T03:43:47 · Check appendix template spec
grep -n -A25 "deliberadamente laxa" prompts/plantillas-de-capitulo.md | head -60; echo "=== plantilla apéndice en plantillas-de-capitulo ==="; grep -n "Apéndice\|## " prompts/plantillas-de-capitulo.md | sed -n '1,60p'

# --- 2026-09-11T03:43:49 · Read appendix template
sed -n '205,300p' prompts/plantillas-de-capitulo.md

# --- 2026-09-11T03:43:56 · Extract 'Usado por' metadata from appendices
for f in bea-*.md a0*.md a1*.md; do printf "%-58s " "$f"; sed -n '1,6p' "$f" | grep -oE "Usado por:[^·]*" | head -1; echo; done

# --- 2026-09-11T03:44:09 · Check appendix/phase reciprocity
python3 - <<'EOF'
import re,glob
# fase -> apéndices declarados en cabecera
fase_ap={}
for f in sorted(glob.glob('[01][0-9]-*.md')):
    if 'convencion' in f or 'historia' in f: continue
    n=f[:2]
    head=''.join(open(f,encoding='utf-8').read().split('\n')[:8])
    m=re.search(r'Apéndices de apoyo:([^·]*(?:·[^·]*)*?)(?:Incidentes|$)',head)
    aps=set(x.upper() for x in re.findall(r'\bA(0[1-9]|1[0-3])\b',m.group(1))) if m else set()
    fase_ap[n]=set('A'+a for a in aps)
ap_fase={}
for f in sorted(glob.glob('a[01][0-9]-*.md')):
    code=f[:3].upper()
    head=''.join(open(f,encoding='utf-8').read().split('\n')[:6])
    m=re.search(r'Usado por:([^·]*)',head)
    ns=re.findall(r'\d+',m.group(1)) if m else []
    ap_fase[code]=set('%02d'%int(x) for x in ns)
print('--- apéndice dice "usado por fase X" pero la fase no lo lista:')
for a,fs in sorted(ap_fase.items()):
    for n in sorted(fs):
        if n in fase_ap and a not in fase_ap[n]: print(f'   {a} dice Fase {n}; la fase {n} no lo lista')
print('--- fase lista apéndice que no la declara:')
for n,aps in sorted(fase_ap.items()):
    for a in sorted(aps):
        if a in ap_fase and n not in ap_fase[a]: print(f'   Fase {n} lista {a}; {a} no la nombra')
EOF

# --- 2026-09-11T03:44:20 · Check BE appendix/phase reciprocity
python3 - <<'EOF'
import re,glob
fase_ap={}
for f in sorted(glob.glob('be0*.md')):
    n=f[:4]
    head=''.join(open(f,encoding='utf-8').read().split('\n')[:8])
    m=re.search(r'Apéndices de apoyo:(.*?)(?:Incidentes|$)',head)
    fase_ap[n]=set(re.findall(r'bea-\d{2}',m.group(1))) if m else set()
ap_fase={}
for f in sorted(glob.glob('bea-*.md')):
    code=f[:6]
    head=''.join(open(f,encoding='utf-8').read().split('\n')[:6])
    m=re.search(r'Usado por:(.*?)·',head+'·')
    ap_fase[code]=set(re.findall(r'be0\d',m.group(1))) if m else set()
for n,v in fase_ap.items(): print(n,sorted(v))
print()
for a,v in ap_fase.items(): print(a,sorted(v))
print('--- apéndice dice usado por X pero X no lo lista:')
for a,fs in sorted(ap_fase.items()):
    for n in sorted(fs):
        if a not in fase_ap.get(n,set()): print(f'   {a} dice {n}; {n} no lo lista en su cabecera')
print('--- fase lista apéndice que no la nombra:')
for n,aps in sorted(fase_ap.items()):
    for a in sorted(aps):
        if n not in ap_fase.get(a,set()): print(f'   {n} lista {a}; {a} no lo nombra')
EOF

# --- 2026-09-11T03:44:31 · Check incident ID reservation coherence
python3 - <<'EOF'
import re,glob
claim={}
for f in sorted(glob.glob('[01][0-9]-*.md')):
    if 'convencion' in f or 'historia' in f: continue
    head=''.join(open(f,encoding='utf-8').read().split('\n')[:8])
    m=re.search(r'Incidentes asociados:([^\n]*)',head)
    ids=re.findall(r'\b(\d{2})\b',m.group(1)) if m else []
    claim[f[:2]]=ids
allc=[i for v in claim.values() for i in v]
print('IDs reclamados por fases:',sorted(allc))
import collections
d=[k for k,v in collections.Counter(allc).items() if v>1]
print('IDs duplicados entre fases:',d)
print('faltan de 01..21:',[('%02d'%i) for i in range(1,22) if '%02d'%i not in allc])
for k,v in claim.items(): print(k,v)
EOF
echo "=== índice del cuaderno ==="; sed -n '/## 📇/,/^## /p' cuaderno-incidentes.md | head -50

# --- 2026-09-11T03:44:38 · Inspect incident claims and notebook index
sed -n '5,8p' 08-resultados-rangos.md; echo ---; sed -n '4,7p' 14-casi-prod-kind.md; echo ---; sed -n '4,7p' 06-ordenes.md; echo "=== índice cuaderno ==="; grep -nE "^\| *\*?\*?[0-9]{2}" cuaderno-incidentes.md | head -30

# --- 2026-09-11T03:44:45 · Check BE incident reciprocity
python3 - <<'EOF'
import re,glob
for f in sorted(glob.glob('be0*.md')):
    head=''.join(open(f,encoding='utf-8').read().split('\n')[:8])
    m=re.search(r'Incidentes asociados:([^\n]*)',head)
    print(f[:4], m.group(1).strip() if m else 'NO DECLARA')
EOF
echo "=== índice cuaderno BE ==="; grep -nE "^\| *\*?\*?be-[0-9]{2}" cuaderno-incidentes-be.md | head -20

# --- 2026-09-11T03:44:58 · Find English code comments
python3 - <<'EOF'
import re,glob
eng=set('the this is are for with from that and not you your when where what have has get set return if else true false value name list new of to in on it as by be we'.split())
sp=set('el la los las de que no se es un una con para por del al en y o si como lo su sus este esta eso más pero porque cuando donde qué'.split())
for f in sorted(glob.glob('*.md')):
    t=open(f,encoding='utf-8').read()
    for block in re.findall(r'```[a-zA-Z]*\n(.*?)```',t,re.S):
        for line in block.split('\n'):
            m=re.search(r'(?://|#|\*)\s+(.+)$',line.strip())
            if not m: continue
            c=m.group(1)
            w=set(re.findall(r"[a-záéíóúñ]+",c.lower()))
            if len(w)>=4 and len(w&eng)>=2 and not (w&sp):
                print(f'{f}: {line.strip()[:110]}')
EOF

# --- 2026-09-11T03:45:10 · Find Spanish comments missing accents
python3 - <<'EOF'
import re,glob
pats=r'\b(esta|estan|numero|version|codigo|solo|tambien|mas|aqui|asi|despues|aun|sesion|validacion|configuracion|migracion|documentacion|razon|esta?|aplicacion|aparecera|aparecio|aqui|aun|aunque|electronico|automatico|ultimo|ultima|aleatorio|practica|critico|critica|aritmetica|logica|magico|aun|porque|aunque)\b'
bad=r'\b(numero|version|codigo|tambien|aqui|asi|despues|sesion|validacion|configuracion|migracion|documentacion|razon|aplicacion|ultimo|ultima|critico|critica|magico|deberia|aqui|ademas|dia|dias|mas\b|habria|seria|estaria|aun\b|aca|mia|aun)\b'
for f in sorted(glob.glob('*.md')):
    t=open(f,encoding='utf-8').read()
    for block in re.findall(r'```[a-zA-Z]*\n(.*?)```',t,re.S):
        for line in block.split('\n'):
            m=re.search(r'(?://|#)\s*(.+)$',line)
            if not m: continue
            c=m.group(1)
            hits=re.findall(bad,c.lower())
            if hits: print(f'{f}: {line.strip()[:120]}   -> {set(hits)}')
EOF

# --- 2026-09-11T03:45:38 · Inspect stale references context
grep -n "plan-del-curso" prompts/alcance-del-proyecto.md; echo ---; grep -n "a05-rxjs-supervivencia" prompts/prompts-extendidos-apendices.md; echo ---; grep -n "a12-mapa-de-deuda-tecnica" prompts/prompts-backend-apendice.md; echo ---; grep -n "plantilla-de-incidente-be" prompts/formato-cuaderno-incidentes.md prompts/propuesta-fases-backend.md

# --- 2026-09-11T03:45:50 · Fix relative links and Advertencias anchors
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs
# A1: links relativos desde prompts/
sed -i '' 's|\](00-convencion-de-git-y-tags\.md)|](../00-convencion-de-git-y-tags.md)|g' prompts/guia-de-estilo-y-convenciones.md prompts/plantillas-de-capitulo.md
# A4: nombre de archivo obsoleto
sed -i '' 's|a05-rxjs-supervivencia\.md|a05-rxjs.md|g' prompts/prompts-extendidos-apendices.md
# A2: ancla de Advertencias en a01-a03
sed -i '' 's|(#-advertencias)|(#️-advertencias)|' a01-material.md a02-bootstrap-sass.md a03-node-npm.md
grep -n "advertencias)" a01-material.md a02-bootstrap-sass.md a03-node-npm.md

# --- 2026-09-11T03:45:56 · Fix exercise anchors in BE appendices
for f in bea-*.md; do n=$(grep -oE "^## 🧪 Ejercicios \(([0-9]+)\)" "$f" | grep -oE "[0-9]+"); sed -i '' "s|(#-ejercicios)|(#-ejercicios-$n)|" "$f"; done; grep -n "#-ejercicios" bea-*.md

# --- 2026-09-11T03:46:18 · Count subheadings and inspect a BE index
for f in bea-*.md; do echo "$f: $(grep -c '^### ' $f) subsecciones"; done; echo; sed -n '/^## Índice/,/^---/p' bea-05-indices-y-explain-en-mongodb.md

# --- 2026-09-11T03:46:32 · Number BE appendix sections and update indexes
python3 - <<'PY'
import re,glob,sys
SKIP={'Índice'}
SKIP_PREFIX=('🧭 Cuándo usar qué','⚠️ Advertencias','📚 Referencias','🧪 Ejercicios','📌 Pendientes')
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip()).replace('`','')
    h=re.sub(r'\*\*|\*',' ',h)
    out=[]
    for c in h.lower():
        if c=='️': out.append(c)
        elif c.isalnum() or c in '-_': out.append(c)
        elif c.isspace(): out.append('-')
    s=''.join(out)
    return re.sub(r'-+','-',s).strip('-') if False else ''.join(out)
for f in sorted(glob.glob('bea-*.md')):
    lines=open(f,encoding='utf-8').read().split('\n')
    idx=[i for i,l in enumerate(lines) if l.strip()=='## Índice'][0]
    n=0; mapping={}
    for i in range(idx+1,len(lines)):
        m=re.match(r'^## (.+)$',lines[i])
        if not m: continue
        t=m.group(1).strip()
        if t in SKIP or t.startswith(SKIP_PREFIX): continue
        if re.match(r'^\d+\.',t): continue
        n+=1
        old=slug(t); new=slug(f'{n}. {t}')
        mapping[old]=(new,n,t)
        lines[i]=f'## {n}. {t}'
    # update índice entries
    for i in range(idx+1,len(lines)):
        if lines[i].startswith('---'): break
        m=re.match(r'^- \[(.+)\]\(#(.+)\)$',lines[i])
        if not m: continue
        label,anc=m.group(1),m.group(2)
        if anc in mapping:
            new,num,t=mapping[anc]
            lines[i]=f'- [{num}. {label}](#{new})'
    open(f,'w',encoding='utf-8').write('\n'.join(lines))
    print(f,'->',n,'secciones numeradas')
PY

# --- 2026-09-11T03:46:45 · Verify numbered index output
sed -n '/^## Índice/,/^---/p' bea-07-transacciones-replica-sets-y-el-standalone.md; echo "=== headings bea-09 ==="; grep -nE "^## " bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md

# --- 2026-09-11T03:46:53 · Revert numbering in bea-09
f=bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md
sed -i '' -E 's|^## [1-4]\. |## |' $f
sed -i '' -E 's|^- \[[1-4]\. (.+)\]\(#[1-4]-(.*)\)$|- [\1](#\2)|' $f
grep -nE "^## |^- \[" $f | head -20; echo "=== ref §1 ==="; grep -n "del §1" $f

# --- 2026-09-11T03:46:58 · Fix section reference in bea-09
f=bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md
python3 - <<'PY'
import re
f='bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md'
t=open(f,encoding='utf-8').read()
t=t.replace('al arquitecto del §1.','al arquitecto de la Parte 1.')
open(f,'w',encoding='utf-8').write(t)
PY
grep -n "Parte 1\." $f | tail -2

# --- 2026-09-11T03:47:07 · Re-validate all anchors
python3 - <<'PY'
import re,glob,os
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip()).replace('`','')
    h=re.sub(r'\*\*|\*','',h)
    out=[]
    for c in h.lower():
        if c=='️': out.append(c)
        elif c.isalnum() or c in '-_': out.append(c)
        elif c.isspace(): out.append('-')
    return ''.join(out)
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
heads={f:{slug(m.group(1)) for m in (re.match(r'^#{1,6}\s+(.*)$',l) for l in open(f,encoding='utf-8')) if m} for f in files}
bad=0
for f in files:
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\]\(([^)\s]*#[^)\s]+)\)',l):
            p,a=m.group(1).split('#',1)
            tf=f if not p else os.path.normpath(os.path.join(os.path.dirname(f),p))
            if tf in heads and a not in heads[tf]:
                bad+=1;print(f'{f}:{i} -> {m.group(1)}')
print('anclas rotas:',bad)
PY

# --- 2026-09-11T03:47:14 · Inspect remaining anchor mismatches
sed -n '25p' bea-06-jsonschema-sobre-datos-sucios.md; grep -n "no.*puede hacer" bea-06-jsonschema-sobre-datos-sucios.md | head -3; echo ---; sed -n '30p' bea-08-tiempo-zonas-y-fechas-en-mongo.md; grep -nE "^## .*BSON" bea-08-tiempo-zonas-y-fechas-en-mongo.md

# --- 2026-09-11T03:47:19 · Fix two remaining index anchors
python3 - <<'PY'
import io
f='bea-06-jsonschema-sobre-datos-sucios.md'
t=open(f,encoding='utf-8').read()
t=t.replace('- [Lo que `$jsonSchema` **no** puede hacer](#lo-que-jsonschema-no-puede-hacer)',
            '- [8. Lo que `$jsonSchema` **no** puede hacer](#8-lo-que-jsonschema-no-puede-hacer)')
open(f,'w',encoding='utf-8').write(t)
f='bea-08-tiempo-zonas-y-fechas-en-mongo.md'
t=open(f,encoding='utf-8').read()
t=t.replace('- [`BSON Date` y lo que **no** guarda](#bson-date-y-lo-que-no-guarda)',
            '- [3. `BSON Date` y lo que **no** guarda](#3-bson-date-y-lo-que-no-guarda)')
open(f,'w',encoding='utf-8').write(t)
print('ok')
PY
sed -n '25p' bea-06-jsonschema-sobre-datos-sucios.md; sed -n '30p' bea-08-tiempo-zonas-y-fechas-en-mongo.md

# --- 2026-09-11T03:47:24 · Read a03 closing sections
sed -n '540,600p' a03-node-npm.md

# --- 2026-09-11T03:47:36 · Add section 9 to a03
python3 - <<'PY'
f='a03-node-npm.md'
t=open(f,encoding='utf-8').read()

nm_start='**Un `node_modules` no se comparte entre arquitecturas'
alpine_end='se hace para **ver** dónde se rompe.\n'
i=t.index(nm_start); j=t.index(alpine_end)+len(alpine_end)
block=t[i:j].rstrip('\n')
t=t[:i]+t[j:]
# limpia dobles saltos sobrantes tras el corte
t=t.replace('## ⚠️ Advertencias\n\n\n','## ⚠️ Advertencias\n\n')

nueva=('## 9. Lo que no se comparte y lo que no compila\n\n'
       + block + '\n\n---\n\n')
k=t.index('## 🧭 Cuándo usar qué')
t=t[:k]+nueva+t[k:]

t=t.replace('- [🧭 Cuándo usar qué](#-cuándo-usar-qué)',
            '- [9. Lo que no se comparte y lo que no compila](#9-lo-que-no-se-comparte-y-lo-que-no-compila)\n- [🧭 Cuándo usar qué](#-cuándo-usar-qué)')
open(f,'w',encoding='utf-8').write(t)
PY
grep -nE "^## |^- \[" a03-node-npm.md | sed -n '1,30p'

# --- 2026-09-11T03:47:40 · Verify new section 9 rendering
sed -n '546,596p' a03-node-npm.md

# --- 2026-09-11T03:47:46 · Read BE phase headers
for f in be02-medir-la-deriva-de-esquema.md be03-la-costura-y-el-reemplazo.md be05-la-cadena-de-custodia-y-la-transaccion.md be06-los-rangos-y-la-historia-perdida.md be08-la-contencion-y-lo-irrecuperable.md be00-el-contrato-auditoria-del-mock.md; do echo "--- $f"; sed -n '1,8p' "$f"; done

# --- 2026-09-11T03:47:54 · Count appendix mentions inside BE phases
for f in be02* be03* be05* be06* be08*; do echo "--- $f"; grep -ohE "bea-[0-9]{2}" "$f" | sort | uniq -c; done

# --- 2026-09-11T03:48:02 · Build appendix usage matrix
python3 - <<'PY'
import re,glob,collections
m=collections.defaultdict(set)
for f in sorted(glob.glob('be0*.md')):
    t=open(f,encoding='utf-8').read()
    for a in set(re.findall(r'bea-\d{2}',t)): m[a].add(f[:4])
for a in sorted(m): print(a, sorted(m[a]))
PY

# --- 2026-09-11T03:48:13 · Check be08 content for Cassandra/licence topics
grep -n "Cassandra\|SSPL\|licencia" be08-la-contencion-y-lo-irrecuperable.md | head; echo "=== be00 bea-02 ==="; grep -n "bea-02" be00-el-contrato-auditoria-del-mock.md; echo "=== be02 bea-06 ==="; grep -n "bea-06" be02-medir-la-deriva-de-esquema.md

# --- 2026-09-11T03:48:17 · Inspect be08 structure and verdict tree
grep -nE "^## |^### " be08-la-contencion-y-lo-irrecuperable.md | head -40; echo ===; grep -n "veredicto" be08-la-contencion-y-lo-irrecuperable.md | head

# --- 2026-09-11T03:48:22 · Inspect be08 section 5.7
sed -n '322,362p' be08-la-contencion-y-lo-irrecuperable.md

# --- 2026-09-11T03:48:25 · Read be08 verdict tree
sed -n '308,322p' be08-la-contencion-y-lo-irrecuperable.md

# --- 2026-09-11T03:48:38 · Correct 'Usado por' claims in BE appendices
python3 - <<'PY'
edits = [
 ('bea-02-receta-de-imagen-y-compose.md',
  'Usado por: be01, be02, be03, be07, be08',
  'Usado por: be01, be02, be03, be07'),
 ('bea-04-agregaciones-como-instrumento-de-medida.md',
  'Usado por: be02 sobre todo, be05, be06',
  'Usado por: be02 sobre todo; de consulta suelta desde be05 y be06'),
 ('bea-05-indices-y-explain-en-mongodb.md',
  'Usado por: be02, be03, be05',
  'Usado por: be02, be03'),
 ('bea-12-datos-de-prueba-y-volumen.md',
  'Usado por: be02, be03, be05',
  'Usado por: be02, be03'),
]
for f,a,b in edits:
    t=open(f,encoding='utf-8').read()
    assert a in t, f
    open(f,'w',encoding='utf-8').write(t.replace(a,b,1))
    print('ok',f)
PY

# --- 2026-09-11T03:48:49 · Wire bea-09/bea-10 into be08 verdict tree
python3 - <<'PY'
f='be08-la-contencion-y-lo-irrecuperable.md'
t=open(f,encoding='utf-8').read()
old="> ⚖️ **Y la frase que resume el árbol, que es la que va en el documento:**"
new=("> 📚 **Las dos opciones que alguien va a proponer en esa reunión y no están en el árbol** tienen su apéndice, y los dos "
     "se escribieron para este momento: cambiar de motor \"porque escala\" se contesta con números en "
     "[`bea-09`](./bea-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md), y \"cambiemos de base por el tema de la "
     "licencia\" se contesta en [`bea-10`](./bea-10-riesgo-de-licencia-sspl.md). Ninguna de las dos mueve el veredicto; "
     "las dos hay que saber contestarlas sin improvisar.\n\n"
     + old)
assert old in t
t=t.replace(old,new,1)
t=t.replace("> Apéndices de apoyo: bea-06 (`$jsonSchema` sobre datos sucios) · bea-11 (mapa de deuda del track BE) · Incidentes asociados: be-12",
            "> Apéndices de apoyo: bea-06 (`$jsonSchema` sobre datos sucios) · bea-11 (mapa de deuda del track BE) · bea-09 (Cassandra: la tentación) y bea-10 (riesgo de licencia), los dos en el árbol de veredicto de §5.6 · Incidentes asociados: be-12",1)
open(f,'w',encoding='utf-8').write(t)
print('ok')
PY
grep -n "bea-09\|bea-10" be08-la-contencion-y-lo-irrecuperable.md

# --- 2026-09-11T03:48:55 · Read bea-11 index and closing
sed -n '18,30p' bea-11-mapa-de-deuda-del-track-be.md; echo ...; sed -n '145,156p' bea-11-mapa-de-deuda-del-track-be.md

# --- 2026-09-11T03:49:09 · Add Referencias section to bea-11
python3 - <<'PY'
f='bea-11-mapa-de-deuda-del-track-be.md'
t=open(f,encoding='utf-8').read()
t=t.replace('- [⚠️ Advertencias](#️-advertencias)\n- [🧪 Ejercicios]',
            '- [⚠️ Advertencias](#️-advertencias)\n- [📚 Referencias](#-referencias)\n- [🧪 Ejercicios]',1)
refs = """---

## 📚 Referencias

- https://wiki.c2.com/?TechnicalDebt — la formulación original de Ward Cunningham, en cuatro párrafos. Vale la pena leerla porque dice algo que la versión popular perdió: la deuda se toma **a propósito y para entregar antes**, y lo que la vuelve tóxica es no devolverla ni declararla. Es exactamente el criterio del §1.
- https://martinfowler.com/bliki/TechnicalDebtQuadrant.html — el cuadrante prudente/temerario × deliberada/inadvertida. Las filas del §2 son todas del cuadrante **prudente-deliberada**; las de 2019 que este mapa no recoge son, casi todas, prudente-inadvertida, y por eso se llaman hallazgos y no deuda.
- https://www.mongodb.com/docs/v7.0/tutorial/convert-standalone-to-replica-set/ — el procedimiento de la deuda número uno del §5, para costearla con el documento delante en vez de con una estimación de pasillo. ⚠️ La URL lleva la versión: `/v7.0/` es la que corre LabCore después de `be07`.
- https://martinfowler.com/bliki/StranglerFigApplication.html — el patrón que sostiene el §6: lo que no se paga se rodea. Es el mismo que `be08` §4.2 aplica por read-model.

> ⚠️ Los dos enlaces de `martinfowler.com` son de 2003 y 2009 y siguen vivos en esa URL; si alguno se mueve, el título es suficiente para encontrarlo. La documentación de MongoDB, en cambio, **rota con cada versión**: verifica siempre que el número de la URL es el tuyo.

"""
t=t.replace('---\n\n## 🧪 Ejercicios (6)', refs+'## 🧪 Ejercicios (6)',1)
open(f,'w',encoding='utf-8').write(t)
PY
grep -nE "^## " bea-11-mapa-de-deuda-del-track-be.md

# --- 2026-09-11T03:49:15 · Check MongoDB doc URL conventions
grep -ho "https://www.mongodb.com/docs/[^ )]*" bea-*.md be0*.md | sort | uniq -c | sort -rn | head -12

# --- 2026-09-11T03:49:19 · Check which MongoDB doc versions are cited
grep -ho "mongodb.com/docs/v[0-9.]*" *.md | sort | uniq -c

# --- 2026-09-11T03:49:24 · Align MongoDB doc URL version in bea-11
python3 - <<'PY'
f='bea-11-mapa-de-deuda-del-track-be.md'
t=open(f,encoding='utf-8').read()
t=t.replace('https://www.mongodb.com/docs/v7.0/tutorial/convert-standalone-to-replica-set/',
            'https://www.mongodb.com/docs/v4.0/tutorial/convert-standalone-to-replica-set/')
t=t.replace('⚠️ La URL lleva la versión: `/v7.0/` es la que corre LabCore después de `be07`.',
            '⚠️ La URL apunta a `/v4.0/`, que es la convención del track: el procedimiento se lee para la versión en la que la deuda nació. Si la costeas después de `be07`, cambia el número por el tuyo — el tutorial no es el mismo entre versiones.')
open(f,'w',encoding='utf-8').write(t)
PY
grep -n "mongodb.com" bea-11-mapa-de-deuda-del-track-be.md

# --- 2026-09-11T03:49:36 · List accent fixes needed in appendices and forensics
python3 - <<'PY'
import re,glob
bad=r'\b(numero|version|codigo|tambien|aqui|asi|despues|sesion|validacion|configuracion|migracion|documentacion|razon|aplicacion|ultimo|ultima|critico|critica|magico|deberia|ademas|dia|dias|mas|habria|seria|estaria|aun|aca|libreria|librerias|arbol|maquina|parecio|salio|estan|sintoma|proposito|pagina|automatico|practica|linea|milimetros)\b'
files=sorted(glob.glob('a[01][0-9]-*.md'))+sorted(glob.glob('bea-*.md'))+sorted(glob.glob('forense-*.md'))
for f in files:
    src=open(f,encoding='utf-8').read().split('\n')
    infence=False
    for i,line in enumerate(src,1):
        if re.match(r'^\s*```',line): infence=not infence; continue
        if not infence: continue
        m=re.search(r'(?://|#)\s*(.+)$',line)
        if not m: continue
        if re.findall(bad,m.group(1).lower()):
            print(f'{f}:{i}: {line.strip()[:130]}')
PY

# --- 2026-09-11T03:50:01 · Apply accent fixes to code comments
python3 - <<'PY'
import re,glob
MAP={'numero':'número','version':'versión','versiones':'versiones','codigo':'código','tambien':'también',
'aqui':'aquí','asi':'así','Asi':'Así','despues':'después','sesion':'sesión','validacion':'validación',
'configuracion':'configuración','migracion':'migración','documentacion':'documentación','razon':'razón',
'aplicacion':'aplicación','ultimo':'último','ultima':'última','critico':'crítico','critica':'crítica',
'magico':'mágico','deberia':'debería','ademas':'además','dia':'día','dias':'días','mas':'más',
'habria':'habría','seria':'sería','estaria':'estaría','aca':'acá','libreria':'librería','librerias':'librerías',
'arbol':'árbol','maquina':'máquina','MAQUINA':'MÁQUINA','parecio':'pareció','salio':'salió','estan':'están',
'sintoma':'síntoma','proposito':'propósito','pagina':'página','automatico':'automático','practica':'práctica',
'linea':'línea','milimetros':'milímetros','peticion':'petición','quedo':'quedó','Miralo':'Míralo',
'Confirmalo':'Confírmalo','creermelo':'creérmelo','Apendice':'Apéndice','categoria':'categoría',
'Cuantos':'Cuántos','todavia':'todavía','Ambar':'Ámbar','multiplataforma':'multiplataforma'}
SKIP={('forense-fase-08.md',136)}
files=sorted(glob.glob('a[01][0-9]-*.md'))+sorted(glob.glob('bea-*.md'))+sorted(glob.glob('forense-*.md'))
total=0
for f in files:
    src=open(f,encoding='utf-8').read().split('\n')
    infence=False; changed=0
    for i,line in enumerate(src):
        if re.match(r'^\s*```',line): infence=not infence; continue
        if not infence: continue
        if (f,i+1) in SKIP: continue
        m=re.search(r'((?://|#)\s*)(.+)$',line)
        if not m: continue
        head=line[:m.start(2)]; body=m.group(2)
        new=re.sub(r'\b[A-Za-zÁÉÍÓÚáéíóúñÑ]+\b', lambda w: MAP.get(w.group(0),w.group(0)), body)
        if new!=body:
            src[i]=head+new; changed+=1
    if changed:
        open(f,'w',encoding='utf-8').write('\n'.join(src)); total+=changed
        print(f,changed)
print('líneas corregidas:',total)
PY

# --- 2026-09-11T03:50:07 · Review accent diffs
git -C .. diff --stat -- angular-8-legacy-for-backend-devs | tail -5; echo "=== revisión de cambios de tildes ==="; git -C .. diff -U0 -- angular-8-legacy-for-backend-devs/a05-rxjs.md angular-8-legacy-for-backend-devs/a06-ngrx.md angular-8-legacy-for-backend-devs/forense-fase-07.md angular-8-legacy-for-backend-devs/forense-fase-11.md angular-8-legacy-for-backend-devs/a07-i18n.md | grep -E "^[-+][^-+]" | head -40

# --- 2026-09-11T03:50:22 · Second accent pass
python3 - <<'PY'
import re,glob
MAP={'alla':'allá','investigacion':'investigación','peticiones':'peticiones','mostro':'mostró',
'facil':'fácil','dificil':'difícil','rapida':'rápida','rapido':'rápido','aritmetica':'aritmética',
'logica':'lógica','metodo':'método','numeros':'números','unico':'único','unica':'única',
'ningun':'ningún','algun':'algún','esta':'esta','deteccion':'detección','ejecucion':'ejecución',
'informacion':'información','operacion':'operación','version':'versión','atencion':'atención',
'relacion':'relación','condicion':'condición','funcion':'función','opcion':'opción','accion':'acción',
'seccion':'sección','direccion':'dirección','excepcion':'excepción','conexion':'conexión',
'transaccion':'transacción','integracion':'integración','resolucion':'resolución','ademas':'además',
'traduccion':'traducción','compilacion':'compilación','instalacion':'instalación','ubicacion':'ubicación',
'duplicacion':'duplicación','cache':'cache','anadir':'añadir','despues':'después'}
files=sorted(glob.glob('a[01][0-9]-*.md'))+sorted(glob.glob('bea-*.md'))+sorted(glob.glob('forense-*.md'))
tot=0
for f in files:
    src=open(f,encoding='utf-8').read().split('\n'); infence=False; ch=0
    for i,l in enumerate(src):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        if f=='forense-fase-08.md' and i+1==136: continue
        m=re.search(r'((?://|#)\s*)(.+)$',l)
        if not m: continue
        h=l[:m.start(2)]; b=m.group(2)
        n=re.sub(r'\b[A-Za-zÁÉÍÓÚáéíóúñÑ]+\b',lambda w:MAP.get(w.group(0),w.group(0)),b)
        if n!=b: src[i]=h+n; ch+=1
    if ch: open(f,'w',encoding='utf-8').write('\n'.join(src)); tot+=ch; print(f,ch)
print('total',tot)
PY

# --- 2026-09-11T03:50:27 · Verify second pass diffs
git -C .. diff -U0 -- angular-8-legacy-for-backend-devs/forense-fase-08.md angular-8-legacy-for-backend-devs/forense-fase-14.md angular-8-legacy-for-backend-devs/a09-kubernetes.md | grep -E "^[-+][^-+]"; echo "=== a07:382 contexto ==="; sed -n '378,386p' a07-i18n.md

# --- 2026-09-11T03:50:44 · Fix -ción endings in comments
python3 - <<'PY'
import re,glob
files=sorted(glob.glob('a[01][0-9]-*.md'))+sorted(glob.glob('bea-*.md'))+sorted(glob.glob('forense-*.md'))
ACC={'a':'á','e':'é','i':'í','o':'ó','u':'ú'}
def fix(w):
    lw=w.lower()
    if len(lw)>5 and lw.endswith(('cion','sion','xion')) and not lw.endswith('ciones'):
        return w[:-4]+ACC[w[-4]]+w[-3:] if w[-4] in ACC else w
    return w
tot=0
for f in files:
    src=open(f,encoding='utf-8').read().split('\n'); infence=False; ch=0
    for i,l in enumerate(src):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        m=re.search(r'((?://|#)\s*)(.+)$',l)
        if not m: continue
        h=l[:m.start(2)]; b=m.group(2)
        n=re.sub(r'\b[A-Za-zÁÉÍÓÚáéíóúñÑ]+\b',lambda w:fix(w.group(0)),b)
        if n!=b: src[i]=h+n; ch+=1; print(f'{f}:{i+1} {n.strip()[:90]}')
    if ch: open(f,'w',encoding='utf-8').write('\n'.join(src)); tot+=ch
print('total',tot)
PY

# --- 2026-09-11T03:50:55 · Correct -ción accent pass
python3 - <<'PY'
import re,glob
files=sorted(glob.glob('a[01][0-9]-*.md'))+sorted(glob.glob('bea-*.md'))+sorted(glob.glob('forense-*.md'))
def fix(w):
    lw=w.lower()
    if len(lw)>6 and lw.endswith(('cion','sion','xion')):
        return w[:-2]+'ó'+w[-1]
    return w
tot=0
for f in files:
    src=open(f,encoding='utf-8').read().split('\n'); infence=False; ch=0
    for i,l in enumerate(src):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        m=re.search(r'((?://|#)\s*)(.+)$',l)
        if not m: continue
        h=l[:m.start(2)]; b=m.group(2)
        n=re.sub(r'\b[A-Za-zÁÉÍÓÚáéíóúñÑ]+\b',lambda w:fix(w.group(0)),b)
        if n!=b: src[i]=h+n; ch+=1; print(f'{f}:{i+1} {n.strip()[:95]}')
    if ch: open(f,'w',encoding='utf-8').write('\n'.join(src)); tot+=ch
print('total',tot)
PY

# --- 2026-09-11T03:51:04 · Restore literal source-map output line
python3 - <<'PY'
f='forense-fase-08.md'
t=open(f,encoding='utf-8').read()
t=t.replace('{"versión":3,"file"','{"version":3,"file"')
open(f,'w',encoding='utf-8').write(t)
PY
sed -n '136p' forense-fase-08.md

# --- 2026-09-11T03:51:16 · Manual interrogative accent fixes
python3 - <<'PY'
import re,glob
pairs=[('a09-kubernetes.md','esto NO esta cifrado','esto NO está cifrado'),
('a12-arm64-m1.md','por si la 2 te dejo dudando','por si la 2 te dejó dudando'),
('a13-docker-colima.md','a que VM le estoy hablando','a qué VM le estoy hablando'),
('a09-kubernetes.md','¿A QUE CLUSTER le estoy hablando','¿A QUÉ CLUSTER le estoy hablando'),
('a09-kubernetes.md','# ④ QUE versión corre','# ④ QUÉ versión corre'),
('a09-kubernetes.md','# ⑥ DE DONDE sale la configuración','# ⑥ DE DÓNDE sale la configuración'),
('a03-node-npm.md','# Que versión quedó REALMENTE','# Qué versión quedó REALMENTE'),
('a03-node-npm.md','# 2. Su versión de Angular','# 2. Su versión de Angular'),
('a10-migracion-8-9.md','# 2. LA PREGUNTA. Que versión de Angular exige esa versión','# 2. LA PREGUNTA. Qué versión de Angular exige esa versión'),
('a11-migracion-9-16.md','# Que Node, que TypeScript y que RxJS exige','# Qué Node, qué TypeScript y qué RxJS exige'),
('a12-arm64-m1.md','# Que paquetes de tu árbol','# Qué paquetes de tu árbol'),
('forense-fase-05.md','# 2. ¿Que vio Express?','# 2. ¿Qué vio Express?'),
('forense-fase-08.md','# 2. A que map dice apuntar','# 2. A qué map dice apuntar'),
('a13-docker-colima.md','# 1. De que arquitectura es esta imagen','# 1. De qué arquitectura es esta imagen'),
('a02-bootstrap-sass.md','# existen en la versión que tienes instalada','# existen en la versión que tienes instalada'),
]
for f,a,b in pairs:
    t=open(f,encoding='utf-8').read()
    if a in t and a!=b:
        open(f,'w',encoding='utf-8').write(t.replace(a,b))
        print('ok',f,'|',b[:60])
    elif a not in t: print('NO ENCONTRADO',f,'|',a[:60])
PY

# --- 2026-09-11T03:51:25 · Re-scan for remaining accent issues
python3 - <<'PY'
import re,glob
bad=r'\b(numero|version|codigo|tambien|aqui|asi|despues|sesion|validacion|configuracion|migracion|documentacion|razon|aplicacion|ultimo|ultima|critico|critica|deberia|ademas|dia|dias|mas|habria|seria|estaria|aca|libreria|librerias|arbol|maquina|estan|sintoma|proposito|pagina|linea|peticion|traduccion|produccion|proteccion|comprobacion|decision|situacion|coleccion|suscripcion|edicion|confirmacion|comparacion|discusion)\b'
files=sorted(glob.glob('a[01][0-9]-*.md'))+sorted(glob.glob('bea-*.md'))+sorted(glob.glob('forense-*.md'))
n=0
for f in files:
    src=open(f,encoding='utf-8').read().split('\n'); infence=False
    for i,l in enumerate(src,1):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        m=re.search(r'(?://|#)\s*(.+)$',l)
        if m and re.findall(bad,m.group(1).lower()):
            n+=1; print(f'{f}:{i}: {l.strip()[:110]}')
print('restantes:',n)
PY

# --- 2026-09-11T03:51:40 · Dry run accent fixes on phases
python3 - <<'PY'
import re,glob
MAP={'numero':'número','version':'versión','codigo':'código','tambien':'también','aqui':'aquí','asi':'así',
'Asi':'Así','despues':'después','sesion':'sesión','razon':'razón','ultimo':'último','ultima':'última',
'deberia':'debería','ademas':'además','dia':'día','dias':'días','mas':'más','habria':'habría','seria':'sería',
'aca':'acá','arbol':'árbol','maquina':'máquina','estan':'están','sintoma':'síntoma','proposito':'propósito',
'pagina':'página','linea':'línea','lineas':'líneas','rapida':'rápida','contradiccion':'contradicción','indices':'índices'}
def fixcion(w):
    lw=w.lower()
    return w[:-2]+'ó'+w[-1] if len(lw)>6 and lw.endswith(('cion','sion','xion')) else w
files=[f for f in sorted(glob.glob('[01][0-9]-*.md'))+sorted(glob.glob('be0*.md'))+['cuaderno-incidentes.md','cuaderno-incidentes-be.md']]
for f in files:
    src=open(f,encoding='utf-8').read().split('\n'); infence=False
    for i,l in enumerate(src):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        m=re.search(r'((?://|#)\s*)(.+)$',l)
        if not m: continue
        b=m.group(2)
        n=re.sub(r'\b[A-Za-zÁÉÍÓÚáéíóúñÑ]+\b',lambda w:MAP.get(w.group(0),fixcion(w.group(0))),b)
        if n!=b: print(f'{f}:{i+1}\n   - {b.strip()[:110]}\n   + {n.strip()[:110]}')
PY

# --- 2026-09-11T03:51:55 · Apply accent fixes to phases
python3 - <<'PY'
import re,glob
MAP={'numero':'número','numeros':'números','version':'versión','codigo':'código','tambien':'también','aqui':'aquí','AQUI':'AQUÍ','asi':'así',
'Asi':'Así','despues':'después','sesion':'sesión','razon':'razón','ultimo':'último','ultima':'última',
'deberia':'debería','ademas':'además','dia':'día','dias':'días','mas':'más','habria':'habría','seria':'sería',
'aca':'acá','Aca':'Acá','arbol':'árbol','maquina':'máquina','estan':'están','sintoma':'síntoma','proposito':'propósito',
'pagina':'página','linea':'línea','lineas':'líneas','rapida':'rápida','indices':'índices','segun':'según',
'unica':'única','unico':'único','vivia':'vivía','moriria':'moriría','imagenes':'imágenes','peticion':'petición'}
def fixcion(w):
    lw=w.lower()
    return w[:-2]+'ó'+w[-1] if len(lw)>6 and lw.endswith(('cion','sion','xion')) else w
files=sorted(glob.glob('[01][0-9]-*.md'))+sorted(glob.glob('be0*.md'))+['cuaderno-incidentes.md','cuaderno-incidentes-be.md']
tot=0
for f in files:
    src=open(f,encoding='utf-8').read().split('\n'); infence=False; ch=0
    for i,l in enumerate(src):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        m=re.search(r'((?://|#)\s*)(.+)$',l)
        if not m: continue
        h=l[:m.start(2)]; b=m.group(2)
        n=re.sub(r'\b[A-Za-zÁÉÍÓÚáéíóúñÑ]+\b',lambda w:MAP.get(w.group(0),fixcion(w.group(0))),b)
        if n!=b: src[i]=h+n; ch+=1
    if ch: open(f,'w',encoding='utf-8').write('\n'.join(src)); tot+=ch; print(f,ch)
print('total',tot)
PY

# --- 2026-09-11T03:52:04 · Final accent cleanup and verification
python3 - <<'PY'
pairs=[('13-build-despliegue.md','Acá si usamos alpine','Acá sí usamos alpine'),
('14-casi-prod-kind.md','el contrato lo fijo la imagen','el contrato lo fijó la imagen'),
('14-casi-prod-kind.md','preguntarle al nodo que imágenes tiene','preguntarle al nodo qué imágenes tiene'),
]
for f,a,b in pairs:
    t=open(f,encoding='utf-8').read()
    print('ok' if a in t else 'NO', f, b[:50])
    if a in t: open(f,'w',encoding='utf-8').write(t.replace(a,b))
PY
python3 - <<'PY'
import re,glob
bad=r'\b(numero|version|codigo|tambien|aqui|asi|despues|sesion|razon|ultimo|ultima|deberia|ademas|dia|dias|mas|habria|seria|aca|arbol|maquina|estan|sintoma|proposito|pagina|linea|peticion|segun|unica|unico|vivia|imagenes)\b'
n=0
for f in sorted(glob.glob('*.md')):
    src=open(f,encoding='utf-8').read().split('\n'); infence=False
    for i,l in enumerate(src,1):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        m=re.search(r'(?://|#)\s*(.+)$',l)
        if m and re.findall(bad,m.group(1).lower()): n+=1; print(f'{f}:{i}: {l.strip()[:100]}')
print('restantes:',n)
PY

# --- 2026-09-11T03:52:10 · Final manual accent fixes
python3 - <<'PY'
pairs=[('11-trazabilidad-audit-log.md','ya es el DESPUES.','ya es el DESPUÉS.'),
('14-casi-prod-kind.md','# Aqui pasa lo importante','# Aquí pasa lo importante'),
('a13-docker-colima.md','# imagenes, sus volumenes y su cache (§8).','# imágenes, sus volúmenes y su cache (§8).'),
('a13-docker-colima.md','(conserva imagenes y volumenes)','(conserva imágenes y volúmenes)')]
for f,a,b in pairs:
    t=open(f,encoding='utf-8').read(); print('ok' if a in t else 'NO',f)
    if a in t: open(f,'w',encoding='utf-8').write(t.replace(a,b))
PY

# --- 2026-09-11T03:52:24 · Link appendices in phase headers
python3 - <<'PY'
import re,glob,os
amap={}
for p in glob.glob('a[01][0-9]-*.md'): amap[p[:3].upper()]=p
for p in glob.glob('bea-[01][0-9]-*.md'): amap[p[:6]]=p
files=sorted(glob.glob('[01][0-9]-*.md'))+sorted(glob.glob('be0*.md'))
for f in files:
    if 'convencion' in f or 'historia' in f: continue
    src=open(f,encoding='utf-8').read().split('\n')
    for i,l in enumerate(src[:9]):
        if 'Apéndices de apoyo:' not in l: continue
        orig=l
        def rep(m):
            code=m.group(1); label=m.group(2)
            p=amap.get(code if code.startswith('bea') else code.upper())
            return f'[{code} {label}](./{p})' if p else m.group(0)
        l=re.sub(r'\b(A\d{2}|bea-\d{2}) (\([^)]*\))',rep,l)
        cuad='./cuaderno-incidentes-be.md' if f.startswith('be0') else './cuaderno-incidentes.md'
        l=l.replace('Incidentes asociados:',f'[Incidentes asociados]({cuad}):')
        if l!=orig: src[i]=l; print(f,'\n   ',l[:200])
    open(f,'w',encoding='utf-8').write('\n'.join(src))
PY

# --- 2026-09-11T03:52:30 · Check be06 header
sed -n '1,7p' be06-los-rangos-y-la-historia-perdida.md; echo ---; sed -n '1,7p' be08-la-contencion-y-lo-irrecuperable.md | tail -2

# --- 2026-09-11T03:52:40 · Retry linking be06 header
python3 - <<'PY'
import re,glob
amap={}
for p in glob.glob('a[01][0-9]-*.md'): amap[p[:3].upper()]=p
for p in glob.glob('bea-[01][0-9]-*.md'): amap[p[:6]]=p
f='be06-los-rangos-y-la-historia-perdida.md'
src=open(f,encoding='utf-8').read().split('\n')
for i,l in enumerate(src[:9]):
    if 'Apéndices de apoyo:' not in l: continue
    print('encontrada línea',i, repr(l[:80]))
    def rep(m):
        code=m.group(1); p=amap.get(code)
        return f'[{code} {m.group(2)}](./{p})' if p else m.group(0)
    n=re.sub(r'\b(A\d{2}|bea-\d{2}) (\([^)]*\))',rep,l)
    n=n.replace('Incidentes asociados:','[Incidentes asociados](./cuaderno-incidentes-be.md):')
    src[i]=n; print(n)
open(f,'w',encoding='utf-8').write('\n'.join(src))
PY

# --- 2026-09-11T03:52:49 · Verify all phase headers linked and links valid
grep -L "Apéndices de apoyo: \[" [01][0-9]-*.md be0*.md 2>/dev/null | grep -v convencion | grep -v historia; echo "---(los que faltan arriba)"; python3 - <<'PY'
import re,glob,os
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
bad=0
for f in files:
    t=open(f,encoding='utf-8').read()
    for m in re.finditer(r'\[([^\]]*)\]\(([^)]+)\)',t):
        tgt=m.group(2).strip()
        if tgt.startswith(('http','#','mailto')): continue
        p=tgt.split('#')[0]
        if not p: continue
        full=os.path.normpath(os.path.join(os.path.dirname(f),p))
        if not os.path.exists(full): bad+=1; print(f,'->',tgt)
print('links locales rotos:',bad)
PY

# --- 2026-09-11T03:52:59 · Final anchor validation
python3 - <<'PY'
import re,glob,os
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip()).replace('`','')
    h=re.sub(r'\*\*|\*','',h); out=[]
    for c in h.lower():
        if c=='️': out.append(c)
        elif c.isalnum() or c in '-_': out.append(c)
        elif c.isspace(): out.append('-')
    return ''.join(out)
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
heads={f:{slug(m.group(1)) for m in (re.match(r'^#{1,6}\s+(.*)$',l) for l in open(f,encoding='utf-8')) if m} for f in files}
bad=0
for f in files:
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\]\(([^)\s]*#[^)\s]+)\)',l):
            p,a=m.group(1).split('#',1)
            tf=f if not p else os.path.normpath(os.path.join(os.path.dirname(f),p))
            if tf in heads and a not in heads[tf]: bad+=1; print(f'{f}:{i} -> {m.group(1)}')
print('anclas rotas:',bad)
PY

# --- 2026-09-11T03:53:06 · Locate README insertion points
grep -n "Catorce fases obligatorias\|^| Fase | Archivo\|^| 🛠️ 0\|^- \`NN-\*\.md\`\|^## 🗂️" README.md

# --- 2026-09-11T03:53:10 · Read README context
sed -n '45,56p' README.md; echo ...; sed -n '163,170p' README.md

# --- 2026-09-11T03:53:18 · Add history doc to README
python3 - <<'PY'
f='README.md'
t=open(f,encoding='utf-8').read()
old="""Catorce fases obligatorias suman **108h**, más **14h** de cuaderno de incidentes.
Las horas del track forense van dentro de las de cada fase, no aparte. Las horas de apéndices no
cuentan en el calendario."""
new="""Antes de la primera hay una lectura de veinte minutos que no es una fase y no
ocupa calendario: [`00-historia-del-sistema.md`](00-historia-del-sistema.md), la
ficha de contexto que cuenta de dónde viene LabCore. Se lee **antes de la Fase 0**
y es lo que evita que el estudiante juzgue el código en vez de entenderlo.

Catorce fases obligatorias suman **108h**, más **14h** de cuaderno de incidentes.
Las horas del track forense van dentro de las de cada fase, no aparte. Las horas de apéndices no
cuentan en el calendario."""
assert old in t
t=t.replace(old,new,1)
old2="- `NN-*.md` — las fases, en orden de lectura.\n"
new2=("- `00-historia-del-sistema.md` — la ficha de contexto que se lee antes de la\n"
      "  Fase 0. No lleva código: lleva los motivos de cada decisión de 2019, y es de\n"
      "  donde sale el encuadre del track BE.\n"
      "- `NN-*.md` — las fases, en orden de lectura.\n")
assert old2 in t
t=t.replace(old2,new2,1)
open(f,'w',encoding='utf-8').write(t)
print('ok')
PY
sed -n '47,60p' README.md

# --- 2026-09-11T03:53:23 · Check phase 0 header
sed -n '1,12p' 00-setup-hola-mundo.md

# --- 2026-09-11T03:53:27 · Point phase 0 at the history doc
python3 - <<'PY'
f='00-setup-hola-mundo.md'
t=open(f,encoding='utf-8').read()
old="> Depende de: ninguna · Habilita: Fase 1 — Estructura base + NgRx\n"
new=("> Depende de: ninguna · Habilita: Fase 1 — Estructura base + NgRx\n"
     "> Antes de empezar: [`00-historia-del-sistema.md`](./00-historia-del-sistema.md), veinte minutos que explican por qué LabCore está así\n")
assert old in t
open(f,'w',encoding='utf-8').write(t.replace(old,new,1))
print('ok')
PY
sed -n '1,7p' 00-setup-hola-mundo.md

# --- 2026-09-11T03:53:33 · Read README appendix paragraph
sed -n '193,210p' README.md

# --- 2026-09-11T03:53:51 · Replace README appendix prose with a linked table
python3 - <<'PY'
f='README.md'
t=open(f,encoding='utf-8').read()
old = """Las catorce fases obligatorias están escritas, y de los apéndices están **A01
(Material)**, **A02 (Bootstrap 4 + Sass)**, **A03 (Node y npm)**, **A04 (Webpack
oculto)**, **A05 (RxJS de supervivencia)**, **A06 (NgRx 8)**, **A07 (i18n en
Angular 8)**, **A08 (PDF en cliente)**, **A09 (Kubernetes para el dev de
front)**, **A10 (Migración 8 → 9)** y **A11 (Migración 9 → 16)**, los dos últimos
opcionales, y los dos de Apple Silicon, **A12 (dependencias problemáticas en
arm64 / M1)** y **A13 (Docker + Colima)**. Con eso, **las catorce fases y los
trece apéndices están completos**, y también el track forense: `forense-master.md`
y las quince piezas, de `forense-fase-00.md` a `forense-fase-14.md`. Falta una sola
cosa: los veintiún enunciados del cuaderno de incidentes, cuyos IDs ya están
reservados por las fases que los producen. Es el único enlace del curso que todavía
no resuelve."""
new = """### 📎 Los trece apéndices

Consulta bajo demanda: se entra por el índice buscando algo concreto y se sale.
Sus horas no cuentan en el calendario.

| Apéndice | Archivo | Usado por |
|---|---|---|
| 🎨 A01 · Angular Material | [`a01-material.md`](a01-material.md) | Fases 3, 5, 6, 7, 8 |
| 💅 A02 · Bootstrap 4 + Sass | [`a02-bootstrap-sass.md`](a02-bootstrap-sass.md) | Fases 0, 1, 4, 5, 6, 8, 10, 13 |
| 📦 A03 · Node y npm | [`a03-node-npm.md`](a03-node-npm.md) | Fases 0, 4, 12, 13, 14 |
| 🧱 A04 · Webpack oculto | [`a04-webpack-oculto.md`](a04-webpack-oculto.md) | Fases 10, 13 |
| 🌊 A05 · RxJS de supervivencia | [`a05-rxjs.md`](a05-rxjs.md) | Fases 1-4, 8-12 |
| 🗃️ A06 · NgRx 8 | [`a06-ngrx.md`](a06-ngrx.md) | Fases 1, 5-12 |
| 🌐 A07 · i18n en Angular 8 | [`a07-i18n.md`](a07-i18n.md) | Fases 2-4, 6-10, 13 |
| 📄 A08 · PDF en cliente | [`a08-pdf-cliente.md`](a08-pdf-cliente.md) | Fase 9 |
| ☸️ A09 · Kubernetes para el dev de front | [`a09-kubernetes.md`](a09-kubernetes.md) | Fases 13, 14 |
| 🔥 A10 · Migración 8 → 9 | [`a10-migracion-8-9.md`](a10-migracion-8-9.md) | Fases 3, 4, 12, 13, como referencia |
| 🔥 A11 · Migración 9 → 16 | [`a11-migracion-9-16.md`](a11-migracion-9-16.md) | Fases 4, 13, como referencia |
| 🔥 A12 · Dependencias problemáticas en arm64 / M1 | [`a12-arm64-m1.md`](a12-arm64-m1.md) | Fases 0, 14 |
| 🔥 A13 · Docker + Colima en Apple Silicon | [`a13-docker-colima.md`](a13-docker-colima.md) | Fases 0, 13, 14 |

Con eso, **las catorce fases y los trece apéndices están completos**, y también el
track forense: [`forense-master.md`](forense-master.md) y las quince piezas, de
[`forense-fase-00.md`](forense-fase-00.md) a
[`forense-fase-14.md`](forense-fase-14.md). Falta una sola cosa: los veintiún
enunciados del cuaderno de incidentes, cuyos IDs ya están reservados por las fases
que los producen. Es el único enlace del curso que todavía no resuelve."""
assert old in t
open(f,'w',encoding='utf-8').write(t.replace(old,new,1))
print('ok')
PY

# --- 2026-09-11T03:53:58 · Link phase files in README table
python3 - <<'PY'
import re
f='README.md'
lines=open(f,encoding='utf-8').read().split('\n')
n=0
for i,l in enumerate(lines):
    if l.startswith('| ') and '`' in l and '](' not in l:
        def rep(m):
            global n
            fn=m.group(1)
            import os
            if os.path.exists(fn):
                n+=1
                return f'[`{fn}`]({fn})'
            return m.group(0)
        lines[i]=re.sub(r'`([0-9a-z][0-9a-zA-Z._-]*\.md)`',rep,l)
open(f,'w',encoding='utf-8').write('\n'.join(lines))
print('enlaces añadidos:',n)
PY
sed -n '59,66p' README.md

# --- 2026-09-11T03:54:04 · Final link validation
python3 - <<'PY'
import re,glob,os
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
bad=0
for f in files:
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\[([^\]]*)\]\(([^)]+)\)',l):
            tgt=m.group(2).strip()
            if tgt.startswith(('http','#','mailto')): continue
            p=tgt.split('#')[0]
            if not p: continue
            if not os.path.exists(os.path.normpath(os.path.join(os.path.dirname(f),p))):
                bad+=1; print(f'{f}:{i} -> {tgt}')
print('links rotos:',bad)
PY
echo "=== README apéndices ==="; grep -n "Los trece apéndices" -A4 README.md | head -8

# --- 2026-09-11T03:54:10 · Check README heading structure
grep -nE "^#{2,3} " README.md

# --- 2026-09-11T03:54:19 · Read README region to relocate
sed -n '186,232p' README.md

# --- 2026-09-11T03:54:23 · Relocate appendix table under Las fases
python3 - <<'PY'
f='README.md'
t=open(f,encoding='utf-8').read()
start=t.index('### 📎 Los trece apéndices')
end=t.index('Con eso, **las catorce fases')
tabla=t[start:end].rstrip()+'\n'
t=t[:start]+t[end:]
# insertar antes de "## 📓 El cuaderno de incidentes"
k=t.index('## 📓 El cuaderno de incidentes')
t=t[:k]+tabla+'\n'+t[k:]
open(f,'w',encoding='utf-8').write(t)
PY
grep -nE "^#{2,3} " README.md

# --- 2026-09-11T03:54:27 · Verify README structure after move
sed -n '86,95p' README.md; echo "..."; sed -n '108,124p' README.md; echo "..."; sed -n '212,222p' README.md

# --- 2026-09-11T03:54:35 · Fix stale heading and link filenames in README
python3 - <<'PY'
import re,os
f='README.md'
t=open(f,encoding='utf-8').read()
t=t.replace('## 🔥 Track opcional de backend (nueve fases escritas)','## 🔥 Track opcional de backend (completo)',1)
# enlazar nombres de archivo sueltos en la sección de organización y prompts
def rep(m):
    fn=m.group(1)
    return f'[`{fn}`]({fn})' if os.path.exists(fn) else m.group(0)
start=t.index('## 🗂️ Cómo está organizado el repositorio')
head,tail=t[:start],t[start:]
tail=re.sub(r'(?<!\[)`([0-9a-z][0-9a-zA-Z._/-]*\.md)`(?!\])',rep,tail)
open(f,'w',encoding='utf-8').write(head+tail)
PY
sed -n '189,215p' README.md

# --- 2026-09-11T03:54:45 · Tidy README bullet and inspect forense-master
python3 - <<'PY'
f='README.md'
t=open(f,encoding='utf-8').read()
t=t.replace("""- `aNN-*.md` — consulta rápida bajo demanda (Material, Bootstrap+Sass,
  Node y npm, Webpack oculto, RxJS de supervivencia, NgRx 8, i18n, PDF en
  cliente, Kubernetes, migraciones 8→9 y 9→16, arm64/M1, Docker + Colima).""",
"""- `aNN-*.md` — consulta rápida bajo demanda: los trece apéndices, con su tabla
  completa y a quién sirve cada uno, están en **📚 Las fases → 📎 Los trece
  apéndices**.""",1)
open(f,'w',encoding='utf-8').write(t)
PY
wc -l forense-master.md; grep -nE "^## |^### " forense-master.md

# --- 2026-09-11T03:54:49 · Read forense-master index tables
sed -n '32,101p' forense-master.md

# --- 2026-09-11T03:55:03 · Clarify master symptom table navigation
python3 - <<'PY'
f='forense-master.md'
t=open(f,encoding='utf-8').read()
old="La tabla que se consulta de verdad. A la izquierda, lo que ves o lo que te cuentan; a la derecha, dónde empezar."
new=("La tabla que se consulta de verdad. A la izquierda, lo que ves o lo que te cuentan; a la derecha, dónde empezar.\n\n"
     "Cada fila te manda **a la fase**, que es donde está el código y el contexto. El recorrido paso a paso vive en su "
     "pieza: la tienes enlazada en la sección 6 de esa fase y, directa, en el índice de §2 — que es la tabla de arriba y "
     "la que conviene abrir en otra pestaña mientras investigas.")
assert old in t
open(f,'w',encoding='utf-8').write(t.replace(old,new,1))
print('ok')
PY

# --- 2026-09-11T03:55:11 · Extract incident references from forensic pieces
for n in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do printf "f%s: " $n; grep -oE "Incidentes del cuaderno que usan esta ruta:[^\n]*" forense-fase-$n.md | head -1 | cut -c1-160; echo; done

# --- 2026-09-11T03:55:19 · Check incident coverage by forensic pieces
python3 - <<'PY'
import re,glob
ids=set()
for f in sorted(glob.glob('forense-fase-*.md')):
    t=open(f,encoding='utf-8').read()
    m=re.search(r'Incidentes del cuaderno que usan esta ruta:\*\*(.*?)(?:\n\*\*|\n\n|$)',t,re.S)
    if m:
        for x in re.findall(r'\*\*(\d{2})\*\*',m.group(1)): ids.add(x)
print('cubiertos:',sorted(ids))
print('sin pieza:',[('%02d'%i) for i in range(1,22) if '%02d'%i not in ids])
PY

# --- 2026-09-11T03:55:28 · Verify BE tag naming convention
grep -hoE "git tag -a [a-z0-9-]+" be0*.md | sort; echo "=== esperados ==="; for f in be0*.md; do echo "be-fase-${f%.md}" | sed 's/be-fase-be/be-fase-/'; done

# --- 2026-09-11T03:55:34 · Verify base tag names and appendix tag declarations
grep -hoE "fase-[0-9]{2}-[a-z0-9-]+" [01][0-9]-*.md a*.md 2>/dev/null | sort -u | head -20; echo "=== apéndices: bloque 🏷️ con prefijo correcto ==="; grep -c "tag propio" a*.md bea-*.md | grep ":0" || echo "todos lo declaran"

# --- 2026-09-11T03:55:38 · Trace tag-name matches and check a11 tag block
grep -rn "fase-00-el-contrato\|fase-03-la-costura" [01][0-9]-*.md a*.md 2>/dev/null | head; echo "=== a11 bloque tag ==="; grep -n -A4 "🏷️" a11-migracion-9-16.md | tail -8

# --- 2026-09-11T03:55:48 · Final integrity validation
python3 - <<'PY'
import glob,re
for f in sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md')):
    n=sum(1 for l in open(f,encoding='utf-8') if re.match(r'^\s*```(?!`)',l))
    n4=sum(1 for l in open(f,encoding='utf-8') if re.match(r'^\s*````',l))
    if n%2: print('fences impares (```):',f,n)
    if n4%2: print('fences impares (````):',f,n4)
print('chequeo de fences hecho')
PY
python3 - <<'PY'
import re,glob,os
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip()).replace('`','')
    h=re.sub(r'\*\*|\*','',h); out=[]
    for c in h.lower():
        if c=='️': out.append(c)
        elif c.isalnum() or c in '-_': out.append(c)
        elif c.isspace(): out.append('-')
    return ''.join(out)
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
heads={f:{slug(m.group(1)) for m in (re.match(r'^#{1,6}\s+(.*)$',l) for l in open(f,encoding='utf-8')) if m} for f in files}
b1=b2=0
for f in files:
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\[([^\]]*)\]\(([^)\s]+)\)',l):
            t=m.group(2)
            if t.startswith(('http','mailto')): continue
            p,_,a=t.partition('#')
            if p:
                full=os.path.normpath(os.path.join(os.path.dirname(f),p))
                if not os.path.exists(full): b1+=1; print('LINK',f,i,t)
            tf=f if not p else os.path.normpath(os.path.join(os.path.dirname(f),p))
            if a and tf in heads and a not in heads[tf]: b2+=1; print('ANCLA',f,i,t)
print('links rotos:',b1,'anclas rotas:',b2)
PY

# --- 2026-09-11T03:55:53 · Inspect fences in phase 8
grep -nE '^\s*```' 08-resultados-rangos.md | head -30

# --- 2026-09-11T03:56:01 · Inspect unbalanced fence region
sed -n '86,95p' 08-resultados-rangos.md; echo "......"; sed -n '160,172p' 08-resultados-rangos.md

# --- 2026-09-11T03:56:09 · Check whether fence imbalance is pre-existing
git -C .. diff -U0 -- angular-8-legacy-for-backend-devs/08-resultados-rangos.md | grep -E "^[-+][^-+]" | head; echo "=== ¿pre-existente? ==="; git -C .. show HEAD:angular-8-legacy-for-backend-devs/08-resultados-rangos.md | grep -cE '^\s*```'

# --- 2026-09-11T03:56:13 · Locate exact fence insertion point
sed -n '163,167p' 08-resultados-rangos.md

# --- 2026-09-11T03:56:17 · Close the unbalanced code fence in phase 8
python3 - <<'PY'
f='08-resultados-rangos.md'
lines=open(f,encoding='utf-8').read().split('\n')
assert lines[162].strip()=='// acepto igual. Esa es la semilla del incidente 12.'
assert lines[163]=='}'
lines[162]=lines[162].replace('acepto igual','aceptó igual')
lines.insert(164,'```')
open(f,'w',encoding='utf-8').write('\n'.join(lines))
PY
sed -n '161,170p' 08-resultados-rangos.md; echo "=== fences ==="; grep -cE '^\s*```' 08-resultados-rangos.md

# --- 2026-09-11T03:56:28 · Re-run accent pass after fence fix
python3 - <<'PY'
import re,glob
MAP={'numero':'número','numeros':'números','version':'versión','codigo':'código','tambien':'también','aqui':'aquí','asi':'así',
'despues':'después','razon':'razón','ultimo':'último','ultima':'última','deberia':'debería','ademas':'además',
'dia':'día','dias':'días','mas':'más','seria':'sería','aca':'acá','arbol':'árbol','maquina':'máquina',
'estan':'están','sintoma':'síntoma','proposito':'propósito','pagina':'página','linea':'línea','lineas':'líneas',
'segun':'según','unica':'única','unico':'único','peticion':'petición'}
def fixcion(w):
    lw=w.lower()
    return w[:-2]+'ó'+w[-1] if len(lw)>6 and lw.endswith(('cion','sion','xion')) else w
for f in sorted(glob.glob('*.md')):
    src=open(f,encoding='utf-8').read().split('\n'); infence=False; ch=0
    for i,l in enumerate(src):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        if f=='forense-fase-08.md' and i+1==136: continue
        m=re.search(r'((?://|#)\s*)(.+)$',l)
        if not m: continue
        h=l[:m.start(2)]; b=m.group(2)
        n=re.sub(r'\b[A-Za-zÁÉÍÓÚáéíóúñÑ]+\b',lambda w:MAP.get(w.group(0),fixcion(w.group(0))),b)
        if n!=b: src[i]=h+n; ch+=1; print(f,i+1,n.strip()[:100])
    if ch: open(f,'w',encoding='utf-8').write('\n'.join(src))
PY

# --- 2026-09-11T03:56:35 · Final fence check and diff summary
python3 - <<'PY'
import glob,re
for f in sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md')):
    n=sum(1 for l in open(f,encoding='utf-8') if re.match(r'^\s*```(?!`)',l))
    n4=sum(1 for l in open(f,encoding='utf-8') if re.match(r'^\s*````',l))
    if n%2 or n4%2: print('DESBALANCE',f,n,n4)
print('ok fences')
PY
git -C .. diff --stat -- angular-8-legacy-for-backend-devs | tail -3; git -C .. status --short -- angular-8-legacy-for-backend-devs | wc -l

# --- 2026-09-11T03:56:45 · Verify bea-01 numbering
sed -n '/^## Índice/,/^---/p' bea-01-java-8-y-spring-para-quien-no-escribe-java.md; grep -nE "^## " bea-01-java-8-y-spring-para-quien-no-escribe-java.md

# --- 2026-09-11T03:56:55 · Final section-reference validation
python3 - <<'PY'
import re,glob
def secs(f):
    s=set()
    for line in open(f,encoding='utf-8'):
        m=re.match(r'^#{2,4}\s+(?:[^\w\s]*\s*)?(\d+(?:\.\d+)*)[.)]?\s',line)
        if m: s.add(m.group(1))
    return s
S={f:secs(f) for f in glob.glob('*.md')}
def resolve(tag):
    tag=tag.lower()
    if tag.startswith('bea'): g=glob.glob('bea-'+tag[-2:]+'-*.md')
    elif tag.startswith('be'): g=glob.glob('be'+tag[-2:]+'-*.md')
    elif tag.startswith('a'): g=glob.glob(tag+'-*.md')
    else: g=glob.glob(tag+'-*.md')
    return g[0] if g else None
pat=re.compile(r'\b(A\d{2}|bea-\d{2}|be\d{2}|Fase\s+\d{1,2})\**\s*§\s*(\d+(?:\.\d+)*)')
bad=0
for f in sorted(glob.glob('*.md')):
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in pat.finditer(l.replace('`','')):
            tag,num=m.group(1),m.group(2)
            t=resolve('%02d'%int(re.search(r'\d+',tag).group())) if tag.lower().startswith('fase') else resolve(tag)
            if not t: continue
            if num not in S[t] and num.split('.')[0] not in S[t]:
                bad+=1; print(f'{f}:{i} {tag} §{num} -> {t}')
print('refs de sección rotas:',bad)
PY

# --- 2026-09-11T03:57:02 · List changed files with line counts
git -C .. diff --numstat -- angular-8-legacy-for-backend-devs | awk '{print $3, "+"$1" -"$2}' | sed 's|angular-8-legacy-for-backend-devs/||' | sort

# --- 2026-09-11T03:57:14 · Check Spanish strings in code
grep -rnoE "'[^']*(traduccion|configuracion|sesion|numero|version|codigo|peticion)[^']*'" a*.md bea-*.md forense-*.md 2>/dev/null | head

# --- 2026-09-11T03:57:16 · Inspect Spanish code strings
sed -n '384,388p' a07-i18n.md; echo ---; sed -n '68,74p' bea-07-transacciones-replica-sets-y-el-standalone.md

# --- 2026-09-11T03:57:20 · Fix Spanish strings in code samples
python3 - <<'PY'
pairs=[('a07-i18n.md',"'[i18n] clave sin traduccion:'","'[i18n] clave sin traducción:'"),
('bea-07-transacciones-replica-sets-y-el-standalone.md',"print('codigo:  ' + e.code);","print('código:  ' + e.code);")]
for f,a,b in pairs:
    t=open(f,encoding='utf-8').read(); print('ok' if a in t else 'NO',f)
    if a in t: open(f,'w',encoding='utf-8').write(t.replace(a,b))
PY

# --- 2026-09-11T04:02:25 · Full markdown link and anchor validation
python3 - <<'PY'
import re,glob,os
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip()).replace('`','')
    h=re.sub(r'\*\*|\*','',h); out=[]
    for c in h.lower():
        if c=='️': out.append(c)
        elif c.isalnum() or c in '-_': out.append(c)
        elif c.isspace(): out.append('-')
    return ''.join(out)
heads={f:{slug(m.group(1)) for m in (re.match(r'^#{1,6}\s+(.*)$',l) for l in open(f,encoding='utf-8')) if m} for f in files}
bl=ba=0; n=0
for f in files:
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\[([^\]]*)\]\(([^)\s]+)\)',l):
            t=m.group(2); n+=1
            if t.startswith(('http','mailto')): continue
            p,_,a=t.partition('#')
            tf=f if not p else os.path.normpath(os.path.join(os.path.dirname(f),p))
            if p and not os.path.exists(tf): bl+=1; print('LINK ROTO',f,i,t)
            if a and tf in heads and a not in heads[tf]: ba+=1; print('ANCLA ROTA',f,i,t)
print(f'{n} enlaces markdown revisados en {len(files)} archivos | rotos: {bl} | anclas rotas: {ba}')
PY

# --- 2026-09-11T04:02:32 · Check backticked filenames exist
python3 - <<'PY'
import re,glob,collections,os
# 1. nombres de archivo .md citados en backticks que no existen
exist={os.path.basename(p) for p in glob.glob('*.md')}|{os.path.basename(p) for p in glob.glob('prompts/*.md')}
bad=collections.defaultdict(list)
for f in sorted(glob.glob('*.md')):
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'`([A-Za-z0-9_./-]+\.md)`',l):
            b=os.path.basename(m.group(1))
            if b not in exist and not re.search(r'NN|<|\*|\{',b): bad[m.group(1)].append(f'{f}:{i}')
print('== archivos .md citados que no existen (fuera de prompts/) ==')
for k,v in sorted(bad.items()): print(' ',k,'->',', '.join(v[:5]))
PY

# --- 2026-09-11T04:02:41 · Check phase dependency chains
python3 - <<'PY'
import re,glob
print('=== BASE ===')
for f in sorted(glob.glob('[01][0-9]-*.md')):
    if 'convencion' in f or 'historia' in f: continue
    h='\n'.join(open(f,encoding='utf-8').read().split('\n')[:8])
    d=re.search(r'Depende de:([^\n·]*)',h); hab=re.search(r'Habilita:([^\n]*)',h)
    print(f'{f[:2]}  dep={d.group(1).strip()[:52]:<52} hab={hab.group(1).strip()[:55] if hab else "—"}')
print('\n=== BE ===')
for f in sorted(glob.glob('be0*.md')):
    h='\n'.join(open(f,encoding='utf-8').read().split('\n')[:8])
    d=re.search(r'Depende de:([^\n]*)',h); hab=re.search(r'Habilita:([^\n]*)',h)
    print(f'{f[:4]} dep={d.group(1).strip()[:56]:<56} hab={hab.group(1).strip()[:35] if hab else "—"}')
PY

# --- 2026-09-11T04:02:57 · Sum declared hours per phase
python3 - <<'PY'
import re,glob
tot=0
for f in sorted(glob.glob('[01][0-9]-*.md')):
    if 'convencion' in f or 'historia' in f: continue
    h=open(f,encoding='utf-8').read().split('\n')[2]
    m=re.search(r'\*\*(\d+)\s*horas?\*\*',h)
    v=int(m.group(1)) if m else 0
    print(f[:2],v,'' if m else '  <-- sin horas en cabecera')
    tot+=v
print('TOTAL base:',tot)
tb=0
for f in sorted(glob.glob('be0*.md')):
    h=open(f,encoding='utf-8').read().split('\n')[2]
    m=re.search(r'\*\*(\d+)\s*horas?\*\*',h); v=int(m.group(1)) if m else 0
    print(f[:4],v); tb+=v
print('TOTAL BE:',tb)
PY

# --- 2026-09-11T04:03:07 · Cross-check README hours against phase headers
python3 - <<'PY'
import re,glob
hdr={}
for f in sorted(glob.glob('[01][0-9]-*.md'))+sorted(glob.glob('be0*.md')):
    if 'convencion' in f or 'historia' in f: continue
    m=re.search(r'\*\*(\d+)\s*horas?\*\*',open(f,encoding='utf-8').read().split('\n')[2])
    hdr[f]=int(m.group(1)) if m else None
bad=0
for l in open('README.md',encoding='utf-8'):
    m=re.search(r'\|\s*\[?`?([a-z0-9][a-z0-9._-]*\.md)`?\]?(?:\([^)]*\))?\s*\|\s*(\d+)h\s*\|',l)
    if m:
        f,h=m.group(1),int(m.group(2))
        if f in hdr and hdr[f]!=h: bad+=1; print('DESAJUSTE',f,'README',h,'cabecera',hdr[f])
print('desajustes de horas README↔fase:',bad)
PY
echo "=== cuaderno BE: horas ==="; head -4 cuaderno-incidentes-be.md | tail -2; echo "=== cuaderno base ==="; head -4 cuaderno-incidentes.md | tail -2

# --- 2026-09-11T04:03:17 · Check stack version consistency
python3 - <<'PY'
import re,glob,collections
# versiones del stack citadas, para detectar contradicciones
pats={
 'Angular': r'Angular\s+(8\.\d+\.\d+)',
 'CLI': r'CLI\s+(8\.\d+\.\d+)',
 'TypeScript': r'TypeScript\s+(3\.\d+\.\d+)',
 'RxJS': r'RxJS\s+(6\.\d+\.\d+)',
 'NgRx': r'NgRx\s+(8\.\d+\.\d+)',
 'Material': r'(?:Material(?: y CDK)?)\s+(8\.\d+\.\d+)',
 'zone.js': r'zone\.js\s+(0\.\d+\.\d+)',
 'node-sass': r'node-sass\s+(4\.\d+\.\d+)',
 'jsPDF': r'jsPDF\s+(1\.\d+\.\d+)',
 'Bootstrap': r'Bootstrap\s+(4\.\d+\.\d+)',
 'json-server': r'json-server\s+(0\.\d+\.\d+)',
 'ngx-translate': r'@ngx-translate/core[`\s]+(\d+\.\d+\.\d+)',
 'Spring Boot': r'Spring Boot\s+(2\.\d+\.\d+)',
}
for k,p in pats.items():
    c=collections.Counter()
    for f in glob.glob('*.md'):
        for v in re.findall(p,open(f,encoding='utf-8').read()): c[v]+=1
    if len(c)>1: print('⚠️ ',k,dict(c))
    elif c: print('ok',k,list(c)[0],f'({sum(c.values())} menciones)')
PY

# --- 2026-09-11T04:03:26 · Check runtime version consistency
python3 - <<'PY'
import re,glob,collections
pats={'Node':r'Node\s+\**(1[0-9]\.\d+\.\d+)',
 'npm':r'npm\s+(6\.\d+\.\d+)',
 'node-sass':r'node-sass`?\s+(4\.\d+\.\d+)',
 'MongoDB tags':r'mongo:(\d+\.\d+(?:\.\d+)?)',
 'Mongo driver':r'mongo-java-driver[`\s]+(\d+\.\d+\.\d+)',
 'Java':r'Java\s+(\d+)\b',
 'Maven':r'Maven\s+(3\.\d+\.\d+)'}
for k,p in pats.items():
    c=collections.Counter()
    for f in glob.glob('*.md'):
        for v in re.findall(p,open(f,encoding='utf-8').read()): c[v]+=1
    print(('⚠️  ' if len(c)>1 else 'ok  ')+k, dict(c))
PY

# --- 2026-09-11T04:03:37 · Compare phase hooks with forensic pieces
python3 - <<'PY'
import re,glob
for n in ['%02d'%i for i in range(15)]:
    ph=[f for f in glob.glob(f'{n}-*.md') if 'convencion' not in f and 'historia' not in f][0]
    t=open(ph,encoding='utf-8').read()
    m=re.search(r'### Pieza forense de esta fase(.*?)(?=\n## )',t,re.S)
    hook=' '.join(m.group(1).split()) if m else '??'
    print(f'--- Fase {n} ({ph})')
    print('  GANCHO:',hook[:400])
    p=open(f'forense-fase-{n}.md',encoding='utf-8').read()
    tk=re.findall(r'^### .*$',p,re.M)
    tickets=re.findall(r'^## 🎫(.*)$',p,re.M)
    print('  PIEZA 🎫:',(tickets[0].strip() if tickets else '??')[:120])
    print('  RUTAS:',re.findall(r'^## 🧭 (.*)$',p,re.M))
PY

# --- 2026-09-11T04:03:48 · Validate deferral targets in section 3
python3 - <<'PY'
import re,glob
pat=re.compile(r'(?:Fase|fase)\s+(\d{1,2})\b')
bad=0; tot=0
for f in sorted(glob.glob('[01][0-9]-*.md')):
    if 'convencion' in f or 'historia' in f: continue
    t=open(f,encoding='utf-8').read()
    m=re.search(r'## 🚫 3\..*?(?=\n## )',t,re.S)
    if not m: print('SIN SECCIÓN 3:',f); continue
    ns={int(x) for x in pat.findall(m.group(0))}
    cur=int(f[:2])
    for n in sorted(ns):
        tot+=1
        if n>14: bad+=1; print(f'{f}: difiere a Fase {n} (no existe)')
        elif n<cur and n!=cur: print(f'  ⓘ {f}: menciona Fase {n} (anterior) en §3')
print('referencias de diferimiento revisadas:',tot,'inválidas:',bad)
PY

# --- 2026-09-11T04:04:01 · Cross-check incident reservations against notebook index
python3 - <<'PY'
import re,glob
# índice del cuaderno base
idx={}
for l in open('cuaderno-incidentes.md',encoding='utf-8'):
    m=re.match(r'\|\s*(\d{2})\s*\|\s*(\d{1,2})\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(🟢|🟡|🟠|🔴)',l)
    if m: idx[m.group(1)]=(m.group(2),m.group(3),m.group(4),m.group(5))
print(len(idx),'incidentes en el índice')
# reservas declaradas en las fases
res={}
for f in sorted(glob.glob('[01][0-9]-*.md')):
    if 'convencion' in f or 'historia' in f: continue
    t=open(f,encoding='utf-8').read()
    m=re.search(r'### Reservas para el cuaderno de incidentes(.*)$',t,re.S)
    if not m: continue
    for mm in re.finditer(r'\*\*(\d{2})\*\*|\|\s*(\d{2})\s*\|',m.group(1)):
        i=mm.group(1) or mm.group(2); res.setdefault(i,f)
print('IDs reservados en fases:',sorted(res))
print('en índice y no reservados:',sorted(set(idx)-set(res)))
print('reservados y no en índice:',sorted(set(res)-set(idx)))
for i in sorted(set(idx)&set(res)):
    fase_idx=idx[i][0]
    if fase_idx.zfill(2)!=res[i][:2]:
        print(f'  ⚠️ {i}: índice dice fase {fase_idx}, lo reserva {res[i][:2]}')
PY

# --- 2026-09-11T04:04:07 · Inspect incident reservations in phases 5 and 7
for f in 05-pacientes.md 07-muestras-custodia.md; do echo "=== $f"; sed -n '/### Reservas para el cuaderno/,$p' "$f"; done

# --- 2026-09-11T04:04:12 · Locate incident ID 22 mention
grep -rn "\*\*22\*\*" [01][0-9]-*.md | head

# --- 2026-09-11T04:04:20 · Check reservation subsections per phase
python3 - <<'PY'
import re,glob
for f in sorted(glob.glob('[01][0-9]-*.md')):
    if 'convencion' in f or 'historia' in f: continue
    t=open(f,encoding='utf-8').read()
    head='\n'.join(t.split('\n')[:8])
    m=re.search(r'Incidentes asociados\]?\([^)]*\)?:([^\n]*)',head)
    ids=re.findall(r'\b\d{2}\b',m.group(1)) if m else []
    has=('Reservas para el cuaderno' in t)
    pend=('📌 Pendientes' in t)
    print(f'{f[:2]}  ids={ids or "—"}  reservas={"sí" if has else "NO"}  pendientes={"sí" if pend else "NO"}')
PY

# --- 2026-09-11T04:04:35 · Inspect notebook index header and reservation format
sed -n '125,135p' cuaderno-incidentes.md; echo "=== ejemplo de reservas (13) ==="; sed -n '/### Reservas para el cuaderno/,$p' 13-build-despliegue.md; echo "=== cola de 11 ==="; tail -12 11-trazabilidad-audit-log.md

# --- 2026-09-11T04:04:41 · Find all reservation subsections
grep -n "eserva.* para el cuaderno" [01][0-9]-*.md be0*.md | sed 's/:.*Reserva/: Reserva/'

# --- 2026-09-11T04:04:49 · Inspect tails of phases 0-4
for f in 00-setup-hola-mundo.md 01-estructura-base-ngrx.md 02-i18n.md 03-autenticacion.md 04-mock-api-caos.md; do echo "=== $f (últimas 6 líneas)"; tail -6 "$f"; done

# --- 2026-09-11T04:04:57 · Check incident ID declarations in phases 0-4
for p in "00-setup-hola-mundo.md 01 02" "01-estructura-base-ngrx.md 03" "02-i18n.md 04" "03-autenticacion.md 05" "04-mock-api-caos.md 06 08"; do set -- $p; f=$1; shift; echo "=== $f -> incidentes $*"; for id in "$@"; do printf "  %s: " $id; grep -c "incidente[s]* \*\*$id\*\*\|incidente $id\|incidentes $id\|\*\*$id\*\*" "$f"; done; done

# --- 2026-09-11T04:05:03 · Locate incident mentions in phases 0-4
python3 - <<'PY'
import re
m={'00-setup-hola-mundo.md':['01','02'],'01-estructura-base-ngrx.md':['03'],
   '02-i18n.md':['04'],'03-autenticacion.md':['05'],'04-mock-api-caos.md':['06','08']}
for f,ids in m.items():
    t=open(f,encoding='utf-8').read()
    print('===',f)
    for i in ids:
        hits=[l.strip()[:120] for l in t.split('\n') if re.search(rf'\b{i}\b',l) and ('ncidente' in l)]
        print(f'  {i}: {len(hits)} menciones ->', hits[:2])
PY

# --- 2026-09-11T04:05:15 · Read incident hook prose in phases 0,1,3
grep -n -B2 -A4 "incidentes 01 y 02" 00-setup-hola-mundo.md | head -20; echo ===; grep -n -A4 "incidente 03\*\*" 01-estructura-base-ngrx.md | head -12; echo ===; grep -n -A3 "incidente 05\*\*" 03-autenticacion.md | head -10

# --- 2026-09-11T04:05:18 · Read incident hooks in phases 1,2,3
grep -n -A3 "incidente \*\*03\*\*" 01-estructura-base-ngrx.md; grep -n -A3 "incidente 03" 01-estructura-base-ngrx.md | head -8; echo "-----"; grep -n -A3 "incidente \*\*05\*\*" 03-autenticacion.md | head -8; echo "-----"; grep -n -A3 "incidente \*\*04\*\*" 02-i18n.md | head -8

# --- 2026-09-11T04:05:38 · Add reservation subsections to phases 0-4
python3 - <<'PY'
blocks = {
'00-setup-hola-mundo.md': """
### Reservas para el cuaderno de incidentes

Esta fase toma los incidentes **01 y 02**, ambos ya reservados en el índice de
[`cuaderno-incidentes.md`](./cuaderno-incidentes.md) —que es el único archivo de
incidentes del curso—. Falta el enunciado completo con la plantilla de ocho puntos:

- **01** · Fase 0 · *"Guardé el paciente y la pantalla dice que no se pudo"* · Categoría: despliegue · Dificultad 🟢 — entra por el `status: 0` del §6: el servidor nunca habló, y la pantalla lo cuenta como si hubiera dicho que no.
- **02** · Fase 0 · *"En la máquina de al lado funciona y en la mía no"* · Categoría: integración · Dificultad 🟢 — la diferencia de entorno: versión de Node, puerto ocupado o el mock que no está levantado. Es el primer diff entre máquinas del curso.
""",
'01-estructura-base-ngrx.md': """
### Reservas para el cuaderno de incidentes

Esta fase toma el incidente **03**, ya reservado en el índice de
[`cuaderno-incidentes.md`](./cuaderno-incidentes.md). Falta el enunciado completo
con la plantilla de ocho puntos:

- **03** · Fase 1 · *"Cambié el paciente y la lista no se entera"* · Categoría: estado (store) · Dificultad 🟡 — la mutación dentro del reducer: el estado es correcto en DevTools y la pantalla muestra lo viejo porque el selector nunca emitió. El ejercicio que lo prepara es el que rompe la inmutabilidad a propósito.
""",
'02-i18n.md': """
### Reservas para el cuaderno de incidentes

Esta fase toma el incidente **04**, ya reservado en el índice de
[`cuaderno-incidentes.md`](./cuaderno-incidentes.md). Falta el enunciado completo
con la plantilla de ocho puntos:

- **04** · Fase 2 · *"Cambié a francés y la fecha sigue en español"* · Categoría: i18n · Dificultad 🟡 — es la ruta 2 de [`forense-fase-02.md`](./forense-fase-02.md) llegando como ticket: `LOCALE_ID` es estático y los pipes de `@angular/common` no escuchan al selector de idioma. El ejercicio 25 ya pide el post-mortem; el enunciado del cuaderno es su versión con pistas escalonadas.
""",
'03-autenticacion.md': """
### Reservas para el cuaderno de incidentes

Esta fase toma el incidente **05**, ya reservado en el índice de
[`cuaderno-incidentes.md`](./cuaderno-incidentes.md). Falta el enunciado completo
con la plantilla de ocho puntos:

- **05** · Fase 3 · *"Cerré sesión en una pestaña y en la otra sigo adentro"* · Categoría: UI · Dificultad 🟡 — quién consulta el storage y cada cuánto. Llega como bug reportado y no como feature pendiente, que es el enfoque correcto para algo que el pendiente del logout sincronizado deja abierto.
""",
'04-mock-api-caos.md': """
### Reservas para el cuaderno de incidentes

Esta fase toma los incidentes **06 y 08**, ambos ya reservados en el índice de
[`cuaderno-incidentes.md`](./cuaderno-incidentes.md). Falta el enunciado completo
con la plantilla de ocho puntos:

- **06** · Fase 4 · *"La pantalla de pacientes sale vacía y no dice nada"* · Categoría: integración · Dificultad 🟡 — el modo `malformed`: un `200` verde con la forma equivocada, y el store despachando **Success** con basura. Se prepara con un flag del inyector de caos, que es la forma más barata de las tres.
- **08** · Fase 4 · *"A veces no carga"* · Categoría: integración · Dificultad 🟡 — el intermitente con `fail=500@30`. La lección es que un "a veces" es un flag del caos que todavía no encendiste, no un misterio.
""",
}
for f,b in blocks.items():
    t=open(f,encoding='utf-8').read()
    assert 'Reserva para el cuaderno' not in t and 'Reservas para el cuaderno' not in t, f
    if not t.endswith('\n'): t+='\n'
    open(f,'w',encoding='utf-8').write(t.rstrip('\n')+'\n'+b)
    print('añadido en',f)
PY

# --- 2026-09-11T04:05:50 · Normalize subsection name and cross-check reservations
sed -i '' 's/^### Reserva para el cuaderno de incidentes$/### Reservas para el cuaderno de incidentes/' 11-trazabilidad-audit-log.md 12-testing-coverage.md
python3 - <<'PY'
import re,glob
idx={}
for l in open('cuaderno-incidentes.md',encoding='utf-8'):
    m=re.match(r'\|\s*(\d{2})\s*\|\s*(\d{1,2})\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(🟢|🟡|🟠|🔴)',l)
    if m: idx[m.group(1)]=(m.group(2),m.group(3).strip(),m.group(4).strip().lower(),m.group(5))
res={}
for f in sorted(glob.glob('[01][0-9]-*.md')):
    t=open(f,encoding='utf-8').read()
    m=re.search(r'### Reservas para el cuaderno de incidentes(.*)$',t,re.S)
    if not m: continue
    for mm in re.finditer(r'^- \*\*(\d{2})\*\* · Fase (\d{1,2}) · \*"([^"]+)"\* · Categoría: ([^·]+) · Dificultad (🟢|🟡|🟠|🔴)',m.group(1),re.M):
        i=mm.group(1); res[i]=(mm.group(2),mm.group(3),mm.group(4).strip().lower(),mm.group(5),f)
print('reservas formales:',len(res))
print('sin reserva formal:',sorted(set(idx)-set(res)))
for i in sorted(set(idx)&set(res)):
    fi,ti,ci,di=idx[i]; fr,tr,cr,dr,f=res[i]
    if fi!=fr: print(f'⚠️ {i} fase: índice {fi} vs fase {fr} ({f})')
    if ti.lower()!=tr.lower(): print(f'⚠️ {i} título:\n     índice: {ti}\n     fase  : {tr}')
    if ci!=cr: print(f'⚠️ {i} categoría: índice "{ci}" vs fase "{cr}"')
    if di!=dr: print(f'⚠️ {i} dificultad: índice {di} vs fase {dr}')
PY

# --- 2026-09-11T04:06:00 · Cross-check BE incident reservations
python3 - <<'PY'
import re,glob
idx={}
for l in open('cuaderno-incidentes-be.md',encoding='utf-8'):
    m=re.match(r'\|\s*(be-\d{2})\s*(?:⭐)?\s*\|\s*(be\d{2})\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(🟢|🟡|🟠|🔴)',l)
    if m: idx[m.group(1)]=(m.group(2),m.group(3).strip(),m.group(4).strip().lower(),m.group(5))
print('índice BE:',len(idx))
res={}
for f in sorted(glob.glob('be0*.md')):
    t=open(f,encoding='utf-8').read()
    m=re.search(r'### Reservas para el cuaderno de incidentes(.*)$',t,re.S)
    if not m: continue
    for mm in re.finditer(r'\*\*(be-\d{2})\*\*',m.group(1)): res.setdefault(mm.group(1),f[:4])
print('reservados en fases:',len(res))
print('en índice sin reserva:',sorted(set(idx)-set(res)))
print('reservados sin índice:',sorted(set(res)-set(idx)))
for i in sorted(set(idx)&set(res)):
    if idx[i][0]!=res[i]: print(f'⚠️ {i}: índice {idx[i][0]} vs fase {res[i]}')
PY

# --- 2026-09-11T04:06:14 · Validate pending-item destinations
python3 - <<'PY'
import re,glob
# pendientes 📌 abiertos que apuntan a un destino inexistente o que quedaron sin dueño
pat=re.compile(r'→\s*\*{0,2}(Fase\s+\d{1,2}|Apéndice\s+A\d{2}|A\d{2}|apéndice\s+\*{0,2}A\d{2}|bea-\d{2}|be\d{2})')
faltan=0
for f in sorted(glob.glob('*.md')):
    t=open(f,encoding='utf-8').read()
    m=re.search(r'## 📌 Pendientes sugeridos(.*)$',t,re.S)
    if not m: continue
    for d in set(pat.findall(m.group(1))):
        d2=d.replace('Apéndice ','').replace('apéndice ','').replace('**','').strip()
        if d2.lower().startswith('fase'):
            n=int(re.search(r'\d+',d2).group()); ok=bool(glob.glob('%02d-*.md'%n))
        elif d2.lower().startswith('bea'): ok=bool(glob.glob('bea-'+d2[-2:]+'-*.md'))
        elif d2.lower().startswith('be'): ok=bool(glob.glob('be'+d2[-2:]+'-*.md'))
        else: ok=bool(glob.glob(d2.lower()+'-*.md'))
        if not ok: faltan+=1; print('DESTINO INEXISTENTE',f,'->',d)
print('destinos de pendientes inválidos:',faltan)
PY
echo "=== pendientes abiertos vs cerrados ==="; grep -c "🪦" [01][0-9]-*.md a*.md be0*.md bea-*.md 2>/dev/null | awk -F: '$2>0{s+=$2} END{print "marcas 🪦 (pendientes cerrados):",s}'

# --- 2026-09-11T04:06:27 · Check domain naming consistency
echo "== auditEntries (nombre prohibido) =="; grep -rn "auditEntries" *.md | head
echo "== estados fuera del flujo canónico =="; grep -rhoE "'(pending|in_process|partial_results|complete|delivered|expired|scheduled|collected|received|processed|discarded|validated|draft)'" *.md | sort | uniq -c
echo "== identificadores en español en código =="
python3 - <<'PY'
import re,glob
sus=r'\b(paciente|orden|muestra|resultado|rango|entrega|validar|crear|obtener|listar|guardar|buscar|usuario|fecha|nombre|estado)[A-Za-z]*\s*(?:=|\(|:)'
for f in sorted(glob.glob('*.md')):
    t=open(f,encoding='utf-8').read()
    for blk in re.findall(r'```[a-zA-Z]*\n(.*?)```',t,re.S):
        for l in blk.split('\n'):
            s=l.strip()
            if s.startswith(('//','#','*')): continue
            m=re.search(sus,s)
            if m and not re.search(r'["\'].*'+m.group(0)[:6],s): print(f,'|',s[:100])
PY

# --- 2026-09-11T04:06:40 · Inspect the 'paciente' lookup field
grep -n "paciente" be02-medir-la-deriva-de-esquema.md | head -12; echo ====; grep -n -B6 '\$match: { paciente' bea-04-agregaciones-como-instrumento-de-medida.md | head -20

# --- 2026-09-11T04:06:44 · Read the lookup pipeline in be02
sed -n '273,300p' be02-medir-la-deriva-de-esquema.md

# --- 2026-09-11T04:06:55 · Inventory Spanish identifiers in code blocks
python3 - <<'PY'
import re,glob
sus=re.compile(r'\b(paciente|pacientes|orden|ordenes|muestra|muestras|resultado|resultados|rango|rangos|entrega|nombre|nombres|apellidos|fecha|fechas|estado|estadoPrevio|accion|accionAjena|activos|huerfan\w*|ordenesHuerfanas|generar\w+|nombreCompleto|fechaNacimiento|usuario|correo|correos)\b')
hits={}
for f in sorted(glob.glob('*.md')):
    t=open(f,encoding='utf-8').read().split('\n')
    infence=False
    for i,l in enumerate(t,1):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        s=l.strip()
        if s.startswith(('//','#','*','>')): continue
        # ignorar texto dentro de comentarios de bloque
        for m in sus.finditer(l):
            # sólo si parece identificador: precedido/seguido por sintaxis de código
            if re.search(r'(?:var|let|const|function|class)\s+'+m.group(0)+r'\b', l) or \
               re.search(r"\b"+m.group(0)+r"\b\s*(?:=|\(|:)", l) or \
               re.search(r"['\"]"+m.group(0)+r"['\"]", l):
                hits.setdefault(f,[]).append((i,s[:110]))
                break
for f,v in hits.items():
    print('==',f)
    for i,s in v: print(f'   {i}: {s}')
PY

# --- 2026-09-11T04:07:10 · Read test code in phase 12
sed -n '130,200p' 12-testing-coverage.md

# --- 2026-09-11T04:07:16 · Rename Spanish test identifiers to English
python3 - <<'PY'
import re
f='12-testing-coverage.md'
t=open(f,encoding='utf-8').read()
ren=[('accionAjena','unknownAction'),('estadoPrevio','previousState'),('acciones','actions'),
     ('accion','action'),('resultado','result'),('creado','created'),('lista','list'),
     ('activos','activeOnes'),('todos','all'),('estado','state')]
lines=t.split('\n'); infence=False; n=0
for i,l in enumerate(lines):
    if re.match(r'^\s*```',l): infence=not infence; continue
    if not infence: continue
    s=l.strip()
    if s.startswith('//'): continue
    new=l
    for a,b in ren:
        new=re.sub(rf'(?<![\w.\'"]){a}(?![\w\'"])',b,new)
    if new!=l: lines[i]=new; n+=1
open(f,'w',encoding='utf-8').write('\n'.join(lines))
print('líneas de código tocadas:',n)
PY
sed -n '135,160p' 12-testing-coverage.md

# --- 2026-09-11T04:07:22 · List test descriptions after rename
grep -n "it('\|describe('" 12-testing-coverage.md | head -40

# --- 2026-09-11T04:07:28 · Restore Spanish test descriptions
python3 - <<'PY'
f='12-testing-coverage.md'
t=open(f,encoding='utf-8').read()
fixes=[("it('deja el state intacto ante una action desconocida'","it('deja el estado intacto ante una acción desconocida'"),
("it('selectAllPatients devuelve all, incluido el inactivo'","it('selectAllPatients devuelve todos, incluido el inactivo'"),
("// misma referencia: no se toco nada","// misma referencia: no se tocó nada"),
("devolvio el server","devolvió el server")]
for a,b in fixes:
    print('ok' if a in t else 'NO ENCONTRADO', b[:60]); t=t.replace(a,b)
open(f,'w',encoding='utf-8').write(t)
PY
grep -n "it('\|describe('" 12-testing-coverage.md | sed -n '1,6p'; echo "=== resto del bloque de selectores ==="; sed -n '222,272p' 12-testing-coverage.md

# --- 2026-09-11T04:07:36 · Review remaining diffs in phase 12
sed -i '' 's/\bactiveOnes\b/activePatients/g' 12-testing-coverage.md
git -C .. diff -- angular-8-legacy-for-backend-devs/12-testing-coverage.md | grep -E "^[-+][^-+]" | grep -viE "^\+.*(previousState|unknownAction|var result|var action|var list|var created|var state|activePatients|allPatients|var all|actions\.forEach|var actions)" | head -30

# --- 2026-09-11T04:07:41 · Check for leftover references in phase 12
git -C .. diff -- angular-8-legacy-for-backend-devs/12-testing-coverage.md | grep -E "^\+" | grep -vE "previousState|unknownAction|result|action|list|created|state|activePatients|allPatients|Apéndices|acción|tocó|devolvió" | head -20; echo "=== narrativa que nombre identificadores viejos ==="; grep -n "estadoPrevio\|accionAjena\|resultado\b" 12-testing-coverage.md | head

# --- 2026-09-11T04:07:49 · Verify rename state in phase 12
grep -n "activeOnes\|activePatients" 12-testing-coverage.md | head; echo "---"; sed -n '209p' 12-testing-coverage.md

# --- 2026-09-11T04:07:53 · Finish renames in phase 12
perl -pi -e 's/\bactiveOnes\b/activePatients/g' 12-testing-coverage.md
python3 - <<'PY'
f='12-testing-coverage.md'
t=open(f,encoding='utf-8').read()
t=t.replace('`funcion(estadoPrevio, accion)`','`patientsReducer(previousState, action)`')
open(f,'w',encoding='utf-8').write(t)
PY
grep -n "activePatients\|patientsReducer(previousState" 12-testing-coverage.md | head -8

# --- 2026-09-11T04:08:03 · Locate all Spanish aggregation aliases
grep -rn "ordenesHuerfanas\|huerfanas\|as: 'paciente'\|{ paciente:" *.md; echo "=== be05 ==="; sed -n '270,295p' be05-la-cadena-de-custodia-y-la-transaccion.md

# --- 2026-09-11T04:08:17 · Rename Spanish identifiers in BE aggregations
python3 - <<'PY'
import re
edits={
'be02-medir-la-deriva-de-esquema.md':[("as: 'paciente'","as: 'patient'"),
  ("{ $match: { paciente: { $size: 0 } } },","{ $match: { patient: { $size: 0 } } },"),
  ("{ $count: 'ordenesHuerfanas' }","{ $count: 'orphanOrders' }"),
  ('{ "ordenesHuerfanas": 37 }','{ "orphanOrders": 37 }'),
  ('37 ordenes huerfanas','37 órdenes huérfanas')],
'bea-03-modelar-documentos-embeber-o-referenciar.md':[("as: 'paciente'             // <- el resultado es un ARREGLO","as: 'patient'              // <- el resultado es un ARREGLO"),
  ("`$match: { paciente: { $size: 0 } }`","`$match: { patient: { $size: 0 } }`")],
'bea-04-agregaciones-como-instrumento-de-medida.md':[("foreignField: 'legacyId', as: 'paciente' } },","foreignField: 'legacyId', as: 'patient' } },"),
  ("{ $match: { paciente: { $size: 0 } } }      // <- los rotos","{ $match: { patient: { $size: 0 } } }       // <- los rotos")],
'cuaderno-incidentes-be.md':[("foreignField: 'legacyId', as: 'paciente' } },","foreignField: 'legacyId', as: 'patient' } },"),
  ("{ $match: { paciente: { $size: 0 } } },","{ $match: { patient: { $size: 0 } } },"),
  ("{ $count: 'ordenesHuerfanas' }","{ $count: 'orphanOrders' }"),
  ("var huerfanas = db.orders.aggregate([...]).toArray()[0].ordenesHuerfanas;","var orphanCount = db.orders.aggregate([...]).toArray()[0].orphanOrders;"),
  ("if (huerfanas > 37) {","if (orphanCount > 37) {"),
  ("print('ALERTA: huerfanas subio de 37 a ' + huerfanas);","print('ALERTA: las huerfanas subieron de 37 a ' + orphanCount);")],
'be05-la-cadena-de-custodia-y-la-transaccion.md':[("{ $group: { _id: '$status', muestras: { $sum: 1 } } }","{ $group: { _id: '$status', samples: { $sum: 1 } } }"),
  ("foreignField: 'orderId', as: 'muestras' } },","foreignField: 'orderId', as: 'samples' } },"),
  ("{ $gt: [ { $size: '$muestras' }, 0 ] },","{ $gt: [ { $size: '$samples' }, 0 ] },"),
  ("{ $eq: [ { $size: { $filter: { input: '$muestras', as: 'm',","{ $eq: [ { $size: { $filter: { input: '$samples', as: 'm',"),
  ("{ $count: 'ordenesQueSeQuedaronAtras' }","{ $count: 'ordersLeftBehind' }")],
'bea-08-tiempo-zonas-y-fechas-en-mongo.md':[("java.util.Date fecha = new java.util.Date();","java.util.Date date = new java.util.Date();")],
}
for f,ps in edits.items():
    t=open(f,encoding='utf-8').read()
    for a,b in ps:
        if a in t: t=t.replace(a,b)
        else: print('NO ENCONTRADO en',f,'|',a[:60])
    open(f,'w',encoding='utf-8').write(t)
print('hecho')
PY
grep -rn "ordenesHuerfanas\|ordenesQueSeQuedaronAtras\|as: 'paciente'\|as: 'muestras'\|huerfanas =" *.md

# --- 2026-09-11T04:08:22 · Verify aggregation renames and check narrative refs
grep -rn "ordenesQueSeQuedaronAtras\|ordersLeftBehind\|orphanOrders\|\$muestras\|muestras:" *.md | head -20; echo "=== bea-08 contexto ==="; sed -n '158,170p' bea-08-tiempo-zonas-y-fechas-en-mongo.md

# --- 2026-09-11T04:08:28 · Inspect Java identifiers in BE docs
sed -n '148,165p' bea-08-tiempo-zonas-y-fechas-en-mongo.md; echo "=== más Java en bea-08 ==="; grep -nE "(LocalDate|ZonedDateTime|Instant|Date) [a-záéíóúñ]+ =" bea-08-tiempo-zonas-y-fechas-en-mongo.md bea-01*.md be0*.md | head -20

# --- 2026-09-11T04:08:39 · Fix Java identifiers and scan BE for more
python3 - <<'PY'
f='bea-08-tiempo-zonas-y-fechas-en-mongo.md'
t=open(f,encoding='utf-8').read()
t=t.replace("Instant ahora = Instant.now();                       // un instante, UTC, sin zona",
            "Instant now = Instant.now();                         // un instante, UTC, sin zona")
t=t.replace('LocalDate nacimiento = LocalDate.parse("1984-03-12");// una fecha de calendario',
            'LocalDate birthDate = LocalDate.parse("1984-03-12"); // una fecha de calendario')
t=t.replace('ZonedDateTime enBogota = ahora.atZone(ZoneId.of("America/Bogota"));  // para pintar',
            'ZonedDateTime inBogota = now.atZone(ZoneId.of("America/Bogota"));    // para pintar')
open(f,'w',encoding='utf-8').write(t)
PY
sed -n '155,163p' bea-08-tiempo-zonas-y-fechas-en-mongo.md; echo "=== otros identificadores es en java/js del track BE ==="
python3 - <<'PY'
import re,glob
pat=re.compile(r'\b(?:var|let|const|Instant|LocalDate|ZonedDateTime|String|int|long|Document|List<[^>]*>|Date)\s+([a-záéíóúñ][A-Za-záéíóúñ]*)\s*=')
es=re.compile(r'(?i)^(paciente|muestra|orden|resultado|rango|fecha|nombre|estado|ahora|hoy|ayer|inicio|fin|cuenta|total|lista|datos|salida|entrada|respuesta|consulta|error|usuario|clave|valor|texto|conteo|huerfan|nacimiento|bogota)')
for f in sorted(glob.glob('be*.md'))+sorted(glob.glob('bea-*.md'))+['cuaderno-incidentes-be.md']:
    t=open(f,encoding='utf-8').read().split('\n'); infence=False
    for i,l in enumerate(t,1):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        for m in pat.finditer(l):
            if es.match(m.group(1)): print(f'{f}:{i}: {l.strip()[:100]}')
PY

# --- 2026-09-11T04:08:43 · Read the generator code in bea-12
sed -n '48,60p' bea-12-datos-de-prueba-y-volumen.md; echo ...; sed -n '118,200p' bea-12-datos-de-prueba-y-volumen.md

# --- 2026-09-11T04:08:48 · Find references to bea-12 generator names
grep -rn "FORMAS\|construirPacientes\|generarPacientes\|contarSinCorreo\|indiceEmail\|EMAIL_VACIO\|nombreCompleto\|fechaNacimiento\|insertar(" *.md | grep -v "^bea-12.*:1[2-9][0-9]:" | head -20

# --- 2026-09-11T04:08:51 · Read FORMAS block and all usages
sed -n '100,118p' bea-12-datos-de-prueba-y-volumen.md; echo "=== resto del archivo con estos nombres ==="; grep -n "FORMAS\|forma\b\|pacientes\|vacio" bea-12-datos-de-prueba-y-volumen.md | sed -n '1,40p'

# --- 2026-09-11T04:09:01 · Read verify-dump.sh block
sed -n '270,325p' bea-12-datos-de-prueba-y-volumen.md

# --- 2026-09-11T04:09:12 · Rename generator identifiers in bea-12
python3 - <<'PY'
import re
f='bea-12-datos-de-prueba-y-volumen.md'
lines=open(f,encoding='utf-8').read().split('\n')
ren=[('generarPacientes','generatePatients'),('contarSinCorreo','countWithoutEmail'),
('insertar','insert'),('construirPacientes','buildPatients'),('FORMAS','SHAPES'),
('NOMBRES','FIRST_NAMES'),('APELLIDOS','LAST_NAMES'),('nombreCompleto','randomFullName'),
('fechaNacimiento','randomBirthDate'),('EMAIL_VACIO','EMAIL_EMPTY'),('indiceEmail','emailIndex'),
('conEmail','withEmail'),('vacios','emptyKinds'),('vacio','emptyKind'),('forma','shape'),
('pacientes','patients')]
infence=False; n=0
for i,l in enumerate(lines):
    if re.match(r'^\s*```',l): infence=not infence; continue
    if not infence: continue
    if l.strip().startswith('check "') or l.strip().startswith('echo'): continue
    new=l
    for a,b in ren:
        new=re.sub(rf'(?<![\w"\']){a}(?![\w"\'])',b,new)
    if new!=l: lines[i]=new; n+=1
t='\n'.join(lines)
t=t.replace('check "email vacio"','check "email vacío"').replace('check "ordenes"','check "órdenes"')
open(f,'w',encoding='utf-8').write(t)
print('líneas tocadas:',n)
PY
sed -n '52,58p' bea-12-datos-de-prueba-y-volumen.md; echo ...; sed -n '120,150p' bea-12-datos-de-prueba-y-volumen.md

# --- 2026-09-11T04:09:21 · Verify no Spanish identifiers remain in bea-12
grep -nE "'paciente'|patient' \+|buildPatients|generate-dump" bea-12-datos-de-prueba-y-volumen.md | head; echo "=== resto: comprobar que no quedan identificadores es ==="; python3 - <<'PY'
import re
f='bea-12-datos-de-prueba-y-volumen.md'
infence=False
for i,l in enumerate(open(f,encoding='utf-8'),1):
    if re.match(r'^\s*```',l): infence=not infence; continue
    if not infence: continue
    s=l.strip()
    if s.startswith(('//','#','echo','check')): continue
    for m in re.finditer(r'\b(?:var|function|let|const)\s+([A-Za-z_][\w]*)',l):
        w=m.group(1)
        if re.search(r'(?i)(pacient|orden|muestra|resultad|fecha|nombre|vacio|forma|huerfan|correo|conteo)',w):
            print(f'{i}: {s[:90]}')
PY

# --- 2026-09-11T04:09:28 · Read the BE incident Java/JSON block
sed -n '1488,1535p' cuaderno-incidentes-be.md

# --- 2026-09-11T04:09:34 · Fix Spanish identifiers in the BE notebook
python3 - <<'PY'
f='cuaderno-incidentes-be.md'
t=open(f,encoding='utf-8').read()
fixes=[('  evidence: { orden: { status: "in_process" },\n              muestras: ["8801:processed", "8802:processed"],',
        '  evidence: { order: { status: "in_process" },\n              samples: ["8801:processed", "8802:processed"],'),
('public void detectaOrdenesQueSeQuedaronAtras() {','public void detectsOrdersLeftBehind() {'),
('    sampleRepository.save(muestra(8801, 4021, "processed"));\n    sampleRepository.save(muestra(8802, 4021, "processed"));\n    orderRepository.save(orden(4021, "in_process"));',
 '    sampleRepository.save(sample(8801, 4021, "processed"));\n    sampleRepository.save(sample(8802, 4021, "processed"));\n    orderRepository.save(order(4021, "in_process"));')]
for a,b in fixes:
    print('ok' if a in t else 'NO ENCONTRADO', b.split('\n')[0][:60]); t=t.replace(a,b)
open(f,'w',encoding='utf-8').write(t)
PY
grep -n "muestra(\|orden(\| orden:\| muestras:" cuaderno-incidentes-be.md | head

# --- 2026-09-11T04:09:39 · Inspect remaining Spanish code strings
sed -n '44,62p' forense-fase-10.md; echo "=== a06 ==="; sed -n '444,452p' a06-ngrx.md; echo "=== a01:318-325 ==="; sed -n '316,326p' a01-material.md

# --- 2026-09-11T04:09:48 · Fix remaining Spanish debug labels and comment accents
python3 - <<'PY'
edits={
'forense-fase-10.md':[("console.count('KPI ordenes');","console.count('KPI orders');"),
 ("KPI ordenes: 5","KPI orders: 5"),("KPI ordenes: 6","KPI orders: 6"),("KPI ordenes: 7","KPI orders: 7")],
'a06-ngrx.md':[("console.log('antes:', state);","console.log('before:', state);"),
 ("console.log('accion:', action);","console.log('action:', action);"),
 ("console.log('despues:', next);","console.log('after:', next);")],
'a01-material.md':[("<!-- displayedColumns decide que columnas se pintan y en que orden. Puedes\n       definir mas columnas de las que muestras: las que no estan en la lista",
  "<!-- displayedColumns decide qué columnas se pintan y en qué orden. Puedes\n       definir más columnas de las que muestras: las que no están en la lista")],
}
for f,ps in edits.items():
    t=open(f,encoding='utf-8').read()
    for a,b in ps:
        print('ok' if a in t else 'NO', f, b.split('\n')[0][:50]); t=t.replace(a,b)
    open(f,'w',encoding='utf-8').write(t)
PY
grep -rn "KPI ordenes\|'accion:'\|no estan en la lista" *.md | head

# --- 2026-09-11T04:09:58 · Scan for Spanish strings in logging calls
python3 - <<'PY'
import re,glob
es=re.compile(r"(?i)\b(antes|despues|después|accion|acción|error de|guardado|cargando|pacientes?|ordenes?|órdenes?|muestras?|resultado|fallo|exito|éxito|aviso|alerta|clave|sin traducción|sin traduccion)\b")
for f in sorted(glob.glob('*.md')):
    lines=open(f,encoding='utf-8').read().split('\n'); infence=False
    for i,l in enumerate(lines,1):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        s=l.strip()
        if s.startswith(('//','#','*','<!--','|')): continue
        for m in re.finditer(r"(?:console\.(?:log|warn|error|count|info)|print|System\.out\.println|throw new \w+)\s*\(\s*['\"]([^'\"]{4,})['\"]",l):
            if es.search(m.group(1)): print(f'{f}:{i}: {s[:110]}')
PY

# --- 2026-09-11T04:10:07 · Inspect remaining Spanish identifiers in BE notebook
sed -n '655,665p' cuaderno-incidentes-be.md; echo ...; sed -n '1700,1715p' cuaderno-incidentes-be.md

# --- 2026-09-11T04:10:17 · Final Spanish identifier and accent fixes
python3 - <<'PY'
edits={
'cuaderno-incidentes-be.md':[
 ("var formas = db.patients.aggregate([","var shapeCount = db.patients.aggregate(["),
 ("{ $group: { _id: '$_id', claves: { $push: '$pairs.k' } } },\n  { $group: { _id: '$claves', n: { $sum: 1 } } }",
  "{ $group: { _id: '$_id', keys: { $push: '$pairs.k' } } },\n  { $group: { _id: '$keys', n: { $sum: 1 } } }"),
 ("if (formas !== 5) { print('ALERTA: ' + formas + ' formas, se esperaban 5'); quit(1); }",
  "if (shapeCount !== 5) { print('ALERTA: ' + shapeCount + ' formas, se esperaban 5'); quit(1); }"),
 ("var corregidosSinAsiento = db.samples.countDocuments({","var fixedWithoutEntry = db.samples.countDocuments({"),
 ("if (corregidosSinAsiento > 0) {\n  print('ALERTA: ' + corregidosSinAsiento + ' muestras modificadas sin asiento');",
  "if (fixedWithoutEntry > 0) {\n  print('ALERTA: ' + fixedWithoutEntry + ' muestras modificadas sin asiento');"),
 ("print('ALERTA: las huerfanas subieron de 37 a ' + orphanCount);","print('ALERTA: las huérfanas subieron de 37 a ' + orphanCount);"),
 ("var haceUnaSemana","var oneWeekAgo")],
'00-setup-hola-mundo.md':[("console.error('[PatientIntake] fallo el POST', error);","console.error('[PatientIntake] falló el POST', error);")],
'03-autenticacion.md':[("console.error('[LoginComponent] fallo el login', error);","console.error('[LoginComponent] falló el login', error);")],
'a05-rxjs.md':[("console.log('1. despues del timeout:', v);","console.log('1. después del timeout:', v);"),
               ("console.log('2. despues del map:', v);","console.log('2. después del map:', v);")],
}
for f,ps in edits.items():
    t=open(f,encoding='utf-8').read()
    for a,b in ps:
        if a in t: t=t.replace(a,b)
        else: print('NO ENCONTRADO',f,'|',a.split('\n')[0][:60])
    open(f,'w',encoding='utf-8').write(t)
print('ok')
PY
grep -n "haceUnaSemana\|oneWeekAgo\|corregidosSinAsiento\|var formas" cuaderno-incidentes-be.md | head

# --- 2026-09-11T04:10:22 · Find remaining Spanish date variables
grep -rn "haceUnaSemana\|haceUnMes\|haceUn" *.md | head

# --- 2026-09-11T04:10:31 · Final sweep for Spanish identifiers
python3 - <<'PY'
for f,a,b in [('cuaderno-incidentes-be.md','$gte: haceUnaSemana','$gte: oneWeekAgo'),
              ('bea-05-indices-y-explain-en-mongodb.md','$gte: haceUnMes','$gte: oneMonthAgo')]:
    t=open(f,encoding='utf-8').read(); print('ok' if a in t else 'NO',f); open(f,'w',encoding='utf-8').write(t.replace(a,b))
PY
echo "=== barrido final de identificadores en español ==="
python3 - <<'PY'
import re,glob
pat=re.compile(r'\b(?:var|let|const|function|class|public\s+\w+|private\s+\w+|Instant|LocalDate|ZonedDateTime|String|int|long)\s+([A-Za-z_][\w]*)')
es=re.compile(r'(?i)(pacient|orden(?!e?r)|muestra|resultad|rango|fecha|nombre|apellid|estado|accion|vacio|forma(?!t)|huerfan|correo|conteo|hace[A-Z]|clave|guion|prueba|salida|entrada|consulta|detectaO)')
n=0
for f in sorted(glob.glob('*.md')):
    lines=open(f,encoding='utf-8').read().split('\n'); infence=False
    for i,l in enumerate(lines,1):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        if l.strip().startswith(('//','#','*','<!--')): continue
        for m in pat.finditer(l):
            if es.search(m.group(1)): n+=1; print(f'{f}:{i}: {l.strip()[:95]}')
print('restantes:',n)
PY

# --- 2026-09-11T04:10:36 · Inspect last Spanish test method
sed -n '1155,1172p' cuaderno-incidentes-be.md

# --- 2026-09-11T04:10:46 · Final full integrity validation
python3 - <<'PY'
f='cuaderno-incidentes-be.md'
t=open(f,encoding='utf-8').read()
a="public void muestraProcesadaSiempreTieneAsientoOMarcaDeFallo() {"
b="public void processedSampleAlwaysHasEntryOrFailureMark() {"
print('ok' if a in t else 'NO'); open(f,'w',encoding='utf-8').write(t.replace(a,b))
PY
echo "=== validación final completa ==="
python3 - <<'PY'
import re,glob,os
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip()).replace('`','')
    h=re.sub(r'\*\*|\*','',h); out=[]
    for c in h.lower():
        if c=='️': out.append(c)
        elif c.isalnum() or c in '-_': out.append(c)
        elif c.isspace(): out.append('-')
    return ''.join(out)
heads={f:{slug(m.group(1)) for m in (re.match(r'^#{1,6}\s+(.*)$',l) for l in open(f,encoding='utf-8')) if m} for f in files}
bl=ba=nf=0; tot=0
for f in files:
    c=sum(1 for l in open(f,encoding='utf-8') if re.match(r'^\s*```(?!`)',l))
    c4=sum(1 for l in open(f,encoding='utf-8') if re.match(r'^\s*````',l))
    if c%2 or c4%2: nf+=1; print('FENCE',f)
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\[([^\]]*)\]\(([^)\s]+)\)',l):
            t=m.group(2); tot+=1
            if t.startswith(('http','mailto')): continue
            p,_,a=t.partition('#')
            tf=f if not p else os.path.normpath(os.path.join(os.path.dirname(f),p))
            if p and not os.path.exists(tf): bl+=1; print('LINK',f,i,t)
            if a and tf in heads and a not in heads[tf]: ba+=1; print('ANCLA',f,i,t)
print(f'{tot} enlaces | rotos {bl} | anclas rotas {ba} | fences desbalanceados {nf}')
PY

# --- 2026-09-11T04:10:57 · Final section-reference validation and git state
python3 - <<'PY'
import re,glob
# §refs
def secs(f):
    s=set()
    for l in open(f,encoding='utf-8'):
        m=re.match(r'^#{2,4}\s+(?:[^\w\s]*\s*)?(\d+(?:\.\d+)*)[.)]?\s',l)
        if m: s.add(m.group(1))
    return s
S={f:secs(f) for f in glob.glob('*.md')}
def res(tag):
    tag=tag.lower()
    g=(glob.glob('bea-'+tag[-2:]+'-*.md') if tag.startswith('bea') else
       glob.glob('be'+tag[-2:]+'-*.md') if tag.startswith('be') else glob.glob(tag+'-*.md'))
    return g[0] if g else None
pat=re.compile(r'\b(A\d{2}|bea-\d{2}|be\d{2}|Fase\s+\d{1,2})\**\s*§\s*(\d+(?:\.\d+)*)')
bad=0; tot=0
for f in sorted(glob.glob('*.md')):
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in pat.finditer(l.replace('`','')):
            tag,num=m.group(1),m.group(2); tot+=1
            t=res('%02d'%int(re.search(r'\d+',tag).group())) if tag.lower().startswith('fase') else res(tag)
            if not t: continue
            if num not in S[t] and num.split('.')[0] not in S[t]: bad+=1; print(f'{f}:{i} {tag} §{num}')
print(f'{tot} referencias §N revisadas | rotas: {bad}')
PY
echo "=== estado git ==="; git -C .. diff --numstat -- angular-8-legacy-for-backend-devs | wc -l; git -C .. status --short -- angular-8-legacy-for-backend-devs | grep -c "??"

# --- 2026-09-11T04:11:06 · Verify appended reservation blocks
for f in 00-setup-hola-mundo.md 02-i18n.md 04-mock-api-caos.md; do echo "=== $f"; tail -8 "$f"; done

# --- 2026-09-11T13:50:33 · Compare structure of both incident notebooks
grep -nE "^#{1,3} " cuaderno-incidentes.md; echo "=== total líneas ==="; wc -l cuaderno-incidentes.md cuaderno-incidentes-be.md

# --- 2026-09-11T13:50:39 · Read the incident template section
sed -n '163,240p' cuaderno-incidentes.md

# --- 2026-09-11T13:50:45 · Compare empty template with a written BE incident
sed -n '308,318p' cuaderno-incidentes.md; echo "=== BE: un incidente escrito, encabezado ==="; grep -n "^## Incidente be-01" -A 22 cuaderno-incidentes-be.md | head -34

# --- 2026-09-11T14:18:56 · Read incident notebook format spec part 1
sed -n '1,200p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-11T14:18:58 · Read incident format spec part 2
sed -n '200,420p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-11T14:19:01 · Read incident format spec part 3
sed -n '420,536p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-11T14:19:07 · Read forensic piece phase 0
cat forense-fase-00.md

# --- 2026-09-11T14:19:12 · Read forensic piece phase 1
cat forense-fase-01.md

# --- 2026-09-11T14:19:28 · Read phase 0 section 6
sed -n '576,634p' 00-setup-hola-mundo.md

# --- 2026-09-11T14:19:41 · Inspect the phase 0 mock setup
grep -n "npm run mock\|json-server\|mock/" 00-setup-hola-mundo.md | head -20; echo "=== scripts ==="; grep -n -A12 '"scripts"' 00-setup-hola-mundo.md | head -25

# --- 2026-09-11T14:20:29 · Inspect phase 1 reducer and selectors
grep -n "case \|selectedId\|createSelector\|selectAllPatients\|selectSelected" 01-estructura-base-ngrx.md | head -40

# --- 2026-09-11T14:20:32 · Read phase 1 selectors and the deliberate-break snippet
sed -n '580,625p' 01-estructura-base-ngrx.md; echo "=== 900-915 ==="; sed -n '900,915p' 01-estructura-base-ngrx.md

# --- 2026-09-11T14:20:57 · Create scratch dir for incidents
mkdir -p /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/ba539b99-1109-4792-8e3e-93ac9d2547da/scratchpad/inc && echo ok

# --- 2026-09-11T14:23:21 · Read forensic piece phase 3
sed -n '1,120p' forense-fase-03.md

# --- 2026-09-11T14:23:24 · Read rest of forensic piece phase 3
sed -n '120,220p' forense-fase-03.md

# --- 2026-09-11T14:23:33 · Inspect phase 3 auth service
grep -n "BehaviorSubject\|currentUser\|logout\|isAuthenticated\|TOKEN_STORAGE_KEY\|lab_clinico_token" 03-autenticacion.md | head -30

# --- 2026-09-11T14:23:36 · Read AuthService code
sed -n '230,280p' 03-autenticacion.md

# --- 2026-09-11T14:23:43 · Check mock auth validation in phase 3
grep -n "jsonwebtoken\|verify\|401" 03-autenticacion.md | head -20

# --- 2026-09-11T14:23:45 · Read the phase 3 mock server
sed -n '75,122p' 03-autenticacion.md

# --- 2026-09-11T14:23:50 · Find the JWT verification middleware
grep -n -B3 -A18 "jwt.verify" 03-autenticacion.md 04-mock-api-caos.md | head -50

# --- 2026-09-11T14:23:52 · Search for auth middleware in mock
grep -rn "jwt.verify\|authMiddleware\|requireAuth\|Bearer" 03-autenticacion.md 04-mock-api-caos.md | head -12

# --- 2026-09-11T14:26:01 · Read forensic piece phase 4
sed -n '1,110p' forense-fase-04.md

# --- 2026-09-11T14:26:04 · Read rest of forensic piece phase 4
sed -n '110,190p' forense-fase-04.md

# --- 2026-09-11T14:28:01 · Read forensic piece phase 5
sed -n '1,105p' forense-fase-05.md

# --- 2026-09-11T14:28:04 · Read rest of forensic piece phase 5
sed -n '105,200p' forense-fase-05.md

# --- 2026-09-11T14:28:13 · Check which selector the patient list uses
grep -n "selectActivePatients\|selectAllPatients\|selectFilteredPatients\|deactivate" 05-pacientes.md | head -20

# --- 2026-09-11T14:28:16 · Read the other consumer and the documented cause
sed -n '540,560p' 05-pacientes.md; echo "=== 1290-1302 ==="; sed -n '1290,1302p' 05-pacientes.md

# --- 2026-09-11T14:30:20 · Read forensic piece phase 7
sed -n '1,110p' forense-fase-07.md

# --- 2026-09-11T14:30:22 · Read rest of forensic piece phase 7
sed -n '110,175p' forense-fase-07.md

# --- 2026-09-11T14:30:29 · Check the route snapshot detail in phase 7
grep -n "snapshot\|paramMap" 07-muestras-custodia.md | head -12

# --- 2026-09-11T14:32:27 · Read forensic piece phase 8
sed -n '1,95p' forense-fase-08.md

# --- 2026-09-11T14:32:30 · Read rest of forensic piece phase 8
sed -n '95,175p' forense-fase-08.md

# --- 2026-09-11T14:32:36 · Read phase 8 incident reservations
sed -n '/### Reservas para el cuaderno/,$p' 08-resultados-rangos.md

# --- 2026-09-11T14:32:43 · Read phase 8 section 5.3
grep -n -B4 -A24 "5.3 " 08-resultados-rangos.md | sed -n '1,60p'

# --- 2026-09-11T14:33:07 · Check for critical-result logic in phase 8
grep -n "critic\|crítico\|alerta\|isCritical\|evaluateResult" 08-resultados-rangos.md | head -20

# --- 2026-09-11T14:33:21 · Read validation flow in phase 8
grep -n -A22 "5.6 " 08-resultados-rangos.md | sed -n '1,45p'; echo "=== validatedBy ==="; grep -n "validatedBy\|validatedAt\|rangeVersionApplied" 08-resultados-rangos.md | head -14

# --- 2026-09-11T14:36:34 · Read forensic piece phase 9
sed -n '1,40p' forense-fase-09.md; echo "=====PASOS"; grep -n -A12 "^### Paso" forense-fase-09.md | sed -n '1,70p'

# --- 2026-09-11T14:36:38 · Read the snapshot code detail
sed -n '73,84p' forense-fase-09.md; echo "=== fase 9 §5 reportSnapshot ==="; grep -n -B3 -A12 "reportSnapshot = {" 09-entrega-pdf.md | head -30

# --- 2026-09-11T14:37:35 · Read PDF font handling in A08
grep -n -B4 -A20 "registerLatinFont\|setFont" a08-pdf-cliente.md | head -50

# --- 2026-09-11T14:37:38 · Read font registration section in A08
grep -n -B6 -A20 "acentos\|Roboto\|addFileToVFS" a08-pdf-cliente.md | sed -n '1,60p'

# --- 2026-09-11T14:37:40 · Read A08 accents section
sed -n '/^## 4\./,/^## 5\./p' a08-pdf-cliente.md | head -60

# --- 2026-09-11T14:38:42 · Read forensic piece phase 10
sed -n '1,70p' forense-fase-10.md

# --- 2026-09-11T14:38:44 · Read rest of forensic piece phase 10
sed -n '70,140p' forense-fase-10.md

# --- 2026-09-11T14:39:41 · Read forensic piece phase 11
sed -n '1,60p' forense-fase-11.md; echo "=== deudas fase 11 ==="; grep -n "💸" 11-trazabilidad-audit-log.md | head -10

# --- 2026-09-11T14:39:43 · Read the rest of forensic piece phase 11
sed -n '60,130p' forense-fase-11.md

# --- 2026-09-11T14:43:54 · Read forensic piece phase 12
sed -n '1,80p' forense-fase-12.md

# --- 2026-09-11T14:43:56 · Read rest of forensic piece phase 12
sed -n '80,150p' forense-fase-12.md

# --- 2026-09-11T14:44:03 · Read phase 12 common errors
grep -n -A8 "random\|Math.random\|new Date()\|fakeAsync\|orden de los tests\|random: " 12-testing-coverage.md | grep -n "random\|orden\|Date\|karma" | head -20; echo "=== errores comunes fase 12 ==="; sed -n '/## ⚠️ 6\./,/### Pieza forense/p' 12-testing-coverage.md | head -50

# --- 2026-09-11T14:45:12 · Read forensic piece phase 13
sed -n '1,75p' forense-fase-13.md

# --- 2026-09-11T14:45:14 · Read rest of forensic piece phase 13
sed -n '75,140p' forense-fase-13.md

# --- 2026-09-11T14:46:14 · Read nginx try_files config in phase 13
grep -n -B3 -A14 "try_files" 13-build-despliegue.md | head -40

# --- 2026-09-11T14:49:43 · Check incident files and splice boundaries
ls /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/ba539b99-1109-4792-8e3e-93ac9d2547da/scratchpad/inc/ && sed -n '160,175p' cuaderno-incidentes.md; echo "=== FIN ==="; sed -n '305,320p' cuaderno-incidentes.md

# --- 2026-09-11T14:49:50 · Splice the 21 incidents into the notebook
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs
INC=/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/ba539b99-1109-4792-8e3e-93ac9d2547da/scratchpad/inc
python3 - <<PY
import glob,io
src=open('cuaderno-incidentes.md',encoding='utf-8').read()
start=src.index('## Incidente 01 — {{Título en palabras del usuario}}')
end=src.index('# 🪞 Retrospectiva del mes')
partes=[]
for n in ['%02d'%i for i in range(1,22)]:
    t=open('$INC/'+n+'.md',encoding='utf-8').read().rstrip('\n')
    partes.append(t)
nuevo='\n\n---\n\n'.join(partes)+'\n\n---\n\n'
out=src[:start]+nuevo+src[end:]
open('cuaderno-incidentes.md','w',encoding='utf-8').write(out)
print('líneas ahora:',out.count('\n')+1)
PY
grep -c "^## Incidente" cuaderno-incidentes.md; wc -l cuaderno-incidentes.md

# --- 2026-09-11T14:49:56 · Verify notebook structure after splice
grep -nE "^# |^## Incidente" cuaderno-incidentes.md | head -30; echo "..."; grep -nE "^# " cuaderno-incidentes.md

# --- 2026-09-11T14:50:02 · Read notebook tail sections
sed -n '4985,5030p' cuaderno-incidentes.md

# --- 2026-09-11T14:50:17 · Read index intro and states table
sed -n '108,132p' cuaderno-incidentes.md

# --- 2026-09-11T14:50:42 · Update index note and fill the pending list
python3 - <<'PY'
f='cuaderno-incidentes.md'
t=open(f,encoding='utf-8').read()
old="""Los veintiún IDs quedaron reservados por las fases que los producen; el título es
el que va a llegar en el ticket. Un ⬜ significa que el enunciado todavía no está
redactado en la sección de abajo — el ID **nunca** se reasigna, así que la fila
existe desde ya."""
new="""Los veintiún IDs quedaron reservados por las fases que los producen; el título es
el que va a llegar en el ticket, en palabras del usuario y no en lenguaje técnico.
**Los veintiún enunciados están escritos abajo**, cada uno con su preparación, sus
tres pistas plegadas y su solución de referencia. La columna de estado es tuya: un
⬜ quiere decir que todavía no lo tocaste, y el ID **nunca** se reasigna aunque un
incidente se retire."""
assert old in t
t=t.replace(old,new,1)

oldp = """Lo que apareció investigando y no cabía en el fix, con el ID que lo originó.

- **[06]** {{pendiente}} → sugerido para {{apéndice / fase / ejercicio 🔥}}."""
newp = """Lo que apareció investigando y no cabía en el fix, con el ID que lo originó. La
lista arranca con lo que salió al redactar los enunciados; **lo que encuentres tú
se agrega abajo**, con el mismo formato y en el commit del incidente que lo
produjo.

- **[02]** La dirección exacta con la que se abre la aplicación no está escrita en
  ningún sitio, y media tarde se perdió por eso → una línea en el README del
  proyecto.
- **[05]** El mock no valida el token en las rutas de datos, así que una sesión
  cerrada sigue pudiendo escribir. En el track base no se arregla —el servidor no
  es nuestro— → lo construye el 🔥 **track BE**, fase `be01`.
- **[07]** La **alerta activa** de resultado crítico —notificar, un canal, un turno
  de guardia, un acuse de recibo— no existe y no es de mantenimiento → decisión de
  producto, fuera del alcance del curso. Se escala con números, no se improvisa.
- **[07]** *¿A qué hora exactamente entra en vigor una norma clínica?* Mientras
  nadie lo conteste, cualquier implementación del borde de vigencia está
  adivinando → decisión de negocio, y va firmada por quien emite la norma.
- **[08]** El modo de caos activo sólo se ve en la terminal del mock; no hay nada
  en la interfaz que lo muestre → ejercicio 🔥 o pendiente ya anotado por la
  **Fase 4**.
- **[10]** `selectPatientsSaving` existe, está exportado y **ninguna plantilla lo
  consume**. Conectarlo cierra la ventana de confusión de las escrituras → deuda
  💸 declarada en la **Fase 5 §5.8**; es un cambio de comportamiento de pantalla,
  con su ticket.
- **[11] [12]** Los dos detectores —custodia rota y validados sin norma— son
  guiones cortos que convierten un hallazgo por casualidad en una revisión
  periódica → ejercicio 🔥 de las Fases 7 y 8, o un apéndice propio si el equipo
  decide correrlos en serio.
- **[15]** `setTextColor` no se revierte solo: a partir del primer valor crítico,
  la firma y la fecha del informe también salen en rojo. Mismo mecanismo que este
  incidente, otro estado del lápiz → buen candidato al **22**, que sigue sin dar
  de alta.
- **[16]** El patrón de suscribirse sin `ngOnDestroy` está en todo el curso, no
  sólo en el dashboard. `grep -rn "\\.subscribe(" src/` da el tamaño real →
  ticket de proyecto, no hotfix.
- **[17]** La pantalla de trazabilidad no dice en ninguna parte que el actor y la
  hora los declara el cliente y no los verifica nadie → una nota en la propia
  pantalla; es lo único que cabe hoy y le importa a una persona.
- **[18]** Una factoría de datos de prueba —`buildPatientsState(overrides)`— que
  quite la tentación de compartir estado entre specs → media tarde sobre la suite
  de la **Fase 12**.
- **[19] [20]** Los dos guiones de humo —`smoke-deploy.sh` y `smoke-routing.sh`—
  deberían correr solos después de cada despliegue → el pipeline de CI/CD está
  **fuera del alcance del curso**, así que hoy se corren a mano y se anota quién."""
assert oldp in t
t=t.replace(oldp,newp,1)
open(f,'w',encoding='utf-8').write(t)
print('ok')
PY
sed -n '/^# 📌 Pendientes/,/^## 🔥/p' cuaderno-incidentes.md | head -20

# --- 2026-09-11T14:50:54 · Validate every incident block structure
python3 - <<'PY'
import re
t=open('cuaderno-incidentes.md',encoding='utf-8').read()
# fences
n=sum(1 for l in t.split('\n') if re.match(r'^\s*```(?!`)',l))
n4=sum(1 for l in t.split('\n') if re.match(r'^\s*````',l))
print('fences ``` :',n,'pares ok' if n%2==0 else 'IMPAR')
print('fences ````:',n4,'pares ok' if n4%2==0 else 'IMPAR')
# details
print('<details>:',t.count('<details>'),' </details>:',t.count('</details>'))
# por incidente
bloques=re.split(r'^## Incidente ',t,flags=re.M)[1:]
print('incidentes:',len(bloques))
faltan=[]
for b in bloques:
    nn=b[:2]
    for k in ['### 🎫 El ticket','### 🎯 Qué se te pide','### 🔧 Preparación','💡 <b>Pista 1</b>','💡 <b>Pista 2</b>','💡 <b>Pista 3</b>','### 📝 Tu investigación','✅ <b>Solución de referencia</b>','**Causa raíz**','**Parche mínimo**','**La refactorización correcta**','**Prueba de regresión**','**Prevención**','**Por qué llegó a producción**','**Si tu causa fue distinta a esta**','**Reportado por:**','**Ambiente:**','**Fase:**','**Categoría:**','**Dificultad:**','**Tiempo sugerido:**']:
        if k not in b: faltan.append((nn,k))
    if b.count('<details>')!=4: faltan.append((nn,'debe tener 4 <details>, tiene %d'%b.count('<details>')))
for f in faltan: print('FALTA',f)
print('OK: todos los bloques completos' if not faltan else 'revisar')
PY

# --- 2026-09-11T14:51:07 · Cross-check index against written statements
python3 - <<'PY'
import re
t=open('cuaderno-incidentes.md',encoding='utf-8').read()
# índice
idx={}
for l in t.split('\n'):
    m=re.match(r'\|\s*(\d{2})\s*\|\s*(\d{1,2})\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*(🟢|🟡|🟠|🔴)\s*\|',l)
    if m: idx[m.group(1)]=(m.group(2),m.group(3).strip(),m.group(4).strip().lower(),m.group(5))
# enunciados
enu={}
for m in re.finditer(r'^## Incidente (\d{2}) — (.+)$\n\n> \*\*Fase:\*\* (\d{1,2}) · \*\*Categoría:\*\* ([^·]+) · \*\*Dificultad:\*\* (🟢|🟡|🟠|🔴)',t,re.M):
    enu[m.group(1)]=(m.group(3),m.group(2).strip(),m.group(4).strip().lower(),m.group(5))
print('índice:',len(idx),'enunciados:',len(enu))
bad=0
for i in sorted(idx):
    if i not in enu: print('SIN ENUNCIADO',i); bad+=1; continue
    a,b=idx[i],enu[i]
    for campo,x,y in zip(['fase','título','categoría','dif'],a,b):
        if x.lower()!=y.lower(): print(f'⚠️ {i} {campo}: índice "{x}" vs enunciado "{y}"'); bad+=1
print('discrepancias:',bad)
# escala
from collections import Counter
c=Counter(v[3] for v in idx.values())
print('escala:',dict(c),'  esperado 2🟢 8🟡 9🟠 2🔴')
# reparto semanal
sem={'1':[],'2':[],'3':[],'4':[]}
for i,v in idx.items():
    f=int(v[0])
    k='1' if f<=4 else '2' if f<=8 else '3' if f<=11 else '4'
    sem[k].append(i)
print({k:len(v) for k,v in sem.items()},' esperado 7/7/4/3')
print('22 dado de alta:', '22' in idx or '## Incidente 22' in t)
PY

# --- 2026-09-11T14:51:18 · Verify chaos flags and phase tag names
echo "=== flags de caos usados ==="; grep -o "CHAOS=[a-z0-9=@]*" cuaderno-incidentes.md | sort -u
echo; echo "=== tags de fase usados en preparación ==="; grep -oE "git checkout -b incidente/[0-9]{2} [a-z0-9-]+" cuaderno-incidentes.md
echo; echo "=== tags que existen de verdad ==="; for f in [01][0-9]-*.md; do [ "${f:0:2}" = "00" ] && [ "${f}" != "00-setup-hola-mundo.md" ] && continue; echo "fase-${f%.md}"; done

# --- 2026-09-11T14:51:31 · Full link validation after adding incidents
python3 - <<'PY'
import re,glob,os
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip()).replace('`','')
    h=re.sub(r'\*\*|\*','',h); out=[]
    for c in h.lower():
        if c=='️': out.append(c)
        elif c.isalnum() or c in '-_': out.append(c)
        elif c.isspace(): out.append('-')
    return ''.join(out)
heads={f:{slug(m.group(1)) for m in (re.match(r'^#{1,6}\s+(.*)$',l) for l in open(f,encoding='utf-8')) if m} for f in files}
bl=ba=0;tot=0
for f in files:
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\[([^\]]*)\]\(([^)\s]+)\)',l):
            t=m.group(2);tot+=1
            if t.startswith(('http','mailto')):continue
            p,_,a=t.partition('#')
            tf=f if not p else os.path.normpath(os.path.join(os.path.dirname(f),p))
            if p and not os.path.exists(tf): bl+=1;print('LINK',f,i,t)
            if a and tf in heads and a not in heads[tf]: ba+=1;print('ANCLA',f,i,t)
print(f'{tot} enlaces | rotos {bl} | anclas rotas {ba}')
PY

# --- 2026-09-11T14:51:43 · Check accents and identifier language in the new notebook
python3 - <<'PY'
import re,glob
# tildes y acentos en comentarios de código dentro del cuaderno nuevo
bad=r'\b(numero|version|codigo|tambien|aqui|asi|despues|sesion|razon|ultimo|ultima|deberia|ademas|dia|dias|mas|habria|seria|aca|arbol|maquina|estan|sintoma|proposito|pagina|linea|peticion|segun|unica|unico|validacion|configuracion|migracion|documentacion|aplicacion|traduccion|produccion|comprobacion|decision|situacion|coleccion|suscripcion|edicion|confirmacion|comparacion)\b'
src=open('cuaderno-incidentes.md',encoding='utf-8').read().split('\n')
infence=False;n=0
for i,l in enumerate(src,1):
    if re.match(r'^\s*```',l): infence=not infence; continue
    if not infence: continue
    m=re.search(r'(?://|#)\s*(.+)$',l)
    if m and re.findall(bad,m.group(1).lower()): n+=1;print(f'{i}: {l.strip()[:100]}')
print('comentarios sin tilde:',n)
# identificadores en español en el código del cuaderno
pat=re.compile(r'\b(?:var|let|const|function)\s+([a-záéíóúñ][A-Za-z0-9]*)')
es=re.compile(r'(?i)(pacient|orden|muestra|resultad|rango|fecha|nombre|estado|accion|vacio|forma|huerfan|correo|conteo|prueba|salida|entrada|consulta|primero|segundo|exito|acciones)')
infence=False;k=0
for i,l in enumerate(src,1):
    if re.match(r'^\s*```',l): infence=not infence; continue
    if not infence: continue
    if l.strip().startswith(('//','#')): continue
    for m in pat.finditer(l):
        if es.search(m.group(1)): k+=1;print('ID ES:',i,l.strip()[:90])
print('identificadores en español:',k)
PY

# --- 2026-09-11T14:51:53 · Find remaining Spanish identifiers in phase 12 and its piece
grep -n "var primero\|var segundo\|var exitos\|accionSalida\|var devuelto\|var enviado" forense-fase-12.md 12-testing-coverage.md | head -20

# --- 2026-09-11T14:51:59 · Rename Spanish identifiers in phase 12 test code
python3 - <<'PY'
import re
ren=[('accionSalida','outAction'),('var primero','var first'),('var segundo','var second'),
     ('var exitos','var successes'),('exitos.','successes.'),('exitos[','successes['),
     ('exitos,','successes,'),('var enviado','var sent'),('var devuelto','var returned'),
     ('enviado as any','sent as any'),('...enviado','...sent'),('devuelto)','returned)'),
     ('primero as any','first as any'),('segundo as any','second as any'),
     ('...primero','...first'),('...segundo','...second'),('exitos.length','successes.length')]
for f in ['forense-fase-12.md','12-testing-coverage.md']:
    t=open(f,encoding='utf-8').read()
    for a,b in ren: t=t.replace(a,b)
    t=t.replace('exitos','successes').replace('primero  =','first   =').replace('segundo  =','second  =')
    open(f,'w',encoding='utf-8').write(t)
    print('ok',f)
PY
grep -n "primero\|segundo\|exitos\|accionSalida\|enviado\|devuelto\|successes\|first\|second" forense-fase-12.md | head -20

# --- 2026-09-11T14:52:07 · Find comment damage from rename
grep -rn "DOS successes\|successes de\|los successes\|dos successes" forense-fase-12.md 12-testing-coverage.md; echo ---; grep -n "sent\b\|returned\b" 12-testing-coverage.md | head

# --- 2026-09-11T14:52:11 · Restore Spanish comment and align formatting
python3 - <<'PY'
f='forense-fase-12.md'
t=open(f,encoding='utf-8').read()
t=t.replace('// Dos altas tienen que producir DOS successes. Con switchMap llega uno solo',
            '// Dos altas tienen que producir DOS éxitos. Con switchMap llega uno solo')
t=t.replace('  var first  = ','  var first   = ')
open(f,'w',encoding='utf-8').write(t)
PY
sed -n '86,112p' forense-fase-12.md

# --- 2026-09-11T14:52:22 · Final accent sweep across the course
python3 - <<'PY'
import re,glob
# barrido final de tildes en comentarios, todo el curso
MAP={'probaria':'probaría','numero':'número','version':'versión','codigo':'código','tambien':'también',
'aqui':'aquí','asi':'así','despues':'después','razon':'razón','ultimo':'último','ultima':'última',
'deberia':'debería','ademas':'además','dia':'día','mas':'más','seria':'sería','aca':'acá',
'arbol':'árbol','maquina':'máquina','estan':'están','sintoma':'síntoma','linea':'línea'}
def fixcion(w):
    lw=w.lower()
    return w[:-2]+'ó'+w[-1] if len(lw)>6 and lw.endswith(('cion','sion','xion')) else w
tot=0
for f in sorted(glob.glob('*.md')):
    src=open(f,encoding='utf-8').read().split('\n'); infence=False; ch=0
    for i,l in enumerate(src):
        if re.match(r'^\s*```',l): infence=not infence; continue
        if not infence: continue
        if f=='forense-fase-08.md' and i+1==136: continue
        m=re.search(r'((?://|#)\s*)(.+)$',l)
        if not m: continue
        h=l[:m.start(2)]; b=m.group(2)
        n=re.sub(r'\b[A-Za-zÁÉÍÓÚáéíóúñÑ]+\b',lambda w:MAP.get(w.group(0),fixcion(w.group(0))),b)
        if n!=b: src[i]=h+n; ch+=1; print(f,i+1,n.strip()[:90])
    if ch: open(f,'w',encoding='utf-8').write('\n'.join(src)); tot+=ch
print('corregidas:',tot)
PY

# --- 2026-09-11T14:52:32 · Find phase texts claiming statements are missing
grep -rn "Falta el enunciado\|falta el enunciado\|enunciado todavía no\|Títulos propuestos para reservar\|Título propuesto para reservar\|Títulos propuestos para el índice" [01][0-9]-*.md | head -20

# --- 2026-09-11T14:52:41 · Update phase reservation texts
python3 - <<'PY'
import re,glob
cambios=0
for f in sorted(glob.glob('[01][0-9]-*.md')):
    t=open(f,encoding='utf-8').read(); o=t
    t=t.replace("""Falta el enunciado completo con la plantilla de ocho puntos:""",
                """El enunciado completo —ticket, preparación, pistas plegadas y solución de referencia— **ya está escrito allí**:""")
    t=t.replace("""Falta el enunciado completo
con la plantilla de ocho puntos:""",
                """El enunciado completo —ticket, preparación,
pistas plegadas y solución de referencia— **ya está escrito allí**:""")
    t=t.replace("""Falta el enunciado completo con la plantilla de ocho
puntos:""","""El enunciado completo —ticket, preparación, pistas plegadas y
solución de referencia— **ya está escrito allí**:""")
    t=t.replace("Títulos propuestos para reservar en el índice del cuaderno:",
                "Los dos están en el índice del cuaderno y con su enunciado escrito:")
    t=t.replace("Títulos propuestos para el índice:",
                "Los dos están en el índice del cuaderno y con su enunciado escrito:")
    t=t.replace("Título propuesto para reservar en el índice del cuaderno, sin desarrollarlo entero acá:",
                "Está en el índice del cuaderno y con su enunciado escrito allí, que es donde vive:")
    t=t.replace("Título propuesto para reservar en el índice del cuaderno, para no desarrollarlo entero acá:",
                "Está en el índice del cuaderno y con su enunciado escrito allí, que es donde vive:")
    if t!=o: open(f,'w',encoding='utf-8').write(t); cambios+=1; print('ok',f)
print(cambios,'archivos')
PY
grep -rn "Falta el enunciado\|Títulos propuestos\|Título propuesto" [01][0-9]-*.md be0*.md | head

# --- 2026-09-11T14:52:49 · Finish reservation text updates and find stale claims
python3 - <<'PY'
f='10-dashboard.md'
t=open(f,encoding='utf-8').read()
t=t.replace("Esta fase toma el incidente **16**. Título propuesto para el índice del cuaderno:",
            "Esta fase toma el incidente **16**. Está en el índice del cuaderno y con su enunciado escrito allí, que es donde vive:")
open(f,'w',encoding='utf-8').write(t)
PY
grep -rn "Falta el enunciado\|Títulos propuestos para\|Título propuesto para el índice" [01][0-9]-*.md | head; echo "--- sin resultados = ok"
echo "=== ¿alguna fase dice que el cuaderno está sin escribir? ==="; grep -rn "sin redactar\|no está redactado\|todavía no resuelve\|enunciados del cuaderno" [01][0-9]-*.md README.md forense-*.md prompts/*.md | head

# --- 2026-09-11T14:52:53 · Read README completion claim
sed -n '214,226p' README.md

# --- 2026-09-11T14:53:00 · Update README completion statement
python3 - <<'PY'
f='README.md'
t=open(f,encoding='utf-8').read()
old="""Con eso, **las catorce fases y los trece apéndices están completos**, y también el
track forense: [`forense-master.md`](forense-master.md) y las quince piezas, de
[`forense-fase-00.md`](forense-fase-00.md) a
[`forense-fase-14.md`](forense-fase-14.md). Falta una sola cosa: los veintiún
enunciados del cuaderno de incidentes, cuyos IDs ya están reservados por las fases
que los producen. Es el único enlace del curso que todavía no resuelve."""
new="""Con eso, **el curso está completo**: las catorce fases, los trece apéndices, el
track forense —[`forense-master.md`](forense-master.md) y las quince piezas, de
[`forense-fase-00.md`](forense-fase-00.md) a
[`forense-fase-14.md`](forense-fase-14.md)—, los **veintiún incidentes** de
[`cuaderno-incidentes.md`](cuaderno-incidentes.md) con su enunciado, sus pistas
escalonadas y su solución de referencia, y el 🔥 track BE entero con su propio
cuaderno. No queda ningún enlace del material sin resolver."""
assert old in t
open(f,'w',encoding='utf-8').write(t.replace(old,new,1))
PY
sed -n '/## 📓 El cuaderno de incidentes/,/^## 🔥/p' README.md

# --- 2026-09-11T14:53:14 · Expand README incident notebook section
python3 - <<'PY'
f='README.md'
t=open(f,encoding='utf-8').read()
old="""[`cuaderno-incidentes.md`](cuaderno-incidentes.md) es el otro eje del curso: veintiún tickets vagos, con
pistas escalonadas y solución colapsada, que se trabajan **sin instructor**. Los
veintiún IDs ya están reservados por las fases que los producen —cada encabezado
de fase los declara— y viven en el índice de ese archivo, que dice a partir de
qué fase se puede resolver cada uno; el ID nunca se reasigna. Cada incidente cierra con un
post-mortem de ocho puntos y sin culpabilización."""
if old not in t:
    old=old.replace("[`cuaderno-incidentes.md`](cuaderno-incidentes.md)","`cuaderno-incidentes.md`")
new="""[`cuaderno-incidentes.md`](cuaderno-incidentes.md) es el otro eje del curso:
**veintiún tickets vagos, escritos**, con su preparación, tres pistas escalonadas
y la solución colapsada, que se trabajan **sin instructor**. Los veintiún IDs los
reservan las fases que los producen —cada una los declara en su cierre— y el
índice del archivo dice a partir de qué fase se puede resolver cada uno; el ID
nunca se reasigna. Cada incidente cierra con un post-mortem de ocho puntos y sin
culpabilización.

La escala quedó en **2 🟢 · 8 🟡 · 9 🟠 · 2 🔴**, repartidos 7 / 7 / 4 / 3 por
semana: el curso carga incidentes en las fases que producen material y se
aligera al final, cuando ya estás desplegando. Y **no todos terminan en fix**:
cuatro de ellos terminan en una medición, una declaración o un recuento, que es
lo que de verdad se hace cuando lo que está mal es una decisión de hace siete
años.

Cómo llega el sistema roto a tu máquina lo dice cada incidente en su «🔧
Preparación», y hay exactamente tres formas —un flag del inyector de caos, un
`db.incidente-NN.json`, o una rama `incidente/NN`—, siempre la más barata que
sirva."""
assert old in t, 'no encontrado'
open(f,'w',encoding='utf-8').write(t.replace(old,new,1))
print('ok')
PY
sed -n '/## 📓 El cuaderno de incidentes/,/^## 🔥/p' README.md

# --- 2026-09-11T14:53:25 · Count incidents that end without a fix
grep -n "no termina en fix\|No termina en fix\|no termina en fix de código\|no es un parche\|no un parche" cuaderno-incidentes.md | head; echo "=== parche mínimo 'ninguno' ==="; grep -n -A1 "^\*\*Parche mínimo\*\*" cuaderno-incidentes.md | grep -i "ninguno\|no hay\|\*\*No hay\*\*" | head

# --- 2026-09-11T14:53:30 · Identify incidents without a code fix
python3 - <<'PY'
import re
t=open('cuaderno-incidentes.md',encoding='utf-8').read()
bloques=re.split(r'^## Incidente (\d{2})',t,flags=re.M)
sinfix=[]
for i in range(1,len(bloques),2):
    nn=bloques[i]; b=bloques[i+1]
    m=re.search(r'\*\*Parche mínimo\*\*\n\n(.{0,120})',b,re.S)
    head=m.group(1).replace('\n',' ') if m else ''
    if re.search(r'(?i)^\s*(\*\*)?(ninguno|no hay|\*\*no hay)',head) or 'no termina en fix' in b.lower():
        sinfix.append(nn)
print('sin fix de código:',sinfix,len(sinfix))
PY

# --- 2026-09-11T14:53:41 · Correct the no-fix count in README
python3 - <<'PY'
f='README.md'
t=open(f,encoding='utf-8').read()
t=t.replace("""Y **no todos terminan en fix**:
cuatro de ellos terminan en una medición, una declaración o un recuento, que es
lo que de verdad se hace cuando lo que está mal es una decisión de hace siete
años.""",
"""Y **no todos terminan en fix**:
seis de ellos —el 03, el 04, el 07, el 11, el 12 y el 17— terminan en un
diagnóstico, un recuento o una declaración por escrito, que es lo que de verdad
se hace cuando lo que está mal es una decisión de hace siete años o un dato que
llegó roto de otra puerta.""")
open(f,'w',encoding='utf-8').write(t)
PY
grep -n "seis de ellos" README.md

# --- 2026-09-11T14:53:58 · Close format checklist and revalidate corpus
python3 - <<'PY'
f='prompts/formato-cuaderno-incidentes.md'
t=open(f,encoding='utf-8').read()
old="""## 11. Checklist antes de dar por cerrado el cuaderno"""
new="""## 11. Checklist antes de dar por cerrado el cuaderno

> ✅ **Escrito el 11/09/2026.** Los veintiún enunciados están en
> `cuaderno-incidentes.md`, con el reparto 7 / 7 / 4 / 3 y la escala
> 2 🟢 · 8 🟡 · 9 🟠 · 2 🔴 de §3, verificados contra el índice fila por fila. Las
> tres formas de preparación de §5 se usaron diez veces la rama, tres veces el
> `db.incidente-NN.json` y tres el flag de caos —sin inventar ni un modo que la
> Fase 4 no construya—, y cinco incidentes no necesitan ninguna porque el
> comportamiento vive en el código tal como se escribió. El 22 sigue **sin dar de
> alta**, con dos candidatos anotados: el `setTextColor` que no se revierte (desde
> el 15) y el `undefined` del slice lazy que la Fase 6 dejó apuntado."""
assert old in t
open(f,'w',encoding='utf-8').write(t.replace(old,new,1))
print('ok')
PY
python3 - <<'PY'
import re,glob,os
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip()).replace('`','')
    h=re.sub(r'\*\*|\*','',h); out=[]
    for c in h.lower():
        if c=='️': out.append(c)
        elif c.isalnum() or c in '-_': out.append(c)
        elif c.isspace(): out.append('-')
    return ''.join(out)
heads={f:{slug(m.group(1)) for m in (re.match(r'^#{1,6}\s+(.*)$',l) for l in open(f,encoding='utf-8')) if m} for f in files}
bl=ba=nf=0;tot=0
for f in files:
    c=sum(1 for l in open(f,encoding='utf-8') if re.match(r'^\s*```(?!`)',l))
    c4=sum(1 for l in open(f,encoding='utf-8') if re.match(r'^\s*````',l))
    if c%2 or c4%2: nf+=1;print('FENCE',f)
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\[([^\]]*)\]\(([^)\s]+)\)',l):
            t=m.group(2);tot+=1
            if t.startswith(('http','mailto')):continue
            p,_,a=t.partition('#')
            tf=f if not p else os.path.normpath(os.path.join(os.path.dirname(f),p))
            if p and not os.path.exists(tf): bl+=1;print('LINK',f,i,t)
            if a and tf in heads and a not in heads[tf]: ba+=1;print('ANCLA',f,i,t)
print(f'{tot} enlaces | rotos {bl} | anclas {ba} | fences {nf}')
PY

# --- 2026-09-11T14:54:09 · Final section-reference validation and size
python3 - <<'PY'
import re,glob
# refs §N siguen resolviendo
def secs(f):
    s=set()
    for l in open(f,encoding='utf-8'):
        m=re.match(r'^#{2,4}\s+(?:[^\w\s]*\s*)?(\d+(?:\.\d+)*)[.)]?\s',l)
        if m: s.add(m.group(1))
    return s
S={f:secs(f) for f in glob.glob('*.md')}
def res(tag):
    tag=tag.lower()
    g=(glob.glob('bea-'+tag[-2:]+'-*.md') if tag.startswith('bea') else
       glob.glob('be'+tag[-2:]+'-*.md') if tag.startswith('be') else glob.glob(tag+'-*.md'))
    return g[0] if g else None
pat=re.compile(r'\b(A\d{2}|bea-\d{2}|be\d{2}|Fase\s+\d{1,2})\**\s*§\s*(\d+(?:\.\d+)*)')
bad=tot=0
for f in sorted(glob.glob('*.md')):
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in pat.finditer(l.replace('`','')):
            tag,num=m.group(1),m.group(2); tot+=1
            t=res('%02d'%int(re.search(r'\d+',tag).group())) if tag.lower().startswith('fase') else res(tag)
            if not t: continue
            if num not in S[t] and num.split('.')[0] not in S[t]:
                bad+=1; print(f'{f}:{i} {tag} §{num} -> {t}')
print(f'{tot} referencias §N | rotas {bad}')
PY
echo "=== tamaño final ==="; wc -l cuaderno-incidentes.md cuaderno-incidentes-be.md; echo; git -C .. status --short -- angular-8-legacy-for-backend-devs | wc -l

# --- 2026-09-11T14:54:18 · Spot-check rendered output
sed -n '170,200p' cuaderno-incidentes.md; echo "......"; sed -n '350,362p' cuaderno-incidentes.md

# --- 2026-09-11T14:54:38 · Add memory index pointer
cd /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory && python3 - <<'PY'
f='MEMORY.md'
t=open(f,encoding='utf-8').read()
linea="- [Curso Angular 8 completo](angular8-curso-completo.md) — LabCore cerrado el 11/09/2026: los 21 enunciados del cuaderno de incidentes ya están escritos; el ID 22 sigue sin dar de alta.\n"
if 'angular8-curso-completo' not in t:
    t=t.rstrip('\n')+'\n'+linea
open(f,'w',encoding='utf-8').write(t)
PY
cat MEMORY.md

# --- 2026-09-11T15:03:50 · Check whether preparation artifacts are specified anywhere
cd angular-8-legacy-for-backend-devs; echo "=== ¿alguien explica cómo se CREAN los db.incidente-NN.json? ==="; grep -rn "db.incidente" *.md | grep -v "^cuaderno-incidentes.md" | head
echo; echo "=== ¿y las ramas incidente/NN? ==="; grep -rn "incidente/NN\|incidente/[0-9]" 00-convencion-de-git-y-tags.md | head -6

# --- 2026-09-11T15:14:09 · Extract phase 0 code for recipes
echo "=== F0: patient-intake (URL) ==="; grep -n -B3 -A3 "localhost:3000/patients" 00-setup-hola-mundo.md | head -20
echo; echo "=== F0: script del mock ==="; grep -n "json-server --watch\|\"mock\"" 00-setup-hola-mundo.md 04-mock-api-caos.md | head -6

# --- 2026-09-11T15:14:19 · Review incident 02 preparation
sed -n '/^## Incidente 02/,/^<details>/p' cuaderno-incidentes.md | sed -n '18,40p'

# --- 2026-09-11T15:14:30 · Fix incident 02 to use the phase-0 mock command
python3 - <<'PY'
f='cuaderno-incidentes.md'
t=open(f,encoding='utf-8').read()
old="""```bash
git checkout -b incidente/02 fase-00-setup-hola-mundo
npm run mock
```

La rama trae un middleware nuevo en el mock —alguien del equipo lo agregó "para
que esto se parezca más a producción"— y una línea distinta en el script. Después
de levantar el mock, **abre la aplicación en `http://127.0.0.1:4200`**, que es como
la tenía en favoritos quien reportó. Tu compañera la abre en `http://localhost:4200`."""
new="""```bash
git checkout -b incidente/02 fase-00-setup-hola-mundo
npx json-server --watch db.json --port 3000 --middlewares mock/cors-origin.js
```

La rama trae un archivo nuevo, `mock/cors-origin.js` —alguien del equipo lo agregó
"para que esto se parezca más a producción"— y la línea de arranque que lo carga.
Con el mock levantado así, **abre la aplicación en `http://127.0.0.1:4200`**, que es
como la tenía en favoritos quien reportó. Tu compañera la abre en
`http://localhost:4200`."""
assert old in t
open(f,'w',encoding='utf-8').write(t.replace(old,new,1))
print('ok')
PY

# --- 2026-09-11T15:14:37 · Extract phase 1 and 5 code
echo "=== F1 reducer loadPatientsSuccess ==="; sed -n '536,556p' 01-estructura-base-ngrx.md
echo; echo "=== F5 patient-list subscribe ==="; sed -n '789,800p' 05-pacientes.md
echo; echo "=== F5 createPatient\$ ==="; grep -n -B4 -A10 "createPatient\$ = createEffect" 05-pacientes.md | head -24

# --- 2026-09-11T15:14:42 · Find createPatient effect code
grep -n -B6 -A14 "createPatient\$" 05-pacientes.md | sed -n '1,40p'

# --- 2026-09-11T15:14:46 · Locate createPatient effect in phase 5
grep -n "createPatient" 05-pacientes.md | head -12; echo ---; sed -n '690,715p' 05-pacientes.md

# --- 2026-09-11T15:14:49 · Read createPatient effect body
sed -n '659,680p' 05-pacientes.md

# --- 2026-09-11T15:14:52 · Extract phase 7 and 9 code
echo "=== F7 sample-timeline paramMap ==="; sed -n '590,605p' 07-muestras-custodia.md
echo; echo "=== F9 report.service generate ==="; grep -n -A16 "generate(snapshot" 09-entrega-pdf.md | head -24

# --- 2026-09-11T15:14:57 · Check whether font registration exists in phase 9
grep -n "registerLatinFont\|addFont\|addFileToVFS\|setFont(" 09-entrega-pdf.md a08-pdf-cliente.md | head -14

# --- 2026-09-11T15:15:01 · Read the real generate() ordering
sed -n '344,362p' 09-entrega-pdf.md

# --- 2026-09-11T15:15:14 · Align incident 15 code with the real phase 9 service
python3 - <<'PY'
f='cuaderno-incidentes.md'
t=open(f,encoding='utf-8').read()
old="""```typescript
// Lo que trae la rama
var doc = new (jsPDF as any)('p', 'mm', 'a4');
doc.setFontSize(16);
doc.text(this.translate.instant('reports.title'), 20, 20);   // ← dibuja con Helvetica
registerLatinFont(doc);                                       // ← llega tarde
doc.setFont('Roboto', 'normal');
doc.text(snapshot.validatedBy, 20, 40);                       // ← ya sale bien
```"""
new="""```typescript
// Lo que trae la rama
var doc = new (jsPDF as any)();
var t = this.translate;

doc.setFontSize(16);
doc.text(t.instant('report.title'), 20, 20);   // ← dibuja con Helvetica
registerLatinFont(doc);                        // ← llega tarde
doc.text(t.instant('report.validatedBy') + ': ' + snapshot.validatedBy, 20, 40);
```"""
assert old in t; t=t.replace(old,new,1)

old2="""```typescript
// El registro de la fuente va ANTES del primer text(). Siempre.
var doc = new (jsPDF as any)('p', 'mm', 'a4');
registerLatinFont(doc);
doc.setFont('Roboto', 'normal');
doc.setFontSize(16);
doc.text(this.translate.instant('reports.title'), 20, 20);
```"""
new2="""```typescript
// El registro de la fuente va ANTES del primer text(). Siempre.
var doc = new (jsPDF as any)();
registerLatinFont(doc);

var t = this.translate;
doc.setFontSize(16);
doc.text(t.instant('report.title'), 20, 20);
```"""
assert old2 in t; t=t.replace(old2,new2,1)
open(f,'w',encoding='utf-8').write(t)
print('ok')
PY

# --- 2026-09-11T15:15:19 · Read the real nginx.conf from phase 13
echo "=== F13 nginx.conf ==="; grep -n -B4 -A14 "try_files" 13-build-despliegue.md | sed -n '1,40p'

# --- 2026-09-11T15:15:22 · Find the nginx.conf block
grep -n -A22 "nginx.conf$\|# nginx.conf" 13-build-despliegue.md | sed -n '1,40p'

# --- 2026-09-11T15:15:31 · Check for docker-compose in phase 13
grep -n "docker compose\|docker-compose" 13-build-despliegue.md | head -8; echo "--- si vacío: la fase usa docker run"

# --- 2026-09-11T15:15:47 · Align incidents 19 and 20 with the real phase 13
python3 - <<'PY'
f='cuaderno-incidentes.md'
t=open(f,encoding='utf-8').read()

# --- incidente 19: la Fase 13 usa docker run, no compose ---
old="""```bash
git checkout -b incidente/19 fase-13-build-despliegue
docker compose -f docker-compose.incidente-19.yml up -d
# y abre la aplicación en http://localhost:8080
```"""
new="""```bash
git checkout -b incidente/19 fase-13-build-despliegue
docker build -t lab-frontend:inc19 .
# El comando con el que "se desplegó a PROD" ese día. Cópialo tal cual,
# sin leerlo con lupa: leerlo con lupa es el final de la investigación.
docker run -d --name lab-frontend-prod -p 8080:80 \\
  -e API_URL=http://uat.interno:3000 \\
  -e ENVIRONMENT_NAME=uat \\
  -e APP_TIME_ZONE=America/Bogota \\
  -e FEATURE_DELIVERY_PDF=true \\
  lab-frontend:inc19
```"""
assert old in t; t=t.replace(old,new,1)
t=t.replace("""Rama de git más el arranque equivocado del contenedor. La rama trae el
`docker-compose.yml` con el que se desplegó.""",
"""Ninguna rama hace falta: el código es correcto. Lo que hay que reproducir es
**el arranque**, y para eso basta con levantar la imagen con las variables
equivocadas — que es exactamente lo que pasó.""")
t=t.replace("""```bash
git checkout -b incidente/19 fase-13-build-despliegue
docker build -t lab-frontend:inc19 .""","""```bash
docker build -t lab-frontend:inc19 .""")

# --- incidente 20: el i18n =404 ya está en el nginx.conf de la fase ---
old2="""Lo que sí cabe discutir —y conviene dejarlo escrito antes de que alguien lo
proponga como mejora— es **hasta dónde llega ese comodín**:"""
new2="""Lo que sí conviene mirar, porque es la otra mitad del asunto y **el proyecto ya
lo trae resuelto**, es hasta dónde llega ese comodín:"""
assert old2 in t; t=t.replace(old2,new2,1)
old3="""Ese matiz es la mitad del valor del incidente: un `try_files` demasiado generoso
convierte cualquier error de ruta en una pantalla en blanco con un mensaje
incomprensible, que es peor que un 404."""
new3="""Ese bloque está en el `nginx.conf` de la Fase 13 desde que lo escribiste, y ahora
sabes por qué: un `try_files` demasiado generoso convierte cualquier error de ruta
en una pantalla en blanco con un mensaje incomprensible, que es peor que un 404.
La rama de este incidente quita el `location /`, no ése."""
assert old3 in t; t=t.replace(old3,new3,1)
open(f,'w',encoding='utf-8').write(t)
print('ok')
PY
sed -n '/^## Incidente 19/,/^<details>/p' cuaderno-incidentes.md | sed -n '20,45p'

# --- 2026-09-11T15:15:57 · Fix incident 19 remediation command
python3 - <<'PY'
f='cuaderno-incidentes.md'
t=open(f,encoding='utf-8').read()
old="""```bash
# Relevantar el contenedor con las variables correctas. Nada que compilar,
# nada que desplegar: es la misma imagen.
docker compose -f docker-compose.prod.yml up -d --force-recreate lab-frontend-prod
docker logs lab-frontend-prod | head -1
# [entrypoint] config generada para ambiente: prod -> http://prod.interno:3000
```"""
new="""```bash
# Relevantar el contenedor con las variables correctas. Nada que compilar,
# nada que desplegar: es exactamente la misma imagen.
docker rm -f lab-frontend-prod
docker run -d --name lab-frontend-prod -p 8080:80 \\
  -e API_URL=http://prod.interno:3000 \\
  -e ENVIRONMENT_NAME=prod \\
  -e APP_TIME_ZONE=America/Bogota \\
  -e FEATURE_DELIVERY_PDF=true \\
  lab-frontend:inc19

docker logs lab-frontend-prod | head -1
# [entrypoint] config generada para ambiente: prod -> http://prod.interno:3000
```"""
assert old in t
open(f,'w',encoding='utf-8').write(t.replace(old,new,1))
print('ok')
PY
grep -n "docker compose\|docker-compose" cuaderno-incidentes.md | head

# --- 2026-09-11T15:16:11 · Check karma config in phase 12
grep -n -B3 -A12 "karma.conf\|jasmine: {" 12-testing-coverage.md | head -30

# --- 2026-09-11T15:16:14 · Read karma.conf block
sed -n '80,120p' 12-testing-coverage.md

# --- 2026-09-11T15:16:30 · Correct the Jasmine seed mechanics for CLI 8
python3 - <<'PY'
f='cuaderno-incidentes.md'
t=open(f,encoding='utf-8').read()
old="""```bash
# La misma semilla = el mismo orden = el mismo fallo, siempre.
npx ng test --watch=false -- --seed=41287
```"""
new="""En el CLI 8 la semilla no se pasa por línea de comandos: se fija en la
configuración de Karma, que es donde vive el cliente de Jasmine.

```javascript
// karma.conf.js — temporal, sólo mientras investigas.
client: {
  clearContext: false,
  // Misma semilla = mismo orden = mismo fallo, siempre.
  jasmine: { random: true, seed: '41287' }
}
```

```bash
npx ng test --watch=false
```"""
assert old in t; t=t.replace(old,new,1)

old2="""```bash
# La suite tiene que pasar con CUALQUIER orden. Tres semillas distintas,
# y si una falla, hay estado compartido en alguna parte.
for seed in 1 41287 99999; do
  npx ng test --watch=false -- --seed=$seed || echo "FALLA con semilla $seed"
done
```"""
new2="""```bash
# La suite tiene que pasar con CUALQUIER orden. Tres semillas distintas,
# y si una falla, hay estado compartido en alguna parte. Se corre con tres
# copias de la config, que es lo que el CLI 8 permite sin inventar nada.
for seed in 1 41287 99999; do
  sed "s/SEED_PLACEHOLDER/$seed/" karma.seed.conf.js > karma.run.conf.js
  npx ng test --watch=false --karma-config=karma.run.conf.js \\
    || echo "FALLA con semilla $seed"
done
```"""
assert old2 in t; t=t.replace(old2,new2,1)
open(f,'w',encoding='utf-8').write(t)
print('ok')
PY
grep -n "seed" cuaderno-incidentes.md | head

# --- 2026-09-11T15:19:01 · Wire the new document into the authoring docs
cd angular-8-legacy-for-backend-devs && python3 - <<'PY'
f='prompts/formato-cuaderno-incidentes.md'
t=open(f,encoding='utf-8').read()
old="""**3. Una rama de git**, y solo cuando haya que romper código."""
new="""> 🧰 **El contenido de cada preparación está en
> [`preparaciones-de-incidentes.md`](preparaciones-de-incidentes.md)**, escrito el
> 11/09/2026: qué línea rompe cada una de las nueve ramas, qué registros lleva cada
> uno de los tres `db.incidente-NN.json`, y cómo comprobar que la preparación
> reproduce el síntoma. Es material de autoría y **no se enlaza desde el cuaderno**:
> es la respuesta.

**3. Una rama de git**, y solo cuando haya que romper código."""
assert old in t
open(f,'w',encoding='utf-8').write(t.replace(old,new,1))
PY
python3 - <<'PY'
f='prompts/guia-de-estilo-y-convenciones.md'
t=open(f,encoding='utf-8').read()
old="""`prompts/formato-cuaderno-incidentes.md`**, que es el anexo de
esta guía para todo lo que toque el cuaderno, y cubre también el
`cuaderno-incidentes-be.md` del track BE."""
new="""`prompts/formato-cuaderno-incidentes.md`**, que es el anexo de
esta guía para todo lo que toque el cuaderno, y cubre también el
`cuaderno-incidentes-be.md` del track BE. El **estado roto** de cada incidente
—qué línea rompe cada rama y qué lleva cada `db.incidente-NN.json`— vive aparte, en
`prompts/preparaciones-de-incidentes.md`, porque es la respuesta y no puede quedar
a un clic del enunciado."""
assert old in t
open(f,'w',encoding='utf-8').write(t.replace(old,new,1))
PY
grep -n "preparaciones-de-incidentes" prompts/*.md

# --- 2026-09-11T15:19:14 · Apply the pending patch to the format spec
pwd; python3 - <<'PY'
f='prompts/formato-cuaderno-incidentes.md'
t=open(f,encoding='utf-8').read()
old="""**3. Una rama de git**, y solo cuando haya que romper código."""
new="""> 🧰 **El contenido de cada preparación está en
> [`preparaciones-de-incidentes.md`](preparaciones-de-incidentes.md)**, escrito el
> 11/09/2026: qué línea rompe cada una de las nueve ramas, qué registros lleva cada
> uno de los tres `db.incidente-NN.json`, y cómo comprobar que la preparación
> reproduce el síntoma. Es material de autoría y **no se enlaza desde el cuaderno**:
> es la respuesta.

**3. Una rama de git**, y solo cuando haya que romper código."""
if old in t and 'preparaciones-de-incidentes' not in t:
    open(f,'w',encoding='utf-8').write(t.replace(old,new,1)); print('ok formato')
else: print('ya estaba o no encontrado')
PY
grep -rn "preparaciones-de-incidentes" prompts/*.md | head

# --- 2026-09-11T15:19:25 · Final validation including the new document
python3 - <<'PY'
import re,glob,os
files=sorted(glob.glob('*.md'))+sorted(glob.glob('prompts/*.md'))
def slug(h):
    h=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',h.strip()).replace('`','')
    h=re.sub(r'\*\*|\*','',h); out=[]
    for c in h.lower():
        if c=='️': out.append(c)
        elif c.isalnum() or c in '-_': out.append(c)
        elif c.isspace(): out.append('-')
    return ''.join(out)
heads={f:{slug(m.group(1)) for m in (re.match(r'^#{1,6}\s+(.*)$',l) for l in open(f,encoding='utf-8')) if m} for f in files}
bl=ba=nf=0;tot=0
for f in files:
    c=sum(1 for l in open(f,encoding='utf-8') if re.match(r'^\s*```(?!`)',l))
    c4=sum(1 for l in open(f,encoding='utf-8') if re.match(r'^\s*````',l))
    if c%2 or c4%2: nf+=1;print('FENCE',f,c,c4)
    for i,l in enumerate(open(f,encoding='utf-8'),1):
        for m in re.finditer(r'\[([^\]]*)\]\(([^)\s]+)\)',l):
            t=m.group(2);tot+=1
            if t.startswith(('http','mailto')):continue
            p,_,a=t.partition('#')
            tf=f if not p else os.path.normpath(os.path.join(os.path.dirname(f),p))
            if p and not os.path.exists(tf): bl+=1;print('LINK',f,i,t)
            if a and tf in heads and a not in heads[tf]: ba+=1;print('ANCLA',f,i,t)
print(f'{tot} enlaces | rotos {bl} | anclas {ba} | fences {nf}')
PY
echo "=== ¿el cuaderno enlaza el doc de preparaciones? (NO debe) ==="; grep -c "preparaciones-de-incidentes" cuaderno-incidentes.md

# --- 2026-09-11T15:19:40 · Fix the count in the preparations doc
python3 - <<'PY'
f='prompts/preparaciones-de-incidentes.md'
t=open(f,encoding='utf-8').read()
t=t.replace("""ese mecanismo. Lo que no estaba escrito en ninguna parte era **el contenido**: qué
línea rompe cada rama y qué registros lleva cada archivo de datos. Sin eso, catorce
de los veintiún incidentes se quedaban en la línea del `git checkout` o del `cp`.""",
"""ese mecanismo. Lo que no estaba escrito en ninguna parte era **el contenido**: qué
línea rompe cada rama y qué registros lleva cada archivo de datos. Sin eso, trece
de los veintiún incidentes se quedaban en la línea del `git checkout` o del `cp`.""")
t=t.replace("""Prepara las nueve ramas y los tres
  archivos de datos de una sentada""","""Prepara las nueve ramas y los tres
  archivos de datos de una sentada""")
open(f,'w',encoding='utf-8').write(t)
print('ok')
PY
grep -n "trece\|catorce\|Nueve ramas" prompts/preparaciones-de-incidentes.md

# --- 2026-09-11T15:19:51 · Update memory and show git status read-only
python3 - <<'PY'
f='/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/angular8-curso-completo.md'
t=open(f,encoding='utf-8').read()
old="""En las mismas sesiones se corrigieron"""
new="""Las preparaciones del sistema roto —lo único que faltaba para poder *ejecutar* el
cuaderno y no sólo leerlo— están en **`prompts/preparaciones-de-incidentes.md`**
(11/09/2026): nueve ramas `incidente/NN` con su diff exacto, los tres
`db.incidente-NN.json` con los registros que cambian, y el `docker run` del 19. Es
material de autoría y **no se enlaza desde el cuaderno**, porque es la respuesta.

En las mismas sesiones se corrigieron"""
assert old in t
open(f,'w',encoding='utf-8').write(t.replace(old,new,1))
print('ok')
PY
cd /Users/oskar/Developer/Learning/courses-ia-generated && git status --short -- angular-8-legacy-for-backend-devs | tail -4; echo "--- total archivos tocados:"; git status --short -- angular-8-legacy-for-backend-devs | wc -l

# --- 2026-09-11T15:19:59 · Correct preparation counts in memory
python3 - <<'PY'
f='/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/angular8-curso-completo.md'
t=open(f,encoding='utf-8').read()
t=t.replace("""escala **2 🟢 · 8 🟡 · 9 🟠 · 2 🔴** y semanas **7 / 7 / 4 / 3**. Preparación: 10
ramas `incidente/NN`, 3 `db.incidente-NN.json` (07, 11, 17), 3 flags de caos
(06, 08, 13) y 5 sin preparación.""",
"""escala **2 🟢 · 8 🟡 · 9 🟠 · 2 🔴** y semanas **7 / 7 / 4 / 3**. Preparación: 9
ramas `incidente/NN`, 3 `db.incidente-NN.json` (07, 11, 17), 1 comando de arranque
(el 19), 3 flags de caos (06, 08, 13) y 5 sin preparación.""")
open(f,'w',encoding='utf-8').write(t)
print('ok')
PY

