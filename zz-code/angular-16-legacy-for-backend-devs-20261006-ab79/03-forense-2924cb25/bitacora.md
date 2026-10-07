# Bitácora de ejecución · sesión 2924cb25-75c3-4115-bbc1-54e92ba194f2

Comandos que ejecutaron código, con el inicio de su salida.

### ⏱️ 2026-09-11T16:20:39Z · Tabulate preparation commands per incident

~~~~~~bash
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
awk '/^## Incidente /{inc=substr($0,4,60)} /^### 🔧 Preparación/{p=1;next} p&&/^<details/{p=0} p&&/git switch|git checkout|CHAOS|cp db|db\.incidente|npm run|docker|npm start/{print inc" ||| "$0}' cuaderno-incidentes.md
~~~~~~

~~~~~~text
Incidente 01 — "Cloné el repo, hice npm install y `ng ser ||| git switch -c incidente/01 fase-00
Incidente 01 — "Cloné el repo, hice npm install y `ng ser ||| npm start
Incidente 02 — "Agregué la pantalla de activos, la ruta f ||| git switch -c incidente/02 fase-01
Incidente 02 — "Agregué la pantalla de activos, la ruta f ||| npm start
Incidente 03 — "Entro con mi usuario y me saca al login si ||| CHAOS=expired npm run mock
Incidente 03 — "Entro con mi usuario y me saca al login si ||| npm start
Incidente 04 — "La pantalla de plantillas a veces carga y  ||| CHAOS=timeout CHAOS_RATE=1 npm run mock
Incidente 05 — "Entro a Plantillas y dice que no hay ningu ||| git switch -c incidente/05 fase-04
Incidente 05 — "Entro a Plantillas y dice que no hay ningu ||| npm run mock     # sin ningún flag: el backend está perfectamente bien
Incidente 05 — "Entro a Plantillas y dice que no hay ningu ||| npm start
Incidente 06 — "El botón de Nuevo cliente se ve gris y pl ||| git switch -c incidente/06 fase-05
Incidente 06 — "El botón de Nuevo cliente se ve gris y pl ||| npm start
Incidente 07 — "Metí el listado de clientes en el panel y ||| git switch -c incidente/07 fase-05
Incidente 07 — "Metí el listado de clientes en el panel y ||| npm start
Incidente 08 — "La inspección de agosto ahora tiene un í ||| git switch -c incidente/08 fase-07
Incidente 08 — "La inspección de agosto ahora tiene un í ||| npm run mock
Incidente 08 — "La inspección de agosto ahora tiene un í ||| npm start
Incidente 09
~~~~~~

### ⏱️ 2026-09-11T16:30:43Z · Run the forensic verification script

~~~~~~bash
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs && python3 prompts/verificar-forenses.py 2>&1 | tail -20
~~~~~~

~~~~~~text
15 piezas revisadas · 0 fallos
~~~~~~

### ⏱️ 2026-09-11T16:31:18Z · Re-verify forensic pieces and check links

~~~~~~bash
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 prompts/verificar-forenses.py 2>&1 | tail -3
python3 - <<'PY'
import re,os
lines=open('cuaderno-incidentes.md').read().split('\n')
cur=None; pairs=[]
for l in lines:
    m=re.match(r'^## Incidente (\d+)',l)
    if m: cur=int(m.group(1))
    if l.startswith('> **Tiempo sugerido:**') and cur:
        pairs.append((cur, re.findall(r'forense-fase-(\d+)\.md\)', l)))
bad=[]
for num,fs in pairs:
    for f in fs:
        p=f'forense-fase-{f}.md'
        foot=[x for x in open(p) if x.startswith('**Incidentes del cuaderno')]
        if not foot or not re.search(r'\b0*%d\b'%num, foot[0]): bad.append((num,p))
print('asimetrías:',bad or 'ninguna')
PY
echo "=== enlaces rotos en los archivos tocados ==="
for f in cuaderno-incidentes.md README.md prompts/formato-cuaderno-incidentes.md prompts/preparaciones-de-incidentes.md 00-convencion-de-git-y-tags.md; do
  d=$(dirname "$f")
  grep -o '](\.\./\?[A-Za-z0-9._/-]*\.md)\|](\([A-Za-z0-9._-]*\.md\))' "$f" | sed 's/](//;s/)$//' | sort -u | while read l; do
    [ -e "$d/$l" ] || echo "ROTO: $f -> $l"; done
done; echo fin
~~~~~~

~~~~~~text
15 piezas revisadas · 0 fallos
asimetrías: ninguna
=== enlaces rotos en los archivos tocados ===
ROTO: prompts/formato-cuaderno-incidentes.md -> forense-fase-NN.md
fin
~~~~~~

### ⏱️ 2026-09-11T16:40:31Z · Validate all internal markdown links

~~~~~~bash
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 - <<'PY'
import re,glob,os
bad=0; total=0
for f in glob.glob('*.md')+glob.glob('prompts/*.md'):
    d=os.path.dirname(f) or '.'
    for m in re.finditer(r'\]\(([^)#\s]+\.md)(#[^)]*)?\)', open(f).read()):
        t=m.group(1); total+=1
        if '{{' in t: continue
        if not os.path.exists(os.path.join(d,t)):
            print('ROTO:',f,'->',t); bad+=1
print(total,'enlaces .md ·',bad,'rotos')
PY
python3 prompts/verificar-forenses.py | tail -2
~~~~~~

~~~~~~text
ROTO: prompts/formato-cuaderno-incidentes.md -> forense-fase-NN.md
267 enlaces .md · 1 rotos

15 piezas revisadas · 0 fallos
~~~~~~

### ⏱️ 2026-09-11T16:44:22Z · Final verification sweep

~~~~~~bash
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 - <<'PY'
import re,glob
esp=re.compile(r'\b(descargar|guardar|cargar|enviar|calcular|obtener|validar|construir|buscar|eliminar|actualizar|crear|abrir|cerrar|mostrar|listar|filtrar|ordenar|resolver|emitir|revocar|aprobar|rechazar)\s*\(')
n=0
for f in sorted(glob.glob('*.md')+glob.glob('prompts/*.md')):
    if '_deprecado' in f: continue
    infence=False
    for i,l in enumerate(open(f).read().split('\n'),1):
        if l.strip().startswith('```'): infence=not infence; continue
        if infence and esp.search(l): print(f'{f}:{i} {l.strip()[:80]}'); n+=1
print('identificadores en español:',n)
PY
python3 - <<'PY'
import re,glob,os
bad=total=0
for f in glob.glob('*.md')+glob.glob('prompts/*.md'):
    d=os.path.dirname(f) or '.'
    for m in re.finditer(r'\]\(([^)#\s]+\.md)(#[^)]*)?\)', open(f).read()):
        total+=1
        if not os.path.exists(os.path.join(d,m.group(1))): print('ROTO:',f,'->',m.group(1)); bad+=1
print(total,'enlaces ·',bad,'rotos')
PY
python3 prompts/verificar-forenses.py | tail -1
~~~~~~

~~~~~~text
identificadores en español: 0
266 enlaces · 0 rotos
15 piezas revisadas · 0 fallos
~~~~~~

### ⏱️ 2026-09-11T17:06:46Z · Verify the cross-reference rule holds and re-run checks

~~~~~~bash
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== ¿LabCore fuera de README y a10? ==="
grep -rn 'LabCore' *.md prompts/*.md | grep -v '^README.md\|^a10-' | grep -v '_deprecado'
echo "— fin —"
echo; echo "=== verificaciones ==="
python3 prompts/verificar-forenses.py | tail -1
python3 - <<'PY'
import re,glob,os
bad=total=0
for f in glob.glob('*.md')+glob.glob('prompts/*.md'):
    d=os.path.dirname(f) or '.'
    for m in re.finditer(r'\]\(([^)#\s]+\.md)(#[^)]*)?\)', open(f).read()):
        total+=1
        if not os.path.exists(os.path.join(d,m.group(1))): print('ROTO:',f,'->',m.group(1)); bad+=1
print(total,'enlaces ·',bad,'rotos')
PY
~~~~~~

~~~~~~text
=== ¿LabCore fuera de README y a10? ===
a13-i18n.md:141:> ⚖️ **Los dos cursos son honestos y toman decisiones opuestas, y ninguna está mal.** LabCore es un laboratorio con personal que habla tres idiomas y una interfaz que tiene que cambiar en caliente. CertCore opera en un solo país, con una norma en un solo idioma, y sus certificados se emiten en español porque así los exige quien los recibe. **La decisión de i18n no la toma la arquitectura: la toma el dominio.**
prompts/alcance-del-proyecto.md:60:### 2.1 Cómo se relaciona con el Track A (Angular 8 — LabCore)
prompts/alcance-del-proyecto.md:74:| | Track A — LabCore | Track B — CertCore |
prompts/plantillas-de-capitulo.md:360:  y trae los reflejos de LabCore puestos. Se escribe hablándole a esa persona, y
prompts/plantillas-de-capitulo.md:361:  es el único documento del curso donde nombrar LabCore es correcto.
prompts/guia-de-estilo-y-convenciones.md:674:LabCore"* deja fuera a quien llegó directo. Este curso **diverge a propósito**, y
prompts/prompts-extendidos-apendices.md:740:- Usado por: lectores que vienen del Track A (LabCore); de consulta en todas las fases
prompts/prompts-extendidos-apendices.md:746:- **Secciones esperadas:** las cuatro puertas del camino largo (Ivy, `strict`, standalone, `inject()`), qué desapareció y qué sólo cambió de nombre, RxJS 6 → 7 (imports, operadores retirados, `toPromise`), formularios sin tipar → tipados, guards e interceptors de clase → funcionales, NgRx de 2019 → estado en servicios, y u
~~~~~~

### ⏱️ 2026-09-11T17:07:16Z · Final verification after this round

~~~~~~bash
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 prompts/verificar-forenses.py | tail -1
python3 - <<'PY'
import re,glob,os
bad=total=0
for f in glob.glob('*.md')+glob.glob('prompts/*.md'):
    d=os.path.dirname(f) or '.'
    for m in re.finditer(r'\]\(([^)#\s]+\.md)(#[^)]*)?\)', open(f).read()):
        total+=1
        if not os.path.exists(os.path.join(d,m.group(1))): print('ROTO:',f,'->',m.group(1)); bad+=1
print(total,'enlaces ·',bad,'rotos')
PY
cd .. && git diff --stat -- angular-16-legacy-for-backend-devs | tail -2
~~~~~~

~~~~~~text
15 piezas revisadas · 0 fallos
267 enlaces · 0 rotos
 .../prompts/propuesta-fases-y-alcance.md           |   2 +-
 52 files changed, 624 insertions(+), 333 deletions(-)
~~~~~~

### ⏱️ 2026-09-11T17:08:10Z · Final verification of the BE prompt files

~~~~~~bash
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 prompts/verificar-forenses.py | tail -1
python3 - <<'PY'
import re,glob,os
bad=total=0
for f in glob.glob('*.md')+glob.glob('prompts/*.md'):
    d=os.path.dirname(f) or '.'
    for m in re.finditer(r'\]\(([^)#\s]+\.md)(#[^)]*)?\)', open(f).read()):
        total+=1
        if not os.path.exists(os.path.join(d,m.group(1))): print('ROTO:',f,'->',m.group(1)); bad+=1
print(total,'enlaces ·',bad,'rotos')
PY
python3 - <<'PY'
import re
fase=open('prompts/prompts-backend-fase.md').read(); ap=open('prompts/prompts-backend-apendice.md').read()
f2a={};cur=None
for l in fase.split('\n'):
    m=re.match(r'^## # Fase (be\d\d)',l)
    if m: cur=m.group(1)
    if cur and l.startswith('- Apéndices de apoyo:'): f2a[cur]=set(re.findall(r'bea-\d\d',l)); coll=True
    elif cur and f2a.get(cur) is not None and l.startswith('  ') and 'bea-' in l: f2a[cur]|=set(re.findall(r'bea-\d\d',l))
a2f={};cur=None
for l in ap.split('\n'):
    m=re.match(r'^## # Apéndice (bea-\d\d)',l)
    if m: cur=m.group(1)
    if cur and l.startswith('- Usado por:'): a2f[cur]=set(re.findall(r'be\d\d',l))
bad=[(a,f) for a,fs in a2f.items() for f in fs if a not in f2a.get(f,set())]
bad+=[(f,a) for f,as_ in f2a.items() for a in as_ if f not in a2f.get(a,set())]
print('asimetrías fase↔apéndice:', bad or 'ninguna')
print('incidentes reservados:', sorted(set(re.findall(r'be-\d\d', fase))))
PY
~~~~~~

~~~~~~text
15 piezas revisadas · 0 fallos
267 enlaces · 0 rotos
asimetrías fase↔apéndice: ninguna
incidentes reservados: ['be-01', 'be-02', 'be-03', 'be-04', 'be-05', 'be-06', 'be-07', 'be-08', 'be-09', 'be-10', 'be-11', 'be-12']
~~~~~~

