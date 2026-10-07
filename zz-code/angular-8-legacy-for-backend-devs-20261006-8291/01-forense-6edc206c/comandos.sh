# Comandos Bash de la sesión 6edc206c-14b6-4874-8e4e-e3c76f720d90, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-08T00:57:19 · List prompts dir and line counts
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs && ls -la prompts/ && wc -l *.md prompts/*.md

# --- 2026-09-08T00:57:23 · Read README and scope
cat README.md && echo "=====ALCANCE=====" && cat prompts/alcance-del-proyecto.md

# --- 2026-09-08T00:57:27 · Read forensic analysis doc head
sed -n 1,140p analisis-forense-tutoriales.md

# --- 2026-09-08T00:57:29 · Read rest of forensic analysis doc
sed -n 140,491p analisis-forense-tutoriales.md

# --- 2026-09-08T00:57:34 · Skim style guide headings and forensic hooks
grep -n '^#\{1,2\} ' prompts/guia-de-estilo-y-convenciones.md prompts/plantillas-de-capitulo.md | head -80; echo "=== gancho ejemplo ==="; grep -n "forense-fase" *.md | head -30

# --- 2026-09-08T01:01:46 · Check Angular 16 forensic reference files
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs && ls && echo "---" && wc -l prompts/formato-piezas-forenses.md forense-master.md 2>/dev/null

# --- 2026-09-08T01:01:49 · Read Angular 16 forensic spec
cat prompts/formato-piezas-forenses.md

# --- 2026-09-08T01:01:51 · Read Angular 16 master and a sample piece
cat forense-master.md; echo "=====PIEZA EJEMPLO 01====="; cat forense-fase-01.md

# --- 2026-09-08T01:01:56 · Read incident notebook
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs && cat cuaderno-incidentes.md

# --- 2026-09-08T01:02:04 · Read style guide callouts and fiction coherence sections
sed -n '319,380p;538,640p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-08T01:02:09 · Read template section 8
sed -n '379,455p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-08T01:02:15 · Check chaos flag syntax
grep -n "CHAOS" 04-mock-api-caos.md | head -40

# --- 2026-09-08T01:03:32 · Extract section 6 of phases 0-3
for f in 00-setup-hola-mundo.md 01-estructura-base-ngrx.md 02-i18n.md 03-autenticacion.md; do echo "########## $f"; awk '/^## ⚠️ 6\./,/^## 🧪 7\./' $f | head -120; done

# --- 2026-09-08T01:03:39 · Extract forensic hooks of phases 4-7
for f in 04-mock-api-caos.md 05-pacientes.md 06-ordenes.md 07-muestras-custodia.md; do echo "########## $f"; awk '/^### Pieza forense/,/^## 🧪 7\./' $f; done

# --- 2026-09-08T01:03:46 · Extract section 6 of phases 8-14
for f in 08-resultados-rangos.md 09-entrega-pdf.md 10-dashboard.md 11-trazabilidad-audit-log.md 12-testing-coverage.md 13-build-despliegue.md 14-casi-prod-kind.md; do echo "########## $f"; awk '/^## ⚠️ 6\./,/^## 🧪 7\./' $f | sed -n '1,200p'; done

# --- 2026-09-08T01:03:58 · Check mentions of Angular DevTools
grep -rn "Angular DevTools" *.md | head; echo "--- ng.getComponent"; grep -rn "getComponent" *.md | head

# --- 2026-09-08T01:05:33 · Read phase 1 code section
awk '/^## 💻 5\./,/^## ⚠️ 6\./' 01-estructura-base-ngrx.md | sed -n '1,400p'

# --- 2026-09-08T01:05:42 · Read phase 1 sections 5.10+
awk '/^### 5\.10/,/^## ⚠️ 6\./' 01-estructura-base-ngrx.md

# --- 2026-09-08T01:06:06 · Find seed patient data
grep -n "fullName\|documentId\|db.json" 00-setup-hola-mundo.md | head -30

# --- 2026-09-08T01:06:09 · Find db.json seed structure
grep -n -A25 '"patients"' 00-setup-hola-mundo.md | head -40; echo "=== seed en fase 5 ==="; grep -n -B3 -A20 'db.json' 05-pacientes.md | grep -n "fullName" | head

# --- 2026-09-08T01:06:11 · Read patients seed data
sed -n '200,260p' 05-pacientes.md

# --- 2026-09-08T01:06:17 · Check phase 4 db.json seed
grep -n -B5 -A25 '"patients": \[' 04-mock-api-caos.md | head -60

# --- 2026-09-08T01:08:06 · Read phase 5 effects and form sections
awk '/^### 5\.8/,/^### 5\.11/' 05-pacientes.md | head -180

# --- 2026-09-08T01:08:21 · Read phase 5 section 5.10
awk '/^### 5\.10/,/^### 5\.12/' 05-pacientes.md | head -130

# --- 2026-09-08T01:08:27 · Check save button and phase 5 common errors
awk '/^### 5\.11/,/^## ⚠️ 6\./' 05-pacientes.md | grep -n "saving\|disabled\|mat-raised-button\|invalid" | head -20; echo "---- 6.x errores"; awk '/^## ⚠️ 6\./,/^### Pieza forense/' 05-pacientes.md | head -60

# --- 2026-09-08T01:08:33 · Find save button markup
grep -n "patientForm.invalid\|mat-dialog-actions\|saving" 05-pacientes.md | head

# --- 2026-09-08T01:08:36 · Read dialog actions markup
sed -n '1185,1210p' 05-pacientes.md

# --- 2026-09-08T01:09:01 · Check saving selector name and reducer cases
sed -n '495,510p;440,470p' 05-pacientes.md

# --- 2026-09-08T01:10:35 · Grep phase 7 key identifiers
grep -n "SAMPLE_TRANSITIONS\|canTransition\|Transition Sample\|custodyEvents\|CUSTODY" 07-muestras-custodia.md | head -40

# --- 2026-09-08T01:10:38 · Read phase 7 transitions, reducer, effect, custodyEvents
sed -n '175,215p;290,330p;400,470p;630,660p' 07-muestras-custodia.md

# --- 2026-09-08T01:12:30 · Read phase 4 chaos middleware
sed -n '200,345p' 04-mock-api-caos.md

# --- 2026-09-08T01:12:33 · Read chaos middleware body
sed -n '345,430p' 04-mock-api-caos.md

# --- 2026-09-08T01:12:44 · Find empty state message
grep -n "no hay pacientes\|emptyList\|patients.length" 04-mock-api-caos.md 05-pacientes.md 02-i18n.md | head

# --- 2026-09-08T01:12:47 · Read phase 4 component template and common errors
sed -n '595,660p' 04-mock-api-caos.md

# --- 2026-09-08T01:12:57 · Find error normalization code
grep -n -B5 -A20 "HTTP_500\|normalizeError\|messageKey" 04-mock-api-caos.md | sed -n '1,80p'

# --- 2026-09-08T01:14:59 · Grep phase 2 i18n identifiers
grep -n "LOCALE_ID\|registerLocaleData\|setDefaultLang\|use(\|httpLoaderFactory\|assets/i18n\|currentLang\|missing" 02-i18n.md | head -30

# --- 2026-09-08T01:15:02 · Read phase 2 translation files and service
sed -n '218,260p;405,480p;735,760p' 02-i18n.md

# --- 2026-09-08T01:15:05 · Check fr.json content and timezone
grep -n "fr.json\|en.json\|pendingOrders_zero\|timeZone\|America/Bogota" 02-i18n.md | head -20

# --- 2026-09-08T01:15:07 · Read fr.json content
sed -n '276,318p' 02-i18n.md

# --- 2026-09-08T01:16:43 · Read phase 6 intro and selectors
sed -n '1,60p' 06-ordenes.md; echo "=== 5.1 ==="; awk '/^### 5\.1/,/^### 5\.3/' 06-ordenes.md | head -80

# --- 2026-09-08T01:16:49 · Read phase 6 common errors and remaining code
awk '/^## ⚠️ 6\./,/^### Pieza forense/' 06-ordenes.md; echo "=== 5.3-5.5 ==="; awk '/^### 5\.3/,/^## ⚠️ 6\./' 06-ordenes.md | head -70

# --- 2026-09-08T01:18:02 · Read phase 0 component code
sed -n '360,440p' 00-setup-hola-mundo.md

# --- 2026-09-08T01:19:15 · Grep phase 11 audit identifiers
grep -n "buildEntry\|auditLog\|entityId\|entityType\|actor\|Log Entry" 11-trazabilidad-audit-log.md | head -40

# --- 2026-09-08T01:19:18 · Read phase 11 model, effect and buildEntry
sed -n '100,135p;290,320p;354,440p' 11-trazabilidad-audit-log.md

# --- 2026-09-08T01:20:53 · Grep phase 9 pdf identifiers
grep -n "reportSnapshot\|onGenerate\|take(1)\|jsPDF\|registerLatinFont" 09-entrega-pdf.md | head -30

# --- 2026-09-08T01:20:56 · Read report component
sed -n '196,300p' 09-entrega-pdf.md

# --- 2026-09-08T01:22:09 · Grep phase 8 key identifiers
grep -n "selectActiveRange\|effectiveFrom\|getTime\|sourceMap\|source map\|hidden" 08-resultados-rangos.md | head -30

# --- 2026-09-08T01:22:12 · Read selectActiveRange and callers
sed -n '226,290p;700,735p;890,915p' 08-resultados-rangos.md

# --- 2026-09-08T01:22:17 · Check source map build config mentions
grep -rn "sourceMap\|source-map\|outputHashing" 08-resultados-rangos.md 13-build-despliegue.md a04-webpack-oculto.md | head -20

# --- 2026-09-08T01:22:20 · Read A04 source maps section and project name
sed -n '300,345p' a04-webpack-oculto.md; grep -n "clinical-lab\|dist/" 13-build-despliegue.md | head -5

# --- 2026-09-08T01:23:51 · Grep phase 3 auth identifiers
grep -n "request-id\|requestId\|X-Request\|lab_clinico_token\|isExpired\|getCurrentUser" 03-autenticacion.md | head -25

# --- 2026-09-08T01:23:56 · Find request-id across course
grep -rn "request-id\|requestId\|X-Request" *.md | grep -v analisis-forense | grep -v forense-fase | head

# --- 2026-09-08T01:24:16 · Read phase 3 mock and interceptor
sed -n '330,420p' 03-autenticacion.md; echo "=== interceptor ==="; grep -n -A25 "class AuthInterceptor" 03-autenticacion.md | head -40

# --- 2026-09-08T01:24:21 · Check phase 3 mock server and isExpired
grep -n "auth.js\|express\|app.post('/login'\|console.log" 03-autenticacion.md | head -15; sed -n '230,320p' 03-autenticacion.md | grep -n "isExpired" -A15

# --- 2026-09-08T01:24:29 · Read phase 3 server.js
sed -n '130,185p' 03-autenticacion.md

# --- 2026-09-08T01:26:18 · Read phase 10 section 5.7
awk '/^### 5\.7/,/^## ⚠️ 6\./' 10-dashboard.md | head -110

# --- 2026-09-08T01:26:26 · Read dashboard component subscriptions
awk '/^### 5\.3/,/^### 5\.4/' 10-dashboard.md | head -60

# --- 2026-09-08T01:27:48 · Read phase 12 test examples
awk '/^### 5\.2/,/^### 5\.3/' 12-testing-coverage.md | head -70; echo "=== 5.5 ==="; awk '/^### 5\.5/,/^### 5\.6/' 12-testing-coverage.md | head -60

# --- 2026-09-08T01:29:17 · Grep phase 13 deployment identifiers
grep -n "config.json\|envsubst\|entrypoint\|API_URL\|FEATURE_\|try_files" 13-build-despliegue.md | head -30

# --- 2026-09-08T01:29:20 · Read config template and entrypoint
sed -n '100,120p;395,470p' 13-build-despliegue.md

# --- 2026-09-08T01:30:55 · Grep phase 14 kubectl commands
grep -n "kind create\|kind load\|kubectl \|lab-cluster\|namespace" 14-casi-prod-kind.md | head -30

# --- 2026-09-08T01:32:34 · Verify piece sizes and link integrity
wc -l forense-*.md && echo "--- ENLACES ---" && grep -oh "forense-fase-[0-9]*\.md\|forense-master\.md" *.md | sort -u | while read f; do [ -f "$f" ] || echo "ENLACE ROTO: $f"; done; echo "(sin salida = todo resuelve)"

# --- 2026-09-08T01:32:55 · Read README section on organization
sed -n '95,125p' README.md

# --- 2026-09-08T01:33:06 · Update README for completed forensic track
python3 - <<'PY'
import re, io
p='README.md'
s=open(p, encoding='utf-8').read()

old_bullet = """- `forense-fase-NN.md` — el paso a paso de la pieza forense de cada fase. Cada
  fase deja el gancho en su sección 6 y el desarrollo vive acá."""
new_bullet = """- `forense-master.md` — la puerta del track forense: el método de cuatro
  preguntas, el índice de síntomas transversal —el que se consulta cuando no
  sabes de qué fase es tu problema— y en qué miente cada herramienta.
- `forense-fase-NN.md` — el paso a paso de la pieza forense de cada fase. Cada
  fase deja el gancho en su sección 6 y el desarrollo vive acá."""
assert old_bullet in s
s = s.replace(old_bullet, new_bullet)

old_tail = """trece apéndices están completos**. Faltan las catorce piezas forenses
—`forense-fase-00.md` a `forense-fase-13.md`, más la opcional `forense-fase-14.md`—
y los veintiún enunciados del cuaderno de incidentes, cuyos IDs ya están reservados.
Cada fase deja el gancho y el enlace, así que esos son los únicos enlaces del
curso que todavía no resuelven."""
new_tail = """trece apéndices están completos**, y también el track forense: `forense-master.md`
y las quince piezas, de `forense-fase-00.md` a `forense-fase-14.md`. Falta una sola
cosa: los veintiún enunciados del cuaderno de incidentes, cuyos IDs ya están
reservados por las fases que los producen. Es el único enlace del curso que todavía
no resuelve."""
assert old_tail in s
s = s.replace(old_tail, new_tail)

old_prompts = """- `prompts/` — documentos de encuadre: alcance, propuesta de fases, guía de
  estilo y plantillas. Se leen antes de escribir o editar cualquier fase."""
new_prompts = """- `prompts/` — documentos de encuadre: alcance, propuesta de fases, guía de
  estilo, plantillas y el formato de las piezas forenses. Se leen antes de
  escribir o editar cualquier fase."""
assert old_prompts in s
s = s.replace(old_prompts, new_prompts)
open(p,'w',encoding='utf-8').write(s)
print("ok")
PY

# --- 2026-09-08T01:33:14 · Verify no links to disposable analysis doc
grep -l "analisis-forense" forense-*.md prompts/formato-piezas-forenses.md README.md 2>/dev/null; echo "(vacío = ningún archivo nuevo lo enlaza)"; echo "--- archivos nuevos ---"; git status --short

# --- 2026-09-08T03:33:56 · Extract appendix references from forensic pieces
echo "=== REFERENCIAS A APENDICES DESDE PIEZAS FORENSES ===" && grep -oh "A0[1-9] §[0-9.]*\|A1[0-3] §[0-9.]*\|Apéndice A[0-9]*\|\*\*A0[1-9]\*\*\|\*\*A1[0-3]\*\*" forense-*.md | sort | uniq -c | sort -rn

# --- 2026-09-08T03:34:00 · List all cross-references per forensic file
for f in forense-*.md; do echo "### $f"; grep -on "A0[1-9] §[0-9.]*\|A1[0-3] §[0-9.]*\|Apéndice A[0-9]*\( §[0-9.]*\)\?\|\*\*A0[1-9]\*\*\|\*\*A1[0-3]\*\*\|§[0-9.]\+ de la [Gg]uía\|ejercicio [0-9]\+\|Fase [0-9]\+ §[0-9.]*" $f | head -20; done

# --- 2026-09-08T03:34:07 · List headings of referenced appendices
for f in a03-node-npm.md a04-webpack-oculto.md a05-rxjs.md a06-ngrx.md a07-i18n.md a08-pdf-cliente.md a09-kubernetes.md a12-arm64-m1.md a13-docker-colima.md; do echo "### $f"; grep -n "^## \|^### " $f | head -30; done

# --- 2026-09-08T03:34:23 · Check existing markdown link conventions
echo "=== links markdown en fases hacia apéndices/fases ==="; grep -oh "\[\`\?[^]]*\`\?\](\.\?/\?[a-z0-9][^)]*\.md[^)]*)" 0*.md 1*.md a0*.md a1*.md | sort | uniq -c | sort -rn | head -40

# --- 2026-09-08T03:34:42 · Compare exercise counts vs references
echo "=== nº de ejercicios por fase ==="; grep -h "^## 🧪 7\. Ejercicios" 0*.md 1*.md; echo; echo "=== ejercicios referenciados por piezas ==="; for f in forense-*.md; do echo -n "$f: "; grep -oh "ejercicio [0-9]\+" $f | tr '\n' ' '; echo; done

# --- 2026-09-08T03:34:49 · Map exercise counts to phases
grep -H "^## 🧪 7\. Ejercicios" 0*.md 1*.md | sed 's/:## 🧪 7\./ →/'

# --- 2026-09-08T03:35:06 · Inspect phase 5 exercises
awk '/^## 🧪 7\./,/^## 📚 8\./' 05-pacientes.md | grep -n "^3[0-9]\.\|^2[5-9]\." | head; echo "=== busca catchError/validador en ejercicios fase 5 ==="; awk '/^## 🧪 7\./,/^## 📚 8\./' 05-pacientes.md | grep -n "validador\|catchError" | head

# --- 2026-09-08T03:35:26 · Extract incident references from all files
for f in 0*.md 1*.md a*.md forense-*.md; do ids=$(grep -oh "incidente[s]* \*\*\?[0-9]\+\*\*\?\|incidente[s]* [0-9]\+\|\*\*incidente[s]* [0-9]\+\*\*\|\*\*[0-9]\+\*\* —" $f 2>/dev/null | grep -oh "[0-9]\+" | sort -un | tr '\n' ' '); [ -n "$ids" ] && echo "$f: $ids"; done

# --- 2026-09-08T03:35:35 · Inspect suspicious incident references in phases
grep -n "incidente 07\|incidente 10\|incidente 16\|incidente 09\|incidente 12" 05-pacientes.md 07-muestras-custodia.md 08-resultados-rangos.md 10-dashboard.md 11-trazabilidad-audit-log.md 12-testing-coverage.md 09-entrega-pdf.md | cut -c1-230

# --- 2026-09-08T03:36:08 · Check appendix mentions and reference-section promises
echo "=== apéndices que mencionan el track forense ==="; grep -n "forense" a*.md | cut -c1-160; echo; echo "=== promesas de §8 Referencias sobre las piezas ==="; grep -n "forense-fase" 0*.md 1*.md | grep -i "doc\|enlaz\|checklist\|referencia" | cut -c1-260

# --- 2026-09-08T03:36:18 · Get reference URLs from phases 8 and 10
awk '/^## 📚 8\./,/^## 🚀 9\./' 08-resultados-rangos.md | grep -n "http" | cut -c1-200; echo "=== fase 10 ==="; awk '/^## 📚 8\./,/^## 🚀 9\./' 10-dashboard.md | grep -n "http" | cut -c1-200

# --- 2026-09-08T03:36:27 · Find source map and heap snapshot doc URLs
grep -n "http" a04-webpack-oculto.md | grep -i "map\|source" | cut -c1-200; echo "=== heap/memory ==="; grep -rn "developer.chrome.com\|heap" a*.md 1*.md | grep http | cut -c1-200 | head

# --- 2026-09-08T03:36:49 · Count phase references per file
echo "=== ocurrencias de 'Fase N' por archivo (piezas) ==="; for f in forense-*.md; do echo -n "$f: "; grep -oh "\*\*Fase [0-9]\+\*\*\|Fase [0-9]\+" $f | wc -l; done; echo; echo "=== 'Fase N' en apéndices ==="; for f in a*.md; do echo -n "$f: "; grep -oh "\*\*Fase [0-9]\+\*\*\|Fase [0-9]\+" $f | wc -l; done

# --- 2026-09-08T03:37:07 · Compare phase titles with piece headers
echo "=== títulos de fase ==="; head -1 0[0-9]-*.md 1[0-4]-*.md | grep -v "^==" | grep . ; echo; echo "=== encabezados de las piezas ==="; grep -h "^> Pieza forense de la" forense-fase-*.md

# --- 2026-09-08T03:37:27 · Verify the seven blocks in each piece
for f in forense-fase-*.md; do printf "%-22s" "$f"; for b in "## 🎫" "## 🧭" "## 🩺" "## ⚰️" "## 🧨" "## 🧠"; do grep -q "^$b" $f && printf "%s " "${b#\#\# }" || printf "FALTA:%s " "${b#\#\# }"; done; echo; done

# --- 2026-09-08T03:37:37 · Lint regionalisms in new files
grep -n "ordenador\|vosotros\|\bvos \|deberíais\|podéis\|Track A\|tenés\|querés" forense-*.md prompts/formato-piezas-forenses.md | head; echo "(vacío arriba = sin regionalismos)"; echo "=== chequeo de acentos/comillas raras ==="; grep -c "" forense-master.md

# --- 2026-09-08T03:37:40 · Locate phase 5 exercise references
grep -n "ejercicio 30\|ejercicio 34\|ejercicio 26" 05-pacientes.md | cut -c1-220

# --- 2026-09-08T03:37:44 · Check phase 5 exercise 26 and context
sed -n '25p;64p' 05-pacientes.md | cut -c1-400; echo "---"; awk '/^## 🧪 7\./,/^## 📚 8\./' 05-pacientes.md | grep -n "^2[0-9]\." | head -8

# --- 2026-09-08T03:37:53 · Fix broken exercise references
python3 - <<'PY'
import re
# Fase 5: tres referencias a ejercicios que no corresponden.
p='05-pacientes.md'; s=open(p,encoding='utf-8').read()
reps=[("(ese es el bug del ejercicio 30)","(ese es el bug del ejercicio 26)"),
      ("Eso es el ejercicio 30 y es un bug real","Eso es el ejercicio 26 y es un bug real"),
      ("está discutido en el ejercicio 34.","está discutido en el ejercicio 30."),
      ("<!-- El bug del ejercicio 30 está en la línea de abajo","<!-- El bug del ejercicio 26 está en la línea de abajo")]
for a,b in reps:
    assert s.count(a)==1, (a, s.count(a))
    s=s.replace(a,b)
open(p,'w',encoding='utf-8').write(s)

# La pieza heredó el número roto.
p='forense-fase-05.md'; s=open(p,encoding='utf-8').read()
a="está discutida en el ejercicio 34 de la fase"; b="está discutida en el ejercicio 30 de la fase"
assert s.count(a)==1
open(p,'w',encoding='utf-8').write(s.replace(a,b))
print("ok")
PY

# --- 2026-09-08T03:38:05 · Locate insertion point in piece 13
grep -n "^## 🧨 Deshacer" -A3 forense-fase-13.md | head -8; echo "..."; grep -n "^## 🧠" forense-fase-13.md

# --- 2026-09-08T03:38:23 · Add promised one-page checklist to piece 13
python3 - <<'PY'
p='forense-fase-13.md'; s=open(p,encoding='utf-8').read()
anchor="## 🧠 El patrón transferible"
assert s.count(anchor)==1
nuevo = '''## 🧾 El checklist de una página — cierre del track

Ésta es la última pieza del track, y le toca dejar el único artefacto que se lleva al trabajo real. No es un archivo nuevo del proyecto: es una página que escribes tú, y que la **retrospectiva del mes** de [`cuaderno-incidentes.md`](cuaderno-incidentes.md) te pide reescribir con lo que aprendiste. Acá está la versión de partida, destilada de los quince recorridos.

**Antes de escribir código**

1. ¿Se reproduce, y con qué? Un flag del caos, un dato, u otro código. Si no se reproduce, no hay fix: hay una hipótesis.
2. ¿Qué dice la evidencia observable —consola, Network, log de acciones— antes que el código?
3. ¿En qué capa está? Plantilla, componente, selector, reducer, effect, interceptor, mock, build, contenedor.
4. 🧬 ¿Lo escribió el sistema, o llegó ya roto en el dato?

**Al escribir el fix**

5. Escribe primero el test que falla por la misma razón que el usuario sufre, y **míralo en rojo**.
6. Distingue el parche mínimo de la refactorización correcta, y di en voz alta cuál estás haciendo.
7. Si el fix cambia el comportamiento de más de una pantalla, ya no es un hotfix: es un ticket con fecha.

**Antes de desplegar**

8. ¿Qué configuración recibe cada ambiente al arrancar, y son la misma imagen?
9. ¿Hay un feature flag que permita apagar esto sin desplegar? Si lo hay, decide antes si lo vas a usar.
10. ¿Qué se rompe si esto sale mal, y cómo lo revierto? `rollout undo`, el flag, o el tag anterior.

**Después de desplegar**

11. Comprueba en el ambiente real lo mismo que comprobaste en el tuyo, y por la misma vía (`config.json` en Network, no "parece que va bien").
12. Cierra con el **post-mortem de ocho puntos** y el par de tags `inc/<ID>/…-roto` / `-fix`, que dejan el `git diff` del fix aislado del ruido de la fase.

> 🧭 **El árbol de decisión, en tres preguntas.** ¿El sistema está en riesgo ahora mismo? → contén con el flag o revierte, y diagnostica después. ¿Está estable pero equivocado? → diagnostica primero, parchea con lo mínimo, y abre el ticket del fix correcto. ¿Está estable y no sabes si es un bug? → no toques nada hasta poder reproducirlo; un fix sobre un síntoma que no reproduces es un cambio a ciegas.

---

'''
open(p,'w',encoding='utf-8').write(s.replace(anchor, nuevo+anchor))
print("ok 13")
PY

# --- 2026-09-08T03:38:42 · Add promised external doc links to pieces 8 and 10
python3 - <<'PY'
# Pieza 08: la fase promete "la doc de source maps enlazada en forense-fase-08.md"
p='forense-fase-08.md'; s=open(p,encoding='utf-8').read()
a="**Amplía:** el **Apéndice A04 §6** para las cuatro claves de `sourceMap` y por qué `hidden` existe, y [`forense-fase-13.md`](./forense-fase-13.md) para cuando el artefacto desplegado no sea el que crees, que es la versión grande de este mismo desfase."
b = """**Amplía:** el [**Apéndice A04 §6**](./a04-webpack-oculto.md) para las cuatro claves de `sourceMap` y por qué `hidden` existe, y [`forense-fase-13.md`](./forense-fase-13.md) para cuando el artefacto desplegado no sea el que crees, que es la versión grande de este mismo desfase.

**📚 La documentación de source maps**, que es la que la §8 de la fase te manda a buscar acá:

- https://developer.chrome.com/docs/devtools/javascript/source-maps — cómo DevTools resuelve un `.map`, dónde lo busca y qué hace cuando no lo encuentra. ⚠️ Enlace no verificado al cierre; si la ruta cambió, busca *"source maps"* en la documentación de Chrome DevTools.
- https://sourcemaps.info/spec.html — la especificación del formato, para leer el `"file"` y el `"sources"` de un `.map` sabiendo qué significan. Se consulta una vez en la vida y es la que convierte el paso 2 en algo que puedes explicar.
- https://v8.angular.io/cli/build — las opciones de build del CLI 8, incluida `sourceMap`. ⚠️ Enlace no verificado al cierre; si `v8.angular.io` no responde, la alternativa es el `ng build --help` de tu propia instalación, que es la fuente exacta de tu versión."""
assert s.count(a)==1
open(p,'w',encoding='utf-8').write(s.replace(a,b))

# Pieza 10: la fase promete "la doc de ChangeDetectionStrategy y el heap snapshot enlazados en forense-fase-10.md"
p='forense-fase-10.md'; s=open(p,encoding='utf-8').read()
a="**Amplía:** el **Apéndice A05** para `takeUntil`, el `async` pipe y por qué un `Subject` de destrucción cierra todo a la vez, y el **Apéndice A06** para cómo funciona la memoización de `createSelector` y qué la rompe."
b = """**Amplía:** el [**Apéndice A05**](./a05-rxjs.md) para `takeUntil`, el `async` pipe y por qué un `Subject` de destrucción cierra todo a la vez, y el [**Apéndice A06**](./a06-ngrx.md) para cómo funciona la memoización de `createSelector` y qué la rompe.

**📚 Las dos referencias que la §8 de la fase te manda a buscar acá:**

- https://developer.chrome.com/docs/devtools/memory-problems/heap-snapshots — cómo se toma un heap snapshot, qué significan las columnas *Shallow size* y *Retained size*, y cómo se lee la vista **Comparison** del paso 5. ⚠️ Enlace no verificado al cierre; si la ruta cambió, busca *"heap snapshot"* en la documentación de Chrome DevTools.
- https://v8.angular.io/api/core/ChangeDetectionStrategy — `OnPush` y el ciclo de detección de cambios, en la versión del curso. ⚠️ Enlace no verificado al cierre; si `v8.angular.io` no responde, la alternativa es `angular.io` marcando la versión 8 en el selector, con la advertencia de que la página por defecto documenta versiones posteriores."""
assert s.count(a)==1
open(p,'w',encoding='utf-8').write(s.replace(a,b))
print("ok 08 y 10")
PY

# --- 2026-09-08T03:39:02 · Count bold phase refs and master table rows
grep -oh "\*\*Fase [0-9]\+\*\*" forense-*.md | sort | uniq -c; echo "=== en líneas de tabla del master ==="; grep -c "^|.*Fase [0-9]" forense-master.md

# --- 2026-09-08T03:39:15 · Link appendix and bold phase references in pieces
python3 - <<'PY'
import re, glob

FASE = {0:'00-setup-hola-mundo.md',1:'01-estructura-base-ngrx.md',2:'02-i18n.md',3:'03-autenticacion.md',
        4:'04-mock-api-caos.md',5:'05-pacientes.md',6:'06-ordenes.md',7:'07-muestras-custodia.md',
        8:'08-resultados-rangos.md',9:'09-entrega-pdf.md',10:'10-dashboard.md',11:'11-trazabilidad-audit-log.md',
        12:'12-testing-coverage.md',13:'13-build-despliegue.md',14:'14-casi-prod-kind.md'}
AP = {1:'a01-material.md',2:'a02-bootstrap-sass.md',3:'a03-node-npm.md',4:'a04-webpack-oculto.md',
      5:'a05-rxjs.md',6:'a06-ngrx.md',7:'a07-i18n.md',8:'a08-pdf-cliente.md',9:'a09-kubernetes.md',
      10:'a10-migracion-8-9.md',11:'a11-migracion-9-16.md',12:'a12-arm64-m1.md',13:'a13-docker-colima.md'}

def link_apendices(s):
    # **Apéndice A06 §9.4** / **Apéndice A06** / **A06 §6** / **A06**  -> enlazados
    def rep(m):
        pre = m.group(0)
        n = int(m.group('n'))
        return '[%s](./%s)' % (pre, AP[n])
    pat = re.compile(r'(?<!\[)\*\*(?:Apéndice )?A(?P<n>0[1-9]|1[0-3])(?: §[0-9.]+(?: y §[0-9.]+)?)?\*\*')
    return pat.sub(rep, s)

def link_fase_bold(s):
    def rep(m):
        n = int(m.group('n'))
        return '[%s](./%s)' % (m.group(0), FASE[n])
    return re.sub(r'(?<!\[)\*\*Fase (?P<n>1[0-4]|[0-9])\*\*', rep, s)

cambios = {}
for f in sorted(glob.glob('forense-fase-*.md')) + ['forense-master.md', 'prompts/formato-piezas-forenses.md']:
    s0 = open(f, encoding='utf-8').read()
    pref = '../' if f.startswith('prompts/') else './'
    s = link_apendices(s0).replace('](./', '](%s' % pref) if pref != './' else link_apendices(s0)
    s = link_fase_bold(s)
    if s != s0:
        open(f,'w',encoding='utf-8').write(s)
        cambios[f] = len(re.findall(r'\]\(\.\.?/a\d\d|\]\(\.\.?/\d\d-', s)) - len(re.findall(r'\]\(\.\.?/a\d\d|\]\(\.\.?/\d\d-', s0))
for k,v in cambios.items(): print(f"{k}: +{v} enlaces")
PY

# --- 2026-09-08T03:39:26 · Verify link integrity after linking pass
grep -n "](\.\.\?/" prompts/formato-piezas-forenses.md; echo "=== doble enlace? ==="; grep -n "\[\[\|\](.*)\](" forense-*.md prompts/formato-piezas-forenses.md | head; echo "=== enlaces rotos ==="; grep -oh "](\.\{0,3\}/\?[a-z0-9][^)]*\.md)" forense-*.md prompts/formato-piezas-forenses.md | tr -d '()]' | sed 's|^\./||' | sort -u | while read f; do t="$f"; case "$f" in ../*) t="${f#../}"; [ -f "../$t" ] || [ -f "$t" ] || echo "ROTO: $f";; *) [ -f "$t" ] || echo "ROTO: $f";; esac; done; echo "(sin ROTO = ok)"

# --- 2026-09-08T03:39:46 · Fix and link the master index
python3 - <<'PY'
import re
FASE = {0:'00-setup-hola-mundo.md',1:'01-estructura-base-ngrx.md',2:'02-i18n.md',3:'03-autenticacion.md',
        4:'04-mock-api-caos.md',5:'05-pacientes.md',6:'06-ordenes.md',7:'07-muestras-custodia.md',
        8:'08-resultados-rangos.md',9:'09-entrega-pdf.md',10:'10-dashboard.md',11:'11-trazabilidad-audit-log.md',
        12:'12-testing-coverage.md',13:'13-build-despliegue.md',14:'14-casi-prod-kind.md'}
p='forense-master.md'; s=open(p,encoding='utf-8').read()

# 1. La fila 1 del indice no coincidia con el ticket de la pieza.
a='| 1 | "Le di a guardar dos veces porque no pasaba nada" | Redux DevTools: Actions · Diff · time-travel | `forense-fase-01.md` |'
b='| 1 | "Cambié el paciente y la lista no se entera" | Redux DevTools: Actions · Diff · time-travel | `forense-fase-01.md` |'
assert s.count(a)==1; s=s.replace(a,b)

# 2. Enlazar los nombres de archivo del indice §2.
s = re.sub(r'`(forense-fase-(\d\d)\.md)`(?= \|)', lambda m: '[`%s`](%s)' % (m.group(1), m.group(1)), s)

# 3. Enlazar "Fase N" dentro de las filas de tabla (el indice de sintomas es navegacion pura).
def link_rows(line):
    if not line.startswith('|'): return line
    return re.sub(r'(?<!\[)\bFase (1[0-4]|[0-9])\b', lambda m: '[Fase %s](%s)' % (m.group(1), FASE[int(m.group(1))]), line)
s = '\n'.join(link_rows(l) for l in s.split('\n'))

# 4. El cierre remite tambien al checklist de una pagina, que vive en la pieza 13.
a = "Ese post-mortem es lo único de todo el track que sirve tal cual en un sistema que no es LabCore. El resto es entrenamiento para poder escribirlo."
b = ("Y hay un segundo artefacto, más corto y más operativo: **el checklist de una página** de "
     "[`forense-fase-13.md`](forense-fase-13.md) §🧾, con sus cuatro momentos —antes de escribir código, al escribir el fix, "
     "antes de desplegar, después de desplegar—. El master no lo duplica; la pieza 13 lo escribe y la retrospectiva del "
     "cuaderno te pide reescribirlo con lo que aprendiste.\n\n"
     "Esos dos son lo único de todo el track que sirve tal cual en un sistema que no es LabCore. El resto es entrenamiento para poder escribirlos.")
assert s.count(a)==1; s=s.replace(a,b)
open(p,'w',encoding='utf-8').write(s)
print("master ok")
PY
grep -c "](0\|](1\|](a0\|](a1\|](forense" forense-master.md

# --- 2026-09-08T03:39:52 · Find plain-text piece mentions in phases
grep -n "\`forense-fase-[0-9]*\.md\`" 0*.md 1*.md | grep -v "](" | cut -c1-120

# --- 2026-09-08T03:40:00 · Link piece mentions in phases
python3 - <<'PY'
import re, glob
total=0
for f in sorted(glob.glob('0[0-9]-*.md')+glob.glob('1[0-4]-*.md')):
    s0=open(f,encoding='utf-8').read()
    # Enlaza solo las menciones en texto plano; respeta las que ya son enlace.
    s=re.sub(r'(?<!\[)`(forense-fase-\d\d\.md)`(?!\]|\))',
             lambda m: '[`%s`](./%s)' % (m.group(1), m.group(1)), s0)
    # Las que ya iban en negrita dentro de la lista de referencias.
    s=re.sub(r'\*\*`(forense-fase-\d\d\.md)`\*\*(?!\])',
             lambda m: '**[`%s`](./%s)**' % (m.group(1), m.group(1)), s)
    if s!=s0:
        n=len(re.findall(r'\]\(\./forense',s))-len(re.findall(r'\]\(\./forense',s0))
        total+=n; open(f,'w',encoding='utf-8').write(s); print(f"{f}: +{n}")
print("total", total)
PY
echo "=== verificación: menciones sin enlace que queden ==="; grep -c "\`forense-fase-[0-9]*\.md\`" 0*.md 1*.md 2>/dev/null | grep -v ":0"; grep -n "\`forense-fase-[0-9]*\.md\`" 0*.md 1*.md | grep -v "](" | wc -l

# --- 2026-09-08T03:40:12 · Inspect appendix insertion points
sed -n '306,312p' a04-webpack-oculto.md; echo "---a05 210"; sed -n '210,214p;348,353p' a05-rxjs.md; echo "---a06 370 481"; sed -n '370,374p;481,485p' a06-ngrx.md; echo "---a07 369"; sed -n '369,373p' a07-i18n.md; echo "---a08 241"; sed -n '241,246p' a08-pdf-cliente.md; echo "---a09 296"; sed -n '296,300p' a09-kubernetes.md; echo "---a12 203"; sed -n '203,207p' a12-arm64-m1.md; echo "---a13 319"; sed -n '319,323p' a13-docker-colima.md

# --- 2026-09-08T03:40:33 · Add track pointers to appendices
python3 - <<'PY'
ins = [
 ('a04-webpack-oculto.md',
  "Un source map es un archivo `.map` que traduce una posición del bundle minificado",
  "> 🕵️ **El recorrido de un source map que miente** —el desfase entre el `.map` y el bundle que sirve producción, y su firma: un breakpoint que no dispara sobre código que sí corre— está en [`forense-fase-08.md`](forense-fase-08.md). Acá está el mecanismo; allá, la investigación.\n\n"),
 ('a05-rxjs.md',
  "**La sección central de este apéndice.** Los dos hacen lo mismo:",
  "> 🕵️ **El bug que produce esta decisión, perseguido de punta a punta**, está en [`forense-fase-05.md`](forense-fase-05.md) —desde el lado de la aplicación— y en [`forense-fase-12.md`](forense-fase-12.md) —desde el lado del test que no lo caza—.\n\n"),
 ('a05-rxjs.md',
  "Un observable no hace **nada** hasta que alguien se suscribe.",
  "> 🕵️ **Cómo se ve un connection leak desde el navegador** —contar antes de medir, y el heap snapshot sólo al final— está en [`forense-fase-10.md`](forense-fase-10.md).\n\n"),
 ('a06-ngrx.md',
  "La extensión Redux DevTools es la herramienta de diagnóstico más rentable",
  "> 🕵️ **El recorrido completo con las tres pestañas** —Actions, Diff y el deslizador, y lo que el time-travel **no** deshace— está en [`forense-fase-01.md`](forense-fase-01.md).\n\n"),
 ('a07-i18n.md',
  "Lo que hace `@ngx-translate` 11 cuando no encuentra una clave, en orden:",
  "> 🕵️ **Las cuatro causas de una clave en crudo, en su orden de descarte**, están en [`forense-fase-02.md`](forense-fase-02.md), junto con la fecha que no cambia de idioma, que es otro sistema y otro bug.\n\n"),
 ('a08-pdf-cliente.md',
  "La **Fase 9 §4** da la intuición",
  "> 🕵️ **El árbol de descarte aplicado a un PDF concreto** —acentos rotos sólo en el encabezado frente a rotos en todo el documento— está en [`forense-fase-09.md`](forense-fase-09.md) §Paso 5.\n\n"),
 ('a09-kubernetes.md',
  "Lo que un dev de front recibe casi nunca es un YAML:",
  "> 🕵️ **Qué comando contesta qué pregunta** —`describe` si nunca llegó a `Running`, `logs --previous` si arrancó y murió— está desarrollado en [`forense-fase-14.md`](forense-fase-14.md).\n\n"),
 ('a12-arm64-m1.md',
  "La tabla que de verdad se consulta, con el mensaje literal delante.",
  "> 🕵️ Si el síntoma no está acá, el índice de síntomas **transversal** del curso —el que cruza \"esto es lo que veo\" con \"empieza acá\"— está en [`forense-master.md`](forense-master.md) §3.\n\n"),
 ('a13-docker-colima.md',
  "## 9. 🩺 Diagnóstico por síntoma\n",
  "\n> 🕵️ Si el síntoma no está acá, el índice de síntomas **transversal** del curso está en [`forense-master.md`](forense-master.md) §3, y el pod que no arranca en [`forense-fase-14.md`](forense-fase-14.md).\n"),
 ('a03-node-npm.md',
  "## 1. Qué versión estás mirando\n",
  "\n> 🕵️ Los errores de arranque de esta familia —`ERR_OSSL_EVP_UNSUPPORTED` y compañía— aparecen en el índice de síntomas de [`forense-master.md`](forense-master.md) §3, que dice a qué apéndice o fase manda cada uno.\n"),
]
for f, anchor, block in ins:
    s=open(f,encoding='utf-8').read()
    assert s.count(anchor)==1, (f, anchor, s.count(anchor))
    if anchor.startswith('## '):
        s=s.replace(anchor, anchor+block)          # justo debajo del encabezado
    else:
        s=s.replace(anchor, block+anchor)          # justo antes del parrafo
    open(f,'w',encoding='utf-8').write(s)
    print("ok", f)
PY

# --- 2026-09-08T03:40:42 · Align piece subtitles with phase titles
python3 - <<'PY'
# Los subtitulos de las piezas citan el titulo de su fase: que coincida literal.
fix = {
 'forense-fase-00.md': ("**Fase 0 — Setup y hola mundo**", "**Fase 0 — Setup + hola mundo**"),
 'forense-fase-01.md': ("**Fase 1 — Estructura base y NgRx**", "**Fase 1 — Estructura base + NgRx**"),
 'forense-fase-04.md': ("**Fase 4 — Mock API y caos**", "**Fase 4 — Mock API + caos**"),
 'forense-fase-12.md': ("**Fase 12 — Testing desde cero y coverage**", "**Fase 12 — Testing desde cero + coverage**"),
}
for f,(a,b) in fix.items():
    s=open(f,encoding='utf-8').read(); assert s.count(a)==1, f
    open(f,'w',encoding='utf-8').write(s.replace(a,b)); print("ok",f)
PY
echo "=== subtítulos finales ==="; grep -h "^> Pieza forense de la" forense-fase-*.md | sed 's/ · Recorrido.*//' | sort

# --- 2026-09-08T03:40:54 · Link piece subtitles to phases and master
python3 - <<'PY'
import re, glob
FASE = {0:'00-setup-hola-mundo.md',1:'01-estructura-base-ngrx.md',2:'02-i18n.md',3:'03-autenticacion.md',
        4:'04-mock-api-caos.md',5:'05-pacientes.md',6:'06-ordenes.md',7:'07-muestras-custodia.md',
        8:'08-resultados-rangos.md',9:'09-entrega-pdf.md',10:'10-dashboard.md',11:'11-trazabilidad-audit-log.md',
        12:'12-testing-coverage.md',13:'13-build-despliegue.md',14:'14-casi-prod-kind.md'}
for f in sorted(glob.glob('forense-fase-*.md')):
    n=int(f[13:15]); s=open(f,encoding='utf-8').read()
    m=re.search(r'^> Pieza forense de la (\*\*Fase [^*]+\*\*)( 🔥)? · (Recorrido: [^\n]+)$', s, re.M)
    assert m, f
    nuevo = '> Pieza forense de la [%s](./%s)%s · %s · [Índice del track](./forense-master.md)' % (
        m.group(1), FASE[n], m.group(2) or '', m.group(3))
    s = s[:m.start()] + nuevo + s[m.end():]
    open(f,'w',encoding='utf-8').write(s)
print("ok")
PY
head -5 forense-fase-07.md; echo "..."; head -5 forense-fase-14.md

# --- 2026-09-08T03:41:05 · Full course link integrity check
echo "=== 1. Enlaces rotos en TODO el curso ==="
grep -oh "](\.\{0,2\}/\?[A-Za-z0-9_][^)#]*\.md)" *.md prompts/*.md | tr -d ')]' | sed 's|^\./||' | sort -u | while read f; do
  case "$f" in ../*) [ -f "${f#../}" ] || [ -f "$f" ] || echo "ROTO: $f";; *) [ -f "$f" ] || echo "ROTO: $f";; esac; done
echo "(sin ROTO = todo resuelve)"
echo; echo "=== 2. Cada fase enlaza su pieza y cada pieza su fase ==="
for n in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do
  fase=$(ls ${n}-*.md 2>/dev/null | head -1)
  a=$(grep -c "](\./forense-fase-${n}\.md)" "$fase"); b=$(grep -c "](\./${fase})" forense-fase-${n}.md)
  printf "fase %s → pieza:%s   pieza → fase:%s\n" "$n" "$a" "$b"; done
echo; echo "=== 3. Enlaces por archivo nuevo ==="
for f in forense-*.md prompts/formato-piezas-forenses.md; do printf "%-38s %s enlaces\n" "$f" "$(grep -o "](\.\{0,2\}/\?[A-Za-z0-9][^)]*\.md" $f | wc -l | tr -d ' ')"; done

# --- 2026-09-08T03:41:18 · Correct link integrity and bidirectional check
echo "=== enlaces rotos (bien contados) ==="
grep -oh "](\.\{0,2\}/\?[A-Za-z0-9_][^)#]*\.md)" *.md prompts/*.md | sed 's/^](//; s/)$//' | sort -u | while read f; do [ -f "$f" ] || echo "ROTO: $f"; done
echo "(sin ROTO = todo resuelve)"
echo; echo "=== fase ↔ pieza (mapeo correcto) ==="
for n in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do
  fase=$(ls ${n}-*.md | grep -v convencion | grep -v historia | head -1)
  a=$(grep -c "forense-fase-${n}\.md)" "$fase"); b=$(grep -c "${fase})" forense-fase-${n}.md)
  printf "%-32s pieza←fase:%s  fase←pieza:%s\n" "$fase" "$a" "$b"; done

# --- 2026-09-08T03:41:28 · Check template placeholder and cross-course links
grep -n "forense-fase-NN" prompts/formato-piezas-forenses.md | cut -c1-140; echo "=== docker-container-legacy refs ==="; grep -oh "\](\.\./docker-container-legacy[^)]*)" a*.md | sort -u | sed 's/^](//;s/)$//' | while read f; do [ -f "$f" ] && echo "OK  $f" || echo "ROTO $f"; done

# --- 2026-09-08T03:41:35 · Locate the NN placeholder link
grep -rn "](\./forense-fase-NN\.md)\|](forense-fase-NN\.md)" *.md prompts/*.md | cut -c1-160

# --- 2026-09-08T03:41:47 · Find all phases promising screenshots in the piece
grep -n "captura" 0*.md 1*.md | grep -i "forense\|desarrolla\|completa" | cut -c1-200

# --- 2026-09-08T03:41:57 · Fix spec claims and compare master index to piece titles
python3 - <<'PY'
p='prompts/formato-piezas-forenses.md'; s=open(p,encoding='utf-8').read()
a="""⚠️ Dos fases publicadas prometen "capturas" en su gancho —la 9 y la 13—. **Esa
palabra es un lapsus del gancho, no un contrato**: lo que la pieza entrega es esa
misma evidencia transcrita. Es el único punto donde la pieza no sigue la fase al
pie de la letra, y se resuelve dando más, no menos."""
b="""⚠️ Tres fases publicadas prometen "capturas" en su gancho o en sus referencias
—la **9**, la **13** y la **14**—. **Esa palabra es un lapsus del gancho, no un
contrato**: lo que la pieza entrega es esa misma evidencia transcrita. Es el único
punto donde la pieza no sigue la fase al pie de la letra, y se resuelve dando más,
no menos."""
assert s.count(a)==1; s=s.replace(a,b)

a2="""> fase anunció, ni más ni menos. Trece de las quince fases ya dejaron ese gancho
> escrito, así que el contenido de cada pieza está especificado antes de empezar."""
b2="""> fase anunció, ni más ni menos. Las quince fases dejaron ese gancho escrito antes
> de que existiera una sola pieza, así que el contenido de cada una estaba
> especificado antes de empezar a redactarla."""
assert s.count(a2)==1; s=s.replace(a2,b2)
open(p,'w',encoding='utf-8').write(s); print("spec ok")
PY
echo "=== índice §2 del master vs títulos de las piezas ==="
paste -d'|' <(grep "^| [0-9]* |" forense-master.md | cut -d'|' -f3 | sed 's/^ //;s/ $//') <(for n in 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14; do head -1 forense-fase-$n.md | sed 's/^# 🕵️ Forense Fase [0-9]* — //'; done) | head -16

# --- 2026-09-08T03:42:15 · Align master row and add cuaderno pointer; verify appendix insertions
python3 - <<'PY'
p='forense-master.md'; s=open(p,encoding='utf-8').read()
a="| 8 | El borde de vigencia que se resbala a UTC |"
b="| 8 | El borde de vigencia que se resbala a UTC · el mapa que miente |"
assert s.count(a)==1; open(p,'w',encoding='utf-8').write(s.replace(a,b))

# El cuaderno es el otro eje del curso y no menciona el track. Una puerta, no un resumen.
p='cuaderno-incidentes.md'; s=open(p,encoding='utf-8').read()
a="""Lees el ticket, reproduces, investigas, escribes tu diagnóstico en el bloque
"Tu investigación", y **recién entonces** abres la solución para compararla."""
b="""> 🕵️ **Si no sabes por dónde empezar, no empieces por el editor.** El índice de
> síntomas transversal —el que cruza *"esto es lo que veo"* con *"empieza acá"*— está
> en [`forense-master.md`](forense-master.md) §3, y cada fase tiene su recorrido
> completo en `forense-fase-NN.md`. El cuaderno te da el ticket; el track forense te
> da el método para atacarlo.

Lees el ticket, reproduces, investigas, escribes tu diagnóstico en el bloque
"Tu investigación", y **recién entonces** abres la solución para compararla."""
assert s.count(a)==1; open(p,'w',encoding='utf-8').write(s.replace(a,b))
print("ok")
PY
sed -n '306,312p' a04-webpack-oculto.md; echo "---"; sed -n '203,210p' a12-arm64-m1.md

# --- 2026-09-08T03:42:33 · Declare the forensic marker and spec in the style guide
python3 - <<'PY'
p='prompts/guia-de-estilo-y-convenciones.md'; s=open(p,encoding='utf-8').read()
a="""- 🧨 **Rompe a propósito.** Marca un experimento destructivo dentro de un apéndice,
  donde no hay una sección 6 que lo aloje como en las fases."""
b="""- 🧨 **Rompe a propósito.** Marca un experimento destructivo dentro de un apéndice,
  donde no hay una sección 6 que lo aloje como en las fases.
- 🕵️ **Track forense.** Encabeza `forense-master.md` y las quince piezas
  `forense-fase-NN.md`, y marca —en blockquote— el puntero desde un apéndice o desde
  el cuaderno hacia el recorrido que desarrolla lo que ahí se explica. Su formato
  completo está en `prompts/formato-piezas-forenses.md`; dentro de una pieza se
  usan además 🎫 (el ticket), ⚰️ (los callejones) y 🧬 (la pregunta propia del
  track: ¿lo escribió el sistema o llegó roto en el dato?)."""
assert s.count(a)==1; s=s.replace(a,b)

a2="""(4) esta guía —con `00-convencion-de-git-y-tags.md` como su anexo para todo lo
  que toque git, repos y tags—, (5) entregables ya aprobados de fases anteriores,"""
b2="""(4) esta guía —con `00-convencion-de-git-y-tags.md` como su anexo para todo lo
  que toque git, repos y tags, y `prompts/formato-piezas-forenses.md` como su anexo
  para el track forense—, (5) entregables ya aprobados de fases anteriores,"""
assert s.count(a2)==1, s.count(a2)
s=s.replace(a2,b2)
open(p,'w',encoding='utf-8').write(s); print("guía ok")
PY

# --- 2026-09-08T03:42:40 · Final integrity check and change summary
echo "=== enlaces rotos, curso completo ==="
grep -oh "](\.\{0,2\}/\?[A-Za-z0-9_][^)#]*\.md)" *.md prompts/*.md | sed 's/^](//; s/)$//' | sort -u > /tmp/l.txt
while read f; do case "$f" in ../*) [ -f "$f" ] || [ -f "${f#../}" ] || echo "ROTO $f";; *) [ -f "$f" ] || echo "ROTO $f";; esac; done < /tmp/l.txt
echo "(sin ROTO = ok · $(wc -l < /tmp/l.txt) destinos distintos)"
echo; echo "=== resumen de cambios ==="; git status --short | sed 's|^|  |'

# --- 2026-09-08T03:42:47 · Read final blocks to verify prose integrity
tail -6 forense-fase-01.md; echo "==="; tail -5 forense-fase-13.md; echo "==="; sed -n '/^## 5\. Cómo se cierra/,$p' forense-master.md

