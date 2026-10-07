# Comandos Bash de la sesión 2924cb25-75c3-4115-bbc1-54e92ba194f2, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-11T16:14:53 · List prompts dir and count lines of course files
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs && ls -la prompts && wc -l *.md prompts/*.md | sort -n | tail -60

# --- 2026-09-11T16:14:56 · Read course README and scope proposal
cat README.md && echo "=====PROPUESTA=====" && sed -n '1,120p' prompts/propuesta-fases-y-alcance.md

# --- 2026-09-11T16:15:02 · Read memory and BE proposal header
cd /Users/oskar/Developer/Learning/courses-ia-generated && cat /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/tracks-be-angular-decisiones.md; echo "=====DIFFSTAT====="; git status --porcelain -- angular-16-legacy-for-backend-devs | head -50; echo "=====PROPUESTA BE cabecera====="; sed -n '1,80p' angular-16-legacy-for-backend-devs/prompts/propuesta-fases-backend.md

# --- 2026-09-11T16:15:07 · Show diffstat summary for the course
git diff --stat -- angular-16-legacy-for-backend-devs | tail -5

# --- 2026-09-11T16:18:30 · Check recent history and working changes for angular-8
git log --oneline -15 -- angular-8-legacy-for-backend-devs | cat; echo "===== STATUS ====="; git status --porcelain -- angular-8-legacy-for-backend-devs; echo "===== DIFFSTAT working tree ====="; git diff --stat -- angular-8-legacy-for-backend-devs | cat

# --- 2026-09-11T16:18:36 · Show diff of the incident logbook format doc
git diff -- angular-8-legacy-for-backend-devs/prompts/formato-cuaderno-incidentes.md | cat

# --- 2026-09-11T16:19:12 · Compare header structure of both cuadernos
echo "=== A8 cuaderno (frontend) headers ==="; grep -n '^#\{1,3\} ' angular-8-legacy-for-backend-devs/cuaderno-incidentes.md | head -80; echo; echo "=== A16 cuaderno headers ==="; grep -n '^#\{1,3\} ' angular-16-legacy-for-backend-devs/cuaderno-incidentes.md | head -80

# --- 2026-09-11T16:19:20 · Compare committed vs current cuaderno in angular-8
echo "=== A8 cuaderno HEAD lines:"; git show HEAD:angular-8-legacy-for-backend-devs/cuaderno-incidentes.md | wc -l; echo "=== A8 cuaderno HEAD headers:"; git show HEAD:angular-8-legacy-for-backend-devs/cuaderno-incidentes.md | grep -n '^#\{1,3\} '; echo "=== A8 cuaderno NOW lines:"; wc -l < angular-8-legacy-for-backend-devs/cuaderno-incidentes.md

# --- 2026-09-11T16:19:30 · Inspect anatomy of an incident in angular-8
echo "=== A8 incidente 03 anatomy ==="; sed -n '563,770p' angular-8-legacy-for-backend-devs/cuaderno-incidentes.md | grep -n '^#\{1,5\} \|^<details\|^</details>\|^> \*\*\|^\*\*'|head -60

# --- 2026-09-11T16:19:34 · Inspect anatomy of an incident in angular-16
echo "=== A16 incidente 03 anatomy ==="; sed -n '471,645p' angular-16-legacy-for-backend-devs/cuaderno-incidentes.md | grep -n '^#\{1,5\} \|^<details\|^</details>\|^> \*\*\|^\*\*'|head -60

# --- 2026-09-11T16:19:42 · Count forensic route links across cuadernos
cd /Users/oskar/Developer/Learning/courses-ia-generated
echo "A8 'Ruta forense' count:"; grep -c 'Ruta forense' angular-8-legacy-for-backend-devs/cuaderno-incidentes.md
echo "A8 incidentes:"; grep -c '^## Incidente ' angular-8-legacy-for-backend-devs/cuaderno-incidentes.md
echo "A16 'Ruta forense' count:"; grep -c 'Ruta forense' angular-16-legacy-for-backend-devs/cuaderno-incidentes.md
echo "A16 incidentes:"; grep -c '^## Incidente ' angular-16-legacy-for-backend-devs/cuaderno-incidentes.md
echo "A8-BE 'Ruta forense':"; grep -c 'Ruta forense' angular-8-legacy-for-backend-devs/cuaderno-incidentes-be.md
echo "A8-BE incidentes:"; grep -c '^## Incidente ' angular-8-legacy-for-backend-devs/cuaderno-incidentes-be.md

# --- 2026-09-11T16:19:49 · Check forensic route usage in format docs
cd /Users/oskar/Developer/Learning/courses-ia-generated
echo "=== A8-BE ruta forense samples ==="; grep -n 'Ruta forense' angular-8-legacy-for-backend-devs/cuaderno-incidentes-be.md | head -4
echo; echo "=== A8 formato: template metadata block ==="; grep -n 'Ruta forense' angular-8-legacy-for-backend-devs/prompts/formato-cuaderno-incidentes.md
echo; echo "=== A16 formato: ==="; grep -n 'Ruta forense\|forense' angular-16-legacy-for-backend-devs/prompts/formato-cuaderno-incidentes.md | head -20

# --- 2026-09-11T16:19:55 · Compare format doc structures
cd /Users/oskar/Developer/Learning/courses-ia-generated
echo "=== A8 formato HEAD had Ruta forense? ==="; git show HEAD:angular-8-legacy-for-backend-devs/prompts/formato-cuaderno-incidentes.md | grep -n 'Ruta forense'
echo; echo "=== A8 formato section list ==="; grep -n '^#\{1,3\} ' angular-8-legacy-for-backend-devs/prompts/formato-cuaderno-incidentes.md
echo; echo "=== A16 formato section list ==="; grep -n '^#\{1,3\} ' angular-16-legacy-for-backend-devs/prompts/formato-cuaderno-incidentes.md

# --- 2026-09-11T16:20:03 · Read the forensic bridge section
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs
sed -n '161,235p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-11T16:20:10 · Check reciprocal linking between forensic pieces and incidents
cd /Users/oskar/Developer/Learning/courses-ia-generated
echo "=== A16 formato-piezas-forenses: secciones ==="; grep -n '^#\{1,3\} ' angular-16-legacy-for-backend-devs/prompts/formato-piezas-forenses.md
echo; echo "=== A16 piezas que enlazan incidentes ==="; grep -l 'cuaderno-incidentes' angular-16-legacy-for-backend-devs/forense-*.md
echo; echo "=== A8 piezas que enlazan incidentes ==="; grep -l 'cuaderno-incidentes' angular-8-legacy-for-backend-devs/forense-*.md

# --- 2026-09-11T16:20:17 · Check incident mentions in forensic pieces and format docs
cd /Users/oskar/Developer/Learning/courses-ia-generated
echo "=== A8 piezas: menciones a incidentes ==="; grep -c 'ncidente' angular-8-legacy-for-backend-devs/forense-fase-*.md | grep -v ':0'
echo; echo "=== A16 piezas: menciones a incidentes ==="; grep -c 'ncidente' angular-16-legacy-for-backend-devs/forense-fase-*.md | grep -v ':0'
echo; echo "=== A8 formato-piezas §8 (checklist) sobre incidentes ==="; grep -n -i 'incidente' angular-8-legacy-for-backend-devs/prompts/formato-piezas-forenses.md
echo; echo "=== A16 formato-piezas: menciones incidente ==="; grep -n -i 'incidente' angular-16-legacy-for-backend-devs/prompts/formato-piezas-forenses.md

# --- 2026-09-11T16:20:24 · Read the new preparations authoring doc
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs
wc -l prompts/preparaciones-de-incidentes.md; grep -n '^#\{1,3\} ' prompts/preparaciones-de-incidentes.md; echo "=== primeras 60 líneas ==="; sed -n '1,60p' prompts/preparaciones-de-incidentes.md

# --- 2026-09-11T16:20:31 · Extract preparation blocks from angular-16 cuaderno
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
awk '/^## Incidente /{inc=$0} /^### 🔧 Preparación/{p=1; buf=""} p&&/^### 📝/{print "---- " inc; print buf; p=0} p{buf=buf"\n"$0}' cuaderno-incidentes.md | head -220

# --- 2026-09-11T16:20:39 · Tabulate preparation commands per incident
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
awk '/^## Incidente /{inc=substr($0,4,60)} /^### 🔧 Preparación/{p=1;next} p&&/^<details/{p=0} p&&/git switch|git checkout|CHAOS|cp db|db\.incidente|npm run|docker|npm start/{print inc" ||| "$0}' cuaderno-incidentes.md

# --- 2026-09-11T16:20:51 · Verify tag convention and chaos flags
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== tags de fase (convención) ==="; grep -n 'fase-0\|fase-1\|slug' 00-convencion-de-git-y-tags.md | head -30
echo; echo "=== CHAOS flags en fase 3 ==="; grep -n 'CHAOS' 03-mock-api-caos.md | head -30

# --- 2026-09-11T16:20:56 · List the six chaos flags
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '575,595p' 03-mock-api-caos.md; echo "=== expired? ==="; grep -n 'expired' 03-mock-api-caos.md | head

# --- 2026-09-11T16:21:09 · Read A16 preparation forms and BE section
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '113,200p' prompts/formato-cuaderno-incidentes.md; echo "===== §🔥 ====="; sed -n '370,405p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-11T16:21:14 · Read A16 cuaderno header and index
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '1,145p' cuaderno-incidentes.md

# --- 2026-09-11T16:21:21 · Read distribution spec and count actual difficulties
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '62,112p' prompts/formato-cuaderno-incidentes.md
echo "=== conteo real dificultades en cuaderno ==="
grep -oE '\| (🟢|🟡|🟠|🔴) \| ⬜' cuaderno-incidentes.md | sort | uniq -c

# --- 2026-09-11T16:21:28 · Count difficulty distribution and read A8 distribution spec
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep '^| \[' cuaderno-incidentes.md | awk -F'|' '{print $6}' | sort | uniq -c
echo "=== A8 formato §3 reparto ==="; sed -n '113,160p' ../angular-8-legacy-for-backend-devs/prompts/formato-cuaderno-incidentes.md

# --- 2026-09-11T16:21:41 · Check tail sections of A16 cuaderno
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -n '^#\{1,2\} ' cuaderno-incidentes.md | tail -8; echo "=== tail ==="; tail -40 cuaderno-incidentes.md

# --- 2026-09-11T16:21:48 · Inspect head of the A8 cuaderno diff
cd /Users/oskar/Developer/Learning/courses-ia-generated
git diff -- angular-8-legacy-for-backend-devs/cuaderno-incidentes.md | head -260 | sed -n '1,260p'

# --- 2026-09-11T16:21:58 · Check git convention doc diff
cd /Users/oskar/Developer/Learning/courses-ia-generated
git diff -- angular-8-legacy-for-backend-devs/00-convencion-de-git-y-tags.md | cat

# --- 2026-09-11T16:22:02 · Read A16 git convention BE section
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '415,463p' 00-convencion-de-git-y-tags.md

# --- 2026-09-11T16:22:27 · Check README changes about cuaderno
cd /Users/oskar/Developer/Learning/courses-ia-generated
git diff -- angular-8-legacy-for-backend-devs/README.md | grep -n '^[-+]' | grep -i 'cuaderno\|incidente\|forense' | head -40

# --- 2026-09-11T16:22:34 · Survey forensic pieces and their incident references
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
for f in forense-fase-*.md; do echo "--- $f"; head -8 "$f" | grep -v '^$' | head -5; grep -n -i 'incidente' "$f" | head -8; done

# --- 2026-09-11T16:22:52 · Find forensic pieces missing the reciprocal footer
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -L 'Incidentes del cuaderno que usan esta ruta' forense-fase-*.md
echo "=== f12 tail ==="; tail -18 forense-fase-12.md
echo "=== f07 línea 178 contexto ==="; sed -n '174,180p' forense-fase-07.md

# --- 2026-09-11T16:23:08 · Extract root cause and minimal patch per incident
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
awk '/^## Incidente /{inc=$0; show=0} /^\*\*Causa raíz\*\*/{show=1; print "\n\n########## " inc} /^\*\*La refactorización correcta\*\*|^\*\*Prueba de regresión\*\*/{show=0} show{print}' cuaderno-incidentes.md | sed -n '1,400p'

# --- 2026-09-11T16:23:14 · Extract remaining root causes
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
awk '/^## Incidente /{inc=$0; show=0} /^\*\*Causa raíz\*\*/{show=1; print "\n\n########## " inc} /^\*\*La refactorización correcta\*\*|^\*\*Prueba de regresión\*\*/{show=0} show{print}' cuaderno-incidentes.md | sed -n '400,900p'

# --- 2026-09-11T16:23:21 · Read seed data shape
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '230,330p' 03-mock-api-caos.md

# --- 2026-09-11T16:23:25 · Read templates seed
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '185,232p' 03-mock-api-caos.md

# --- 2026-09-11T16:23:29 · Read preparations of incidents 09 and 12
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '1508,1552p' cuaderno-incidentes.md; echo "==== INC 12 ===="; sed -n '/^## Incidente 12/,/^<details/p' cuaderno-incidentes.md | sed -n '1,40p'

# --- 2026-09-11T16:23:42 · Find cross-references to the format doc
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -rn 'formato-cuaderno-incidentes' . | grep -v '^./prompts/formato-cuaderno'

# --- 2026-09-11T16:23:54 · Read section 2 of format doc
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '45,62p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-11T16:24:28 · Locate template metadata line
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -n 'Tiempo sugerido' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-11T16:24:47 · Read BE proposal section on the incident logbook
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '/^## .*9\./,/^## /p' prompts/propuesta-fases-backend.md | grep -n 'cuaderno\|incidente\|prepar\|plantilla-de-incidente\|\.env' | head -30
echo "=== busca la sección del cuaderno BE ==="
grep -n 'cuaderno-incidentes-be\|plantilla-de-incidente-be' prompts/propuesta-fases-backend.md | head

# --- 2026-09-11T16:25:13 · List all incident metadata lines
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -n '^> \*\*Tiempo sugerido:\*\*' cuaderno-incidentes.md

# --- 2026-09-11T16:25:19 · Insert forensic route field into all incidents
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 - <<'PY'
import re
p='cuaderno-incidentes.md'
s=open(p).read().split('\n')
rutas={
1:['00'],2:['01'],3:['02'],4:['03'],5:['04'],6:['05'],7:['05','01'],
8:['07','12'],9:['07'],10:['07','08'],11:['08'],12:['09'],13:['09'],
14:['10'],15:['10'],16:['11','04'],17:['12'],18:['13'],19:['13'],20:['12'],
}
lines=[149,327,475,649,812,977,1135,1315,1495,1694,1888,2086,2280,2478,2667,2879,3067,3265,3442,3662]
for i,ln in enumerate(lines,start=1):
    idx=ln-1
    assert s[idx].startswith('> **Tiempo sugerido:**'), s[idx]
    refs=' y '.join('[`forense-fase-%s.md`](forense-fase-%s.md)'%(n,n) for n in rutas[i])
    s[idx]=s[idx]+' · **Ruta forense:** '+refs
open(p,'w').write('\n'.join(s))
print('ok')
PY
grep -n 'Ruta forense' cuaderno-incidentes.md | head -20

# --- 2026-09-11T16:25:49 · Locate key code symbols across phases
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
for s in "certificate-pdf.service" "buildAnswerForm" "addControl" "resolveTemplateVersion" "CLIENT_LIST_PAGE_SIZE" "router-outlet" "severityOf" "check-coverage" "entrypoint.sh" "interval(60_000)" "takeUntilDestroyed"; do echo "##### $s"; grep -rln "$s" --include='*.md' . | tr '\n' ' '; echo; done

# --- 2026-09-11T16:25:56 · Read PDF service and dashboard refresh code
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== PDF service en Fase 10 ==="; grep -n -A22 'certificate-pdf.service' 10-certificados-vigencia.md | head -60
echo; echo "=== dashboard refresco Fase 11 ==="; grep -n -B3 -A12 'interval(' 11-dashboard-alertas.md | head -50

# --- 2026-09-11T16:26:06 · Check dashboard refresh and testing specifics
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -n 'interval\|refresc\|60_000\|reload()' 11-dashboard-alertas.md | head -20
echo "=== fase 12 coverage/ karma ==="; grep -n 'seed\|random\|localStorage' 12-testing-coverage.md | head -20

# --- 2026-09-11T16:26:13 · Read dashboard heartbeat code
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '645,700p' 11-dashboard-alertas.md

# --- 2026-09-11T16:26:28 · Check severity derivation decisions in phase 9
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -n 'severityOverride\|overriddenBy\|deriva\|severity' 09-hallazgos-severidad.md | head -30

# --- 2026-09-11T16:26:42 · Check phase 1 feature structure
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -n 'features/\|loadChildren\|RouterModule.forChild\|assets' 01-estructura-base-ngmodules.md | head -30

# --- 2026-09-11T16:30:22 · Verify inspection status values
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -n "InspectionStatus" 03-mock-api-caos.md | head -5; grep -n "type InspectionStatus" -A3 03-mock-api-caos.md | head -8

# --- 2026-09-11T16:30:24 · Read full inspection status union
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '659,670p' 03-mock-api-caos.md

# --- 2026-09-11T16:30:27 · Read README cuaderno section
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -n -A8 '^## 📓 Cuaderno de incidentes' README.md

# --- 2026-09-11T16:30:39 · Check whether A8 references preparaciones from README
cd /Users/oskar/Developer/Learning/courses-ia-generated
grep -n 'preparaciones' angular-8-legacy-for-backend-devs/README.md angular-8-legacy-for-backend-devs/cuaderno-incidentes.md | head

# --- 2026-09-11T16:30:43 · Run the forensic verification script
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs && python3 prompts/verificar-forenses.py 2>&1 | tail -20

# --- 2026-09-11T16:30:52 · Verify reciprocal forensic links
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 - <<'PY'
import re,os
# comprueba que cada enlace forense del cuaderno existe y que la pieza reclama el incidente
txt=open('cuaderno-incidentes.md').read()
inc=re.findall(r'^## Incidente (\d+) .*?\n>.*?\n>.*?\n> \*\*Tiempo sugerido:\*\*(.*)$', txt, re.M)
bad=[]
for num,meta in inc:
    files=re.findall(r'forense-fase-(\d+)\.md\)', meta)
    for f in files:
        p=f'forense-fase-{f}.md'
        if not os.path.exists(p): bad.append((num,p,'no existe')); continue
        foot=[l for l in open(p) if l.startswith('**Incidentes del cuaderno')]
        if foot and re.search(r'\b0?%d\b'%int(num), foot[0]) is None:
            bad.append((num,p,'la pieza no lo reclama: '+foot[0].strip()[:90]))
print(len(inc),'incidentes con Ruta forense')
for b in bad: print(' ⚠️',b)
PY

# --- 2026-09-11T16:31:00 · Verify reciprocal forensic links again
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
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
        if not os.path.exists(p): bad.append((num,p,'no existe')); continue
        foot=[x for x in open(p) if x.startswith('**Incidentes del cuaderno')]
        if not foot: bad.append((num,p,'sin pie recíproco')); continue
        if not re.search(r'\b0*%d\b'%num, foot[0]): bad.append((num,p,foot[0].strip()[:80]))
print(len(pairs),'incidentes con Ruta forense'); [print(' ⚠️',b) for b in bad] or print('recíprocos OK')
PY

# --- 2026-09-11T16:31:18 · Re-verify forensic pieces and check links
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

# --- 2026-09-11T16:31:25 · Final sanity check of edits
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -c 'Ruta forense' cuaderno-incidentes.md
grep -n '^#\{1,3\} ' prompts/formato-cuaderno-incidentes.md
echo "=== diffstat del curso ==="; cd .. && git diff --stat -- angular-16-legacy-for-backend-devs | tail -8; git status --porcelain -- angular-16-legacy-for-backend-devs | grep '??'

# --- 2026-09-11T16:37:13 · Inspect representative phase and appendix diffs
cd /Users/oskar/Developer/Learning/courses-ia-generated
git diff -- angular-8-legacy-for-backend-devs/05-pacientes.md angular-8-legacy-for-backend-devs/10-dashboard.md angular-8-legacy-for-backend-devs/a05-rxjs.md | cat

# --- 2026-09-11T16:37:23 · Check phase headers and incident reservation blocks
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== cabeceras de fases ==="; for f in 0*.md 1*.md; do head -6 "$f" | grep -n 'Apéndices de apoyo\|Incidentes asociados' | sed "s|^|$f: |"; done
echo; echo "=== bloques de reservas ==="; grep -rn 'Reservas para el cuaderno' *.md | head -20

# --- 2026-09-11T16:37:29 · Read reservation block wording
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
for f in 00-setup-hola-mundo.md 04-estado-servicios.md 07-plantillas-versionadas.md 14-casi-prod-kind.md; do echo "===== $f"; sed -n "/^### Reservas para el cuaderno/,+6p" "$f"; done

# --- 2026-09-11T16:37:36 · View full reservation blocks
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '/^### Reservas para el cuaderno/,/^###\|^---/p' 07-plantillas-versionadas.md | head -20; echo "-----"; sed -n '/^### Reservas para el cuaderno/,/^###\|^---/p' 12-testing-coverage.md | head -20

# --- 2026-09-11T16:37:46 · Update reservation blocks in all phases
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 - <<'PY'
import glob,re
intro = ("Los enunciados ya están escritos en el índice de "
         "[`cuaderno-incidentes.md`](cuaderno-incidentes.md), que es donde viven; "
         "acá queda constancia de qué fase los produce. **El ID no se reasigna nunca.**\n\n")
n=0
for f in sorted(glob.glob('[01][0-9]-*.md')):
    s=open(f).read()
    if '### Reservas para el cuaderno de incidentes' not in s: continue
    if '14-casi-prod-kind' in f:
        s2=s.replace('| ID | Título propuesto | Categoría | Dif. |','| ID | Título | Categoría | Dif. |')
    else:
        s2=s.replace('### Reservas para el cuaderno de incidentes\n\n| ID | Título propuesto |',
                     '### Reservas para el cuaderno de incidentes\n\n'+intro+'| ID | Título |')
    if s2!=s:
        open(f,'w').write(s2); n+=1; print('✓',f)
print(n,'archivos')
PY
grep -rn 'Título propuesto' *.md | head

# --- 2026-09-11T16:37:57 · Cross-check reservation tables against the index
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 - <<'PY'
import glob,re
idx={}
for l in open('cuaderno-incidentes.md'):
    m=re.match(r'^\| \[(\d+)\]\(#[^)]*\) \| \d+ \| (.*?) \| (.*?) \| (.*?) \| ⬜ \|', l)
    if m: idx[int(m.group(1))]=(m.group(2).strip(), m.group(3).strip(), m.group(4).strip())
res={}
for f in sorted(glob.glob('[01][0-9]-*.md')):
    for l in open(f):
        m=re.match(r'^\| (\d+) \| (.*?) \| (.*?) \| (.*?) \|\s*$', l)
        if m: res[int(m.group(1))]=(f, m.group(2).strip(), m.group(3).strip(), m.group(4).strip())
print('índice:',len(idx),'reservas:',len(res))
for k in sorted(set(idx)|set(res)):
    if k not in idx: print(' ⚠️ reservado sin fila en el índice:',k,res[k]); continue
    if k not in res: print(' ⚠️ en el índice y sin reserva:',k,idx[k]); continue
    f,t,c,d=res[k]; ti,ci,di=idx[k]
    if (t,c,d)!=(ti,ci,di): print(f' ⚠️ {k} ({f}) difiere:\n    reserva: {t} | {c} | {d}\n    índice : {ti} | {ci} | {di}')
PY

# --- 2026-09-11T16:38:04 · Align category name in the index
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -i '' 's/ | Convivencia 🧬 | /| Convivencia de estilos 🧬 | /' cuaderno-incidentes.md
grep -n 'Convivencia' cuaderno-incidentes.md | head

# --- 2026-09-11T16:38:10 · Repair the table separator spacing
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -i '' 's/compila"| Convivencia/compila" | Convivencia/; s/blanco"| Convivencia/blanco" | Convivencia/' cuaderno-incidentes.md
sed -n '112,113p' cuaderno-incidentes.md | cut -c1-200

# --- 2026-09-11T16:38:16 · Inspect appendix headers
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
ls a*.md; echo "=== cabeceras de apéndices ==="; for f in a*.md; do sed -n '3,7p' "$f" | grep -n 'Fases que\|Apéndice\|Relacionad\|Incidentes' | sed "s|^|$f: |"; done

# --- 2026-09-11T16:38:20 · Read appendix header shape
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
for f in a01-material.md a06-rxjs.md a12-arm64-m1.md; do echo "===== $f"; head -8 "$f"; done

# --- 2026-09-11T16:38:26 · See how A8 linked appendix and forensic headers
cd /Users/oskar/Developer/Learning/courses-ia-generated
git diff -- angular-8-legacy-for-backend-devs/a01-material.md | head -30
echo "=== y una pieza forense ==="; git diff -- angular-8-legacy-for-backend-devs/forense-fase-04.md | cat

# --- 2026-09-11T16:38:35 · Check for malformed emoji anchors
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== anclas ⚠️ mal formadas ==="; grep -rn '](#-advertencias)' *.md prompts/*.md | head -20
echo; echo "=== otras anclas con emoji sospechosas ==="; grep -rhno '](#[^)]*)' *.md | grep -o '#[^)]*' | sort -u | head -40

# --- 2026-09-11T16:38:44 · Scan for unaccented Spanish words
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -rnoiE '\b(peticion|peticiones|suscripcion|suscripciones|edicion|configuracion|aplicacion|version|versiones|informacion|validacion|navegacion|inyeccion|aqui|despues|tambien|segun|codigo|numero|numeros|ultimo|ultima|mas rapido|invalido|invalida|deberia|estaria|habria|seria|podria|tenia|dia|dias|solucion|razon|opcion|opciones|funcion|funciones|mecanica|practica|automatico|automatica|basico|basica|rapido|rapida|logica|publico|publica|critico|critica|analisis|parametro|parametros|metodo|metodos|linea|lineas|ademas|alli|aun asi|aunque no|aqui mismo)\b' *.md prompts/*.md | grep -viE 'version|versiones' | awk -F: '{print $1}' | sort | uniq -c | sort -rn | head -20

# --- 2026-09-11T16:38:52 · List actual unaccented matches with location
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -rnoiE '\b(peticion|peticiones|suscripcion|suscripciones|edicion|configuracion|aplicacion|informacion|validacion|navegacion|inyeccion|aqui|despues|tambien|segun|codigo|numero|numeros|ultimo|ultima|invalido|invalida|deberia|estaria|habria|seria|podria|tenia|solucion|razon|opcion|opciones|funcion|funciones|mecanica|practica|automatico|automatica|basico|basica|rapido|rapida|logica|publico|publica|critico|analisis|parametro|parametros|metodo|metodos|linea|lineas|ademas|alli)\b' *.md | head -40

# --- 2026-09-11T16:39:00 · Find genuinely unaccented singular forms
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -rnE '\b([Ff]uncion|[Pp]eticion|[Ss]uscripcion|[Ee]dicion|[Cc]onfiguracion|[Aa]plicacion|[Ii]nformacion|[Vv]alidacion|[Nn]avegacion|[Ii]nyeccion|[Ss]olucion|[Rr]azon|[Oo]pcion|aqui|despues|tambien|segun|codigo|numero|ultimo|ultima|invalido|invalida|deberia|podria|tenia|mecanica|practica|automatico|basico|rapido|logica|publica|critico|analisis|parametro|metodo|linea|ademas|alli)\b' *.md prompts/*.md | grep -vE 'Publica|publica' | head -30

# --- 2026-09-11T16:39:11 · Check forense-master diff in A8
cd /Users/oskar/Developer/Learning/courses-ia-generated
git diff -- angular-8-legacy-for-backend-devs/forense-master.md | cat

# --- 2026-09-11T16:39:15 · Check A16 symptom index table
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -n -A6 'Lo que ves o te cuentan' forense-master.md | head -12

# --- 2026-09-11T16:39:19 · Read full symptom index
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '44,80p' forense-master.md

# --- 2026-09-11T16:39:25 · Read section 2 index table
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '25,48p' forense-master.md

# --- 2026-09-11T16:39:35 · Link forensic master tables
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 - <<'PY'
import re,glob

fases={}
for f in glob.glob('[01][0-9]-*.md'):
    n=int(f[:2]); fases[n]=f
aps={}
for f in glob.glob('a[01][0-9]-*.md'):
    aps[f[:3].upper()]=f

# ---- forense-master: §2 (archivos) y §3 (fases) ----
p='forense-master.md'; s=open(p).read()
s=re.sub(r'`(forense-fase-(\d\d)\.md)`', lambda m: '[`%s`](%s)'%(m.group(1),m.group(1)), s)
intro=("Cada fila te manda **a la fase**, que es donde está el código y el contexto. "
       "El recorrido paso a paso vive en su pieza: la tienes enlazada en la sección 6 de esa "
       "fase y, directa, en el índice de §2 — que es la tabla de arriba y la que conviene "
       "abrir en otra pestaña mientras investigas.\n\n")
s=s.replace("y a la derecha, dónde empezar.\n\n| Lo que ves",
            "y a la derecha, dónde empezar.\n\n"+intro+"| Lo que ves")
out=[]
for line in s.split('\n'):
    if line.startswith('| ') and ' | Fase ' in line or (line.startswith('| ') and line.count('|')==3 and re.search(r'\| Fase \d', line)):
        line=re.sub(r'(?<!\[)\bFase (\d{1,2})\b(?!\])',
                    lambda m: '[Fase %s](%s)'%(m.group(1), fases[int(m.group(1))]) if int(m.group(1)) in fases else m.group(0),
                    line)
    out.append(line)
s='\n'.join(out)
open(p,'w').write(s)
print('forense-master: ok')
PY
sed -n '54,60p' forense-master.md; echo ...; sed -n '29,31p' forense-master.md

# --- 2026-09-11T16:39:43 · Fix phase 0 link target
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -i '' 's|\[Fase 0\](00-historia-del-sistema.md)|[Fase 0](00-setup-hola-mundo.md)|g; s|\[Fase 0\](00-convencion-de-git-y-tags.md)|[Fase 0](00-setup-hola-mundo.md)|g' forense-master.md
grep -n '\[Fase ' forense-master.md | sed 's/\(.\{130\}\).*/\1/' 

# --- 2026-09-11T16:39:58 · Link phase and appendix headers
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 - <<'PY'
import re,glob
fases={}
for f in glob.glob('[01][0-9]-*.md'):
    if re.match(r'\d\d-(historia|convencion)', f): continue
    fases[int(f[:2])]=f
aps={f[:3].upper():f for f in glob.glob('a[01][0-9]-*.md')}

# 1) forense-master §3: enlazar A04 / A08
p='forense-master.md'; s=open(p).read()
s=re.sub(r'\*\*(A\d\d)\*\* §', lambda m: '[**%s**](%s) §'%(m.group(1), aps[m.group(1)]), s)
open(p,'w').write(s)

# 2) cabeceras de fase
n=0
for num,f in sorted(fases.items()):
    s=open(f).read(); o=s
    def ap(m):
        return '[%s](%s)'%(m.group(0), aps[m.group(1)])
    head, sep, rest = s.partition('\n\n')
    head=re.sub(r'(?m)^(> Apéndices de apoyo: .*)$',
                lambda m: re.sub(r'\b(A\d\d)\b(?! *\]) *\(([^)]*)\)',
                                 lambda x: '[%s (%s)](%s)'%(x.group(1), x.group(2), aps[x.group(1)]),
                                 m.group(1)), head)
    head=re.sub(r'(?m)^> Incidentes asociados: ',
                '> [Incidentes asociados](cuaderno-incidentes.md): ', head)
    s=head+sep+rest
    if s!=o: open(f,'w').write(s); n+=1
print('fases con cabecera enlazada:',n)

# 3) cabeceras de apéndice: "Usado por: Fase 1, Fase 5"
m=0
for a,f in sorted(aps.items()):
    s=open(f).read(); o=s
    head, sep, rest = s.partition('\n\n')
    head=re.sub(r'(?m)^(> Usado por: .*)$',
                lambda mm: re.sub(r'\bFase (\d{1,2})\b',
                                  lambda x: '[Fase %s](%s)'%(x.group(1), fases[int(x.group(1))]), mm.group(1)), head)
    s=head+sep+rest
    if s!=o: open(f,'w').write(s); m+=1
print('apéndices con cabecera enlazada:',m)
PY
head -6 07-plantillas-versionadas.md | tail -3; echo ---; head -4 a06-rxjs.md | tail -1

# --- 2026-09-11T16:40:10 · Retry header linking
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 - <<'PY'
import re,glob
fases={int(f[:2]):f for f in glob.glob('[01][0-9]-*.md') if not re.match(r'\d\d-(historia|convencion)',f)}
aps={f[:3].upper():f for f in glob.glob('a[01][0-9]-*.md')}
n=m=0
for num,f in sorted(fases.items()):
    L=open(f).read().split('\n'); o=list(L)
    for i in range(min(10,len(L))):
        if L[i].startswith('> Apéndices de apoyo:'):
            L[i]=re.sub(r'\b(A\d\d) \(([^)]*)\)', lambda x:'[%s (%s)](%s)'%(x.group(1),x.group(2),aps[x.group(1)]), L[i])
        elif L[i].startswith('> Incidentes asociados:'):
            L[i]=L[i].replace('> Incidentes asociados:','> [Incidentes asociados](cuaderno-incidentes.md):',1)
    if L!=o: open(f,'w').write('\n'.join(L)); n+=1
for a,f in sorted(aps.items()):
    L=open(f).read().split('\n'); o=list(L)
    for i in range(min(10,len(L))):
        if L[i].startswith('> Usado por:'):
            L[i]=re.sub(r'\bFase (\d{1,2})\b', lambda x:'[Fase %s](%s)'%(x.group(1),fases[int(x.group(1))]), L[i])
    if L!=o: open(f,'w').write('\n'.join(L)); m+=1
print('fases:',n,'apéndices:',m)
PY
head -6 07-plantillas-versionadas.md | tail -2; echo ---; head -4 a06-rxjs.md | tail -1

# --- 2026-09-11T16:40:15 · Find appendices whose header was not linked
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== apéndices sin 'Usado por' enlazado (3 restantes) ==="; for f in a*.md; do head -6 "$f" | grep -q 'Usado por: \[' || { echo "--- $f"; sed -n '3,5p' "$f"; }; done

# --- 2026-09-11T16:40:25 · Fix accent in env comment
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -i '' 's|# .env — La version de la base vive AQUI, fuera del codigo fuente.|# .env — La versión de la base vive AQUÍ, fuera del código fuente.|' prompts/propuesta-fases-backend.md
grep -n 'vive AQU' prompts/propuesta-fases-backend.md 00-convencion-de-git-y-tags.md

# --- 2026-09-11T16:40:31 · Validate all internal markdown links
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

# --- 2026-09-11T16:40:40 · Check whether the verifier script is documented
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -rn 'verificar-forenses' . | head

# --- 2026-09-11T16:40:48 · Final link validation and diffstat
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 - <<'PY'
import re,glob,os
bad=0; total=0
for f in glob.glob('*.md')+glob.glob('prompts/*.md'):
    d=os.path.dirname(f) or '.'
    for m in re.finditer(r'\]\(([^)#\s]+\.md)(#[^)]*)?\)', open(f).read()):
        t=m.group(1); total+=1
        if not os.path.exists(os.path.join(d,t)): print('ROTO:',f,'->',t); bad+=1
print(total,'enlaces .md ·',bad,'rotos')
PY
cd .. && git diff --stat -- angular-16-legacy-for-backend-devs | tail -3

# --- 2026-09-11T16:41:19 · Add memory index entry
cd /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory
printf '%s\n' '- [Cuaderno y forense de CertCore](angular16-cuaderno-y-forense.md) — alineado el 11/09/2026: preparaciones escritas, puente forense bidireccional y la sección sin número.' >> MEMORY.md
tail -2 MEMORY.md

# --- 2026-09-11T16:43:30 · Inspect the testing phase diff in A8
cd /Users/oskar/Developer/Learning/courses-ia-generated
git diff -- angular-8-legacy-for-backend-devs/12-testing-coverage.md | grep -E '^[-+]' | grep -vE '^[-+]{3}' | grep -viE 'acento|^\+$|^\-$' | head -60

# --- 2026-09-11T16:43:45 · Scan for Spanish identifiers in code blocks
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 - <<'PY'
import re,glob
pat=re.compile(r'\b(?:const|let|var|function|readonly)\s+([a-záéíóúñ][A-Za-z0-9áéíóúñ_]*)\b')
esp=re.compile(r'(?i)(resultado|estado(?!Ref)|accion|acciones|lista|creado|actualizado|respuesta|valor(?!ue)|nombre|fecha|usuario|plantilla|hallazgo|inspeccion|certificado|activo|cliente(?!s?Api)|previo|siguiente|contador|archivo|datos|prueba|error(?:es)?Msg|cantidad|indice|clave|elemento|numero|texto|linea|mensaje|descarga|guardar|cargar|enviar|calcular|obtener|validar|construir)')
hits={}
for f in sorted(glob.glob('*.md')+glob.glob('prompts/*.md')):
    s=open(f).read(); infence=False
    for i,l in enumerate(s.split('\n'),1):
        if l.strip().startswith('```'): infence=not infence; continue
        if not infence: continue
        for m in pat.finditer(l):
            n=m.group(1)
            if esp.fullmatch(n) or esp.match(n) and len(n)>4:
                hits.setdefault(f,[]).append((i,n,l.strip()[:80]))
for f,v in hits.items():
    print('###',f)
    for i,n,l in v[:6]: print('   ',i,n,'|',l)
print('archivos con sospecha:',len(hits))
PY

# --- 2026-09-11T16:43:57 · Scan for Spanish method names and JSON keys
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 - <<'PY'
import re,glob
esp=re.compile(r'\b(descargar|guardar|cargar|enviar|calcular|obtener|validar|construir|buscar|eliminar|actualizar|crear|abrir|cerrar|mostrar|ocultar|listar|filtrar|ordenar|resolver|emitir|revocar|aprobar|rechazar)\s*\(')
key=re.compile(r'"(requiere[A-Z]|severidad|nombre|fecha|estado|version[A-Z]|plantilla|hallazgo|inspeccion|certificado|cliente|activo)[A-Za-z]*"\s*:')
for f in sorted(glob.glob('*.md')+glob.glob('prompts/*.md')):
    if '_deprecado' in f: continue
    s=open(f).read().split('\n'); infence=False
    for i,l in enumerate(s,1):
        if l.strip().startswith('```'): infence=not infence; continue
        if not infence: continue
        for rx,tag in ((esp,'método'),(key,'clave')):
            m=rx.search(l)
            if m: print(f'{f}:{i} [{tag}] {l.strip()[:90]}')
PY
echo "— fin del barrido —"

# --- 2026-09-11T16:44:03 · Find the component method name for PDF download
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -n 'pdf.download\|downloadPdf\|onDownload' 10-certificados-vigencia.md cuaderno-incidentes.md | head

# --- 2026-09-11T16:44:06 · Check how the download is invoked in phase 10
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -n 'download' 10-certificados-vigencia.md | head -12

# --- 2026-09-11T16:44:10 · Read the component-level download method
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '780,792p' 10-certificados-vigencia.md

# --- 2026-09-11T16:44:22 · Final verification sweep
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

# --- 2026-09-11T17:04:00 · Inspect the angular-16 appendix prompts file
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -n '^## \|^# ' prompts/prompts-backend-apendice.md; echo "=== líneas:"; wc -l prompts/prompts-backend-apendice.md; echo "=== tail ==="; tail -25 prompts/prompts-backend-apendice.md

# --- 2026-09-11T17:04:17 · Read the common frame and first appendices
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '1,115p' prompts/prompts-backend-apendice.md

# --- 2026-09-11T17:04:33 · Look for placeholders and section coverage
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== marcadores de pendiente ==="; grep -n 'TODO\|FALTA\|por escribir\|pendiente de redactar\|\[Pega aquí\|XXX\|{{' prompts/prompts-backend-fase.md prompts/prompts-backend-apendice.md | head -20
echo; echo "=== secciones por prompt en el archivo de fases ==="
awk '/^## # Fase/{f=$0; c[""]} /^## /{if(f&&$0!~/^## # Fase/) printf "%s | %s\n", substr(f,8,22), $0}' prompts/prompts-backend-fase.md

# --- 2026-09-11T17:04:47 · Compare section structure with the completed angular-8 track
cd /Users/oskar/Developer/Learning/courses-ia-generated
echo "=== angular-8 apendice: secciones por apéndice ==="
awk '/^## # Apéndice/{f=substr($0,14,12)} /^## /{if(f&&$0!~/^## # Apéndice/) printf "%s | %s\n", f, $0}' angular-8-legacy-for-backend-devs/prompts/prompts-backend-apendice.md | head -40
echo; echo "=== angular-8 fase: secciones ==="
awk '/^## # Fase/{f=substr($0,8,10)} /^## /{if(f&&$0!~/^## # Fase/) printf "%s | %s\n", f, $0}' angular-8-legacy-for-backend-devs/prompts/prompts-backend-fase.md | head -14

# --- 2026-09-11T17:05:00 · Cross-check appendix references between the two prompt files
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== apéndices referenciados desde las fases ==="
grep -o 'bea-[0-9][0-9]' prompts/prompts-backend-fase.md | sort | uniq -c
echo; echo "=== 'Usado por' declarado en cada apéndice ==="
grep -n '^- Usado por:' prompts/prompts-backend-apendice.md
echo; echo "=== títulos de apéndice en cada archivo ==="
grep -o '^## # Apéndice bea-[0-9][0-9] — .*' prompts/prompts-backend-apendice.md

# --- 2026-09-11T17:05:24 · Check completeness of each prompt block
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== apéndices sin línea de Ejercicios ==="
awk '/^## # Apéndice/{if(cur&&!ej) print cur" ← SIN ejercicios"; cur=$0; ej=0} /Ejercicios:/{ej=1} END{if(cur&&!ej)print cur" ← SIN ejercicios"}' prompts/prompts-backend-apendice.md
echo "=== apéndices sin 'Qué queda explícitamente fuera' ==="
awk '/^## # Apéndice/{if(cur&&!f) print cur; cur=$0; f=0} /explícitamente fuera|queda fuera|NO entra/{f=1} END{if(cur&&!f)print cur}' prompts/prompts-backend-apendice.md
echo "=== fases sin línea de Ejercicios ==="
awk '/^## # Fase/{if(cur&&!ej) print cur" ← SIN ejercicios"; cur=$0; ej=0} /Ejercicios:/{ej=1} END{if(cur&&!ej)print cur" ← SIN ejercicios"}' prompts/prompts-backend-fase.md
echo "— fin —"

# --- 2026-09-11T17:05:36 · Read the two support-appendix lines to correct
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '378,380p;607,609p' prompts/prompts-backend-fase.md

# --- 2026-09-11T17:05:59 · Verify bidirectional phase-appendix consistency
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
python3 - <<'PY'
import re
fase=open('prompts/prompts-backend-fase.md').read()
ap=open('prompts/prompts-backend-apendice.md').read()
# fase -> apéndices
f2a={}
cur=None
for l in fase.split('\n'):
    m=re.match(r'^## # Fase (be\d\d)',l)
    if m: cur=m.group(1); buf=[]
    if cur and l.startswith('- Apéndices de apoyo:'): f2a[cur]=set(re.findall(r'bea-\d\d',l))
    elif cur and cur in f2a and l.startswith('  ') and 'bea-' in l: f2a[cur]|=set(re.findall(r'bea-\d\d',l))
a2f={}
cur=None
for l in ap.split('\n'):
    m=re.match(r'^## # Apéndice (bea-\d\d)',l)
    if m: cur=m.group(1)
    if cur and l.startswith('- Usado por:'): a2f[cur]=set(re.findall(r'be\d\d',l))
bad=0
for a,fs in sorted(a2f.items()):
    for f in fs:
        if a not in f2a.get(f,set()):
            print(f'⚠️ {a} dice «usado por {f}» y {f} no lo lista'); bad+=1
for f,as_ in sorted(f2a.items()):
    for a in as_:
        if f not in a2f.get(a,set()):
            print(f'⚠️ {f} lista {a} y {a} no lo reclama'); bad+=1
print('asimetrías:',bad)
PY

# --- 2026-09-11T17:06:12 · Locate cross-course references
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -n 'LabCore\|angular-8\|Track A\|curso hermano' prompts/guia-de-estilo-y-convenciones.md prompts/alcance-del-proyecto.md README.md a10-migracion-8-16.md | head -20

# --- 2026-09-11T17:06:21 · Read style guide section list
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -n '^## \|^### ' prompts/guia-de-estilo-y-convenciones.md | sed -n '1,40p'

# --- 2026-09-11T17:06:23 · Read section 12 on document coherence
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '652,675p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-11T17:06:46 · Verify the cross-reference rule holds and re-run checks
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

# --- 2026-09-11T17:06:56 · Read the a13 callout context
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '135,143p' a13-i18n.md

# --- 2026-09-11T17:07:09 · Align the chapter template and re-check the rule
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -i '' 's|  y trae los reflejos de LabCore puestos. Se escribe hablándole a esa persona, y\n|&|' prompts/plantillas-de-capitulo.md
python3 - <<'PY'
p='prompts/plantillas-de-capitulo.md'
s=open(p).read()
s=s.replace("es el único documento del curso donde nombrar LabCore es correcto.",
            "es el único documento del **cuerpo** del curso donde nombrar LabCore\n  es correcto — el otro sitio es la sección «Su curso hermano» del `README.md`.\n  La regla completa está en §12.1 de la guía de estilo.")
open(p,'w').write(s)
PY
echo "=== LabCore en el cuerpo del curso (debe quedar solo a10) ==="
grep -rln 'LabCore' *.md | grep -v '^README.md\|^a10-'
echo "— fin —"

# --- 2026-09-11T17:07:16 · Final verification after this round
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

# --- 2026-09-11T17:07:30 · Read the security and debt-map appendix prompts
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== bea-08 (seguridad) ==="; sed -n '386,432p' prompts/prompts-backend-apendice.md
echo; echo "=== bea-10 (mapa de deuda) ==="; sed -n '480,518p' prompts/prompts-backend-apendice.md

# --- 2026-09-11T17:07:56 · Check other base-track appendix references from BE prompts
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== otras referencias a apéndices del track base desde los prompts BE ==="
grep -n '`a[0-9][0-9]`\|a12\|a01\|a04\|a07\|a08\|a09' prompts/prompts-backend-apendice.md prompts/prompts-backend-fase.md prompts/propuesta-fases-backend.md | head -20

# --- 2026-09-11T17:08:10 · Final verification of the BE prompt files
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

# --- 2026-09-11T17:12:32 · Check declared BE filenames and naming rationale
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
echo "=== nombres de archivo declarados en los prompts BE ==="
grep -oE '`be[a0-9][^`]*\.md`' prompts/prompts-backend-fase.md prompts/prompts-backend-apendice.md | sort -u
echo; echo "=== lo que dice la propuesta sobre la convención ==="
sed -n '765,790p' prompts/propuesta-fases-backend.md

# --- 2026-09-11T17:12:48 · Calibrate size against angular-8 BE track
cd /Users/oskar/Developer/Learning/courses-ia-generated
echo "=== tamaños del track BE de angular-8 (referencia) ==="
wc -w angular-8-legacy-for-backend-devs/be0*.md angular-8-legacy-for-backend-devs/bea-0[1-3]*.md angular-8-legacy-for-backend-devs/cuaderno-incidentes-be.md | tail -15
echo; echo "=== plantilla de fase (9 secciones) en angular-16 ==="
cd angular-16-legacy-for-backend-devs
grep -n '^## \|^### ' prompts/plantillas-de-capitulo.md | head -30

# --- 2026-09-11T17:12:58 · Read the phase chapter template
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '1,135p' prompts/plantillas-de-capitulo.md

# --- 2026-09-11T17:13:02 · Read rest of template and style guide BE section
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '135,225p' prompts/plantillas-de-capitulo.md; echo "======= GUIA §15 ======="; sed -n '732,838p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-11T17:13:08 · Read the fixed stack section of the BE proposal
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '/^## .*5\..*[Ee]l stack/,/^## /p' prompts/propuesta-fases-backend.md | head -80

# --- 2026-09-11T17:13:12 · List proposal sections
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
grep -n '^## ' prompts/propuesta-fases-backend.md

# --- 2026-09-11T17:13:15 · Read the fixed stack and versions
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '310,446p' prompts/propuesta-fases-backend.md

# --- 2026-09-11T17:13:25 · Read the mock auth and routes
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
sed -n '330,400p' 03-mock-api-caos.md

# --- 2026-09-11T17:18:08 · Verify the new phase document
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs
wc -w be00-el-contrato-auditoria-del-mock.md
echo "=== secciones ==="; grep -c '^## ' be00-el-contrato-auditoria-del-mock.md
echo "=== ejercicios numerados ==="; grep -cE '^[0-9]+\. ' be00-el-contrato-auditoria-del-mock.md
echo "=== enlaces rotos ==="
python3 - <<'PY'
import re,os
f='be00-el-contrato-auditoria-del-mock.md'
for m in re.finditer(r'\]\(([^)#\s]+\.md)(#[^)]*)?\)', open(f).read()):
    if not os.path.exists(m.group(1)): print('ROTO ->',m.group(1))
print('ok')
PY

