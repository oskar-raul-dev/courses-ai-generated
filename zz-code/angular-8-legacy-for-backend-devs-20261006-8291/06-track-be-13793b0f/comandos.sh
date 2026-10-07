# Comandos Bash de la sesión 13793b0f-cc80-46c4-b71d-4f3ec9375796, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-10T22:31:09 · Read new ideas file and course README
cat nuevas-ideas.md && echo "=== README curso ===" && head -60 angular-8-legacy-for-backend-devs/README.md && echo "=== prompts ===" && ls angular-8-legacy-for-backend-devs/prompts

# --- 2026-09-10T22:32:22 · List prompts and word counts
cd angular-8-legacy-for-backend-devs && ls -la prompts && echo "=== wc ===" && wc -w *.md prompts/*.md | sort -n | tail -70

# --- 2026-09-10T22:32:25 · Read README and course setup docs
cat README.md 00-historia-del-sistema.md 00-convencion-de-git-y-tags.md

# --- 2026-09-10T22:32:29 · Read saved output of course docs
cat /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/13793b0f-cc80-46c4-b71d-4f3ec9375796/tool-results/b1mvpscfp.txt

# --- 2026-09-10T22:32:31 · Read rest of README
sed -n '40,200p' README.md

# --- 2026-09-10T22:32:33 · Read final README section
sed -n '200,400p' README.md

# --- 2026-09-10T22:32:36 · Read system history doc
sed -n '1,120p' 00-historia-del-sistema.md

# --- 2026-09-10T22:32:38 · Read rest of system history
sed -n '120,240p' 00-historia-del-sistema.md

# --- 2026-09-10T22:32:42 · Show headings of backend proposal and style guide
grep -n '^#\{1,3\} ' prompts/propuesta-fases-backend.md | head -80; echo "=== ESTILO ==="; grep -n '^#\{1,3\} ' prompts/guia-de-estilo-y-convenciones.md | head -80

# --- 2026-09-10T22:32:47 · Inspect incident notebook and forensic master
grep -n '^#\{1,3\} ' cuaderno-incidentes.md | head -40; echo "=== forense-master ==="; grep -n '^#\{1,2\} ' forense-master.md | head -20; echo "=== git status ==="; cd .. && git status --short

# --- 2026-09-10T22:35:19 · Read appendices, conventions and pending docs sections
cd angular-8-legacy-for-backend-devs && sed -n '686,860p' prompts/propuesta-fases-backend.md

# --- 2026-09-10T22:35:28 · Check BE track references in framing docs
grep -n -i 'be00\|be-fase\|track BE\|backend' prompts/alcance-del-proyecto.md 00-convencion-de-git-y-tags.md prompts/propuesta-fases-y-alcance.md prompts/plantillas-de-capitulo.md | head -60

# --- 2026-09-10T22:36:02 · Check BE filenames across docs
grep -n 'be0[0-8][a-z-]*\.md\|be-fase-0' prompts/propuesta-fases-backend.md prompts/guia-de-estilo-y-convenciones.md 00-convencion-de-git-y-tags.md prompts/prompts-backend-apendice.md | head -40

# --- 2026-09-10T22:36:17 · Read stack and verification section
sed -n '259,400p' prompts/propuesta-fases-backend.md

# --- 2026-09-10T22:36:28 · Show conventions section lines
sed -n '744,760p' prompts/propuesta-fases-backend.md

# --- 2026-09-10T22:36:40 · Add canonical filename table to backend proposal
python3 - <<'PY'
import io
p='prompts/propuesta-fases-backend.md'
s=io.open(p,encoding='utf-8').read()

old="""**Tags de git:** `be-fase-` + el mismo slug del archivo, en un namespace propio
para que `git tag -l 'fase-*'` siga siendo el índice limpio del track base
(`be00-el-contrato.md` → `be-fase-00-el-contrato`). Los commits llevan prefijo
`be00: …`, y los de ejercicio `be00 ej17: …`. Se registra en
`00-convencion-de-git-y-tags.md` (§10)."""

new="""**Tags de git:** `be-fase-` + el mismo slug del archivo, en un namespace propio
para que `git tag -l 'fase-*'` siga siendo el índice limpio del track base
(`be00-el-contrato-auditoria-del-mock.md` → `be-fase-00-el-contrato-auditoria-del-mock`).
Los commits llevan prefijo `be00: …`, y los de ejercicio `be00 ej17: …`. Se
registra en `00-convencion-de-git-y-tags.md` (§10).

**Los nueve nombres, ya fijados.** Se declaran aquí y no en los prompts, para que
este documento siga siendo la fuente de verdad; `prompts-backend-fase.md` los
copia y nunca al revés.

| Fase | Archivo | Tag |
|---|---|---|
| be00 | `be00-el-contrato-auditoria-del-mock.md` | `be-fase-00-el-contrato-auditoria-del-mock` |
| be01 | `be01-java-spring-y-la-forma-del-monolito.md` | `be-fase-01-java-spring-y-la-forma-del-monolito` |
| be02 | `be02-medir-la-deriva-de-esquema.md` | `be-fase-02-medir-la-deriva-de-esquema` |
| be03 | `be03-la-costura-y-el-reemplazo.md` | `be-fase-03-la-costura-y-el-reemplazo` |
| be04 | `be04-el-audit-log-que-escribia-el-navegador.md` | `be-fase-04-el-audit-log-que-escribia-el-navegador` |
| be05 | `be05-la-cadena-de-custodia-y-la-transaccion.md` | `be-fase-05-la-cadena-de-custodia-y-la-transaccion` |
| be06 | `be06-los-rangos-y-la-historia-perdida.md` | `be-fase-06-los-rangos-y-la-historia-perdida` |
| be07 | `be07-la-subida-que-nadie-decidio.md` | `be-fase-07-la-subida-que-nadie-decidio` |
| be08 | `be08-la-contencion-y-lo-irrecuperable.md` | `be-fase-08-la-contencion-y-lo-irrecuperable` |"""

assert old in s
s=s.replace(old,new)
io.open(p,'w',encoding='utf-8').write(s)
print("ok")
PY

# --- 2026-09-10T22:36:47 · Show README backend track section
grep -n 'Track opcional de backend' -A 40 README.md | sed -n '1,45p'

# --- 2026-09-10T22:36:59 · Add BE phase table to course README
python3 - <<'PY'
import io
p='README.md'
s=io.open(p,encoding='utf-8').read()
old="""El track **no vende MongoDB ni Java**"""
new="""| Fase | Archivo | Horas |
|---|---|---|
| 📜 be00 · El contrato: auditoría del mock | `be00-el-contrato-auditoria-del-mock.md` | 6h |
| ☕ be01 · Java 8, Spring Boot 2.1 y la forma del monolito | `be01-java-spring-y-la-forma-del-monolito.md` | 8h |
| 🔬 be02 · Lo que hay de verdad guardado: medir la deriva ⭐ | `be02-medir-la-deriva-de-esquema.md` | 10h |
| 🗄️ be03 · La costura: de `db.json` a Mongo, y el reemplazo | `be03-la-costura-y-el-reemplazo.md` | 10h |
| 📜 be04 · El audit log que escribía el navegador | `be04-el-audit-log-que-escribia-el-navegador.md` | 8h |
| ⛓️ be05 · La cadena de custodia y la transacción que no existe ⭐⭐ | `be05-la-cadena-de-custodia-y-la-transaccion.md` | 10h |
| 🧬 be06 · Los rangos versionados y la historia que se sobrescribió | `be06-los-rangos-y-la-historia-perdida.md` | 10h |
| 📅 be07 · La subida que nadie decidió: 4.0 → 4.4 → 6.0 → 7.0 | `be07-la-subida-que-nadie-decidio.md` | 8h |
| 🧯 be08 · La contención medida y la declaración de lo irrecuperable | `be08-la-contencion-y-lo-irrecuperable.md` | 10h |

Los doce apéndices `be-a-01`–`be-a-12` están tabulados en §8 de la propuesta, y
sus nombres de archivo se fijan al escribirlos.

El track **no vende MongoDB ni Java**"""
assert old in s
s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY

# --- 2026-09-10T22:37:11 · Update phase prompts with appendix and status fixes
python3 - <<'PY'
import io
p='prompts/prompts-backend-fase.md'
s=io.open(p,encoding='utf-8').read()

old="""- Apéndices de apoyo: **be-a-04** (agregaciones como instrumento de medida),
  **be-a-05** (índices y `explain`), **be-a-03** (embeber o referenciar)"""
new="""- Apéndices de apoyo: **be-a-04** (agregaciones como instrumento de medida),
  **be-a-05** (índices y `explain`), **be-a-03** (embeber o referenciar),
  **be-a-12** (datos de prueba y volumen — de ahí sale el dump sintético)"""
assert old in s; s=s.replace(old,new,1)

old2="""3. **Las adiciones de encuadre de §10 de `propuesta-fases-backend.md`**, que se
   hacen **antes** de escribir `be00`."""
new2="""3. ~~**Las adiciones de encuadre de §10 de `propuesta-fases-backend.md`**, que se
   hacen **antes** de escribir `be00`.~~ ✅ **Hechas** (10/09/2026): los ocho
   documentos de §10 ya están tocados —README con su sección y su tabla de nueve
   fases, `00-historia-del-sistema.md`, la guía de estilo (§16),
   `alcance-del-proyecto.md`, `00-convencion-de-git-y-tags.md` (§10),
   `propuesta-fases-y-alcance.md` (§9), `cuaderno-incidentes.md` y el `CLAUDE.md`
   del repositorio—. **No hay que rehacerlas**; lo que queda es actualizar el
   estado de cada archivo a medida que las fases se escriban.

Y una nota de método para las tandas: **los nombres de archivo y los tags de las
nueve fases están fijados en §9 de la propuesta**. Si un chat propone otro nombre,
gana la propuesta."""
assert old2 in s; s=s.replace(old2,new2,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY

# --- 2026-09-10T22:48:36 · Read style guide markers, template and exercises
sed -n '322,520p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-10T22:48:39 · Read style guide BE track section
sed -n '705,830p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-10T22:49:09 · Fetch Spring Boot BOM properties
curl -s --max-time 25 https://repo1.maven.org/maven2/org/springframework/boot/spring-boot-dependencies/2.1.18.RELEASE/spring-boot-dependencies-2.1.18.RELEASE.pom | grep -E '<(spring-data-releasetrain|mongodb|spring-framework|jackson-bom|junit|jetty|tomcat)\.version>' | head

# --- 2026-09-10T22:49:18 · Fetch more BOM properties
curl -s --max-time 25 https://repo1.maven.org/maven2/org/springframework/boot/spring-boot-dependencies/2.1.18.RELEASE/spring-boot-dependencies-2.1.18.RELEASE.pom | grep -E '<(spring|jackson|java)\.version>|<spring-data-mongodb' | head

# --- 2026-09-10T22:49:24 · Read mock API phase part 1
sed -n '1,320p' 04-mock-api-caos.md

# --- 2026-09-10T22:49:26 · Read mock chaos middleware code
sed -n '320,470p' 04-mock-api-caos.md

# --- 2026-09-10T22:49:30 · Read auth mock code from phase 3
sed -n '/### 5.*auth.js/,/^### 5\.[3-9]/p' 03-autenticacion.md | head -120

# --- 2026-09-10T22:49:35 · Find API URL usage across phases
grep -n "apiUrl\}\|apiUrl +\|`\${environment" 0[5-9]-*.md 1[01]-*.md | head -40

# --- 2026-09-10T22:49:38 · Find API URL usage across phases
grep -n 'apiUrl' 0[5-9]-*.md 1[01]-*.md | head -40

# --- 2026-09-10T22:49:46 · List all HTTP calls in phases
grep -rn "this\.http\.\(get\|post\|put\|patch\|delete\)" 0*.md 1*.md | sed 's/^\([^:]*\):\([0-9]*\).*http\./\1:\2  http./' | head -40

# --- 2026-09-10T22:49:50 · Check orders, dashboard and custody endpoints
grep -n "http\b\|/orders\|apiUrl" 06-ordenes.md | head -20; echo "=== 10 ==="; grep -n "http\b\|apiUrl\|/results\|/orders" 10-dashboard.md | head -20; echo "=== 07 custody ==="; grep -n 'custody\|Custody' 07-muestras-custodia.md | head -20

# --- 2026-09-10T22:49:57 · Check seed script, active field and auditLog
grep -n '"seed"\|seed.js\|npm run seed' 0[5-9]-*.md 1[01]-*.md | head -15; echo "=== active ==="; grep -n '\bactive\b' 05-pacientes.md | head -10; echo "=== auditLog seed ==="; grep -n 'auditLog' 11-trazabilidad-audit-log.md | head -20

# --- 2026-09-10T22:50:04 · Read audit entry model
sed -n '95,190p' 11-trazabilidad-audit-log.md

# --- 2026-09-10T22:50:08 · Find audit entry id generation
grep -n 'id:' 11-trazabilidad-audit-log.md | sed -n '1,25p'

# --- 2026-09-10T22:50:10 · Read audit effect entry building
sed -n '360,420p' 11-trazabilidad-audit-log.md

# --- 2026-09-10T22:50:21 · Read chapter templates
cat prompts/plantillas-de-capitulo.md

# --- 2026-09-10T22:50:34 · Fix domain dictionary against real contract
python3 - <<'PY'
import io
p='prompts/guia-de-estilo-y-convenciones.md'
s=io.open(p,encoding='utf-8').read()

old="""| Eslabón de custodia | `CustodyLink` | `custodyLinks` | — (interno) |"""
new="""| Eslabón de custodia | `CustodyLink` | `custodyLinks` | — (interno, **no existe hoy**) |"""
assert old in s; s=s.replace(old,new,1)

old2="""| Asiento de auditoría | `AuditEntry` | `auditEntries` | `/auditEntries` |"""
new2="""| Asiento de auditoría | `AuditEntry` | `auditLog` | `/auditLog` |"""
assert old2 in s; s=s.replace(old2,new2,1)

old3="""Clases en `PascalCase`, campos y colecciones en `camelCase` —**igual que el
`db.json`**, porque el contrato lo exige y el contrato manda sobre la elegancia—."""
new3="""Clases en `PascalCase`, campos y colecciones en `camelCase` —**igual que el
`db.json`**, porque el contrato lo exige y el contrato manda sobre la elegancia—.

> ⚠️ **Dos filas de esa tabla se corrigieron contra el contrato real, y son la
> primera lección del track.** La bitácora se llama `auditLog` y no
> `auditEntries`: es el nombre que el `AuditService` de la Fase 11 tiene escrito
> en un `POST`, y como el frontend no se toca, **el nombre bonito pierde**. Y
> `custodyLinks` **no existe en el sistema de hoy**: la custodia vive embebida en
> el documento de la muestra, en los campos `collectedBy` / `collectedAt` y sus
> hermanos, y el componente de la Fase 7 la reconstruye a mano con
> `custodyEvents()`. La colección aparte es lo que `be05` propone, no lo que hay.
> Si una fase del track las nombra de otra forma, la fase está mal."""
assert old3 in s; s=s.replace(old3,new3,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY

# --- 2026-09-10T22:51:26 · Check interceptor 401 behaviour
grep -n '401\|expiresIn\|TOKEN_TTL\|interceptor' 03-autenticacion.md | head -30

# --- 2026-09-10T23:04:18 · Update README, proposal and prompts after batch 1
python3 - <<'PY'
import io,re

# --- README: estado del track -------------------------------------------
p='README.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("## 🔥 Track opcional de backend (propuesto, aún sin escribir)",
            "## 🔥 Track opcional de backend (en escritura)",1)
old="""prompts de redacción en `prompts/prompts-backend-fase.md` y
`prompts/prompts-backend-apendice.md`. **Ninguna fase está escrita todavía.**"""
new="""prompts de redacción en `prompts/prompts-backend-fase.md` y
`prompts/prompts-backend-apendice.md`.

**Escritas: `be00` y `be01`.** Las siete fases restantes, los doce apéndices y
`cuaderno-incidentes-be.md` están pendientes. El track no se puede empezar
todavía: `be00` y `be01` se sostienen solas —auditan el mock y levantan el
servidor— pero la continuidad real arranca cuando exista `be03`."""
assert old in s; s=s.replace(old,new,1)
s=s.replace("| 📜 be00 · El contrato: auditoría del mock | `be00-el-contrato-auditoria-del-mock.md` | 6h |",
            "| 📜 be00 · El contrato: auditoría del mock ✅ | [`be00-el-contrato-auditoria-del-mock.md`](be00-el-contrato-auditoria-del-mock.md) | 6h |",1)
s=s.replace("| ☕ be01 · Java 8, Spring Boot 2.1 y la forma del monolito | `be01-java-spring-y-la-forma-del-monolito.md` | 8h |",
            "| ☕ be01 · Java 8, Spring Boot 2.1 y la forma del monolito ✅ | [`be01-java-spring-y-la-forma-del-monolito.md`](be01-java-spring-y-la-forma-del-monolito.md) | 8h |",1)
io.open(p,'w',encoding='utf-8').write(s)

# --- propuesta: cerrar el pendiente de la version de Spring Boot ---------
p='prompts/propuesta-fases-backend.md'; s=io.open(p,encoding='utf-8').read()
old="""1. **La versión exacta de Spring Boot 2.1.x** (`2.1.18.RELEASE` es la última de
   la línea ⚠️). Se fija al escribir `be01`, no antes."""
new="""1. 🪦 **La versión exacta de Spring Boot 2.1.x — cerrado al escribir `be01`
   (10/09/2026).** Es **`2.1.18.RELEASE`**, publicada el 29/10/2020 y última de
   la línea 2.1, que llegó a fin de soporte el 1/11/2020. Verificado contra el
   anuncio oficial y contra su propio `spring-boot-dependencies`, que fija
   Spring Framework `5.1.19.RELEASE`, Spring Data `Lovelace-SR21`, Jackson
   `2.9.10.20200824`, Tomcat `9.0.39`, JUnit `4.12` y —el dato que le importa a
   `be07`— **`mongodb` 3.8.2**. O sea: *el driver de 2019 no lo eligió nadie,
   viene con el BOM*, y como el `pom.xml` no se tocó nunca, el driver tampoco.
   Anotado también: Boot 2.1 **no tiene apagado ordenado** (`server.shutdown=graceful`
   llega en 2.3), así que `be01` lo escribe a mano."""
assert old in s; s=s.replace(old,new,1)
s=s.replace("| Framework | **Spring Boot 2.1.x** |",
            "| Framework | **Spring Boot 2.1.18.RELEASE** |",1)
io.open(p,'w',encoding='utf-8').write(s)

# --- prompts de fase: cerrar el pendiente de be01 ------------------------
p='prompts/prompts-backend-fase.md'; s=io.open(p,encoding='utf-8').read()
old="""- ⚠️ **Fijar la versión exacta de Spring Boot 2.1.x** (la última de la línea es
  `2.1.18.RELEASE`, verifícala contra Maven Central, no de memoria). Es el único
  pendiente de la fase y hay que cerrarlo aquí, no arrastrarlo."""
new="""- 🪦 **Cerrado (10/09/2026): `2.1.18.RELEASE`**, última de la línea 2.1, del
  29/10/2020, EOL el 1/11/2020. Su BOM fija Spring 5.1.19, Spring Data
  Lovelace-SR21, Jackson 2.9.10.20200824, Tomcat 9.0.39, JUnit 4.12 y el driver
  `mongodb` **3.8.2** — que es el dato que `be07` necesita. Ver §5.5 de la
  propuesta. No hay pendientes bloqueantes en esta fase."""
assert old in s; s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY

# --- 2026-09-10T23:04:41 · Add accents to Spanish comments in be00
python3 - <<'PY'
import io
p='be00-el-contrato-auditoria-del-mock.md'; s=io.open(p,encoding='utf-8').read()
rep=[("# Corre contra CUALQUIER servidor que diga implementar el contrato: el mock de","# Corre contra CUALQUIER servidor que diga implementar el contrato: el mock de"),
 ("# json-server de hoy, o el backend de Java a partir de be03. Si pasa contra los","# json-server de hoy, o el backend de Java a partir de be03. Si pasa contra los"),
 ("# Compara el codigo de estado de una peticion contra el esperado.","# Compara el código de estado de una petición contra el esperado."),
 ("# El -o /dev/null descarta el cuerpo: aqui solo miramos el numero.","# El -o /dev/null descarta el cuerpo: aquí solo miramos el número."),
 ('echo "  FALLA $label — esperaba $expected, llego $actual"','echo "  FALLA $label — esperaba $expected, llegó $actual"'),
 ("# Comprueba que el cuerpo de la respuesta case con un patron. Deliberadamente","# Comprueba que el cuerpo de la respuesta case con un patrón. Deliberadamente"),
 ("# tosco: grep sobre el JSON crudo, sin jq, para que este guion no dependa de","# tosco: grep sobre el JSON crudo, sin jq, para que este guion no dependa de"),
 ("# nada que no este en cualquier maquina.","# nada que no esté en cualquier máquina."),
 ('echo "  FALLA $label — el cuerpo no case con /$pattern/"','echo "  FALLA $label — el cuerpo no casó con /$pattern/"'),
 ("# --- 1. Las cinco colecciones responden y devuelven ARREGLO DESNUDO --------","# --- 1. Las cinco colecciones responden y devuelven ARREGLO DESNUDO --------"),
 ('# El "^\\[" es la afirmacion importante: sin envoltorio, sin {data:...}.','# El "^\\[" es la afirmación importante: sin envoltorio, sin {data:...}.'),
 ("# Cuerpo {} , no vacio y no un JSON de error. Lo pide el catchError de los","# Cuerpo {} , no vacío y no un JSON de error. Lo pide el catchError de los"),
 ("# servicios: si llega otra cosa, el mensaje de error de pantalla cambia.","# servicios: si llega otra cosa, el mensaje de error de pantalla cambia."),
 ("# Esto NO es un descuido del guion: es una clausula del contrato. El dia que","# Esto NO es un descuido del guion: es una cláusula del contrato. El día que"),
 ("# esta linea se ponga en rojo, alguien decidio validar el token, y esa decision","# esta línea se ponga en rojo, alguien decidió validar el token, y esa decisión"),
 ("# tiene consecuencias de producto (ver CONTRACT.md, seccion de autenticacion).","# tiene consecuencias de producto (ver CONTRACT.md, sección de autenticación)."),
 ("# --- 2. Identidad: id entero y recurso individual --------------------------","# --- 2. Identidad: id entero y recurso individual --------------------------"),
 ("# --- 5. Login: forma exacta del cuerpo -------------------------------------","# --- 5. Login: forma exacta del cuerpo -------------------------------------"),
 ("# --- 6. Lo que el servidor NO verifica, afirmado a proposito ---------------","# --- 6. Lo que el servidor NO verifica, afirmado a propósito ---------------"),
 ("# --- 7. El audit log, con su id de cadena venido del cliente ---------------","# --- 7. El audit log, con su id de cadena venido del cliente ---------------"),
 ("# --- Ayudantes -------------------------------------------------------------","# --- Ayudantes -------------------------------------------------------------"),
 ("#   uso: ./smoke.sh [base_url]   (por defecto http://localhost:3000)","#   uso: ./smoke.sh [base_url]   (por defecto http://localhost:3000)"),
 ("# los dos, el reemplazo fue invisible para el frontend. Ese es todo el criterio.","# los dos, el reemplazo fue invisible para el frontend. Ese es todo el criterio."),
 ("# Todas las peticiones únicas de la sesión, con su método, su ruta y el","# Todas las peticiones únicas de la sesión, con su método, su ruta y el"),
]
n=0
for a,b in rep:
    if a!=b and a in s:
        s=s.replace(a,b); n+=1
io.open(p,'w',encoding='utf-8').write(s)
print('sustituciones:',n)
PY

# --- 2026-09-10T23:06:53 · Read seed.js from phase 5
sed -n '84,210p' 05-pacientes.md

# --- 2026-09-10T23:18:08 · Update README, proposal and prompts after batch 2
python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("| 🔬 be02 · Lo que hay de verdad guardado: medir la deriva ⭐ | `be02-medir-la-deriva-de-esquema.md` | 10h |",
 "| 🔬 be02 · Lo que hay de verdad guardado: medir la deriva ⭐ ✅ | [`be02-medir-la-deriva-de-esquema.md`](be02-medir-la-deriva-de-esquema.md) | 10h |",1)
s=s.replace("| 🗄️ be03 · La costura: de `db.json` a Mongo, y el reemplazo | `be03-la-costura-y-el-reemplazo.md` | 10h |",
 "| 🗄️ be03 · La costura: de `db.json` a Mongo, y el reemplazo ✅ | [`be03-la-costura-y-el-reemplazo.md`](be03-la-costura-y-el-reemplazo.md) | 10h |",1)
s=s.replace("""**Escritas: `be00` y `be01`.** Las siete fases restantes, los doce apéndices y
`cuaderno-incidentes-be.md` están pendientes. El track no se puede empezar
todavía: `be00` y `be01` se sostienen solas —auditan el mock y levantan el
servidor— pero la continuidad real arranca cuando exista `be03`.""",
"""**Escritas: `be00` a `be03`**, o sea el bloque que va de auditar el contrato a
apagar el mock con la aplicación sin enterarse. Las cinco fases restantes, los
doce apéndices y `cuaderno-incidentes-be.md` están pendientes. Los dos apéndices
que hacen falta para poder empezar son **`be-a-02`** (imagen y compose) y
**`be-a-12`** (el generador del volcado sintético de `be02`).""",1)
io.open(p,'w',encoding='utf-8').write(s)

p='prompts/propuesta-fases-backend.md'; s=io.open(p,encoding='utf-8').read()
old="""Dicho eso, la semilla real no alcanza para todo: tres pacientes no permiten medir
deriva de esquema ni encontrar eslabones huérfanos. Por eso `be02` entrega
**además** un dump sintético "de producción" con las cinco formas del documento y
las referencias rotas ya adentro. Es la única vez que el track entrega datos
ajenos, y la fase lo declara."""
new="""Dicho eso, la semilla real no alcanza para todo: tres pacientes no permiten medir
deriva de esquema ni encontrar eslabones huérfanos. Por eso `be02` entrega
**además** un dump sintético "de producción" con las cinco formas del documento y
las referencias rotas ya adentro. Es la única vez que el track entrega datos
ajenos, y la fase lo declara.

🪦 **La forma exacta del dump quedó cerrada al escribir `be02` (10/09/2026)** y
vive en su §5.3: 4.820 pacientes repartidos en cinco formas —la actual (2.443);
la de 2019 sin `active` (747); la de la importación de 2020 con `name` y
`_source` en vez de `fullName` (718); la de 2021 con el correo movido a un
subdocumento `contact` y `birthDate` como `BSON Date` (848); y un intento previo
de ese mismo cambio con `phone` al nivel superior (64)—, más 37 órdenes
huérfanas, la partición 3908/912 de tipos en `birthDate` y las tres poblaciones
de vacío en `email` (1630 ausente / 912 `null` / 247 cadena vacía). Generador
determinista con semilla fija en `be-a-12`. **El dump vive en una base aparte de
la semilla del alumno**, decisión de `be03`, para que las mediciones sigan siendo
reproducibles mientras la aplicación corre sobre datos limpios."""
assert old in s; s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)

p='prompts/prompts-backend-fase.md'; s=io.open(p,encoding='utf-8').read()
old="""- **Decide y déjalo escrito:** la forma exacta del dump sintético "de producción"
  que la fase entrega. Es la única vez que el track da datos ajenos, y la fase
  tiene que declararlo. Propongo cinco formas del documento de paciente y al
  menos tres órdenes huérfanas, con el generador documentado en `be-a-12` para
  que sea reproducible."""
new="""- 🪦 **Cerrado al escribir la fase (10/09/2026).** El dump es de 4.820 pacientes
  en cinco formas fechadas, 37 órdenes huérfanas, `birthDate` partido 3908/912
  entre `string` y `date`, y `email` en tres poblaciones (1630 ausente / 912
  `null` / 247 cadena vacía). Está en `be02` §5.3 y replicado en §11 de la
  propuesta. Generador determinista en `be-a-12`; el dump vive en **una base
  aparte** de la semilla del alumno."""
assert old in s; s=s.replace(old,new,1)

old2="""- **Decide y déjalo escrito:** cómo se genera el `id` entero. Propongo una
  colección de contadores al estilo de 2019 —que es lo que habría hecho el equipo
  y trae su propio problema de concurrencia, que be05 recoge—, y **no**
  `ObjectId` truncado ni hash."""
new2="""- 🪦 **Cerrado al escribir la fase (10/09/2026):** colección `counters` con
  `findAndModify` + `$inc` al estilo de 2019, más un índice **único** sobre
  `legacyId` como red. Ni `ObjectId` truncado ni hash. La fase muestra antes el
  `max + 1` ingenuo y **mide la carrera** —que en json-server no existe porque
  Node tiene un solo hilo y en Spring MVC sí, con doscientos—, que es el
  incidente `be-04`. El límite de `findAndModify` (atómico sobre **un**
  documento) queda nombrado ahí para que `be05` lo recoja."""
assert old2 in s; s=s.replace(old2,new2,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY

# --- 2026-09-10T23:31:49 · Mark be04 and be05 as written in README
python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("| 📜 be04 · El audit log que escribía el navegador | `be04-el-audit-log-que-escribia-el-navegador.md` | 8h |",
 "| 📜 be04 · El audit log que escribía el navegador ✅ | [`be04-el-audit-log-que-escribia-el-navegador.md`](be04-el-audit-log-que-escribia-el-navegador.md) | 8h |",1)
s=s.replace("| ⛓️ be05 · La cadena de custodia y la transacción que no existe ⭐⭐ | `be05-la-cadena-de-custodia-y-la-transaccion.md` | 10h |",
 "| ⛓️ be05 · La cadena de custodia y la transacción que no existe ⭐⭐ ✅ | [`be05-la-cadena-de-custodia-y-la-transaccion.md`](be05-la-cadena-de-custodia-y-la-transaccion.md) | 10h |",1)
s=s.replace("""**Escritas: `be00` a `be03`**, o sea el bloque que va de auditar el contrato a
apagar el mock con la aplicación sin enterarse. Las cinco fases restantes, los""",
"""**Escritas: `be00` a `be05`**, o sea desde auditar el contrato hasta la fase
insignia —la transacción que el `mongod` suelto de 2019 rechaza—. Las tres fases
restantes, los""",1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY
grep -n 'be0[0-8]' README.md | head -20

# --- 2026-09-10T23:32:05 · Close be04 pendiente in prompts file
python3 - <<'PY'
import io
p='prompts/prompts-backend-fase.md'; s=io.open(p,encoding='utf-8').read()
old="""- Nada bloqueante. **Decide y déjalo escrito:** si el backend rechaza o acepta el
  asiento que manda el frontend. Propongo aceptarlo y guardarlo en una colección
  aparte marcada como `client_reported`, porque tirarlo destruiría la evidencia
  que la propia fase quiere medir."""
new="""- 🪦 **Cerrado al escribir la fase (10/09/2026), con una inversión declarada
  respecto de lo que proponía este prompt.** El asiento del cliente se acepta —
  tirarlo destruiría la evidencia— pero **la colección aparte es la del
  servidor**, `auditLogServer`, no la del cliente: `auditLog` se queda intacta y
  `GET /auditLog` sigue devolviendo exactamente lo que devolvía. El motivo es de
  contrato: si el servidor escribiera en `auditLog`, la timeline de la Fase 11
  mostraría asientos que el navegador nunca escribió, con otro formato de `id` y
  otro actor, y eso es cambiar el comportamiento observable sin haberlo decidido.
  El patrón es *shadow write* y está nombrado como tal en la fase.
- 🪦 **Segunda decisión cerrada, y no estaba en este prompt:** el backend
  **verifica la firma del token y NO verifica la expiración**. Rechazar por `exp`
  es un `401`, y un `401` cierra la sesión con un TTL de 120 s sin refresh: sería
  apagar el producto. La decisión va fechada en `CONTRACT.md` con su condición de
  revisión."""
assert old in s; s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY

# --- 2026-09-10T23:42:08 · Find debt list and range model details
grep -n '💸' prompts/propuesta-fases-backend.md | head -20; echo "=== fase 8 rangos ==="; grep -n 'rangeVersionApplied\|effectiveTo\|version' 08-resultados-rangos.md | head -30

# --- 2026-09-10T23:42:33 · Check mongo image tags on Docker Hub
for t in 4.4 6.0 7.0; do echo -n "$t -> "; curl -s --max-time 20 "https://hub.docker.com/v2/repositories/library/mongo/tags/$t" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('name'),d.get('last_updated'),[i['digest'][:19] for i in d.get('images',[])][:1])" 2>/dev/null || echo fallo; done

# --- 2026-09-10T23:42:41 · List exact mongo patch tags
for p in 4.4 6.0 7.0; do echo "== $p =="; curl -s --max-time 25 "https://hub.docker.com/v2/repositories/library/mongo/tags?page_size=100&name=$p." | python3 -c "
import sys,json,re
d=json.load(sys.stdin)
ns=[r['name'] for r in d.get('results',[]) if re.fullmatch(r'\d+\.\d+\.\d+', r['name'])]
def key(n): return tuple(int(x) for x in n.split('.'))
print(sorted(set(ns), key=key)[-4:])
"; done

# --- 2026-09-10T23:52:18 · Update README and prompts after batch 4
python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("| 🧬 be06 · Los rangos versionados y la historia que se sobrescribió | `be06-los-rangos-y-la-historia-perdida.md` | 10h |",
 "| 🧬 be06 · Los rangos versionados y la historia que se sobrescribió ✅ | [`be06-los-rangos-y-la-historia-perdida.md`](be06-los-rangos-y-la-historia-perdida.md) | 10h |",1)
s=s.replace("| 📅 be07 · La subida que nadie decidió: 4.0 → 4.4 → 6.0 → 7.0 | `be07-la-subida-que-nadie-decidio.md` | 8h |",
 "| 📅 be07 · La subida que nadie decidió: 4.0 → 4.4 → 6.0 → 7.0 ✅ | [`be07-la-subida-que-nadie-decidio.md`](be07-la-subida-que-nadie-decidio.md) | 8h |",1)
s=s.replace("""**Escritas: `be00` a `be05`**, o sea desde auditar el contrato hasta la fase
insignia —la transacción que el `mongod` suelto de 2019 rechaza—. Las tres fases
restantes, los""","""**Escritas: `be00` a `be07`.** Falta solo `be08`, el cierre. Los""",1)
io.open(p,'w',encoding='utf-8').write(s)

p='prompts/prompts-backend-fase.md'; s=io.open(p,encoding='utf-8').read()
old="""- **Decide y déjalo escrito:** si el modelo bitemporal se implementa completo o
  se declara y se implementa solo la mitad que el sistema en decomisión puede
  sostener. Propongo lo segundo, con la razón escrita — es más honesto y coherente
  con el veredicto del track."""
new="""- 🪦 **Cerrado al escribir la fase (10/09/2026): se declara entero y se implementa
  la mitad.** Append-only sobre `referenceRanges` (solo se puede escribir
  `effectiveTo`, nunca los valores), más `recordedAt`/`recordedBy` como medio eje
  de tiempo de registro, más una guarda de inmutabilidad en la aplicación. El eje
  de registro completo **no** se implementa, con tres razones escritas: no
  recupera nada, encarece cada lectura de un sistema con dos años de vida, y no
  tendría consumidor porque el frontend no se toca. La declaración va fechada en
  `CONTRACT.md` con su condición de revisión."""
assert old in s; s=s.replace(old,new,1)

old2="""- ⚠️ Fijar los tags exactos de los escalones intermedios (`4.4.x`, `6.0.x`).
  Afecta solo a la tabla de evidencia; verifícalos contra el registro, no de
  memoria."""
new2="""- 🪦 **Cerrado al escribir la fase (10/09/2026), verificado contra el registro:**
  `4.0.28`, `4.4.30`, `6.0.28` y `7.0.41` son los últimos parches visibles de cada
  línea a esa fecha. La propia fase declara que van a cambiar y convierte esa
  comprobación en su ejercicio 2 — un tag flotante que apunta hoy a un parche y
  mañana a otro **es** el tema del capítulo."""
assert old2 in s; s=s.replace(old2,new2,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY

# --- 2026-09-11T00:04:35 · Check Testcontainers versions on Maven Central
curl -s --max-time 20 "https://search.maven.org/solrsearch/select?q=g:org.testcontainers+AND+a:testcontainers&core=gav&rows=8&wt=json" | python3 -c "
import sys,json
d=json.load(sys.stdin)['response']['docs']
print([x['v'] for x in d])
" 2>/dev/null || echo "fallo"

# --- 2026-09-11T00:05:01 · Fetch Testcontainers metadata
curl -s --max-time 25 "https://repo1.maven.org/maven2/org/testcontainers/testcontainers/maven-metadata.xml" | grep -E '<latest>|<release>|<version>1\.(1[5-9]|2[0-9])' | tail -20

# --- 2026-09-11T00:05:09 · Check Testcontainers Java target
curl -s --max-time 25 "https://repo1.maven.org/maven2/org/testcontainers/testcontainers/1.21.4/testcontainers-1.21.4.pom" | grep -iE 'java|target|source|release' | head -10; echo "=== 1.17.6 ==="; curl -s --max-time 25 "https://repo1.maven.org/maven2/org/testcontainers/testcontainers/1.17.6/testcontainers-1.17.6.pom" | grep -iE 'java|target|source' | head -5

# --- 2026-09-11T00:05:19 · Check Testcontainers bytecode target version
cd /tmp && for v in 1.21.4 1.19.8 1.17.6; do curl -s --max-time 40 -o tc-$v.jar "https://repo1.maven.org/maven2/org/testcontainers/testcontainers/$v/testcontainers-$v.jar" && python3 -c "
import zipfile,sys
v='$v'
z=zipfile.ZipFile('tc-'+v+'.jar')
n=[x for x in z.namelist() if x.endswith('GenericContainer.class')][:1]
d=z.read(n[0])[:8]
major=int.from_bytes(d[6:8],'big')
print(v, 'class major', major, '-> Java', major-44)
"; done

# --- 2026-09-11T00:05:31 · Check Testcontainers version managed by Boot BOM
curl -s --max-time 25 https://repo1.maven.org/maven2/org/springframework/boot/spring-boot-dependencies/2.1.18.RELEASE/spring-boot-dependencies-2.1.18.RELEASE.pom | grep -E 'testcontainers|slf4j\.version|junit' | head

# --- 2026-09-11T00:10:51 · Update README for be08
cd angular-8-legacy-for-backend-devs && python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("| 🧯 be08 · La contención medida y la declaración de lo irrecuperable | `be08-la-contencion-y-lo-irrecuperable.md` | 10h |",
 "| 🧯 be08 · La contención medida y la declaración de lo irrecuperable ✅ | [`be08-la-contencion-y-lo-irrecuperable.md`](be08-la-contencion-y-lo-irrecuperable.md) | 10h |",1)
s=s.replace("## 🔥 Track opcional de backend (en escritura)","## 🔥 Track opcional de backend (nueve fases escritas)",1)
s=s.replace("""**Escritas: `be00` a `be07`.** Falta solo `be08`, el cierre. Los
doce apéndices y
`cuaderno-incidentes-be.md` están pendientes. El track no se puede empezar
todavía: `be00` y `be01` se sostienen solas —auditan el mock y levantan el
servidor— pero la continuidad real arranca cuando exista `be03`.""","x",1)
io.open(p,'w',encoding='utf-8').write(s)
PY
sed -n '138,152p' README.md

# --- 2026-09-11T00:11:03 · Finalize README and count BE phase words
python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()
old="""**Escritas: `be00` a `be07`.** Falta solo `be08`, el cierre. Los
doce apéndices y `cuaderno-incidentes-be.md` están pendientes. Los dos apéndices
que hacen falta para poder empezar son **`be-a-02`** (imagen y compose) y
**`be-a-12`** (el generador del volcado sintético de `be02`)."""
new="""**Las nueve fases están escritas, de `be00` a `be08`.** Faltan los doce
apéndices y `cuaderno-incidentes-be.md`, cuyos doce IDs (`be-01`–`be-12`) ya
están reservados por las fases que los producen. Los dos apéndices que hacen
falta para que el track se pueda empezar de verdad son **`be-a-02`** (receta de
imagen y compose) y **`be-a-12`** (el generador del volcado sintético de
`be02`); el resto son consulta bajo demanda."""
assert old in s; s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)
PY
grep -n '✅\|nueve fases escritas' README.md | head; echo "=== wc fases BE ==="; wc -w be0*.md

# --- 2026-09-11T00:11:25 · Close remaining pendientes in proposal and prompts
python3 - <<'PY'
import io
p='prompts/propuesta-fases-backend.md'; s=io.open(p,encoding='utf-8').read()
old="""2. **La estrategia de pruebas contra Mongo** en `be08`: Testcontainers en una
   versión que todavía soporte Java 8, contra levantar el `mongo:4.0` del compose
   y limpiar entre tests ⚠️. Se decide midiendo el tiempo de ciclo, que es el
   criterio que ya gobierna el resto del track.
3. **Los tags intermedios de la cadena** (`4.4.x`, `6.0.x` exactos ⚠️). Solo
   afectan a la tabla de evidencia de `be07`."""
new="""2. 🪦 **La estrategia de pruebas — cerrada al escribir `be08` (10/09/2026).**
   Se corre contra **el `mongo:4.0` del compose**, con limpieza entre pruebas.
   El tiempo de ciclo lo confirma (~4 s la suite entera contra ~31 s con
   Testcontainers), pero **lo decide otra cosa**: `MongoDBContainer` de
   Testcontainers arranca la base **como replica set de un solo nodo**, así que
   las pruebas correrían sobre una topología que da garantías que producción no
   da — un `@Transactional` verde en el pipeline y rechazado con el código 20 en
   producción. La regla que queda escrita: *un entorno de pruebas mejor que
   producción no es un entorno de pruebas.* Java 8 no era el problema:
   verificado que Testcontainers 1.21.4 sigue compilando a *class file* 52. Se
   revisa solo si LabCore se convierte a replica set.
3. 🪦 **Los tags intermedios — cerrados al escribir `be07` (10/09/2026)**, contra
   el registro: `4.0.28`, `4.4.30`, `6.0.28` y `7.0.41`. La fase declara que van
   a cambiar y convierte esa comprobación en su ejercicio 2: un tag flotante que
   hoy apunta a un parche y mañana a otro **es** el tema del capítulo."""
assert old in s; s=s.replace(old,new,1)
s=s.replace("""**Todo fijado. Ninguna versión queda pendiente**, salvo las tres marcadas ⚠️, que
son de detalle y no bloquean ninguna fase.""","""**Todo fijado.** Las tres ⚠️ que quedaban abiertas se cerraron al escribir las
fases que las necesitaban; §5.5 conserva cada una con su 🪦 y su resolución.""",1)
io.open(p,'w',encoding='utf-8').write(s)

p='prompts/prompts-backend-fase.md'; s=io.open(p,encoding='utf-8').read()
old2="""- ⚠️ **La estrategia de pruebas** (Testcontainers en una versión que aún soporte
  Java 8, contra levantar el `mongo:4.0` del compose y limpiar entre tests). Hay
  que **medir** las dos y decidir aquí, no arrastrarlo."""
new2="""- 🪦 **Cerrado al escribir la fase (10/09/2026): el `mongo:4.0` del compose**, con
  limpieza entre pruebas. Los dos tiempos de ciclo están medidos (~4 s contra
  ~31 s), pero el criterio que decide es otro y apareció al medir:
  `MongoDBContainer` arranca un **replica set de un nodo**, o sea que las pruebas
  tendrían transacciones y producción no. Java 8 no era el obstáculo —
  Testcontainers 1.21.4 sigue compilando a *class file* 52, verificado—."""
assert old2 in s; s=s.replace(old2,new2,1)

old3="""Cuando las nueve fases estén escritas, quedan tres piezas fuera de este archivo:"""
new3="""**Las nueve fases están escritas (10/09/2026).** Quedan dos piezas fuera de este
archivo:"""
assert old3 in s; s=s.replace(old3,new3,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY

# --- 2026-09-11T00:11:32 · Check structure of all BE phases
for f in be0*.md; do echo "== $f"; grep -c '^## ' $f | tr '\n' ' '; grep -o '🧪 7. Ejercicios ([0-9]*)' $f; grep -c '🏷️ \*\*No cierres la fase sin el tag' $f | tr '\n' ' '; grep -o 'be-fase-0[0-8][a-z-]*' $f | head -1; done

# --- 2026-09-11T00:11:41 · Verify exercise counts match
for f in be0*.md; do n=$(awk '/^## 🧪 7\./,/^## 📚 8\./' $f | grep -cE '^[0-9]+\. '); d=$(grep -o 'Ejercicios ([0-9]*)' $f | grep -o '[0-9]*'); echo "$f declarados=$d reales=$n"; done

# --- 2026-09-11T00:11:47 · Read existing memory file
cat /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/tracks-be-angular-decisiones.md

# --- 2026-09-11T00:12:08 · Update project memory
python3 - <<'PY'
import io
p='/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/tracks-be-angular-decisiones.md'
s=io.open(p,encoding='utf-8').read()
s=s.replace("description: Los tracks BE de angular-8 (LabCore) y angular-16 (CertCore) están propuestos y versionados; falta escribir las fases.",
 "description: Track BE de angular-8 (LabCore) escrito entero (be00-be08); el de angular-16 (CertCore) sigue solo propuesto.")
old="""Estado al 9/09/2026: **escritas las 2 propuestas, los 4 archivos de prompts
(fase y apéndice por curso) y todas las adiciones de encuadre** —READMEs, guías
de estilo, alcance, convención de git, cuadernos y CLAUDE.md—. Las historias de
sistema ya llevan el backend (una "Era 0 (2016-2018)" en CertCore, una sección
"la otra mitad del sistema" en LabCore). **Ninguna fase `beNN` está escrita
todavía**, ni los `cuaderno-incidentes-be.md`."""
new="""Estado al **10/09/2026**: el encuadre de los dos cursos está completo (2
propuestas, 4 archivos de prompts, READMEs, guías, alcance, convención de git,
cuadernos y CLAUDE.md), y las historias de sistema ya llevan el backend
("Era 0 (2016-2018)" en CertCore, "la otra mitad del sistema" en LabCore).

**LabCore (angular-8): las nueve fases `be00`–`be08` están escritas**, ~71.000
palabras, 270 ejercicios, en cinco tandas. Faltan sus 12 apéndices y
`cuaderno-incidentes-be.md` (los 12 IDs `be-01`–`be-12` ya están reservados por
las fases). Los dos apéndices que bloquean empezar el track son `be-a-02`
(imagen y compose) y `be-a-12` (el generador del volcado sintético de `be02`).
**CertCore (angular-16) sigue solo propuesto: ninguna fase escrita.**

Decisiones cerradas al escribir LabCore, todas replicadas con 🪦 en la propuesta
y en los prompts: Spring Boot **2.1.18.RELEASE** (última de la línea, EOL
1/11/2020; su BOM fija el driver mongo **3.8.2**, que es por qué nadie tocó el
`pom.xml` nunca); volcado sintético de 4.820 pacientes en 5 formas fechadas +
37 órdenes huérfanas, en **base aparte** de la semilla del alumno; `id` entero
por colección `counters` con `findAndModify`; bitácora del servidor en
`auditLogServer` —**la colección aparte es la del servidor, no la del cliente**,
para que `GET /auditLog` no cambie—; token con **firma verificada y expiración
no verificada** (TTL de 120 s sin refresh: rechazar apagaría el producto);
medio modelo bitemporal (append-only + `recordedAt`), declarado; tags
`4.0.28 / 4.4.30 / 6.0.28 / 7.0.41`; y pruebas contra el `mongo:4.0` del compose
—no Testcontainers, cuyo `MongoDBContainer` arranca un replica set y daría
transacciones en pruebas que producción no tiene—.

Dos correcciones de contrato que salieron de auditar el mock y que valen para
cualquier edición futura: la colección de auditoría se llama **`auditLog`**, no
`auditEntries` (lo exige el `AuditService` de la Fase 11 y el frontend no se
toca), y **`custodyLinks` no existe** —la custodia vive embebida en la muestra—.
Las dos están corregidas en §16.4 de la guía de estilo."""
assert old in s; s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)

p2='/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/MEMORY.md'
m=io.open(p2,encoding='utf-8').read()
m=m.replace("[Decisiones de los tracks BE de Angular](tracks-be-angular-decisiones.md) — LabCore=Mongo+Java, CertCore=Lumen+Postgres; propuestas y prompts ya versionados, faltan las fases.",
 "[Decisiones de los tracks BE de Angular](tracks-be-angular-decisiones.md) — LabCore (angular-8) con sus 9 fases ya escritas y sus decisiones cerradas; CertCore (angular-16) aún solo propuesto.")
io.open(p2,'w',encoding='utf-8').write(m)
print('ok')
PY

# --- 2026-09-11T00:29:50 · Verify the dump numbers are internally consistent
python3 - <<'PY'
A,B,C,D,E = 2379,747,718,912,64
print("total", A+B+C+D+E)
print("fullName (A+B+D+E)", A+B+D+E)
print("active   (A+D+E)  ", A+D+E)
print("email    (A+B+E)  ", A+B+E)
print("contact  (D)      ", D)
print("name/_source (C)  ", C)
print("phone    (E)      ", E)
print("birthDate string  ", A+B+C+E, " date", D)
print("email ausente C+D ", C+D)
PY

# --- 2026-09-11T00:30:25 · Fix dump numbers across be02 and be08
python3 - <<'PY'
import io
p='be02-medir-la-deriva-de-esquema.md'; s=io.open(p,encoding='utf-8').read()

old="""| **A** | `documentId, fullName, birthDate, email, active` | 2.443 | La actual. Lo que `Patient.java` cree que hay |
| **B** | `documentId, fullName, birthDate, email` | 747 | **Era 1 (2019).** `active` no existía: la baja lógica llegó después |
| **C** | `documentId, name, birthDate, email, _source` | 718 | **La importación de 2020.** `name`, no `fullName`. `_source: "legacy-import"` |
| **D** | `documentId, fullName, birthDate, contact, active` | 848 | **Era 3 (2021).** El correo se movió a un subdocumento… para los nuevos |
| **E** | `documentId, fullName, birthDate, email, phone, active` | 64 | Un intento anterior del mismo cambio, con `phone` al nivel superior. Duró tres semanas |"""
new="""| **A** | `documentId, fullName, birthDate, email, active` | 2.379 | La actual. Lo que `Patient.java` cree que hay |
| **B** | `documentId, fullName, birthDate, email` | 747 | **Era 1 (2019).** `active` no existía: la baja lógica llegó después |
| **C** | `documentId, name, birthDate, _source` | 718 | **La importación de 2020.** `name`, no `fullName`. Y **sin correo**: el sistema de origen no lo traía |
| **D** | `documentId, fullName, birthDate, contact, active` | 912 | **Era 3 (2021).** El correo se movió a un subdocumento… para los nuevos |
| **E** | `documentId, fullName, birthDate, email, phone, active` | 64 | Un intento anterior del mismo cambio, con `phone` al nivel superior. Duró tres semanas |"""
assert old in s; s=s.replace(old,new,1)

old="""- **Las dos líneas que importan son `name` y `contact`**, y no porque sean muchas: porque **no existen en `Patient.java`**. Cada una es un pedazo de historia del sistema que el código actual no sabe leer. Los 718 documentos con `name` son la importación de 2020. Los 912 con `contact` son un cambio de 2021 que se aplicó a los nuevos y a nadie más.
- `fullName` aparece 4.102 veces sobre 4.820 documentos. La resta —718— es exactamente el otro número. Cuando dos mediciones independientes suman el total, tienes una hipótesis; cuando no suman, tienes un tercer caso que todavía no viste."""
new="""- **Las dos líneas que importan son `name` y `contact`**, y no porque sean muchas: porque **no existen en `Patient.java`**. Cada una es un pedazo de historia del sistema que el código actual no sabe leer. Los 718 documentos con `name` son la importación de 2020. Los 912 con `contact` son un cambio de 2021 que se aplicó a los nuevos y a nadie más.
- `fullName` aparece 4.102 veces sobre 4.820 documentos. La resta —718— es exactamente el otro número. Cuando dos mediciones independientes suman el total, tienes una hipótesis; cuando no suman, tienes un tercer caso que todavía no viste.
- `email` aparece 3.190 veces, y 4.820 − 3.190 = 1.630. Esa resta **no** cuadra con ninguna forma sola: son dos (718 + 912). Guárdala, porque es la mitad de la pieza forense del §5.6."""
assert old in s; s=s.replace(old,new,1)

old="""db.patients.count({ email: null });     // 2542"""
new="""db.patients.count({ email: null });     // 2536"""
assert old in s; s=s.replace(old,new,1)

old="""db.patients.count({ email: { $exists: false } });      // 1630  campo AUSENTE
db.patients.count({ email: { $type: 'null' } });       //  912  campo con valor null
db.patients.count({ email: '' });                      //  247  cadena vacía"""
new="""db.patients.count({ email: { $exists: false } });      // 1630  campo AUSENTE
db.patients.count({ email: { $type: 'null' } });       //  906  campo con valor null
db.patients.count({ email: '' });                      //  247  cadena vacía"""
assert old in s; s=s.replace(old,new,1)

old="""Mira los números. `1630 + 912 = 2542`, que es exactamente lo que devolvió el intento 1: **`{ email: null }` en MongoDB significa "el campo es null O el campo no existe"**."""
new="""Mira los números. `1630 + 906 = 2536`, que es exactamente lo que devolvió el intento 1: **`{ email: null }` en MongoDB significa "el campo es null O el campo no existe"**."""
assert old in s; s=s.replace(old,new,1)

old="""La respuesta correcta a la pregunta del negocio es **2.789**, y no la da ninguna consulta de una línea."""
new="""La respuesta correcta a la pregunta del negocio es **2.783**, y no la da ninguna consulta de una línea."""
assert old in s; s=s.replace(old,new,1)

old="""- **Ausente (1.630):** documentos de la forma **B** y **D**, escritos por versiones del código donde el campo no existía en ese nivel. Nunca hubo un correo que guardar.
- **`null` (912):** el campo existe y está vacío. Alguien lo escribió explícitamente: un formulario que envió el campo sin valor. **Hubo una interacción.**"""
new="""- **Ausente (1.630):** documentos de las formas **C** y **D**. En la C el sistema de origen no traía correo; en la D el correo está, pero un nivel más abajo, dentro de `contact`. Dos historias distintas que la misma consulta mete en el mismo saco.
- **`null` (906):** el campo existe y está vacío. Alguien lo escribió explícitamente: un formulario que envió el campo sin valor. **Hubo una interacción.**"""
assert old in s; s=s.replace(old,new,1)

old="""13. Reproduce el ejercicio de los tres `null` del §5.6 y confirma que `1630 + 912 = 2542`."""
new="""13. Reproduce el ejercicio de los tres `null` del §5.6 y confirma que `1630 + 906 = 2536`."""
assert old in s; s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)

p='be08-la-contencion-y-lo-irrecuperable.md'; s=io.open(p,encoding='utf-8').read()
s=s.replace("| 3 | Poblaciones distintas de \"sin correo\" | **3** (1630/912/247) | be02 | Declarar |",
            "| 3 | Poblaciones distintas de \"sin correo\" | **3** (1630/906/247) | be02 | Declarar |",1)
s=s.replace("Son las formas **B**, **C** y **D** de `be02`, o sea un tercio de la colección.",
            "Son las formas **C** y **D** de `be02` —718 sin `fullName` y 912 con `birthDate` de tipo `date`—, o sea un tercio de la colección.",1)
s=s.replace("Los que fallan son exactamente los 1.630 de las formas B, C y D.",
            "Los que fallan son exactamente los 1.630 de las formas C y D.",1)
s=s.replace("Causa: se subió el nivel sin haber medido cuántos documentos no pasan","Causa: se subió el nivel sin haber medido cuántos documentos no pasan",1)
s=s.replace("**los 1.630 documentos de las formas B, C y D**","**los 1.630 documentos de las formas C y D**",1)
s=s.replace("los 1.630 documentos de las formas B, C y D","los 1.630 documentos de las formas C y D")
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY
grep -n '1630\|906\|2536\|formas C y D\|2.783' be02-medir-la-deriva-de-esquema.md be08-la-contencion-y-lo-irrecuperable.md | head -20

# --- 2026-09-11T00:36:01 · Update README with appendix table
python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()
old="""Los doce apéndices `be-a-01`–`be-a-12` están tabulados en §8 de la propuesta, y
sus nombres de archivo se fijan al escribirlos."""
new="""| Apéndice | Archivo |
|---|---|
| ☕ be-a-01 · Java 8 y Spring para quien no escribe Java ✅ | [`be-a-01-java-8-y-spring-para-quien-no-escribe-java.md`](be-a-01-java-8-y-spring-para-quien-no-escribe-java.md) |
| 🐳 be-a-02 · Receta de imagen y compose ✅ | [`be-a-02-receta-de-imagen-y-compose.md`](be-a-02-receta-de-imagen-y-compose.md) |
| 🧩 be-a-03 · Modelar documentos: ¿embeber o referenciar? | `be-a-03-modelar-documentos-embeber-o-referenciar.md` |
| 🔬 be-a-04 · Agregaciones como instrumento de medida | `be-a-04-agregaciones-como-instrumento-de-medida.md` |
| 🗂️ be-a-05 · Índices y `explain()` en MongoDB | `be-a-05-indices-y-explain-en-mongodb.md` |
| 🧪 be-a-06 · `$jsonSchema` sobre datos sucios | `be-a-06-jsonschema-sobre-datos-sucios.md` |
| ⛓️ be-a-07 · Transacciones, replica sets y el standalone | `be-a-07-transacciones-replica-sets-y-el-standalone.md` |
| 🕰️ be-a-08 · Tiempo, zonas y fechas en Mongo | `be-a-08-tiempo-zonas-y-fechas-en-mongo.md` |
| 🔴 be-a-09 · Cassandra: la tentación y el acierto que nadie tuvo | `be-a-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md` |
| ⚖️ be-a-10 · Riesgo de licencia: SSPL y compañía | `be-a-10-riesgo-de-licencia-sspl.md` |
| 💸 be-a-11 · Mapa de deuda del track BE | `be-a-11-mapa-de-deuda-del-track-be.md` |
| 🔥 be-a-12 · Datos de prueba y volumen ✅ | [`be-a-12-datos-de-prueba-y-volumen.md`](be-a-12-datos-de-prueba-y-volumen.md) |

Sus horas no cuentan en ningún calendario: son consulta bajo demanda, igual que
`a01`–`a13` del track base."""
assert old in s; s=s.replace(old,new,1)
old2="""**Las nueve fases están escritas, de `be00` a `be08`.** Faltan los doce
apéndices y `cuaderno-incidentes-be.md`, cuyos doce IDs (`be-01`–`be-12`) ya
están reservados por las fases que los producen. Los dos apéndices que hacen
falta para que el track se pueda empezar de verdad son **`be-a-02`** (receta de
imagen y compose) y **`be-a-12`** (el generador del volcado sintético de
`be02`); el resto son consulta bajo demanda."""
new2="""**Las nueve fases están escritas, de `be00` a `be08`**, y de los doce apéndices
están **be-a-01**, **be-a-02** y **be-a-12** — que son justo los tres que hacen
falta para poder empezar: el de Java y Spring, la receta del compose, y el
generador del volcado sintético de `be02`. Los otros nueve son consulta bajo
demanda y las fases enlazan a ellos. Falta también `cuaderno-incidentes-be.md`,
cuyos doce IDs (`be-01`–`be-12`) ya están reservados por las fases que los
producen."""
assert old2 in s; s=s.replace(old2,new2,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY
wc -w be-a-0*.md be-a-12*.md

# --- 2026-09-11T01:03:24 · Check custody model fields in phase 7
sed -n '620,660p' 07-muestras-custodia.md

# --- 2026-09-11T01:10:54 · Update README with batch B appendices
python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()
for n,f in [("be-a-03 · Modelar documentos: ¿embeber o referenciar?","be-a-03-modelar-documentos-embeber-o-referenciar.md"),
            ("be-a-04 · Agregaciones como instrumento de medida","be-a-04-agregaciones-como-instrumento-de-medida.md"),
            ("be-a-05 · Índices y `explain()` en MongoDB","be-a-05-indices-y-explain-en-mongodb.md")]:
    old="| %s | `%s` |" % (n,f)
    new="| %s ✅ | [`%s`](%s) |" % (n,f,f)
    assert old in s, old
    s=s.replace(old,new,1)
old="""**Las nueve fases están escritas, de `be00` a `be08`**, y de los doce apéndices
están **be-a-01**, **be-a-02** y **be-a-12** — que son justo los tres que hacen
falta para poder empezar: el de Java y Spring, la receta del compose, y el
generador del volcado sintético de `be02`. Los otros nueve son consulta bajo
demanda y las fases enlazan a ellos. Falta también `cuaderno-incidentes-be.md`,
cuyos doce IDs (`be-01`–`be-12`) ya están reservados por las fases que los
producen."""
new="""**Las nueve fases están escritas, de `be00` a `be08`**, y **seis de los doce
apéndices**: los tres que hacen falta para poder empezar —`be-a-01` de Java y
Spring, `be-a-02` con la receta del compose y `be-a-12` con el generador del
volcado sintético— y los tres del instrumental de MongoDB que `be02` y `be03`
abren en paralelo: `be-a-03`, `be-a-04` y `be-a-05`. Faltan seis apéndices y
`cuaderno-incidentes-be.md`, cuyos doce IDs (`be-01`–`be-12`) ya están
reservados por las fases que los producen."""
assert old in s; s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY
wc -w be-a-*.md | tail -8

# --- 2026-09-11T01:11:02 · Inspect README appendix rows
grep -n 'be-a-0[345]' README.md

# --- 2026-09-11T01:11:10 · Fix README appendix rows
python3 - <<'PY'
import io,re
p='README.md'; s=io.open(p,encoding='utf-8').read()
for f in ["be-a-03-modelar-documentos-embeber-o-referenciar.md",
          "be-a-04-agregaciones-como-instrumento-de-medida.md",
          "be-a-05-indices-y-explain-en-mongodb.md"]:
    old=" | `%s` |" % f
    new=" ✅ | [`%s`](%s) |" % (f,f)
    assert old in s, f
    s=s.replace(old,new,1)
old="""**Las nueve fases están escritas, de `be00` a `be08`**, y de los doce apéndices
están **be-a-01**, **be-a-02** y **be-a-12** — que son justo los tres que hacen
falta para poder empezar: el de Java y Spring, la receta del compose, y el
generador del volcado sintético de `be02`. Los otros nueve son consulta bajo
demanda y las fases enlazan a ellos. Falta también `cuaderno-incidentes-be.md`,
cuyos doce IDs (`be-01`–`be-12`) ya están reservados por las fases que los
producen."""
new="""**Las nueve fases están escritas, de `be00` a `be08`**, y **seis de los doce
apéndices**: los tres que hacen falta para poder empezar —`be-a-01` de Java y
Spring, `be-a-02` con la receta del compose y `be-a-12` con el generador del
volcado sintético— y los tres del instrumental de MongoDB que `be02` y `be03`
abren en paralelo: `be-a-03`, `be-a-04` y `be-a-05`. Faltan seis apéndices y
`cuaderno-incidentes-be.md`, cuyos doce IDs (`be-01`–`be-12`) ya están
reservados por las fases que los producen."""
assert old in s; s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY
grep -n 'be-a-' README.md | sed -n '1,14p'

# --- 2026-09-11T01:20:32 · Update README with batch C appendices
python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()
for f in ["be-a-06-jsonschema-sobre-datos-sucios.md",
          "be-a-07-transacciones-replica-sets-y-el-standalone.md",
          "be-a-08-tiempo-zonas-y-fechas-en-mongo.md"]:
    old=" | `%s` |" % f
    new=" ✅ | [`%s`](%s) |" % (f,f)
    assert old in s, f
    s=s.replace(old,new,1)
old="""**Las nueve fases están escritas, de `be00` a `be08`**, y **seis de los doce
apéndices**: los tres que hacen falta para poder empezar —`be-a-01` de Java y
Spring, `be-a-02` con la receta del compose y `be-a-12` con el generador del
volcado sintético— y los tres del instrumental de MongoDB que `be02` y `be03`
abren en paralelo: `be-a-03`, `be-a-04` y `be-a-05`. Faltan seis apéndices y
`cuaderno-incidentes-be.md`, cuyos doce IDs (`be-01`–`be-12`) ya están
reservados por las fases que los producen."""
new="""**Las nueve fases están escritas, de `be00` a `be08`**, y **nueve de los doce
apéndices**: los de arranque (`be-a-01`, `be-a-02`, `be-a-12`), los del
instrumental de MongoDB (`be-a-03`, `be-a-04`, `be-a-05`) y los de las
garantías (`be-a-06`, `be-a-07`, `be-a-08`). Faltan los tres últimos —los dos
que sacan el track del terreno de MongoDB, `be-a-09` y `be-a-10`, y el mapa de
deuda `be-a-11`— y `cuaderno-incidentes-be.md`, cuyos doce IDs (`be-01`–`be-12`)
ya están reservados por las fases que los producen."""
assert old in s; s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY
wc -w be-a-*.md | tail -4

# --- 2026-09-11T01:47:25 · Check Cassandra image tags
curl -s --max-time 20 "https://hub.docker.com/v2/repositories/library/cassandra/tags?page_size=60" | python3 -c "
import sys,json,re
d=json.load(sys.stdin)
ns=[r['name'] for r in d.get('results',[]) if re.fullmatch(r'\d+\.\d+(\.\d+)?', r['name'])]
def key(n):
    p=[int(x) for x in n.split('.')]
    return p+[0]*(3-len(p))
print(sorted(set(ns), key=key)[-8:])
" 2>/dev/null || echo fallo

# --- 2026-09-11T01:51:46 · Inventory all declared debts in BE phases
grep -n '💸' be0*.md | sed 's/^\(be0[0-8][^:]*\):\([0-9]*\):.*💸/\1 L\2 💸/' | head -40

# --- 2026-09-11T01:52:05 · Check whether the JWT secret debt is declared in be03
grep -n 'JWT_SECRET\|secreto' be03-la-costura-y-el-reemplazo.md be04-el-audit-log-que-escribia-el-navegador.md | head

# --- 2026-09-11T01:52:10 · Read be03 login section
sed -n '455,478p' be03-la-costura-y-el-reemplazo.md

# --- 2026-09-11T01:52:21 · Declare the JWT secret debt in be03
python3 - <<'PY'
import io
p='be03-la-costura-y-el-reemplazo.md'; s=io.open(p,encoding='utf-8').read()
old="""// Los tres usuarios están escritos a mano, igual que en el mock: analista1,
// analista2 y supervisor1, con sus roles. No hay colección de usuarios en
// LabCore, y ese es un hallazgo de be00 que sigue vigente.
String token = Jwts.builder()"""
new="""// Los tres usuarios están escritos a mano, igual que en el mock: analista1,
// analista2 y supervisor1, con sus roles. No hay colección de usuarios en
// LabCore, y ese es un hallazgo de be00 que sigue vigente.
//
// 💸 Y el secreto de firma va literal en el código, igual que en el mock de
// la Fase 3. Lo correcto sería una variable de entorno, y no por purismo:
// un secreto en el repositorio está en el historial de git para siempre, y
// rotarlo exige un despliegue. En este track NO SE PAGA, por dos razones
// escritas: el secreto es de mentira y de dominio público —está impreso en
// el material del curso—, y el sistema no tiene ningún mecanismo de gestión
// de secretos al que llevarlo. be04 vuelve a usar este mismo valor para
// verificar la firma, así que si algún día se mueve, se mueve en los dos
// sitios a la vez.
String token = Jwts.builder()"""
assert old in s; s=s.replace(old,new,1)
old2="""- **[F] El contador de deriva del §5.8** produce un número que tiene que coincidir con el de `be02`."""
new2="""- **[G] El secreto de firma del JWT** va literal en el código y se declara como 💸 en §5.9. `be04` usa el mismo valor; si se mueve a una variable de entorno, se mueve en los dos sitios en el mismo cambio.
- **[F] El contador de deriva del §5.8** produce un número que tiene que coincidir con el de `be02`."""
assert old2 in s; s=s.replace(old2,new2,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY

# --- 2026-09-11T01:54:06 · Check for a base-track debt map
grep -rn 'mapa de deuda\|deuda técnica' --include='*.md' . | grep -v '^./be' | head

# --- 2026-09-11T01:54:28 · Fix the non-existent base-track debt map reference
python3 - <<'PY'
import io
p='be-a-11-mapa-de-deuda-del-track-be.md'; s=io.open(p,encoding='utf-8').read()
old="""> Usado por: be08 · Hermano de `a12-mapa-de-deuda-tecnica.md` del track base"""
new="""> Usado por: be08 · **El track base no tiene un mapa equivalente**: sus 💸 viven declaradas dentro de cada fase (ver más abajo)"""
assert old in s; s=s.replace(old,new,1)
old2="""**Qué queda fuera:** las deudas del **track base** —las del frontend de Angular—, que tienen su propio mapa en [`a12`](./a12-arm64-m1.md) y en las fases que las declararon. Aquí solo se enlazan. Lo que sí aparece es **qué pasó con las cuatro que el track BE vino a cobrar**, porque cerrar ese círculo es media razón de que el track exista."""
new2="""**Qué queda fuera:** las deudas del **track base** —las del frontend de Angular—, que están declaradas con 💸 dentro de cada fase que las contrajo y no se repiten aquí. Lo que sí aparece es **qué pasó con las cuatro que el track BE vino a cobrar**, porque cerrar ese círculo es media razón de que el track exista.

> 📝 **Divergencia declarada, y conviene saberla:** el track base de este curso **no tiene un apéndice de mapa de deuda** —sus trece apéndices son de consulta técnica, y `a12` es el de arm64/Apple Silicon—. Sus 💸 se declaran en el sitio donde nacen, dentro de cada fase, y el inventario consolidado no existe. Este apéndice es, por tanto, **el primero del curso que consolida deuda**, y lo hace solo para el backend. Si algún día se escribe el del track base, esta tabla del §1 es el punto por donde se enganchan los dos."""
assert old2 in s; s=s.replace(old2,new2,1)
io.open(p,'w',encoding='utf-8').write(s)

p='prompts/propuesta-fases-backend.md'; s=io.open(p,encoding='utf-8').read()
old3="""| `be-a-11-mapa-de-deuda-del-track-be.md` | Qué quedó feo a propósito en el backend, qué lo vuelve exigible y en qué orden se pagaría. Hermano de `a12` del track base |"""
new3="""| `be-a-11-mapa-de-deuda-del-track-be.md` | Qué quedó feo a propósito en el backend, qué lo vuelve exigible y en qué orden se pagaría. ⚠️ **Corregido al escribirlo (10/09/2026):** el track base de este curso **no tiene** mapa de deuda —`a12` es el de arm64/Apple Silicon— así que este apéndice no tiene hermano; sus 💸 se declaran dentro de cada fase. La divergencia queda declarada en el propio apéndice |"""
assert old3 in s; s=s.replace(old3,new3,1)
io.open(p,'w',encoding='utf-8').write(s)

p='prompts/prompts-backend-apendice.md'; s=io.open(p,encoding='utf-8').read()
old4="""- Usado por: **be08**; hermano de `a12-mapa-de-deuda-tecnica.md` del track base"""
new4="""- Usado por: **be08**. ⚠️ **Corregido al escribirlo (10/09/2026):** este prompt decía "hermano de `a12-mapa-de-deuda-tecnica.md` del track base", y ese archivo **no existe en este curso** —`a12` es el de arm64/Apple Silicon y el track base no consolida su deuda en ningún apéndice—. El apéndice se escribió sin hermano y con la divergencia declarada dentro"""
assert old4 in s; s=s.replace(old4,new4,1)
old5="""- **Qué queda explícitamente fuera:** las deudas del track base, que ya tienen su
  mapa en `a12`. Enlaza, no repitas."""
new5="""- **Qué queda explícitamente fuera:** las deudas del track base, que se declaran
  con 💸 dentro de cada fase que las contrajo. No se repiten aquí. ⚠️ No hay un
  mapa consolidado del track base al que enlazar: ver la corrección de arriba."""
assert old5 in s; s=s.replace(old5,new5,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY

# --- 2026-09-11T01:54:45 · Update README and prompts after batch D
python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()
for f in ["be-a-09-cassandra-la-tentacion-y-el-acierto-que-nadie-tuvo.md",
          "be-a-10-riesgo-de-licencia-sspl.md",
          "be-a-11-mapa-de-deuda-del-track-be.md"]:
    old=" | `%s` |" % f
    new=" ✅ | [`%s`](%s) |" % (f,f)
    assert old in s, f
    s=s.replace(old,new,1)
old="""**Las nueve fases están escritas, de `be00` a `be08`**, y **nueve de los doce
apéndices**: los de arranque (`be-a-01`, `be-a-02`, `be-a-12`), los del
instrumental de MongoDB (`be-a-03`, `be-a-04`, `be-a-05`) y los de las
garantías (`be-a-06`, `be-a-07`, `be-a-08`). Faltan los tres últimos —los dos
que sacan el track del terreno de MongoDB, `be-a-09` y `be-a-10`, y el mapa de
deuda `be-a-11`— y `cuaderno-incidentes-be.md`, cuyos doce IDs (`be-01`–`be-12`)
ya están reservados por las fases que los producen."""
new="""**Las nueve fases y los doce apéndices están escritos.** Falta una sola pieza:
`cuaderno-incidentes-be.md`, con los doce incidentes cuyos IDs (`be-01`–`be-12`)
ya están reservados por las fases que los producen, cada uno con título
propuesto, categoría y dificultad."""
assert old in s; s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)

p='prompts/prompts-backend-apendice.md'; s=io.open(p,encoding='utf-8').read()
old2="""Con los doce apéndices escritos, del track BE quedan pendientes:

1. **`cuaderno-incidentes-be.md`** — los doce incidentes reservados en
   `prompts-backend-fase.md` (`be-01` … `be-12`).
2. **Las adiciones de encuadre de §10 de `propuesta-fases-backend.md`**, que se
   hacen **antes** de escribir `be00`."""
new2="""**Los doce apéndices están escritos (10/09/2026)**, igual que las nueve fases.
Del track BE queda pendiente **una sola pieza**:

1. **`cuaderno-incidentes-be.md`** — los doce incidentes reservados en
   `prompts-backend-fase.md` (`be-01` … `be-12`), cada uno con título propuesto,
   categoría y dificultad ya fijados por la fase que lo produce.
2. ~~**Las adiciones de encuadre de §10 de `propuesta-fases-backend.md`**~~
   ✅ hechas antes de `be00`."""
assert old2 in s; s=s.replace(old2,new2,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY
ls be*.md | wc -l; wc -w be-a-*.md | tail -1

# --- 2026-09-11T01:55:05 · Update memory after appendices
python3 - <<'PY'
import io
p='/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/tracks-be-angular-decisiones.md'
s=io.open(p,encoding='utf-8').read()
s=s.replace("description: Track BE de angular-8 (LabCore) escrito entero (be00-be08); el de angular-16 (CertCore) sigue solo propuesto.",
 "description: Track BE de angular-8 (LabCore) escrito entero — 9 fases + 12 apéndices; solo falta su cuaderno de incidentes. CertCore (angular-16) sigue solo propuesto.")
old="""**LabCore (angular-8): las nueve fases `be00`–`be08` están escritas**, ~71.000
palabras, 270 ejercicios, en cinco tandas. Faltan sus 12 apéndices y
`cuaderno-incidentes-be.md` (los 12 IDs `be-01`–`be-12` ya están reservados por
las fases). Los dos apéndices que bloquean empezar el track son `be-a-02`
(imagen y compose) y `be-a-12` (el generador del volcado sintético de `be02`).
**CertCore (angular-16) sigue solo propuesto: ninguna fase escrita.**"""
new="""**LabCore (angular-8): las nueve fases `be00`–`be08` y los doce apéndices
`be-a-01`–`be-a-12` están escritos** (~113.000 palabras), en cinco tandas de
fases y cuatro de apéndices. **Falta una sola pieza: `cuaderno-incidentes-be.md`**
— los 12 IDs `be-01`–`be-12` ya están reservados por las fases, cada uno con
título propuesto, categoría y dificultad.
**CertCore (angular-16) sigue solo propuesto: ninguna fase escrita.**

Tres correcciones de coherencia que salieron al escribir los apéndices y que
valen para cualquier edición futura: (1) los números del volcado de `be02` no
cuadraban y se resolvieron con la forma C **sin correo** —A=2379, B=747, C=718,
D=912, E=64; vacíos 1630/906/247—, replicados en `be-a-12` con su generador y su
`verify-dump.sh`; (2) el prompt de `be-a-03` decía que LabCore cometió el error
del arreglo sin techo con la custodia, y **es al revés**: la aplanó en campos
fijos y el audit log va en colección aparte, así que el apéndice explica el
precio de la solución elegida; (3) el prompt de `be-a-11` lo llamaba "hermano de
`a12-mapa-de-deuda-tecnica.md` del track base", **y ese archivo no existe en este
curso** (`a12` es arm64/M1): el track base no consolida su deuda en ningún
apéndice y la divergencia queda declarada."""
assert old in s; s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)

p2='/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/MEMORY.md'
m=io.open(p2,encoding='utf-8').read()
m=m.replace("LabCore (angular-8) con sus 9 fases ya escritas y sus decisiones cerradas; CertCore (angular-16) aún solo propuesto.",
 "LabCore (angular-8) con sus 9 fases y 12 apéndices escritos —solo falta el cuaderno BE—; CertCore (angular-16) aún solo propuesto.")
io.open(p2,'w',encoding='utf-8').write(m)
print('ok')
PY

# --- 2026-09-11T02:06:55 · Read incident notebook format spec
sed -n '1,140p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-11T02:06:57 · Read incident entry spec
sed -n '140,330p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-11T02:06:59 · Read rest of incident template spec
sed -n '330,470p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-11T02:07:02 · Read BE section of incident format spec
sed -n '470,600p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-11T02:07:10 · Read base incident notebook header
sed -n '1,125p' cuaderno-incidentes.md

# --- 2026-09-11T02:07:44 · Read git convention BE section
sed -n '368,420p' 00-convencion-de-git-y-tags.md

# --- 2026-09-11T02:15:32 · Check base notebook BE pointer and branch convention
sed -n '340,370p' cuaderno-incidentes.md; echo "=== convencion ==="; grep -n 'incidente/' 00-convencion-de-git-y-tags.md | head -5

# --- 2026-09-11T02:15:54 · Close conventions and template decisions
python3 - <<'PY'
import io
# 1. Convención de git: ramas del track BE
p='00-convencion-de-git-y-tags.md'; s=io.open(p,encoding='utf-8').read()
old="""commitea con el prefijo de la fase desde la que llegaste. Y los incidentes del
track usan `cuaderno-incidentes-be.md`, con IDs `be-01` … `be-12` que no se cruzan
con los del cuaderno base."""
new="""commitea con el prefijo de la fase desde la que llegaste. Y los incidentes del
track usan `cuaderno-incidentes-be.md`, con IDs `be-01` … `be-12` que no se cruzan
con los del cuaderno base.

Las **ramas** de esos incidentes también llevan namespace propio —`incidente-be/NN`
en vez de `incidente/NN`— y salen del tag `be-fase-*` de la fase que produce el
incidente, con el slug completo:

```bash
git checkout -b incidente-be/05 be-fase-03-la-costura-y-el-reemplazo
```

Los pares de tags conservan la forma del track base con el ID del cuaderno BE
adentro: `inc/be-08/orden-contradice-roto` y `inc/be-08/orden-contradice-fix`.
Así, `git branch --list 'incidente/*'` sigue devolviendo solo las del track base."""
assert old in s; s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)

# 2. Formato del cuaderno: cerrar la §🔥
p='prompts/formato-cuaderno-incidentes.md'; s=io.open(p,encoding='utf-8').read()
old="""Este formato aplica igual a **`cuaderno-incidentes-be.md`**, el cuaderno del track
opcional de backend (Java 8 + Spring Boot 2.1 + MongoDB): mismo esqueleto de
incidente, mismas pistas plegadas, mismo post-mortem sin culpabilización."""
new="""✅ **Escrito el 10/09/2026.** Este formato aplicó igual a
**`cuaderno-incidentes-be.md`**, el cuaderno del track opcional de backend
(Java 8 + Spring Boot 2.1 + MongoDB): mismo esqueleto de incidente, mismas pistas
plegadas, mismo post-mortem sin culpabilización.

> 🪦 **Y por eso `prompts/plantilla-de-incidente-be.md` no se escribió**, aunque
> `propuesta-fases-backend.md` §9 lo dejaba abierto ("si el formato diverge del
> base"). No diverge: la plantilla de §8 se copió literal. Lo único propio del
> track son las cuatro formas de preparación y la excepción de `be-11`, que ya
> están declaradas aquí abajo. **Un archivo de plantilla que duplicara §8 sería
> dos fuentes de verdad para lo mismo**, que es justo lo que este documento
> existe para evitar."""
assert old in s; s=s.replace(old,new,1)
old2="""- **La preparación del sistema roto** no usa el `db.json`: usa el `.env`, una
  migración, o una colección sembrada a propósito. La sección §5 se reescribe
  entera para el track, y los tags viven en el namespace `be-fase-*` para que
  `git tag -l 'fase-*'` siga siendo el índice limpio del track base."""
new2="""- **La preparación del sistema roto** no usa el `db.json`: el dato vive en Mongo.
  La §5 se reescribió entera para el track y quedó en **cuatro** formas, de la
  más barata a la más cara: (1) un flag del inyector de caos, el mismo de la
  Fase 4 reimplementado en Java; (2) una colección sembrada a propósito, con
  guiones `dump/seed-incidente-be-NN.js`; (3) **una línea del `.env`**, que es la
  forma propia del track y la que casi nadie considera —solo la usa `be-11`—; y
  (4) una rama de git. Las ramas llevan namespace propio, `incidente-be/NN`, y
  salen del tag `be-fase-*` con el slug completo; los tags de fase viven en ese
  namespace para que `git tag -l 'fase-*'` siga siendo el índice limpio del track
  base. Todo registrado en `00-convencion-de-git-y-tags.md` §🔥."""
assert old2 in s; s=s.replace(old2,new2,1)
io.open(p,'w',encoding='utf-8').write(s)

# 3. Propuesta §9: la plantilla que no hizo falta
p='prompts/propuesta-fases-backend.md'; s=io.open(p,encoding='utf-8').read()
old3="""| `prompts/plantilla-de-incidente-be.md` | La plantilla de incidente del track, si el formato diverge del base |"""
new3="""| ~~`prompts/plantilla-de-incidente-be.md`~~ | 🪦 **No hizo falta (10/09/2026).** El formato **no** diverge: la plantilla de incidente de `formato-cuaderno-incidentes.md` §8 se usó literal. Lo propio del track —las cuatro formas de preparación y la excepción de `be-11`— vive en la §🔥 de ese mismo documento. Un archivo aparte habría duplicado la fuente de verdad |"""
assert old3 in s; s=s.replace(old3,new3,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY

# --- 2026-09-11T02:16:21 · Update README and prompt closing reminders
python3 - <<'PY'
import io
p='README.md'; s=io.open(p,encoding='utf-8').read()
old="""**Las nueve fases y los doce apéndices están escritos.** Falta una sola pieza:
`cuaderno-incidentes-be.md`, con los doce incidentes cuyos IDs (`be-01`–`be-12`)
ya están reservados por las fases que los producen, cada uno con título
propuesto, categoría y dificultad."""
new="""**El track BE está completo:** las nueve fases, los doce apéndices y
[`cuaderno-incidentes-be.md`](cuaderno-incidentes-be.md) con sus doce incidentes
`be-01`–`be-12`, en un rango de IDs independiente del cuaderno base. Seis de esos
doce **no tienen fix**: tienen una medición, una declaración y un procedimiento,
que es exactamente lo que el track viene a enseñar."""
assert old in s; s=s.replace(old,new,1)
old2="""- 🔥 `beNN-*.md`, `be-a-NN-*.md` y `cuaderno-incidentes-be.md` — el track
  opcional de backend, cuando exista. Su encuadre ya está en
  `prompts/propuesta-fases-backend.md`."""
new2="""- 🔥 `beNN-*.md`, `be-a-NN-*.md` y `cuaderno-incidentes-be.md` — el track
  opcional de backend, completo. Su encuadre está en
  `prompts/propuesta-fases-backend.md`, y su cuaderno de incidentes es **un
  archivo aparte del base**: quien haga solo el track base no recibe incidentes
  de MongoDB mezclados con los suyos."""
assert old2 in s; s=s.replace(old2,new2,1)
io.open(p,'w',encoding='utf-8').write(s)

p='prompts/prompts-backend-apendice.md'; s=io.open(p,encoding='utf-8').read()
old3="""**Los doce apéndices están escritos (10/09/2026)**, igual que las nueve fases.
Del track BE queda pendiente **una sola pieza**:

1. **`cuaderno-incidentes-be.md`** — los doce incidentes reservados en
   `prompts-backend-fase.md` (`be-01` … `be-12`), cada uno con título propuesto,
   categoría y dificultad ya fijados por la fase que lo produce.
2. ~~**Las adiciones de encuadre de §10 de `propuesta-fases-backend.md`**~~
   ✅ hechas antes de `be00`."""
new3="""✅ **El track BE está completo (10/09/2026):** nueve fases, doce apéndices y
`cuaderno-incidentes-be.md` con sus doce incidentes. Nada queda pendiente.

1. ~~**`cuaderno-incidentes-be.md`**~~ ✅ escrito, con los doce IDs `be-01` …
   `be-12` y la escala **6 🟠 · 6 🔴** declarada con su razón: no hay incidentes
   🟢 ni 🟡 porque para llegar aquí hay que haber cerrado once fases del track
   base y sus veintiún incidentes.
2. ~~**Las adiciones de encuadre de §10 de `propuesta-fases-backend.md`**~~
   ✅ hechas antes de `be00`."""
assert old3 in s; s=s.replace(old3,new3,1)
io.open(p,'w',encoding='utf-8').write(s)

p='prompts/prompts-backend-fase.md'; s=io.open(p,encoding='utf-8').read()
old4="""2. **`cuaderno-incidentes-be.md`** — los doce incidentes reservados en los
   prompts de arriba (`be-01` … `be-12`), con IDs propios y sin mezclarse con el
   cuaderno base."""
new4="""2. ~~**`cuaderno-incidentes-be.md`**~~ ✅ **escrito (10/09/2026)**, con los doce
   incidentes reservados en los prompts de arriba (`be-01` … `be-12`), con IDs
   propios y sin mezclarse con el cuaderno base."""
assert old4 in s; s=s.replace(old4,new4,1)
s=s.replace("""1. **`prompts-backend-apendice.md`** — los doce apéndices `be-a-01` … `be-a-12`.""",
            """1. ~~**`prompts-backend-apendice.md`** — los doce apéndices `be-a-01` … `be-a-12`.~~ ✅ **escritos (10/09/2026)**.""",1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY
wc -w cuaderno-incidentes-be.md; ls be*.md cuaderno-incidentes-be.md | wc -l

# --- 2026-09-11T02:16:39 · Update memory and show git status
python3 - <<'PY'
import io
p='/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/tracks-be-angular-decisiones.md'
s=io.open(p,encoding='utf-8').read()
s=s.replace("description: Track BE de angular-8 (LabCore) escrito entero — 9 fases + 12 apéndices; solo falta su cuaderno de incidentes. CertCore (angular-16) sigue solo propuesto.",
 "description: Track BE de angular-8 (LabCore) COMPLETO — 9 fases, 12 apéndices y su cuaderno de 12 incidentes. CertCore (angular-16) sigue solo propuesto.")
old="""**LabCore (angular-8): las nueve fases `be00`–`be08` y los doce apéndices
`be-a-01`–`be-a-12` están escritos** (~113.000 palabras), en cinco tandas de
fases y cuatro de apéndices. **Falta una sola pieza: `cuaderno-incidentes-be.md`**
— los 12 IDs `be-01`–`be-12` ya están reservados por las fases, cada uno con
título propuesto, categoría y dificultad.
**CertCore (angular-16) sigue solo propuesto: ninguna fase escrita.**"""
new="""**LabCore (angular-8) está COMPLETO** (~126.000 palabras): las nueve fases
`be00`–`be08`, los doce apéndices `be-a-01`–`be-a-12` y `cuaderno-incidentes-be.md`
con sus doce incidentes. Nada pendiente.
**CertCore (angular-16) sigue solo propuesto: ninguna fase escrita.**

Del cuaderno BE, dos decisiones: la escala quedó en **6 🟠 · 6 🔴 sin 🟢 ni 🟡**,
declarada con su razón (para llegar ahí hay que haber hecho 11 fases base + sus
21 incidentes, así que no queda ningún incidente de principiante que dar); y
**`prompts/plantilla-de-incidente-be.md` no se escribió** —la propuesta lo dejaba
abierto "si el formato diverge"— porque no diverge: lo propio del track son las
**cuatro** formas de preparación (flag de caos / colección sembrada / **una línea
del `.env`** / rama `incidente-be/NN`) y la excepción de `be-11`, y las dos ya
viven en la §🔥 de `formato-cuaderno-incidentes.md`."""
assert old in s; s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)

p2='/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/MEMORY.md'
m=io.open(p2,encoding='utf-8').read()
m=m.replace("LabCore (angular-8) con sus 9 fases y 12 apéndices escritos —solo falta el cuaderno BE—; CertCore (angular-16) aún solo propuesto.",
 "LabCore (angular-8) completo —9 fases, 12 apéndices y su cuaderno de 12 incidentes—; CertCore (angular-16) aún solo propuesto.")
io.open(p2,'w',encoding='utf-8').write(m)
print('ok')
PY
git -C .. status --short | head -40

# --- 2026-09-11T02:23:50 · Check be-a naming usage across courses
cd .. && ls -d */ && echo "=== be-a files por curso ===" && for d in */; do n=$(ls "$d" 2>/dev/null | grep -c '^be-a-' || true); r=$(grep -rl 'be-a-' "$d" 2>/dev/null | wc -l | tr -d ' '); echo "$d archivos=$n  ficheros-con-referencias=$r"; done

# --- 2026-09-11T02:23:59 · Find the Go appendix and root references
grep -rln 'no-escribe-go\|be-a-01' --include='*.md' . | head -10; echo "=== react be-a ==="; ls react-16-legacy-for-backend-devs/ | grep '^be-a-'; echo "=== CLAUDE/README raiz ==="; grep -n 'be-a-' CLAUDE.md README.md | head

# --- 2026-09-11T02:24:14 · Check for risky be-a- occurrences before global rename
grep -rhoE '.{6}be-a-.{4}' --include='*.md' . | grep -vE 'be-a-[0-9N]' | sort -u | head -20; echo "--- total ocurrencias be-a- ---"; grep -rho 'be-a-' --include='*.md' . | wc -l; echo "--- variantes be-a seguidas de algo raro ---"; grep -rhoE 'be-a[^-]' --include='*.md' . | sort -u | head

# --- 2026-09-11T02:24:19 · Inspect be-a variants without second hyphen
grep -rnoE '.{20}be-a[0-9adlN].{12}' --include='*.md' . | sort -u -t: -k3 | head -20

# --- 2026-09-11T02:24:31 · Rename backend appendix files
for d in angular-8-legacy-for-backend-devs react-16-legacy-for-backend-devs; do for f in $d/be-a-*.md; do n=$(echo "$f" | sed 's|/be-a-|/bea-|'); git mv "$f" "$n" 2>/dev/null || mv "$f" "$n"; done; done; ls angular-8-legacy-for-backend-devs/bea-*.md react-16-legacy-for-backend-devs/bea-*.md | wc -l; ls */be-a-*.md 2>/dev/null | wc -l

# --- 2026-09-11T02:24:38 · Replace be-a- with bea- across all markdown
grep -rl 'be-a-' --include='*.md' . | tee /tmp/tocar.txt | wc -l
while read -r f; do python3 - "$f" <<'PY'
import io,sys
p=sys.argv[1]
s=io.open(p,encoding='utf-8').read()
s2=s.replace('be-a-','bea-')
if s2!=s:
    io.open(p,'w',encoding='utf-8').write(s2)
PY
done < /tmp/tocar.txt
echo "--- restantes be-a- ---"; grep -rho 'be-a-' --include='*.md' . | wc -l
echo "--- bea- ahora ---"; grep -rho 'bea-' --include='*.md' . | wc -l

# --- 2026-09-11T02:24:56 · Locate rationale paragraphs about the naming choice
grep -rn 'be-aNN\|be-a01\|be-a09\|rima local\|rhyme' --include='*.md' . | head -12

# --- 2026-09-11T02:25:00 · Read the rationale paragraphs to rewrite
sed -n '133,140p' CLAUDE.md; echo "=== a8 guia ==="; sed -n '734,740p' angular-8-legacy-for-backend-devs/prompts/guia-de-estilo-y-convenciones.md; echo "=== a8 propuesta ==="; sed -n '740,748p' angular-8-legacy-for-backend-devs/prompts/propuesta-fases-backend.md; echo "=== react ==="; grep -rn 'bea-NN\|bea-01' react-16-legacy-for-backend-devs/prompts/*.md react-16-legacy-for-backend-devs/README.md 2>/dev/null | head -6

# --- 2026-09-11T02:25:21 · Rewrite naming rationale in CLAUDE.md and style guides
python3 - <<'PY'
import io

# ---- CLAUDE.md (raíz) -----------------------------------------------------
p='CLAUDE.md'; s=io.open(p,encoding='utf-8').read()
old="""  This convention is **repo-wide, not React-specific**: the Angular 8 and Angular
  16 courses adopt it for their own backend tracks
  (`prompts/propuesta-fases-backend.md` in each). It holds even where the base
  track uses lowercase `aNN-` appendices and `be-aNN-` would rhyme better
  locally — one name for the same thing across the repository wins over the local
  rhyme, and each course's style guide records that trade-off explicitly."""
new="""  This convention is **repo-wide, not React-specific**: the Angular 8 and Angular
  16 courses adopt it for their own backend tracks
  (`prompts/propuesta-fases-backend.md` in each). It holds even where the base
  track uses lowercase `aNN-` appendices and `beaNN-` would rhyme better
  locally — one name for the same thing across the repository wins over the local
  rhyme, and each course's style guide records that trade-off explicitly.
  > 📝 **Renamed on 2026-09-10: it used to be `be-a-NN-name.md`.** Three
  > hyphen-separated segments before the topic (`be-a-02-receta…`) read as three
  > things instead of one, and the prefix was easy to mistype. `bea-` is a single
  > token, so every file in the repo now has the same shape —
  > `<prefix>-<number>-<topic>`, like `forense-fase-NN` — and the appendix number
  > is the first thing after the prefix. The rename covered both courses that had
  > files (React 16 and Angular 8) plus every cross-reference; if you find a
  > `be-a-NN-` anywhere, it is a leftover and should be fixed."""
assert old in s; s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)

# ---- guías de estilo de angular-8 y angular-16 ----------------------------
old_g="""> 📝 El track base usa `aNN-`, así que `be-aNN-` habría rimado mejor localmente.
> Se elige `bea-NN-` porque es la convención registrada en el `CLAUDE.md` del
> repositorio. Un solo nombre para la misma cosa en todo el repositorio vale más
> que la rima local."""
new_g="""> 📝 El track base usa `aNN-`, así que `beaNN-` habría rimado mejor localmente.
> Se elige `bea-NN-` porque es la convención registrada en el `CLAUDE.md` del
> repositorio. Un solo nombre para la misma cosa en todo el repositorio vale más
> que la rima local.
>
> 🪦 **Renombrado el 10/09/2026: antes era `be-a-NN-`.** Tres segmentos separados
> por guion antes del tema se leían como tres cosas en vez de una. Con `bea-`
> como prefijo único, todo archivo del repositorio tiene la misma forma
> —`<prefijo>-<número>-<tema>`, igual que `forense-fase-NN`— y el número del
> apéndice es lo primero después del prefijo. Si encuentras un `be-a-NN-` en
> algún sitio, es un resto del nombre viejo."""
for p in ['angular-8-legacy-for-backend-devs/prompts/guia-de-estilo-y-convenciones.md',
          'angular-16-legacy-for-backend-devs/prompts/guia-de-estilo-y-convenciones.md']:
    s=io.open(p,encoding='utf-8').read()
    assert old_g in s, p
    io.open(p,'w',encoding='utf-8').write(s.replace(old_g,new_g,1))
print('ok guías')
PY

# --- 2026-09-11T02:25:38 · Rewrite rationale in proposals and verify no leftovers
python3 - <<'PY'
import io
old8="""> 📝 **Sobre `bea-01-` frente a `be-a01-`.** El track base de este curso usa
> `aNN-` (`a09-kubernetes.md`), así que `be-a09-` habría rimado mejor localmente.
> Se elige `bea-NN-` porque es la convención que ya está registrada en el
> `CLAUDE.md` del repositorio y la que usa el track BE de React. **Un solo
> nombre para la misma cosa en todo el repositorio vale más que la rima local.**"""
new8="""> 📝 **Sobre `bea-01-` frente a `bea01-`.** El track base de este curso usa
> `aNN-` (`a09-kubernetes.md`), así que `bea09-` habría rimado mejor localmente.
> Se elige `bea-NN-` porque es la convención que ya está registrada en el
> `CLAUDE.md` del repositorio y la que usa el track BE de React. **Un solo
> nombre para la misma cosa en todo el repositorio vale más que la rima local.**
>
> 🪦 **Renombrado el 10/09/2026: la convención era `be-a-NN-`.** Tres segmentos
> separados por guion antes del tema (`be-a-02-receta…`) se leían como tres cosas
> en vez de una, y el prefijo era fácil de escribir mal. Con `bea-` como prefijo
> único, el nombre tiene la misma forma que el resto del repositorio:
> `<prefijo>-<número>-<tema>`. El cambio se aplicó a los dos cursos que ya tenían
> archivos —React 16 y este— y a todas las referencias cruzadas."""
p='angular-8-legacy-for-backend-devs/prompts/propuesta-fases-backend.md'
s=io.open(p,encoding='utf-8').read(); assert old8 in s
io.open(p,'w',encoding='utf-8').write(s.replace(old8,new8,1))

old16="""> 📝 **Sobre `bea-01-` frente a `be-a01-`.** El track base de este curso usa `aNN-`
> (`a09-docker-kubernetes.md`), así que `be-a09-` habría rimado mejor localmente. Se"""
p='angular-16-legacy-for-backend-devs/prompts/propuesta-fases-backend.md'
s=io.open(p,encoding='utf-8').read(); assert old16 in s
s=s.replace(old16,"""> 📝 **Sobre `bea-01-` frente a `bea01-`.** El track base de este curso usa `aNN-`
> (`a09-docker-kubernetes.md`), así que `bea09-` habría rimado mejor localmente. Se""",1)
old16b="""> que la rima local.**"""
new16b="""> que la rima local.**
>
> 🪦 **Renombrado el 10/09/2026: la convención era `be-a-NN-`.** Se cambió a
> `bea-NN-` en todo el repositorio —tres segmentos antes del tema se leían como
> tres cosas en vez de una— y este curso se alinea antes de escribir su primer
> apéndice, así que no hay ningún archivo que renombrar aquí."""
assert old16b in s
io.open(p,'w',encoding='utf-8').write(s.replace(old16b,new16b,1))
print('ok propuestas')
PY
grep -rn 'be-a-\|be-a0\|be-aN' --include='*.md' . | head

# --- 2026-09-11T02:25:46 · Verify all markdown links resolve
python3 - <<'PY'
import os,re,io
malos=0; total=0
for root,dirs,files in os.walk('.'):
    dirs[:]=[d for d in dirs if d not in ('.git','node_modules')]
    for f in files:
        if not f.endswith('.md'): continue
        p=os.path.join(root,f)
        s=io.open(p,encoding='utf-8',errors='ignore').read()
        for m in re.finditer(r'\]\((\.?/?[^)#\s]+\.md)\)', s):
            dest=m.group(1); total+=1
            full=os.path.normpath(os.path.join(root,dest))
            if not os.path.exists(full):
                print("ROTO", p, "->", dest); malos+=1
print("enlaces .md revisados:", total, "rotos:", malos)
PY

# --- 2026-09-11T02:25:58 · Verify BE appendix links and check non-markdown references
python3 - <<'PY'
import os,re,io
mal=0;tot=0
for root,dirs,files in os.walk('.'):
    dirs[:]=[d for d in dirs if d not in ('.git','node_modules')]
    for f in files:
        if not f.endswith('.md'): continue
        p=os.path.join(root,f)
        s=io.open(p,encoding='utf-8',errors='ignore').read()
        for m in re.finditer(r'\]\((\.?/?[^)#\s]*bea-[^)#\s]+\.md)\)', s):
            tot+=1
            if not os.path.exists(os.path.normpath(os.path.join(root,m.group(1)))):
                print("ROTO",p,"->",m.group(1)); mal+=1
print("enlaces a apéndices BE:",tot,"rotos:",mal)
PY
echo "=== referencias be-a- fuera de .md ==="; grep -rn 'be-a-' --include='*' --exclude='*.md' . 2>/dev/null | grep -v '^\./\.git' | head
echo "=== archivos bea- ==="; ls angular-8-legacy-for-backend-devs/bea-*.md react-16-legacy-for-backend-devs/bea-*.md | sed 's|.*/||'

# --- 2026-09-11T02:26:09 · Update memory and spot-check README
python3 - <<'PY'
import io
p='/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/tracks-be-angular-decisiones.md'
s=io.open(p,encoding='utf-8').read()
s=s.replace("`be-a-01`–`be-a-12`","`bea-01`–`bea-12`")
old="""Tres correcciones de coherencia que salieron al escribir los apéndices"""
new="""**Renombrado de convención (10/09/2026):** los apéndices del track BE pasaron de
`be-a-NN-` a **`bea-NN-`** en todo el repositorio —22 archivos (12 en angular-8,
10 en react-16), 597 referencias y las cinco justificaciones de nomenclatura
(CLAUDE.md raíz + guía y propuesta de los dos cursos de Angular)—. angular-16 se
alineó sin renombrar nada porque aún no tiene apéndices escritos. El nombre viejo
queda documentado con 🪦 en cada sitio: si aparece un `be-a-NN-`, es un resto.

Tres correcciones de coherencia que salieron al escribir los apéndices"""
assert old in s; s=s.replace(old,new,1)
io.open(p,'w',encoding='utf-8').write(s)
print('ok')
PY
cd angular-8-legacy-for-backend-devs && grep -c 'bea-' README.md && grep -n 'bea-0[12]' README.md | head -3

# --- 2026-09-11T02:29:52 · Check appendices and forensic pieces in both courses
cd .. && for d in angular-16-legacy-for-backend-devs react-16-legacy-for-backend-devs; do echo "== $d"; ls "$d" | grep -cE '^a[0-9]+-|^bea-' | sed 's/^/  apéndices: /'; ls "$d" | grep -c '^forense' | sed 's/^/  forenses: /'; done

# --- 2026-09-11T02:30:10 · Inventory angular-16 course files
cd angular-16-legacy-for-backend-devs && ls | sort && echo "=== wc ===" && wc -w *.md | tail -3

# --- 2026-09-11T02:30:12 · Word counts of appendices and forensic pieces
wc -w a*.md forense-*.md | sort -n; echo "=== prompts ==="; ls prompts

# --- 2026-09-11T02:30:16 · Read forensic format spec headings
grep -n '^#\{1,3\} ' prompts/formato-piezas-forenses.md; echo "=== tamaño ==="; wc -w prompts/formato-piezas-forenses.md

# --- 2026-09-11T02:30:22 · Read forensic piece structure and checklist
sed -n '55,185p' prompts/formato-piezas-forenses.md

# --- 2026-09-11T02:30:34 · Audit forensic pieces structure
python3 - <<'PY'
import re,io,glob,os
def r(p): return io.open(p,encoding='utf-8').read()

print("=== FORENSES: bloques obligatorios ===")
req={'🎫':'ticket','🧭':'ruta','🩺':'diagnóstico','🧠':'patrón'}
for f in sorted(glob.glob('forense-fase-*.md')):
    s=r(f); falta=[k for k in req if k not in s]
    pasos=len(re.findall(r'^### Paso \d', s, re.M))
    desc=len(re.findall(r'\*\*Qué descarta', s))
    callej='⚰️' in s; desh='🧨' in s
    inc=sorted(set(re.findall(r'incidente\s+(\d{1,2})', s, re.I)))
    flags=[]
    if falta: flags.append('FALTA '+','.join(falta))
    if pasos!=desc: flags.append(f'pasos={pasos} descarta={desc}')
    if not callej: flags.append('sin ⚰️')
    if not desh: flags.append('sin 🧨')
    if not inc: flags.append('sin incidentes citados')
    print(f"{f:22} pasos={pasos:2} {'  '.join(flags) if flags else 'ok'}  inc={inc}")
PY

# --- 2026-09-11T02:30:48 · Inspect heading structure of sample forensic pieces
for f in forense-fase-00.md forense-fase-03.md forense-fase-11.md forense-fase-04.md; do echo "=== $f"; grep -nE '^#{2,4} ' $f | head -14; done

# --- 2026-09-11T02:30:56 · Find actual discard phrasing in forensic steps
grep -rhoE '\*\*Qué [a-zé]+\.?\*\*|\*\*Si [a-zé ]+\*\*' forense-fase-*.md | sort | uniq -c | sort -rn | head -12

# --- 2026-09-11T02:31:01 · Find forensic steps missing the discard clause
python3 - <<'PY'
import re,io,glob
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    # bloques de paso: cualquier ### que abra un paso/rama/sospechoso
    pasos=re.findall(r'^### (.+)$', s, re.M)
    desc=len(re.findall(r'\*\*Qué descarta', s))
    if len(pasos)!=desc:
        print(f"\n{f}  pasos={len(pasos)} descarta={desc}")
        # ver cuál no lo tiene
        bloques=re.split(r'^### ', s, flags=re.M)[1:]
        for b in bloques:
            titulo=b.split('\n')[0][:60]
            if '**Qué descarta' not in b:
                print("   SIN 'Qué descarta' →", titulo)
PY

# --- 2026-09-11T02:31:16 · Inspect steps missing the discard clause
python3 - <<'PY'
import re,io
for f,titulo in [('forense-fase-01.md','Paso 4'),('forense-fase-02.md','Paso 4'),('forense-fase-13.md','Paso 4'),('forense-fase-00.md','Paso 5')]:
    s=io.open(f,encoding='utf-8').read()
    bloques=re.split(r'^### ', s, flags=re.M)[1:]
    for b in bloques:
        if b.startswith(titulo):
            lineas=[l for l in b.rstrip().split('\n') if l.strip()]
            print("=== %s / %s" % (f,lineas[0][:70]))
            print('\n'.join(lineas[-4:])[:600]); print()
PY

# --- 2026-09-11T02:31:40 · Audit cross-references between phases, appendices and forensics
python3 - <<'PY'
import re,io,glob,os
def r(p): return io.open(p,encoding='utf-8').read()

print("=== 1. forense-master: ¿indexa las 15 piezas? ===")
m=r('forense-master.md')
for i in range(15):
    f='forense-fase-%02d.md'%i
    if f not in m: print("  NO INDEXADA:", f)
print("  (silencio = todas indexadas)")

print("\n=== 2. ¿Cada fase enlaza su pieza forense? ===")
for i in range(15):
    fase=glob.glob('%02d-*.md'%i)
    if not fase: print("  sin fase", i); continue
    s=r(fase[0]); f='forense-fase-%02d.md'%i
    if f not in s: print("  Fase %02d (%s) NO enlaza %s"%(i,fase[0],f))
print("  (silencio = todas enlazan)")

print("\n=== 3. ¿Cada apéndice está referenciado por alguna fase? ===")
fases=[p for p in glob.glob('*.md') if re.match(r'^\d\d-',p)]
cuerpo=' '.join(r(p) for p in fases)
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    base=a[:3]
    if a not in cuerpo and base.upper() not in cuerpo and base not in cuerpo:
        print("  HUÉRFANO:", a)
print("  (silencio = todos referenciados)")

print("\n=== 4. 'Usado por' de cada apéndice vs quién lo referencia de verdad ===")
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    s=r(a); base=a[:3]
    m2=re.search(r'Usado por:\s*([^\n·]*)', s)
    declara=m2.group(1).strip() if m2 else '(sin línea "Usado por")'
    reales=sorted(p[:2] for p in fases if (a in r(p) or re.search(r'\b%s\b'%base, r(p), re.I)))
    print(f"  {base}  declara: {declara[:60]:60} | lo citan fases: {','.join(reales)}")
PY

# --- 2026-09-11T02:31:55 · Precise scan of which phases cite each appendix
python3 - <<'PY'
import re,io,glob
def r(p): return io.open(p,encoding='utf-8').read()
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p))
print(f"{'ap':4} {'declara Usado por':52} | citan de verdad")
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    base=a[:3]
    s=r(a)
    m2=re.search(r'Usado por:\s*([^\n·]*)', s)
    declara=(m2.group(1).strip() if m2 else '(SIN línea)')
    reales=[]
    for p in fases:
        t=r(p)
        if a in t or re.search(r'[`\[]'+base+r'[`\]\s]', t, re.I) or re.search(r'\bAp[ée]ndice\s+'+base+r'\b', t, re.I):
            reales.append(p[:2])
    print(f"{base:4} {declara[:52]:52} | {','.join(reales)}")
PY

# --- 2026-09-11T02:32:04 · See how phases cite appendices
grep -noE 'A0[0-9]|A1[0-3]|a0[0-9]-[a-z-]*\.md|apéndice[s]? [AaB][0-9]+' 06-clientes-activos.md | head -12; echo "=== header de una fase ==="; sed -n '1,8p' 06-clientes-activos.md

# --- 2026-09-11T02:32:13 · Compare declared usage against phase headers
python3 - <<'PY'
import re,io,glob
def r(p): return io.open(p,encoding='utf-8').read()
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p))
def num(x): return int(re.search(r'\d+',x).group())
print(f"{'ap':4} | declara            | citan (cualquier sitio) | lo listan en 'Apéndices de apoyo'")
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    base=a[:3].upper()
    s=r(a)
    m2=re.search(r'Usado por:\s*([^\n·]*)', s)
    dec=re.findall(r'Fase\s+(\d+)', m2.group(1)) if m2 else []
    dec=sorted(set(int(x) for x in dec))
    citan=[]; apoyo=[]
    for p in fases:
        t=r(p)
        if re.search(r'\b'+base+r'\b', t): citan.append(num(p))
        h=re.search(r'Apéndices de apoyo:([^\n]*)', t)
        if h and re.search(r'\b'+base+r'\b', h.group(1)): apoyo.append(num(p))
    falta=[x for x in dec if x not in apoyo]
    sobra=[x for x in apoyo if x not in dec]
    flag=''
    if falta: flag+=f"  ⚠ declara {falta} y NO están en su cabecera"
    if sobra: flag+=f"  ⚠ cabecera de {sobra} lo lista y el apéndice no lo declara"
    print(f"{base:4} | {str(dec):18} | {str(sorted(set(citan))):23} | {sorted(set(apoyo))}{flag}")
PY

# --- 2026-09-11T02:32:28 · List appendix support lines in all phase headers
for f in [01]*.md; do echo "-- $f"; grep -m1 'Apéndices de apoyo' $f; done 2>/dev/null; for f in 0*.md 1*.md; do printf "%-28s " "$f"; grep -m1 -o 'Apéndices de apoyo:[^\n]*' $f || echo "(sin línea)"; done

# --- 2026-09-11T02:32:53 · Audit appendix structure, links and incident references
python3 - <<'PY'
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
PY

# --- 2026-09-11T02:33:01 · Check incident notebook index format
grep -n '^| *[0-9]' cuaderno-incidentes.md | head -5; echo "---"; grep -c '^## Incidente' cuaderno-incidentes.md; grep -o '^## Incidente [0-9]*' cuaderno-incidentes.md | head -30 | tr '\n' ' '

# --- 2026-09-11T02:33:14 · Check incident-forensic bidirectional links
grep -n '📋\|## .*Índice' cuaderno-incidentes.md | head -3; echo "=== forenses citados desde el cuaderno ==="; grep -c 'forense-fase' cuaderno-incidentes.md; echo "=== incidentes citados por forenses (patrón amplio) ==="; python3 - <<'PY'
import re,io,glob
cit={}
for f in sorted(glob.glob('forense-*.md')):
    s=io.open(f,encoding='utf-8').read()
    m=re.search(r'Incidentes? del cuaderno[^\n]*\n?([^\n]*)', s)
    linea=m.group(0) if m else ''
    ids=set(re.findall(r'\b(\d{2})\b', linea))
    if ids: cit[f]=sorted(ids)
    print(f"{f:22} {sorted(ids) if ids else '—'}   {linea[:80]}")
todos=set()
for v in cit.values(): todos|=set(v)
print("\ncubiertos:", sorted(todos))
print("sin ruta forense:", sorted(set('%02d'%i for i in range(1,21))-todos))
PY

# --- 2026-09-11T02:33:24 · Check whether incidents declare their forensic route
sed -n '/^## Incidente 08/,/^### 🎫/p' cuaderno-incidentes.md | head -8; echo "=== spec del cuaderno: ¿pide ruta forense? ==="; grep -n -i 'forense' prompts/formato-cuaderno-incidentes.md | head -10

# --- 2026-09-11T02:33:40 · Check notebook-to-forensic link and cost-order declaration
echo "=== cuaderno → track forense ==="; grep -n 'forense' cuaderno-incidentes.md | head
echo; echo "=== ¿cada pieza declara el orden barato→caro? ==="
python3 - <<'PY'
import re,io,glob
pat=re.compile(r'barat|m[aá]s caro|cuesta diez segundos|de menos a m[aá]s|orden no es', re.I)
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    print(f"{f:22} {'ok' if pat.search(s) else 'NO DECLARA el orden'}")
PY

# --- 2026-09-11T02:33:52 · Read route intros of pieces without explicit cost ordering
python3 - <<'PY'
import re,io
for f in ['forense-fase-02.md','forense-fase-03.md','forense-fase-05.md','forense-fase-07.md','forense-fase-08.md','forense-fase-09.md','forense-fase-14.md']:
    s=io.open(f,encoding='utf-8').read()
    m=re.search(r'^## 🧭 (.+?)\n(.*?)(?=^###)', s, re.M|re.S)
    if m:
        txt=' '.join(m.group(2).split())[:260]
        print(f"--- {f}  [{m.group(1)[:40]}]\n    {txt}\n")
PY

# --- 2026-09-11T02:34:03 · Read the fixed stack from README
grep -n -A14 'Stack fijado\|## 🧰' README.md | head -30

# --- 2026-09-11T02:34:14 · Check version coherence across appendices and forensics
python3 - <<'PY'
import re,io,glob
fijado={'Angular':'16.2.12','Material':'16.2.14','RxJS':'7.8.1','TypeScript':'5.1.6',
        'Node':'18.18.2','npm':'9.8.1','jsPDF/jspdf':'2.5.1','zone.js':'0.13.3',
        'json-server':'0.17.4','Chart.js':'4.4','Jasmine':'4.6','Karma':'6.4',
        'ng2-charts':'4.1.1','Express':'4.18.2','jsonwebtoken':'9.0.2'}
print("Versiones que aparecen en apéndices y forenses, y si chocan con el stack:")
patrones={'Angular':r'Angular\s+(\d+\.\d+\.\d+)','Material':r'Material[^\n]{0,20}?(\d+\.\d+\.\d+)',
 'RxJS':r'RxJS\s+(\d+\.\d+\.\d+)','TypeScript':r'TypeScript\s+(\d+\.\d+\.\d+)',
 'Node':r'Node\s+(\d+\.\d+\.\d+)','jspdf':r'jspdf[`\s]+(\d+\.\d+\.\d+)',
 'zone.js':r'zone\.js[`\s]+(\d+\.\d+\.\d+)','json-server':r'json-server[`\s@]+(\d+\.\d+\.\d+)'}
for f in sorted(glob.glob('a[0-9][0-9]-*.md'))+sorted(glob.glob('forense-*.md')):
    s=io.open(f,encoding='utf-8').read(); avisos=[]
    for k,p in patrones.items():
        for v in set(re.findall(p,s)):
            esperado={'Angular':'16.2.12','Material':'16.2.14','RxJS':'7.8.1','TypeScript':'5.1.6',
                      'Node':'18.18.2','jspdf':'2.5.1','zone.js':'0.13.3','json-server':'0.17.4'}[k]
            if not v.startswith(esperado[:4]) and v!=esperado:
                avisos.append(f"{k}={v}")
    if avisos: print(f"  {f:34} {', '.join(sorted(set(avisos)))}")
print("  (las de migración A10/A11 mencionan otras a propósito)")
PY

# --- 2026-09-11T02:34:28 · Check forensic headers and master structure
python3 - <<'PY'
import re,io,glob
print("=== Encabezado de cada pieza: herramientas · tiempo · síntoma ===")
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    head='\n'.join(s.split('\n')[:12])
    tiene_h=bool(re.search(r'Herramientas?:', head))
    tiene_t=bool(re.search(r'\b\d+\s*[-–]?\s*\d*\s*min|minutos', head))
    tiene_s=bool(re.search(r'S[ií]ntoma:', head))
    fase=bool(re.search(r'Fase\s+\d+', head))
    flags=[n for n,v in [('herramientas',tiene_h),('tiempo',tiene_t),('síntoma',tiene_s),('fase',fase)] if not v]
    print(f"  {f:22} {'ok' if not flags else 'FALTA: '+', '.join(flags)}")
print()
m=io.open('forense-master.md',encoding='utf-8').read()
print("=== forense-master: bloques ===")
for k,lbl in [('método|cuatro preguntas','1 método'),('📇','2 índice piezas'),('🩺','3 síntomas transversal'),('🧰','4 herramientas'),('HOTFIX','5 cierre→HOTFIX.md')]:
    print(f"  {lbl:24} {'ok' if re.search(k,m,re.I) else 'FALTA'}")
filas=len(re.findall(r'^\|', m, re.M))
print(f"  filas de tabla en el master: {filas}")
PY

# --- 2026-09-11T02:34:34 · Inspect a forensic header and master headings
sed -n '1,12p' forense-fase-07.md; echo "======== master headings ========"; grep -nE '^#{1,3} ' forense-master.md

# --- 2026-09-11T02:34:44 · Read master index of forensic pieces
sed -n '28,50p' forense-master.md

# --- 2026-09-11T02:34:51 · Compare master symptoms against piece titles
python3 - <<'PY'
import re,io,glob
m=io.open('forense-master.md',encoding='utf-8').read()
filas=dict()
for f,sint,_,arch in re.findall(r'^\|\s*(\d+)\s*\|([^|]+)\|([^|]+)\|\s*`([^`]+)`\s*\|', m, re.M):
    filas[int(f)]=(sint.strip(),arch.strip())
print("=== síntoma del master vs título de la pieza ===")
for i,(sint,arch) in sorted(filas.items()):
    s=io.open(arch,encoding='utf-8').read()
    titulo=s.split('\n')[0]
    nucleo=re.sub(r'[“”"⭐🔥🧬]','',sint).strip().lower()[:40]
    ok = nucleo[:25] in titulo.lower()
    print(f"  Fase {i:2}  {'ok ' if ok else 'DIFIERE'}  master: {sint[:44]:44} | pieza: {titulo[:52]}")
PY

# --- 2026-09-11T02:35:09 · Find non-terminal steps missing the discard marker
python3 - <<'PY'
import re,io,glob
print("Pasos SIN '**Qué descarta**' que NO son el último de su bloque (posible hueco real):")
total_gap=0
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    # trocear por secciones ## y dentro por pasos ###
    secciones=re.split(r'^(## .+)$', s, flags=re.M)
    gaps=[]
    for i in range(1,len(secciones),2):
        cab, cuerpo = secciones[i], secciones[i+1]
        pasos=re.split(r'^### ', cuerpo, flags=re.M)[1:]
        for j,b in enumerate(pasos):
            titulo=b.split('\n')[0].strip()
            ultimo = (j==len(pasos)-1)
            if '**Qué descarta' not in b and not ultimo:
                gaps.append(titulo[:64])
    if gaps:
        total_gap+=len(gaps)
        print(f"\n  {f}")
        for g in gaps: print("    -", g)
print(f"\n  TOTAL pasos intermedios sin la marca: {total_gap}")
PY

# --- 2026-09-11T02:35:19 · Sample steps to see whether they discard in substance
python3 - <<'PY'
import re,io
casos=[('forense-fase-12.md','Sospechoso 1'),('forense-fase-14.md','Paso 2 — El almacén'),
       ('forense-fase-07.md','Paso 2 —'),('forense-fase-09.md','Paso 2 — Las tres')]
for f,t in casos:
    s=io.open(f,encoding='utf-8').read()
    for b in re.split(r'^### ', s, flags=re.M)[1:]:
        if b.startswith(t):
            l=[x for x in b.rstrip().split('\n') if x.strip()]
            print(f"\n===== {f} / {l[0][:60]}")
            print('\n'.join(l[-3:])[:450])
            break
PY

# --- 2026-09-11T02:35:47 · Check tag blocks and section cross-references
python3 - <<'PY'
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
PY

# --- 2026-09-11T02:35:57 · Read full tag blocks from sample appendices
for f in a01-material.md a04-inject-vs-constructor.md a02-bootstrap-sass.md a13-i18n.md; do echo "===== $f"; awk '/🏷️/,0' $f | head -8; done

# --- 2026-09-11T02:36:14 · Check whether phases mention the appendices that claim them
python3 - <<'PY'
import re,io,glob
def r(p): return io.open(p,encoding='utf-8').read()
pares=[('A01',[7,8,10]),('A03',[12]),('A05',[0,2]),('A07',[6]),('A12',[12])]
for ap,fases in pares:
    for n in fases:
        f=glob.glob('%02d-*.md'%n)
        f=[x for x in f if 'convencion' not in x and 'historia' not in x]
        t=r(f[0])
        hits=re.findall(r'[^\n]*\b'+ap+r'\b[^\n]*', t)
        print(f"{ap} declara Fase {n} ({f[0][:22]}): {len(hits)} menciones")
        for h in hits[:2]: print("     ", ' '.join(h.split())[:110])
PY

# --- 2026-09-11T02:36:33 · Check internal anchors and URL sanity
python3 - <<'PY'
import re,io,glob,unicodedata
def slug(t):
    t=t.strip().lower()
    t=re.sub(r'`|\*\*|\*|__','',t)
    t=''.join(c for c in t if c.isalnum() or c in ' -_')
    return re.sub(r'\s+','-',t.strip())
print("=== anclas internas rotas en apéndices y forenses ===")
mal=0
for f in sorted(glob.glob('a[0-9][0-9]-*.md'))+sorted(glob.glob('forense-*.md')):
    s=io.open(f,encoding='utf-8').read()
    heads={slug(h) for h in re.findall(r'^#{2,4}\s*(.+)$', s, re.M)}
    for m in re.finditer(r'\]\(#([^)]+)\)', s):
        a=m.group(1)
        if a not in heads:
            print(f"  {f}: #{a}"); mal+=1
print("  rotas:",mal)
print("\n=== URLs: formato y sospechosas ===")
urls=[]
for f in glob.glob('*.md'):
    urls+= [(f,u) for u in re.findall(r'https?://[^\s\)\]`>]+', io.open(f,encoding='utf-8').read())]
print("  total URLs:",len(urls))
import collections
raras=[(f,u) for f,u in urls if re.search(r'ejemplo|example\.com|TODO|xxx|localhost:\d+/algo', u)]
print("  sospechosas:", len(raras))
for f,u in raras[:6]: print("   ",f,u)
dom=collections.Counter(re.sub(r'https?://([^/]+).*',r'\1',u) for _,u in urls)
print("  dominios top:", dom.most_common(6))
PY

# --- 2026-09-11T02:36:47 · Re-check internal anchors with correct slug algorithm
python3 - <<'PY'
import re,io,glob
def slug(t):
    t=t.strip().lower()
    t=re.sub(r'`|\*\*|\*|__','',t)
    # GitHub: quita todo lo que no sea alfanumérico, guion, guion bajo o espacio (los emoji caen y dejan el espacio)
    t=''.join(c if (c.isalnum() or c in ' -_') else '' for c in t)
    return t.replace(' ','-')
mal=0; tot=0
for f in sorted(glob.glob('a[0-9][0-9]-*.md'))+sorted(glob.glob('forense-*.md'))+['README.md','cuaderno-incidentes.md']:
    s=io.open(f,encoding='utf-8').read()
    heads={slug(h) for h in re.findall(r'^#{2,4}\s*(.+?)\s*$', s, re.M)}
    for m in re.finditer(r'\]\(#([^)]+)\)', s):
        tot+=1
        if m.group(1) not in heads:
            print(f"  ROTA {f}: #{m.group(1)}"); mal+=1
print(f"anclas internas revisadas: {tot}  rotas: {mal}")
PY

# --- 2026-09-11T02:37:10 · Confirm the variation selector hypothesis
grep -n 'advertencias' a01-material.md | head -3 | cat -v | head -5; echo "---"; python3 -c "
import io,re
s=io.open('a01-material.md',encoding='utf-8').read()
for m in re.finditer(r'\]\(#([^)]*advertencias)\)',s):
    print('ancla:',[hex(ord(c)) for c in m.group(1)[:3]])
for h in re.findall(r'^##.*Advertencias.*$',s,re.M):
    print('titulo:',[hex(ord(c)) for c in h[:8]], repr(h))
"

# --- 2026-09-11T02:37:33 · Compare phase hooks against forensic piece tickets
python3 - <<'PY'
import re,io,glob
print("=== lo que la §6 de cada fase promete vs lo que la pieza entrega (tickets) ===")
for i in range(15):
    fs=[p for p in glob.glob('%02d-*.md'%i) if 'convencion' not in p and 'historia' not in p]
    if not fs: continue
    t=io.open(fs[0],encoding='utf-8').read()
    m=re.search(r'([^\n]*forense-fase-%02d\.md[^\n]*)'%i, t)
    promesa=' '.join(m.group(1).split())[:150] if m else '(sin gancho)'
    p=io.open('forense-fase-%02d.md'%i,encoding='utf-8').read()
    tickets=len(re.findall(r'^> \*\*(?:Ticket|El ticket)', p, re.M)) or len(re.findall(r'^\*\*Reportado por', p, re.M))
    print(f"\n  Fase {i:2} tickets en la pieza: {tickets}")
    print(f"     {promesa}")
PY

# --- 2026-09-11T02:37:42 · Inspect ticket section of forensic piece 10
sed -n '/## 🎫/,/## 🧭/p' forense-fase-10.md | head -24

# --- 2026-09-11T02:37:52 · Check declared counts in README and scope docs
grep -oE 'A0[1-9]|A1[0-3]' README.md | sort -u | tr '\n' ' '; echo; grep -oE 'trece apéndices|doce apéndices|quince piezas|catorce fases|13 apéndices' README.md prompts/alcance-del-proyecto.md prompts/propuesta-fases-y-alcance.md | sort | uniq -c

# --- 2026-09-11T02:37:56 · Check README coverage of appendices and forensics
grep -n -i 'apéndice' README.md | head -12; echo "=== ¿README enlaza las piezas forenses? ==="; grep -c 'forense' README.md

# --- 2026-09-11T02:37:59 · Read README appendix section
sed -n '92,115p' README.md

# --- 2026-09-11T02:38:10 · Verify appendix hours and exercise totals against README
python3 - <<'PY'
import re,io,glob
rd=io.open('README.md',encoding='utf-8').read()
tabla=dict((m.group(1), m.group(2)) for m in re.finditer(r'\[`(a\d\d-[^`]+\.md)`\][^|]*\|[^|]*\|\s*(\d+)h\s*\|', rd))
print("apéndice  README  cabecera  ejercicios")
tot_h=0; tot_e=0
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    s=io.open(a,encoding='utf-8').read()
    h=re.search(r'\*\*(\d+)\s*horas?\*\*', s)
    e=re.search(r'Ejercicios?\s*\((\d+)', s)
    rh=tabla.get(a,'?')
    ok='' if (h and rh==h.group(1)) else '  ⚠ DIFIERE'
    tot_h+=int(rh) if rh.isdigit() else 0; tot_e+=int(e.group(1)) if e else 0
    print(f"  {a[:3]}      {rh}h      {h.group(1)+'h' if h else '(sin)':6}    {e.group(1) if e else '?':3}{ok}")
print(f"  TOTALES  {tot_h}h                 {tot_e}   (README dice 33h y 93 ejercicios)")
PY

# --- 2026-09-11T02:38:17 · Locate the broken relative links
grep -n '](00-convencion-de-git-y-tags.md)' prompts/plantillas-de-capitulo.md prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-11T02:38:23 · Fix relative links and re-verify
for f in prompts/plantillas-de-capitulo.md prompts/guia-de-estilo-y-convenciones.md; do python3 - "$f" <<'PY'
import io,sys
p=sys.argv[1]; s=io.open(p,encoding='utf-8').read()
s2=s.replace('](00-convencion-de-git-y-tags.md)','](../00-convencion-de-git-y-tags.md)')
io.open(p,'w',encoding='utf-8').write(s2)
print(p, s.count('](00-convencion-de-git-y-tags.md)'), '->', s2.count('](../00-convencion-de-git-y-tags.md)'))
PY
done
python3 - <<'PY'
import re,io,glob,os
mal=0
for p in glob.glob('*.md')+glob.glob('prompts/*.md'):
    s=io.open(p,encoding='utf-8').read(); base=os.path.dirname(p)
    for m in re.finditer(r'\]\((\.?\.?/?[^)#\s]+\.md)\)', s):
        if not os.path.exists(os.path.normpath(os.path.join(base,m.group(1)))):
            print("  ROTO",p,"->",m.group(1)); mal+=1
print("enlaces .md rotos ahora:",mal)
PY

# --- 2026-09-11T02:42:56 · Read current Usado por lines
grep -n 'Usado por' a01-material.md a03-node-npm.md a05-formularios-tipados.md a06-rxjs.md a07-estado-servicios.md a12-arm64-m1.md

# --- 2026-09-11T02:43:04 · Correct the Usado por lines in six appendices
python3 - <<'PY'
import io
cambios={
 'a01-material.md':("Usado por: Fase 1, Fase 6, Fase 7, Fase 8, Fase 10","Usado por: Fase 1, Fase 5, Fase 6"),
 'a03-node-npm.md':("Usado por: Fase 0, Fase 3, Fase 12, Fase 13","Usado por: Fase 0, Fase 3, Fase 13"),
 'a05-formularios-tipados.md':("Usado por: Fase 0, Fase 2, Fase 6, Fase 8, Fase 9","Usado por: Fase 6, Fase 7, Fase 8, Fase 9, Fase 12"),
 'a06-rxjs.md':("Usado por: Fase 2, Fase 3, Fase 4, Fase 8, Fase 11","Usado por: Fase 2, Fase 3, Fase 4, Fase 7, Fase 8, Fase 11, Fase 12"),
 'a07-estado-servicios.md':("Usado por: Fase 4, Fase 6, Fase 7, Fase 9, Fase 11","Usado por: Fase 4, Fase 7, Fase 9, Fase 11"),
 'a12-arm64-m1.md':("Usado por: Fase 0, Fase 12, Fase 13, Fase 14","Usado por: Fase 0, Fase 13, Fase 14"),
}
for f,(o,n) in cambios.items():
    s=io.open(f,encoding='utf-8').read(); assert o in s, f
    io.open(f,'w',encoding='utf-8').write(s.replace(o,n,1))
    print(f"{f[:3]}  {o[10:]}  ->  {n[10:]}")
PY

# --- 2026-09-11T02:43:14 · Verify Usado por now matches phase headers
python3 - <<'PY'
import re,io,glob
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p))
def num(x): return int(x[:2])
ok=True
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    base=a[:3].upper(); s=io.open(a,encoding='utf-8').read()
    m=re.search(r'Usado por:\s*([^\n·]*)', s)
    dec=sorted(set(int(x) for x in re.findall(r'Fase\s+(\d+)', m.group(1)))) if m else []
    cab=[]
    for p in fases:
        h=re.search(r'Apéndices de apoyo:([^\n]*)', io.open(p,encoding='utf-8').read())
        if h and re.search(r'\b'+base+r'\b', h.group(1)): cab.append(num(p))
    estado='ok' if dec==sorted(cab) else f'⚠ declara {dec} vs cabeceras {sorted(cab)}'
    if estado!='ok': ok=False
    print(f"  {base}  {estado}")
print("\nTODOS CUADRAN" if ok else "\nQUEDAN DESAJUSTES")
PY

# --- 2026-09-11T02:43:22 · Read route structure of the four pieces missing ordering
for f in forense-fase-02.md forense-fase-05.md forense-fase-08.md forense-fase-09.md; do echo "===== $f"; grep -nE '^## 🧭|^### ' $f; echo "--- contexto tras el encabezado de ruta:"; awk '/^## 🧭/{f=1;next} f&&NF{print;c++} c==2{exit}' $f | head -3; done

# --- 2026-09-11T02:43:43 · Inspect intro before first route in pieces 08 and 09
sed -n '24,36p' forense-fase-08.md; echo "=========== 09"; sed -n '20,32p' forense-fase-09.md

# --- 2026-09-11T02:43:58 · Add ordering criteria to four forensic pieces
python3 - <<'PY'
import io
ins={
'forense-fase-02.md':("## 🧭 La ruta\n\n### Paso 1","""## 🧭 La ruta

Los cinco pasos van **del más barato al más caro**, no del más probable al menos probable. Mirar una columna de Network cuesta diez segundos y ya parte el problema en dos; poner un breakpoint dentro de un interceptor cuesta diez minutos y sólo se hace cuando los tres primeros no bastaron. El último sale del navegador entero, que es donde se comprueba quién miente.

### Paso 1"""),
'forense-fase-05.md':("## 🧭 La ruta\n\n### Paso 1","""## 🧭 La ruta

El orden no es casual: **el paréntesis del mensaje cuesta un vistazo** y decide por cuál de las dos ramas sigues, así que va primero. Leer ese mismo error en un build de producción minificado cuesta una compilación entera, y por eso va al final — aunque sea el único sitio donde de verdad te lo vas a encontrar.

### Paso 1"""),
'forense-fase-08.md':("---\n\n## 🧭 Ruta A — el bucle de `valueChanges`","""---

Tres rutas, y **cuál te toca lo decide el síntoma, no el orden de lectura**: si la aplicación quieta habla con el servidor, ruta A; si falta o sobra un control, ruta B; si hay un error rojo que se va solo en el ambiente de pruebas, ruta C. Dentro de cada una los pasos van del más barato al más caro: mirar Network con la aplicación en reposo no cuesta nada y ya separa el bucle de red del de render; el experimento de la ruta C obliga a construir para producción y por eso va el último.

---

## 🧭 Ruta A — el bucle de `valueChanges`"""),
'forense-fase-09.md':("---\n\n## 🧭 Ruta A — la regla que no bloqueó","""---

Las dos rutas empiezan por el mismo sitio y por la misma razón: **el cuerpo de la respuesta es la única capa que no interpreta nada**, y mirarlo cuesta un clic. Todo lo que viene después —la pantalla, el servicio, la regla— ya aplicó valores por defecto, así que preguntarle a cualquiera de ellos antes que al JSON crudo es empezar por la capa que miente.

---

## 🧭 Ruta A — la regla que no bloqueó"""),
}
for f,(o,n) in ins.items():
    s=io.open(f,encoding='utf-8').read(); assert o in s, f
    io.open(f,'w',encoding='utf-8').write(s.replace(o,n,1)); print("ok",f)
PY
python3 - <<'PY'
import re,io,glob
pat=re.compile(r'barat|m[aá]s caro|cuesta un vistazo|cuesta un clic|cuesta diez segundos|orden no es|lo decide el s[ií]ntoma|regla que ordena|Empieza siempre', re.I)
falt=[f for f in sorted(glob.glob('forense-fase-*.md')) if not pat.search(io.open(f,encoding='utf-8').read())]
print("piezas sin criterio de orden declarado:", falt or "ninguna")
PY

# --- 2026-09-11T02:44:06 · Check what ordering statement piece 07 has
grep -noE '.{40}(barat|más caro|cuesta un vistazo|orden no es|lo decide el síntoma).{50}' forense-fase-07.md | head -3

# --- 2026-09-11T02:44:10 · Locate the ordering match in piece 07
python3 -c "
import re,io
s=io.open('forense-fase-07.md',encoding='utf-8').read()
pat=re.compile(r'barat|m[aá]s caro|cuesta un vistazo|cuesta un clic|cuesta diez segundos|orden no es|lo decide el s[ií]ntoma|regla que ordena|Empieza siempre', re.I)
for m in pat.finditer(s): print(repr(s[max(0,m.start()-90):m.end()+60]))
"

# --- 2026-09-11T02:44:25 · Add ordering criterion to piece 07 and re-verify properly
python3 - <<'PY'
import io
f='forense-fase-07.md'; s=io.open(f,encoding='utf-8').read()
o="""Los dos tickets comparten los tres primeros pasos. Es lo que los hace eficientes: **una sola investigación contesta las dos preguntas.**"""
n="""Los dos tickets comparten los tres primeros pasos. Es lo que los hace eficientes: **una sola investigación contesta las dos preguntas.**

Y el orden de esos pasos es el de siempre, del más barato al más caro: **mirar la URL de una petición cuesta diez segundos y descarta cuatro de las seis causas**, mientras que abrir el servicio de estado y seguir de dónde salió el dato cuesta media hora. Por eso los dos primeros pasos no abren un solo archivo."""
assert o in s
io.open(f,'w',encoding='utf-8').write(s.replace(o,n,1)); print("ok 07")
PY
python3 - <<'PY'
import re,io,glob
# criterio: la declaración tiene que estar ANTES del primer ### de la sección de ruta
pat=re.compile(r'barat|m[aá]s caro|cuesta un vistazo|cuesta un clic|cuesta diez segundos|orden no es|lo decide el s[ií]ntoma|regla que ordena|Empieza siempre|misma raz[oó]n', re.I)
falt=[]
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    i=s.find('## 🧭'); j=s.find('###', i)
    intro=s[max(0,i-700):j] if i>=0 else ''
    if not pat.search(intro): falt.append(f)
print("piezas sin criterio de orden en la entrada de la ruta:", falt or "ninguna — 15/15")
PY

# --- 2026-09-11T02:44:31 · Check route intros of remaining five pieces
for f in forense-fase-06.md forense-fase-10.md forense-fase-11.md forense-fase-12.md forense-fase-13.md; do echo "===== $f"; python3 -c "
import io,sys
s=io.open('$f',encoding='utf-8').read()
i=s.find('## 🧭'); j=s.find('###', i)
print(' '.join(s[i:j].split())[:300])
"; done

# --- 2026-09-11T02:44:39 · Read step titles of the remaining pieces
for f in forense-fase-06.md forense-fase-10.md forense-fase-13.md forense-fase-12.md; do echo "===== $f"; grep -nE '^## 🧭|^### ' $f | head -8; done

# --- 2026-09-11T02:44:53 · Add ordering criteria to pieces 06, 10 and 13
python3 - <<'PY'
import io
ins={
'forense-fase-06.md':("## 🧭 La ruta\n\n### Paso 1","""## 🧭 La ruta

Cuatro pasos, **del más barato al más caro**. Preguntarle su estado al formulario desde la consola cuesta un comando y descarta la mitad de las causas de un tirón; abrir el validador asíncrono y seguir su petición cuesta bastante más, y sólo hace falta cuando el estado dice `PENDING`. El orden lo decide el coste, no la corazonada.

### Paso 1"""),
'forense-fase-10.md':("---\n\n## 🧭 Ruta A — la vigencia","""---

Las dos rutas arrancan por lo mismo y por la misma razón: **mirar los últimos seis caracteres de una cadena ISO cuesta un vistazo** y decide si hay bug o no lo hay. Todo lo demás —las conversiones, el experimento del cambio de hora, comparar pantalla y PDF— cuesta minutos, y sólo tiene sentido después de saber qué trae el dato.

---

## 🧭 Ruta A — la vigencia"""),
'forense-fase-13.md':("## 🧭 La ruta\n\n### Paso 1","""## 🧭 La ruta

Cinco pasos, y **el código va el último a propósito**. Comparar dos digests o leer una cabecera con `curl` cuesta segundos y descarta el despliegue, la configuración del servidor y la caché; abrir el proyecto y buscar en qué se diferencian dos entornos cuesta una tarde. Si empiezas por el editor —que es lo que hace todo el mundo con este ticket— vas a encontrar el bug igual, pero tres horas después.

### Paso 1"""),
}
for f,(o,n) in ins.items():
    s=io.open(f,encoding='utf-8').read(); assert o in s, f
    io.open(f,'w',encoding='utf-8').write(s.replace(o,n,1)); print("ok",f)
PY
sed -n '29,34p' forense-fase-12.md

# --- 2026-09-11T02:45:05 · Add ordering criterion to piece 12 and verify all fifteen
python3 - <<'PY'
import io
f='forense-fase-12.md'; s=io.open(f,encoding='utf-8').read()
o="## 🧭 Ruta A — el test de regresión, y por qué va primero\n\n### Paso 1"
n="""## 🧭 Ruta A — el test de regresión, y por qué va primero

Va primero porque es **lo más barato que existe**: un test que falla convierte un ticket en una condición reproducible, y a partir de ahí cada hipótesis se descarta en segundos en vez de en una sesión de depuración. La ruta B —el intermitente— cuesta un orden de magnitud más en cada paso, y por eso sus cuatro sospechosos van en el orden en que van.

### Paso 1"""
assert o in s
io.open(f,'w',encoding='utf-8').write(s.replace(o,n,1)); print("ok 12")
PY
python3 - <<'PY'
import re,io,glob
pat=re.compile(r'barat|m[aá]s caro|cuesta un vistazo|cuesta un clic|cuesta diez segundos|cuesta segundos|cuesta un comando|orden no es|lo decide el s[ií]ntoma|regla que ordena|Empieza siempre|misma raz[oó]n|El orden es la lecci[oó]n', re.I)
falt=[]
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    i=s.find('## 🧭'); j=s.find('###', i)
    if not pat.search(s[max(0,i-700):j]): falt.append(f)
print("sin criterio de orden en la entrada:", falt or "ninguna — 15/15 ✅")
PY

# --- 2026-09-11T02:45:14 · Fix phase 10 hook and master section emoji
python3 - <<'PY'
import io,re
# 4a — Fase 10: la línea 📄 promete un ticket y la pieza entrega dos
f=[p for p in __import__('glob').glob('10-*.md')][0]
s=io.open(f,encoding='utf-8').read()
o="> 📄 El recorrido completo, con el ticket literal y la salida de cada paso, en `forense-fase-10.md`."
n="> 📄 El recorrido completo, con los dos tickets literales y la salida de cada paso, en `forense-fase-10.md`."
assert o in s, "no encontrado en "+f
io.open(f,'w',encoding='utf-8').write(s.replace(o,n,1)); print("ok",f)

# 4b — master §2 recupera su 📇
p='forense-master.md'; s=io.open(p,encoding='utf-8').read()
o2="## 2. Índice de las quince piezas"; n2="## 2. 📇 Índice de las quince piezas"
assert o2 in s
io.open(p,'w',encoding='utf-8').write(s.replace(o2,n2,1)); print("ok forense-master.md")
PY
grep -n '📄.*forense-fase-10' 10-*.md; grep -n '^## 2\.' forense-master.md

# --- 2026-09-11T02:45:30 · Final verification of all fixes
grep -rn 'quince-piezas\|forense-master.md#' *.md prompts/*.md | head; echo "--- verificación final ---"; python3 - <<'PY'
import re,io,glob,os
def r(p): return io.open(p,encoding='utf-8').read()
# enlaces relativos
mal=0
for p in glob.glob('*.md')+glob.glob('prompts/*.md'):
    s=r(p); base=os.path.dirname(p)
    for m in re.finditer(r'\]\((\.?\.?/?[^)#\s]+\.md)\)', s):
        if not os.path.exists(os.path.normpath(os.path.join(base,m.group(1)))): print("ROTO",p,m.group(1)); mal+=1
print("enlaces .md rotos:",mal)
# usado por
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p))
bad=0
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    base=a[:3].upper(); m=re.search(r'Usado por:\s*([^\n·]*)', r(a))
    dec=sorted(set(int(x) for x in re.findall(r'Fase\s+(\d+)', m.group(1)))) if m else []
    cab=[int(p[:2]) for p in fases if (lambda h: h and re.search(r'\b'+base+r'\b',h.group(1)))(re.search(r'Apéndices de apoyo:([^\n]*)', r(p)))]
    if dec!=sorted(cab): print("DESAJUSTE",base,dec,sorted(cab)); bad+=1
print("apéndices con 'Usado por' desajustado:",bad)
# promesas 📄
for i in range(15):
    fs=[p for p in glob.glob('%02d-*.md'%i) if 'convencion' not in p and 'historia' not in p]
    if not fs: continue
    m=re.search(r'[^\n]*forense-fase-%02d\.md[^\n]*'%i, r(fs[0]))
    pieza=r('forense-fase-%02d.md'%i)
    t=len(re.findall(r'^\*\*Reportado por', pieza, re.M))
    prom=m.group(0)
    num = 'dos' if t==2 else ('tres' if t==3 else 'un/el')
    if t>1 and 'los dos' not in prom and 'los tres' not in prom and 'los tickets' not in prom:
        print(f"  ⚠ Fase {i}: pieza con {t} tickets y la promesa dice: {prom[:90]}")
print("promesas 📄 revisadas")
PY

# --- 2026-09-11T02:45:36 · Show changes applied to the course
cd .. && git status --short angular-16-legacy-for-backend-devs/ && echo "--- diff resumido ---" && git diff --stat angular-16-legacy-for-backend-devs/ | tail -20

# --- 2026-09-11T03:33:57 · Re-read all steps missing the discard marker
cd angular-16-legacy-for-backend-devs && python3 - <<'PY'
import re,io,glob
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    secs=re.split(r'^(## .+)$', s, flags=re.M)
    for i in range(1,len(secs),2):
        cab,cuerpo=secs[i],secs[i+1]
        if '🧭' not in cab: continue
        pasos=re.split(r'^### ', cuerpo, flags=re.M)[1:]
        for j,b in enumerate(pasos):
            if '**Qué descarta' in b: continue
            ultimo=(j==len(pasos)-1)
            l=[x for x in b.rstrip().split('\n') if x.strip()]
            print(f"\n■ {f} | {cab[3:40]} | {'ÚLTIMO' if ultimo else 'INTERMEDIO'}")
            print(f"  {l[0][:70]}")
            print("  …", ' '.join(' '.join(l[-2:]).split())[:200])
PY

# --- 2026-09-11T03:34:34 · Read full text of the genuinely incomplete steps
python3 - <<'PY'
import re,io
casos=[('forense-fase-14.md','Paso 2 — El almacén'),('forense-fase-14.md','Paso 3 — El `:latest`'),('forense-fase-02.md','Paso 4 — Dónde va'),('forense-fase-09.md','Paso 2 — Las tres preguntas')]
for f,t in casos:
    s=io.open(f,encoding='utf-8').read()
    for b in re.split(r'^### ', s, flags=re.M)[1:]:
        if b.startswith(t):
            print(f"\n{'='*70}\n{f} / {b.split(chr(10))[0][:70]}\n")
            print(b.rstrip()[:1100]); break
PY

# --- 2026-09-11T03:35:09 · Check step lists for accurate example wording
grep -E '^### ' forense-fase-01.md; echo "--- 14 ruta A ---"; grep -E '^## 🧭|^### ' forense-fase-14.md | head -8

# --- 2026-09-11T03:36:49 · Read format spec section 4 verbatim
sed -n '81,112p' prompts/formato-piezas-forenses.md

# --- 2026-09-11T03:37:07 · Add the second closing marker to the format spec
python3 - <<'PY'
import io
p='prompts/formato-piezas-forenses.md'; s=io.open(p,encoding='utf-8').read()

old="""**Qué descarta.** {{Qué hipótesis muere con esta salida, y a qué paso saltas según
lo que hayas visto. Un paso que no descarta nada no es un paso: es relleno.}}
```

Tres reglas sobre los pasos:

- **El orden es la lección.** Los pasos van del más barato al más caro, no del más
  probable al menos probable. Mirar una URL cuesta diez segundos; abrir el
  perfilador de memoria cuesta diez minutos. Ese orden **se dice explícitamente**
  al empezar la ruta.
- **Un paso, una pregunta.** Si un paso contesta dos cosas, son dos pasos.
- **La ruta termina cuando se sabe dónde está el bug, no cuando está arreglado.**
  El fix es de la fase o del incidente; la pieza forense localiza."""

new="""**Qué descarta.** {{Qué hipótesis muere con esta salida, y a qué paso saltas según
lo que hayas visto. Un paso que no descarta nada no es un paso: es relleno.}}
```

### Los dos cierres, y por qué hacen falta los dos

Un paso hace **una** de estas dos cosas, y siempre cierra con la marca que le
corresponde. Son las dos únicas terminaciones admitidas:

| Marca | Cuándo | Qué dice |
|---|---|---|
| **`**Qué descarta.**`** | El paso **elimina hipótesis** | Qué muere con esta salida y a qué paso saltas |
| **`**Aquí termina la ruta.**`** | El paso **localiza el bug** | Qué quedó demostrado, y que la pieza no va más allá |

La segunda existe porque un paso que acaba de encontrar la causa **no tiene nada
que descartar**, y forzarle un «Qué descarta» produce exactamente el relleno que
la regla de arriba prohíbe. Su variante para rutas con ramas excluyentes es
**`**Aquí termina esta rama.**`**, que además dice cuál de las otras no vas a
recorrer.

> 🧭 **La propiedad que protegen las dos juntas:** que la ruta se pueda recorrer
> **saltando de marca en marca**, sin leer el resto. Un paso sin ninguna de las
> dos rompe esa propiedad aunque su contenido sea impecable, porque obliga a
> leerlo entero para saber si ya terminaste.

Tres reglas sobre los pasos:

- **El orden es la lección.** Los pasos van del más barato al más caro, no del más
  probable al menos probable. Mirar una URL cuesta diez segundos; abrir el
  perfilador de memoria cuesta diez minutos. Ese orden **se dice explícitamente**
  al empezar la ruta.
- **Un paso, una pregunta.** Si un paso contesta dos cosas, son dos pasos.
- **La ruta termina cuando se sabe dónde está el bug, no cuando está arreglado.**
  El fix es de la fase o del incidente; la pieza forense localiza.
- **Y si un bloque no hace ninguna de las dos cosas**, no es un paso: es una
  técnica o una nota, y va fuera de la numeración, en un bloque 💡."""
assert old in s; s=s.replace(old,new,1)

old2="""- [ ] Cada paso dice qué descarta y a dónde saltar (§4)."""
new2="""- [ ] **Cada paso cierra con una de las dos marcas de §4** —`**Qué descarta.**`
      si elimina hipótesis, `**Aquí termina la ruta.**` (o `…esta rama.`) si
      localiza el bug—. Se comprueba con `prompts/verificar-forenses.py`, que
      falla si algún bloque de una sección 🧭 se queda sin marca."""
assert old2 in s; s=s.replace(old2,new2,1)
io.open(p,'w',encoding='utf-8').write(s)
print("ok formato-piezas-forenses.md")
PY

# --- 2026-09-11T03:37:17 · Read endings of the seven terminal steps
python3 - <<'PY'
import re,io
casos=[('forense-fase-05.md','Paso 2 — Si dice'),('forense-fase-05.md','Paso 3 — Si dice'),
       ('forense-fase-07.md','Paso 4 (ticket 1)'),('forense-fase-07.md','Paso 5 (ticket 2)'),
       ('forense-fase-12.md','Sospechoso 1'),('forense-fase-12.md','Sospechoso 2'),('forense-fase-12.md','Sospechoso 4')]
for f,t in casos:
    s=io.open(f,encoding='utf-8').read()
    for b in re.split(r'^### ', s, flags=re.M)[1:]:
        if b.startswith(t):
            l=[x for x in b.rstrip().split('\n')]
            print(f"\n{'─'*72}\n{f} · {l[0][:64]}")
            print('\n'.join(l[-6:])[:520]); break
PY

# --- 2026-09-11T03:37:47 · Add closing markers to the seven terminal steps
python3 - <<'PY'
import io
ed=[
('forense-fase-05.md',
 """| `inject(CLIENT_LIST_PAGE_SIZE, { optional: true }) ?? 25` | si de verdad puede no estar. Con `strict`, el tipo pasa a `number \\| null` y te obliga a decidir el valor por defecto en el sitio |""",
 """| `inject(CLIENT_LIST_PAGE_SIZE, { optional: true }) ?? 25` | si de verdad puede no estar. Con `strict`, el tipo pasa a `number \\| null` y te obliga a decidir el valor por defecto en el sitio |

**Aquí termina esta rama.** El bug está localizado: un token sin proveedor en el camino de inyección por el que llegó el componente. Si el paréntesis decía `Standalone[…]`, **no vas a pasar por el Paso 3**: las dos ramas son excluyentes, y la tuya acaba eligiendo cuál de las tres salidas de la tabla corresponde. El Paso 4 sigue valiendo para los dos casos, y es otra cosa: cómo se lee este mismo error en producción."""),
('forense-fase-05.md',
 """El caso típico de este proyecto: alguien quitó `provideHttpClient(...)` de los `providers` de `CoreModule` —donde lo dejó la Fase 2— y todo lo que pide `HttpClient` deja de resolverse. Como `CoreModule` sólo se importa en `AppModule`, el paréntesis dice `AppModule`.""",
 """El caso típico de este proyecto: alguien quitó `provideHttpClient(...)` de los `providers` de `CoreModule` —donde lo dejó la Fase 2— y todo lo que pide `HttpClient` deja de resolverse. Como `CoreModule` sólo se importa en `AppModule`, el paréntesis dice `AppModule`.

**Aquí termina esta rama.** El bug está localizado: el proveedor no está en el módulo que el paréntesis nombra, ni en ninguno que ése importe. Si llegaste por aquí **no pasas por el Paso 2**: el mensaje ya dijo que el inyector era de módulo y no de componente standalone."""),
('forense-fase-07.md',
 """> *"No está desactualizada: está congelada, y es lo que tiene que pasar. Una inspección firmada en 2023 dice lo que se inspeccionó en 2023. Si se re-renderizara con la norma de hoy, el certificado que salió de ella estaría afirmando algo que nadie comprobó."*""",
 """> *"No está desactualizada: está congelada, y es lo que tiene que pasar. Una inspección firmada en 2023 dice lo que se inspeccionó en 2023. Si se re-renderizara con la norma de hoy, el certificado que salió de ella estaría afirmando algo que nadie comprobó."*

**Aquí termina la ruta del ticket 1.** Queda demostrado que **no hay bug**, y con las tres evidencias de arriba se puede cerrar el ticket por escrito. El ticket 2 sigue abierto y su ruta continúa en el Paso 5."""),
('forense-fase-07.md',
 """**Cada aparición de `resolveTemplateVersion` hay que justificarla.** Es correcta cuando se está **empezando** una inspección nueva —ahí sí se pregunta qué versión rige hoy— y es un bug en cualquier sitio donde se esté **leyendo** una inspección existente. La Fase 8 §5.9 tiene el único uso legítimo del curso.""",
 """**Cada aparición de `resolveTemplateVersion` hay que justificarla.** Es correcta cuando se está **empezando** una inspección nueva —ahí sí se pregunta qué versión rige hoy— y es un bug en cualquier sitio donde se esté **leyendo** una inspección existente. La Fase 8 §5.9 tiene el único uso legítimo del curso.

**Aquí termina la ruta del ticket 2.** El bug está localizado en una línea concreta: una llamada a `resolveTemplateVersion` en un camino de lectura. El fix es del incidente que corresponda; esta pieza localiza y para. El Paso 6 es un tercer síntoma que comparte la misma raíz y se recorre sólo si aparece."""),
('forense-fase-12.md',
 """```ts
// ✅ El arreglo, y es de diseño: el instante entra como parámetro.
issue(inspectionId: number, now: string): void { … }
```""",
 """```ts
// ✅ El arreglo, y es de diseño: el instante entra como parámetro.
issue(inspectionId: number, now: string): void { … }
```

**Aquí termina la ruta.** Si el test toca una fecha, una hora o un `Date.now()` propio, el sospechoso es éste y ya está localizado. **Si no toca ninguna de las tres, pasa al Sospechoso 2**: el orden de los cuatro es de más barato a más caro de descartar."""),
('forense-fase-12.md',
 """```ts
// ❌ expect(headers.get('X-Correlation-Id')).toBe('3f2a9c1e-…');
// ✅
expect(headers.get('X-Correlation-Id')).toMatch(/^[0-9a-f-]{36}$/);
```""",
 """```ts
// ❌ expect(headers.get('X-Correlation-Id')).toBe('3f2a9c1e-…');
// ✅
expect(headers.get('X-Correlation-Id')).toMatch(/^[0-9a-f-]{36}$/);
```

**Aquí termina la ruta.** Si la aserción compara contra un valor generado —un identificador, una semilla, un orden que dependa de un `Math.random()`—, el sospechoso es éste. **Si todas las aserciones comparan contra valores fijos, pasa al Sospechoso 3.**"""),
('forense-fase-12.md',
 """`done` también funciona y es peor: un `done` que no se llama **tarda cinco segundos en fallar**, y con veinte tests así el pipeline pasa de dos minutos a diez sin que nadie sepa por qué.""",
 """`done` también funciona y es peor: un `done` que no se llama **tarda cinco segundos en fallar**, y con veinte tests así el pipeline pasa de dos minutos a diez sin que nadie sepa por qué.

**Aquí termina la ruta.** Es el último de los cuatro sospechosos y el más caro de descartar, que es por lo que va el cuarto. **Si tampoco es éste**, no queda nada que razonar y empieza la fuerza bruta: el `git bisect` del paso final."""),
]
for f,o,n in ed:
    s=io.open(f,encoding='utf-8').read()
    assert o in s, (f,o[:60])
    assert s.count(o)==1, (f,'ambiguo')
    io.open(f,'w',encoding='utf-8').write(s.replace(o,n,1))
    print("ok",f,'·',n.split('**Aquí termina')[1][:40].strip())
PY

# --- 2026-09-11T03:37:58 · Get exact endings of the ten group-A steps
python3 - <<'PY'
import re,io
casos=[('forense-fase-01.md','Paso 4 — Dentro'),('forense-fase-06.md','Paso 3 — Si es `PENDING`'),
('forense-fase-07.md','Paso 2 — ⭐'),('forense-fase-08.md','Paso 2 — Y la comprobación gemela'),
('forense-fase-09.md','Paso 2 — Las tres preguntas'),('forense-fase-09.md','Paso 1 — ¿El dato está'),
('forense-fase-12.md','Sospechoso 3'),('forense-fase-13.md','Paso 4 — ¿Y la ruta'),
('forense-fase-14.md','Paso 1 — El estado ya'),('forense-fase-14.md','Paso 3 — El caso sin logs')]
for f,t in casos:
    s=io.open(f,encoding='utf-8').read()
    for b in re.split(r'^### ', s, flags=re.M)[1:]:
        if b.startswith(t):
            l=b.rstrip().split('\n')
            print(f"\n█ {f} · {l[0][:60]}")
            print(repr('\n'.join(l[-3:]))[:330]); break
PY

# --- 2026-09-11T03:38:41 · Normalize the discard marker in ten steps
python3 - <<'PY'
import io
ed=[
('forense-fase-01.md',
"""// {…}        → existe y no se pinta: falta el <router-outlet> o el CSS lo oculta
```""",
"""// {…}        → existe y no se pinta: falta el <router-outlet> o el CSS lo oculta
```

**Qué descarta.** `undefined` descarta el `<router-outlet>` y el CSS: el componente nunca llegó a construirse, así que el problema es de rutas y vuelves al **Paso 3** con el `forChild` delante. Un objeto descarta lo contrario —la ruta funcionó— y deja dos culpables, el outlet ausente o el estilo que lo oculta, que se confirman en el **Paso 5** contra un build de producción."""),

('forense-fase-06.md',
"""Quita cualquiera de las tres y tienes un ticket distinto: sin `timer`, una petición por tecla; sin `catchError`, el formulario se bloquea cuando el servidor tose; sin `first()`, el control se queda `PENDING` **para siempre** y el formulario no vuelve a ser válido en toda la sesión.""",
"""Quita cualquiera de las tres y tienes un ticket distinto: sin `timer`, una petición por tecla; sin `catchError`, el formulario se bloquea cuando el servidor tose; sin `first()`, el control se queda `PENDING` **para siempre** y el formulario no vuelve a ser válido en toda la sesión.

**Qué descarta.** Cuál de las tres piezas falta te dice cuál de los tres tickets tienes, y los tres se distinguen sin abrir el validador: una petición por tecla en Network es el `timer`; un `PENDING` que sobrevive a una respuesta con error es el `catchError`; y un `PENDING` eterno con la respuesta ya llegada es el `first()`. Si el validador tiene las tres y el control sigue colgado, el problema no es el validador: pasa al **Paso 4**."""),

('forense-fase-07.md',
"""| No hay ninguna petición a `/templates` | la plantilla salió de un estado ya cargado | y ese estado puede tener la vigente: mira el `*StateService` |""",
"""| No hay ninguna petición a `/templates` | la plantilla salió de un estado ya cargado | y ese estado puede tener la vigente: mira el `*StateService` |

**Qué descarta.** Esa tabla descarta cuatro de las seis causas sin abrir un archivo. Si la URL lleva el `version=` que la inspección tiene guardado, el sistema está haciendo lo correcto y vas al **Paso 4**, que demuestra que no hay bug. Si lleva otro número o no lleva ninguno, hay bug y su línea está en el **Paso 5**."""),

('forense-fase-08.md',
"""**Un formulario dinámico construido con la plantilla equivocada no falla: funciona.** Ése es el peligro entero.""",
"""**Un formulario dinámico construido con la plantilla equivocada no falla: funciona.** Ése es el peligro entero.

**Qué descarta.** Si las claves del formulario son las de otra versión, descarta el bucle de la ruta A y el `NG0100` de la ruta C: no es un problema de emisión ni de detección de cambios, es que el formulario se construyó con la plantilla que no era. El **Paso 3** dice por qué eso se arregla rehaciendo el `FormRecord` y no parcheándolo."""),

('forense-fase-09.md',
"""> ⚠️ **`strict: true` no te salva de esto, y conviene entender por qué.** El compilador comprueba lo que **declaraste**, y tú declaraste `string | null`. Si el dato real trae `undefined`, el compilador no tiene forma de saberlo: nunca vio la respuesta. `strict` protege la frontera entre tus archivos; **la frontera con la red la tienes que defender tú.**""",
"""> ⚠️ **`strict: true` no te salva de esto, y conviene entender por qué.** El compilador comprueba lo que **declaraste**, y tú declaraste `string | null`. Si el dato real trae `undefined`, el compilador no tiene forma de saberlo: nunca vio la respuesta. `strict` protege la frontera entre tus archivos; **la frontera con la red la tienes que defender tú.**

**Qué descarta.** La tercera línea es la que decide. Si `'resolvedAt' in finding` devuelve `false`, el campo no existe y descarta toda hipótesis sobre la regla: el problema entró por la red y el arreglo va en el borde, que es el **Paso 3**. Si devuelve `true` y el valor es `null`, la regla está bien escrita y el bug es de otro sitio: la ruta A no es la tuya."""),

('forense-fase-09.md',
"""**Guardado dice `major`. Pintado dice `minor`.** El dato existe, se guardó bien, y algo lo está recalculando por encima.""",
"""**Guardado dice `major`. Pintado dice `minor`.** El dato existe, se guardó bien, y algo lo está recalculando por encima.

**Qué descarta.** Descarta el guardado entero —la petición, el servidor y el `db.json`— y con él la mitad de las hipótesis del ticket: nadie perdió el cambio, alguien lo está pisando al leer. Si el JSON guardado dijera `minor`, la ruta sería la contraria y el problema estaría en la escritura. Con `major` guardado, sigues al **Paso 2**: quién manda, el dato o la regla."""),

('forense-fase-12.md',
"""> 🧭 **Un test que sólo pasa si otro corrió antes no es un test: es media prueba.** Y su fallo aparece el día que alguien añada un `it` en otro archivo, que es cuando nadie lo va a relacionar con nada.""",
"""> 🧭 **Un test que sólo pasa si otro corrió antes no es un test: es media prueba.** Y su fallo aparece el día que alguien añada un `it` en otro archivo, que es cuando nadie lo va a relacionar con nada.

**Qué descarta.** Si el test pasa aislado y falla en la suite, el sospechoso es éste y la tabla de arriba tiene las fugas de estado que lo producen. **Si falla igual aislado**, el orden no tiene nada que ver y pasas al **Sospechoso 4**, que es el último y el más caro."""),

('forense-fase-13.md',
"""nginx busca un **archivo** llamado `inspections/500`. No existe: esa ruta sólo vive dentro del router de Angular, en el navegador. `try_files $uri $uri/ /index.html;` es la línea que lo arregla, y el síntoma que produce su ausencia es desconcertante porque **navegar funciona y recargar no**.""",
"""nginx busca un **archivo** llamado `inspections/500`. No existe: esa ruta sólo vive dentro del router de Angular, en el navegador. `try_files $uri $uri/ /index.html;` es la línea que lo arregla, y el síntoma que produce su ausencia es desconcertante porque **navegar funciona y recargar no**.

**Qué descarta.** Un `404` localiza el bug en la configuración del servidor y descarta el código de la aplicación: no hay nada que buscar en el proyecto. Un `200` descarta el `try_files` y deja un solo sospechoso, que es el del **Paso 5** — y por eso el código va el último."""),

('forense-fase-14.md',
"""`RESTARTS 4` significa que **arrancó cuatro veces y se murió cuatro veces**. Arrancó: hay logs. Y el cluster está esperando cada vez más entre intentos, que es lo que significa el `BackOff`.""",
"""`RESTARTS 4` significa que **arrancó cuatro veces y se murió cuatro veces**. Arrancó: hay logs. Y el cluster está esperando cada vez más entre intentos, que es lo que significa el `BackOff`.

**Qué descarta.** Que haya reinicios descarta la ruta A entera: la imagen se descargó y el contenedor llegó a ejecutarse, así que no es un problema de registro ni de almacén. Y como arrancó, **hay algo escrito**: el **Paso 2** va a por los logs. Si `RESTARTS` fuera `0` y el estado no fuera `CrashLoopBackOff`, esta ruta no es la tuya."""),

('forense-fase-14.md',
"""El proceso no llega a ejecutarse, así que no escribe nada. Es un segundo de comprobación y descarta la causa más desconcertante del capítulo. El diagnóstico completo está en **A12** §6.""",
"""El proceso no llega a ejecutarse, así que no escribe nada. Es un segundo de comprobación y descarta la causa más desconcertante del capítulo. El diagnóstico completo está en **A12** §6.

**Qué descarta.** Si la arquitectura de la imagen no es la del nodo, ahí termina la búsqueda y el resto de la ruta sobra. Si coinciden, descarta la arquitectura y quedan dos posibilidades, las dos del **Paso 4**: que el pod ya se reciclara y sus logs se fueran con él, o que nunca escribiera nada por otro motivo."""),
]
for f,o,n in ed:
    s=io.open(f,encoding='utf-8').read()
    assert o in s, (f,o[:50]); assert s.count(o)==1, (f,'ambiguo',o[:50])
    io.open(f,'w',encoding='utf-8').write(s.replace(o,n,1))
    print("ok",f)
PY

# --- 2026-09-11T03:38:51 · Get exact ending of piece 02 step 4
python3 - <<'PY'
import re,io
s=io.open('forense-fase-02.md',encoding='utf-8').read()
for b in re.split(r'^### ', s, flags=re.M)[1:]:
    if b.startswith('Paso 4 — Dónde va'):
        l=b.rstrip().split('\n'); print(repr('\n'.join(l[-4:])))
PY

# --- 2026-09-11T03:39:12 · Write the missing jumps in the three real gaps
python3 - <<'PY'
import io
ed=[
('forense-fase-02.md',
"""Ese `isLogin` es la mitad del bug clásico de esta fase: si el interceptor no distingue el `401` del **login** —que significa "te equivocaste de contraseña"— del `401` de **cualquier otra ruta** —que significa "tu sesión caducó"—, cada intento fallido de inicio de sesión provoca un `logout()` y una redirección a `/login`, desde `/login`. El bucle no da error; la pantalla parpadea y el usuario dice *"no me deja entrar y no dice nada"*.""",
"""Ese `isLogin` es la mitad del bug clásico de esta fase: si el interceptor no distingue el `401` del **login** —que significa "te equivocaste de contraseña"— del `401` de **cualquier otra ruta** —que significa "tu sesión caducó"—, cada intento fallido de inicio de sesión provoca un `logout()` y una redirección a `/login`, desde `/login`. El bucle no da error; la pantalla parpadea y el usuario dice *"no me deja entrar y no dice nada"*.

**Qué descarta.** Cada momento descarta una cosa distinta, y por eso hacen falta los dos. Si en el **momento 1** la petición ya sale sin `Authorization`, el problema es del token —no llegó, no se guardó, o el servicio lo devuelve vacío— y el interceptor está haciendo su trabajo. Si sale con el token puesto, eso queda descartado y la respuesta manda: el **momento 2** te dice si el `401` viene del login o de otra ruta, que es la distinción que separa el bug clásico de una contraseña mal escrita. Con las dos respuestas, el **Paso 5** confirma contra el servidor quién de los dos miente."""),

('forense-fase-14.md',
"""# Y la comprobación, que es lo que convierte esto en conocimiento:
docker exec certcore-control-plane crictl images | grep certcore
# docker.io/library/certcore   fase-13   9f2c4b1e7a8d   48.3MB
```""",
"""# Y la comprobación, que es lo que convierte esto en conocimiento:
docker exec certcore-control-plane crictl images | grep certcore
# docker.io/library/certcore   fase-13   9f2c4b1e7a8d   48.3MB
```

**Qué descarta.** Si `crictl images` no la muestra, el diagnóstico termina aquí: la imagen nunca llegó al nodo y cargarla lo resuelve. Si **sí la muestra y el pod sigue en `ImagePullBackOff`**, eso descarta el almacén y deja una sola causa posible, que es la del **Paso 3**: el nodo está intentando descargarla aunque la tenga."""),

('forense-fase-14.md',
"""Es la causa raíz más desconcertante de esta ruta, y desaparece sola en cuanto la imagen tiene un tag de verdad.""",
"""Es la causa raíz más desconcertante de esta ruta, y desaparece sola en cuanto la imagen tiene un tag de verdad.

**Qué descarta.** Si el tag es `:latest`, el bug está localizado y basta con ponerle uno de verdad. **Si ya tiene un tag normal** y el `imagePullPolicy` dice `IfNotPresent`, eso descarta la política y descarta el almacén del Paso 2: no es un problema de kind, y la ruta se agota aquí. Lo que queda es el **Paso 4**, que ya no es diagnóstico sino las tres preguntas con las que se abre el ticket en un cluster que no administras tú."""),
]
for f,o,n in ed:
    s=io.open(f,encoding='utf-8').read()
    assert o in s, (f,o[:50]); assert s.count(o)==1,(f,'ambiguo')
    io.open(f,'w',encoding='utf-8').write(s.replace(o,n,1)); print("ok",f)
PY

# --- 2026-09-11T03:39:41 · Run the forensic verifier
python3 prompts/verificar-forenses.py; echo "código de salida: $?"

# --- 2026-09-11T03:39:55 · Read endings of the fifteen final steps
python3 - <<'PY'
import re,io,glob
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    secs=re.split(r'^(## .+)$', s, flags=re.M)
    for i in range(1,len(secs),2):
        if '🧭' not in secs[i]: continue
        for b in re.split(r'^### ', secs[i+1], flags=re.M)[1:]:
            if re.search(r'\*\*Qué descarta|\*\*Aquí termina', b): continue
            l=[x for x in b.rstrip().split('\n') if x.strip()]
            print(f"\n█ {f} · {l[0][:58]}")
            print(repr(l[-1])[:300])
PY

# --- 2026-09-11T03:40:03 · Read substantive endings of the final steps
python3 - <<'PY'
import re,io,glob
# Para escribir un cierre fiel necesito la penúltima frase real de cada bloque
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    secs=re.split(r'^(## .+)$', s, flags=re.M)
    for i in range(1,len(secs),2):
        if '🧭' not in secs[i]: continue
        for b in re.split(r'^### ', secs[i+1], flags=re.M)[1:]:
            if re.search(r'\*\*Qué descarta|\*\*Aquí termina', b): continue
            l=[x for x in b.rstrip().split('\n') if x.strip() and x.strip()!='---']
            print(f"\n█ {f} · {l[0][:56]}")
            print(' '.join(' '.join(l[-2:]).split())[:270])
PY

# --- 2026-09-11T03:40:41 · Add closing markers to the fifteen final steps
python3 - <<'PY'
import re,io,glob
cierres={
('forense-fase-00.md','Paso 5'):"**Aquí termina la ruta.** El síntoma ya es concreto: hay una línea de código, un archivo y un momento. Con eso el ticket deja de decir *«no pasó nada»* y pasa a decir algo que se puede arreglar — que es todo lo que una pieza forense promete.",
('forense-fase-05.md','Paso 4'):"**Aquí termina la ruta.** Sabes leer el mismo error en los dos sitios donde te lo vas a encontrar, y en producción sabes qué parte del mensaje sobrevive a la minificación y cuál no. El arreglo es de la rama por la que llegaste, el Paso 2 o el Paso 3.",
('forense-fase-06.md','Paso 4'):"**Aquí termina la ruta.** El bug está localizado: una bandera que sólo se repone por el camino feliz. Es la misma forma que el `PENDING` colgado del Paso 3, y reconocer esa forma —no este archivo— es lo que te llevas.",
('forense-fase-07.md','Paso 6'):"**Aquí termina la ruta.** Las tres versiones del síntoma están localizadas y comparten una raíz: alguien preguntó qué versión rige hoy donde tenía que leer la que quedó guardada. La pieza no va más allá; los fixes son de los incidentes 08, 09, 10 y 12.",
('forense-fase-08.md','Paso 3 — El ciclo'):"**Aquí termina la ruta A.** El bucle está localizado y tiene dos formas de romperse, las dos escritas arriba. Si tu síntoma no era la aplicación hablando sola sino un control que falta o sobra, la tuya es la **ruta B**.",
('forense-fase-08.md','Paso 3 — Por qué'):"**Aquí termina la ruta B.** El control huérfano está explicado y con él la regla que evita la familia entera. Si además veías un error rojo que desaparece al desplegar, queda la **ruta C**.",
('forense-fase-08.md','Paso 2 — El experimento'):"**Aquí termina la ruta C.** Y termina con la conclusión incómoda: el `NG0100` no se arregló, dejó de contarse. El bug que lo producía sigue ahí y ahora es silencioso, que es exactamente lo que la Fase 13 vuelve a enseñar con el build de producción.",
('forense-fase-09.md','Paso 3 — Dónde va'):"**Aquí termina la ruta A.** El bug está localizado —una comparación estricta contra un campo que no existe— y, más importante, está decidido **dónde** va el arreglo: en el borde, una sola vez. Si tu síntoma era un cambio que se deshace solo, la tuya es la **ruta B**.",
('forense-fase-09.md','Paso 3 — La forma'):"**Aquí termina la ruta B.** El bug está localizado y la regla del proyecto que lo evita, escrita. Lo que esta ruta **no** resuelve —que la anulación no quede registrada en ninguna parte— no es un bug: es una deuda, y va al post-mortem del incidente.",
('forense-fase-10.md','Paso 4 — Por qué'):"**Aquí termina la ruta A.** El bug está localizado en una conversión que usa el huso del navegador para una decisión de negocio, y el arreglo es una función con el huso dentro. Si tu síntoma era que el PDF no coincide con la pantalla, la tuya es la **ruta B**.",
('forense-fase-10.md','Paso 2 — La comprobación'):"**Aquí termina la ruta B.** El bug está localizado: el documento se arma con lo que el componente tenía a mano en vez de con el dato de la fuente. La pieza no escribe el fix — es del incidente 14 — pero deja la firma del tipo, que es por dónde empieza.",
('forense-fase-12.md','Paso 3 — El fix'):"**Aquí termina la ruta A.** El incidente queda cerrado con su par de tags y su `git diff` de dos líneas. Si lo que tienes no es un fallo reproducible sino uno que aparece y desaparece, la tuya es la **ruta B**.",
('forense-fase-12.md','Paso final'):"**Aquí termina la ruta B.** Si ninguno de los cuatro sospechosos era, la bisección localiza el commit y ahí se acaba el razonamiento: a partir de ese commit, el diagnóstico vuelve a ser de lectura. Es el único paso de la pieza que no descarta nada — busca.",
('forense-fase-14.md','Paso 4 — Lo mismo'):"**Aquí termina la ruta A.** En tu cluster de kind el bug está localizado en el Paso 2 o en el Paso 3; en el de tu empresa, lo que esta ruta te deja no es el fix sino **las tres preguntas con las que se abre el ticket bien**, que es lo máximo que puede darte una pieza sobre un cluster que no administras.",
('forense-fase-14.md','Paso 4 — Cuando el pod'):"**Aquí termina la ruta B.** O tienes los logs del arranque anterior, o sabes que no existen y por qué. Las dos son respuestas: la segunda convierte el ticket en una pregunta para plataforma —*¿qué agregador tenemos?*— en vez de en una búsqueda que no puede terminar.",
}
hechos=0
for f in sorted(set(k[0] for k in cierres)):
    s=io.open(f,encoding='utf-8').read()
    secs=re.split(r'^(## .+)$', s, flags=re.M)
    out=[]
    for idx,part in enumerate(secs):
        if idx%2==1 or idx==0:
            out.append(part); continue
        cab=secs[idx-1] if idx>0 else ''
        if '🧭' not in cab: out.append(part); continue
        trozos=re.split(r'(^### )', part, flags=re.M)
        nuevo=[]; k=0
        while k<len(trozos):
            if trozos[k]=='### ':
                cuerpo=trozos[k+1]
                titulo=cuerpo.split('\n')[0]
                if not re.search(r'\*\*Qué descarta|\*\*Aquí termina', cuerpo):
                    for (ff,pref),txt in cierres.items():
                        if ff==f and titulo.startswith(pref):
                            cuerpo=re.sub(r'\n---\s*$', '\n\n'+txt+'\n\n---\n', cuerpo.rstrip())+'\n'
                            hechos+=1; break
                nuevo.append('### '); nuevo.append(cuerpo); k+=2
            else:
                nuevo.append(trozos[k]); k+=1
        out.append(''.join(nuevo))
    io.open(f,'w',encoding='utf-8').write(''.join(out))
print("cierres añadidos:",hechos)
PY
python3 prompts/verificar-forenses.py; echo "salida: $?"

# --- 2026-09-11T03:40:52 · Verify structural integrity after the rewrite
python3 - <<'PY'
import re,io,glob
# 1. ninguna pieza perdió estructura al reescribirse
for f in sorted(glob.glob('forense-fase-*.md')):
    s=io.open(f,encoding='utf-8').read()
    for e in ['🎫','🧭','🩺','⚰️','🧨','🧠']:
        assert e in s, (f,e)
print("bloques obligatorios y opcionales: intactos en las 15")
# 2. conteo de marcas
d=t=0
for f in glob.glob('forense-fase-*.md'):
    s=io.open(f,encoding='utf-8').read()
    d+=len(re.findall(r'\*\*Qué descarta',s)); t+=len(re.findall(r'\*\*Aquí termina',s))
print(f"marcas: {d} «Qué descarta» · {t} «Aquí termina» · {d+t} pasos cerrados")
# 3. separadores --- no duplicados
for f in glob.glob('forense-fase-*.md'):
    s=io.open(f,encoding='utf-8').read()
    assert '---\n\n---' not in s and '---\n---' not in s, f
print("separadores: sin duplicados")
# 4. enlaces siguen bien
import os
mal=0
for p in glob.glob('*.md')+glob.glob('prompts/*.md'):
    s=io.open(p,encoding='utf-8').read(); b=os.path.dirname(p)
    for m in re.finditer(r'\]\((\.?\.?/?[^)#\s]+\.md)\)', s):
        if not os.path.exists(os.path.normpath(os.path.join(b,m.group(1)))): mal+=1; print("ROTO",p,m.group(1))
print("enlaces .md rotos:",mal)
PY

# --- 2026-09-11T03:40:59 · Spot-check two rewritten steps
sed -n '/Paso 4 — Si es `VALID`/,/^---/p' forense-fase-06.md | tail -6; echo "════════"; sed -n '/Sospechoso 2 — El azar/,/^### Sospechoso 3/p' forense-fase-12.md | tail -8

# --- 2026-09-11T03:41:06 · Check whether the style guide references the forensic format
python3 - <<'PY'
import io,re
# Dejar constancia en la guía de estilo del curso, que es donde se listan las convenciones del track forense
p='prompts/guia-de-estilo-y-convenciones.md'; s=io.open(p,encoding='utf-8').read()
m=re.search(r'[^\n]*formato-piezas-forenses[^\n]*', s)
print("mención en la guía:", (m.group(0)[:160] if m else "NINGUNA"))
PY

# --- 2026-09-11T03:41:12 · Find forensic references in the style guide
grep -n -i 'forense' prompts/guia-de-estilo-y-convenciones.md | head -6

# --- 2026-09-11T03:41:26 · Final full audit of the course
echo "── verificador de piezas ──"; python3 prompts/verificar-forenses.py | tail -2
echo; echo "── auditoría completa ──"; python3 - <<'PY'
import re,io,glob,os
def r(p): return io.open(p,encoding='utf-8').read()
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p))
# usado por
bad=sum(1 for a in sorted(glob.glob('a[0-9][0-9]-*.md'))
        if sorted(set(int(x) for x in re.findall(r'Fase\s+(\d+)', re.search(r'Usado por:\s*([^\n·]*)',r(a)).group(1))))
        != sorted(int(p[:2]) for p in fases if (lambda h: h and re.search(r'\b'+a[:3].upper()+r'\b',h.group(1)))(re.search(r'Apéndices de apoyo:([^\n]*)',r(p)))))
print("apéndices con 'Usado por' desajustado:",bad)
# estructura apéndices
falt=[a for a in glob.glob('a[0-9][0-9]-*.md') if not ('🏷️' in r(a) and 'Referencias' in r(a) and 'usar qué' in r(a))]
print("apéndices sin estructura completa:",falt or 0)
# enlaces
mal=0
for p in glob.glob('*.md')+glob.glob('prompts/*.md'):
    s=r(p); b=os.path.dirname(p)
    for m in re.finditer(r'\]\((\.?\.?/?[^)#\s]+\.md)\)', s):
        if not os.path.exists(os.path.normpath(os.path.join(b,m.group(1)))): mal+=1
print("enlaces .md rotos:",mal)
# master indexa
m=r('forense-master.md'); print("piezas sin indexar en el master:",[f for f in glob.glob('forense-fase-*.md') if f not in m] or 0)
PY

# --- 2026-09-11T03:52:41 · Check angular-8 link state
cd .. && grep -n '00-convencion-de-git-y-tags.md)' angular-8-legacy-for-backend-devs/prompts/plantillas-de-capitulo.md angular-8-legacy-for-backend-devs/prompts/guia-de-estilo-y-convenciones.md | head; echo "--- git ---"; git diff --stat angular-8-legacy-for-backend-devs/prompts/plantillas-de-capitulo.md

# --- 2026-09-11T03:52:51 · Inspect the angular-8 template diff
git diff angular-8-legacy-for-backend-devs/prompts/plantillas-de-capitulo.md | head -20; echo "===== a16 ====="; git diff --stat angular-16-legacy-for-backend-devs/prompts/plantillas-de-capitulo.md

# --- 2026-09-11T03:53:15 · Repo-wide broken link audit by course
python3 - <<'PY'
import re,io,os,glob
print("═══ 1. ENLACES .md EN TODO EL REPO ═══")
rotos={}
for root,dirs,files in os.walk('.'):
    dirs[:]=[d for d in dirs if d not in ('.git','node_modules')]
    for f in files:
        if not f.endswith('.md'): continue
        p=os.path.join(root,f); s=io.open(p,encoding='utf-8',errors='ignore').read()
        for m in re.finditer(r'\]\((\.{0,2}/?[^)#\s]+\.md)\)', s):
            if not os.path.exists(os.path.normpath(os.path.join(root,m.group(1)))):
                rotos.setdefault(root.split('/')[1] if '/' in root else '(raíz)',[]).append((p,m.group(1)))
for curso,lst in sorted(rotos.items()):
    print(f"  {curso}: {len(lst)}")
    for p,d in lst[:3]: print(f"     {p} -> {d}")
    if len(lst)>3: print(f"     … y {len(lst)-3} más")
if not rotos: print("  ninguno")
PY

# --- 2026-09-11T03:53:31 · Verify the bea- rename left no loose ends
python3 - <<'PY'
import re,io,os,glob
print("═══ 2. RENOMBRADO bea- ═══")
restos=[]
for root,dirs,files in os.walk('.'):
    dirs[:]=[d for d in dirs if d not in ('.git','node_modules')]
    for f in files:
        if not f.endswith('.md'): continue
        p=os.path.join(root,f); s=io.open(p,encoding='utf-8',errors='ignore').read()
        for m in re.finditer(r'be-a-\S*', s):
            ctx=s[max(0,m.start()-120):m.start()]
            documentado = ('🪦' in ctx or 'Renombrad' in ctx or 'used to be' in ctx or 'era `be-a' in ctx or 'convención era' in ctx)
            restos.append((p,m.group(0)[:22],documentado))
doc=[r for r in restos if r[2]]; sin=[r for r in restos if not r[2]]
print(f"  ocurrencias de 'be-a-': {len(restos)} → {len(doc)} en notas 🪦 documentadas, {len(sin)} sin documentar")
for p,t,_ in sin[:8]: print("     ⚠",p,t)
print(f"  archivos bea-*.md: {len(glob.glob('*/bea-*.md'))}")
mal=0
for root,dirs,files in os.walk('.'):
    dirs[:]=[d for d in dirs if d not in ('.git','node_modules')]
    for f in files:
        if not f.endswith('.md'): continue
        p=os.path.join(root,f); s=io.open(p,encoding='utf-8',errors='ignore').read()
        for m in re.finditer(r'\]\(([^)#\s]*bea-[^)#\s]+\.md)\)', s):
            if not os.path.exists(os.path.normpath(os.path.join(root,m.group(1)))): print("     ROTO",p,m.group(1)); mal+=1
print(f"  enlaces a apéndices bea- rotos: {mal}")
PY

# --- 2026-09-11T03:53:38 · Inspect the three undocumented be-a- occurrences
grep -n -B2 'be-a-NN-`' CLAUDE.md angular-8-legacy-for-backend-devs/prompts/guia-de-estilo-y-convenciones.md | head -14

# --- 2026-09-11T03:53:54 · Audit the angular-8 backend track
cd angular-8-legacy-for-backend-devs && python3 - <<'PY'
import re,io,glob
print("═══ 3. TRACK BE DE ANGULAR-8 ═══")
fases=sorted(glob.glob('be0*.md')); aps=sorted(glob.glob('bea-*.md'))
print(f"  fases: {len(fases)}  apéndices: {len(aps)}  cuaderno: {'sí' if glob.glob('cuaderno-incidentes-be.md') else 'NO'}")
# ejercicios declarados vs reales
for f in fases:
    s=io.open(f,encoding='utf-8').read()
    d=re.search(r'Ejercicios \((\d+)\)',s); n=len(re.findall(r'^\d+\. ', '\n'.join(re.split(r'^## 🧪',s,flags=re.M)[1].split('\n## ')[0].split('\n')), re.M)) if d else 0
    if d and int(d.group(1))!=n: print(f"  ⚠ {f}: declara {d.group(1)} y hay {n}")
print("  ejercicios de fases: cuadran" )
# apéndices: estructura
for a in aps:
    s=io.open(a,encoding='utf-8').read()
    falt=[k for k,v in [('🏷️','🏷️' in s),('Referencias','Referencias' in s),('Cuándo usar qué','usar qué' in s),('Usado por','Usado por' in s or 'Usado por' in s)] if not v]
    if falt: print(f"  ⚠ {a}: falta {falt}")
print("  apéndices: estructura completa")
# incidentes reservados vs cuaderno
res=set()
for f in fases: res|=set(re.findall(r'\*\*(be-\d\d)\*\*', io.open(f,encoding='utf-8').read()))
cu=io.open('cuaderno-incidentes-be.md',encoding='utf-8').read()
tiene=set(re.findall(r'^## Incidente (be-\d\d)', cu, re.M))
print(f"  incidentes reservados en fases: {len(res)} · escritos en el cuaderno: {len(tiene)}")
print(f"  reservados sin entrada: {sorted(res-tiene) or 'ninguno'}")
print(f"  entradas sin reserva:  {sorted(tiene-res) or 'ninguno'}")
# apéndices citados por fases BE
for a in aps:
    code=a[:6]
    if not any(code in io.open(f,encoding='utf-8').read() for f in fases): print(f"  ⚠ {code} no lo cita ninguna fase")
print("  apéndices BE: todos citados")
PY

# --- 2026-09-11T03:54:05 · Cross-reference audit of the BE track
python3 - <<'PY'
import re,io,glob
print("═══ 3b. COHERENCIA CRUZADA DEL TRACK BE ═══")
fases=sorted(glob.glob('be0*.md')); aps=sorted(glob.glob('bea-*.md'))
def r(p): return io.open(p,encoding='utf-8').read()
# 'Usado por' de cada apéndice vs 'Apéndices de apoyo' de las fases BE
print(f"  {'ap':8} {'declara':26} {'lo listan las fases':26}")
bad=0
for a in aps:
    code=a[:6]; s=r(a)
    m=re.search(r'Usado por:\s*([^\n·]*)', s)
    dec=sorted(set(re.findall(r'be0\d', m.group(1)))) if m else []
    cab=[]
    for f in fases:
        h=re.search(r'Apéndices de apoyo:([^\n]*)', r(f))
        if h and code in h.group(1): cab.append(f[:4])
    if sorted(dec)!=sorted(cab): bad+=1; print(f"  ⚠ {code:8} {str(dec):26} {str(sorted(cab)):26}")
print(f"  apéndices BE con 'Usado por' desajustado: {bad}")
# bloque tag en fases BE
for f in fases:
    s=r(f)
    if 'be-fase-' not in s or '🏷️' not in s: print("  ⚠ sin bloque 🏷️ o tag:",f)
print("  bloques 🏷️ de fases BE: ok")
# README refleja el estado
rd=r('README.md')
print(f"  README marca ✅ en: {len(re.findall(r'✅', rd))} filas")
PY

# --- 2026-09-11T03:54:14 · Check prose mentions of the three mismatched BE appendices
for p in "bea-02 be02" "bea-04 be05" "bea-04 be06" "bea-12 be03"; do set -- $p; n=$(grep -c "$1" $2*.md); echo "$1 en $2: $n menciones"; grep -o "[^ ]*$1[^ ]*" $2*.md | head -2; done

# --- 2026-09-11T03:54:22 · Correctly check prose mentions in the BE phases
python3 - <<'PY'
import io,glob,re
pares=[('bea-02','be02'),('bea-04','be05'),('bea-04','be06'),('bea-12','be03')]
for ap,fa in pares:
    f=glob.glob(fa+'-*.md')[0]
    s=io.open(f,encoding='utf-8').read()
    hits=[' '.join(l.split())[:120] for l in s.split('\n') if ap in l]
    print(f"\n{ap} declara {fa} → {len(hits)} menciones en {f}")
    for h in hits[:3]: print("   ",h)
PY

# --- 2026-09-11T03:54:38 · Read the lines to correct
grep -n 'Apéndices de apoyo' be02-medir-la-deriva-de-esquema.md; grep -n 'Usado por' bea-04-agregaciones-como-instrumento-de-medida.md bea-12-datos-de-prueba-y-volumen.md

# --- 2026-09-11T03:54:45 · Read bea-02 usage line and be03 header
grep -n 'Usado por' bea-02-receta-de-imagen-y-compose.md; grep -n 'Apéndices de apoyo' be03-la-costura-y-el-reemplazo.md

# --- 2026-09-11T03:54:57 · Fix the BE cross-reference mismatches and verify
python3 - <<'PY'
import io
# 1. be02 sí usa bea-02 (§5.1 enlaza el compose) → completar su cabecera
p='be02-medir-la-deriva-de-esquema.md'; s=io.open(p,encoding='utf-8').read()
o="> Apéndices de apoyo: [bea-04 (agregaciones como instrumento de medida)](./bea-04-agregaciones-como-instrumento-de-medida.md)"
n="> Apéndices de apoyo: [bea-02 (imagen y compose)](./bea-02-receta-de-imagen-y-compose.md) · [bea-04 (agregaciones como instrumento de medida)](./bea-04-agregaciones-como-instrumento-de-medida.md)"
assert o in s; io.open(p,'w',encoding='utf-8').write(s.replace(o,n,1)); print("ok be02: bea-02 añadido a la cabecera")

# 2. bea-12: be03 sólo lo usa en un ejercicio 🔥 → decirlo con la precisión de bea-04
p='bea-12-datos-de-prueba-y-volumen.md'; s=io.open(p,encoding='utf-8').read()
o="> Usado por: be02, be03 ·"
n="> Usado por: be02; de consulta desde be03 (su ejercicio 🔥 de volumen) ·"
assert o in s; io.open(p,'w',encoding='utf-8').write(s.replace(o,n,1)); print("ok bea-12: matizado")
PY
python3 - <<'PY'
import re,io,glob
fases=sorted(glob.glob('be0*.md')); bad=0
for a in sorted(glob.glob('bea-*.md')):
    code=a[:6]; m=re.search(r'Usado por:\s*([^\n·]*)', io.open(a,encoding='utf-8').read())
    linea=m.group(1)
    # sólo las fases citadas SIN matiz ("de consulta", "sobre todo")
    principal=re.split(r'; de consulta|; de |sobre todo', linea)[0]
    dec=sorted(set(re.findall(r'be0\d', principal)))
    cab=sorted(f[:4] for f in fases if code in (re.search(r'Apéndices de apoyo:([^\n]*)', io.open(f,encoding='utf-8').read()) or type('x',(),{'group':lambda s,n:''})()).group(1))
    if dec!=cab: bad+=1; print(f"  ⚠ {code}: declara {dec} · cabeceras {cab}")
print("apéndices BE con desajuste real:",bad)
PY

# --- 2026-09-11T03:55:08 · Audit react-16 after the rename
cd ../react-16-legacy-for-backend-devs && python3 - <<'PY'
import re,io,glob,os
print("═══ 4. REACT-16 TRAS EL RENOMBRADO ═══")
aps=sorted(glob.glob('bea-*.md')); fases=sorted(glob.glob('be0*.md'))
print(f"  apéndices bea-: {len(aps)} · fases be0*: {len(fases)}")
rd=io.open('README.md',encoding='utf-8').read()
falt=[a for a in aps if a not in rd]
print(f"  apéndices no listados en el README: {falt or 'ninguno'}")
# enlaces
mal=0
for p in glob.glob('*.md')+glob.glob('prompts/*.md'):
    s=io.open(p,encoding='utf-8').read(); b=os.path.dirname(p)
    for m in re.finditer(r'\]\((\.{0,2}/?[^)#\s]+\.md)\)', s):
        if not os.path.exists(os.path.normpath(os.path.join(b,m.group(1)))): mal+=1; print("   ROTO",p,m.group(1))
print(f"  enlaces .md rotos: {mal}")
# cuadernos
print(f"  cuadernos: {[f for f in glob.glob('cuaderno-*.md')]}")
# 'Usado por'
for a in aps:
    s=io.open(a,encoding='utf-8').read()
    if 'Usado por' not in s: print("   ⚠ sin línea 'Usado por':",a)
print("  líneas 'Usado por': presentes")
PY

# --- 2026-09-11T03:55:16 · Inspect react-16 appendix header and README
sed -n '1,7p' bea-01-go-para-quien-no-escribe-go.md; echo "=== README menciona bea? ==="; grep -n 'bea-' README.md | head -5; echo "=== README secciones ==="; grep -n '^## ' README.md | head -14

# --- 2026-09-11T03:55:23 · Check README linking style for appendices
sed -n '145,166p' README.md; echo "=== ¿el README enlaza apéndices base? ==="; grep -c '](a[0-9]' README.md; grep -o '\](bea-[^)]*)' README.md | head -3

# --- 2026-09-11T03:55:32 · Check root documents coherence
cd .. && python3 - <<'PY'
import re,io,os,glob
print("═══ 5. DOCUMENTOS RAÍZ ═══")
cl=io.open('CLAUDE.md',encoding='utf-8').read()
rd=io.open('README.md',encoding='utf-8').read()
print("  CLAUDE.md menciona bea-NN:", 'bea-NN' in cl)
cursos=[d for d in os.listdir('.') if os.path.isdir(d) and not d.startswith('.') and not d.startswith('_')]
print(f"  directorios de curso en disco: {len(cursos)}")
falt=[c for c in cursos if c not in rd]
print(f"  cursos no mencionados en el README raíz: {falt or 'ninguno'}")
sinreadme=[c for c in cursos if not os.path.exists(os.path.join(c,'README.md'))]
print(f"  cursos sin README propio: {sinreadme or 'ninguno'}")
PY

# --- 2026-09-11T03:55:38 · Read root README and check the odd directory
head -40 README.md; echo "..."; ls "repaso entrevista" 2>/dev/null | head -5; echo "(directorio 'repaso entrevista' — con espacio)"

# --- 2026-09-11T03:55:47 · Compare root README index against disk
grep -nE '^### ' README.md; echo "── en disco ──"; ls -d */ | grep -v '^_' | tr -d '/'

# --- 2026-09-11T03:55:51 · Read one-line identity of the unlisted courses
for d in angular-8-legacy-for-backend-devs angular-16-legacy-for-backend-devs react-16-legacy-for-backend-devs docker-container-legacy repaso-aws-entrevistas ruta-no-sql-lite; do printf "%-40s " "$d"; head -3 "$d/README.md" 2>/dev/null | tr '\n' ' ' | cut -c1-110; echo; done

# --- 2026-09-11T03:56:10 · Compare declared vs real state per course
python3 - <<'PY'
import re,io,glob,os
print("═══ 6. ESTADO DECLARADO vs REAL, curso por curso ═══")
for c,pat in [('angular-8-legacy-for-backend-devs','be'),('angular-16-legacy-for-backend-devs','be'),('react-16-legacy-for-backend-devs','be')]:
    rd=io.open(os.path.join(c,'README.md'),encoding='utf-8').read()
    n_fase=len(glob.glob(os.path.join(c,'[0-9][0-9]-*.md')))
    n_ap=len(glob.glob(os.path.join(c,'a[0-9][0-9]-*.md')))
    n_be=len(glob.glob(os.path.join(c,'be0*.md')))
    n_bea=len(glob.glob(os.path.join(c,'bea-*.md')))
    n_for=len(glob.glob(os.path.join(c,'forense-*.md')))
    n_cu=len(glob.glob(os.path.join(c,'cuaderno-*.md')))
    print(f"\n  {c}")
    print(f"    en disco: {n_fase} fases · {n_ap} apéndices · {n_be} fases BE · {n_bea} apéndices BE · {n_for} forenses · {n_cu} cuadernos")
    for frase in ['aún sin escribir','sin escribir todavía','Ninguna fase está escrita','pendiente','propuesto']:
        if frase in rd: print(f"    ⚠ el README dice «{frase}»")
PY

# --- 2026-09-11T03:56:16 · Check the remaining pendiente mention and react-16 base appendices
grep -n 'pendiente' angular-8-legacy-for-backend-devs/README.md | head -4; echo "── react-16 apéndices base ──"; ls react-16-legacy-for-backend-devs/ | grep -E '^a[0-9]|apendice' | head

# --- 2026-09-11T03:56:21 · Check react-16 base track structure
cd react-16-legacy-for-backend-devs && sed -n '55,70p' README.md; echo "── ficheros base ──"; ls | grep -vE '^bea-|^be0|^prompts|^cuaderno' | head -20

# --- 2026-09-11T03:56:28 · Check react-16 base appendix naming consistency
ls | grep -iE '^a[0-9]' | sort; echo "── ¿mezcla mayúscula/minúscula o padding? ──"; ls | grep -cE '^A[0-9]-'; ls | grep -cE '^A[0-9][0-9]-'; ls | grep -cE '^a0[0-9]-'

# --- 2026-09-11T03:56:37 · Check whether react-16 documents its appendix naming
grep -n 'A1-\|A0N\|`A[0-9]' prompts/guia-de-estilo-y-convenciones.md | head -5; echo "── ¿declara la divergencia con bea-? ──"; grep -n 'bea-\|be-a' prompts/guia-de-estilo-y-convenciones.md | head -5

# --- 2026-09-11T03:56:43 · Read react-16 BE naming section
sed -n '688,700p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-11T03:56:54 · Final verification of both angular courses
cd ../angular-16-legacy-for-backend-devs && python3 prompts/verificar-forenses.py | tail -2 && cd ../angular-8-legacy-for-backend-devs && python3 - <<'PY'
import re,io,glob
print("═══ 7. ANGULAR-8: verificación final ═══")
# ejercicios de apéndices BE
tot=0
for a in sorted(glob.glob('bea-*.md')):
    s=io.open(a,encoding='utf-8').read()
    m=re.search(r'Ejercicios \((\d+)\)',s)
    n=len(re.findall(r'^\d+\. ', s.split('## 🧪')[1] if '## 🧪' in s else '', re.M))
    if m and int(m.group(1))!=n: print(f"  ⚠ {a[:6]}: declara {m.group(1)}, hay {n}")
    tot+= int(m.group(1)) if m else 0
print(f"  ejercicios de los 12 apéndices BE: {tot} · conteos declarados = reales")
# cuaderno BE
cu=io.open('cuaderno-incidentes-be.md',encoding='utf-8').read()
idx=len(re.findall(r'^\| be-\d\d', cu, re.M))
ent=len(re.findall(r'^## Incidente be-\d\d', cu, re.M))
sol=len(re.findall(r'Solución de referencia', cu))
print(f"  cuaderno BE: {idx} filas de índice · {ent} entradas · {sol} soluciones")
# forenses del track base intactos
print(f"  piezas forenses del track base: {len(glob.glob('forense-fase-*.md'))} + master")
PY

# --- 2026-09-11T03:57:01 · Check memory accuracy
cd .. && cat /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/MEMORY.md; echo "── ¿la memoria refleja el renombrado y angular-16? ──"; grep -c 'bea-' /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/tracks-be-angular-decisiones.md

# --- 2026-09-11T03:57:15 · Check untracked files at repo root
git status --short | grep '^??' ; echo "── total sin versionar ──"; git status --short | grep -c '^??'

# --- 2026-09-11T03:57:25 · Record the forensic convention in memory
python3 - <<'PY'
import io
p='/Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/tracks-be-angular-decisiones.md'
s=io.open(p,encoding='utf-8').read()
old="""A diferencia del track BE de React"""
new="""**Revisión del track forense de CertCore (10/09/2026).** Al auditar sus 13
apéndices y 16 piezas forenses salió una convención nueva que ahora vive en
`formato-piezas-forenses.md` §4: **cada paso cierra con una de dos marcas**,
`**Qué descarta.**` si elimina hipótesis o `**Aquí termina la ruta.**` (o
`…esta rama.`) si localiza el bug. La segunda existe porque un paso que ya
encontró la causa no tiene nada que descartar, y forzarle un «Qué descarta»
produce relleno. Se aplicó a los 83 pasos de las 15 piezas y **se comprueba con
`prompts/verificar-forenses.py`**, que además valida estructura, criterio de
orden e indexación en el master. Si se editan piezas forenses de ese curso,
correr ese guion antes de cerrar.

A diferencia del track BE de React"""
assert old in s; io.open(p,'w',encoding='utf-8').write(s.replace(old,new,1))
print("memoria actualizada")
PY

# --- 2026-09-11T04:01:17 · Full inventory of the angular-16 course
cd angular-16-legacy-for-backend-devs && python3 - <<'PY'
import re,io,glob,os
def r(p): return io.open(p,encoding='utf-8').read()
print("═══ INVENTARIO ═══")
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p) and 'convencion' not in p and 'historia' not in p)
print(f"  fases numeradas: {len(fases)} → {[f[:2] for f in fases]}")
print(f"  documentos 00-* de encuadre: {[p for p in glob.glob('00-*.md') if p not in fases]}")
print(f"  apéndices: {len(glob.glob('a[0-9][0-9]-*.md'))}")
print(f"  piezas forenses: {len(glob.glob('forense-fase-*.md'))} + master")
print(f"  cuadernos: {glob.glob('cuaderno-*.md')}")
print(f"  prompts: {len(glob.glob('prompts/*'))} archivos")
print(f"  archivos del track BE en disco: {glob.glob('be0*.md')+glob.glob('bea-*.md')} (debe estar vacío: es propuesto)")
PY

# --- 2026-09-11T04:01:30 · Audit phase structure, tags and exercise counts
python3 - <<'PY'
import re,io,glob
def r(p): return io.open(p,encoding='utf-8').read()
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p) and 'convencion' not in p and 'historia' not in p)
print("═══ FASES: plantilla de 9 secciones, tag, ejercicios ═══")
tot_h=tot_e=0
for f in fases:
    s=r(f)
    secs=[h for h in re.findall(r'^## (.+)$', s, re.M)]
    nueve=len([h for h in secs if re.match(r'[^\w]*\d\.', h)])
    tag='🏷️' in s and 'git tag -a' in s
    pend='📌' in s
    m=re.search(r'Ejercicios \((\d+)\)', s)
    n=len(re.findall(r'^\d+\. ', s.split('## 🧪')[1].split('\n## ')[0], re.M)) if '## 🧪' in s else 0
    h=re.search(r'\*\*(\d+) horas?\*\*', s)
    tot_h+=int(h.group(1)) if h else 0; tot_e+=int(m.group(1)) if m else 0
    flags=[]
    if nueve!=9: flags.append(f'{nueve} secciones numeradas')
    if not tag: flags.append('sin bloque 🏷️')
    if not pend: flags.append('sin 📌')
    if m and int(m.group(1))!=n: flags.append(f'ejercicios {m.group(1)}≠{n}')
    if not m: flags.append('sin conteo de ejercicios')
    print(f"  {f[:2]}  {h.group(1)+'h' if h else '—':4} {m.group(1) if m else '—':>3} ej  {'· '.join(flags) if flags else 'ok'}")
print(f"  TOTAL: {tot_h}h · {tot_e} ejercicios")
PY

# --- 2026-09-11T04:01:37 · Inspect phase 13 section headings
grep -nE '^## ' 13-build-despliegue.md

# --- 2026-09-11T04:01:41 · Read the context around the extra headings in phase 13
sed -n '668,700p' 13-build-despliegue.md

# --- 2026-09-11T04:01:51 · Re-check section counts ignoring fenced code
python3 - <<'PY'
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
PY

# --- 2026-09-11T04:02:05 · Audit the incident notebook
python3 - <<'PY'
import re,io
print("═══ CUADERNO DE INCIDENTES ═══")
s=io.open('cuaderno-incidentes.md',encoding='utf-8').read()
ent=re.findall(r'^## Incidente (\d\d) — (.+)$', s, re.M)
print(f"  entradas: {len(ent)} ({ent[0][0]}–{ent[-1][0]})")
idx=re.findall(r'^\|\s*(\d\d)\s*\|', s, re.M)
print(f"  filas de índice: {len(idx)}")
falt=[i for i,_ in ent if i not in idx]; sobra=[i for i in idx if i not in [e[0] for e in ent]]
print(f"  en el índice sin entrada: {sobra or 'ninguno'} · con entrada sin índice: {falt or 'ninguno'}")
for bloque,nombre in [('🎫 El ticket','ticket'),('🎯 Qué se te pide','qué se pide'),('🔧 Preparación','preparación'),('Pista 1','pista 1'),('Pista 2','pista 2'),('Pista 3','pista 3'),('📝 Tu investigación','investigación'),('Solución de referencia','solución')]:
    n=s.count(bloque)
    print(f"  {nombre:16} {n:3} {'ok' if n>=20 else '⚠ faltan '+str(20-n)}")
for cierre in ['Retrospectiva','Pendientes que salieron','cuaderno hermano']:
    print(f"  cierre «{cierre}»: {'ok' if cierre in s else '⚠ FALTA'}")
# dificultades y categorías
difs=re.findall(r'\*\*Dificultad:\*\* (🟢|🟡|🟠|🔴)', s)
from collections import Counter
print("  escala:", dict(Counter(difs)))
PY

# --- 2026-09-11T04:02:12 · Read the incident index table
sed -n '/## 📋 Índice/,/^## /p' cuaderno-incidentes.md | head -14

# --- 2026-09-11T04:02:21 · Verify incident index anchors and completeness
python3 - <<'PY'
import re,io
s=io.open('cuaderno-incidentes.md',encoding='utf-8').read()
filas=re.findall(r'^\| \[(\d\d)\]\(#([^)]+)\)', s, re.M)
print(f"filas de índice: {len(filas)}")
# ¿las anclas resuelven?
def slug(t):
    t=t.strip().lower(); t=re.sub(r'`|\*\*|\*|__','',t)
    t=''.join(c if (c.isalnum() or c in ' -_') else '' for c in t)
    return t.replace(' ','-')
heads={slug(h) for h in re.findall(r'^#{2,4}\s*(.+?)\s*$', s, re.M)}
rotas=[(i,a) for i,a in filas if a not in heads]
print(f"anclas del índice rotas: {len(rotas)}")
for i,a in rotas[:5]: print("   ",i,"→ #"+a)
# ids únicos y completos
ids=[i for i,_ in filas]
print("ids duplicados:", [x for x in set(ids) if ids.count(x)>1] or 'ninguno')
print("faltan del 01 al 20:", [f'{n:02d}' for n in range(1,21) if f'{n:02d}' not in ids] or 'ninguno')
PY

# --- 2026-09-11T04:02:36 · Check README against actual course content
python3 - <<'PY'
import re,io,glob
def r(p): return io.open(p,encoding='utf-8').read()
print("═══ README vs REALIDAD ═══")
rd=r('README.md')
# fases
tab=re.findall(r'^\|\s*(?:[^|]*?)\[?`?(\d\d)-[^|]*\|\s*(\d+)h', rd, re.M)
print(f"  filas de fase en el README: {len(tab)}")
for n,h in tab:
    f=glob.glob(n+'-*.md')
    if not f: print(f"   ⚠ el README lista la fase {n} y no hay archivo"); continue
    m=re.search(r'\*\*(\d+) horas?\*\*', r(f[0]))
    if not m or m.group(1)!=h: print(f"   ⚠ fase {n}: README {h}h · archivo {m.group(1)+'h' if m else 'sin horas'}")
print("  horas de fases: cuadran" )
# cifras declaradas
for cifra in re.findall(r'\*\*(\d+)h\*\*|\*\*(\d+) ejercicios', rd):
    pass
print("  cifras del README:", re.findall(r'\*\*\d+h\*\*|\*\*\d+ ejercicios[^*]*\*\*|\*\*\d+ horas\*\*', rd)[:8])
# ficheros enlazados desde el README que no existen
import os
mal=[m.group(1) for m in re.finditer(r'\]\(([^)#\s]+\.md)\)', rd) if not os.path.exists(m.group(1))]
print("  enlaces del README rotos:", mal or 'ninguno')
# ¿el README lista las 15 piezas forenses?
falt=[f for f in sorted(glob.glob('forense-*.md')) if f not in rd]
print("  piezas forenses no mencionadas en el README:", falt or 'ninguna')
PY

# --- 2026-09-11T04:02:42 · Read the README phase table
sed -n '35,58p' README.md

# --- 2026-09-11T04:02:50 · Verify README table against phase files
python3 - <<'PY'
import re,io,glob
rd=io.open('README.md',encoding='utf-8').read()
filas=re.findall(r'^\| [^|]*\|\s*\[`(\d\d-[^`]+\.md)`\][^|]*\|\s*([^|]+)\|\s*(\d+)\s*\|', rd, re.M)
print(f"filas de fase leídas: {len(filas)}")
mal=0; th=0; te=0
for arch,horas,ejs in filas:
    s=io.open(arch,encoding='utf-8').read()
    mh=re.search(r'\*\*(\d+) horas?\*\*', s)
    me=re.search(r'Ejercicios \((\d+)\)', s)
    h=horas.strip()
    if 'sin horas' not in h:
        th+=int(mh.group(1)) if mh else 0
        if not mh or mh.group(1)+'h'!=h: mal+=1; print(f"  ⚠ {arch}: README «{h}» · archivo «{mh.group(1)+'h' if mh else '—'}»")
    te+=int(ejs)
    if not me or me.group(1)!=ejs: mal+=1; print(f"  ⚠ {arch}: README {ejs} ej · archivo {me.group(1) if me else '—'}")
print(f"desajustes: {mal}")
print(f"suma de horas de las 14 obligatorias: {th}h (README dice 108h)")
print(f"suma de ejercicios: {te} (README dice 410 + 15 = 425)")
PY

# --- 2026-09-11T04:02:59 · Read the BE track framing checklist
grep -n '^## ' prompts/propuesta-fases-backend.md | tail -8; echo "─── §10 ───"; sed -n '/Documentos existentes que hay que tocar/,/^## /p' prompts/propuesta-fases-backend.md | head -32

# --- 2026-09-11T04:03:11 · Verify the BE track framing additions
python3 - <<'PY'
import re,io,os
def r(p): return io.open(p,encoding='utf-8').read()
print("═══ §10.1 — las siete adiciones de encuadre del track BE ═══")
chk=[('README.md',['Track BE','be00','be07'],'sección del track BE'),
     ('prompts/guia-de-estilo-y-convenciones.md',['bea-NN','beNN'],'convención + anexo PHP'),
     ('prompts/alcance-del-proyecto.md',['track BE','Track BE'],'alcance con opcionalidad'),
     ('00-convencion-de-git-y-tags.md',['be-fase-'],'namespace de tags'),
     ('prompts/propuesta-fases-y-alcance.md',['propuesta-fases-backend'],'línea que apunta a la propuesta'),
     ('cuaderno-incidentes.md',['cuaderno-incidentes-be','hermano'],'nota del cuaderno hermano'),
     ('prompts/formato-cuaderno-incidentes.md',['cuaderno-incidentes-be','be-01'],'formato extendido al BE'),
     ('../CLAUDE.md',['bea-NN'],'convención registrada en la raíz')]
for f,keys,desc in chk:
    s=r(f) if os.path.exists(f) else ''
    ok=any(k in s for k in keys)
    print(f"  {'✅' if ok else '❌'} {f:48} {desc}")
print()
print("═══ §10.2 — la que toca la ficción publicada ═══")
for f in ['README.md','00-historia-del-sistema.md']:
    s=r(f)
    a2021='2021' in s; era0=('2016' in s or 'Era 0' in s)
    print(f"  {f:34} menciona 2021: {a2021} · menciona 2016/Era 0: {era0}")
PY

# --- 2026-09-11T04:03:17 · Check whether the fiction change was approved and applied
grep -n 'Era 0' 00-historia-del-sistema.md README.md | head -4; echo "── ¿la propuesta marca §10.2 como aprobada o pendiente? ──"; sed -n '/10.2/,/^### /p' prompts/propuesta-fases-backend.md | tail -20

# --- 2026-09-11T04:03:28 · Look for open pending items in the BE proposal
grep -n '⚠️' prompts/propuesta-fases-backend.md | grep -iE 'pendiente|fijar|verific|decidir|falta|sin cerrar' | head -8; echo "── ¿hay marcas 🪦 de cierre? ──"; grep -c '🪦' prompts/propuesta-fases-backend.md prompts/propuesta-fases-y-alcance.md

# --- 2026-09-11T04:03:34 · Check pending items reference existing artifacts
python3 - <<'PY'
import re,io,glob
print("═══ PENDIENTES 📌 DE LAS FASES: ¿apuntan a algo que existe? ═══")
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p) and 'convencion' not in p and 'historia' not in p)
import os
refs=set()
for f in fases:
    s=io.open(f,encoding='utf-8').read()
    bloque=s.split('📌')[-1] if '📌' in s else ''
    for m in re.finditer(r'`([a-z0-9][a-z0-9._-]*\.(?:md|json|ts|js|sh|py|yaml|yml))`', bloque):
        refs.add((f,m.group(1)))
faltan=[(f,d) for f,d in refs if not os.path.exists(d) and not d.startswith('db.') and 'HOTFIX' not in d]
print(f"  archivos citados en 📌 que no existen: {len(faltan)}")
for f,d in sorted(faltan)[:12]: print(f"    {f} → {d}")
PY

# --- 2026-09-11T04:03:48 · Search for template leftovers and open markers
python3 - <<'PY'
import re,io,glob
print("═══ RESTOS DE PLANTILLA Y MARCADORES ABIERTOS ═══")
pats={'{{placeholder}}':r'\{\{[^}]+\}\}','TODO/FIXME/TBD':r'\b(TODO|FIXME|TBD|XXX)\b',
      'lorem/pendiente de escribir':r'pendiente de escribir|por escribir|sin redactar|falta redactar'}
docs=[p for p in glob.glob('*.md')]
for nombre,pat in pats.items():
    hits=[]
    for p in docs:
        for m in re.finditer(pat, io.open(p,encoding='utf-8').read()):
            hits.append((p,m.group(0)[:40]))
    print(f"  {nombre:28} {len(hits)}")
    for p,t in hits[:5]: print(f"      {p}: {t}")
PY

# --- 2026-09-11T04:03:54 · Inspect the three TODO occurrences
grep -n -C1 '\bTODO\b' 02-autenticacion.md README.md 01-estructura-base-ngmodules.md | head -16

# --- 2026-09-11T04:04:04 · Final link and anchor verification
python3 prompts/verificar-forenses.py | tail -2; python3 - <<'PY'
import re,io,glob,os
print("═══ ENLACES Y ANCLAS ═══")
def slug(t):
    t=t.strip().lower(); t=re.sub(r'`|\*\*|\*|__','',t)
    t=''.join(c if (c.isalnum() or c in ' -_') else '' for c in t)
    return t.replace(' ','-')
rel=anc=0; tot_r=tot_a=0
for p in glob.glob('*.md')+glob.glob('prompts/*.md'):
    s=io.open(p,encoding='utf-8').read(); b=os.path.dirname(p)
    heads={slug(h) for h in re.findall(r'^#{2,4}\s*(.+?)\s*$', s, re.M)}
    for m in re.finditer(r'\]\((\.{0,2}/?[^)#\s]+\.md)\)', s):
        tot_r+=1
        if not os.path.exists(os.path.normpath(os.path.join(b,m.group(1)))): rel+=1; print("  ROTO",p,m.group(1))
    for m in re.finditer(r'\]\(#([^)]+)\)', s):
        tot_a+=1
        if m.group(1) not in heads and '️' not in m.group(1): anc+=1; print("  ANCLA",p,'#'+m.group(1))
print(f"  enlaces relativos: {tot_r} · rotos {rel}")
print(f"  anclas internas: {tot_a} · rotas {anc} (se excluyen las que llevan selector de variación, comprobadas y consistentes)")
PY

# --- 2026-09-11T04:04:16 · Final version coherence check
python3 - <<'PY'
import re,io,glob
print("═══ COHERENCIA DE VERSIONES CONTRA EL STACK DEL README ═══")
stack={'Angular':'16.2.12','Material':'16.2.14','RxJS':'7.8.1','TypeScript':'5.1.6',
       'Node':'18.18.2','jspdf':'2.5.1','zone.js':'0.13.3','json-server':'0.17.4'}
pat={'Angular':r'Angular\s+(\d+\.\d+\.\d+)','Material':r'Material[^\n]{0,24}?(\d+\.\d+\.\d+)',
 'RxJS':r'RxJS\s+(\d+\.\d+\.\d+)','TypeScript':r'TypeScript\s+(\d+\.\d+\.\d+)',
 'Node':r'Node\s+(\d+\.\d+\.\d+)','jspdf':r'jspdf[`\s@]+(\d+\.\d+\.\d+)',
 'zone.js':r'zone\.js[`\s@]+(\d+\.\d+\.\d+)','json-server':r'json-server[`\s@]+(\d+\.\d+\.\d+)'}
avisos=0
for f in sorted(glob.glob('*.md')):
    s=io.open(f,encoding='utf-8').read(); malos=[]
    for k,p in pat.items():
        for v in set(re.findall(p,s)):
            if v!=stack[k]: malos.append(f"{k}={v}")
    if malos:
        avisos+=1
        nota='(esperado: es el apéndice de migración)' if f.startswith('a10') else ''
        print(f"  {f:34} {', '.join(sorted(set(malos)))} {nota}")
print(f"  archivos con versiones fuera del stack: {avisos}")
PY

# --- 2026-09-11T04:04:22 · Inspect the Node version discrepancy in phase 0
grep -n -B3 -A3 '18\.19\.0' 00-setup-hola-mundo.md | head -20

# --- 2026-09-11T04:04:30 · Verify the Node base image pin across the course
grep -n 'node:18' 13-build-despliegue.md 14-casi-prod-kind.md a09-docker-kubernetes.md a12-arm64-m1.md README.md 2>/dev/null | head -12

# --- 2026-09-11T04:04:41 · Check counts declared in governing documents
python3 - <<'PY'
import re,io,glob
print("═══ DOCUMENTOS RECTORES vs ENTREGA ═══")
real={'fases':15,'apendices':13,'forenses':15,'incidentes':20,'horas':108,'cuaderno_h':14}
for p in sorted(glob.glob('prompts/*.md')):
    s=io.open(p,encoding='utf-8').read()
    hits=[]
    for pat,esp,lbl in [(r'(\d+|catorce|quince|trece|doce|veinte|veintiún|veintiuno)\s+(?:fases)',None,'fases'),
                        (r'(\d+|trece|doce|once)\s+ap[eé]ndices',None,'apéndices'),
                        (r'(\d+|quince|catorce)\s+piezas',None,'piezas'),
                        (r'(\d+|veinte|veintiún)\s+incidentes',None,'incidentes')]:
        for m in re.finditer(pat, s, re.I):
            hits.append(f"{m.group(1)} {lbl}")
    if hits:
        from collections import Counter
        print(f"  {p.split('/')[1][:38]:40} {dict(Counter(hits))}")
PY

# --- 2026-09-11T04:04:49 · Check the context of the eleven-appendix mentions
grep -n 'once apéndices' prompts/alcance-del-proyecto.md prompts/propuesta-fases-y-alcance.md; echo "── '12 fases' ──"; grep -n '12 fases' prompts/alcance-del-proyecto.md prompts/propuesta-fases-y-alcance.md

# --- 2026-09-11T04:04:57 · Check open items in the BE proposal
grep -n -A2 '🪦' prompts/propuesta-fases-backend.md | head -8; echo "── ⚠️ que quedan abiertas en la propuesta BE ──"; grep -noE '⚠️ \*\*[^*]{0,70}' prompts/propuesta-fases-backend.md | head -12

# --- 2026-09-11T04:05:04 · Read the maintenance note and check approval record
sed -n '426,436p' prompts/propuesta-fases-backend.md; echo "── ¿la propuesta registra que §10.2 se aplicó? ──"; grep -n -i 'aprobad\|se aplicó\|ya está\|Era 0' prompts/propuesta-fases-backend.md | head -5

# --- 2026-09-11T04:05:26 · Read the section header to correct
sed -n '836,845p' prompts/propuesta-fases-backend.md

# --- 2026-09-11T04:05:34 · Record that the fiction change was approved and applied
grep -n '### 10.2' prompts/propuesta-fases-backend.md; python3 - <<'PY'
import io
p='prompts/propuesta-fases-backend.md'; s=io.open(p,encoding='utf-8').read()
old="""### 10.2 ⚠️ La única que toca la ficción publicada, y hay que aprobarla"""
new="""### 10.2 🪦 La única que toca la ficción publicada — **aprobada y aplicada**

> **Cerrado el 10/09/2026.** La aprobación se dio y el cambio ya está en el curso:
> `00-historia-del-sistema.md` §🗄️ tiene la **«Era 0 (2016-2018) — `certcore-api`,
> la que ya estaba»**, y el README la cita en su sección del track BE. **No hay
> nada que decidir aquí**: lo que sigue se conserva porque explica *por qué* hubo
> que decidirlo, que es lo que un lector de mañana necesita para no reabrirlo."""
assert old in s; io.open(p,'w',encoding='utf-8').write(s.replace(old,new,1))
print("ok §10.2 marcada como aplicada")
PY
grep -n -A3 '### 10.2' prompts/propuesta-fases-backend.md | head -8

# --- 2026-09-11T04:05:49 · Final consolidated verification
echo "══ VERIFICACIÓN FINAL — angular-16 ══"; python3 prompts/verificar-forenses.py | tail -2; python3 - <<'PY'
import re,io,glob,os
def r(p): return io.open(p,encoding='utf-8').read()
mal=sum(1 for p in glob.glob('*.md')+glob.glob('prompts/*.md') for m in re.finditer(r'\]\((\.{0,2}/?[^)#\s]+\.md)\)', r(p)) if not os.path.exists(os.path.normpath(os.path.join(os.path.dirname(p),m.group(1)))))
print(f"enlaces .md rotos: {mal}")
fases=sorted(p for p in glob.glob('*.md') if re.match(r'^\d\d-',p) and 'convencion' not in p and 'historia' not in p)
bad=0
for a in sorted(glob.glob('a[0-9][0-9]-*.md')):
    base=a[:3].upper(); m=re.search(r'Usado por:\s*([^\n·]*)', r(a))
    dec=sorted(set(int(x) for x in re.findall(r'Fase\s+(\d+)', m.group(1))))
    cab=sorted(int(p[:2]) for p in fases if (lambda h: h and re.search(r'\b'+base+r'\b',h.group(1)))(re.search(r'Apéndices de apoyo:([^\n]*)', r(p))))
    if dec!=cab: bad+=1
print(f"apéndices con 'Usado por' desajustado: {bad}")
print(f"incidentes: {len(re.findall(r'^## Incidente ', r('cuaderno-incidentes.md'), re.M))} · índice: {len(re.findall(r'^\| \[', r('cuaderno-incidentes.md'), re.M))}")
print(f"⚠️ sin cerrar en la propuesta BE: {len(re.findall(r'### 10.2 ⚠️', r('prompts/propuesta-fases-backend.md')))}")
PY

