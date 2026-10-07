# Comandos Bash de la sesión 70a2da9f-4377-4097-8175-04d5f3b7e008, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-10T19:23:53 · List prompts dir and file sizes
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs && ls -la prompts && wc -l *.md prompts/*.md | sort -n | tail -60

# --- 2026-09-10T19:23:56 · Read course README
cat README.md

# --- 2026-09-10T19:24:01 · Inspect incident logbook and backend proposal outline
head -60 cuaderno-incidentes.md; echo ---; grep -n "^## \|^### " prompts/propuesta-fases-backend.md | head -60

# --- 2026-09-10T19:24:04 · Check incident logbook headings and recent commits
grep -n "^## \|^### " cuaderno-incidentes.md | tail -30; echo ---; cd .. && git log --oneline -3 -- angular-8-legacy-for-backend-devs

# --- 2026-09-10T19:47:02 · Find angular-16 references in the course
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs && grep -rn -i "angular.16\|angular 16\|angular-16\|CertCore\|Lumen\|curso hermano\|otro curso" --include=*.md . | grep -v "^./prompts/_deprecado"

# --- 2026-09-10T19:47:04 · Find cross-course references
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs && grep -rn -iE "angular.?16|CertCore|Lumen|curso hermano|otro curso|react.?16|vue.?2" . --include='*.md' | grep -v "_deprecado"

# --- 2026-09-10T19:47:15 · Read backend proposal intro sections
sed -n '1,135p' prompts/propuesta-fases-backend.md

# --- 2026-09-10T19:47:31 · Read remaining cross-course passages
sed -n '255,275p;518,532p' prompts/propuesta-fases-backend.md; echo "=== guia 755-772"; sed -n '750,775p' prompts/guia-de-estilo-y-convenciones.md; echo "=== formato-piezas 165,210"; sed -n '165,212p' prompts/formato-piezas-forenses.md

# --- 2026-09-10T19:47:48 · Confirm section boundaries
sed -n '20,30p;100,108p' prompts/propuesta-fases-backend.md | cat -n

# --- 2026-09-10T19:48:09 · Replace section 0 of the backend proposal
cat > /tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/70a2da9f-4377-4097-8175-04d5f3b7e008/scratchpad/sec0.md <<'EOF'
El track no se diseñó de un tirón: salió de once rondas de discusión llevadas en
notas de trabajo sin versionar, que ya no existen; **lo que quedó de ellas es
este apartado**, y por eso conserva **el razonamiento que descartó cosas**, que
es la mitad del valor: sin él, dentro de seis meses alguien va a volver a
proponer Cassandra como store principal.

### 0.1 La bisagra: el backend no viene a redimir nada

El molde obvio para un track de backend es la **redención**: el mock es un atajo
declarado, y las fases del servidor existen para cobrar —una por una— las deudas
💸 que el track base anunció y no podía pagar desde el navegador. El alumno
termina con un sistema mejor del que empezó.

Ese molde se descartó, y la inversión de signo es lo que funda este track:

> 🧠 **El backend no viene a redimir nada. El backend es la escena del crimen.**
> El contenido no es *"cómo se hace bien"*, es *"qué haces el lunes cuando lo
> que está mal es una decisión de arquitectura de hace cinco años, el sistema
> factura, y no hay presupuesto para deshacerla"*.

Y su corolario, que ordena el final del track: **el desenlace honesto casi nunca
es migrar.** Es estabilizar, acotar el daño, y escribir el documento que defiende
por qué no se migra.

### 0.2 La ficha del pecado

Que el pecado sea de **modelo de datos** —y no, por ejemplo, de ausencia de
revisión o de un framework mal elegido— es la decisión que ordena las nueve
fases. Queda fijada así:

- **El pecado:** moda de modelo de datos.
- **El actor:** el equipo huyendo del DBA de Oracle.
- **Cómo se decidió:** *"con Mongo el esquema lo movemos nosotros"*, en 2019.
- **El stack que salió de ahí:** Java 8 + Spring Boot 2.1 + `mongo:4.0`.
- **El fallo insignia:** integridad, historia, auditoría.
- **El entregable final:** un plan de contención medido.

Dentro de esa decisión se evaluó y se descartó **Cassandra como store
principal**: sería el mismo curso —*"elegí mal el modelo de datos"*— con otra
base, y además con el modelo de acceso equivocado (§0.4).

### 0.3 Por qué esas versiones y no otras

**El dato duro:** `mongo:4.0` (jul-2018) + Spring Boot 2.1 (oct-2018) es
exactamente lo que instalaría un equipo que arranca en **2019**, que es la fecha
que el README de LabCore ya publicó. Boot 1.5 se descartó por lo mismo:
implicaría un proyecto empezado en 2017 y contradiría la historia escrita. La
edad del backend no la fija la edad del frontend, la fija la historia publicada
del equipo que lo escribió.

**Y la rima de disciplina**, que es la razón de fondo:

> 🧠 `strict: false` con `any` tolerado (el frontend) ↔ **Mongo sin
> `$jsonSchema`** (el backend).

El curso enseña la misma pregunta de disciplina en sus dos capas. La deriva de
esquema de este track —*tres años sin validación producen cinco formas del mismo
documento de paciente*— **es el pecado de `any` tolerado una capa más abajo**.
Cualquier stack que rompiera esa rima quedaba fuera por eso solo.
EOF
python3 - <<'PY'
p='prompts/propuesta-fases-backend.md'
L=open(p).read().split('\n')
new=open('/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/70a2da9f-4377-4097-8175-04d5f3b7e008/scratchpad/sec0.md').read().rstrip('\n').split('\n')
assert L[22].startswith('El track no se diseñó'), L[22]
assert L[104].startswith('### 0.4'), L[104]
out=L[:22]+new+['']+L[104:]
open(p,'w').write('\n'.join(out))
PY
grep -n "^### 0\.\|^## " prompts/propuesta-fases-backend.md | head -12

# --- 2026-09-10T19:48:20 · Clean remaining cross-course mentions in proposal
python3 - <<'PY'
import re
p='prompts/propuesta-fases-backend.md'
s=open(p).read()
subs=[
("sin reactive. Aparecen como comparación 🔥, igual que Angular 16 en el track base.",
 "sin reactive. Lo posterior a Java 8 aparece marcado 🔥 como comparación, nunca\ncomo la forma en que LabCore está escrito."),
("""distintas — campo ausente, campo con valor `null`, y campo con string vacío. Es
literalmente la conversación de `strict: true` del curso de Angular 16, y acá el
alumno la vive desde el otro lado.""",
 """distintas — campo ausente, campo con valor `null`, y campo con string vacío. Es
la conversación de `strict: true` que el frontend nunca tuvo, vivida desde el
otro lado del cable."""),
]
for a,b in subs:
    assert a in s, a[:50]
    s=s.replace(a,b)
open(p,'w').write(s)
PY
grep -rniE "angular.?16|certcore|lumen|react.?16|curso hermano|postgres" prompts/propuesta-fases-backend.md

# --- 2026-09-10T19:48:28 · Fix style guide and scan other prompt docs
python3 - <<'PY'
p='prompts/guia-de-estilo-y-convenciones.md'
s=open(p).read()
a="""  usaba. Lo posterior a Java 8 aparece marcado 🔥 como comparación, igual que
  Angular 16 en el track base."""
b="""  usaba. Lo posterior a Java 8 aparece marcado 🔥 como comparación, nunca como la
  forma en que LabCore está escrito."""
assert a in s
open(p,'w').write(s.replace(a,b))
PY
grep -rniE "angular.?16|certcore|lumen|react.?16|curso hermano" prompts/guia-de-estilo-y-convenciones.md prompts/prompts-backend-fase.md prompts/prompts-backend-apendice.md prompts/alcance-del-proyecto.md prompts/propuesta-fases-y-alcance.md prompts/plantillas-de-capitulo.md prompts/prompts-de-redaccion.md prompts/prompts-extendidos-fases.md prompts/prompts-extendidos-apendices.md prompts/formato-cuaderno-incidentes.md

# --- 2026-09-10T19:48:37 · Read header of forensic format doc
sed -n '1,40p' prompts/formato-piezas-forenses.md

# --- 2026-09-10T19:48:40 · Read section 6 header
sed -n '145,175p' prompts/formato-piezas-forenses.md

# --- 2026-09-10T19:48:55 · Rewrite forensic format divergence sections
python3 - <<'PY'
p='prompts/formato-piezas-forenses.md'
s=open(p).read()
subs=[
("""### 6.1 Divergencia declarada — la cuarta pregunta del método

El track forense del curso hermano de Angular 16 cierra su método con *"¿de qué
generación es el archivo que voy a tocar?"*, porque allá conviven NgModules y
componentes standalone. **Acá no aplica y se reemplaza**: LabCore es de una sola
época —2019 a 2021, Angular 8 de principio a fin— y esa pregunta no tendría nada
que separar. Su reemplazo es la bifurcación que ya aparece en los ganchos de las
fases 7 y 11:""",
"""### 6.1 La cuarta pregunta del método

Las tres primeras preguntas son las de cualquier investigación. **La cuarta es la
propia de este curso**, y hay que fijarla acá porque es la que se presta a
copiarse mal. Una tentación frecuente es preguntar *"¿de qué generación es el
archivo que voy a tocar?"*, que funciona donde conviven varias épocas del
framework en el mismo repositorio; **acá no aplica**: LabCore es de una sola
época —2019 a 2021, Angular 8 de principio a fin— y esa pregunta no tendría nada
que separar. La que sí ordena el trabajo es la bifurcación que ya aparece en los
ganchos de las fases 7 y 11:"""),
("""El emoji 🧬 se mantiene con el mismo papel que tiene en el curso hermano —marcar
la pregunta propia del track— aunque la pregunta sea otra.""",
"""El emoji 🧬 queda reservado para eso: marcar la pregunta propia del track, la que
no se hereda de ningún manual de depuración general."""),
("""### 6.2 Divergencia declarada — el elenco de herramientas""",
"""### 6.2 El elenco de herramientas"""),
("""### 6.3 Divergencia declarada — cómo cierra el master

El curso hermano cierra su track remitiendo a un `HOTFIX.md` de una página que
escribe su Fase 13. **Angular 8 no tiene ese artefacto** —su Fase 13 termina en la
prueba de fuego del contenedor— y no se inventa uno, porque crearlo obligaría a
tocar una fase publicada y eso choca con la regla de content lock. El equivalente
ya existe y ya está en uso: el **post-mortem de ocho puntos** de la §13 de la guía""",
"""### 6.3 Cómo cierra el master

El cierre natural de un track forense es un artefacto de una página —un
`HOTFIX.md` con el procedimiento destilado— que el curso escribiría en alguna
fase tardía. **Este curso no lo tiene** —su Fase 13 termina en la prueba de fuego
del contenedor— y **no se inventa uno**, porque crearlo obligaría a tocar una
fase publicada y eso choca con la regla de content lock. El equivalente ya existe
y ya está en uso: el **post-mortem de ocho puntos** de la §13 de la guía"""),
]
for a,b in subs:
    assert a in s, a[:60]
    s=s.replace(a,b)
open(p,'w').write(s)
PY
grep -rniE "angular.?16|certcore|lumen|react.?16|curso hermano|divergencia declarada" prompts/formato-piezas-forenses.md; grep -rn "6\.1\|6\.2\|6\.3" forense-master.md | head

# --- 2026-09-10T19:49:01 · Read forensic analysis doc header
sed -n '1,30p' analisis-forense-tutoriales.md; echo ...; grep -n "^## " analisis-forense-tutoriales.md

# --- 2026-09-10T19:49:08 · Verify no cross-course refs remain
grep -rniE "angular.?16|certcore|lumen|react.?16|vue.?2|curso hermano|otro curso del catálogo" . --include='*.md' | grep -v "analisis-forense-tutoriales" | grep -v "_deprecado" | grep -viE "a11-migracion|volumen"

# --- 2026-09-10T19:49:18 · Neutralize sibling-course hints in self-containment rules
python3 - <<'PY'
edits = {
 'prompts/prompts-backend-apendice.md': [
   ("otro curso del catálogo**, aunque exista uno de contenedores. Si algo necesita",
    "otro curso del catálogo**, ni siquiera para los contenedores. Si algo necesita")],
 'prompts/propuesta-fases-backend.md': [
   ("**Autocontención estricta.** Este track no remite a ningún otro curso, aunque\nexista uno de contenedores en el catálogo. Todo lo que hace falta para levantar",
    "**Autocontención estricta.** Este track no remite a ningún otro curso del\ncatálogo, ni siquiera para los contenedores. Todo lo que hace falta para levantar")],
 'prompts/guia-de-estilo-y-convenciones.md': [
   ("catálogo, ni siquiera al de contenedores. Todo lo necesario vive en `be-a-02`.",
    "catálogo, ni siquiera para los contenedores. Todo lo necesario vive en `be-a-02`.")],
}
for p,subs in edits.items():
    s=open(p).read()
    for a,b in subs:
        assert a in s,(p,a[:40])
        s=s.replace(a,b)
    open(p,'w').write(s)
print("ok")
PY

# --- 2026-09-10T19:51:28 · Move analysis doc to repo root and check inbound links
cd /Users/oskar/Developer/Learning/courses-ia-generated && git mv angular-8-legacy-for-backend-devs/analisis-forense-tutoriales.md analisis-forense-tutoriales.md && grep -rn "analisis-forense-tutoriales" --include='*.md' . | grep -v "^./analisis-forense"

# --- 2026-09-10T19:51:33 · Show status and remaining references
cd /Users/oskar/Developer/Learning/courses-ia-generated && git status --short && echo "=== refs restantes en el curso:" && grep -rniE "angular.?16|certcore|lumen|react.?16" angular-8-legacy-for-backend-devs --include='*.md' | grep -v "_deprecado"

# --- 2026-09-10T19:51:40 · Read existing memory file
cat /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/tracks-be-angular-decisiones.md

# --- 2026-09-10T19:51:49 · Update project memory with self-containment decision
cd /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory && python3 - <<'PY'
p='tracks-be-angular-decisiones.md'
s=open(p).read()
a="""**El reparto se invirtió por error una vez y se revirtió.** Si vuelve a salir la
idea de dar Lumen a angular-8 "porque es el curso más viejo", el análisis
completo está en §0.3 de cada propuesta: la edad del frontend no ordena la del
backend, y romper la inversión rompe dos rimas de disciplina
(`strict:false`↔sin `$jsonSchema`, `strict:true`↔`NULL`)."""
b="""**El reparto se invirtió por error una vez y se revirtió.** Si vuelve a salir la
idea de dar Lumen a angular-8 "porque es el curso más viejo": la edad del
frontend no ordena la del backend, y romper la inversión rompe dos rimas de
disciplina (`strict:false`↔sin `$jsonSchema`, `strict:true`↔`NULL`). Ese
razonamiento comparado **ya no vive en ningún documento de curso**: el
10/09/2026 se purgaron de `angular-8` todas las referencias a `angular-16`
—cada curso es autocontenido, "uno no debe saber del otro"—, así que §0 de su
propuesta conserva solo el porqué de Java/Mongo/2019 y la rima propia. Si se
edita la propuesta de CertCore, hacer lo mismo en sentido contrario. El análisis
comparado del track forense se movió a `analisis-forense-tutoriales.md` en la
**raíz** del repo por la misma razón."""
assert a in s
open(p,'w').write(s.replace(a,b))
PY
echo ok

# --- 2026-09-10T22:06:44 · Verify no cross-course references remain
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs
echo "=== 1. refs a cursos hermanos (excluye 'volumen' y a11) ==="
grep -rniE "angular.?16|angular-16|certcore|lumen|react.?16|react-16|vue.?2|curso hermano|curso de contenedores" . --include='*.md' | grep -v "_deprecado" | grep -viE "volumen|volúmen" | grep -v "^./a11-migracion-9-16.md"
echo "--- (a11, solo versión de Angular:)"
grep -rn "Angular 16" a11-migracion-9-16.md | wc -l
echo
echo "=== 2. rutas a otros directorios de curso ==="
grep -rnE "\.\./(react|angular|vue)-" . --include='*.md' | grep -v "_deprecado"
echo "(vacío = ok)"

# --- 2026-09-10T22:06:53 · Check dangling section refs and broken internal links
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs
echo "=== refs a §0.x / §6.x de los docs editados ==="
grep -rnE "§ ?0\.[0-9]|§ ?6\.[0-9]|Divergencia declarada|reparto|inversión de signo" . --include='*.md' | grep -v "_deprecado"
echo
echo "=== enlaces internos rotos ==="
grep -rhoE "\]\(\.?/?[A-Za-z0-9._/-]+\.md" . --include='*.md' | sed 's/^](//' | sort -u | while read f; do
  for base in . prompts; do :; done
done
python3 - <<'PY'
import re,os
bad=[]
for root,d,fs in os.walk('.'):
    if '.git' in root: continue
    for f in fs:
        if not f.endswith('.md'): continue
        p=os.path.join(root,f)
        for i,l in enumerate(open(p),1):
            for m in re.findall(r'\]\(([^)#\s]+\.md)[^)]*\)', l):
                t=os.path.normpath(os.path.join(root,m))
                if not os.path.exists(t): bad.append(f"{p}:{i} -> {m}")
print('\n'.join(bad) if bad else "(ninguno)")
PY

# --- 2026-09-10T22:07:05 · Check whether the broken links pre-date the edits
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs
echo "=== ¿los 3 enlaces sin ../ son previos? ==="
for f in prompts/plantillas-de-capitulo.md prompts/guia-de-estilo-y-convenciones.md; do
  echo -n "$f en HEAD: "; git show HEAD:angular-8-legacy-for-backend-devs/$f | grep -c "](00-convencion-de-git-y-tags.md"
done
echo
echo "=== diff resumido ==="
cd .. && git diff --stat -- angular-8-legacy-for-backend-devs

# --- 2026-09-10T22:07:12 · Re-check git status and diffs
git status --short && echo "---diffstat---" && git diff --stat && echo "---staged---" && git diff --cached --stat

# --- 2026-09-10T22:07:17 · Check whether the course directory still exists
ls -d angular-8-legacy-for-backend-devs 2>&1; ls | head -30; echo "--- .gitignore?"; cat .gitignore 2>/dev/null; echo "--- ls-files count"; git ls-files angular-8-legacy-for-backend-devs | wc -l

# --- 2026-09-10T22:07:24 · Investigate current state of the moved file
git log --oneline -3; echo "--- ¿existe en raíz?"; ls -la analisis-forense-tutoriales.md 2>&1; echo "--- ¿en el curso?"; ls -la angular-8-legacy-for-backend-devs/analisis-forense-tutoriales.md 2>&1; echo "--- HEAD contiene:"; git ls-tree --name-only HEAD | grep -i analisis

# --- 2026-09-10T22:07:32 · Verify committed changes and scan HEAD for cross-course refs
git show --stat f36f2b9 | head -20; echo "=== verificación sobre HEAD ==="; git grep -niE "angular.?16|certcore|lumen|react.?16|curso hermano" HEAD -- angular-8-legacy-for-backend-devs | grep -v "_deprecado" | grep -v "a11-migracion"

# --- 2026-09-10T22:07:40 · Check the deprecated tutorial file too
grep -cniE "angular.?16|certcore|react.?16|curso hermano" angular-8-legacy-for-backend-devs/prompts/_deprecado-tutorial-angular8.md; echo "(0 = limpio)"

# --- 2026-09-10T22:07:42 · Show the hit in the deprecated file
grep -niE "angular.?16|certcore|react.?16|curso hermano" angular-8-legacy-for-backend-devs/prompts/_deprecado-tutorial-angular8.md

# --- 2026-09-10T22:09:37 · Restore the file and read its risk and tracking sections
git checkout -- analisis-forense-tutoriales.md && ls -la analisis-forense-tutoriales.md && sed -n '396,491p' analisis-forense-tutoriales.md

# --- 2026-09-10T22:09:46 · Check whether both plans were executed
cd /Users/oskar/Developer/Learning/courses-ia-generated
echo "=== angular-8 forense:"; ls angular-8-legacy-for-backend-devs/forense-*.md | wc -l; ls angular-8-legacy-for-backend-devs/prompts/formato-piezas-forenses.md
echo "=== react-16:"; ls react-16-legacy-for-backend-devs/ | grep -i "forense" ; echo "--- prompts:"; ls react-16-legacy-for-backend-devs/prompts/ 2>/dev/null | grep -i forense
echo "=== react-16 alcance §6/§7 sobre track forense:"; grep -n -i "forense" react-16-legacy-for-backend-devs/00-alcance-del-proyecto.md | head -20

# --- 2026-09-10T22:09:53 · Read the React 16 plan options
sed -n '275,340p' analisis-forense-tutoriales.md

# --- 2026-09-10T22:10:05 · Check react-16 course state for forensic track
ls react-16-legacy-for-backend-devs | head -40 && echo "=== README react-16, menciones forense:" && grep -n -i "forense" react-16-legacy-for-backend-devs/README.md | head

# --- 2026-09-10T22:10:11 · Confirm restore left a clean tree
git status --short | grep -i analisis; echo "(sin salida = restaurado y limpio)"; git status --short

# --- 2026-09-10T22:12:42 · Check react-16 backend track completeness
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && ls be*.md | tr '\n' ' '; echo; ls cuaderno*.md 2>/dev/null

