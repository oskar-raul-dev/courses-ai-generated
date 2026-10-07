# Comandos Bash de la sesión 51943195-594f-48db-896d-65f9d0a7faaf, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-10T00:36:02 · List course tree and read README
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs && ls -R . | head -80 && echo "=== README ===" && cat README.md

# --- 2026-09-10T00:36:06 · Inspect prompts dir and forensic doc
ls prompts/ && wc -l prompts/*.md contenido_forense.md 01-vue2-legacy/README.md 02-complement-mongodb-backend/README.md && echo "=== FORENSE ===" && cat contenido_forense.md

# --- 2026-09-10T00:36:11 · Read forensic plan first part
sed -n '1,400p' /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/51943195-594f-48db-896d-65f9d0a7faaf/tool-results/bcrrq1qgb.txt

# --- 2026-09-10T00:36:17 · Read forensic plan middle
sed -n '400,700p' /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/51943195-594f-48db-896d-65f9d0a7faaf/tool-results/bcrrq1qgb.txt

# --- 2026-09-10T00:36:21 · Read forensic plan end
sed -n '700,1100p' /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/51943195-594f-48db-896d-65f9d0a7faaf/tool-results/bcrrq1qgb.txt

# --- 2026-09-10T00:36:27 · Check working tree state of the vue2 package
cd /Users/oskar/Developer/Learning/courses-ia-generated && git status --short -- vue2-legacy-for-backend-devs/ && echo "--- diffstat ---" && git diff --stat -- vue2-legacy-for-backend-devs/ && echo "--- grep pieza forense en fases ---" && grep -rl "Errores comunes y pieza forense" vue2-legacy-for-backend-devs/ | sort

# --- 2026-09-10T00:36:34 · Inspect forensic master docs
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs && wc -l */forense-master.md prompts/formato-*.md && echo "=== C01 master headings ===" && grep -n '^#\{1,3\} ' 01-vue2-legacy/forense-master.md && echo "=== C02 master headings ===" && grep -n '^#\{1,3\} ' 02-complement-mongodb-backend/forense-master.md

# --- 2026-09-10T00:36:39 · Check chaos injector and piece index
grep -c "CHAOS" 01-vue2-legacy/03-mock-api-minima.md; echo "---indice piezas C01---"; sed -n '48,80p' 01-vue2-legacy/forense-master.md

# --- 2026-09-10T00:38:11 · Read P0 diff on git convention
git diff -- prompts/convencion-de-git-y-tags.md | head -260

# --- 2026-09-10T00:38:24 · Verify factual claims in git convention
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
echo "--- ej14 fase3 seed ---"; grep -n "db.seed.json\|mock:reset" 01-vue2-legacy/03-mock-api-minima.md | head -20
echo "--- MONGO_VERSION ---"; grep -rn "MONGO_VERSION" 02-complement-mongodb-backend/*.md | head -5
echo "--- npm run seed C02 ---"; grep -rn "npm run seed" 02-complement-mongodb-backend/*.md | head -5
echo "--- cliente mentiroso F8 ---"; grep -n "mentiroso\|💸" 01-vue2-legacy/08-websockets-minimos.md | head -10
echo "--- login sincrono F2/F3 store ---"; grep -n "💸" 01-vue2-legacy/02-autenticacion-minima.md | head -10
echo "--- SECURITY-NOTES ej7 ---"; grep -n "SECURITY-NOTES" 02-complement-mongodb-backend/11-auth-real-y-pago-de-deudas.md | head -5

# --- 2026-09-10T00:38:30 · Read P2 diffs
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
echo "=== GUIA DIFF ==="; git diff -- prompts/guia-de-estilo-y-convenciones.md
echo "=== PLANTILLA DIFF ==="; git diff -- prompts/plantilla-de-fase.md

# --- 2026-09-10T00:38:36 · Read forensic pieces format spec
cat prompts/formato-piezas-forenses.md

# --- 2026-09-10T00:38:42 · Read course 01 forensic master
cat 01-vue2-legacy/forense-master.md

# --- 2026-09-10T00:39:01 · Count symptom rows and read C02 master head
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
echo "=== filas tabla sintomas C01 ==="; awk '/^## 3\./,/^## 4\./' 01-vue2-legacy/forense-master.md | grep -c '^| '
echo "=== fases citadas en la tabla C01 ==="; awk '/^## 3\./,/^## 4\./' 01-vue2-legacy/forense-master.md | grep -o 'Fase [0-9]*' | sort -u -V
echo; cat 02-complement-mongodb-backend/forense-master.md | sed -n '1,60p'

# --- 2026-09-10T00:39:10 · Read rest of C02 master
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
sed -n '60,171p' 02-complement-mongodb-backend/forense-master.md

# --- 2026-09-10T00:39:25 · Outline of cuaderno format spec
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
grep -n '^#\{1,3\} \|^| ' prompts/formato-cuaderno-incidentes.md | head -80

# --- 2026-09-10T00:39:30 · Read quotas, categories, preparation forms
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
sed -n '100,175p' prompts/formato-cuaderno-incidentes.md; echo "..."; sed -n '180,262p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-10T00:39:42 · Inspect errores comunes of phases 1,2,4,7
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
for f in 01-estructura-base-legacy.md 02-autenticacion-minima.md 04-dashboard-tickets.md 07-metricas-minimas.md; do echo "=========== $f"; awk '/^## ⚠️/,/^## 🧪|^## 🚀|^## 📚/' $f | grep -n '^\*\*\|^### \|^| ' | head -25; done

# --- 2026-09-10T00:39:48 · List section 6 headings across course 01 phases
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
for f in 0[0-9]*.md 1[01]*.md q[0-4]*.md vu[0-4]*.md nx[0-4]*.md; do printf "%-34s %s\n" "$f" "$(grep -n '^## .*\(Errores comunes\|Consideraciones de seguridad\|forense\)' $f | tr '\n' ' | ')"; done

# --- 2026-09-10T00:39:56 · Find section 6 in q1,q3,nx1
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
grep -n '^## ' q1-leer-quasar.md q3-migrar-dashboard-qtable.md nx1-leer-nuxt.md | grep -i 'error\|forense\|trampa\|6\.'

# --- 2026-09-10T00:40:04 · Extract common errors of phases 1,2,4,7
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
echo "### F01"; sed -n '405,470p' 01-estructura-base-legacy.md | grep -E '^\*\*|^\| |^[0-9]+\.' | head -20
echo "### F02"; sed -n '511,580p' 02-autenticacion-minima.md | grep -E '^\*\*|^\| |^[0-9]+\.' | head -20
echo "### F04"; sed -n '710,780p' 04-dashboard-tickets.md | grep -E '^\*\*|^\| |^[0-9]+\.' | head -20
echo "### F07"; sed -n '715,790p' 07-metricas-minimas.md | grep -E '^\*\*|^\| |^[0-9]+\.' | head -20

# --- 2026-09-10T00:40:09 · Read errores comunes F01 and F02
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
echo "### F01 405+"; sed -n '405,440p' 01-estructura-base-legacy.md
echo "### F02 511+"; sed -n '511,545p' 02-autenticacion-minima.md

# --- 2026-09-10T00:40:23 · Spot-check symptom sourcing in course 01
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
echo "--F0 EADDRINUSE/version mismatch--"; grep -n "EADDRINUSE\|version mismatch\|Volar\|Vetur" 00-setup-hola-mundo.md | head
echo "--F5 error/invalid--"; grep -n '\$error\|\$invalid\|\$touch' 05-crud-tickets.md | head -5
echo "--F7 canvas--"; grep -n "Canvas is already in use\|destroy()" 07-metricas-minimas.md | head -4
echo "--F10 strict prod--"; grep -n "strict" 10-vuex-a-fondo.md | head -8
echo "--strict en rutas Q--"; grep -rn "strict" q*.md | head -5
echo "--X-Total-Count--"; grep -rln "X-Total-Count" *.md

# --- 2026-09-10T00:40:40 · Spot-check symptom sourcing in course 02
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
echo "--F4 NumberInt--"; grep -n "NumberInt\|double" 04-el-esquema-que-no-esta-en-la-base.md | head -4
echo "--F5 unwind preserve--"; grep -n "preserveNullAndEmptyArrays" 05-lookup-y-por-que-es-una-alarma.md | head -3
echo "--F6 matchedCount--"; grep -n "matchedCount" 06-atomicidad-transacciones-consistencia.md | head -3
echo "--F10 envelope/curl--"; grep -n "envelope\|_id" 10-express-el-vehiculo.md | head -5
echo "--F13 binario CI--"; grep -n "CI" 13-testing-de-api.md | head -4
echo "--F12 rele--"; grep -n "relé\|rele tonto\|Curso 01" 12-el-backend-habla.md | head -5
echo "--fecha zona horaria--"; grep -rn "zona horaria\|timezone\|un día menos" *.md | head -5

# --- 2026-09-10T00:40:47 · Read cuaderno format head
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
sed -n '1,95p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-10T00:40:55 · Check HTML exception and checklist
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
grep -n "HTML" prompts/guia-de-estilo-y-convenciones.md | head -6
echo "=== §9 excepcion details ==="; sed -n '274,300p' prompts/formato-cuaderno-incidentes.md
echo "=== §12 checklist ==="; sed -n '459,481p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-10T00:41:07 · Link, voseo and section 9 checks
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
echo "=== links rotos ==="
for f in prompts/convencion-de-git-y-tags.md prompts/guia-de-estilo-y-convenciones.md prompts/plantilla-de-fase.md prompts/formato-piezas-forenses.md prompts/formato-cuaderno-incidentes.md 01-vue2-legacy/forense-master.md 02-complement-mongodb-backend/forense-master.md; do
  d=$(dirname $f)
  grep -o '](\.\{0,2\}[^)]*\.md[^)]*)' $f | sed 's/](//;s/)$//;s/#.*//' | sort -u | while read p; do
    [ -e "$d/$p" ] || echo "ROTO: $f -> $p"
  done
done
echo "=== voseo ==="
grep -nE '\b(tenés|podés|querés|hacé|mirá|fijate|vos|sabés|ponés|andá)\b' prompts/formato-*.md */forense-master.md prompts/convencion-de-git-y-tags.md | head
echo "=== guia §9 encabezado ==="
sed -n '600,632p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-10T00:41:15 · Read guia 9.1
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
sed -n '633,676p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-10T00:41:36 · Check F7 errors and 404 symptom
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
echo "== F07 errores =="; sed -n '715,740p' 07-metricas-minimas.md
echo "== 404 comments =="; grep -rn "404" 03-mock-api-minima.md 09-panel-soporte.md | head -6

# --- 2026-09-10T00:41:57 · Count C02 symptom rows
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs && awk '/^## 3\./,/^## 4\./' 02-complement-mongodb-backend/forense-master.md | grep -c '^| '

# --- 2026-09-10T01:17:10 · Look for sourced symptoms in F1 and F2
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
echo "== F01 conceptos/router =="; grep -n "router-view\|router-link\|:key\|params\|watch" 01-estructura-base-legacy.md | head -20
echo "== F02 guard/localStorage/pestaña =="; grep -n "guard\|pestaña\|storage\|expira\|token" 02-autenticacion-minima.md | sed -n '1,25p'

# --- 2026-09-10T01:17:50 · F9 errors and other symptom sources
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
echo "== F09 errores =="; sed -n '988,1020p' 09-panel-soporte.md
echo "== this undefined / arrow =="; grep -rn "arrow\|función flecha\|this.*undefined" 0*.md 1*.md | head -8
echo "== comments endpoint =="; grep -rn "comments" 03-mock-api-minima.md | head -8

# --- 2026-09-10T01:17:57 · Read F3 errores comunes and F0 arrow note
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
sed -n '657,690p' 03-mock-api-minima.md; echo "== F0 564 =="; sed -n '558,570p' 00-setup-hola-mundo.md

# --- 2026-09-10T01:18:25 · Find all references to the reservas block name
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
grep -rn "Reservas para el cuaderno" prompts/*.md 0*/*.md

# --- 2026-09-10T01:18:37 · Apply fixes D and E
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
python3 - <<'PY'
import io
p='prompts/formato-cuaderno-incidentes.md'
s=open(p,encoding='utf-8').read()
s=s.replace("en su bloque `### Reservas para el cuaderno de incidentes`.",
            "en su bloque `### 📌 Reservas para el cuaderno de incidentes`.")
open(p,'w',encoding='utf-8').write(s)

p='prompts/guia-de-estilo-y-convenciones.md'
s=open(p,encoding='utf-8').read()
old="""Toda fase produce un `.md` con exactamente estas nueve secciones, en orden. El
esqueleto rellenable está en `plantilla-de-fase.md`."""
new="""Toda fase produce un `.md` con exactamente estas nueve secciones, en orden —
más el bloque de servicio 📌 que va después del cierre (§9.1). El esqueleto
rellenable está en `plantilla-de-fase.md`."""
assert old in s
s=s.replace(old,new)

old2="""Los apéndices **no** llevan este bloque, porque no producen código de fase.

Los apéndices **no** siguen esta plantilla:"""
new2="""Los apéndices **no** llevan este bloque, porque no producen código de fase.

Después de "Siguiente parada" —y solo después— va el bloque
`### 📌 Reservas para el cuaderno de incidentes`, con la tabla de los IDs que
esta fase aporta al `cuaderno-incidentes.md` de su curso. No contradice lo de
arriba: "Siguiente parada" sigue siendo lo último **de la fase**, y el 📌 no es
narrativa, es un bloque de servicio para quien escribe el cuaderno y para quien
audita que los IDs cuadren. Los apéndices tampoco lo llevan.

Los apéndices **no** siguen esta plantilla:"""
assert old2 in s
s=s.replace(old2,new2)
open(p,'w',encoding='utf-8').write(s)
print("ok D+E")
PY

# --- 2026-09-10T01:18:50 · Apply fix F
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
python3 - <<'PY'
p='prompts/convencion-de-git-y-tags.md'
s=open(p,encoding='utf-8').read()
old="""El compose final de la Fase 14 empaqueta el sistema entero, y el Dockerfile de
la API aparece ahí. Cuando llegues, **no dejes esa imagen en `:latest`**:
etiquétala con el mismo nombre del tag de git que la produjo."""
new="""El compose final de la
[Fase 14](../02-complement-mongodb-backend/14-operacion.md) empaqueta el sistema
entero, y el Dockerfile de la API aparece ahí. Cuando llegues, **no dejes esa
imagen en `:latest`**: etiquétala con el mismo nombre del tag de git que la
produjo."""
assert old in s
s=s.replace(old,new)

old2="""Es el mismo reflejo que ya practicaste sin darte cuenta al fijar
`MONGO_VERSION` en vez de aceptar `mongo:latest` — solo que ahora la imagen sin
versionar es la tuya."""
new2="""Es el mismo reflejo que ya practicaste sin darte cuenta al fijar
`MONGO_VERSION` en vez de aceptar `mongo:latest`
([A01](../02-complement-mongodb-backend/a01-docker.md)) — solo que ahora la
imagen sin versionar es la tuya."""
assert old2 in s
s=s.replace(old2,new2)
open(p,'w',encoding='utf-8').write(s)
print("ok F")
PY

# --- 2026-09-10T01:19:01 · Apply fixes G and C
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
python3 - <<'PY'
p='02-complement-mongodb-backend/forense-master.md'
s=open(p,encoding='utf-8').read()
old="| El mismo evento llega dos veces | Fase 12 — el relé tonto del Curso 01 sigue encendido junto al emisor nuevo |"
new="| El mismo evento llega dos veces | Fase 12 — quedaron dos emisores: el relé de sockets que el frontend traía y el `io.emit` nuevo del servidor |"
assert old in s
s=s.replace(old,new)
open(p,'w',encoding='utf-8').write(s)

p='prompts/formato-cuaderno-incidentes.md'
s=open(p,encoding='utf-8').read()
old="""- **Fases 0–3 · tres incidentes 🟢🟢🟡.** Setup y arranque, el endpoint mal escrito, el
  mock caído que parece un bug del frontend, la sesión que sobrevive a lo que no debería."""
new="""- **Fases 0–3 · tres incidentes 🟢🟢🟡.** El arranque que falla con un error que habla de
  otra cosa, el mock caído que parece un bug del frontend, y el token borrado a mano del
  que la aplicación se entera tarde."""
assert old in s
s=s.replace(old,new)

old2="""- **Fases 7–9 · tres incidentes 🟠.** La métrica que no cuadra con la tabla, el evento de
  socket que duplica filas, el doble "tomar" que ninguno de los dos agentes ve."""
new2="""- **Fases 7–9 · tres incidentes 🟠.** La pestaña que se va arrastrando hasta que el
  ventilador se dispara, el evento de socket que duplica filas, y el doble "tomar" que
  ninguno de los dos agentes ve."""
assert old2 in s
s=s.replace(old2,new2)
open(p,'w',encoding='utf-8').write(s)
print("ok G+C")
PY

# --- 2026-09-10T01:19:52 · Apply A and B to course 01 master
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
python3 - <<'PY'
p='01-vue2-legacy/forense-master.md'
s=open(p,encoding='utf-8').read()

# --- B: columna de herramienta en el índice de piezas
old_tronco = """| Fase | El síntoma que cubre | Archivo |
|---|---|---|
| 0 | "Instalé todo y no arranca", con errores que no hablan de lo que pasa | `forense-fase-00.md` |
| 1 | "La ruta cambia, la URL cambia, y la pantalla no" | `forense-fase-01.md` |
| 2 | "Me saca al login sin decir nada" | `forense-fase-02.md` |
| 3 | "A veces carga y a veces se queda pensando" | `forense-fase-03.md` |
| 4 | "Cambié el filtro y la tabla se quedó igual" ⭐ | `forense-fase-04.md` |
| 5 | "Le di a guardar y no pasó nada" | `forense-fase-05.md` |
| 6 | "Volví atrás en el wizard y perdí lo que había escrito" | `forense-fase-06.md` |
| 7 | "La pestaña se va poniendo lenta y el ventilador se dispara" | `forense-fase-07.md` |
| 8 | "Tomé el ticket y a mi compañero le sigue apareciendo libre" ⭐ | `forense-fase-08.md` |
| 9 | "Cambié el estado y el detalle no se enteró" | `forense-fase-09.md` |
| 10 | "El estado cambió y nadie sabe quién lo cambió" ⭐ | `forense-fase-10.md` |
| 11 | "El test pasa solo cuando lo corro aislado" | `forense-fase-11.md` |"""

new_tronco = """| Fase | El síntoma que cubre | Herramienta principal | Archivo |
|---|---|---|---|
| 0 | "Instalé todo y no arranca", con errores que no hablan de lo que pasa | La salida de `vue-cli-service` en la terminal | `forense-fase-00.md` |
| 1 | "Entré a un ticket que no existe y la pantalla no dice nada" | Vue DevTools → Components, junto a la URL | `forense-fase-01.md` |
| 2 | "Me saca al login sin decir nada" | DevTools → Application → `localStorage` | `forense-fase-02.md` |
| 3 | "A veces carga y a veces se queda pensando" | Network | `forense-fase-03.md` |
| 4 | "Cambié el filtro y la tabla se quedó igual" ⭐ | Vue DevTools → Components | `forense-fase-04.md` |
| 5 | "Le di a guardar y no pasó nada" | La consola, y después Network | `forense-fase-05.md` |
| 6 | "Volví atrás en el wizard y perdí lo que había escrito" | Vue DevTools → el árbol de componentes | `forense-fase-06.md` |
| 7 | "La pestaña se va poniendo lenta y el ventilador se dispara" | Performance y Memory de Chrome | `forense-fase-07.md` |
| 8 | "Tomé el ticket y a mi compañero le sigue apareciendo libre" ⭐ | Network → WS, con dos navegadores | `forense-fase-08.md` |
| 9 | "Cambié el estado y el detalle no se enteró" | Vue DevTools → Components, y Network | `forense-fase-09.md` |
| 10 | "El estado cambió y nadie sabe quién lo cambió" ⭐ | Vue DevTools → Vuex, registro de mutations | `forense-fase-10.md` |
| 11 | "El test pasa solo cuando lo corro aislado" | La salida de Jest, con y sin `--runInBand` | `forense-fase-11.md` |"""
assert old_tronco in s
s = s.replace(old_tronco, new_tronco)

old_rutas = """| Ruta | Lo que investiga | Archivo |
|---|---|---|
| 🅠 Quasar 1 | El componente que no renderiza y no avisa · la tabla que pagina dos veces | `forense-ruta-q.md` |
| 🅥 Vuetify 2 | El `v-app` ausente que rompe en silencio · el hex que mata el tema | `forense-ruta-vu.md` |
| 🅝 Nuxt 2 | `window is not defined` · la hidratación que no cuadra | `forense-ruta-nx.md` |"""
new_rutas = """| Ruta | Lo que investiga | Herramienta principal | Archivo |
|---|---|---|---|
| 🅠 Quasar 1 | El componente que no renderiza y no avisa · la tabla que pagina dos veces | Vue DevTools → Components, y `quasar.conf.js` | `forense-ruta-q.md` |
| 🅥 Vuetify 2 | El `v-app` ausente que rompe en silencio · el hex que mata el tema | El inspector de elementos, sobre el DOM renderizado | `forense-ruta-vu.md` |
| 🅝 Nuxt 2 | `window is not defined` · la hidratación que no cuadra | La terminal del servidor Nuxt, antes que la consola | `forense-ruta-nx.md` |"""
assert old_rutas in s
s = s.replace(old_rutas, new_rutas)

# --- A: preámbulo honesto del índice de síntomas
old_pre = """La tabla que se consulta de verdad. A la izquierda, lo que ves o lo que te cuentan; a la
derecha, dónde empezar. Todo lo que está acá sale de las secciones «⚠️ Errores comunes» de
las fases: no hay ningún síntoma inventado."""
new_pre = """La tabla que se consulta de verdad. A la izquierda, lo que ves o lo que te cuentan; a la
derecha, dónde empezar. Todo lo que está acá sale de lo que las fases ya enseñan —casi
todo, de sus secciones «⚠️ Errores comunes»; el resto, de su código o de sus ejercicios—:
no hay ningún síntoma inventado. Lo que ninguna fase produce está en §6, y no en esta
tabla."""
assert old_pre in s
s = s.replace(old_pre, new_pre)

# --- A: filas para las fases 0→3, 1 y 2
old_row = """| "Le di a guardar y no pasó nada", consola limpia | Fase 5 —"""
new_row = """| `this` es `undefined` dentro de un método, y el código "es idéntico" al de al lado | Fase 0 → Fase 3 — una arrow function en las opciones del componente: `this` dejó de ser la instancia |
| "Entré a un ticket que no existe y la pantalla no dice nada" | Fase 1 — la vista de detalle no distingue "no existe" de "todavía no cargó" |
| El mismo dato se pide desde tres componentes y cada uno lo trae distinto | Fase 1 — falta la capa de servicios; no es un bug todavía, es el que viene |
| "Me saca al login sin decir nada" | Fase 2 — el guard redirige sin mensaje; y solo mira que el token **exista** |
| El token venció (o es basura) y la aplicación se comporta como si nada | Fase 2 — existencia no es validez: hasta que el mock conteste 401, nadie lo desmiente |
| Borraste el token a mano en DevTools y la sesión siguió en pantalla hasta navegar | Fase 2 — el guard y el interceptor leen `localStorage`, el store tiene su propia copia, y nadie las sincroniza |
| "Le di a guardar y no pasó nada", consola limpia | Fase 5 —"""
assert old_row in s
s = s.replace(old_row, new_row)

# --- A: bloque de pendientes al final
old_end = """> 🧭 **El criterio para saber si el track hizo su trabajo:** que ante un ticket vago, tu
> primer movimiento ya no sea abrir el editor."""
new_end = old_end + """

---

## 6. 📌 Síntomas sin pieza (pendientes)

Estos tres se consideraron para el índice y **no entraron**, porque ninguna fase del curso
los produce. Se anotan acá en vez de inventarles una fase, que es lo que manda
[`formato-piezas-forenses.md`](../prompts/formato-piezas-forenses.md) §9. Si alguna fase
llega a cubrirlos, suben a §3.

| Síntoma | Por qué no tiene pieza |
|---|---|
| "Cierro sesión en una pestaña y en la otra sigo dentro" | Ninguna fase toca el evento `storage` ni la sesión multi-pestaña: la Fase 2 guarda en `localStorage` y ahí se queda |
| "La métrica del dashboard no cuadra con el número de filas de la tabla" | La Fase 7 calcula sus métricas sobre el mismo arreglo que pinta la tabla, así que el curso nunca produce la divergencia |
| "El mock devuelve 404 en un endpoint anidado y en Postman funciona" | El curso consume los comentarios como `GET /comments?ticketId=X` (Fase 3), nunca en forma anidada |"""
assert old_end in s
s = s.replace(old_end, new_end)
open(p,'w',encoding='utf-8').write(s)
print("ok A+B C01")
PY

# --- 2026-09-10T01:20:20 · Apply A and B to course 02 master
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
python3 - <<'PY'
p='02-complement-mongodb-backend/forense-master.md'
s=open(p,encoding='utf-8').read()

old = """| Fase | El síntoma que cubre | Archivo |
|---|---|---|
| 0 | "Levanté todo y no conecta", con errores que no hablan de lo que pasa | `forense-fase-00.md` |
| 1 | "El dato está en la base y la consulta no lo encuentra" | `forense-fase-01.md` |
| 2 | "Traduje mi WHERE y devuelve de más" ⭐ | `forense-fase-02.md` |
| 4 | "El validator rechaza un documento que a mí me parece correcto" | `forense-fase-04.md` |
| 5 | "Esta pantalla hace seis viajes a la base" ⭐ | `forense-fase-05.md` |
| 6 | "Dos agentes tomaron el mismo ticket" ⭐ | `forense-fase-06.md` |
| 7 | "El índice está creado y `explain()` sigue diciendo COLLSCAN" | `forense-fase-07.md` |
| 8 | "La migración pasó el conteo y los datos son basura" | `forense-fase-08.md` |
| 9 | "Mi GROUP BY devuelve UNA fila" | `forense-fase-09.md` |
| 10 | "El request se queda girando para siempre" ⭐ | `forense-fase-10.md` |
| 12 | "Por socket llega distinto que por HTTP" | `forense-fase-12.md` |
| 13 | "Verde en mi máquina, rojo en CI" | `forense-fase-13.md` |"""

new = """| Fase | El síntoma que cubre | Herramienta principal | Archivo |
|---|---|---|---|
| 0 | "Levanté todo y no conecta", con errores que no hablan de lo que pasa | El log del contenedor (`docker compose logs`) | `forense-fase-00.md` |
| 1 | "El dato está en la base y la consulta no lo encuentra" | `mongosh`, sobre el documento crudo | `forense-fase-01.md` |
| 2 | "Traduje mi WHERE y devuelve de más" ⭐ | `mongosh`, comparando contra el conteo | `forense-fase-02.md` |
| 4 | "El validator rechaza un documento que a mí me parece correcto" | `mongosh` + `db.getCollectionInfos()` | `forense-fase-04.md` |
| 5 | "Esta pantalla hace seis viajes a la base" ⭐ | `explain()` sobre el pipeline, y Compass | `forense-fase-05.md` |
| 6 | "Dos agentes tomaron el mismo ticket" ⭐ | Dos sesiones de `mongosh`, y `matchedCount` | `forense-fase-06.md` |
| 7 | "El índice está creado y `explain()` sigue diciendo COLLSCAN" | `explain("executionStats")` | `forense-fase-07.md` |
| 8 | "La migración pasó el conteo y los datos son basura" | El muestreo campo a campo, no el conteo | `forense-fase-08.md` |
| 9 | "Mi GROUP BY devuelve UNA fila" | `mongosh`, corriendo el pipeline por etapas | `forense-fase-09.md` |
| 10 | "El request se queda girando para siempre" ⭐ | Los logs de morgan, y `curl` | `forense-fase-10.md` |
| 12 | "Por socket llega distinto que por HTTP" | El cliente de socket junto a `curl`, lado a lado | `forense-fase-12.md` |
| 13 | "Verde en mi máquina, rojo en CI" | La salida de la suite y el log del runner | `forense-fase-13.md` |"""
assert old in s
s = s.replace(old, new)

old_pre = """La tabla que se consulta de verdad. A la izquierda, lo que ves o lo que te cuentan; a la
derecha, dónde empezar. Todo lo que está acá sale de las secciones «⚠️ Errores comunes» de
las fases: no hay ningún síntoma inventado."""
new_pre = """La tabla que se consulta de verdad. A la izquierda, lo que ves o lo que te cuentan; a la
derecha, dónde empezar. Todo lo que está acá sale de lo que las fases ya enseñan —casi
todo, de sus secciones «⚠️ Errores comunes»; el resto, de su código o de sus ejercicios—:
no hay ningún síntoma inventado. Lo que ninguna fase produce está en §6, y no en esta
tabla."""
assert old_pre in s
s = s.replace(old_pre, new_pre)

old_end = """> 🧭 **El criterio para saber si el track hizo su trabajo:** que ante *"Mongo va lento"*, tu
> primer movimiento sea pedir la consulta y el `explain()`, y no proponer un índice."""
new_end = old_end + """

---

## 6. 📌 Síntomas sin pieza (pendientes)

Dos se consideraron para el índice y **no entraron**, porque ninguna fase los produce como
síntoma. Se anotan acá en vez de inventarles una fase, que es lo que manda
[`formato-piezas-forenses.md`](../prompts/formato-piezas-forenses.md) §9. Si alguna fase
llega a cubrirlos, suben a §3.

| Síntoma | Por qué no tiene pieza |
|---|---|
| "La fecha se guarda bien y se lee con un día menos" | El curso trata las fechas sin zona en un ejercicio de la Fase 1 y en la frontera `Date → ISO` de la Fase 10, pero ninguna fase produce el corrimiento de un día ni enseña a diagnosticarlo |
| "Guardé el ticket y al releerlo falta un campo" | Lo más cercano es la proyección que mezcla `1` y `0` (Fase 2), que es otra causa. El caso del campo que se pierde al escribir no aparece en ninguna fase |"""
assert old_end in s
s = s.replace(old_end, new_end)
open(p,'w',encoding='utf-8').write(s)
print("ok A+B C02")
PY

# --- 2026-09-10T01:20:32 · Final verification of edits
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
echo "== refs viejas =="; grep -rn "La ruta cambia, la URL cambia\|relé tonto del Curso 01\|sesión que sobrevive\|métrica que no cuadra" prompts/ 0*/forense-master.md
echo "== links =="
for f in prompts/*.md 01-vue2-legacy/forense-master.md 02-complement-mongodb-backend/forense-master.md; do d=$(dirname $f); grep -o '](\.\{0,2\}[^)]*\.md[^)]*)' $f | sed 's/](//;s/)$//;s/#.*//' | sort -u | while read p; do [ -e "$d/$p" ] || echo "ROTO: $f -> $p"; done; done
echo "== voseo =="; grep -nE '\b(tenés|podés|querés|hacé|mirá|fijate|vos|sabés|ponés|andá)\b' prompts/*.md 0*/forense-master.md
echo "== columnas tablas §2 =="; awk -F'|' '/^\|/{print NF-2, FILENAME}' 01-vue2-legacy/forense-master.md 02-complement-mongodb-backend/forense-master.md | sort | uniq -c

# --- 2026-09-10T01:20:42 · Show final diffstat
cd /Users/oskar/Developer/Learning/courses-ia-generated && git diff --stat -- vue2-legacy-for-backend-devs/ && wc -l vue2-legacy-for-backend-devs/0*/forense-master.md

# --- 2026-09-10T01:26:27 · Outline of mock API phase
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy && grep -n '^## \|^### ' 03-mock-api-minima.md && echo "=== total ===" && wc -l 03-mock-api-minima.md

# --- 2026-09-10T01:26:29 · Read install/run section of mock phase
sed -n '127,235p' 03-mock-api-minima.md

# --- 2026-09-10T01:26:33 · Read delay, exercises and closing
sed -n '383,420p' 03-mock-api-minima.md; echo "=== EJERCICIOS 675-760 ==="; sed -n '675,760p' 03-mock-api-minima.md; echo "=== CIERRE ==="; sed -n '788,824p' 03-mock-api-minima.md

# --- 2026-09-10T01:27:57 · Insert chaos injector section into phase 3
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > /tmp/chaos_section.md <<'EOF'
## 🔥 El inyector de caos (opcional, y de lo más rentable de la fase)

Hasta acá json-server se ha portado como un backend educado: contesta rápido,
contesta bien, y contesta siempre. Ningún backend real hace eso. El día que tu
aplicación se rompa en producción no vas a tener un error limpio en consola:
vas a tener un spinner que no termina, una tabla vacía que no explica nada, o
un `200 OK` que trae basura.

El inyector de caos es un middleware de treinta líneas que hace mentir al mock
**a propósito**, cuando tú se lo pides. Sin la variable de entorno es
completamente transparente: no toca una sola respuesta.

### `mock/chaos.js`

Créalo en una carpeta `mock/` en la raíz del proyecto:

```js
// mock/chaos.js
// Middleware de caos para json-server. Se activa con la variable de entorno
// CHAOS; sin ella no toca ni una respuesta.
//
// Uso:  CHAOS=malformed npm run mock

var CHAOS = process.env.CHAOS || "off";
var SLOW_MS = 4000;

module.exports = function (req, res, next) {
  // Sin caos, el middleware es transparente.
  if (CHAOS === "off") {
    return next();
  }

  // El navegador bloquea la respuesta porque le faltan las cabeceras de CORS.
  // json-server las pone por defecto; acá las quitamos justo antes de enviar.
  if (CHAOS === "cors") {
    var originalWriteHead = res.writeHead;
    res.writeHead = function () {
      res.removeHeader("Access-Control-Allow-Origin");
      return originalWriteHead.apply(res, arguments);
    };
    return next();
  }

  // El servidor recibe el request y no contesta nunca. Sin error, sin cierre.
  if (CHAOS === "timeout") {
    return; // a propósito: no se llama a next() ni se responde
  }

  // 200 en verde, cuerpo roto: JSON cortado a la mitad.
  if (CHAOS === "malformed" && req.method === "GET") {
    res.status(200);
    res.set("Content-Type", "application/json");
    return res.send('[{"id":1,"title":"La impresora no imp');
  }

  // El error honesto: el servidor admite que algo se rompió.
  if (CHAOS === "500" && req.method === "GET") {
    return res.status(500).json({ error: "Internal Server Error" });
  }

  // Contesta bien, pero tarde. Cuatro segundos son eternos en una pantalla.
  if (CHAOS === "slow") {
    return setTimeout(next, SLOW_MS);
  }

  // 200, JSON válido, y ni un dato adentro.
  if (CHAOS === "empty" && req.method === "GET") {
    return res.status(200).json([]);
  }

  return next();
};
```

### Encenderlo

El middleware se carga con la bandera `--middlewares` de json-server, la misma
que usa el ejercicio 24. Cambia el script `mock` de tu `package.json` para que
lo cargue siempre —recuerda que sin la variable no hace nada—:

```json
{
  "scripts": {
    "mock": "json-server --watch db.json --port 3000 --middlewares mock/chaos.js"
  }
}
```

Y a partir de ahí, el caos se pide en la línea de comandos:

```bash
npm run mock                      # normal, como siempre
CHAOS=malformed npm run mock      # el mock miente
CHAOS=timeout npm run mock        # el mock no contesta
```

> 📝 **En Windows** la sintaxis `CHAOS=… npm run …` no funciona ni en `cmd` ni
> en PowerShell. Usa `set CHAOS=malformed && npm run mock` en `cmd`, o instala
> `cross-env` como devDependency y escribe
> `cross-env CHAOS=malformed npm run mock`.

### Qué enseña cada fallo

No son seis variantes del mismo susto: cada una entrena una lectura distinta.

**`cors`, `timeout` y el servidor apagado son indistinguibles desde el código
del cliente**, y ésa es la lección más importante de las seis. En los tres
casos `error.response` es `undefined`: axios no recibió una respuesta, y no
tiene forma de decirte por qué. Tu `catch` no puede distinguir "el servidor no
está" de "el servidor está y el navegador me bloqueó la respuesta" de "el
servidor recibió el request y se quedó pensando". La diferencia solo se ve en
Network y en la consola del navegador, nunca en tu código — y por eso el
ejercicio 19 te pedía un mensaje genérico de "sin conexión": es honesto
justamente porque no puedes ser más preciso.

**`malformed` es el traicionero**, porque llega en verde. Network dice `200`,
tu `.catch` no se ejecuta, tu spinner se apaga… y la vista revienta después,
en un sitio que no tiene nada que ver, con un error del tipo
`tickets.filter is not a function`. Averigua qué tiene `res.data` cuando el
cuerpo no es JSON válido —`typeof` te va a sorprender— y vas a entender por qué
el error aparece tan lejos de su causa.

**`500` es el fallo cortés:** el servidor te dice que se rompió, `error.response`
existe, y tu código puede decidir. Compáralo con `malformed` y vas a ver que un
error explícito es un regalo.

**`timeout` es el spinner eterno**, el bug más caro de soportar: nadie reporta
"salió un error", reportan "se queda cargando" o directamente "va lento". Sin
un `timeout` configurado en axios, tu aplicación espera para siempre.

**`slow` y `empty` no son errores, y ése es el punto.** Con `slow` el sistema
funciona perfecto, solo que cuatro segundos después: si tu vista no muestra
estado de carga, el usuario hace clic tres veces y crea tres tickets. Y con
`empty` la pantalla se ve idéntica a "todavía no hay tickets", cuando en
realidad es "los tickets no llegaron". Distinguir *vacío* de *fallido* es una
decisión de diseño que casi nadie toma hasta que le explota.

### Lo que ves / lo que es

| Lo que ves en la pantalla | Lo que dice Network | Lo que es de verdad |
|---|---|---|
| Spinner infinito | El request queda en `pending`, sin cerrarse | `timeout` — o el servidor caído, no puedes saberlo desde el código |
| "Sin conexión con el servidor" | Request en rojo, sin cuerpo; la consola habla de CORS | `cors` — el servidor contestó, el navegador lo bloqueó |
| "Sin conexión con el servidor" | El request ni siquiera sale | Servidor apagado. Idéntico al anterior para tu `catch` |
| Tabla vacía sin mensaje | `200 OK`, cuerpo `[]` | `empty` — no es "no hay datos", es "no llegaron datos" |
| La tabla revienta con `.filter is not a function` | `200 OK`, y el cuerpo se ve raro | `malformed` — el cuerpo no era JSON, y `res.data` te llegó como texto |
| Mensaje de error del `catch` | `500` con cuerpo JSON | `500` — el único fallo que se anuncia |
| Todo funciona, pero se siente mal | `200 OK`, cuatro segundos de latencia | `slow` — no es un bug, es una ausencia de estado de carga |

> 🧭 **Guarda esta tabla.** Es la primera columna la que te van a reportar
> —siempre— y la tercera la que necesitas averiguar. Todo el track forense de
> este curso consiste en aprender a recorrer esa distancia rápido:
> [`forense-master.md`](forense-master.md) es la puerta.

> 💡 **Esta es la forma preferida de preparar un incidente.** Los casos del
> [cuaderno de incidentes](cuaderno-incidentes.md) se montan con una de tres
> formas —un flag, un `db.json` alterno o una rama de git— y el flag va
> primero siempre que sirva: no toca tu código, no toca tus datos, y se apaga
> sola cuando reinicias el mock.

---

EOF
python3 - <<'PY'
p='03-mock-api-minima.md'
s=open(p,encoding='utf-8').read()
sec=open('/tmp/chaos_section.md',encoding='utf-8').read()
anchor="## ⚠️ Errores comunes\n"
assert s.count(anchor)==1
s=s.replace(anchor, sec+anchor)
open(p,'w',encoding='utf-8').write(s)
print('sección insertada')
PY

# --- 2026-09-10T01:28:17 · Append chaos exercises and update count
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
python3 - <<'PY'
p='03-mock-api-minima.md'
s=open(p,encoding='utf-8').read()

old_head="## 🧪 Ejercicios (26)"
assert s.count(old_head)==1
s=s.replace(old_head,"## 🧪 Ejercicios (30)")

anchor="""26. Escribe `API-CONTRACT.md`: documenta cada endpoint que usa el frontend
    (método, ruta, params, forma del request y response, códigos de error
    esperados). Este documento es lo que le entregarías al equipo de backend
    para reemplazar el mock. En proyectos reales, este contrato vale más que
    el código.
"""
assert s.count(anchor)==1
extra = anchor + """
**🔥 Caos (27–30)** — necesitan `mock/chaos.js` de la sección 🔥.

27. Corre `CHAOS=empty npm run mock` y mira `TicketsView`. ¿Puede tu vista, hoy,
    distinguir "no hay tickets" de "los tickets no llegaron"? Haz que sí pueda:
    el estado vacío legítimo dice una cosa, y el que viene de una respuesta
    sospechosa dice otra. Criterio de éxito: las dos situaciones muestran textos
    distintos, y ninguna se llama "Error".
28. Con `CHAOS=malformed npm run mock`, entra a la lista y anota **tres cosas**:
    el status que muestra Network, si tu `.catch` se ejecutó, y qué devuelve
    `typeof` sobre la respuesta del servicio. Después arregla `ticketService`
    para que un cuerpo que no sea un arreglo se convierta en un error del
    servicio y no en un reventón de la vista, con un `console.count` de por
    medio si te ayuda. Criterio de éxito: el mensaje de error aparece en la
    vista, no en la consola.
29. Levanta `CHAOS=timeout npm run mock` y cronometra cuánto espera tu
    aplicación. Después agrega `timeout: 5000` al `apiClient` y repite. Compara
    contra apagar json-server del todo: ¿puede tu código distinguir los dos
    casos? Escribe la respuesta en un comentario, con el valor de
    `error.response` en cada uno como evidencia.
30. **El experimento de CORS.** Corre `CHAOS=cors npm run mock` y verifica que
    la petición sale y no vuelve. Ahora pídele lo mismo al servidor con
    `curl -i http://localhost:3000/tickets` desde otra terminal. Funciona.
    Explica en tres líneas por qué `curl` no se entera de nada y el navegador
    sí — y por qué la consola del navegador es el único sitio del sistema donde
    aparece la palabra CORS.
"""
s=s.replace(anchor,extra)
open(p,'w',encoding='utf-8').write(s)
print('ejercicios ok')
PY
grep -n "Ejercicios (30)\|🔥 Caos" 03-mock-api-minima.md; wc -l 03-mock-api-minima.md

# --- 2026-09-10T01:28:30 · Outline phase 0 and its common errors
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
grep -n '^## \|^### ' 00-setup-hola-mundo.md | head -40; echo "=== errores F0 ==="; sed -n '1009,1040p' 00-setup-hola-mundo.md

# --- 2026-09-10T01:28:36 · Read versions, verification and startup of phase 0
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
sed -n '89,112p;358,372p' 00-setup-hola-mundo.md; echo "=== script mock + arranque ==="; sed -n '749,776p;964,1008p' 00-setup-hola-mundo.md

# --- 2026-09-10T01:30:03 · Write forensic piece for phase 0
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > forense-fase-00.md <<'EOF'
# 🕵️ Forense Fase 00 — "Instalé todo y no arranca"

> **Sale de:** [Fase 0 — Setup y Hola Mundo](00-setup-hola-mundo.md) ·
> **Herramientas:** la salida de `vue-cli-service` en la terminal, `node -v`,
> `npm ls` · **Recorrido:** cuatro pasos, ninguno abre un archivo `.vue`
>
> **El síntoma, en una línea:** la aplicación no compila, y el error habla de
> algo que tú no escribiste.

Es la investigación menos glamorosa del curso y la que más veces vas a repetir
en tu vida: llegas a un proyecto ajeno, corres `npm install && npm run serve`, y
la terminal escupe un muro que menciona archivos que no existen en tu código.
La lección es que **casi ninguno de esos errores es del proyecto: son del
entorno**, y el entorno se descarta en tres minutos si lo miras en el orden
correcto.

---

## 🎫 El ticket

> "Clonaste el repo del Mini Jira como te dije y no te arranca. A mí me
> funciona perfecto, o sea que algo hiciste mal en la instalación. Mándame el
> error y lo vemos, pero seguro es tu máquina."
>
> — el compañero que te pasó el proyecto, por chat, un lunes

Dos cosas ciertas y una falsa. Cierto: a él le funciona. Cierto: es tu máquina.
Falso: que eso signifique que hiciste algo mal.

---

## 🧭 La ruta

Los pasos van **del más barato al más caro**, y en esta fase la diferencia es
brutal: el paso 1 cuesta cinco segundos y descarta la mitad de los casos; el
reflejo que casi todo el mundo tiene primero —borrar `node_modules` y
reinstalar— cuesta diez minutos y no descarta nada.

### Paso 1 — ¿qué Node estás corriendo?

Antes que nada, en la raíz del proyecto:

```bash
node -v
cat .nvmrc
```

```
v18.19.0
14.21.3
```

**Qué descarta.** Si los dos números no coinciden, para acá: `nvm use` y vuelve
a empezar. Un Node que no es el del proyecto explica los muros de `gyp ERR!` al
instalar, los binarios que no compilan y buena parte de los "comportamientos
raros del tooling" que no tienen mejor nombre. Si coinciden, el entorno de Node
queda descartado y sigues al paso 2.

> ⚠️ En Apple Silicon el `.nvmrc` del curso puede decir `16.20.2` en vez de
> `14.21.3`, y está bien: la Fase 0 lo explica. Lo que importa es que
> `node -v` diga lo mismo que el archivo.

### Paso 2 — ¿el error habla de compilar plantillas?

Lee la **primera** línea del muro, no la última. Si aparece la palabra
`compiler`, el diagnóstico está a un comando:

```bash
npm ls vue vue-template-compiler
```

```
mini-jira@0.1.0 /Users/…/mini-jira
├── vue@2.6.14
└── vue-template-compiler@2.6.12
```

Y el error que lo delata, tal como sale:

```
Vue packages version mismatch:

- vue@2.6.14
- vue-template-compiler@2.6.12

This may cause things to work incorrectly. Make sure to use the same version
for both.
```

**Qué descarta.** Si los dos números no son idénticos —no "compatibles":
**idénticos**—, ése es tu bug y se arregla igualando las versiones y
reinstalando. Fíjate en el detalle que hace que esto pase: el error dice
*"esto puede hacer que las cosas funcionen incorrectamente"*, no *"esto está
roto"*, así que a veces compila igual y te muerde tres fases después. Si las
versiones coinciden, sigues al paso 3.

### Paso 3 — ¿es un puerto, y no un error?

Si el muro trae `EADDRINUSE`, no es un problema de dependencias:

```
Error: listen EADDRINUSE: address already in use :::8888
```

```bash
lsof -i :8888        # macOS / Linux
netstat -ano | findstr :8888   # Windows
```

**Qué descarta.** Descarta el proyecto entero. Es un proceso vivo de otra
terminal —el Stubby de la Fase 0 es el sospechoso habitual, y en la Fase 3 lo
será json-server en el 3000— que sigue escuchando porque cerraste la ventana en
vez de hacer `Ctrl+C`. Mátalo y vuelve a arrancar. Si el puerto está libre,
sigues al paso 4.

### Paso 4 — ¿compila y el problema está en el editor?

Éste es el caso que más tiempo hace perder, porque no es un error: el proyecto
arranca, pero el archivo "baila" al guardar, o el `.vue` se ve sin colores, o
aparecen subrayados rojos que `npm run serve` no reporta.

```bash
code --list-extensions | grep -i "vetur\|volar\|prettier"
```

```
esbenp.prettier-vscode
octref.vetur
Vue.volar
```

**Qué descarta.** Descarta el código: lo que ves es el editor discutiendo
consigo mismo. Volar es de **Vue 3** y con Vetur se sabotean mutuamente; y si
además Prettier y el formateador de Vetur compiten por el mismo tipo de
archivo, cada guardado te deja un diff distinto. Un solo formateador por tipo
de archivo, y Volar desinstalado mientras estés en Vue 2.

---

## 🩺 Diagnóstico por síntoma

| Lo que dice la terminal (o el editor) | Dónde está de verdad |
|---|---|
| `Vue packages version mismatch` | `package.json` — `vue` y `vue-template-compiler` desalineados |
| Muros de `gyp ERR!` al instalar | Node equivocado: falta `nvm use` |
| `EADDRINUSE :::8888` | Un mock zombi de otra terminal |
| `EADDRINUSE :::8080` | Otro `npm run serve` vivo, casi siempre en otra pestaña del IDE |
| `command not found: vue-cli-service` | No corriste `npm install`, o lo corriste con otro Node |
| El `.vue` no tiene resaltado de sintaxis | Falta Vetur, o Volar lo está peleando |
| El archivo cambia solo al guardar, siempre distinto | Dos formateadores compitiendo |
| "En mi IDE no funciona, en la terminal sí" | WebStorm apuntando a otro Node interpreter |
| El formulario del Hello World no responde y la consola pide el mock | Stubby apagado — no es un bug del código |

---

## ⚰️ Los callejones

**"Borro `node_modules` y reinstalo."** Es el reflejo universal y el peor uso
posible de diez minutos: si el problema es el Node equivocado, reinstalar con
el mismo Node equivocado reproduce el problema idéntico, y ahora además no
sabes si cambió algo. Reinstalar es la **consecuencia** de un diagnóstico
(cambiaste de Node, igualaste versiones), nunca el diagnóstico.

**"Voy a actualizar las dependencias, seguro es que están viejas."** Están
viejas **a propósito**: la tabla de versiones de la Fase 0 es el terreno del
curso. Actualizar `vue` a la 2.7 para "ver si se arregla" te cambia el problema
por otro que ya no está documentado en ninguna parte.

**"Es Windows."** A veces sí, pero casi nunca por lo que crees. El caso real es
otro: la sintaxis `CHAOS=… npm run mock` de la Fase 3 no existe en `cmd` ni en
PowerShell, y eso no es un bug del proyecto sino una diferencia de shell.

---

## 🧨 Deshacer

El paso 2 invita a romper a propósito, y conviene hacerlo hoy (es el ejercicio
4 de la fase). Para volver:

```bash
npm install vue@2.6.14 vue-template-compiler@2.6.14 --save-exact
npm run serve
```

Si además tocaste el `.nvmrc`, restáuralo con `git checkout -- .nvmrc`.

---

## 🧠 El patrón transferible

Un error críptico **nombra el síntoma, no la causa**, y casi siempre lo nombra
en el vocabulario de la herramienta que se rompió —no en el tuyo. Por eso el
orden de esta pieza no es "de lo más probable a lo menos probable", sino
**del entorno hacia adentro**: versión de runtime, versiones de paquetes,
puertos, editor. Todo eso se descarta sin leer una línea de código de la
aplicación, y cuando no lo descartas primero terminas depurando tu componente
porque el editor tenía dos formateadores.

La versión corta, para llevar: *"a mí me funciona" es la descripción de una
diferencia, y encontrarla es el trabajo.*

**Sigue por acá:** el resumen de esta ruta vive en la sección 6 de la
[Fase 0](00-setup-hola-mundo.md); el índice de síntomas de todo el curso, en
[`forense-master.md`](forense-master.md); y el caso completo, en el
[incidente 01](cuaderno-incidentes.md) del cuaderno.
EOF
wc -l forense-fase-00.md

# --- 2026-09-10T01:30:10 · Read phase 1 structure and services
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
sed -n '1,60p' 01-estructura-base-legacy.md; echo "=== services ==="; grep -n "ticketService\|services/" 01-estructura-base-legacy.md | head -20; echo; sed -n '230,320p' 01-estructura-base-legacy.md

# --- 2026-09-10T01:30:13 · Read phase 1 services placeholders
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
sed -n '320,405p' 01-estructura-base-legacy.md

# --- 2026-09-10T01:31:13 · Write forensic piece for phase 1
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > forense-fase-01.md <<'EOF'
# 🕵️ Forense Fase 01 — "Entré a un ticket que no existe y la pantalla no dice nada"

> **Sale de:** [Fase 1 — Estructura base legacy](01-estructura-base-legacy.md) ·
> **Herramientas:** Vue DevTools → Components, la URL, y la consola del
> navegador · **Recorrido:** cuatro pasos
>
> **El síntoma, en una línea:** la ruta hace match, la vista se monta, y lo que
> se pinta es un hueco.

Ésta es la primera investigación del curso que **no** termina en un bug. Termina
en una decisión que nadie tomó, que es una categoría de hallazgo que vas a
encontrar mucho más seguido que los errores de verdad: el código hace
exactamente lo que le pediste, y lo que le pediste no cubre el caso.

---

## 🎫 El ticket

> "Un compañero me pasó el link de un ticket por chat y cuando lo abro no se ve
> nada. Bueno, se ve el título 'Detalle de ticket' y abajo nada. No sale ningún
> error, no dice que no exista, no dice nada. ¿Se borró el ticket? ¿Se rompió
> la aplicación? No sé qué decirle al usuario."
>
> — coordinadora de soporte · **Ambiente:** desarrollo

---

## 🧭 La ruta

Del más barato al más caro: primero la URL (que ya está en pantalla), después
el estado del componente (un clic en DevTools), después el servicio (una línea
en la consola), y solo al final el código.

### Paso 1 — ¿la ruta hizo match, y con cuál?

Mira la URL y abre Vue DevTools → **Components** → el componente montado.

```
URL: http://localhost:8080/tickets/999
Componente montado: <TicketDetailView>
$route.params: { id: "999" }
```

**Qué descarta.** Descarta el router entero, que es el sospechoso número uno
cuando "la pantalla no muestra nada". La ruta dinámica `/tickets/:id` capturó el
999 y montó la vista correcta — si el problema fuera de rutas verías
`<NotFoundView>`, porque la Fase 1 dejó el fallback `*` configurado. También te
deja ver, gratis, un dato que importa en el paso 3: **`id` es el string
`"999"`, no el número 999.** Los params de vue-router siempre son texto.

### Paso 2 — ¿qué tiene el componente adentro?

En el mismo panel, con `<TicketDetailView>` seleccionado, mira sus datos.

```
data
  ticket: undefined
```

**Qué descarta.** Descarta la plantilla: no es que el `<template>` esté pintando
mal un objeto, es que no hay objeto. Y descarta también la mitad de las
hipótesis de red que se te estaban ocurriendo — en esta fase todavía no hay
red: los datos salen de un arreglo en memoria dentro de `ticketService.js`. Si
`ticket` es `undefined`, alguien devolvió `undefined`.

### Paso 3 — ¿quién devolvió el hueco?

En la consola del navegador, pregúntaselo al servicio directamente:

```js
> ticketService.getTicketById("999")
undefined
> ticketService.getTicketById("1")
{ id: 1, title: "La impresora no imprime", status: "open", priority: "high" }
```

**Qué descarta.** Descarta que el servicio esté roto: con un id que existe
devuelve el ticket, y con uno que no existe devuelve `undefined`. Eso es
**exactamente** lo que hace un `Array.find` que no encuentra nada, y es la
respuesta correcta: el servicio no tiene por qué inventarse un ticket ni
explotar. Acá se cierra la mitad del caso — el dato no está porque no existe, no
porque se haya perdido.

### Paso 4 — ¿en qué capa vive la decisión que falta?

Ahora sí, el archivo, que es el paso caro y el último:

```
src/
  views/TicketDetailView.vue     ← pinta lo que le den
  services/ticketService.js      ← devuelve undefined cuando no encuentra
```

**Qué descarta.** Descarta la idea de "arreglar el servicio". La pregunta
*"¿este ticket no existe, o todavía no llegó?"* es de **presentación**, no de
datos: solo la vista sabe si está en su primer render, si terminó de buscar, o
si buscó y no había. El servicio contestó bien; la vista nunca preguntó. Y la
distinción no es cosmética: cuando en la Fase 3 el mismo `undefined` pueda
significar además "el servidor no contestó", una vista que no diferencia los
tres casos va a mentir tres veces con la misma pantalla en blanco.

Acá termina el recorrido: ya sabes **dónde** está. El fix es de la fase — los
ejercicios 12 y 13 lo piden — y en la Fase 3 se vuelve a tocar con `TicketsView`
y su estado de error.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| La vista de detalle se monta y está hueca | El servicio devolvió `undefined`: falta el caso "no encontrado" en la vista |
| Ves `<NotFoundView>` con un id que existe | La ruta no hizo match: revisa el orden y el `path` en `router/index.js` |
| `$route.params.id` es `"1"` y tu comparación falla | Los params son **string** siempre; el servicio hace `Number(id)` por eso |
| El enlace del sidebar no se marca como activo | Falta la clase de `router-link-active`, no es un problema de navegación |
| Recargas con F5 y aparece un 404 del servidor | `mode: "history"` sin el fallback del servidor. En `npm run serve` no pasa; en el build sí |
| El mismo dato se pide desde tres componentes y cada uno lo trae distinto | No hay bug todavía: falta capa de servicios, y es el bug de la fase que viene |

---

## ⚰️ Los callejones

**"Es que el param llega como string y la comparación con `===` falla."** Es la
hipótesis más razonable del caso, la que se le ocurre a todo el mundo, y en este
proyecto **es falsa**: `getTicketById` ya hace `Number(id)` antes de comparar.
La evidencia que la tumba es el paso 3, que devuelve el ticket correcto para
`"1"` — si el problema fuera el tipo, tampoco funcionaría ése. Vale la pena
haberla tenido igual: en un proyecto ajeno esa conversión falta más veces de
las que está.

**"Se borró el ticket de la base."** No hay base todavía. En la Fase 1 los
datos viven en un arreglo dentro de `ticketService.js` y desaparecen al
recargar, cosa que la Fase 3 arregla con json-server. Antes de investigar una
pérdida de datos, pregunta dónde estaban guardados.

**"Hay que meter esto en Vuex para que la vista lo tenga."** El store de la
Fase 1 existe pero está vacío a propósito. Meter el ticket seleccionado en Vuex
no contesta la pregunta que falta —"¿no existe o no cargó?"— solo la mueve de
sitio, y encima crea el problema de la Fase 9: guardar el objeto en vez del id.

---

## 🧠 El patrón transferible

**Una pantalla vacía es siempre ambigua, y la ambigüedad es de quien la pinta.**
"No hay datos", "todavía no llegaron" y "hubo un error" se ven exactamente igual
si nadie decidió que se vieran distinto — y el que reporta el ticket solo puede
describir lo que se ve, así que el reporte también será ambiguo. Por eso este
recorrido tiene tan pocos pasos: la mitad del trabajo fue **traducir un síntoma
ambiguo a una pregunta con respuesta binaria** ("¿el servicio devolvió algo?"), y
la otra mitad, ubicar en qué capa vive la decisión.

Te lo vas a llevar tal cual al trabajo real: cuando alguien te diga *"no se ve
nada"*, tu primera pregunta no es "¿qué falló?" sino **"¿qué debería verse, y
quién decide eso?"**.

**Sigue por acá:** el resumen está en la sección 6 de la
[Fase 1](01-estructura-base-legacy.md), el índice de síntomas en
[`forense-master.md`](forense-master.md), y la versión con más capas encima en
la [pieza de la Fase 3](forense-fase-03.md), cuando el hueco pueda venir además
de la red.
EOF
wc -l forense-fase-01.md

# --- 2026-09-10T01:31:24 · Read phase 2 authService, guard and store
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
sed -n '143,215p' 02-autenticacion-minima.md; echo "=== store auth ==="; sed -n '196,300p' 02-autenticacion-minima.md | head -60

# --- 2026-09-10T01:32:17 · Write forensic piece for phase 2
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > forense-fase-02.md <<'EOF'
# 🕵️ Forense Fase 02 — "Me saca al login sin decir nada"

> **Sale de:** [Fase 2 — Autenticación mínima](02-autenticacion-minima.md) ·
> **Herramientas:** DevTools → Application → `localStorage`, Vue DevTools →
> Vuex, y el guard del router · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** la aplicación te devuelve a `/login` sin
> mensaje, sin error en consola y sin nada en Network.

Es el primer caso del curso donde **dos copias del mismo dato** no coinciden, y
donde el sistema toma una decisión importante sin dejar rastro. Las dos cosas
son la firma de los bugs de sesión: nadie registra nada, porque el código que
te expulsa no considera que haya pasado algo digno de contarse.

---

## 🎫 El ticket

> "Estaba trabajando normal, le di clic a un ticket de la lista y de golpe me
> apareció la pantalla de login otra vez. No salió ningún mensaje. Volví a
> entrar con mi usuario y ahí sí, todo normal. Me pasó dos veces esta semana,
> las dos como a media mañana."
>
> — agente de soporte · **Ambiente:** desarrollo y UAT

Guarda "no salió ningún mensaje": es el dato más informativo del reporte, y el
que va a orientar el paso 2.

---

## 🧭 La ruta

De lo más barato a lo más caro: primero se mira el almacenamiento (dos clics),
después quién decide la expulsión, después la segunda copia del dato, y solo al
final se toca el código.

### Paso 1 — ¿el token está?

DevTools → **Application** → Storage → Local Storage → `http://localhost:8080`.

```
Key      Value
─────────────────────────────
user     {"username":"admin","name":"Usuario Demo"}
```

**Qué descarta.** Descarta media investigación de una sentada. Si `token` no
está y `user` sí, ya sabes tres cosas: no fue un `logout` (que borra los dos con
`clearSession`), no fue el navegador limpiando el dominio (se habría llevado los
dos), y la sesión quedó **a medias**. Si estuvieran los dos, el problema sería
otro y saltarías al paso 4.

### Paso 2 — ¿quién te sacó?

En esta fase hay exactamente un actor con poder de redirigir, y está en
`router/index.js`:

```js
router.beforeEach(function (to, from, next) {
  var token = localStorage.getItem("token");
  // …
  if (requiresAuth && !token) {
    next("/login");
    return;
  }
```

**Qué descarta.** Descarta el backend, la red y cualquier 401: en la Fase 2 no
hay servidor todavía, y el interceptor de respuesta que expulsa por 401 es la
deuda 💸 que se paga en el ejercicio 24 de la Fase 3. También explica el "sin
mensaje" del reporte: `next("/login")` no muestra nada, no loguea nada y no
pone nada en Network. **El silencio no es un bug del guard: es su diseño.**

### Paso 3 — ¿y el store qué opina?

Vue DevTools → pestaña **Vuex** → módulo `auth`.

```
auth
  token: "mock-jwt-token-123"
  user: { username: "admin", name: "Usuario Demo" }
```

**Qué descarta.** Acá está el hallazgo. El store cree que la sesión sigue viva
—por eso el header seguía mostrando tu nombre hasta que navegaste— y el guard
cree que no hay sesión. Los dos tienen razón, porque **leen de sitios
distintos**: el guard va a `localStorage` y el store tiene su copia en memoria.
La Fase 2 lo dice sin esconderlo en su nota legacy honesta, y ésta es la
consecuencia práctica.

Descarta también "el store se limpió solo", que es la hipótesis natural cuando
uno cree que hay una sola fuente de verdad.

### Paso 4 — ¿y si el token está pero no sirve?

Prueba el caso contrario, que es el que nadie reporta porque no molesta:

```js
> localStorage.setItem("token", "cualquier-cosa")
> // navega a /tickets
```

Entras sin problema.

**Qué descarta.** Descarta la idea de que el guard "valide la sesión". No la
valida: comprueba que la clave `token` exista. Existencia no es validez, y hasta
que en la Fase 3 haya un servidor que conteste 401, nadie en el sistema es capaz
de desmentir un token inventado. Esto no es un fallo de esta fase —está
declarado en sus errores comunes— pero es el que va a producir el reporte
gemelo: *"un usuario dado de baja siguió entrando toda la tarde"*.

### Paso 5 — la reproducción, para poder cerrarlo

Con lo anterior ya sabes dónde está. Falta poder contárselo a alguien, y para
eso hay que reproducirlo a voluntad:

```js
> localStorage.removeItem("token")   // el usuario no hace esto…
> // …pero un script de la página, una extensión o un logout a medias, sí
```

Navega a cualquier ruta con `meta.requiresAuth` y verás la expulsión limpia, sin
mensaje. Ese es el reporte de la agente, reproducido en dos líneas.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves o te cuentan | Dónde empezar |
|---|---|
| Te manda a `/login` sin mensaje y sin nada en Network | El guard: `requiresAuth && !token` |
| El header sigue mostrando tu nombre después de la expulsión | El store conserva su copia; el guard lee `localStorage` |
| Entras con un token inventado | El guard comprueba existencia, no validez |
| Cierras sesión y al volver atrás con el navegador se ve la pantalla anterior | El componente ya estaba montado; la navegación hacia atrás no siempre dispara el guard como esperas |
| Estás en `/login` con sesión válida y te rebota a `/` | Es el segundo `if` del guard, y está haciendo lo correcto |
| Recargas y pierdes la sesión | `getStoredSession` no se está llamando al arrancar la app |
| El request sale sin `Authorization` | El interceptor lee `localStorage`, no el store: si están desincronizados, gana el vacío |

---

## ⚰️ Los callejones

**"Expiró el token."** No hay expiración en esta fase: el token es la cadena
literal `"mock-jwt-token-123"` y no caduca nunca. Lo que sí existe es el
ejercicio 17, que agrega un `expiresAt` — y ahí la hipótesis se vuelve
comprobable. Pídele siempre al reporte una hora: "como a media mañana" invita a
pensar en expiración, y no siempre lo es.

**"Es que el guard corre antes que el store."** Suena bien y es medio cierto,
pero no explica **este** síntoma: el orden de inicialización importa al
arrancar la aplicación, no al navegar entre rutas con todo ya montado. La
evidencia que lo tumba es el paso 3: el store estaba poblado.

**"Hay que mover el token a Vuex y listo."** Es la refactorización correcta
—el ejercicio 24 la propone— pero no es el diagnóstico, y aplicarla a ciegas
puede esconder el síntoma sin explicarlo. Primero se entiende por qué había dos
copias; después se elige cuál sobrevive.

---

## 🧨 Deshacer

Los pasos 4 y 5 te dejan la sesión sucia. Para volver a un estado sano:

```js
> localStorage.clear()
```

Y vuelve a iniciar sesión con `admin` / `1234`. Si además tocaste el guard para
probar, `git checkout -- src/router/index.js`.

---

## 🧠 El patrón transferible

**Cuando el mismo dato vive en dos sitios, el bug no está en ninguno de los
dos: está en que no hay contrato sobre cuál manda.** El guard no está mal
escrito, el store tampoco; lo que falta es la frase "la fuente de verdad de la
sesión es X" escrita en alguna parte y respetada por todos.

Y una segunda cosa, más útil todavía: **las decisiones silenciosas son las más
caras de depurar**. Un `next("/login")` sin log es un sistema tomando una
decisión de seguridad sin dejar rastro; cuando llegues a un legacy ajeno, busca
temprano esos puntos —redirecciones, `catch` vacíos, valores por defecto
silenciosos— porque son los sitios donde el sistema hace cosas que nadie puede
contar después.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 2](02-autenticacion-minima.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo, en el
[incidente 03](cuaderno-incidentes.md); y la continuación natural en la
[pieza de la Fase 3](forense-fase-03.md), donde por fin hay un servidor capaz
de decir que no.
EOF
wc -l forense-fase-02.md

# --- 2026-09-10T01:32:23 · Read phase 3 service and view code
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
sed -n '234,300p' 03-mock-api-minima.md; echo "=== VIEW ==="; sed -n '300,383p' 03-mock-api-minima.md

# --- 2026-09-10T01:33:29 · Write forensic piece for phase 3
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > forense-fase-03.md <<'EOF'
# 🕵️ Forense Fase 03 — "A veces carga y a veces se queda pensando"

> **Sale de:** [Fase 3 — Mock API mínima](03-mock-api-minima.md) ·
> **Herramientas:** Network, el inyector de caos (`mock/chaos.js`), `curl` y la
> consola · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el spinner se queda girando, o la pantalla
> queda vacía, y el `catch` no siempre puede decirte por qué.

Ésta es la pieza más rentable del tronco, y no porque el bug sea difícil: es
porque acá se aprende la lectura de Network, que sirve para todas las fases que
vienen. La lección central es incómoda y hay que decirla sin adornos: **desde el
código del cliente, "el servidor está apagado", "el navegador me bloqueó la
respuesta" y "el servidor recibió el request y no contestó" son el mismo
evento.** Tu `catch` no puede distinguirlos. Network sí.

---

## 🎫 El ticket

> "La lista de tickets a veces carga y a veces se queda cargando para siempre.
> No es que salga error, no sale nada, se queda con la ruedita. Si le doy F5
> unas cuantas veces al final entra. Ah, y a veces entra pero sale vacía, como
> si no hubiera tickets, y sí hay."
>
> — agente de soporte · **Ambiente:** desarrollo

Dos síntomas en un solo ticket, que es lo normal: "se queda cargando" y "sale
vacía" son distintos, y probablemente tengan causas distintas. El paso 1 los
separa.

---

## 🧭 La ruta

Del más barato al más caro: la pestaña Network ya está abierta y contesta el 80%
del caso; `curl` cuesta diez segundos y desempata cliente contra servidor; el
código es lo último.

### Paso 1 — ¿el request salió, volvió, o se quedó a medias?

DevTools → **Network** → filtro `XHR` → recarga `/tickets`.

```
Name      Status    Type   Size     Time
tickets   (pending) xhr    —        18.4 s
```

**Qué descarta.** Descarta todo tu código. Un request en `(pending)` significa
que el navegador mandó y está esperando: no hubo respuesta, no hubo error, y por
lo tanto ni tu `.then` ni tu `.catch` se ejecutaron nunca — por eso el spinner
sigue vivo, porque el `.finally` tampoco corrió. Compara con las otras dos
formas que puede tomar esta misma fila:

```
tickets   200       xhr    1.2 kB   61 ms     ← normal
tickets   (failed)  xhr    —        3 ms      ← no hubo servidor, o el navegador cortó
```

Si ves `(pending)`, sigue al paso 2. Si ves `(failed)`, salta al paso 3.

### Paso 2 — ¿el servidor está vivo y solo no contesta esta ruta?

Desde otra terminal, sin tocar el navegador:

```bash
curl -i -m 5 http://localhost:3000/tickets
```

```
curl: (28) Operation timed out after 5001 milliseconds with 0 bytes received
```

**Qué descarta.** Descarta el navegador entero: CORS, extensiones, caché,
service workers. Si `curl` también se queda esperando, el que no contesta es el
servidor, y ya sabes que tu frontend no tiene nada que ver. En este curso eso
significa casi siempre `CHAOS=timeout` encendido; en producción significa un
handler que entró y no salió — exactamente el request colgado que el Curso 02
investiga en su Fase 10.

Si `curl` **sí** contesta y el navegador no, el problema está entre los dos: ve
al paso 3.

### Paso 3 — el servidor contesta a `curl` y no al navegador

Ese cuadro tiene un solo sospechoso serio, y no deja rastro en tu código:

```bash
curl -i http://localhost:3000/tickets
```

```
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8
X-Powered-By: Express
```

Y en la **consola** del navegador (no en Network, no en tu `catch`):

```
Access to XMLHttpRequest at 'http://localhost:3000/tickets' from origin
'http://localhost:8080' has been blocked by CORS policy: No
'Access-Control-Allow-Origin' header is present on the requested resource.
```

**Qué descarta.** Descarta el servidor: contestó `200`, con cuerpo, y `curl` lo
recibió sin queja. El que se negó a entregarte la respuesta fue tu propio
navegador, aplicando una regla que `curl` no tiene por qué respetar. Reprodúcelo
a voluntad con `CHAOS=cors npm run mock`. Y fíjate en el detalle que hace a este
fallo tan caro: **la palabra "CORS" aparece en un solo sitio de todo el
sistema** —esa línea de la consola—; en tu `catch` llega el mismo error genérico
que si el servidor estuviera apagado.

### Paso 4 — el request volvió en verde y la pantalla igual está vacía

Otro síntoma del mismo ticket, otra rama. Si Network dice `200`:

```
tickets   200   xhr   38 B   45 ms
```

Mira el **cuerpo**, pestaña Response, y después pregúntale al servicio qué te
devolvió:

```js
> ticketService.getTickets().then(function (d) { console.log(typeof d, d); })
object []          // ← respuesta vacía: CHAOS=empty
string [{"id":1,"title":"La impresora no imp    // ← cuerpo roto: CHAOS=malformed
```

**Qué descarta.** Separa los dos casos que se ven idénticos en pantalla. Si es
un arreglo vacío, el sistema funcionó y no hay datos —o el mock te está mintiendo
con `empty`—, y tu vista no distingue "no hay tickets" de "no llegaron
tickets". Si `typeof` dice `string`, el cuerpo no era JSON válido: axios intenta
parsearlo, falla en silencio y te entrega el texto crudo, sin lanzar nada. El
`.catch` no corre, el error aparece más tarde y en otro sitio, con la forma
`tickets.filter is not a function`.

### Paso 5 — ¿y si el error existía y nadie lo vio?

Si nada de lo anterior encaja, queda el caso en el que el fallo se perdió por el
camino:

```js
// El sospechoso, en cualquier servicio o action:
.catch(function () { /* … */ })
```

**Qué descarta.** Descarta la red y apunta al código, que es el último lugar
donde había que mirar. Un `catch` vacío, o una action que no **devuelve** su
Promise, hacen que el error exista y no llegue a ninguna parte: la vista se
queda en el estado en que estaba, con el spinner encendido o con la lista vieja.
Es el mismo error de diseño que la fase enumera en sus errores comunes, y el que
la Fase 10 se vuelve a encontrar con Vuex de por medio.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Spinner infinito, request en `(pending)` | El servidor no contestó: `CHAOS=timeout`, o un handler colgado |
| Spinner infinito, request en `200` | Tu `.finally` no corre, o el `.catch` se comió el error |
| "No se pudieron cargar los tickets", `(failed)` en Network | Mock apagado, o CORS: mira la consola para desempatar |
| `curl` funciona y el navegador no | CORS, siempre. La consola es el único sitio que lo dice |
| Lista vacía, `200` con cuerpo `[]` | No distingue "sin datos" de "sin respuesta útil" |
| `tickets.filter is not a function` | El cuerpo no era JSON: `res.data` te llegó como string |
| Todo funciona pero lento y se crean cosas duplicadas | Falta estado de carga: el usuario hace clic tres veces |
| Editaste `db.json` a mano y tus cambios desaparecieron | json-server con `--watch` reescribió el archivo |
| El error de una petición no aparece por ningún lado | La action no devuelve la Promise, o hay `try/catch` sobre código asíncrono |
| Un 404 en `/tickets/999` que la vista no muestra | El error sí llegó: la vista no tiene caso para él |

---

## ⚰️ Los callejones

**"Es CORS."** Es la primera hipótesis de todo el mundo y casi siempre es falsa,
porque json-server permite CORS por defecto y la Fase 3 no lo toca. La evidencia
que la confirma o la tumba es una sola línea de la consola, y tarda cinco
segundos en mirarse. Cuando la confirmes, recuerda que **CORS no es un error de
tu código**: el servidor y el cliente están bien; falta una cabecera.

**"El backend está caído."** Puede ser, pero es indistinguible de otras dos
cosas desde el frontend, y decirlo sin `curl` es adivinar. Un `curl` te separa
"no hay servidor" de "hay servidor y algo pasa en el medio", y esa frase en un
ticket vale más que cualquier hipótesis.

**"Hay que subir el `timeout` de axios."** Al revés: sin `timeout` configurado,
axios espera **para siempre**, y ese es justamente el spinner eterno. Poner un
timeout no arregla el problema, pero convierte un cuelgue silencioso en un error
que tu `catch` puede contar — que es lo que te hacía falta para depurarlo.

---

## 🧨 Deshacer

Todo el recorrido se hace con el inyector de caos, así que se apaga solo:
`Ctrl+C` en la terminal del mock y `npm run mock` sin variable. Si además
ensuciaste los datos probando:

```bash
git checkout -- db.json     # recupera tus escenarios commiteados
npm run mock:reset          # o regenera desde db.seed.json, y se los lleva
```

La diferencia entre esos dos comandos está en
[la convención de git §🧹](../prompts/convencion-de-git-y-tags.md).

---

## 🧠 El patrón transferible

**Lo que tu `catch` puede contarte es mucho menos de lo que pasó.** En una
petición HTTP fallida hay al menos cuatro historias distintas —no salió, salió y
no volvió, volvió bloqueada, volvió rota— y el código del cliente colapsa todas
en un solo camino de error. Por eso el orden de esta ruta pone Network y `curl`
por delante del código: son las dos únicas herramientas que ven la diferencia.

Y el corolario que te vas a llevar a cualquier stack: **cuando el cliente y una
herramienta de línea de comandos no ven lo mismo, el problema está entre los dos,
no en ninguno de los dos.** Es el desempate más barato que existe, y casi nadie
lo hace primero.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 3](03-mock-api-minima.md), la tabla completa de fallos del inyector en su
sección 🔥, el índice de síntomas en [`forense-master.md`](forense-master.md), y
el caso completo en el [incidente 02](cuaderno-incidentes.md) del cuaderno.
EOF
wc -l forense-fase-03.md

# --- 2026-09-10T01:33:37 · Read phase 4 errors and outline
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
echo "### F4 errores"; sed -n '710,760p' 04-dashboard-tickets.md
echo "### F4 estructura"; grep -n '^## \|^### ' 04-dashboard-tickets.md

# --- 2026-09-10T01:33:41 · Read phase 4 view and search flow
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
sed -n '415,470p' 04-dashboard-tickets.md; echo "=== flujo busqueda ==="; sed -n '620,660p' 04-dashboard-tickets.md

# --- 2026-09-10T01:33:49 · Read phase 5 and 6 common errors
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
echo "### F5 errores"; sed -n '768,800p' 05-crud-tickets.md
echo "### F6 errores"; sed -n '817,850p' 06-wizard-minimo.md
echo "### F6 outline"; grep -n '^## ' 06-wizard-minimo.md | head -20

# --- 2026-09-10T01:34:57 · Write forensic piece for phase 4
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > forense-fase-04.md <<'EOF'
# 🕵️ Forense Fase 04 — "Cambié el filtro y la tabla se quedó igual" ⭐

> **Sale de:** [Fase 4 — Dashboard de tickets](04-dashboard-tickets.md) ·
> **Herramientas:** Vue DevTools → Components, Network (para descartarla) y
> `git log -S` · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el control cambia, el estado cambia, y lo que
> se pinta se quedó en la versión anterior.

Es una de las tres piezas estrella del curso, y la que más veces vas a
reencontrar en un legacy ajeno. El bug no es de Vue: es de **arquitectura de
estado**. Alguien guardó un dato derivado como si fuera un dato crudo, y a
partir de ahí el sistema tiene dos verdades que hay que sincronizar a mano —y
la mano se olvida.

---

## 🎫 El ticket

> "Pongo el filtro en 'Abiertos' y la tabla no cambia, sigue mostrando todo. Si
> además escribo algo en el buscador, ahí sí se actualiza y entonces el filtro
> de estado se aplica bien. O sea que funciona, pero hay que hacerle dos cosas
> para que haga una."
>
> — coordinadora de soporte · **Ambiente:** desarrollo

Ese "si además escribo algo, ahí sí" es el dato de oro del reporte: **un
control funciona y el otro no**, y los dos alimentan la misma tabla. Cuando dos
entradas al mismo cálculo se comportan distinto, el cálculo no es un cálculo:
es una copia que alguien actualiza a veces.

---

## 🧭 La ruta

De lo más barato a lo más caro: mirar el estado en DevTools cuesta un clic;
buscar quién lo escribe cuesta un `grep`; abrir el archivo es lo último.

### Paso 1 — ¿la tabla está recibiendo datos distintos?

Vue DevTools → **Components** → selecciona `<TicketsTable>` y mira sus props
antes y después de cambiar el `<select>` de estado.

```
props
  tickets: Array[8]      ← antes de filtrar
  tickets: Array[8]      ← después de elegir "Abiertos"
```

**Qué descarta.** Descarta a `TicketsTable` entera —el `v-for`, el `:key`, el
`v-if` del estado vacío— y descarta la plantilla del padre. El componente pinta
fielmente lo que le llega; lo que le llega no cambió. El problema está aguas
arriba, en quien produce esa prop.

### Paso 2 — ¿es un `computed` o es un `data`?

Con `<TicketsView>` seleccionado, mira el panel: DevTools separa `data` de
`computed` en dos secciones distintas, y ahí está el hallazgo.

```
data
  tickets: Array[8]
  search: ""
  statusFilter: "open"
  filteredTickets: Array[8]      ← ⚠️ esto no debería estar acá

computed
  (vacío)
```

**Qué descarta.** Descarta la reactividad de Vue: `statusFilter` **sí** cambió a
`"open"`, así que el `v-model` funcionó y el sistema reactivo hizo su trabajo.
Lo que no ocurrió es el recálculo, porque `filteredTickets` no se calcula: se
guarda. Un `computed` se marca sucio cuando cambia cualquier dependencia que
leyó; un `data` solo cambia si alguien le asigna.

### Paso 3 — ¿quién le asigna, y cuándo?

No abras todavía el componente: pregúntale a git quién toca esa variable.

```bash
git log --oneline -S "filteredTickets"
```

```
a3f9c21 f04 ej19: debounce en la búsqueda
7b2e5d4 f04: dashboard con filtros
```

Y en el archivo, solo la parte que asigna:

```bash
grep -n "filteredTickets" src/views/TicketsView.vue
```

```
42:      filteredTickets: [],
88:    search: function (value) {
93:        this.filteredTickets = this.tickets.filter(…);
```

**Qué descarta.** Cierra el caso: hay **un** watcher, y vigila **una** entrada.
`search` tiene quien lo escuche; `statusFilter` no. Por eso teclear en el
buscador "arregla" el filtro de estado: el watcher de `search` recalcula todo,
incluida la condición de estado que ya estaba puesta. El bug no es que el filtro
de estado no funcione, es que **nadie le avisa a la copia**.

### Paso 4 — ¿es filtrado de cliente o de servidor?

Antes de proponer un arreglo, mira Network mientras cambias el `<select>`.

```
(sin peticiones nuevas)
```

**Qué descarta.** Descarta el mock y el servicio: en esta fase el filtrado es
**en el cliente**, sobre el arreglo que ya está en memoria — la fase lo compara
con el filtrado en servidor en su sección ⚖️. Si hubieras visto un `GET
/tickets?status=open` en Network, la investigación se iría a otra parte
completamente: a los params del servicio.

### Paso 5 — ¿cuántas copias hay en total?

Con el patrón identificado, vale diez segundos preguntarse si es el único caso:

```bash
grep -rn "watch:" src/views src/components
```

```
src/views/TicketsView.vue:87:  watch: {
```

**Qué descarta.** Descarta —o confirma— que sea un incidente aislado. Un
proyecto con un watcher que sincroniza un derivado suele tener tres, y el
siguiente reporte va a ser el mismo síntoma con otro control. Acá termina el
recorrido: ya sabes **dónde** y **por qué**. El fix es de la fase: el derivado
vuelve a ser un `computed` y el watcher desaparece.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Cambias un filtro y la tabla no reacciona; otro filtro sí | Estado derivado en `data` con watchers parciales |
| La tabla se actualiza "con un cambio de retraso" | El watcher escribe antes de que la dependencia termine de cambiar |
| El contador "Mostrando X de Y" no coincide con las filas | Dos consumidores leyendo copias distintas del mismo derivado |
| Las filas conservan estado al reordenar o filtrar | `:key` ausente o puesto sobre el índice del `v-for` |
| Vue grita en consola que estás mutando una prop | El hijo escribe lo que debería emitir hacia arriba |
| Tabla vacía sin mensaje, que parece rota | Falta el estado vacío. No es un bug, y hay que demostrarlo |
| Al teclear se siente pesado con muchos tickets | El computed recalcula por tecla: es correcto, y pide debounce |
| Cambia la URL con los filtros pero no la tabla | Los query params se leen en `mounted` y nadie los vuelve a mirar |

---

## ⚰️ Los callejones

**"Falta el `:key` en el `v-for`."** Es el reflejo más común ante cualquier
problema de listas, y acá es falso: el `:key` decide **qué fila es cuál** cuando
la lista cambia, no **cuántas filas hay**. La evidencia que lo tumba está en el
paso 1: la prop llegó con la misma longitud. Si el problema fuera el `:key`,
verías el número correcto de filas con el contenido mezclado.

**"Es la reactividad de Vue 2, que no ve el cambio."** Tentador, porque la Fase 9
enseña que Vue 2 tiene puntos ciegos de verdad. Pero acá no aplica: el paso 2
muestra `statusFilter` con su valor nuevo, así que Vue vio el cambio
perfectamente. Vue no falló; falló la cadena que va del dato al derivado.

**"Le pongo un `this.$forceUpdate()` y sigue."** Funciona, y es la peor decisión
posible: repinta el componente con la copia vieja recalculada por casualidad, y
convierte un bug reproducible en uno intermitente. Cuando encuentres un
`$forceUpdate` en un proyecto ajeno, casi siempre estás mirando la cicatriz de
este mismo caso.

---

## 🧨 Deshacer

Si llegaste acá desde el ejercicio de "rompe a propósito" de la fase, o desde el
incidente 04:

```bash
git checkout -- src/views/TicketsView.vue
```

Y si prefieres verlo al revés —convertir el `computed` correcto en un `data` con
watcher para sentir el bug en carne propia—, hazlo en una rama:

```bash
git switch -c experimento/estado-duplicado
```

---

## 🧠 El patrón transferible

**Todo dato que se puede calcular y además se guarda es un bug esperando su
turno.** No importa el framework: en Vue se llama `computed` contra `data`, en
React `useMemo` contra `useState`, en un backend una vista materializada contra
una consulta — el problema es idéntico, y el síntoma también: dos verdades que
alguien tiene que sincronizar, hasta que se olvida de una entrada.

La pregunta que resuelve esta familia entera de bugs, y que conviene hacerse
antes de escribir el código: **¿este valor es un hecho o es una consecuencia?**
Los hechos se guardan. Las consecuencias se calculan, siempre, aunque cueste.

Y la señal para reconocerlo en un legacy ajeno, sin leer una línea: cuando un
control funciona y otro que alimenta lo mismo no, deja de buscar el bug del
control. Busca la copia.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 4](04-dashboard-tickets.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 04](cuaderno-incidentes.md); y el mismo patrón, con Vuex de por
medio y a mayor escala, en la [pieza de la Fase 10](forense-fase-10.md).
EOF
wc -l forense-fase-04.md

# --- 2026-09-10T01:35:03 · Outline phase 5 and find submit handling
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
grep -n '^### \|^## ' 05-crud-tickets.md | head -25; echo "=== submit ==="; grep -n "\$touch\|submit\|saving\|disabled" 05-crud-tickets.md | head -25

# --- 2026-09-10T01:35:09 · Read handleSubmit and vuelidate state table
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
sed -n '392,426p' 05-crud-tickets.md; sed -n '79,101p' 05-crud-tickets.md

# --- 2026-09-10T01:36:04 · Write forensic piece for phase 5
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > forense-fase-05.md <<'EOF'
# 🕵️ Forense Fase 05 — "Le di a guardar y no pasó nada"

> **Sale de:** [Fase 5 — CRUD de tickets](05-crud-tickets.md) ·
> **Herramientas:** la consola, Network, y Vue DevTools → Components ·
> **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el clic no produce ni request, ni error, ni
> mensaje — el formulario simplemente no hace nada.

El silencio es lo que hace difícil este caso, y el silencio tiene una causa
concreta: **el formulario ya decidió que no envía, y la decisión no se pinta en
ninguna parte.** Vuelidate sabe perfectamente qué campo está mal; el usuario no,
porque el sistema que muestra los errores depende de una condición que nadie
cumplió.

---

## 🎫 El ticket

> "Lleno el formulario de ticket nuevo, le doy a 'Crear ticket' y no pasa nada.
> No sale error, no se crea el ticket, no me lleva a ninguna parte. El botón
> hace clic, se ve que se hunde, pero de ahí no pasa. Ya probé en Chrome y en
> Edge."
>
> — agente de soporte · **Ambiente:** desarrollo

"No sale error" y "el botón se hunde" son las dos pistas. La segunda descarta
un botón deshabilitado; la primera dice que el sistema tomó una decisión en
silencio, que es exactamente lo que pasó.

---

## 🧭 La ruta

Los pasos van del más barato al más caro, y en este caso el primero es
literalmente gratis: mirar si hubo tráfico.

### Paso 1 — ¿salió algún request?

DevTools → **Network** → filtro `XHR` → clic en "Crear ticket".

```
(sin peticiones)
```

**Qué descarta.** Descarta la mitad del sistema de una vez: el servicio, el
`apiClient`, el interceptor, el mock, la red. Nada de eso llegó a intervenir. El
problema está **antes** del HTTP, en el propio componente. Si hubieras visto un
`POST /tickets` en rojo, ésta sería otra investigación completamente distinta —
la de la [Fase 3](forense-fase-03.md).

### Paso 2 — ¿el handler llegó a ejecutarse?

En la consola, sin tocar el código, con el componente del formulario
seleccionado en Vue DevTools (que lo expone como `$vm0`):

```js
> $vm0.$v.$invalid
true
> $vm0.$v.$dirty
false
```

**Qué descarta.** Descarta que el clic se haya perdido: el formulario **sí**
evaluó su estado y sabe que es inválido. Y descarta también la hipótesis de "el
`@submit.prevent` está mal puesto", porque si el evento no llegara, `$v` seguiría
en su estado inicial y no habría nada que contar. El código hizo su trabajo:

```js
handleSubmit: function () {
  this.$v.$touch();
  if (this.$v.$invalid) {
    return; // los errores ya se pintan solos vía $error
  }
  this.$emit("submit", Object.assign({}, this.form));
}
```

El `return` es correcto. Lo que hay que averiguar es por qué el usuario no ve
nada de eso.

### Paso 3 — ¿qué campo está mal, y por qué no se pinta?

Pregúntale a vuelidate campo por campo:

```js
> $vm0.$v.form.description.$invalid
true
> $vm0.$v.form.description.required
true
> $vm0.$v.form.description.minLength
false
> $vm0.$v.form.description.$error
false        // ← acá está el caso
```

**Qué descarta.** Cierra el diagnóstico. El campo `description` viola
`minLength(10)`, pero `$error` es `false`, y `$error` es lo que la plantilla
usa para pintar el mensaje. La razón está en su definición: **`$error` es
`$invalid && $dirty`**, y `$dirty` solo se pone en `true` cuando el usuario toca
el campo o alguien llama a `$touch()`. Si el `@blur` no está puesto en ese input
—o si el usuario llegó al botón sin pasar por el campo— el error existe y es
invisible.

### Paso 4 — el caso simétrico: el formulario en rojo desde el principio

Vale la pena mirarlo aunque no sea el reporte de hoy, porque es el mismo
mecanismo al revés y llega como ticket la semana siguiente. Si en la plantilla
aparece `$invalid` donde debería ir `$error`:

```
El formulario se pinta con todos los campos en rojo antes de escribir una letra.
```

**Qué descarta.** Descarta que sea "otro bug": es el mismo par de propiedades,
usado al revés. `$invalid` contesta *"¿esto viola una regla ahora?"* —y un
formulario vacío las viola todas—; `$error` contesta *"¿esto viola una regla y
el usuario ya tuvo su oportunidad?"*. La UI se construye sobre la segunda.

### Paso 5 — ¿y el ticket que sí se creó… dos veces?

Última rama del mismo formulario, y la más cara en datos. Si el reporte fue "se
me creó dos veces el mismo ticket":

```
Name      Status   Type   Size
tickets   201      xhr    412 B
tickets   201      xhr    412 B
```

**Qué descarta.** Descarta el mock —contestó dos veces porque le pidieron dos
veces— y apunta al botón: sin `:disabled="saving"`, un doble clic manda dos
POST. La fase lo trae resuelto con la prop `saving`, así que si lo ves en un
proyecto ajeno, la pregunta es quién quitó el binding, y `git log -S "saving"`
te lo dice.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Clic en guardar y nada, sin request en Network | El submit se cortó en `$v.$invalid`, y el error no se pinta |
| Todo en rojo antes de escribir | `$invalid` usado donde va `$error` |
| Un campo inválido sin mensaje visible | Falta `$touch()` en ese campo: `$dirty` sigue en `false` |
| Se crean dos tickets iguales de un clic | Botón sin `:disabled="saving"` |
| Tooltips del navegador peleando con tus mensajes | Falta `novalidate` en el `<form>` |
| Editas un ticket y se modifica también en la lista antes de guardar | Se mutó la prop en vez de clonarla a `form` |
| El formulario limpia los campos pero sigue en rojo | Se reseteó `form` sin `$v.$reset()` |
| El ticket se crea con `status` o `reporter` inventados por el navegador | Reglas de negocio en el formulario: 💸 deuda declarada, se paga con backend real |

---

## ⚰️ Los callejones

**"El evento no llega, será el `.prevent`."** Es la primera sospecha razonable y
se descarta en el paso 2: si el handler no corriera, `$dirty` no habría cambiado
nunca. Además, si `@submit.prevent` estuviera mal, verías la página recargarse
entera — un síntoma imposible de confundir.

**"Es el servicio, que no está devolviendo la Promise."** Ese bug existe y es
real, pero produce otro síntoma: request en Network y vista que no reacciona. Acá
no hubo request. Cuando el paso 1 sale vacío, todo lo que vive detrás del HTTP
queda descartado de un plumazo, y conviene decírselo a uno mismo en voz alta
para no seguir mirando ahí.

**"Vuelidate está mal configurado."** Casi nunca. La confusión `$error` /
`$invalid` no es un fallo de la librería sino de lectura: las dos propiedades
existen, las dos son correctas, y contestan preguntas distintas. Antes de
sospechar de la herramienta, mira su tabla de estado —está en la sección de
concepto de la fase— y decide cuál de las dos preguntas querías hacer.

---

## 🧨 Deshacer

Si probaste el paso 5 y te quedaron tickets duplicados en el mock:

```bash
git checkout -- db.json     # si tenías tus escenarios commiteados
npm run mock:reset          # o desde la semilla, y se lleva todo lo demás
```

---

## 🧠 El patrón transferible

**Un sistema que decide en silencio produce tickets sin información.** El
formulario sabía exactamente qué estaba mal, con nombre de campo y regla
violada, y esa información se quedó adentro porque la condición que la muestra
—"el usuario ya tuvo su oportunidad"— no se cumplió. El bug no está en la
validación: está en el puente entre lo que el sistema sabe y lo que el sistema
cuenta.

Cuando heredes un formulario ajeno, la pregunta rápida es siempre la misma:
**¿qué distingue "todavía no" de "está mal"?** Si el código no tiene esa
distinción escrita en alguna parte, o vas a molestar al usuario desde la primera
tecla, o vas a callarte cuando más falta hace.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 5](05-crud-tickets.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 05](cuaderno-incidentes.md); y la versión con tres pasos y estado
compartido en la [pieza de la Fase 6](forense-fase-06.md).
EOF
wc -l forense-fase-05.md

# --- 2026-09-10T01:36:11 · Read phase 6 wizard mechanics
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
grep -n "keep-alive\|activated\|\$refs\|draft\|currentStep\|beforeRouteLeave\|validate()" 06-wizard-minimo.md | head -30; echo "=== 52-76 concepto ==="; sed -n '52,76p' 06-wizard-minimo.md

# --- 2026-09-10T01:37:06 · Write forensic piece for phase 6
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > forense-fase-06.md <<'EOF'
# 🕵️ Forense Fase 06 — "Volví atrás en el wizard y perdí lo que había escrito"

> **Sale de:** [Fase 6 — Wizard mínimo](06-wizard-minimo.md) ·
> **Herramientas:** Vue DevTools → Components (el árbol y los hooks), y la
> consola · **Recorrido:** cuatro pasos
>
> **El síntoma, en una línea:** el paso al que vuelves aparece vacío, o
> parcialmente vacío, y nadie borró nada.

Acá el sistema no pierde datos: **destruye componentes**, que es otra cosa y se
diagnostica distinto. La investigación consiste en separar tres estados que el
usuario ve como uno solo — lo que está en el borrador, lo que está en el
formulario del paso, y lo que está en el estado de validación — y averiguar
cuál de los tres murió.

---

## 🎫 El ticket

> "Estoy creando un ticket con el asistente, lleno el paso 1, paso al 2, me doy
> cuenta de que me equivoqué en el título y le doy 'Atrás'. El título está,
> pero la descripción se me borró. Y los mensajitos rojos de error también
> desaparecieron, aunque el campo sigue mal."
>
> — agente de soporte · **Ambiente:** desarrollo

Ojo al detalle que casi nadie reporta: **una parte se conservó y otra no.** Eso
descarta de entrada "se perdió todo" y convierte el caso en una pregunta mucho
más precisa: ¿qué distingue lo que sobrevivió de lo que no?

---

## 🧭 La ruta

Del más barato al más caro: el árbol de componentes y sus hooks contestan casi
todo, y solo al final hace falta abrir el archivo.

### Paso 1 — ¿el componente del paso sigue vivo, o vuelve a nacer?

Vue DevTools → **Components**. Avanza al paso 2, vuelve al paso 1, y mira el
árbol mientras lo haces.

```
<TicketWizardView>
  └─ <TicketStepBasics>      ← desaparece del árbol al avanzar
```

Para confirmarlo sin depender del ojo, la fase ya trae el experimento hecho
—es su ejercicio 5—: pon un `console.log` en `created` del paso 1 y navega
adelante y atrás.

```
[paso 1] created
[paso 1] created      ← al volver: nació otra vez
```

**Qué descarta.** Descarta que alguien esté limpiando datos. Nadie borró la
descripción: el componente que la contenía dejó de existir y volvió a nacer
vacío. Si en vez de un segundo `created` vieras un `activated`, el componente
estaría vivo y el caso sería otro — salta al paso 3.

### Paso 2 — ¿por qué se destruye?

Mira la plantilla del wizard, solo esa línea:

```bash
grep -n "component :is\|keep-alive" src/views/TicketWizardView.vue
```

```
84:      <component :is="currentStepComponent" ref="stepComponent" />
```

**Qué descarta.** Cierra la primera mitad del caso. `<component :is>` **destruye
y monta** por diseño: es su contrato. `keep-alive` es lo que lo convierte en
"esconder y mostrar", y acá no está. Sin él, cada avance es una muerte y cada
retroceso, un nacimiento.

### Paso 3 — entonces, ¿por qué el título sí sobrevivió?

Con el paso 1 en pantalla, compara sus datos con los del padre:

```
<TicketWizardView>
  data
    draft: { title: "La impresora no imprime", description: "", priority: "" }

  <TicketStepBasics>
    data
      form: { title: "La impresora no imprime", description: "" }
```

**Qué descarta.** Descarta la teoría de "se pierde todo al volver" y explica el
reporte tal cual: el paso **entrega** sus datos al borrador del padre cuando
avanzas, y al volver a nacer se inicializa leyendo ese borrador. Lo que llegó al
`draft` sobrevive; lo que se quedó a medio escribir en el paso, no. Por eso
sobrevivió el título —validado y entregado— y no la descripción.

### Paso 4 — ¿y los mensajes de error?

Última pregunta del ticket, y la que más despista:

```js
> $vm0.$v.$dirty
false
```

**Qué descarta.** Descarta cualquier problema con vuelidate. El estado de
validación —`$dirty`, `$error`, el `$touch()` que ya habías provocado— vive
**dentro** del componente, no en el borrador. Un componente nuevo trae un `$v`
nuevo, virgen, sin memoria de que alguien tocó nada. El campo sigue siendo
inválido, pero volvió a ser "todavía no lo tocaste", que es exactamente lo que
la [Fase 5](forense-fase-05.md) enseñó a distinguir.

Acá termina el recorrido: sabes qué se destruye, por qué, y qué parte de lo
perdido vive en cada sitio. El fix es de la fase (`keep-alive`, y el hook pasa a
ser `activated`).

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Vuelves atrás y el paso está vacío | Falta `keep-alive`: el componente se destruyó y nació de nuevo |
| Vuelves atrás y sobrevive parte de lo escrito | Lo que llegó al `draft` vive; lo que se quedó en el paso, no |
| Los errores de validación desaparecen al volver | `$v` es del componente: nace virgen con él |
| Pusiste `keep-alive` y ahora los datos no se refrescan | `created`/`mounted` ya no se repiten: el hook que buscas es `activated` |
| Te deja avanzar con el paso 2 vacío | La validación corre al final, no por paso: `validate()` no se está invocando al avanzar |
| No te deja volver atrás con el paso inválido | Se está validando también hacia atrás: retroceder nunca debería exigir validez |
| Sales del wizard y te pregunta si quieres abandonar, después de crear el ticket | Falta apagar el `beforeRouteLeave` en el camino del éxito |
| Recargas con F5 y pierdes todo | Es el diseño: el borrador vive en el componente, no en `sessionStorage` |

---

## ⚰️ Los callejones

**"Se borró el borrador."** El `draft` del padre no se toca nunca en este flujo:
el paso 3 lo muestra intacto. Cuando un dato "se borra" al navegar dentro de la
misma vista, sospecha del ciclo de vida antes que de una asignación — es mucho
más frecuente que alguien destruya un componente sin querer que alguien escriba
`draft = {}`.

**"Es que `$refs` no está funcionando."** `$refs.stepComponent` apunta al
componente vivo, y cuando el paso se remonta apunta al nuevo. Funciona
perfectamente; lo que cambió es a quién apunta. Si sospechas de `$refs`,
compruébalo en la consola antes de tocar nada: es una línea.

**"Hay que meter el borrador en Vuex."** Es la respuesta correcta a **otro**
problema —pasos en rutas distintas, o "retomar donde quedé"— y la fase lo
explica en su tabla de decisión. Para este síntoma no arregla nada: el estado de
validación seguiría muriendo con el componente, porque `$v` nunca estuvo en el
borrador.

---

## 🧨 Deshacer

Si quitaste el `keep-alive` para reproducir —el ejercicio 6 lo pide—, vuelve con:

```bash
git checkout -- src/views/TicketWizardView.vue
```

Y si dejaste `console.log` en los hooks para el paso 1, bórralos antes de
commitear: el ruido en consola de mañana es el bug fantasma de pasado mañana.

---

## 🧠 El patrón transferible

**El estado de un formulario no es una cosa: son tres**, y viven en sitios
distintos con vidas distintas. Los datos entregados (el borrador), los datos en
edición (el `form` del paso), y el estado de la interacción (qué tocó el
usuario, qué se le mostró). Cuando algo "se pierde", la pregunta útil no es
"¿quién lo borró?" sino **"¿en cuál de los tres vivía, y quién es dueño de esa
vida?"**.

Y una regla que se transfiere a cualquier framework con componentes: **montar y
desmontar no es lo mismo que mostrar y ocultar**, aunque en pantalla se vean
idénticos. Cada vez que veas un intercambio dinámico de componentes, pregúntate
qué muere con ellos — porque algo siempre muere, y el usuario lo va a notar
antes que tú.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 6](06-wizard-minimo.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); y el caso completo en el
[incidente 06](cuaderno-incidentes.md) del cuaderno.
EOF
wc -l forense-fase-06.md

# --- 2026-09-10T01:37:12 · Read phase 7 chart lifecycle
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
grep -n '^### \|^## ' 07-metricas-minimas.md | head -20; sed -n '60,150p' 07-metricas-minimas.md

# --- 2026-09-10T01:38:11 · Write forensic piece for phase 7
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > forense-fase-07.md <<'EOF'
# 🕵️ Forense Fase 07 — "La pestaña se va poniendo lenta y el ventilador se dispara"

> **Sale de:** [Fase 7 — Métricas mínimas](07-metricas-minimas.md) ·
> **Herramientas:** Performance y Memory de Chrome, Vue DevTools, y la consola
> · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** la aplicación funciona bien y se degrada con el
> uso, sin ningún error en ninguna parte.

Ésta es la primera investigación del curso que **no tiene un momento de fallo**.
No hay un clic que rompa nada, no hay una petición en rojo, no hay excepción: hay
una aplicación que a los diez minutos va peor que a los dos. Los bugs de
degradación se diagnostican al revés que los demás — no se busca qué se rompió,
se busca **qué se acumula**.

---

## 🎫 El ticket

> "El sistema arranca bien pero se va poniendo lento. Sobre todo si entro a la
> pantalla de métricas y salgo varias veces, después todo va pesado y a la
> laptop se le prende el ventilador. Cerrando la pestaña y abriendo de nuevo se
> arregla. No sale ningún error."
>
> — coordinadora de soporte · **Ambiente:** desarrollo y UAT

"Cerrando la pestaña se arregla" es la firma del caso: lo que sea que esté mal,
vive en la memoria del navegador y sobrevive a la navegación interna.

---

## 🧭 La ruta

Del más barato al más caro, y acá la escala es real: los dos primeros pasos son
gratis, el tercero cuesta un minuto, y el cuarto —el profiler de memoria— es la
herramienta más cara de esta fase. Casi nunca hace falta llegar a ella.

### Paso 1 — ¿el síntoma es acumulativo?

Antes de medir nada, delimita. Entra y sal de `/metrics` cinco veces y mira la
consola.

```
Uncaught Error: Canvas is already in use. Chart with ID '0' must be destroyed
before the canvas with ID 'statusChart' can be reused.
```

**Qué descarta.** Si ese error aparece, la investigación prácticamente terminó
en el primer paso: alguien está creando un chart nuevo sobre un canvas que
todavía cree tener uno vivo. Es la forma **ruidosa** del problema, y hay que
agradecerla. Si la consola está limpia y la lentitud igual crece, sigue al
paso 2: estás ante la forma silenciosa, que es la que trae el ticket de hoy.

### Paso 2 — ¿qué componente lo dispara?

Vue DevTools → **Components**, y navega adentro y afuera de `/metrics`.

```
<MetricsView>
  ├─ <MetricCard>
  ├─ <StatusDoughnut>
  └─ <AgentBarChart>
```

Con el componente del gráfico seleccionado, mira sus datos:

```
data
  chart: { canvas: canvas#statusChart, ctx: CanvasRenderingContext2D, config: {…},
           data: { datasets: Array[1], labels: Array[4] }, … }
```

**Qué descarta.** Descarta las otras vistas y, sobre todo, te da el hallazgo casi
completo. Que la instancia de chart.js **aparezca en el panel de datos** de
DevTools significa que está dentro de `data`, y por lo tanto que Vue la está
observando recursivamente: un objeto enorme, con referencias circulares al
canvas y a sus datasets internos, envuelto entero en getters y setters. Eso solo
ya explica la lentitud, y la fase lo advierte antes de escribir el componente.

### Paso 3 — ¿se destruyen los gráficos al salir?

Sin abrir el archivo, pregúntaselo al ciclo de vida:

```js
> // en la consola, con el componente montado:
> $vm0.$options.beforeDestroy
undefined
```

**Qué descarta.** Confirma la segunda mitad. Si no hay `beforeDestroy`, nadie
llama a `chart.destroy()`, y cada visita a la vista deja un gráfico zombi: sus
listeners de resize siguen atados a `window`, sus animaciones siguen agendadas y
su canvas sigue referenciado, así que el recolector de basura no puede llevarse
nada. **Ese es el ventilador.** Cinco visitas, cinco charts vivos, cinco veces
el trabajo por cada repintado.

### Paso 4 — medirlo, para poder contarlo

Ahora sí, la herramienta cara, y solo para tener el número que convence a
alguien más. DevTools → **Memory** → *Heap snapshot*: uno recién cargada la
aplicación, después entra y sal de `/metrics` cinco veces, y toma otro.

```
Snapshot 1     12.4 MB     Chart ×0
Snapshot 2     41.7 MB     Chart ×5      ← ninguno se fue
```

**Qué descarta.** Descarta cualquier duda sobre si "son imaginaciones": el
contador de instancias vivas de `Chart` no discute. Si en el snapshot 2 los
gráficos hubieran desaparecido, la lentitud vendría de otro sitio y habría que
mirar el paso 5.

### Paso 5 — ¿y si no es el chart?

Dos causas menores producen síntomas parecidos y conviene descartarlas antes de
cerrar:

```
El gráfico mide 30.000 píxeles de alto, o no se ve.
```

Eso no es un leak: es un `<canvas>` con `responsive: true` dentro de un
contenedor sin dimensiones, peleándose consigo mismo en cada repintado. Y el
otro:

```js
> $vm0.$refs.canvas
undefined
```

Si eso pasa en `created`, es que se intentó crear el gráfico antes de que
existiera el DOM. No degrada nada; simplemente no funciona. El hook correcto es
`mounted`, y la fase lo pone en su tabla de tres tablones.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| La pestaña se degrada con el uso, sin errores | Instancias de librería que nadie destruye |
| `Canvas is already in use` al volver a la vista | Falta `chart.destroy()` en `beforeDestroy` |
| Todo va lento apenas se pinta el primer gráfico | La instancia está en `data`: reactividad recursiva sobre un objeto enorme |
| El gráfico no se ve, o mide una barbaridad de alto | Canvas dentro de un contenedor sin dimensiones, con `responsive: true` |
| `this.$refs.canvas` es `undefined` | Se pidió en `created`: todavía no hay DOM |
| El gráfico no se actualiza cuando cambian los datos | Falta el `watch` sobre la prop, o falta `chart.update()` |
| Cambian los datos y el gráfico parpadea entero | Se está recreando el chart en vez de actualizarlo |
| El componente está dentro de `keep-alive` y el leak persiste | `beforeDestroy` no corre: los hooks son `activated`/`deactivated` |
| Un `setInterval` de refresco sigue vivo después de salir | Lo mismo que el chart, con otro disfraz: falta `clearInterval` |

---

## ⚰️ Los callejones

**"Son demasiados tickets, hay que paginar."** Es la hipótesis que todo el mundo
propone ante "va lento", y acá es falsa: el volumen de datos de esta fase son
decenas de tickets, y el snapshot del paso 4 muestra que lo que crece son
instancias de `Chart`, no filas. Cuando alguien diga "es el volumen", pide el
número: si el sistema va peor con **los mismos datos** que hace diez minutos, el
volumen no es la causa.

**"Es chart.js, que es pesado."** chart.js hace lo que se le pide y se va cuando
se le dice que se vaya. La librería no tiene forma de saber que tu componente
murió; ese aviso es tuyo, y tiene nombre: `destroy()`. Culpar a la librería acá
es no ver el patrón, que es lo único que se transfiere a Leaflet, FullCalendar o
cualquier otra.

**"Le pongo `Object.freeze` y listo."** `Object.freeze` sí resuelve la
reactividad recursiva de un objeto de datos —la fase lo enseña como escape— pero
no resuelve el leak: un chart congelado que nadie destruye sigue vivo, sigue
escuchando `resize` y sigue consumiendo. Son dos problemas, y arreglar uno deja
el ventilador encendido.

---

## 🧨 Deshacer

El paso 3 y el ejercicio 6 de la fase invitan a comentar el `beforeDestroy` para
ver el leak en carne propia. Para volver:

```bash
git checkout -- src/components/metrics/
```

Y recarga la pestaña con `Ctrl+Shift+R`: los gráficos zombi viven en la memoria
del navegador, no en tu código, así que un `git checkout` no se los lleva.

---

## 🧠 El patrón transferible

**Todo lo que se crea en `mounted` y vive fuera de Vue, se destruye en
`beforeDestroy`.** Es la regla de la fase, y el track forense la reformula como
método: cuando un sistema se degrada con el uso, no busques qué se rompe — busca
**qué se crea y no se destruye**. Charts, mapas, editores, `setInterval`,
listeners de `window`, suscripciones a un socket (que es la Fase 8, con este
mismo patrón puesto sobre otra librería).

Y la lección que va con ella, más incómoda: **un framework declarativo no puede
limpiar lo que no sabe que existe.** Cada vez que metas una librería imperativa
dentro de un componente estás firmando un contrato de tres tablones —crear,
actualizar, destruir— y el tercero es el único que nadie prueba, porque su
ausencia no se nota el primer día.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 7](07-metricas-minimas.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 07](cuaderno-incidentes.md); y el mismo contrato aplicado a sockets
en la [pieza de la Fase 8](forense-fase-08.md).
EOF
wc -l forense-fase-07.md

# --- 2026-09-10T01:38:18 · Read phase 8 sockets
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
grep -n '^## \|^### ' 08-websockets-minimos.md; echo "=== deuda 231 ==="; sed -n '200,260p' 08-websockets-minimos.md; echo "=== errores ==="; sed -n '626,660p' 08-websockets-minimos.md

# --- 2026-09-10T01:38:28 · Check take-ticket in phase 9 and listener in phase 8
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
grep -n "takeTicket\|tomar\|assignee" 09-panel-soporte.md | head -20; echo "=== 480-520 F8 dashboard escucha ==="; sed -n '480,520p' 08-websockets-minimos.md

# --- 2026-09-10T01:39:33 · Write forensic piece for phase 8
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > forense-fase-08.md <<'EOF'
# 🕵️ Forense Fase 08 — "Tomé el ticket y a mi compañero le sigue apareciendo libre" ⭐

> **Sale de:** [Fase 8 — WebSockets mínimos](08-websockets-minimos.md) ·
> **Herramientas:** Network → **WS**, dos navegadores, la consola del servidor
> de sockets · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** una pantalla se enteró y la otra no, y las dos
> creen tener la verdad.

Es la pieza estrella del curso, y no por dificultad técnica: es la única donde
el recorrido termina **encontrando una deuda 💸 que el material te había
declarado cien líneas antes**, y que probablemente leíste sin entender del todo.
Descubrirla depurando es otra cosa que leerla.

---

## 🎫 El ticket

> "Tomé el ticket #0412 hace como cinco minutos y aparece asignado a mí,
> perfecto. Pero Ana me dice que en su pantalla el ticket sigue apareciendo sin
> asignar, en la cola de pendientes. Ella no lo ha refrescado. Los tickets
> nuevos sí le aparecen solos, eso funciona bien, es cuando uno los toma que no
> se entera."
>
> — agente de soporte · **Ambiente:** desarrollo y UAT

El reporte trae el experimento de control ya hecho, y hay que aprovecharlo: **la
creación sí se propaga y la asignación no.** Eso descarta de entrada la conexión,
el servidor y la librería — si nada llegara, tampoco llegarían los tickets
nuevos.

---

## 🧭 La ruta

Del más barato al más caro: recargar la otra pestaña cuesta un segundo, mirar
los frames del socket cuesta un clic, y solo al final hace falta abrir código.

### Paso 1 — ¿es que no se propagó, o es que no se pintó?

En el navegador de Ana, sin tocar nada más, recarga con F5.

```
El ticket aparece asignado, en la cola correcta.
```

**Qué descarta.** Es el desempate más barato del track y separa dos
investigaciones completamente distintas. El dato **sí** está guardado: el PATCH
llegó a json-server y la lectura fresca lo confirma. Lo que falló es la
propagación en vivo, no la escritura. Si tras recargar el ticket siguiera libre,
esta pieza no aplicaría y habría que ir a mirar el PATCH — que es la
[Fase 9](forense-fase-09.md).

### Paso 2 — ¿pasó algo por el socket?

En el navegador que **tomó** el ticket: DevTools → Network → filtro **WS** →
selecciona la conexión a `localhost:4000` → pestaña **Messages**. Repite la
operación de tomar.

```
↑ 42["ticket:created",{…}]     ← al crear un ticket, hace un rato
(nada nuevo al tomar)
```

**Qué descarta.** Acá está el hallazgo, y llegó sin abrir un archivo: **no se
emitió nada**. No es que el evento se haya perdido, ni que Ana no lo haya
recibido: nadie lo mandó. Descarta el servidor de sockets, la red y el cliente
de Ana de una sola vez.

> ⚠️ Si la pestaña **WS** está vacía del todo, tu problema es otro y anterior:
> el socket no conectó. Mira el indicador del header y la consola del servidor.

### Paso 3 — ¿quién emite, y qué emite?

Ahora sí, pero a la consola del servidor de sockets, que es más barata que el
código:

```
🟢 cliente conectado: k3Jd…
📨 ticket:created → 47 Impresora de la sala 2
🟢 cliente conectado: p9Za…
```

Un solo tipo de evento en todo el log. Y en el cliente:

```bash
grep -rn "socketService.emit\|socketService.on" src/
```

```
src/views/TicketCreateView.vue:64:      socketService.emit("ticket:created", created);
src/views/TicketWizardView.vue:212:     socketService.emit("ticket:created", created);
src/views/TicketsView.vue:38:          socketService.on("ticket:created", this.onCreatedHandler);
```

**Qué descarta.** Cierra el caso técnico: el sistema tiene **un** evento,
`ticket:created`, y lo emite quien crea. Tomar un ticket es un PATCH, y ningún
PATCH del proyecto anuncia nada. No hay bug: hay una funcionalidad que nadie
escribió, y un sistema en vivo que solo está vivo a medias.

### Paso 4 — la pregunta incómoda: ¿y quién debería emitirlo?

Mira **dónde** está ese `emit` del paso 3. No está en el servidor: está en el
componente del navegador que acaba de hacer el POST.

```js
.then(function (created) {
  socketService.emit("ticket:created", created); // 📣 anunciar a los demás
  self.$router.push("/tickets/" + created.id);
})
```

**Qué descarta.** Descarta la idea de que agregar `ticket:updated` en el mismo
sitio sea "el arreglo". Lo sería para el síntoma, y duplicaría el problema de
fondo: **el que anuncia no es el que persiste.** Es la deuda 💸 declarada en la
fase —*el cliente mentiroso*—, y la fase la acepta a propósito porque su
servidor es un relé de veinte líneas que solo rebota. Sus consecuencias son
comprobables hoy, en el paso 5.

### Paso 5 — comprobar por qué eso importa

En la consola del navegador, con la aplicación abierta:

```js
> socketService.emit("ticket:created", { id: 999, title: "No existe", status: "open" })
```

Mira la otra pestaña.

```
Toast: "Nuevo ticket #999 — No existe"
```

**Qué descarta.** Descarta cualquier duda sobre la gravedad de la deuda. Ese
ticket **no existe en ninguna base**: lo inventó un cliente y todos los demás lo
creyeron, porque el sistema no tiene forma de distinguir un anuncio legítimo de
uno falso. El servidor rebota lo que le llega, tal cual, y el ejercicio 24 de la
fase te hace repetir esto a propósito.

Acá termina el recorrido. La deuda es correcta **hoy** —con un relé tonto no hay
alternativa mejor— y su pago vive fuera de este curso: el día que exista un
backend de verdad, quien confirma la escritura es quien anuncia, y el cliente
pasa a ser solo oyente.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Un cambio no llega a la otra pantalla, y F5 lo muestra | No se emitió: mira la pestaña WS antes que el código |
| Nada llega nunca, ni siquiera los tickets nuevos | El socket no conectó: indicador del header y consola del server |
| El evento llega y se aplica dos, tres veces | Listeners sin `off`, o `.bind(this)` distinto en el alta y en la baja |
| El evento llega y la lista no cambia | El handler escribe en el sitio equivocado, o reemplaza el arreglo entero |
| El socket conecta y no llega nada, con errores raros | Cliente y servidor de socket.io desparejados (2.x contra 3.x/4.x) |
| Aparece un ticket que no existe en `db.json` | El anuncio lo emite un cliente: 💸 el cliente mentiroso |
| Cada vez que entras a la vista se abre otra conexión | Se conecta en `mounted` de la vista en vez de una vez por sesión |
| El toast aparece en la pestaña de quien creó el ticket | `socket.broadcast.emit` cambiado por `io.emit` en el servidor |
| Al recargar, el estado en vivo se pierde y no vuelve | El socket repuebla, no reconstruye: el estado se carga por HTTP |

---

## ⚰️ Los callejones

**"Se desconectó el socket."** Es la sospecha inmediata y la pestaña WS la
tumba en un segundo: la conexión está abierta —hay frames de heartbeat— y los
tickets nuevos siguen llegando. Cuando alguien diga "se cayó el socket", pide la
pestaña Messages: una conexión viva se ve, no se argumenta.

**"El PATCH no se guardó."** El paso 1 lo descarta antes de empezar. Este orden
importa: si hubieras empezado por el PATCH habrías pasado veinte minutos en
Network mirando un request perfectamente correcto.

**"Hay que agregar `ticket:updated` y listo."** Arregla el síntoma de hoy y
consolida el error de diseño: un segundo evento emitido por el cliente es un
segundo sitio donde cualquiera puede mentir. Merece decirse en el ticket, no
solo en el código — es la diferencia entre cerrar un caso y entenderlo.

**"Es la caché del navegador de Ana."** No hay caché en juego: los datos llegaron
por XHR sin cabeceras de caché y el socket no cachea nada. Es la hipótesis
comodín cuando dos pantallas no coinciden, y casi nunca es cierta en una SPA.

---

## 🧨 Deshacer

El paso 5 deja un toast falso en la otra pestaña, nada más: no se escribió en
`db.json`. Recarga y desaparece. Si además comentaste el `off` para ver los
handlers zombis (ejercicio 6 de la fase):

```bash
git checkout -- src/views/TicketsView.vue
```

Y recarga las dos pestañas: los listeners duplicados viven en la memoria del
navegador, no en tu código.

---

## 🧠 El patrón transferible

**En un sistema en vivo hay dos preguntas, y confundirlas cuesta horas: ¿se
emitió? y ¿se aplicó?** La primera se contesta en el emisor, la segunda en el
receptor, y hay una tercera —¿se persistió?— que no tiene nada que ver con las
otras dos. El F5 del paso 1 es el desempate más barato que existe entre "el dato
no está" y "el dato está y no viajó".

Y la lección que de verdad se transfiere: **pregúntate siempre quién tiene
autoridad para anunciar un hecho.** Si el que anuncia no es el que lo hizo
cierto, tienes un sistema donde el aviso y la verdad pueden separarse — y se van
a separar. Es la misma discusión que en tu backend de siempre separaba el
commit de la publicación del evento, y acá se ve con dos navegadores abiertos.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 8](08-websockets-minimos.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); los casos completos en los
[incidentes 08 y 09](cuaderno-incidentes.md); y el ciclo de vida de las
suscripciones, que es el mismo contrato de la
[pieza de la Fase 7](forense-fase-07.md) con otra librería encima.
EOF
wc -l forense-fase-08.md

# --- 2026-09-10T01:39:39 · Read phase 9 selection and update flow
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
grep -n "selectedId\|selectedTicket\|onTicketUpdated\|:key" 09-panel-soporte.md | head -20; sed -n '940,985p' 09-panel-soporte.md

# --- 2026-09-10T01:40:37 · Write forensic piece for phase 9
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > forense-fase-09.md <<'EOF'
# 🕵️ Forense Fase 09 — "Cambié el estado y el detalle no se enteró"

> **Sale de:** [Fase 9 — Panel de soporte](09-panel-soporte.md) ·
> **Herramientas:** Vue DevTools → Components, Network, y la consola ·
> **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el PATCH salió bien, la lista se actualizó, y
> el panel de al lado sigue mostrando lo de antes.

La Fase 9 pone dos vistas del mismo dato en la misma pantalla —la cola y el
workspace— y ahí es donde los bugs de identidad dejan de ser teóricos. Todos los
casos de esta pieza son variantes de una sola pregunta: **¿los dos paneles están
mirando el mismo objeto, o cada uno tiene el suyo?**

---

## 🎫 El ticket

> "Estoy en el panel de soporte, selecciono un ticket de la cola, le cambio el
> estado a 'Resuelto' y el ticket de la lista de la izquierda cambia bien. Pero
> el panel de la derecha, el grande, sigue diciendo 'En progreso'. Si selecciono
> otro ticket y vuelvo, ahí sí aparece bien."
>
> — agente de soporte · **Ambiente:** desarrollo

"Si selecciono otro y vuelvo, ahí sí" es la firma de una copia obsoleta: el dato
correcto existe en alguna parte, y el panel lo lee **solo cuando vuelve a
nacer**.

---

## 🧭 La ruta

Del más barato al más caro: Network descarta la escritura, DevTools compara las
dos copias, y el código es lo último.

### Paso 1 — ¿la escritura llegó?

DevTools → **Network** → filtro `XHR`, y cambia el estado.

```
Name         Status   Type   Size
tickets/12   200      xhr    486 B
```

Y en la pestaña Response:

```json
{ "id": 12, "title": "No me llega el correo", "status": "resolved",
  "assignee": "soporte1", … }
```

**Qué descarta.** Descarta el servicio, el mock y la escritura entera: el
servidor recibió el PATCH, lo aplicó y devolvió el ticket completo con
`status: "resolved"`. Todo lo que sigue pasa **dentro** del navegador. Si el
status hubiera sido 404 o el cuerpo hubiera venido a medias, ésta sería otra
investigación.

### Paso 2 — ¿quién tiene qué?

Vue DevTools → Components. Compara las tres copias que hay en pantalla:

```
<SupportView>
  data
    tickets: Array[8]              → tickets[3].status: "resolved"   ✅
    selectedTicket: { id: 12, status: "in_progress" }   ⚠️ objeto viejo

  <TicketQueue>   props.tickets[3].status: "resolved"   ✅
  <TicketWorkspace>  props.ticket.status: "in_progress" ⚠️
```

**Qué descarta.** Ahí está el caso, y no hizo falta abrir un archivo. La lista
maestra se actualizó; `selectedTicket` no. Descarta la reactividad como culpable
—la cola se enteró perfectamente— y descarta el `:key`, que en esta fase se usa
para recrear el workspace al cambiar de ticket, no para actualizarlo.

### Paso 3 — ¿es una copia o es una referencia?

La pregunta que decide el diagnóstico. En la consola:

```js
> $vm0.selectedTicket === $vm0.tickets[3]
false
```

**Qué descarta.** Cierra el caso. `selectedTicket` es un **objeto guardado**, no
una referencia viva a la lista: cuando el update reemplazó el elemento del
arreglo —`splice(i, 1, updated)`, que sí es reactivo— la lista pasó a apuntar a
un objeto nuevo, y `selectedTicket` se quedó apuntando al viejo. La fase lo dice
en sus errores comunes con todas las letras: **se guardó el objeto en vez del
id.** Con un `selectedId` y un computed que lo busque en la lista, esto no puede
pasar: hay una sola fuente y N lectores.

Si la comparación hubiera dado `true`, el problema sería otro —una mutación que
Vue no ve— y saltarías al paso 5.

### Paso 4 — el caso vecino: el workspace con datos ajenos

Otro reporte de la misma pantalla, misma familia:

```
"Al cambiar de ticket veo medio segundo los comentarios del anterior, y a veces
el textarea trae texto que yo no escribí ahí."
```

Compruébalo en DevTools mirando si el componente se recrea o se reutiliza al
cambiar de selección:

```
<TicketWorkspace>   ← la misma instancia, con la prop nueva
```

**Qué descarta.** Descarta los comentarios, el servicio y el `v-model`: el
componente **no nació de nuevo**, así que su estado local —comentarios cargados,
borrador del textarea— sobrevivió al cambio de ticket. Es lo contrario del bug
de la [Fase 6](forense-fase-06.md): allá el componente moría cuando no debía,
acá sobrevive cuando debía morir. La herramienta es la misma, `:key`, usada al
revés: `:key="selectedTicket.id"` fuerza una instancia nueva por ticket.

### Paso 5 — el silencio reactivo

Última variante, y la más muda de todas. Si el handler del update hiciera esto:

```js
onTicketUpdated: function (updated) {
  var i = this.tickets.findIndex(function (t) { return t.id === updated.id; });
  this.tickets[i] = updated;    // ⚠️ ni un error, ni un repintado
}
```

```
La lista no cambia. La consola está limpia. Network dice 200.
```

**Qué descarta.** Descarta absolutamente todo lo anterior y apunta a la
limitación de Vue 2 que la Fase 8 ya había advertido: **la asignación por índice
en un arreglo no es reactiva.** El dato está en el arreglo —compruébalo en
DevTools, ahí se ve— y nadie repinta. Se arregla con `splice`, que es uno de los
métodos parcheados, o con `Vue.set`.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| La lista se actualiza y el detalle no | `selectedTicket` guarda el objeto en vez del id |
| El detalle se actualiza al cambiar de ticket y volver | Confirma lo anterior: solo se refresca al recrearse |
| Ves medio segundo datos del ticket anterior | Falta `:key`: instancia reutilizada sin reset |
| El textarea trae texto de otro ticket | Lo mismo: estado local que sobrevivió al cambio de selección |
| Asignaste por índice y no pasó nada | Vue 2 no ve `array[i] = x`: usa `splice` o `Vue.set` |
| Vue grita que estás mutando una prop | El workspace escribe el ticket en vez de emitir hacia arriba |
| "Tomar" deja el ticket asignado pero en estado viejo | Dos PATCH encadenados en vez de uno: si van juntos, viajan juntos |
| Dos agentes toman el mismo ticket y ninguno se entera | No hay candado ni precondición: 💸 deuda, hace falta un backend |
| El ticket cambia de sección de la cola "solo" | No es un bug: es la cadena reactiva de los computed haciendo su trabajo |

---

## ⚰️ Los callejones

**"Falta recargar la lista después del PATCH."** Funciona, y es exactamente lo
que no hay que hacer: un `loadData()` después de cada escritura esconde el bug
de identidad detrás de un viaje a la red, y convierte una pantalla reactiva en
una pantalla que parpadea. Cuando veas ese reflejo en un legacy ajeno,
pregúntate qué estaba mal de verdad — casi siempre es esta pieza.

**"Es que json-server devuelve mal el PATCH."** El paso 1 lo descarta con el
cuerpo de la respuesta a la vista. Cuesta diez segundos y evita media hora de
sospechas sobre el mock, que en este proyecto casi nunca tiene la culpa porque
casi no hace nada.

**"Hay que meter el ticket seleccionado en Vuex."** No arregla nada por sí solo:
si en Vuex guardas otra vez el **objeto**, tienes el mismo bug con más
ceremonia. El problema no es dónde vive la selección, es **qué guardas**: el id
o la cosa.

---

## 🧨 Deshacer

Si reprodujiste el paso 5 a propósito:

```bash
git checkout -- src/views/SupportView.vue
```

Y si probaste tomando tickets, el `db.json` quedó con asignaciones nuevas:
`git checkout -- db.json` recupera tus escenarios; `npm run mock:reset` los
borra y regenera desde la semilla.

---

## 🧠 El patrón transferible

**Guarda identificadores, no objetos.** Un id es un puntero estable a una
verdad que vive en un solo sitio; un objeto guardado es una fotografía que
envejece sin avisar. La regla vale para la selección de una lista, para el
usuario "actual", para el ticket de un formulario y para cualquier caché que
hayas escrito en cualquier lenguaje: en cuanto hay dos copias del mismo hecho,
alguien tiene que sincronizarlas, y ese alguien se va a olvidar.

Y la segunda, específica de las pantallas maestro-detalle: **un solo camino de
escritura, N caminos de lectura.** Si el detalle escribe por su cuenta y la
lista también, no hay forma de que no discrepen. Cuando heredes una pantalla
así, dibuja las flechas antes de tocar nada: dónde se escribe, quién deriva de
qué. El bug casi siempre está en una flecha que va en los dos sentidos.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 9](09-panel-soporte.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 09](cuaderno-incidentes.md); y la misma discusión, subida a estado
global, en la [pieza de la Fase 10](forense-fase-10.md).
EOF
wc -l forense-fase-09.md

# --- 2026-09-10T01:40:43 · Outline phase 10 and read its errors
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
grep -n '^## \|^### ' 10-vuex-a-fondo.md; echo "=== errores ==="; sed -n '530,560p' 10-vuex-a-fondo.md

# --- 2026-09-10T01:40:47 · Read plugins and devtools flow in phase 10
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
sed -n '184,215p;471,500p' 10-vuex-a-fondo.md

# --- 2026-09-10T01:41:50 · Write forensic piece for phase 10
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > forense-fase-10.md <<'EOF'
# 🕵️ Forense Fase 10 — "El estado cambió y nadie sabe quién lo cambió" ⭐

> **Sale de:** [Fase 10 — Vuex a fondo](10-vuex-a-fondo.md) ·
> **Herramientas:** Vue DevTools → pestaña **Vuex** (registro de mutations y
> time travel), y `git log -S` · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** un dato compartido cambia solo, y el registro
> de mutations no tiene ninguna entrada que lo explique.

Ésta es la tercera pieza estrella, y la que mejor resume por qué existe Vuex. La
ceremonia del store —mutations con nombre, actions que orquestan, plugins— no es
burocracia: es lo que convierte "el estado cambió" en **"la mutation
`SET_TICKETS` lo cambió a las 10:42:07 con este payload"**. Cuando ese registro
tiene un hueco, el hueco es el bug.

---

## 🎫 El ticket

> "A veces la lista de tickets se queda con datos raros: aparecen tickets que
> ya resolví, o desaparece uno que acabo de crear. No sé decirte cuándo pasa.
> Y cuando pasa, si navego a otra pantalla y vuelvo, unas veces se arregla y
> otras no."
>
> — coordinadora de soporte · **Ambiente:** desarrollo y UAT

Un reporte sin pasos de reproducción, que es lo normal cuando el estado global
es el enfermo: el usuario no puede ver el estado, solo sus consecuencias, y las
consecuencias aparecen en pantallas distintas de donde estuvo el daño.

---

## 🧭 La ruta

Del más barato al más caro: el registro de mutations ya está grabando —solo hay
que abrirlo—, el time travel cuesta un clic, y el `grep` es lo último.

### Paso 1 — ¿está encendido el testigo?

Vue DevTools → pestaña **Vuex**. Antes de investigar nada, comprueba que el
sistema esté siendo vigilado:

```js
// src/store/index.js
strict: process.env.NODE_ENV !== "production",
```

**Qué descarta.** No descarta un bug: decide si esta investigación es posible.
Con `strict` encendido, cualquier escritura al state fuera de una mutation
lanza un error inmediato en desarrollo. Si está apagado —o si estás mirando un
build de producción, donde **siempre** está apagado— las mutaciones furtivas
ocurren en silencio y el time travel muestra una historia falsa. Éste es también
el motivo de que un bug pueda existir solo en producción: no es que el código
cambie, es que el vigilante se fue.

### Paso 2 — ¿hay mutation para lo que pasó?

Reproduce lo que puedas y mira el registro.

```
Mutations
  tickets/SET_LOADING     10:42:06.912   true
  tickets/SET_TICKETS     10:42:07.238   Array[8]
  tickets/SET_LOADING     10:42:07.240   false
```

Ahora provoca el síntoma —o espera a que aparezca— y vuelve a mirar:

```
(sin entradas nuevas, y el state es distinto)
```

**Qué descarta.** Éste es el paso que parte el caso en dos. Si el estado cambió y
**no hay mutation**, alguien escribió el state directamente y ya sabes qué tipo
de bug tienes; salta al paso 3. Si **sí** hay mutation pero con un payload que
no esperabas, el bug está en quien la despacha: salta al paso 4.

### Paso 3 — ¿quién escribe fuera de una mutation?

Con `strict` encendido, el propio Vuex te lo dice en la consola:

```
Error: [vuex] do not mutate vuex store state outside mutation handlers.
```

Y si necesitas ubicar el sitio, pregúntale a git antes que al editor:

```bash
git log --oneline -S "state.items.push"
```

```
c81f0a2 f10 ej14: el socket alimenta el store
```

**Qué descarta.** Cierra el caso. Los sospechosos habituales son tres, y los
tres aparecen en los errores comunes de la fase: un componente que escribe
`this.$store.state.tickets.items` directamente, una action que se salta su
propia mutation (`context.state.items.push(...)`), o un plugin que commitea mal.
Fíjate en la ironía útil: **el error de strict mode es el mejor regalo de esta
fase**, porque convierte un bug intermitente en uno que salta al instante y con
stack trace.

### Paso 4 — ¿la mutation correcta, en el módulo correcto?

Si la mutation existe pero el efecto es otro, mira el nombre completo con su
espacio de nombres:

```
Mutations
  SET_TICKETS            10:51:02.114   Array[3]     ← ⚠️ sin prefijo de módulo
```

```bash
grep -rn "namespaced" src/store/modules/
```

```
src/store/modules/tickets.js:4:  namespaced: true,
src/store/modules/ui.js:3:  // namespaced: true,
```

**Qué descarta.** Descarta el módulo que sí está bien y explica los efectos
fantasma. Sin `namespaced: true`, los getters y las actions de ese módulo viven
en el espacio global: dos módulos con un `SET_LOADING` se pisan **en silencio**,
sin warning, y un `dispatch("fetchTickets")` puede ejecutar el de otro módulo.
No hay error porque, para Vuex, no hay nada malo: le pediste algo que existe.

### Paso 5 — ¿y si la vista nunca se enteró del final?

Última rama, y es una reincidencia declarada: la vista despacha, la action hace
su trabajo, y la vista se queda esperando algo que nunca llega.

```js
> $vm0.$store.dispatch("tickets/fetchTickets").then(function () { console.log("ok"); })
Uncaught TypeError: Cannot read property 'then' of undefined
```

**Qué descarta.** Descarta el store: los datos llegaron, las mutations están en
el registro, el state es correcto. Lo que falta es el `return` de la Promise
dentro de la action. La [Fase 3](forense-fase-03.md) enseñó este mismo error con
un servicio; acá tiene más víctimas, porque toda vista que despache se queda sin
poder encadenar nada — ni redirigir, ni apagar un spinner propio, ni mostrar un
error.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| El estado cambió y no hay mutation en el registro | Escritura directa al state: `strict` la caza |
| `do not mutate vuex store state outside mutation handlers` | Ya tienes el sitio: mira el stack, es literal |
| Una mutation sin prefijo de módulo | Falta `namespaced: true`: colisión silenciosa |
| Un `dispatch` ejecuta la action de otro módulo | Lo mismo, desde el otro lado |
| La vista no puede encadenar tras despachar | La action no devuelve la Promise (Fase 3, otra vez) |
| Todo va bien en `npm run serve` y raro en el build | `strict` está apagado en producción: las mutaciones furtivas ya no avisan |
| El time travel muestra estados que no cuadran | Hay async dentro de una mutation: el registro miente por diseño |
| El evento de socket se aplica N veces | Quedaron los handlers de las vistas **y** el plugin del store |
| Un getter recalcula sin parar dentro de un `v-for` | Getter-función sin caché: deriva un mapa en un getter normal |
| El store navega, o importa un componente | El flujo es UI → store; la navegación es de la vista que despachó |

---

## ⚰️ Los callejones

**"Vuex está roto, mejor lo saco."** Es la conclusión que saca mucha gente tras
un caso así, y es exactamente al revés: sin Vuex este bug no habría sido
diagnosticable en absoluto. Con un `data` compartido a mano, el estado cambia
igual —o peor— y no hay registro, ni payload, ni time travel. La ceremonia es lo
que te dejó ver el hueco.

**"Habría que meter también los filtros y la selección en el store."** La
auditoría de la fase decidió que no, con nueve fases de evidencia detrás. Un
store más grande no diagnostica mejor: solo hace que haya más sitios donde
alguien pueda escribir sin mutation, que es justo el bug de hoy.

**"Es la caché de la action, que devuelve datos viejos."** La action cachea a
propósito —segunda visita al dashboard sin viaje a la red— y eso puede parecer
el síntoma. La evidencia que lo separa está en el registro: una lectura cacheada
**no produce mutations**, así que si ves `SET_TICKETS` con datos raros, la caché
no fue; y si no ves nada de nada, tampoco fue la caché: fue una escritura
furtiva.

---

## 🧨 Deshacer

Si apagaste `strict` para probar el comportamiento de producción, o si tocaste
un módulo:

```bash
git checkout -- src/store/
```

Y recarga la aplicación: el estado del store vive en memoria y no se limpia con
un `git checkout`.

---

## 🧠 El patrón transferible

**Un cambio sin registro es un cambio que no existió, hasta que hace daño.** Todo
lo que Vuex te cobra —nombrar las mutations, no escribir el state a mano,
concentrar la orquestación en actions— se paga en una sola moneda: la
trazabilidad. Y la trazabilidad no sirve para escribir código, sirve para el día
de esta pieza.

Lo que se transfiere fuera de Vue, y fuera del frontend: **cuando diseñes un
sistema con estado compartido, la pregunta no es "¿cómo lo cambio?" sino "¿cómo
sabré después quién lo cambió?"**. Es la misma pregunta que en tu backend de
siempre justificaba una tabla de auditoría en vez de un `UPDATE` a secas — y la
misma que hace que un `strict` apagado en producción sea una decisión, no un
detalle.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 10](10-vuex-a-fondo.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); los casos completos en los
[incidentes 10 y 12](cuaderno-incidentes.md); y el mismo conflicto —el
framework queriendo el estado que tu store ya controla— en las piezas de ruta
[Q](forense-ruta-q.md), [VU](forense-ruta-vu.md) y [NX](forense-ruta-nx.md).
EOF
wc -l forense-fase-10.md

# --- 2026-09-10T01:41:55 · Read phase 11 testing details
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
sed -n '626,660p' 11-testing-minimo.md; grep -n '^## \|^### ' 11-testing-minimo.md | head -25; grep -n "clearAllMocks\|data-testid\|jest.mock\|flushPromises" 11-testing-minimo.md | head -12

# --- 2026-09-10T01:42:53 · Write forensic piece for phase 11
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > forense-fase-11.md <<'EOF'
# 🕵️ Forense Fase 11 — "El test pasa solo cuando lo corro aislado"

> **Sale de:** [Fase 11 — Testing mínimo](11-testing-minimo.md) ·
> **Herramientas:** la salida de Jest (con `-t` y `--runInBand`), y el propio
> código del test · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el mismo test, con el mismo código, da verde o
> rojo según con quién corra.

Un test que depende del orden no es un test: es un dado. Y hay un caso todavía
peor que el de hoy —el test que **nunca** falla— porque ése ni siquiera te
avisa de que algo va mal. Las dos patologías tienen la misma raíz: **estado que
sobrevive de un test a otro**, o promesas que nadie esperó.

---

## 🎫 El ticket

> "El test de `fetchTickets` me falla desde ayer. Lo corro solo con `-t` y pasa
> perfecto. Lo corro con toda la suite y falla. No toqué ese archivo, toqué el
> de al lado. Ya borré `node_modules` y sigue igual."
>
> — un compañero del equipo, en el canal de dev · **Ambiente:** local y CI

"Toqué el de al lado" es el dato que orienta todo el recorrido: si un cambio en
otro archivo altera este resultado, la suite comparte algo entre archivos, y ese
algo es el sospechoso.

---

## 🧭 La ruta

Del más barato al más caro: primero se confirma la dependencia del orden (dos
comandos), después se busca qué se comparte, y solo al final se lee el test.

### Paso 1 — ¿de verdad depende del orden?

Corre el test solo, y después toda la suite en serie:

```bash
npx vue-cli-service test:unit -t "fetchTickets"
```

```
PASS  tests/unit/store-tickets.spec.js
  ✓ fetchTickets guarda los tickets en el state (12 ms)
```

```bash
npx vue-cli-service test:unit --runInBand
```

```
FAIL  tests/unit/store-tickets.spec.js
  ✕ fetchTickets guarda los tickets en el state (8 ms)

    expect(jest.fn()).toHaveBeenCalledTimes(expected)
    Expected number of calls: 1
    Received number of calls: 3
```

**Qué descarta.** Descarta el código de producción por completo: el store hace
lo mismo en los dos casos. Y el mensaje de fallo trae el diagnóstico casi
regalado — **tres llamadas donde esperabas una** no es un bug de tu store, es un
contador que venía con cuentas de antes.

### Paso 2 — ¿qué se comparte entre tests?

Busca los dos sospechosos habituales, en este orden:

```bash
grep -rn "jest.mock\|clearAllMocks\|resetModules" tests/unit/
```

```
tests/unit/store-tickets.spec.js:4:jest.mock("@/services/ticketService");
tests/unit/store-tickets.spec.js:22:    jest.clearAllMocks();
tests/unit/ticketService.spec.js:3:jest.mock("@/services/apiClient");
```

**Qué descarta.** Si `clearAllMocks` está y el fallo persiste, descarta la causa
más común y sigue al paso 3. Si **no** está en el archivo que falla, ya
terminaste: los mocks son objetos vivos que acumulan llamadas, y sin limpieza
entre tests el segundo hereda el historial del primero. Es exactamente el
"falla en conjunto pero no solo" del reporte.

### Paso 3 — ¿o es un módulo que guarda estado?

Si los mocks están limpios, el sospechoso es cualquier módulo con memoria. En
este proyecto hay dos con nombre y apellido: la **caché de la action** de la
Fase 10 y el **singleton del socket** de la Fase 8.

```js
// en el test, antes de nada:
console.log(store.state.tickets.items.length);
```

```
0      // corrido solo
8      // corrido después del test que puebla el store
```

**Qué descarta.** Cierra el caso cuando el culpable es estado de módulo: un
store creado una vez para todo el archivo —o peor, importado del `store/index.js`
real— arrastra lo que hicieron los tests anteriores, y la action con caché
decide no llamar al servicio porque "ya tiene datos". De ahí el contador de
llamadas que no cuadra. La fase lo resuelve creando el store dentro del
`beforeEach`, con `createLocalVue`.

### Paso 4 — el caso peor: el test que nunca falla

Aprovecha que estás acá y comprueba lo contrario, que es más grave y no reporta
nadie:

```js
it("guarda los tickets", function () {
  store.dispatch("tickets/fetchTickets");        // ⚠️ sin return, sin await
  expect(store.state.tickets.items).toHaveLength(3);
});
```

```
PASS  tests/unit/store-tickets.spec.js
  ✓ guarda los tickets (3 ms)
```

Rompe el store a propósito —cambia la mutation para que no guarde nada— y vuelve
a correr:

```
PASS  tests/unit/store-tickets.spec.js
  ✓ guarda los tickets (3 ms)
```

**Qué descarta.** Descarta la idea de que "verde" signifique algo. El test
termina antes de que la promesa se resuelva, así que la aserción corre sobre el
state inicial y nunca falla. **Un test que sigue en verde con el código roto no
está probando nada**, y la única forma de descubrirlo es la que acabas de hacer:
romper a propósito lo que dice probar.

### Paso 5 — ¿es el test o es la maquetación?

Si el fallo apareció después de un cambio de plantilla y no de lógica:

```
FAIL  tests/unit/TicketsTable.spec.js
  ✕ muestra el estado del ticket

    Cannot read property 'text' of undefined
      wrapper.find(".col-md-6 > div:nth-child(2)")
```

**Qué descarta.** Descarta el componente: hace lo que debe, y lo que se rompió
fue el selector. Un test acoplado al DOM prueba la maquetación de ayer. La fase
lo resuelve con `data-testid`, y el criterio es sencillo: si un cambio visual
que no altera el comportamiento tumba un test, el test estaba mal escrito.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Pasa solo, falla en conjunto | Estado compartido: mocks sin limpiar, o módulo con memoria |
| "Expected 1 call, received 3" | Un mock que arrastra llamadas de tests anteriores |
| Un test que nunca falla, aunque rompas el código | Async sin `return`/`await`: la aserción corre antes de tiempo |
| Falla al cambiar la maquetación, sin tocar lógica | Selectores acoplados al DOM en vez de `data-testid` |
| Falla solo en CI | Orden distinto, paralelismo, o zona horaria de la máquina |
| El test es lentísimo y falla por un hijo ajeno | `mount` donde bastaba `shallowMount` |
| El test se rompe con cada refactor inocente | Está probando implementación, no comportamiento |
| Todo verde y el bug sigue en producción | Falta el test de la invariante: mira qué NO se está probando |

---

## ⚰️ Los callejones

**"Borro `node_modules` y reinstalo."** Ya lo hizo quien reportó, y no cambió
nada — como era esperable: el problema no es qué versión hay instalada, es qué
estado sobrevive **dentro de una misma corrida**. Es el mismo reflejo caro que
aparece en la [pieza de la Fase 0](forense-fase-00.md), en otro contexto.

**"Es que Jest corre los tests en paralelo."** Puede empeorar el síntoma, pero
`--runInBand` los pone en serie y el fallo sigue: el paso 1 lo demuestra. El
paralelismo revela dependencias de orden, no las crea.

**"Le pongo `.skip` mientras tanto y sigo."** Es la muerte de las suites legacy,
y ocurre exactamente en este punto: un test intermitente molesta, se salta, y
seis meses después nadie sabe si probaba algo importante. Si de verdad hay que
saltarlo, que sea con un comentario que diga qué invariante quedó sin cubrir.

---

## 🧨 Deshacer

El paso 4 te pide romper el store a propósito. Para volver:

```bash
git checkout -- src/store/modules/tickets.js
npx vue-cli-service test:unit
```

Y si el experimento te resultó revelador, es material de commit: el par
`ej/f11/3-roto` / `ej/f11/3-fix` de la
[convención de tags](../prompts/convencion-de-git-y-tags.md) existe para eso.

---

## 🧠 El patrón transferible

**Un test que depende del orden y un test que nunca falla son el mismo bug visto
desde dos lados: nadie controló el estado con el que empieza y termina cada
prueba.** El primero te lo grita de forma incómoda; el segundo se calla y te deja
creer que estás cubierto, que es mucho peor.

De ahí la única técnica que de verdad se lleva uno de esta pieza, y que sirve en
cualquier lenguaje y cualquier framework: **rompe a propósito lo que el test
dice probar.** Si sigue en verde, no tienes un test, tienes decoración. Es un
minuto de trabajo, se puede hacer sobre una suite heredada que no escribiste, y
es la forma más rápida que existe de saber cuánto vale la red de seguridad que
te acaban de entregar — que es exactamente lo que las fases X0 de las tres rutas
te van a pedir antes de migrar nada.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 11](11-testing-minimo.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); y el caso completo en el
[incidente 11](cuaderno-incidentes.md) del cuaderno.
EOF
wc -l forense-fase-11.md; ls forense-*.md

# --- 2026-09-10T01:43:01 · Read common errors of route Q phases
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
for f in q0-red-de-seguridad.md q1-leer-quasar.md q2-migrar-crud-qform.md q3-migrar-dashboard-qtable.md q4-timeline-actividad.md; do echo "======== $f"; awk '/^#{2} (⚠️|🐛).*(Errores|errores)/{flag=1} flag&&/^## 🧪/{flag=0} flag' $f | head -40; done

# --- 2026-09-10T01:44:10 · Write forensic piece for route Q
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > forense-ruta-q.md <<'EOF'
# 🕵️ Forense Ruta 🅠 — Quasar 1

> **Cubre:** [Q0](q0-red-de-seguridad.md) · [Q1](q1-leer-quasar.md) ·
> [Q2](q2-migrar-crud-qform.md) · [Q3](q3-migrar-dashboard-qtable.md) ·
> [Q4](q4-timeline-actividad.md) ·
> **Herramientas:** Vue DevTools → Components, `quasar.conf.js`, la pestaña
> Vuex y Network
>
> **El eje:** en Quasar casi nada grita. La mitad de los fallos de esta ruta
> **no producen error**, y la otra mitad produce uno que habla de Vuex cuando
> el problema es de la tabla.

Una sola pieza para las cinco fases, porque las rutas son excluyentes: si
elegiste Quasar, esto es todo tu track de ruta y se lee solo. Y porque el
conflicto de fondo es uno, no cinco — **el componente del framework quiere ser
dueño de un estado que tu store ya controla**, y todo lo demás son variaciones.

---

## 🎫 Los tres tickets de esta ruta

> **1.** "Copié el template del panel de otro archivo y no se ve nada. No sale
> ningún error. En la máquina de Ana el mismo código funciona."
>
> **2.** "El formulario de ticket guarda aunque deje campos vacíos. Antes no
> dejaba."
>
> **3.** "La tabla dice '1-10 de 10' pero hay 87 tickets, y al pasar a la
> página 2 me muestra la 1 otra vez."

---

## 🧭 La ruta, en cuatro preguntas

Del más barato al más caro. En esta ruta el orden importa más que en el tronco,
porque el paso 1 —diez segundos— explica una familia entera de síntomas que
parecen bugs de tu código.

### Paso 1 — ¿el componente está declarado?

Ante cualquier "no se ve nada y no hay error", antes que nada:

```bash
grep -n "components:" -A 12 quasar.conf.js
```

```js
framework: {
  components: [
    'QLayout', 'QPageContainer', 'QPage', 'QTable', 'QInput', 'QBtn'
    // QCard, QCardSection, QTd, QChip, QTimeline… no están
  ],
```

**Qué descarta.** Descarta tu template, tus datos y tu store de una sola vez.
Un componente de Quasar 1 que no está en `framework.components` **no renderiza y
no avisa**: en el mejor de los casos verás un `[Vue warn]: Unknown custom
element`, y muchas veces ni eso. Si el componente tenía `<slot>`, el contenido de
adentro también desaparece. Y explica el "en la máquina de Ana funciona":
copiaste el template, no la configuración.

Es el error nº 1 de Q1 y reaparece en Q3 (con `QTd` y los slots `body-cell-*`
que no pintan) y en Q4 (con `QTimeline` y `QChip`). **Tres fases, un solo
diagnóstico.**

### Paso 2 — ¿el método del framework devuelve lo que crees?

Si algo "pasa siempre" —una validación que nunca bloquea, una condición que
nunca es falsa—, míralo en la consola antes de leer código:

```js
> $vm0.$refs.form.validate()
Promise { <pending> }
> Boolean($vm0.$refs.form.validate())
true
```

**Qué descarta.** Descarta las reglas de validación, que suelen estar bien. En
Quasar 1 `QForm.validate()` devuelve una **promesa**, y una promesa siempre es
`truthy`: un `if (this.$refs.form.validate())` entra siempre, con el formulario
vacío o lleno. Es el bug nº 1 de Q2 y el más difícil de ver, porque *parece*
funcionar hasta que alguien deja un campo en blanco. La forma correcta es
`validate().then(function (ok) { … })`.

Del mismo tipo, y con el mismo paso: `q-select` sin `emit-value` + `map-options`
mete el **objeto** entero en el `v-model`, lo manda al POST y corrompe `db.json`.
Compruébalo en la consola mirando qué tiene el modelo, no qué se ve en pantalla.

### Paso 3 — ¿quién es dueño del estado, el componente o tu store?

El conflicto central de la ruta, y estalla en Q3. El síntoma llega de dos formas
según dónde estés corriendo:

```
[vuex] do not mutate vuex store state outside mutation handlers
```

o —peor— nada en absoluto:

```
(en el build de producción: sin error, sin time travel, y el estado cambiado)
```

**Qué descarta.** Descarta a Vuex como culpable, aunque sea quien grita.
`QTable` con `:pagination.sync` **escribe** en lo que le des: si le das un
computed sin `set`, escribe directamente en el state del store, y `strict` lo
caza en desarrollo. En producción `strict` está apagado (Fase 10) y la mutación
ocurre en silencio — de ahí el reporte "en producción se comporta distinto".

La pregunta que resuelve toda esta familia: **¿este estado lo controla mi store
o lo controla el componente?** Con `.sync` la respuesta tiene que ser una sola, y
la salida es un computed con `get`/`set` que commitee.

### Paso 4 — ¿el componente cree que está en modo cliente o en modo servidor?

Cuando la tabla "pagina dos veces" o muestra un total que no es:

```
Footer: 1-10 de 10       ← lo que dice QTable
GET /tickets?_page=1&_limit=10   → 200, x-total-count: 87
```

**Qué descarta.** Descarta el backend: el mock contestó bien y el header trae el
total real. Lo que pasa es que `QTable` **no sabe** que está en modo servidor:
sin `rowsNumber` en el objeto de paginación asume que le diste todas las filas y
pagina por su cuenta lo que ya está paginado. Declara `rowsNumber: 0` en `data()`
desde el principio y asígnalo tras el fetch.

Y mientras estés ahí, dos trampas vecinas que se ven idénticas desde la vista:
`response.headers["X-Total-Count"]` es `undefined` porque **axios normaliza los
headers a minúsculas**; y si en minúsculas tampoco está pero en Network sí se ve,
es CORS —falta `Access-Control-Expose-Headers`— y eso se arregla en el backend,
no en tu componente. 💸

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Copiaste un template y no se ve nada, sin error | `framework.components` en `quasar.conf.js` (Q1) |
| Los slots `body-cell-*` no pintan | Falta `QTd` declarado, o el `name` de la columna no coincide (Q3) |
| El formulario guarda con campos vacíos | `validate()` devuelve una promesa: siempre truthy (Q2) |
| Al guardar, la prioridad se corrompe o se borra | `q-select` sin `emit-value` + `map-options` (Q2) |
| Dos POST de un solo clic | `@click` **y** `type="submit"` en el mismo botón (Q2) |
| El formulario grita desde la primera tecla | Es el default: te falta `lazy-rules` (Q2) |
| Formulario válido pintado en rojo al abrir en modo edición | Falta `resetValidation()` en `$nextTick` (Q2) |
| `this.$q` es `undefined` | Falta el plugin en `framework.plugins`, no es un bug de Quasar (Q2) |
| `do not mutate vuex store state…` al ordenar la tabla | `:pagination.sync` contra un computed sin `set` (Q3) |
| En producción no da ese error y el estado igual cambia | `strict` apagado en prod: la mutación es silenciosa (Q3 · F10) |
| La tabla pagina dos veces | Falta `rowsNumber`: cree que está en modo cliente (Q3) |
| `x-total-count` es `undefined` | axios normaliza a minúsculas; si aun así falta, es CORS 💸 (Q3) |
| Página 2 muestra la página 1 | La action paginada heredó la caché de F10: no debe cachear (Q3) |
| El color hex del chip no se aplica | Quasar aplica clases, no estilos inline: usa la paleta (Q4) |
| El evento del timeline aparece en el ticket equivocado | Falta filtrar por `ticketId` en el handler del socket (Q4) |
| El cuarto evento aparece tres veces | `.bind(this)` distinto en el `on` y en el `off`: zombis de F8 (Q4) |
| El layout se descuadra al meter `QTable` | `.row` de Bootstrap contra `.row` de Quasar en el mismo subárbol (Q3) |
| El `q-select` se abre detrás del modal | z-index: Bootstrap 1050 contra los portales de Quasar (Q3) |
| Los tests de Q0 fallan buscando `.table` | No es un bug: `QTable` renderiza `.q-table`. Tu test estaba acoplado al DOM |

---

## ⚰️ Los callejones

**"Quasar está roto."** Casi nunca. Tres de los cuatro pasos de esta pieza
terminan en configuración o en una firma de API que no era la que suponías. La
señal para distinguirlo: si el fallo es **silencioso**, sospecha de la
declaración de componentes; si el fallo **grita sobre Vuex**, sospecha del dueño
del estado.

**"Reescribo el test de Q0 para que pase."** Es la peor decisión de toda la ruta
y la más tentadora, porque el rojo aparece justo cuando estás migrando. Un test
que buscaba `.table` y ahora busca `.q-table` no protege nada: certifica lo que
acabas de hacer. Los rojos de Q0 **se leen**, no se ajustan — y el que se rompió
por una clase CSS te está diciendo que estaba acoplado al DOM, que es
exactamente lo que Q0 vino a enseñar.

**"Ya que estoy migrando, arreglo también este bug."** Migrar y arreglar en el
mismo commit garantiza que, cuando algo falle, no sepas cuál de los dos fue.
Anótalo; con la red puesta, después, es un cambio de cinco minutos con test
rojo → verde.

---

## 🧠 El patrón transferible

**Un framework de componentes es un socio que quiere ser dueño.** Cada
componente rico —tabla, formulario, selector— trae su propio estado interno y su
propia idea de quién manda: paginación, validación, valor seleccionado. Migrar no
es cambiar etiquetas, es **negociar propiedades**: decidir, campo por campo, si
la verdad vive en tu store o en el componente, y no dejar ninguna en el medio.

Y la segunda, que en Quasar 1 duele especialmente: **el silencio es un modo de
fallo**. Un componente que no renderiza y no avisa entrena un reflejo que sirve
para cualquier librería configurable — antes de depurar tu código, comprueba que
la pieza que estás usando esté registrada, declarada y encendida.

**Sigue por acá:** el índice de síntomas completo del curso está en
[`forense-master.md`](forense-master.md), y la ruta se apoya en las piezas de las
fases [4](forense-fase-04.md), [8](forense-fase-08.md) y
[10](forense-fase-10.md), que es donde nacieron los tres bugs que Quasar
reencuentra con otra ropa.
EOF
wc -l forense-ruta-q.md

# --- 2026-09-10T01:44:20 · Read common errors of route VU phases
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
for f in vu1-leer-vuetify.md vu2-migrar-crud-vuetify.md vu3-migrar-dashboard-vdatatable.md vu4-timeline-vuetify.md; do echo "======== $f"; awk '/^#{2} ⚠️.*[Ee]rrores/{flag=1} flag&&/^## 🧪/{flag=0} flag' $f | head -32; done

# --- 2026-09-10T01:45:26 · Write forensic piece for route VU
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > forense-ruta-vu.md <<'EOF'
# 🕵️ Forense Ruta 🅥 — Vuetify 2

> **Cubre:** [VU0](vu0-red-de-seguridad.md) · [VU1](vu1-leer-vuetify.md) ·
> [VU2](vu2-migrar-crud-vuetify.md) · [VU3](vu3-migrar-dashboard-vdatatable.md)
> · [VU4](vu4-timeline-vuetify.md) ·
> **Herramientas:** el inspector de elementos sobre el DOM renderizado,
> `plugins/vuetify.js`, Vue DevTools y Network
>
> **El eje:** Vuetify falla **sutilmente**. No desaparecen componentes enteros:
> se descoloca una línea, un color no cambia con el tema, un diálogo no abre. Y
> la consola, limpia.

Una sola pieza para las cinco fases, porque las rutas son excluyentes: si
elegiste Vuetify, esto es todo tu track de ruta y se lee solo. El conflicto de
fondo es el mismo de todas las rutas —**el componente del framework quiere ser
dueño de un estado que tu store ya controla**— con un acompañante propio: en
Vuetify, el **tema** es estado global, y tratarlo como CSS es la fuente de la
mitad de los casos.

---

## 🎫 Los tres tickets de esta ruta

> **1.** "Los colores de la aplicación no son los que definimos y los diálogos
> no abren. No sale ningún error en la consola."
>
> **2.** "Guardé un ticket y la prioridad quedó rara; ahora el badge del
> dashboard sale en blanco para ese ticket."
>
> **3.** "La tabla no ordena al hacer clic en la cabecera. No pasa nada, ni
> error ni movimiento."

---

## 🧭 La ruta, en cuatro preguntas

Del más barato al más caro. En esta ruta el paso 1 cuesta cinco segundos y
resuelve la familia de síntomas más desconcertante.

### Paso 1 — ¿hay `<v-app>` en la raíz?

Ante cualquier cosa "casi bien" con la consola limpia:

```bash
grep -n "v-app" src/App.vue
```

```
(sin resultados)
```

**Qué descarta.** Descarta el tema, los componentes y tu código. Vuetify 2
necesita un `<v-app>` ancestro para dos cosas que parecen no tener relación: la
**inyección del tema** (por eso los colores "no son los que pusiste") y el
**punto de anclaje de los portales** (por eso los diálogos, menús y overlays no
aparecen). Sin él nada explota: se degrada en silencio. Es el error que más
horas cuesta de toda la ruta.

Reaparece en VU4 con otra cara —la línea vertical del `v-timeline` que se
descoloca— y sobre todo **en los tests**: un componente montado sin `<v-app>` y
sin la instancia de Vuetify inyectada falla de formas que no se parecen a nada.
VU0 avisa y VU2 lo resuelve dentro del helper `mountView`.

### Paso 2 — ¿estás leyendo la documentación de tu versión?

Cuando la API "no coincide" con lo que tienes delante:

```
vuetifyjs.com          → Vuetify 3   ← la que sale primero en Google
v2.vuetifyjs.com       → la tuya
```

**Qué descarta.** Descarta que el proyecto esté mal configurado. Es el fallo
menos técnico de la ruta y uno de los que más tiempo consume, porque manda a
depurar código que está bien. Su primo cercano: `<v-flex xs12>` es sintaxis de
Vuetify **1**, y si la encuentras en un proyecto heredado no es un bug, es un
estrato geológico — su traducción a v2 es `<v-col cols="12">`, dentro de la
tríada `container > row > col`.

### Paso 3 — ¿el valor que guarda el componente es el que crees?

Cuando un dato "queda raro" tras guardar, míralo antes de tocar nada:

```js
> $vm0.form.priority
{ text: "Alta", value: "high" }     // ⚠️ el objeto entero
```

**Qué descarta.** Descarta el servicio, el mock y el badge que aparece en
blanco: todos están recibiendo fielmente lo que el formulario les dio. En
Vuetify 2, un `<v-select>` con `return-object` —o copiado de un ejemplo que lo
traía— mete el objeto completo en el `v-model`, y de ahí viaja al POST y
corrompe `db.json`. El primo del mismo caso: las opciones se declaran con
`text`/`value`, no con `label` —que es la convención de Quasar—, y con `label`
el select sale simplemente en blanco.

Y dos firmas de API que hay que comprobar en la consola en vez de suponer,
porque en Vuetify 2 se comportan al revés de lo que espera quien viene de otra
librería:

```js
> $vm0.$refs.form.validate()
true                                 // síncrono: NO devuelve promesa
```

`reset()` borra los datos; `resetValidation()` solo quita los rojos. Confundirlos
significa vaciarle el formulario al usuario para "limpiar unos mensajes".

### Paso 4 — ¿quién manda en la tabla?

El conflicto central, en VU3. Empieza por el síntoma mudo:

```js
> $vm0.sortBy
"createdAt"        // ⚠️ string
```

**Qué descarta.** Descarta la tabla, los datos y el orden del backend: en
Vuetify 2 `sortBy` y `sortDesc` son **arrays**, y con un string la tabla no
ordena y no avisa. La misma familia de fallos silenciosos por contrato mal leído
incluye `align: "left"` (Vuetify usa `start`/`end`, pensando en RTL) y el header
escrito con `label` en vez de `text`, que deja la cabecera vacía.

Y la parte que sí es de propiedad del estado: si estás en modo servidor,
`@update:options` ya pide los datos al montar, así que un fetch en `created()`
produce **dos peticiones**; en modo cliente es exactamente al revés. Míralo en
Network antes de discutirlo:

```
GET /tickets?_page=1&_limit=10    200
GET /tickets?_page=1&_limit=10    200      ← la de created(), de más
```

Mientras estés ahí, la trampa compartida con la ruta Q:
`response.headers["X-Total-Count"]` es `undefined` porque **axios normaliza los
headers a minúsculas**; y `:search` en modo servidor solo filtra las diez filas
que ya tienes en pantalla, porque la búsqueda tiene que viajar como parámetro.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Colores del tema que no aplican y diálogos que no abren, consola limpia | Falta `<v-app>` en la raíz (VU1) |
| La línea del timeline desaparece o se descoloca | Lo mismo: falta el `<v-app>` ancestro (VU4) |
| Un test monta el componente y todo se comporta raro | Sin `<v-app>` y sin instancia de Vuetify inyectada (VU0 · VU2) |
| El color `primary` "no es el que puse" | Vive en `plugins/vuetify.js`, no en el CSS (VU1) |
| El icono no aparece | Fuente MDI no cargada, o nombre/prefijo mal (VU1) |
| La API de la documentación no coincide | Estás en `vuetifyjs.com`, que es v3: usa `v2.vuetifyjs.com` (VU1) |
| `<v-flex xs12>` que no se comporta | Es sintaxis de Vuetify 1: en v2 es `<v-col cols="12">` (VU1) |
| El `<v-select>` sale en blanco | Opciones con `label` en vez de `text`/`value` (VU2) |
| La prioridad se guarda como objeto y corrompe `db.json` | `return-object` heredado de un ejemplo (VU2) |
| `validate().then(…)` te da `undefined` | En Vuetify 2 es **síncrono** (VU2) |
| Llamaste `reset()` y le borraste el formulario al usuario | Querías `resetValidation()` (VU2) |
| `wrapper.find()` no encuentra un campo del diálogo | El `<v-dialog>` se teletransporta: usa `attach` o `document.querySelector` (VU2) |
| Clic fuera del diálogo y se pierde lo escrito | Falta `persistent` (VU2) |
| La tabla no ordena y no da error | `sortBy` como string en vez de array (VU3) |
| `align: "left"` que se ignora | Vuetify usa `start`/`end` (VU3) |
| Dos peticiones al montar la tabla | Fetch en `created()` estando en server-side (VU3) |
| `x-total-count` es `undefined` | axios normaliza los headers a minúsculas (VU3) |
| La búsqueda solo encuentra en la página actual | En server-side, `:search` no viaja: hay que mandarlo como param (VU3) |
| Buscas algo inexistente y sale el mensaje equivocado | Definiste `no-data` pero no `no-results` (VU3) |
| El chip con color hex no cambia con el tema ni en dark mode | Un hex es un color; un rol es una decisión (VU4) |
| El evento del timeline aparece en el ticket equivocado | Falta filtrar por `ticketId` en el handler del socket (VU4) |
| El cuarto evento aparece tres veces | `.bind(this)` distinto en el `on` y en el `off`: zombis de F8 (VU4) |
| El layout salta según el orden de los imports | `.row`/`.col` de Bootstrap dentro de una vista Vuetify (VU3) |

---

## ⚰️ Los callejones

**"Es un problema de CSS."** Es la conclusión natural cuando los colores no
aplican, y manda a buscar en la hoja de estilos algo que vive en
`plugins/vuetify.js`. En Vuetify el tema es **estado global reactivo**: tocar un
rol cambia todos los componentes que lo usan, en caliente. Trátalo como estado,
no como estilo, y la mitad de estos casos dejan de existir.

**"Vuetify valida solo, quito el flag de error."** Ese flag no era de validación:
era de HTTP. Sin él, un 500 del servidor es un silencio absoluto en la pantalla —
el mismo error que la ruta Q comete con su propio formulario, y el mismo que la
[pieza de la Fase 3](forense-fase-03.md) enseña a no cometer.

**"Quito vuelidate ahora que Vuetify valida."** Sí, pero entero. Quitarlo a
medias deja un formulario huérfano con `$v` reventando en consola: la peor de las
dos aguas, y un mes después nadie sabe cuál de los dos sistemas manda.

---

## 🧠 El patrón transferible

**Los fallos silenciosos son un rasgo de diseño de las librerías de UI, no una
casualidad.** Un componente que no encuentra su contexto —el `<v-app>`, el tema,
el plugin— casi nunca lanza una excepción: se degrada, porque lanzar rompería la
pantalla entera. Eso convierte "consola limpia" en un dato inútil y obliga a
cambiar de método: **comprobar el contexto antes que el código.**

Y la lección propia de Vuetify, que vale para cualquier sistema de diseño:
**escribir un hex es renunciar al tema.** Un color literal funciona el primer día
y traiciona el día del dark mode o del cambio de paleta. Cuando heredes una
interfaz, buscar hexes sueltos es una de las auditorías más rentables que
existen — y se hace con un `grep`.

**Sigue por acá:** el índice de síntomas completo del curso está en
[`forense-master.md`](forense-master.md), y la ruta se apoya en las piezas de las
fases [4](forense-fase-04.md), [8](forense-fase-08.md) y
[10](forense-fase-10.md), donde nacieron los bugs que Vuetify reencuentra con
otra ropa.
EOF
wc -l forense-ruta-vu.md

# --- 2026-09-10T01:45:31 · Read common errors of route NX phases
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
for f in nx0-red-de-seguridad.md nx1-leer-nuxt.md nx2-hidratacion-window-not-defined.md nx3-asyncdata-vs-vuex.md nx4-pagina-ssr-nueva.md; do echo "======== $f"; awk '/^#{2} ⚠️.*[Ee]rrores/{flag=1} flag&&/^## 🧪/{flag=0} flag' $f | head -26; done

# --- 2026-09-10T01:46:40 · Write forensic piece for route NX
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > forense-ruta-nx.md <<'EOF'
# 🕵️ Forense Ruta 🅝 — Nuxt 2

> **Cubre:** [NX0](nx0-red-de-seguridad.md) · [NX1](nx1-leer-nuxt.md) ·
> [NX2](nx2-hidratacion-window-not-defined.md) ·
> [NX3](nx3-asyncdata-vs-vuex.md) · [NX4](nx4-pagina-ssr-nueva.md) ·
> **Herramientas:** la **terminal del servidor Nuxt** (antes que la consola del
> navegador), "Ver código fuente de la página", y Vue DevTools
>
> **El eje:** en Nuxt tu código corre en dos sitios con capacidades distintas, y
> la mayoría de los fallos de esta ruta son **un trozo de código ejecutándose
> donde no debería**.

Una sola pieza para las cinco fases, porque las rutas son excluyentes: si
elegiste Nuxt, esto es todo tu track de ruta y se lee solo. Comparte con las
otras rutas el conflicto de propiedad del estado —**el framework quiere ser
dueño de datos que tu store ya controla**, que es NX3 en estado puro— y le
agrega el suyo propio, que ninguna otra tiene: **la misma línea de código se
comporta distinto según quién la ejecute.**

---

## 🎫 Los tres tickets de esta ruta

> **1.** "Si entro al dashboard desde el menú funciona, pero si recargo la
> página con F5 se cae y sale una pantalla de error de Nuxt."
>
> **2.** "Desde que se subió lo nuevo, al entrar aparece un parpadeo raro y
> después la lista sale vacía. En el código fuente de la página sí están los
> tickets."
>
> **3.** "El login no funciona en el servidor de pruebas. En local va bien."

---

## 🧭 La ruta, en cuatro preguntas

Del más barato al más caro. La primera pregunta de esta ruta no la hace ninguna
otra pieza del curso, y es la que ordena todo lo demás.

### Paso 1 — ¿dónde se ejecutó el código que falló?

Antes de mirar nada, mira **la terminal donde corre Nuxt**, no la consola del
navegador:

```
 ERROR  window is not defined

  at ticketService.js:14
  at TicketsPage.created (pages/tickets/index.vue:31)
```

**Qué descarta.** Descarta el navegador entero y localiza el bug en un solo
paso. `window` no existe en Node: si ese error aparece en la terminal, el código
corrió en el **servidor**. Y explica el reporte tal cual: al navegar desde el
menú, la página se monta en el cliente y todo funciona; al recargar con F5,
Nuxt la renderiza primero en el servidor y ahí revienta.

La regla que se deriva y sirve para el resto de la ruta: **`created()` corre en
los dos mundos; `mounted()` solo en el navegador.** Todo lo que toque `window`,
`localStorage`, un socket o el DOM va en `mounted`.

### Paso 2 — ¿el servidor y el cliente pintaron lo mismo?

Cuando hay parpadeo, o el contenido "se va" después de aparecer:

```
[Vue warn]: The client-side rendered virtual DOM tree is not matching
server-rendered content. …bailing hydration and performing full client-side render.
```

Y el desempate, que es gratis: **Ver código fuente de la página** (el HTML que
mandó el servidor, no el inspector, que muestra el DOM ya hidratado).

```html
<li>#1 — La impresora no imprime</li>
<li>#2 — No me llega el correo</li>
```

**Qué descarta.** Descarta el servidor y la carga de datos: el HTML llegó
completo. Lo que se rompió es la **hidratación** — Vue intentó adoptar ese HTML,
encontró que su propio render no coincidía, y lo tiró entero para repintar desde
cero. Los sospechosos son siempre los mismos: `Date.now()`, `new Date()`,
`Math.random()`, `toLocaleString()` — cualquier cosa cuyo valor dependa de
**cuándo** o **dónde** se evalúa, metida en un template o en un computed que se
renderiza.

> ⚠️ La hidratación rota a veces no avisa: se ve como un parpadeo, o como un
> dato que cambia solo. El aviso vive en la consola del navegador, y el
> diagnóstico, en el código fuente de la página.

### Paso 3 — ¿de quién son los datos, de la página o del store?

El conflicto central de la ruta, y estalla en NX3 con este síntoma:

```
"La tabla no se actualiza cuando llega un ticket nuevo por socket, pero si
recargo sí aparece."
```

Compruébalo en Vue DevTools comparando los dos sitios:

```
Vuex → tickets.items: Array[9]        ← el socket commiteó acá
<TicketsPage> data.tickets: Array[8]  ← asyncData guardó acá
```

**Qué descarta.** Descarta el socket, que funcionó perfectamente. `asyncData`
devuelve datos que Nuxt fusiona en el `data()` de la **página**; el plugin del
socket commitea al **store**. Son dos sitios distintos, y nadie los sincroniza.
No hay bug que arreglar: hay una decisión que tomar, y la fase la plantea con
todas las letras — **si quieres tiempo real, los datos viven en el store**, y la
herramienta es `fetch` + Vuex, no `asyncData`.

De la misma familia, y todos silenciosos: `asyncData` **solo corre en `pages/`**
(en un componente hijo no se ejecuta y no avisa fuerte); dentro de `asyncData` no
hay `this` (se usa `context.store`); y `nuxtServerInit` es una action del store
**raíz**, así que en un módulo namespaced no se ejecuta nunca.

### Paso 4 — ¿esto depende de dónde esté corriendo el proceso?

La última pregunta, la de los bugs que solo existen fuera de tu máquina:

```js
// nuxt.config.js
axios: { baseURL: "http://localhost:3000" }
```

**Qué descarta.** Descarta tu código: es configuración, y es la deuda 💸
declarada de NX3. En SSR hay **dos** clientes HTTP —el del servidor Node y el
del navegador— y no tienen por qué alcanzar la misma URL. En local coinciden por
casualidad del entorno; en un servidor de pruebas, no. Nuxt distingue `baseURL`
de `browserBaseURL` exactamente por esto.

Su hermano es el reporte 3 de arriba: la sesión de la Fase 2 vive en
`localStorage`, que en el servidor no existe. El guard, el interceptor y el
servicio de auth son los tres puntos que hay que reescribir con cookies, y si
dejas uno, revienta la primera vez que ese código corra en Node. Detalle que
cuesta tardes: una cookie sin `path: "/"` se guarda con el path de la ruta
actual y "desaparece" al navegar.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| `window is not defined` al recargar una página que en navegación funciona | `created()` corre en el servidor: mueve a `mounted` (NX2) |
| Error solo con F5, nunca navegando desde el menú | Lo mismo: el F5 es el que dispara el render en servidor (NX2) |
| Parpadeo y contenido que se va tras aparecer | Hidratación rota: mira el aviso en consola y el código fuente (NX2) |
| El HTML del servidor y el del cliente no coinciden | `Date.now()`, `new Date()`, `Math.random()` en el render (NX2 · NX4) |
| El login funciona en local y no en el servidor | `localStorage` en el servidor: hay que migrar a cookie (NX1 · NX2) |
| La cookie "desaparece" al navegar | Falta `path: "/"` (NX2) |
| El socket actualiza el store y la tabla no cambia | `asyncData` guarda en la página, el socket commitea al store (NX3) |
| `TypeError: Cannot read 'store' of undefined` | No hay `this` en `asyncData`: usa `context.store` (NX3) |
| Pusiste `asyncData` en un componente y no corre | Solo funciona en `pages/` (NX3) |
| `nuxtServerInit` que no se ejecuta | Es del store raíz, no de un módulo namespaced (NX3) |
| El SSR pinta la página vacía y luego se llena | Falta el `return` de la Promise en `asyncData`/`fetch` (NX3) |
| `context.req` es `undefined` | Solo existe en servidor: protégelo con `process.server` (NX3) |
| No ves el spinner en la carga inicial | No hay nada que esperar: el HTML llega con datos (NX3) |
| Se pide el historial dos veces | Se re-fetchea en `mounted` lo que `asyncData` ya trajo (NX4) |
| El `head` pete o salga vacío | Debe ser función, no objeto, para poder leer `this` (NX4) |
| Dos `<meta name="description">` | Falta `hid` para que Nuxt deduplique (NX4) |
| El evento llega y la lista no se repinta | `activity[0] = ev` en vez de `unshift`: F4 cobrando de nuevo (NX4) |
| Handlers de socket acumulados al navegar | Falta `beforeDestroy`, o la referencia del `off` no es la del `on` (NX2 · NX4) |
| Buscas `router/index.js` y no está | El router **es** `pages/` (NX1) |
| La documentación no coincide | `nuxt.com` es Nuxt 3 (Vue 3): la tuya es `v2.nuxt.com` (NX1) |

---

## ⚰️ Los callejones

**"Lo envuelvo todo en `<client-only>` y deja de petar."** Funciona, y acabas de
convertir tu aplicación SSR en una SPA con un servidor Node de adorno: pagas el
render y no lo aprovechas. `<client-only>` es un bisturí para la pieza que de
verdad necesita el navegador, no una manta.

**"Le pongo `process.client` al computed."** No sirve: los computed se evalúan
durante el render, que corre en los dos mundos. `process.client` es útil en
`mounted` y en métodos; para lo que pinta el template, la herramienta es
`<client-only>` o traer el dato en `mounted`.

**"Verde en los tests, entonces migro tranquilo."** Es el error central de la
ruta, y NX0 lo advierte antes de empezar: los tests corren en **jsdom**, donde
`window` existe. Verde significa "seguro en jsdom", que es necesario y no
suficiente. La única prueba de que el SSR funciona es recargar con F5 y mirar la
terminal del servidor.

**"El socket está roto."** Casi nunca. Si el evento llega —y en DevTools se ve
que el store cambió— lo que falla es dónde miran tus datos, que es el paso 3.

---

## 🧠 El patrón transferible

**El código no tiene un solo entorno de ejecución, y suponer que sí es el bug.**
En Nuxt son dos —Node y el navegador— con capacidades distintas: uno tiene
`window` y `localStorage`, el otro tiene `req` y el sistema de archivos. La
pregunta que ordena la ruta entera, y que ninguna de las otras dos necesita, es
**"¿dónde corre esto?"** — y se contesta mirando en qué terminal apareció el
error, antes de leer una línea.

Es el mismo problema que vas a reencontrar el día que un job programado, una
lambda y tu API compartan código: la biblioteca común asume un entorno que solo
uno de los tres tiene. Y la segunda lección, más barata: **cuando el HTML del
servidor y la pantalla no coinciden, el desempate es "Ver código fuente"**, que
enseña lo que se mandó, no lo que el navegador hizo después con ello.

**Sigue por acá:** el índice de síntomas completo del curso está en
[`forense-master.md`](forense-master.md), y la ruta se apoya en las piezas de las
fases [2](forense-fase-02.md) —la sesión en `localStorage` que aquí se
rompe—, [4](forense-fase-04.md) y [8](forense-fase-08.md).
EOF
wc -l forense-ruta-nx.md; ls forense-*.md | wc -l

# --- 2026-09-10T01:46:50 · Read common errors of course 02 phases 0-2
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
for f in 00-preliminares.md 01-mongo-en-30-min.md 02-consultar-tu-sql-traducido.md; do echo "======== $f"; awk '/^## ⚠️/{flag=1} flag&&/^## 🧪/{flag=0} flag' $f; done

# --- 2026-09-10T01:46:57 · Read inline forensic piece in phase 02
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
sed -n '346,400p' 02-consultar-tu-sql-traducido.md

# --- 2026-09-10T01:47:03 · Read inline forensic pieces of phases 09 and 10
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
sed -n '444,500p' 09-aggregation.md; echo "=========10"; sed -n '499,560p' 10-express-el-vehiculo.md

# --- 2026-09-10T01:47:10 · Read errors of course 02 phases 4-6
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
for f in 04-el-esquema-que-no-esta-en-la-base.md 05-lookup-y-por-que-es-una-alarma.md 06-atomicidad-transacciones-consistencia.md; do echo "======== $f"; awk '/^## ⚠️/{flag=1} flag&&/^## 🧪/{flag=0} flag' $f | head -30; done

# --- 2026-09-10T01:47:18 · Read errors of course 02 phases 7,8,12,13
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
for f in 07-indices.md 08-la-autopsia.md 12-el-backend-habla.md 13-testing-de-api.md; do echo "======== $f"; awk '/^## ⚠️/{flag=1} flag&&/^## 🧪/{flag=0} flag' $f | head -34; done

# --- 2026-09-10T01:48:14 · Write course 02 forensic piece phase 0
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat > forense-fase-00.md <<'EOF'
# 🕵️ Forense Fase 00 — "Levanté todo y no conecta"

> **Sale de:** [Fase 0 — Preliminares](00-preliminares.md) ·
> **Herramientas:** el log del contenedor (`docker compose logs`), `mongosh` y
> el listado de puertos · **Recorrido:** cuatro pasos, ninguno abre un archivo
> de la aplicación
>
> **El síntoma, en una línea:** el contenedor dice que está arriba, y nada
> logra conectarse.

Es la investigación menos vistosa del curso y la que más se repite en la vida
real. El punto no es Mongo: es el reflejo de **leer el log del arranque antes de
googlear el mensaje de error del cliente**, porque el cliente casi nunca sabe
por qué no lo dejaron entrar.

---

## 🎫 El ticket

> "Seguí los pasos, levanté el compose y me dice que el contenedor está
> corriendo, pero Compass no conecta y mongosh tampoco. Ayer funcionaba. No
> cambié nada, solo reinicié la máquina."
>
> — un compañero que se está incorporando al proyecto

"Ayer funcionaba" y "no cambié nada" son, casi siempre, ciertos. Lo que cambió
fue el entorno alrededor, y eso es lo que hay que buscar.

---

## 🧭 La ruta

Del más barato al más caro: el log del arranque cuesta un comando y contesta el
90% de los casos; los puertos, otro comando; y solo al final se toca el compose.

### Paso 1 — ¿qué dice el log del arranque?

Antes que nada, y antes que el cliente:

```bash
docker compose logs -f mongo
```

```
mongo_1  | {"t":{"$date":"…"},"s":"E","c":"NETWORK","msg":"Failed to set up listener",
mongo_1  |  "attr":{"error":"Address already in use"}}
mongo_1  | {"t":{"$date":"…"},"s":"I","c":"CONTROL","msg":"now exiting"}
```

**Qué descarta.** Descarta el cliente, la cadena de conexión, la red de Docker y
tu configuración: el servidor **ni siquiera llegó a escuchar**. Y descarta la
sensación de que "el contenedor está arriba": puede estar reiniciándose en bucle,
cosa que `docker compose ps` confirma. Las dos pistas que resuelven la mayoría de
los tropiezos de setup viven acá — el puerto ocupado y los permisos sobre el
`dbPath` del bind mount.

### Paso 2 — ¿quién tiene el 27017?

Si el log habla de la dirección en uso:

```bash
lsof -i :27017              # macOS / Linux
netstat -ano | findstr :27017   # Windows
```

```
mongod   1284  oskar   11u  IPv4  TCP *:27017 (LISTEN)
```

**Qué descarta.** Cierra el caso más común de todos, y explica el "ayer
funcionaba": hay **dos `mongod` peleando** — el nativo, instalado como servicio y
que arranca solo al encender la máquina, y el del contenedor. El de Docker llega
segundo y no puede escuchar. Apaga uno de los dos; en el Curso 02 el que manda es
el del compose.

### Paso 3 — el contenedor vive y aun así no entra nadie

Si el log no tiene errores y el proceso escucha, prueba desde dentro y desde
fuera, en ese orden:

```bash
docker compose exec mongo mongosh --eval 'db.runCommand({ ping: 1 })'
```

```
{ ok: 1 }
```

```bash
mongosh "mongodb://localhost:27017/minijira" --eval 'db.runCommand({ ping: 1 })'
```

```
MongoServerSelectionError: connect ECONNREFUSED 127.0.0.1:27017
```

**Qué descarta.** Separa dos mundos que se confunden todo el tiempo. Si adentro
responde y afuera no, Mongo está perfecto: lo que falta es la **publicación del
puerto** en el compose (`ports: - "27017:27017"`), o el proceso está escuchando
solo en la interfaz interna. Ningún cambio en tu código va a arreglar eso.

### Paso 4 — "se perdieron los datos"

Variante del mismo ticket, con otro susto. Si conecta pero las colecciones están
vacías:

```js
> show dbs
admin    41 kB
config   61 kB
local    41 kB
```

```bash
grep -n "MONGO_DATA_PATH\|volumes:" -A 3 docker-compose.yml
```

**Qué descarta.** Descarta el borrado. Los datos casi nunca se pierden en este
escenario: **siguen en la ruta vieja**. Cambiar la ruta del volumen con el
contenedor corriendo deja los archivos donde estaban y monta un directorio
nuevo, vacío. El orden correcto es `down` → cambiar → `up`. Y si el proyecto se
levantó sin volumen ninguno, entonces sí: recrear el contenedor se lleva todo, y
eso es diseño de compose, no un fallo de Mongo.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| El contenedor "está arriba" y nadie conecta | El log del arranque: casi seguro no llegó a escuchar |
| `Address already in use` en el log | Dos `mongod`: el nativo como servicio y el de Docker |
| Adentro responde el ping y afuera no | Falta publicar el puerto en el compose |
| Conecta y las colecciones están vacías | El volumen cambió de ruta: los datos siguen en la vieja |
| Errores de permisos sobre el `dbPath` | Bind mount con dueño equivocado |
| `mongoexport` no existe | Desde 4.4 las Database Tools se instalan aparte |
| Importaste un dump y "no entró nada" | `--jsonArray` puesto o faltante según el formato del archivo |
| Editaste `mongod.cfg` en Windows y nada cambió | El servicio no se reinició |
| Compass conecta y tu aplicación no | Cadena de conexión distinta: revisa base, usuario y host |

---

## ⚰️ Los callejones

**"Borro el contenedor y lo levanto de cero."** Es el `rm -rf node_modules` de
este curso: a veces funciona, nunca enseña nada, y si el problema era el volumen
acabas de perder datos de verdad. Antes de recrear, lee el log — cuesta cinco
segundos y suele traer el diagnóstico escrito.

**"Instalo la última versión, seguro es un bug de la 4.4."** El curso fija 4.4 a
propósito: es el motor que tu legacy va a tener. Estudiar contra otra versión
cambia el comportamiento de cosas que sí importan —transacciones, `$lookup` con
`let`, el planificador— y te deja aprendiendo un sistema que no es el tuyo.

**"Instalé Compass, entonces ya tengo MongoDB."** Son tres piezas distintas —el
servidor, el shell y la interfaz gráfica— y confundirlas produce media hora de
desconcierto. Compass es un cliente: si el servidor no está, no hay nada que
mirar.

---

## 🧠 El patrón transferible

**Cuando un cliente no puede conectarse, el cliente es el peor testigo posible.**
Solo sabe que no lo dejaron entrar; el motivo está del otro lado. Por eso el
orden de esta pieza pone el log del servidor por delante del mensaje de error, y
por eso el paso 3 prueba desde dentro antes que desde fuera: cada movimiento
parte el problema en dos y descarta una mitad.

Lo que se lleva uno a cualquier stack: **el arranque de un servicio es su
declaración de intenciones**, y casi siempre dice en texto plano lo que después
vas a tardar una hora en deducir desde el otro extremo.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 0](00-preliminares.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 01](cuaderno-incidentes.md); y los detalles de Docker, en
[A01](a01-docker.md).
EOF
wc -l forense-fase-00.md

# --- 2026-09-10T01:48:18 · Read react course incident notebook checklist
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && wc -l completado_cuaderno_incidentes.md && cat completado_cuaderno_incidentes.md

# --- 2026-09-10T01:48:22 · Find checklist items and outline
grep -n '^#\{2,3\} \|^- \[ \]\|^- \[x\]' completado_cuaderno_incidentes.md

# --- 2026-09-10T01:48:32 · Read final checklist and H3 details
sed -n '617,630p' completado_cuaderno_incidentes.md; echo "=== §4bis H3 ==="; sed -n '183,220p' completado_cuaderno_incidentes.md

# --- 2026-09-10T01:48:39 · Verify checklist state in react course
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
echo "== incidentes en cuaderno base =="; grep -c "^## Incidente" cuaderno-incidentes.md
echo "== incidentes BE =="; grep -c "^## Incidente" cuaderno-incidentes-be.md 2>/dev/null
echo "== indice sintomas =="; grep -rn "🩺" cuaderno-incidentes.md cuaderno-incidentes-be.md | head
echo "== plantilla =="; ls prompts/ ; echo "== referencias al doc =="; grep -rln "completado_cuaderno_incidentes" --include="*.md" .
echo "== hueco en README/guia =="; grep -n "no están redactados\|hueco\|⚠️.*redact" README.md prompts/guia-de-estilo-y-convenciones.md | head

# --- 2026-09-10T01:48:44 · Inspect base incident notebook
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
wc -l cuaderno-incidentes.md cuaderno-incidentes-be.md prompts/plantilla-de-incidente.md
echo "== headings base =="; grep -n '^## \|^### ' cuaderno-incidentes.md | head -30
echo "== indice base (filas) =="; grep -c '^| ' cuaderno-incidentes.md

# --- 2026-09-10T01:48:54 · Verify H1, guide section 15 and README hole
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
echo "== convencion inc14 =="; sed -n '236,248p' 00-convencion-de-git-y-tags.md
echo "== guia 15 =="; sed -n '805,830p' prompts/guia-de-estilo-y-convenciones.md
echo "== README 96-112 =="; sed -n '96,112p' README.md

# --- 2026-09-10T01:49:30 · Fill in the react course checklist with verified state
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
python3 - <<'PY'
p='completado_cuaderno_incidentes.md'
s=open(p,encoding='utf-8').read()
old = """## 7. ✅ Antes de borrar este archivo

- [x] D1–D6 confirmadas. **Falta** anotar sus resoluciones en la guía de estilo §15 (P4).
- [x] H1: `00-convencion-de-git-y-tags.md` describe el incidente 14 como lo describe el código.
- [x] H2: `prompts/plantilla-de-incidente.md` existe. **Falta** que el placeholder salga
      del cuaderno (lo hace L1).
- [ ] H3: los seis incidentes de la ficha §4bis declaran su condición, y el 19 trae su
      script de siembra.
- [ ] Los 20 incidentes redactados (`grep -c "^## Incidente"` → 20).
- [ ] El índice 🩺 está en los dos cuadernos.
- [ ] README y guía §15 ya no describen el hueco.
- [ ] Este archivo **no** quedó referenciado desde ningún `.md` del curso
      (`grep -rn "completado_cuaderno_incidentes" --include="*.md" .` → solo él mismo).
- [ ] `rm completado_cuaderno_incidentes.md`"""

new = """## 7. ✅ Antes de borrar este archivo

> 📌 **Verificado el 2026-09-09 contra el árbol de trabajo.** Cada ítem lleva el comando
> con el que se comprobó y lo que devolvió. Resumen: **P1 hecho, P2 sin empezar, P3 sin
> empezar, P4 sin empezar.** El cuaderno base sigue con sus dos placeholders y cero
> enunciados redactados; el del track BE sigue completo y no se toca.

- [x] **D1–D6 confirmadas.** **Falta** anotar sus resoluciones en la guía de estilo §15
      (P4). Comprobado: §15 registra el hueco del cuaderno y la excepción de la tabla de
      seis columnas del índice, pero **ninguna** de las seis decisiones aparece escrita
      ahí. Sigue pendiente, tal como estaba.
- [x] **H1: `00-convencion-de-git-y-tags.md` describe el incidente 14 como lo describe el
      código.** Verificado en `00-convencion-de-git-y-tags.md:240-243`: el mensaje del tag
      `-fix` dice *"boardRefreshEpic sin takeUntil"* y *"takeUntil(...) último en el pipe
      interno"*, que es lo que hace `07-…md:508-528` y lo que enseña el error común #3 de
      la Fase 6. Cerrado.
- [x] **H2: `prompts/plantilla-de-incidente.md` existe** (231 líneas). **Falta** que el
      placeholder salga del cuaderno, y lo hace L1: hoy `cuaderno-incidentes.md:191` sigue
      siendo `## Incidente 01 — {{Título en palabras del usuario}}` y `:328` es
      `## Incidente 02 — {{...}}`.
- [ ] **H3: los seis incidentes de la ficha §4bis declaran su condición, y el 19 trae su
      script de siembra.** No verificable todavía: ninguno de los seis (07, 15, 16, 17, 19,
      20) está redactado. Bloqueado por P2.
- [ ] **Los 20 incidentes redactados** (`grep -c "^## Incidente" cuaderno-incidentes.md`
      → **2**, y los dos son los placeholders `{{…}}` de H2, así que **cero redactados**).
      El archivo tiene 361 líneas de las ~3.900 previstas: índice, cómo se trabaja un
      incidente, convención de commits, estados, la reserva 🔥 del track BE y los dos
      moldes. Es el paquete grande que queda: L1…L5 completos.
- [ ] **El índice 🩺 está en los dos cuadernos.** `grep -n "🩺" cuaderno-incidentes.md
      cuaderno-incidentes-be.md` → **sin resultados**. No está en ninguno de los dos. P3
      entero pendiente.
- [ ] **README y guía §15 ya no describen el hueco.** Siguen describiéndolo, y con razón:
      `README.md:100-107` mantiene el ⚠️ de "los enunciados todavía no están redactados"
      —y su nota de que el cuaderno BE sí está completo— y
      `prompts/guia-de-estilo-y-convenciones.md:818-822` lo lista como *"el hueco de
      autocontención más grande del curso"*. Los dos textos se retiran en P4, **después**
      de L5, no antes.
- [x] **Este archivo no quedó referenciado desde ningún `.md` del curso.**
      `grep -rln "completado_cuaderno_incidentes" --include="*.md" .` → solo él mismo.
      Se mantiene así: cada lote que lo cite en un commit rompe este ítem.
- [ ] `rm completado_cuaderno_incidentes.md`

### Lo que falta, en una línea por paquete

| Paquete | Estado | Qué queda |
|---|---|---|
| P1 · plantilla | ✅ hecho | — |
| P2 · L1 (01-04, entorno y routing) | ⬜ sin empezar | 4 enunciados + sacar el placeholder |
| P2 · L2 (05-08, auth e integración) | ⬜ sin empezar | 4 enunciados; el 07 declara `CHAOS_LEVEL=high` |
| P2 · L3 (09-12, store y concurrencia) | ⬜ sin empezar | 4 enunciados |
| P2 · L4 (13, 14, 15, 17, RxJS/epics) | ⬜ sin empezar | 4 enunciados; 15 y 17 declaran caos alto |
| P2 · L5 (16, 18, 19, 20) | ⬜ sin empezar | 4 enunciados + el script de siembra del 19 |
| P3 · índice 🩺 | ⬜ sin empezar | ~60 líneas, en los dos cuadernos |
| P4 · costura y cierre | ⬜ sin empezar | README, guía §15, D1–D6, y borrar este archivo |"""
assert old in s
s=s.replace(old,new)
open(p,'w',encoding='utf-8').write(s)
print("checklist actualizado")
PY

# --- 2026-09-10T01:50:29 · Write course 02 piece for phase 1
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat > forense-fase-01.md <<'EOF'
# 🕵️ Forense Fase 01 — "El dato está en la base y la consulta no lo encuentra"

> **Sale de:** [Fase 1 — Mongo en 30 minutos](01-mongo-en-30-min.md) ·
> **Herramientas:** `mongosh` sobre el documento crudo · **Recorrido:** cinco
> pasos
>
> **El síntoma, en una línea:** ves el documento en Compass y tu `find` devuelve
> vacío, sin ningún error.

En SQL, una consulta que no encuentra nada suele ser una consulta mal escrita, y
el motor te avisa si el nombre de la tabla o de la columna no existe. En Mongo
**no hay ese aviso**: una colección que no existe está vacía, un campo que no
existe es `null`, y una comparación entre tipos distintos simplemente no
coincide. Todo el silencio de esta pieza sale de ahí.

---

## 🎫 El ticket

> "El ticket está en la base, lo veo en Compass, tiene su `_id` y todo. Pero el
> script que hice para buscarlo por `_id` me devuelve vacío. Lo copié y pegué,
> no puede estar mal escrito."
>
> — un compañero migrando desde Oracle · **Ambiente:** local

Copiar y pegar el `_id` es exactamente lo que produce este bug, y es lo primero
que hace todo el mundo. La respuesta está en el paso 3.

---

## 🧭 La ruta

Del más barato al más caro: primero se comprueba dónde estás parado, después si
el documento existe, y solo entonces se discute el filtro.

### Paso 1 — ¿en qué base y en qué colección estás?

```js
> db
test
> show dbs
admin     41 kB
config    61 kB
local     41 kB
minijira  2.4 MB
```

**Qué descarta.** Descarta la mitad de los sustos de esta fase en dos líneas. Si
`db` dice `test`, no estás donde crees, y todo lo que consultes va a salir
vacío sin una sola queja. Es la primera pregunta y casi nadie se la hace.

### Paso 2 — ¿la colección se llama como tú crees?

```js
> use minijira
> show collections
comments
tickets
users
> db.tiket.countDocuments()
0
> db.tickets.countDocuments()
100
```

**Qué descarta.** Descarta el "se borraron los datos", que es como llega este
ticket la mitad de las veces. **Mongo no tiene el error "la tabla no existe":**
un typo crea el concepto de una colección fantasma que responde `0` con toda
naturalidad. En SQL esto habría sido un `ORA-00942`; acá es un cero.

### Paso 3 — ¿el valor que buscas es del tipo que está guardado?

Ahora sí, el caso del ticket. Mira el documento crudo, sin cliente gráfico de
por medio:

```js
> db.tickets.findOne({ title: /impresora/i })
{
  _id: ObjectId("5f8a1c2e4b3d2f0012a4e991"),
  title: 'La impresora no imprime',
  status: 'open',
  createdAt: ISODate('2020-03-10T10:00:00.000Z')
}
> db.tickets.find({ _id: "5f8a1c2e4b3d2f0012a4e991" }).count()
0
> db.tickets.find({ _id: ObjectId("5f8a1c2e4b3d2f0012a4e991") }).count()
1
```

**Qué descarta.** Cierra el caso y explica el silencio: un `_id` es un
**`ObjectId`**, no la cadena de 24 caracteres con la que se imprime. Comparar un
`ObjectId` con un string no es un error de tipos: es una comparación que da
`false`, y Mongo te devuelve el conjunto vacío que corresponde. Esa traducción
—string afuera, `ObjectId` adentro— es exactamente de lo que vive la capa API de
la [Fase 10](forense-fase-10.md), y es el origen del incidente de costura más
clásico del curso: *el frontend no muestra nada y `curl` sí devuelve los
tickets*.

### Paso 4 — la misma trampa, con fechas

El primo del caso anterior, y el que más tarda en aparecer:

```js
> db.tickets.findOne({}, { createdAt: 1 })
{ _id: ObjectId("…"), createdAt: '2020-03-10T10:00:00Z' }     // ⚠️ comillas
> db.tickets.find({ createdAt: { $gte: ISODate("2020-01-01") } }).count()
0
```

**Qué descarta.** Descarta el rango, que está bien escrito. Si `createdAt` se
guardó como **string** —porque así venía en el `db.json` heredado— comparar
contra un `ISODate` no coincide nunca. Lo traicionero es que a veces *parece*
funcionar: entre strings, el orden lexicográfico del ISO 8601 coincide con el
cronológico… hasta que llega una fecha sin zona, o con otro formato. Y el TTL de
la [Fase 7](forense-fase-07.md) sobre un campo string no borra nada y no avisa.

### Paso 5 — ¿o simplemente no está?

Si nada de lo anterior encaja, comprueba el supuesto de partida:

```js
> db.tickets.countDocuments()
0
> db.tickets.countDocuments({ status: "open" })
0
```

**Qué descarta.** Descarta el filtro y te manda a la siembra: si la colección
está vacía, el `npm run seed` falló, corrió contra otra base, o el contenedor se
recreó sin volumen —que es el caso de la [pieza de la Fase 0](forense-fase-00.md).
Comprobar el total antes de discutir un filtro cuesta un comando y evita
investigaciones enteras en la dirección equivocada.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| El `find` devuelve vacío y el documento está en Compass | Tipos: `ObjectId` contra string, o `Date` contra string |
| "Se borraron los datos" y la colección está intacta | Typo en el nombre: colecciones fantasma que responden 0 |
| Todo sale vacío, incluso lo que existe | Estás en otra base: mira `db` |
| Un rango de fechas devuelve cualquier cosa | Fechas guardadas como string |
| El orden por fecha pone los documentos donde no toca | Mezcla de tipos en el mismo campo: Mongo ordena entre tipos |
| `distinct` devuelve `null` entre los valores | Hay documentos sin el campo, y eso es un valor más |
| Recreaste el contenedor y no hay nada | Sin volumen no hay persistencia (Fase 0) |
| El seed "corrió bien" y la colección está vacía | Corrió contra otra base o contra otro puerto |

---

## ⚰️ Los callejones

**"Mongo perdió mi documento."** Prácticamente nunca. En esta fase, un documento
que "desaparece" está en otra base, en otra colección por un typo, o guardado
con un tipo distinto del que buscas. Antes de acusar al motor, cuenta: `db` →
`show collections` → `countDocuments()`. Son tres comandos y cierran el 90%.

**"Voy a poner un índice, seguro por eso no lo encuentra."** Un índice cambia la
velocidad, nunca el resultado. Si una consulta devuelve vacío, con índice
devolverá vacío más rápido. Confundir rendimiento con corrección es el error de
instinto más caro de este curso, y la [Fase 7](forense-fase-07.md) le dedica una
sección entera.

**"Le pongo `String(_id)` a todo y listo."** Convierte el bug en un problema de
datos: si empiezas a guardar `_id` como string pierdes el índice natural, el
orden temporal implícito del `ObjectId` y la compatibilidad con cualquier
herramienta. La traducción se hace **en la frontera** —la capa API de la Fase
10—, no en la base.

---

## 🧠 El patrón transferible

**En Mongo, "no existe" y "no coincide" se ven exactamente igual: un conjunto
vacío.** No hay error de tabla inexistente, ni de columna desconocida, ni de
tipos incompatibles. Eso obliga a un método distinto del que traes de SQL:
**antes de dudar del filtro, comprueba el terreno** —base, colección, total— y
solo después discute la condición.

Y la regla que se lleva uno a cualquier base sin esquema: **mira el documento
crudo antes que cualquier cosa que lo formatee.** Compass, un ODM o tu API te
enseñan una versión traducida del dato, y las comillas alrededor de una fecha
—o su ausencia— son justamente lo que se pierde en la traducción.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 1](01-mongo-en-30-min.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 02](cuaderno-incidentes.md); y la versión con más filtros encima, en
la [pieza de la Fase 2](forense-fase-02.md).
EOF
wc -l forense-fase-01.md

# --- 2026-09-10T01:50:37 · Read trap 1 in phase 2
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
grep -n "Trampa" 02-consultar-tu-sql-traducido.md | head; sed -n "$(grep -n 'Trampa 1' 02-consultar-tu-sql-traducido.md | head -1 | cut -d: -f1),+30p" 02-consultar-tu-sql-traducido.md

# --- 2026-09-10T01:51:35 · Write course 02 piece for phase 2
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat > forense-fase-02.md <<'EOF'
# 🕵️ Forense Fase 02 — "Traduje mi WHERE y devuelve de más" ⭐

> **Sale de:** [Fase 2 — Consultar: tu SQL traducido](02-consultar-tu-sql-traducido.md)
> · **Herramientas:** `mongosh`, comparando siempre contra el conteo ·
> **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** la consulta funciona, no da error, y el conjunto
> que devuelve no es el que pediste.

Ésta es la pieza que más rinde del Curso 02, porque cubre el sitio exacto donde
el instinto relacional contesta rápido y contesta mal: **la traducción literal
casi funciona.** Un `WHERE` mal traducido no revienta; devuelve un resultado
plausible, y un resultado plausible se cuela hasta producción.

---

## 🎫 El ticket

> "El reporte de tickets sin asignar me da 34 y el que hice yo a mano en Compass
> me da 41. Los dos filtran por lo mismo. Ninguno da error. ¿Cuál está bien?"
>
> — el analista que heredó los reportes · **Ambiente:** desarrollo

La pregunta correcta no es cuál está bien: es **qué está contando cada uno**. Y
la respuesta, casi siempre, es que uno de los dos incluye documentos donde el
campo ni siquiera existe.

---

## 🧭 La ruta

Del más barato al más caro, con una regla propia de esta fase que ordena todo:
**cada paso se contesta con un conteo, no con una impresión.** Mirar veinte
documentos y decir "parece bien" es exactamente cómo se cuelan estos bugs.

### Paso 1 — ¿cuántos son en total, y cuántos devuelve cada versión?

```js
> db.tickets.countDocuments()
100
> db.tickets.countDocuments({ assignee: null })
41
> db.tickets.countDocuments({ assignee: { $type: "null" } })
34
> db.tickets.countDocuments({ assignee: { $exists: false } })
7
```

**Qué descarta.** Descarta la idea de que uno de los dos filtros esté "mal
escrito": los dos hacen exactamente lo que dicen, y la diferencia —7— tiene
nombre. En Mongo hay **tres estados**, no dos: campo con valor, campo con `null`
explícito, y campo **ausente**. `{ assignee: null }` matchea los dos últimos.

> 🪞 Tu instinto de SQL dice que `= NULL` no matchea nada y hace falta
> `IS NULL`. Acá se equivoca **en la dirección contraria**: la igualdad con
> `null` matchea, y matchea de más.

### Paso 2 — ¿el filtro negado excluye lo que crees?

La otra mitad de la misma trampa, y la que produce reportes que faltan filas:

```js
> db.tickets.countDocuments({ assignee: { $ne: "soporte1" } })
72
> db.tickets.countDocuments({ assignee: { $ne: "soporte1", $exists: true, $ne: null } })
```

Como `$ne` no se puede repetir en el mismo objeto, se escribe explícito:

```js
> db.tickets.countDocuments({ assignee: { $nin: ["soporte1", null], $exists: true } })
31
```

**Qué descarta.** Descarta la lectura ingenua de `$ne`. *"Asignados a alguien
que no es soporte1"* y *"no asignados a soporte1"* son dos preguntas distintas:
la segunda incluye a los que no están asignados a nadie. En SQL la
tricotomía te obligaba a decidirlo; acá el filtro más corto decide por ti, y
decide mal.

### Paso 3 — ¿estás comparando el tipo correcto?

Si los conteos no cuadran y el campo no es nullable, sospecha del tipo antes que
del filtro:

```js
> db.tickets.countDocuments({ priority: { $type: "string" } })
99
> db.tickets.countDocuments({ priority: { $not: { $type: "string" } } })
1
> db.tickets.findOne({ priority: { $not: { $type: "string" } } })
{ _id: ObjectId("…"), title: 'Ticket de prueba', priority: 3 }
```

**Qué descarta.** Descarta el filtro y apunta a los datos: **nadie custodia los
tipos**. Un `priority: 3` numérico entre 99 strings no rompe nada, no aparece en
ningún reporte por prioridad, y sobrevive meses. Lo mismo con `_id` como string
y `createdAt` como texto, que es lo que la [Fase 1](forense-fase-01.md) enseña a
detectar. Un auditor de tipos por campo sospechoso es de las cosas más rentables
que puedes escribir en una base heredada.

### Paso 4 — ¿la proyección está haciendo lo que crees?

Otro reporte de la misma familia, con síntoma distinto:

```js
> db.tickets.find({}, { title: 1, assignee: 0 })
MongoServerError: Cannot do exclusion on field assignee in inclusion projection
```

**Qué descarta.** Es de los pocos casos de esta fase donde Mongo **sí** grita, y
conviene reconocerlo para no perder tiempo: una proyección o incluye o excluye,
no las dos cosas; `_id` es la única excepción, y por eso `{ title: 1, _id: 0 }`
sí es legal. Si tu consulta trae campos que no pediste, mira la proyección antes
que el serializer.

### Paso 5 — el filtro es correcto y aun así el número extraña

Última comprobación antes de cerrar: que no estés contando con la herramienta
equivocada.

```js
> db.tickets.count()
100
> db.tickets.countDocuments({ status: "open" })
41
```

**Qué descarta.** Descarta el filtro. `count()` sin filtro puede devolver una
**estimación** basada en metadatos —rápida y, tras un apagón sucio, mentirosa—,
mientras `countDocuments()` cuenta de verdad. En un reporte que alguien va a
firmar, la diferencia importa; en SQL nunca tuviste que elegir.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Dos filtros "iguales" con conteos distintos | Los tres estados: valor / `null` / ausente |
| `$ne` trae documentos que no esperabas | `$ne` incluye a los ausentes: no significa "tiene otro valor" |
| Un filtro por valor deja fuera documentos que lo cumplen | Tipos mezclados en el campo |
| `$or` que no filtra nada | Está escrito dentro del campo en vez de en la raíz |
| La proyección falla o devuelve de más | Se mezclaron `1` y `0`: solo `_id` va a contracorriente |
| Un rango de fechas devuelve cualquier cosa | Fechas guardadas como string (Fase 1) |
| El conteo cambia entre dos formas de contarlo | `count()` estima; `countDocuments()` cuenta |
| Paginar la página 400 tarda un mundo | `skip` gigante: el mismo pecado que `OFFSET` |
| El regex encuentra de más con textos raros | Falta escapar: el `?q=` del contrato vive de esto (Fase 10) |
| `distinct` devuelve `null` entre los valores | Es un valor legítimo: filtra en el segundo argumento |

---

## ⚰️ Los callejones

**"La base está corrupta."** Casi nunca. Lo que suele haber es una base **sin
custodia de tipos** —que es otra cosa— y una consulta que asume un esquema que
nadie hace cumplir. La diferencia importa porque el arreglo es distinto: no se
repara la base, se le pone un validator (Fase 4) y se auditan los tipos.

**"Le agrego `$exists: true` a todo por si acaso."** Convierte cada filtro en un
conjuro y esconde la pregunta real, que es de negocio: *¿"sin asignar" incluye a
los tickets que nunca tuvieron el campo?* Contéstala primero, escribe el filtro
después, y déjala escrita en el código — porque el siguiente que lo lea va a
tener la misma duda.

**"Lo arreglo en la capa API con un `filter` de JavaScript."** Traer 100.000
documentos para descartar 60.000 en Node funciona en desarrollo y muere en
producción. Y además esconde el problema: la consulta sigue siendo incorrecta, y
el siguiente que la use sin tu `filter` va a heredar el bug.

---

## 🧠 El patrón transferible

**Un resultado plausible es más peligroso que un error.** Todo lo de esta pieza
—los tres estados del campo, el `$ne` que incluye ausentes, los tipos sin
custodia— produce consultas que devuelven algo razonable, y por eso llegan a
producción y se convierten en reportes que alguien firma.

De ahí el método, que es lo que de verdad se lleva uno: **valida por conteo, no
por muestra.** Escribe la consulta de las dos formas que se te ocurran, cuenta
las dos, y si los números difieren has encontrado una pregunta de negocio que
nadie había contestado. Es la técnica más barata que existe para auditar una
migración, un reporte heredado o cualquier filtro que no escribiste tú.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 2](02-consultar-tu-sql-traducido.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 03](cuaderno-incidentes.md); y la misma disciplina de medir, aplicada
al rendimiento, en la [pieza de la Fase 7](forense-fase-07.md).
EOF
wc -l forense-fase-02.md

# --- 2026-09-10T01:53:23 · Write course 02 pieces for phases 4 and 5
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat > forense-fase-04.md <<'EOF'
# 🕵️ Forense Fase 04 — "El validator rechaza un documento que a mí me parece correcto"

> **Sale de:** [Fase 4 — El esquema que no está en la base](04-el-esquema-que-no-esta-en-la-base.md)
> · **Herramientas:** `mongosh`, `db.getCollectionInfos()` y el error completo
> de la escritura · **Recorrido:** cuatro pasos
>
> **El síntoma, en una línea:** una escritura que siempre funcionó empieza a
> fallar, y el documento se ve bien.

Un validator es la primera pieza del Curso 02 que dice **que no**. Y decir que no
es exactamente lo que querías —para eso lo pusiste—, así que la investigación no
va sobre si el validator está roto, sino sobre **qué regla concreta se está
violando**, que el mensaje por defecto no cuenta.

---

## 🎫 El ticket

> "Desde ayer el script de carga falla. El documento que manda es idéntico al
> que cargamos toda la semana pasada, lo comparé campo por campo. El error solo
> dice 'Document failed validation'. No dice qué campo."
>
> — el compañero que mantiene los scripts de datos · **Ambiente:** desarrollo

"Es idéntico" suele ser cierto **a la vista**. Lo que casi nunca se compara es
el **tipo** de cada valor, y ahí está el caso más famoso de esta fase.

---

## 🧭 La ruta

Del más barato al más caro: primero se lee la regla, después se compara el
documento contra ella, y solo al final se discute si la regla debería existir.

### Paso 1 — ¿qué regla hay puesta, exactamente?

El validator no vive en tu código: vive en la colección.

```js
> db.getCollectionInfos({ name: "tickets" })[0].options
{
  validator: {
    $jsonSchema: {
      bsonType: 'object',
      required: [ 'title', 'status', 'priority', 'createdAt' ],
      properties: {
        status: { enum: [ 'open', 'in_progress', 'resolved', 'closed' ] },
        schemaVersion: { bsonType: 'int' },
        createdAt: { bsonType: 'date' }
      }
    }
  },
  validationLevel: 'strict',
  validationAction: 'error'
}
```

**Qué descarta.** Descarta tu aplicación entera y te da el contrato en la mano.
Y contesta de paso una pregunta que la gente arrastra desde el ODM: **esto no es
el schema de Mongoose.** El de Mongoose valida dentro de tu proceso Node; éste
lo aplica el motor a **todos** los clientes — tu API, el script del compañero,
mongosh y la herramienta gráfica.

### Paso 2 — ¿qué tipo tiene de verdad el valor que mandas?

Con la regla delante, compara tipo por tipo, no valor por valor:

```js
> db.tickets.insertOne({ title: "Prueba", status: "open", priority: "high",
                         createdAt: new Date(), schemaVersion: 3 })
MongoServerError: Document failed validation
> typeof 3
'number'
> db.tickets.insertOne({ …, schemaVersion: NumberInt(3) })
{ acknowledged: true, insertedId: ObjectId("…") }
```

**Qué descarta.** Cierra el caso más clásico de la fase, el que se lleva una
hora y media de todo el mundo la primera vez: **JavaScript no tiene enteros**. El
driver manda `double` por defecto, y un `bsonType: "int"` lo rechaza aunque el
número sea `3` a la vista. Las salidas son dos, y son decisión de diseño:
mandar `NumberInt()` desde el cliente, o relajar la regla a `"number"`.

La misma trampa con otra ropa: `createdAt` como string ISO contra un
`bsonType: "date"`, que es el eco de la [Fase 1](forense-fase-01.md).

### Paso 3 — ¿y si el que falla es el seed?

Variante que descoloca, porque parece un fallo del curso:

```bash
npm run seed
```

```
MongoServerError: Document failed validation
```

**Qué descarta.** Descarta el validator como sospechoso y **le da la razón**. Si
el seed de la [Fase 1](forense-fase-01.md) no pasa la validación que acabas de
poner, la validación acaba de encontrarle un bug al seed: llevabas semanas
sembrando documentos que no cumplen tus propias invariantes. Es el resultado
correcto y el más incómodo, y por eso conviene decirlo en voz alta antes de que
alguien "arregle" el validator para que el seed vuelva a pasar.

### Paso 4 — ¿por qué entonces sí entró ese documento inválido?

El caso simétrico, y el que de verdad enseña la fase:

```js
> db.tickets.countDocuments({ status: { $nin: ["open","in_progress","resolved","closed"] } })
3
```

Con el validator puesto, y aun así hay tres documentos que lo violan.

```js
> db.getCollectionInfos({ name: "tickets" })[0].options.validationLevel
'moderate'
```

**Qué descarta.** Descarta que alguien haya "saltado" la validación. Con
`validationLevel: "moderate"`, el motor **solo valida los documentos que ya
cumplían**: los históricos rotos pueden seguir actualizándose sin pasar por el
aro. Es lo correcto para activar reglas sobre datos heredados sin romper la
operación, y es exactamente lo que hay que saber antes de prometerle a alguien
que "la base ya no acepta basura". Si el nivel es `strict` y aun así entró,
mira la fecha del documento: probablemente es anterior a la regla.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| `Document failed validation` sin más detalle | Lee la regla con `getCollectionInfos`, después compara tipos |
| Un número "obviamente entero" rechazado | El driver manda `double`: `NumberInt()` o relaja a `"number"` |
| Una fecha rechazada | Llega como string ISO contra un `bsonType: "date"` |
| El seed dejó de entrar | El validator le encontró un bug al seed: no lo relajes por reflejo |
| Documentos inválidos que siguen entrando | `validationLevel: "moderate"`, o son anteriores a la regla |
| Otro servicio escribió basura y nadie avisó | Ese servicio no pasa por tu ODM: el validator del motor sí los cubre |
| La migración corrió dos veces y duplicó datos | No era idempotente: el `--dry` existe por esto |
| El validator rechaza campos nuevos legítimos | `additionalProperties: false` con un modelo que evolucionó |

---

## ⚰️ Los callejones

**"El validator está roto, lo quito."** Es la reacción natural bajo presión y la
peor decisión posible: quitarlo no arregla el documento, solo apaga al único
testigo. Si hay que desbloquear la operación, el movimiento correcto es bajar el
`validationAction` a `warn` —que registra y deja pasar— y arreglar con calma.

**"Lo valido en Mongoose y listo."** Cubre a tu proceso Node y a nadie más. En
un sistema donde escriben la API, un script de migración y el compañero desde
mongosh, la única regla que aplica a todos es la del motor. Las dos capas no
compiten: la del ODM da mensajes buenos al usuario, la del motor garantiza la
invariante.

**"Le pongo todas las reglas de negocio."** Un validator que replica el negocio
entero se convierte en un despliegue cada vez que cambia una política. Al motor
van las **invariantes duras** —lo que jamás debe existir en la base—; lo que
cambia seguido va a la aplicación.

---

## 🧠 El patrón transferible

**La pregunta no es "¿hay esquema?" sino "¿quién lo hace cumplir, y sobre
quién?"** En tu motor relacional esas dos respuestas eran una sola —la base, para
todos— y por eso nunca hiciste la pregunta. Acá hay al menos tres candidatos con
alcances distintos: el ODM (tu proceso), el validator (todos los clientes) y los
scripts (nadie los vigila). Elegir mal no da error: da una garantía que crees
tener y no tienes.

Y el corolario para heredar una base ajena: **antes de confiar en un campo,
cuenta cuántos documentos lo violan.** El validator te dice qué debería haber;
solo un conteo te dice qué hay.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 4](04-el-esquema-que-no-esta-en-la-base.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); y la autopsia de lo que pasa cuando
nadie hizo esta pregunta durante años, en la
[pieza de la Fase 8](forense-fase-08.md).
EOF
cat > forense-fase-05.md <<'EOF'
# 🕵️ Forense Fase 05 — "Esta pantalla hace seis viajes a la base" ⭐

> **Sale de:** [Fase 5 — `$lookup` y por qué es una alarma](05-lookup-y-por-que-es-una-alarma.md)
> · **Herramientas:** los logs de la API, `explain()` sobre el pipeline y
> Compass · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** la pantalla funciona y es lenta, y la lentitud
> crece con los datos, no con el código.

Ésta es la pieza donde el instinto SQL más se equivoca, y no por ignorancia: por
**exceso de confianza**. El `$lookup` se parece tanto a un JOIN que se usa igual,
y usarlo igual es el síntoma de un modelo que se diseñó como si fuera un esquema
relacional. El recorrido termina siempre en la misma pregunta incómoda: *¿esto
debió embeberse?*

---

## 🎫 El ticket

> "El dashboard de tickets tarda como cuatro segundos en abrir. Antes iba bien.
> No hemos cambiado esa pantalla en meses, solo se ha ido llenando de tickets."
>
> — coordinadora de soporte · **Ambiente:** UAT

"Solo se ha ido llenando" es el diagnóstico a medio hacer: un problema que crece
con el volumen y no con el código es de **modelo o de acceso**, nunca de una
línea que alguien tocó.

---

## 🧭 La ruta

Del más barato al más caro: contar peticiones cuesta leer un log; medir el
pipeline cuesta un `explain`; rediseñar el modelo es la conversación cara y va
al final, con números en la mano.

### Paso 1 — ¿cuántas consultas hace esa pantalla?

Antes de medir ninguna consulta, cuéntalas. En el log de la API, al abrir la
pantalla una vez:

```
GET /tickets 200 - 38 ms
GET /users/5f8a… 200 - 6 ms
GET /users/5f8b… 200 - 5 ms
GET /users/5f8c… 200 - 6 ms
GET /comments?ticketId=… 200 - 7 ms
GET /comments?ticketId=… 200 - 6 ms
… (58 líneas más)
```

**Qué descarta.** Descarta la consulta individual: ninguna de ellas es lenta.
Es el **N+1 de siempre con otro collar** — una consulta para la lista y una por
cada elemento— y se reconoce contando, no midiendo. Si en vez de sesenta líneas
vieras una sola lenta, saltarías al paso 3.

### Paso 2 — ¿el pipeline sustituye al N+1 o lo esconde?

Supongamos que ya lo resolvieron con un `$lookup`. Míralo antes de celebrar:

```js
> db.tickets.aggregate([
    { $lookup: { from: "comments", localField: "_id", foreignField: "ticketId", as: "comments" } },
    { $match: { status: "open" } }
  ]).explain("executionStats").stages[0].$cursor.executionStats
{ nReturned: 100000, totalDocsExamined: 100000, executionTimeMillis: 3184 }
```

**Qué descarta.** Descarta el índice y apunta al **orden de las etapas**: el
`$match` está después del `$lookup`, así que el motor une los 100.000 tickets
con sus comentarios y **después** se queda con los abiertos. Es el `WHERE` que
tu instinto jamás habría puesto al final en SQL, y acá se escribe así todos los
días porque el pipeline se lee como una receta. Con el `$match` primero:

```js
{ nReturned: 41230, totalDocsExamined: 41230, executionTimeMillis: 帮412 }
```

### Paso 3 — ¿el resultado tiene la forma que esperas?

Dos síntomas que llegan como tickets distintos y son el mismo malentendido:

```js
> db.tickets.aggregate([{ $lookup: { … , as: "comments" } }]).next()
{ _id: ObjectId("…"), title: 'La impresora no imprime',
  comments: [ { … }, { … } ] }        // ⚠️ un array, no filas planas
```

Y su reverso, cuando alguien lo "arregla" con `$unwind`:

```js
> db.tickets.aggregate([
    { $lookup: { …, as: "comments" } },
    { $unwind: "$comments" }
  ]).toArray().length
63          // de 100 tickets
```

**Qué descarta.** Descarta un bug de datos: los 37 tickets que faltan no se
borraron, **los quitó el `$unwind`**. Un `$unwind` sin
`preserveNullAndEmptyArrays: true` descarta los documentos con el array vacío:
tu LEFT JOIN se volvió INNER JOIN sin avisar. Y la forma con array no es un
error del `$lookup`: es lo que hace por diseño —agrupa—, y quien esperaba filas
planas estaba traduciendo literalmente un JOIN.

### Paso 4 — ¿el pipeline interno corre una vez o N veces?

Cuando un `$lookup` con `let` iba bien y se degrada al crecer:

```js
{ $lookup: {
    from: "comments",
    let: { tid: "$_id" },
    pipeline: [
      { $match: { $expr: { $eq: ["$ticketId", "$$tid"] } } },
      { $sort: { createdAt: -1 } },      // ⚠️ por CADA ticket
      { $limit: 3 }
    ],
    as: "lastComments" } }
```

**Qué descarta.** Descarta la consulta externa. Ese pipeline interno se ejecuta
**una vez por cada documento de la izquierda**: un `$sort` caro ahí dentro se
multiplica por 100.000. Es el equivalente exacto de la subconsulta correlacionada
que en tu motor de siempre aprendiste a temer, y acá no tiene un plan de
ejecución que te la señale con nombre propio.

### Paso 5 — la pregunta que la fase te obliga a hacer

Con los números anteriores, la conversación deja de ser técnica:

```
tickets   ←→ comments      3 lookups por pantalla
tickets   ←→ users         1 lookup por pantalla
comments  ←→ users         1 lookup anidado
```

**Qué descarta.** Descarta la optimización como solución. Una **cadena** de
lookups no es una consulta que afinar: es el síntoma de que el modelo se diseñó
como un esquema relacional y se guardó en Mongo. La pregunta es si esos datos se
leen siempre juntos —y entonces debían **embeberse**— o si de verdad son
entidades independientes. La fase da el criterio y la
[Fase 8](forense-fase-08.md) lo mide con `soporte_v1` en la mesa de autopsias.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Una pantalla hace decenas de peticiones | N+1: cuenta las consultas antes de medirlas |
| El `$lookup` devuelve arrays donde esperabas filas | Agrupa por diseño: no es un JOIN |
| Desaparecieron documentos al agregar `$unwind` | Falta `preserveNullAndEmptyArrays`: LEFT convertido en INNER |
| El pipeline iba rápido y se degradó al crecer | Falta el `$match` previo, o el `let` interno corre por documento |
| `$sort` que revienta con error de 100 MB | Sin `allowDiskUse`, y si lo pones en un endpoint caliente, era un batch |
| Una cadena de tres lookups | El modelo, no la consulta: pregunta si debió embeberse |
| Un batch con `$in` "modernizado" a `$lookup` y ahora va peor | Se cambió sin medir: `$in` sano era mejor |
| Copias denormalizadas que divergen | Denormalizar sin protocolo de reconciliación |
| La reconciliación nocturna tarda horas | Recorre todo: acota con `updatedAt` |

---

## ⚰️ Los callejones

**"Le pongo un índice al `$lookup` y listo."** El índice sobre `ticketId` es
necesario y no suficiente: si el `$match` está después, seguirás uniendo 100.000
documentos antes de filtrar. El orden de las etapas manda sobre el índice, y es
gratis cambiarlo.

**"Meto todo en un solo pipeline para hacer una sola petición."** Reduce el
número de viajes y puede empeorar el tiempo total: un pipeline que une tres
colecciones y ordena por un campo sin índice es una sola petición larguísima.
Menos peticiones no es lo mismo que menos trabajo.

**"En SQL esto era un JOIN de tres tablas y volaba."** Es verdad, y por eso duele.
El motor relacional tenía un optimizador que reordenaba tu consulta y estadísticas
para elegir el plan; acá el orden que escribes es, en buena medida, el orden que
corre. El instinto sigue siendo bueno —filtrar antes de unir—, lo que cambió es
que ahora es **tu** responsabilidad escribirlo así.

---

## 🧠 El patrón transferible

**Un `$lookup` frecuente es una pregunta sobre el modelo disfrazada de consulta.**
La técnica de esta pieza —contar peticiones, mirar el orden de las etapas, medir
`totalDocsExamined`— sirve para localizar el coste, pero el hallazgo casi nunca
es "esta consulta está mal escrita": es "estos datos se leen siempre juntos y
están guardados separados".

Lo que se transfiere fuera de Mongo: **cuando la lentitud crece con el volumen y
no con el código, deja de mirar líneas y empieza a mirar accesos.** Cuántas
idas y vueltas, cuántos documentos examinados por documento devuelto, y qué se
lee siempre en compañía de qué. Esas tres preguntas resuelven la mayoría de los
"antes iba bien" de cualquier base de datos.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 5](05-lookup-y-por-que-es-una-alarma.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 05](cuaderno-incidentes.md); y la autopsia con números en la
[pieza de la Fase 8](forense-fase-08.md).
EOF
wc -l forense-fase-04.md forense-fase-05.md

# --- 2026-09-10T01:53:33 · Fix stray character and scan for others
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
python3 - <<'PY'
p='forense-fase-05.md'
s=open(p,encoding='utf-8').read()
s=s.replace("executionTimeMillis: 帮412","executionTimeMillis: 412")
open(p,'w',encoding='utf-8').write(s)
PY
grep -n "executionTimeMillis" forense-fase-05.md; LC_ALL=C grep -n '[^\x00-\x7F]' forense-fase-05.md | grep -vE '📄|🕵️|⚠️|🎫|🧭|🩺|⚰️|🧨|🧠|⭐|💸|🔑|📝|💡|🧩|🪞|→|←|—|–|…|●|·|✅|❌|“|”|‘|’|á|é|í|ó|ú|ñ|ü|¿|¡|Á|É|Í|Ó|Ú|Ñ' | head

# --- 2026-09-10T01:54:34 · Write course 02 piece for phase 6
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat > forense-fase-06.md <<'EOF'
# 🕵️ Forense Fase 06 — "Dos agentes tomaron el mismo ticket" ⭐

> **Sale de:** [Fase 6 — Atomicidad, transacciones y consistencia](06-atomicidad-transacciones-consistencia.md)
> · **Herramientas:** dos sesiones de `mongosh`, `matchedCount` /
> `modifiedCount`, y el log de la API · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** dos operaciones que deberían excluirse mutuamente
> tuvieron éxito las dos, y ninguna dio error.

Ésta es la pieza donde el instinto relacional falla por una razón muy concreta:
en tu motor de siempre, la transacción era gratis y estaba puesta por defecto en
la mitad de los frameworks. Acá **no hay nada puesto**, y el bug no se ve nunca
en desarrollo, donde eres un solo usuario haciendo una cosa a la vez.

---

## 🎫 El ticket

> "Ana y yo tomamos el mismo ticket casi al mismo tiempo. A los dos nos dijo que
> quedó asignado. En la pantalla de ella figura ella, en la mía figuro yo, y en
> el listado aparece asignado a Ana. Nadie recibió ningún error."
>
> — agente de soporte · **Ambiente:** UAT, con dos usuarios reales

Este ticket es un regalo: trae la reproducción incluida. La mayoría llegan como
"a veces se pierden asignaciones", sin nombres y sin hora.

---

## 🧭 La ruta

Del más barato al más caro: primero se lee lo que la propia escritura devolvió,
después se mira el código, después se reproduce, y la transacción —la
herramienta cara— se discute al final y casi siempre se descarta.

### Paso 1 — ¿qué devolvió cada escritura?

En el log de la API, o repitiendo la operación en `mongosh`:

```js
> db.tickets.updateOne({ _id: id }, { $set: { assignee: "soporte1", status: "in_progress" } })
{ acknowledged: true, matchedCount: 1, modifiedCount: 1 }
> db.tickets.updateOne({ _id: id }, { $set: { assignee: "soporte2", status: "in_progress" } })
{ acknowledged: true, matchedCount: 1, modifiedCount: 1 }
```

**Qué descarta.** Descarta cualquier fallo del motor: las dos escrituras hicieron
exactamente lo que se les pidió, y la segunda pisó a la primera con todo el
derecho del mundo. **El filtro no dice nada sobre quién puede tomar el ticket**:
dice "este ticket", y ese ticket existe. No hubo carrera perdida: hubo dos
carreras ganadas.

### Paso 2 — ¿el código lee y después escribe?

El sospechoso tiene una forma reconocible, y se busca sin leer todo el archivo:

```bash
grep -n "findOne" -A 6 src/services/ticketService.js
```

```js
var ticket = await tickets.findOne({ _id: id });
if (ticket.assignee) {
  throw new ConflictError("El ticket ya está asignado");
}
await tickets.updateOne({ _id: id }, { $set: { assignee: user } });
```

**Qué descarta.** Cierra el diagnóstico. Entre el `findOne` y el `updateOne` hay
una ventana, y esa ventana es el bug: los dos procesos leyeron "sin asignar" y
los dos escribieron. La comprobación existe, está bien escrita y **no sirve**,
porque comprobar y escribir son dos operaciones distintas. En tu motor de
siempre, un `SELECT … FOR UPDATE` dentro de una transacción tapaba esto sin que
tuvieras que pensarlo.

### Paso 3 — reproducirlo a voluntad

Sin reproducción no hay caso, y con dos sesiones de `mongosh` alcanza. En la
primera, prepara el ticket libre; después ejecuta en las dos, lo más seguido que
puedas:

```js
// sesión A y sesión B, casi a la vez
db.tickets.updateOne({ _id: id }, { $set: { assignee: "soporte1" } })
db.tickets.updateOne({ _id: id }, { $set: { assignee: "soporte2" } })
```

```
A: { matchedCount: 1, modifiedCount: 1 }
B: { matchedCount: 1, modifiedCount: 1 }
```

**Qué descarta.** Descarta la idea de que haga falta carga o concurrencia real
para verlo: dos terminales bastan. Y demuestra la parte incómoda: **el bug es
determinista**, no intermitente. Lo intermitente era que dos personas
coincidieran, no que el sistema fallara.

### Paso 4 — la precondición va en el filtro

Ahora la misma operación, escrita como una sola:

```js
> db.tickets.updateOne(
    { _id: id, assignee: null },
    { $set: { assignee: "soporte1", status: "in_progress" } })
{ matchedCount: 1, modifiedCount: 1 }
> db.tickets.updateOne(
    { _id: id, assignee: null },
    { $set: { assignee: "soporte2", status: "in_progress" } })
{ matchedCount: 0, modifiedCount: 0 }        // ← el segundo pierde, y se entera
```

**Qué descarta.** Descarta la necesidad de una transacción para este caso: una
escritura sobre **un** documento ya es atómica, y meter la precondición en el
filtro convierte el "comprobar y escribir" en una sola operación indivisible.

Y trae de regalo la distinción que el contrato necesita: `matchedCount: 0` **no
significa "no existe"**. Puede existir y no cumplir la precondición. Son dos
respuestas distintas —404 y 409— y confundirlas produce el reporte gemelo: *"me
dice que el ticket no existe y ahí está"*.

### Paso 5 — ¿y cuando de verdad hay que tocar dos documentos?

Si el caso involucra dos colecciones —crear el ticket y su primer comentario, por
ejemplo— y una de las dos escrituras aparece a veces sola:

```js
await session.withTransaction(async function () {
  await tickets.insertOne(doc, { session });
  await comments.insertOne(comment);      // ⚠️ sin { session }
});
```

**Qué descarta.** Descarta el motor y las transacciones como culpables. Una
operación sin `{ session }` corre **fuera** de la transacción, sin error y sin
aviso: si algo falla después, se revierte lo de dentro y se queda lo de fuera. Es
el fallo más traicionero de la fase, porque el código *parece* transaccional y el
`withTransaction` reporta éxito.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Dos operaciones excluyentes que ambas tuvieron éxito | Read-modify-write: la precondición no está en el filtro |
| Un contador quedó corto tras un pico | `doc.n++; save()` es una carrera con disfraz: usa `$inc` |
| `matchedCount: 0` y el documento existe | Tu filtro llevaba precondición: es 409, no 404 |
| La transacción "funcionó" y falta una escritura | Falta `{ session }` en alguna operación |
| La transacción aborta con conflictos bajo carga | Trabajo lento o llamadas externas dentro de `withTransaction` |
| El código comprueba y falla igual | La ventana entre comprobar y escribir |
| El test de concurrencia pasa siempre | Una sola ronda: la carrera es probabilística (Fase 13) |
| Todo va bien en desarrollo y falla en UAT | En desarrollo eres un usuario haciendo una cosa a la vez |

---

## ⚰️ Los callejones

**"Hay que meter una transacción."** Es el reflejo que trae todo el mundo desde
SQL, y en este caso es **de más**: una escritura sobre un solo documento ya es
atómica, y envolverla en una transacción paga precio —sesión, límite de 60 s,
conflictos— por una garantía que ya tenías. Las transacciones son para varios
documentos, y son la excepción, no la norma.

**"Es que Mongo no tiene bloqueos."** Los tiene, y no es lo que falta acá. Lo que
falta es que la condición del negocio esté **dentro** de la operación que
escribe. Es el mismo `UPDATE … WHERE assignee IS NULL` que habrías escrito en
SQL sin pensarlo — la diferencia es que allá la transacción por defecto te
perdonaba escribirlo mal.

**"Lo arreglo con un reintento."** Reintentar una operación mal condicionada la
repite mal. Y peor: esconde el conflicto en vez de reportarlo, cuando el
conflicto es información que el usuario necesita —*"Ana se te adelantó"* es una
respuesta útil; un reintento silencioso que reasigna el ticket, no.

---

## 🧠 El patrón transferible

**Comprobar y actuar son la misma operación, o no son nada.** Da igual el motor,
el lenguaje o la capa: en cuanto entre la comprobación y el efecto hay una
ventana, alguien se va a meter por ella. Lo que cambia entre tecnologías es
**quién te tapaba esa ventana sin que lo supieras** — en tu base relacional, la
transacción implícita del framework; acá, nadie.

Y el corolario que vale para diseñar contratos de API: **"no pasó nada" tiene al
menos dos motivos, y el usuario merece saber cuál.** No existe y no cumplió la
condición son 404 y 409, y colapsarlos en el mismo mensaje convierte un conflicto
legítimo en un misterio.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 6](06-atomicidad-transacciones-consistencia.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 06](cuaderno-incidentes.md); y cómo se prueba de verdad una carrera,
en la [pieza de la Fase 13](forense-fase-13.md).
EOF
wc -l forense-fase-06.md

# --- 2026-09-10T01:55:22 · Write course 02 piece for phase 7
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat > forense-fase-07.md <<'EOF'
# 🕵️ Forense Fase 07 — "El índice está creado y `explain()` sigue diciendo COLLSCAN"

> **Sale de:** [Fase 7 — Índices](07-indices.md) ·
> **Herramientas:** `explain("executionStats")`, `getIndexes()` y `currentOp()`
> · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el índice existe, la consulta no lo usa, y nadie
> explica por qué.

Todo lo que sabes de índices en tu motor relacional sigue valiendo acá:
selectividad, prefijo izquierdo, el coste en las escrituras. Lo que cambia es la
**herramienta de diagnóstico** y su capacidad de mentir. Esta pieza es, sobre
todo, un curso de lectura de `explain()`.

---

## 🎫 El ticket

> "Creamos el índice que dijiste y la consulta sigue igual de lenta. Lo verifiqué
> en Compass, ahí está el índice. ¿Hay que reiniciar Mongo para que lo tome?"
>
> — el compañero que está optimizando el listado · **Ambiente:** UAT

No hay que reiniciar nada, y ésa es la primera cosa que conviene sacar de la
conversación: los índices se usan —o no— consulta por consulta.

---

## 🧭 La ruta

Del más barato al más caro. Y una advertencia sobre el orden: mucha gente empieza
creando índices, que es el paso caro. Acá se empieza mirando.

### Paso 1 — ¿qué índices hay, exactamente?

```js
> db.tickets.getIndexes()
[
  { v: 2, key: { _id: 1 }, name: '_id_' },
  { v: 2, key: { createdAt: -1, status: 1 }, name: 'createdAt_-1_status_1' }
]
```

**Qué descarta.** Descarta la duda de si el índice existe y, de paso, ya deja ver
el problema más probable: el orden de las claves. Guárdalo para el paso 3.

### Paso 2 — ¿qué dice el plan, con los números?

Nunca el `explain()` a secas: siempre con estadísticas de ejecución.

```js
> db.tickets.find({ status: "open" }).sort({ createdAt: -1 })
    .explain("executionStats").executionStats
{
  nReturned: 41230,
  executionTimeMillis: 1874,
  totalKeysExamined: 0,
  totalDocsExamined: 100000,
  executionStages: { stage: 'COLLSCAN', … }
}
```

**Qué descarta.** Descarta la sensación y la reemplaza por dos números. La razón
que importa es **`totalDocsExamined` frente a `nReturned`**: examinar 100.000
para devolver 41.230 es un COLLSCAN, y el `stage` lo confirma. Si el `stage`
dijera `IXSCAN` pero la razón siguiera siendo mala, el diagnóstico sería otro —
paso 4.

### Paso 3 — ¿el compuesto está en el orden correcto?

Con el índice del paso 1 y la consulta del paso 2, el desajuste salta:

```
Índice:   { createdAt: -1, status: 1 }
Consulta: filtra por status, ordena por createdAt
```

**Qué descarta.** Cierra el caso más común. El prefijo izquierdo del índice es
`createdAt`, y la consulta no filtra por ese campo: el índice no puede arrancar
por ahí, así que no se usa. Con `{ status: 1, createdAt: -1 }` el filtro entra
por el prefijo y el orden sale gratis del propio índice — sin etapa `SORT`, que
es la otra pista que el `explain()` te grita cuando el compuesto está al revés.
Es exactamente la regla de prefijo izquierdo que ya conoces; lo nuevo es dónde
leerla.

### Paso 4 — usa el índice y sigue lento

El caso que más despista, porque el `stage` dice lo que querías leer:

```js
> db.tickets.find({ title: /impresora/i }).explain("executionStats").executionStats
{ nReturned: 20, totalKeysExamined: 100000, totalDocsExamined: 90000,
  executionStages: { stage: 'IXSCAN', … } }
```

**Qué descarta.** Descarta la etapa como criterio: **un IXSCAN que examina 90.000
documentos para devolver 20 es un COLLSCAN con corbata.** Un regex no anclado
—y encima insensible a mayúsculas— recorre el índice entero; solo un
`^impresora` puede aprovecharlo. La regla es la misma que la del `LIKE '%algo%'`
de siempre, con la diferencia de que acá el plan no te dice "no puedo": te dice
que usó el índice.

### Paso 5 — ¿el problema es la consulta o el modelo?

Antes de crear el siguiente índice, la pregunta que la fase pone con todas las
letras:

```js
> db.tickets.find({ status: "open" }).sort({ createdAt: -1 }).limit(20)
    .explain("executionStats").executionStats
{ nReturned: 20, totalKeysExamined: 20, totalDocsExamined: 20,
  executionTimeMillis: 3 }
```

Y la pantalla sigue tardando cuatro segundos.

**Qué descarta.** Descarta los índices por completo, y es el meta-error de la
fase: **seguir afinando índices cuando el `explain()` ya está limpio y lo lento
es el modelo.** Si cada consulta es óptima y la pantalla sigue lenta, el coste
está en el número de consultas o en la forma de los datos — que es la
[pieza de la Fase 5](forense-fase-05.md).

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| El índice existe y el plan dice COLLSCAN | Prefijo izquierdo, o tipos que no coinciden |
| IXSCAN y sigue lento | `totalDocsExamined` contra `nReturned`: la razón es el diagnóstico |
| Aparece una etapa SORT | El compuesto está al revés para esa consulta |
| Un regex que no usa el índice | Solo el anclado (`^…`) puede: el flotante recorre todo |
| El TTL no borra nada y no avisa | Está sobre fechas guardadas como string (Fase 1) |
| Un índice unique que rechaza documentos legítimos | Los documentos **sin** el campo también compiten por el `null` |
| Los inserts se volvieron lentos | Índices nuevos en una colección de escritura intensa |
| El plan cambia entre corridas | Plan cacheado: el que ves puede no ser el que corrió |
| Todo óptimo y la pantalla sigue lenta | Es el modelo o el N+1, no los índices (Fase 5) |
| "Mongo va lento" sin más datos | Pide la consulta y su `explain()` antes de proponer nada |

---

## ⚰️ Los callejones

**"Creo un índice por cada campo importante."** Indexar por catálogo es el error
de instinto más caro de la fase: cada índice se paga en cada escritura, y una
colección con doce índices tiene los inserts lentos y probablemente sigue sin
cubrir la consulta real. Se indexa **por consulta del contrato**, no por campo.

**"Hay que reiniciar Mongo para que tome el índice."** No. Los índices están
disponibles al instante; lo que puede engañarte es el **plan cacheado**, que hace
que una consulta siga usando el plan elegido antes. Es la mentira característica
de `explain()` y conviene conocerla antes de sacar conclusiones de dos
mediciones seguidas.

**"Ya está indexado, entonces es rápido."** Es la conclusión que el paso 4
desmiente. "Usa índice" y "usa bien el índice" son afirmaciones distintas, y solo
la segunda se puede comprobar — mirando cuántos documentos examinó para devolver
los que devolvió.

---

## 🧠 El patrón transferible

**Un plan de ejecución no se lee por su etiqueta, se lee por su aritmética.** La
razón entre lo examinado y lo devuelto es el único número que no se puede
maquillar: si es cercana a 1, el acceso es sano; si es de miles a uno, da igual
lo que diga la etapa. Ese criterio es idéntico en cualquier motor que hayas usado
—solo cambian los nombres de las columnas del plan— y es lo que te permite
opinar sobre una consulta que no escribiste tú.

Y la disciplina que va con él: **mide antes, mide después, y con las mismas
condiciones.** Una medición con caché caliente contra otra con caché fría no
compara nada, y es la forma más común de "demostrar" una mejora que no existe.

**Sigue por acá:** el resumen en la sección 6 de la [Fase 7](07-indices.md); el
índice de síntomas en [`forense-master.md`](forense-master.md); el caso completo
en el [incidente 07](cuaderno-incidentes.md); y qué hacer cuando el problema
resulta ser el modelo, en la [pieza de la Fase 8](forense-fase-08.md).
EOF
wc -l forense-fase-07.md

# --- 2026-09-10T01:55:28 · Read phase 8 structure
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
grep -n '^## \|^### ' 08-la-autopsia.md | head -20; grep -n "soporte_v1" 08-la-autopsia.md | head -5; sed -n '1,40p' 08-la-autopsia.md

# --- 2026-09-10T01:56:22 · Write course 02 piece for phase 8
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat > forense-fase-08.md <<'EOF'
# 🕵️ Forense Fase 08 — "La migración pasó el conteo y los datos son basura"

> **Sale de:** [Fase 8 — La autopsia](08-la-autopsia.md) ·
> **Herramientas:** el muestreo campo a campo (no el conteo), `mongosh` y el
> cronómetro con condiciones iguales · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** la migración terminó, los números cuadran, y los
> datos no significan lo que dicen.

Una migración es el único trabajo de este curso donde **el error se descubre
tarde y ya no hay origen al que volver**. Por eso la pieza no va sobre arreglar:
va sobre verificar, que es lo que nadie hace hasta la segunda vez que le pasa.

---

## 🎫 El ticket

> "La migración a `soporte_v2` terminó bien anoche, el reporte dice 100.000
> tickets migrados de 100.000. Pero el listado sale raro: hay tickets cerrados
> que aparecen como abiertos, y a varios les cambió el asignado. Los conteos por
> estado ahora no cuadran con los de la semana pasada."
>
> — el analista de reportes · **Ambiente:** la base migrada

Un reporte de conteos en verde y datos corridos es la firma de una verificación
que contó filas en vez de mirar contenido.

---

## 🧭 La ruta

Del más barato al más caro: comparar totales cuesta dos comandos, muestrear
cuesta cinco minutos, y rehacer la migración es el final del camino, no el
principio.

### Paso 1 — ¿los totales cuadran de verdad?

```js
> use soporte_v1
> db.tickets.countDocuments()
100000
> use soporte_v2
> db.tickets.countDocuments()
100000
```

**Qué descarta.** Descarta la pérdida de documentos y **nada más**. Es
importante decirlo así, porque este paso es donde la mayoría de las migraciones
declaran victoria: un conteo igual demuestra que hay la misma cantidad de cosas,
no que sean las mismas cosas. Sigue al paso 2 sin celebrar.

### Paso 2 — muestreo campo a campo

Toma documentos concretos de los dos lados y compáralos:

```js
> var sample = db.getSiblingDB("soporte_v1").tickets.find().limit(5).toArray()
> sample.map(function (t) { return { id: t.ticket_id, status: t.status_id, who: t.assignee_id }; })
[ { id: 1, status: 4, who: 12 }, { id: 2, status: 1, who: null }, … ]

> db.tickets.find({ legacyId: { $in: [1, 2] } }, { legacyId: 1, status: 1, assignee: 1 }).toArray()
[ { legacyId: 1, status: 'open',   assignee: 'ana' },
  { legacyId: 2, status: 'closed', assignee: null } ]
```

**Qué descarta.** Ahí está el caso: el ticket 1 era `status_id: 4` y quedó como
`open`; el 2 era `1` y quedó `closed`. **El mapa de estados está corrido una
posición** — el clásico off-by-one de todo diccionario de traducción, casi
siempre por indexar un arreglo desde 0 cuando los ids del origen empiezan en 1.
Los conteos globales por estado pueden incluso coincidir si el corrimiento es
uniforme, que es lo que hace este bug tan difícil de ver desde arriba.

### Paso 3 — ¿en qué orden se migró?

Si además hay referencias que no resuelven:

```js
> db.tickets.countDocuments({ assignee: null })
41210
> db.getSiblingDB("soporte_v1").tickets.countDocuments({ assignee_id: null })
7
```

**Qué descarta.** Descarta el mapa de estados y apunta al **orden de ejecución**:
si `tickets` se migró antes que `users`, el script no tenía todavía el mapa de
traducción `user_id → username` y resolvió a `null` sin quejarse. Por eso la
fase migra usuarios primero y no por gusto: **las referencias se resuelven contra
algo que ya existe, o no se resuelven.**

### Paso 4 — ¿se puede volver a correr?

Antes de arreglar nada, comprueba con qué herramienta cuentas:

```bash
node scripts/migrate-02-tickets.js --dry
```

```
[dry] 100000 documentos serían insertados en soporte_v2.tickets
[dry] 0 actualizaciones
```

**Qué descarta.** Descarta —o confirma— la posibilidad de repetir. Un script
idempotente se puede volver a correr sobre el resultado anterior sin duplicar ni
corromper; uno que no lo es, te obliga a limpiar y empezar de cero, y en un
sistema real eso significa otra ventana de mantenimiento. Si el `--dry` de una
segunda corrida anuncia 100.000 inserciones nuevas en vez de actualizaciones, no
es idempotente y ése es el primer arreglo, antes que el mapa de estados.

### Paso 5 — la re-medición que cierra la autopsia

Con los datos ya correctos, el último paso es el que le da sentido al trabajo:

```js
> db.tickets.find({ status: "open" }).sort({ createdAt: -1 }).limit(20)
    .explain("executionStats").executionStats.executionTimeMillis
3
```

**Qué descarta.** Descarta las opiniones. La tabla de la autopsia —la misma
operación medida en v1 crudo, v1 indexado y v2— es lo que convierte "el modelo
nuevo es mejor" en una afirmación defendible. Con una condición que hay que
vigilar: **las tres mediciones tienen que hacerse en las mismas condiciones**;
una con caché caliente y otra con caché fría produce una mejora que no existe, y
es la forma más común de mentir sin querer en un informe.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Conteos iguales y datos incorrectos | Verificaste cantidad, no contenido: muestrea campo a campo |
| Un campo enumerado corrido una posición | El mapa de traducción y su índice de origen |
| Referencias que quedaron en `null` | Orden de migración: los referenciados van primero |
| Correr el script dos veces duplicó datos | No es idempotente: `--dry` y `upsert` por clave estable |
| El proceso se queda sin memoria | Se cargó todo en memoria: cursor y lotes |
| La mejora medida no se nota en producción | Caché caliente en una medición y fría en la otra |
| El informe solo trae mejoras | Falta lo que empeoró: sin eso no es un informe, es una venta |
| No sabes a qué modelo migrar | El diagnóstico no está cerrado: migrar sin destino es el pecado original |

---

## ⚰️ Los callejones

**"Los conteos cuadran, la migración está bien."** Es el callejón que produce
este ticket. Cien mil documentos con el `status` corrido pasan cualquier
verificación por cantidad y son basura. La verificación por muestreo cuesta
cinco minutos y es la diferencia entre descubrirlo hoy o descubrirlo cuando
alguien tome una decisión con esos reportes.

**"Lo arreglo con un `updateMany` rápido."** A veces es exactamente eso, pero
solo si sabes con precisión qué documentos están mal y por qué. Un `updateMany`
sobre datos que ya fueron transformados una vez —y quizá dos, si el script corrió
dos veces— puede corregir unos y romper otros. Primero el diagnóstico, después el
bisturí.

**"Migrar a Mongo hizo esto más lento, entonces Mongo es peor."** Puede ser
cierto y hay que estar dispuesto a escribirlo — el informe honesto incluye lo que
empeoró. Pero antes comprueba qué mediste: `soporte_v1` era un esquema relacional
guardado en Mongo, y comparar contra él no dice nada sobre Mongo; dice sobre el
modelo. Esa distinción es el corazón del curso.

---

## 🧠 El patrón transferible

**Verificar una migración por conteo es contar cajas sin abrirlas.** El número de
documentos es la propiedad más fácil de preservar y la que menos información
aporta: casi cualquier bug de transformación la respeta. Lo que hay que
comparar es contenido, y no hace falta comparar todo — un muestreo de veinte
documentos elegidos por los extremos (el más viejo, el más nuevo, los que tenían
campos nulos, los que tenían referencias rotas) encuentra el 90% de los errores.

Y la disciplina que sostiene todo lo demás: **un script de migración es código de
producción**, con dry-run, idempotencia y verificación propia. La diferencia con
el resto de tu código es que este se ejecuta una vez, de noche, con todo el
mundo esperando — que es justo cuando peor se improvisa.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 8](08-la-autopsia.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 08](cuaderno-incidentes.md); y el modelo que originó todo esto, en la
[pieza de la Fase 5](forense-fase-05.md).
EOF
wc -l forense-fase-08.md

# --- 2026-09-10T01:56:30 · Read full inline piece of phase 13
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
sed -n "$(grep -n '🩻 Pieza forense — "verde en mi máquina' 13-testing-de-api.md | cut -d: -f1),+45p" 13-testing-de-api.md

# --- 2026-09-10T01:57:23 · Promote phase 9 inline piece to file
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat > forense-fase-09.md <<'EOF'
# 🕵️ Forense Fase 09 — "Mi GROUP BY devuelve UNA fila"

> **Sale de:** [Fase 9 — Aggregation](09-aggregation.md) ·
> **Herramientas:** `mongosh`, corriendo el pipeline **etapa por etapa** ·
> **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el pipeline no falla, devuelve un documento, y
> ese documento es el total global de algo que querías desglosar.

Esta pieza promueve a archivo el recorrido que la Fase 9 ya traía en su sección
6, y le agrega el método que lo generaliza. El caso es el bug silencioso número
uno de la agregación en esta época, y su gracia pedagógica es que **la salida te
confiesa la causa** si sabes qué mirar.

---

## 🎫 El ticket

> "El reporte de tickets por estado dejó de funcionar. No da error, pero en vez
> de la tabla por estado sale una sola línea con el total de todo. Lo heredé de
> quien se fue, no lo he tocado."
>
> — el analista de reportes · **Ambiente:** desarrollo

---

## 🧭 La ruta

Del más barato al más caro: la salida ya está en pantalla y contiene la
respuesta; después se corre el pipeline por etapas; el código es lo último.

### Paso 1 — mira el `_id` de la salida

El pipeline heredado y lo que devuelve:

```js
db.tickets.aggregate([
  { $group: { _id: "status", total: { $sum: 1 } } }
])
// salida real:
// [ { "_id" : "status", "total" : 100000 } ]
```

**Qué descarta.** Descarta los datos, el índice y el volumen: el número es
correcto —son todos los tickets— y el problema está en cómo se agruparon. Y la
pista definitiva está en el `_id` de la salida: **dice `"status"`, el nombre del
campo, no `"open"`, que sería un valor de tus datos.** Ésa es la huella dactilar.

Tu ojo de SQL ya lo tradujo antes de leer esto: un `GROUP BY` que colapsa a una
fila es un `GROUP BY <constante>`.

### Paso 2 — la autopsia, que es un carácter

```js
{ $group: { _id: "status",  … } }    // el LITERAL de cuatro letras
{ $group: { _id: "$status", … } }    // el VALOR del campo
```

```js
db.tickets.aggregate([
  { $group: { _id: "$status", total: { $sum: 1 } } }
])
// [ { "_id":"open", "total":41230 }, { "_id":"closed", "total":38110 }, … ]
```

**Qué descarta.** Cierra el caso. Sin `$`, Mongo agrupó por una constante: un
solo grupo, todos los documentos dentro. No hay error porque no hay nada
ilegal — agrupar por un literal es una operación perfectamente válida, solo que
inútil.

### Paso 3 — el método que lo habría cazado en la primera etapa

Cuando una etapa da algo raro, no leas el pipeline entero: **córrelo por
partes**, mirando dos documentos.

```js
> db.tickets.aggregate([{ $match: { status: "open" } }, { $limit: 2 }]).toArray()
[ { _id: ObjectId("…"), title: 'La impresora…', status: 'open', … }, { … } ]
```

Añade una etapa, vuelve a mirar. Añade otra, vuelve a mirar.

**Qué descarta.** Descarta todas las etapas anteriores a la que rompe, una por
una, y es la técnica que convierte un pipeline opaco en algo depurable. Con
`$group` en particular hay un motivo extra para hacerlo: **el `$group` no
propaga los campos que no declaras**, así que una etapa posterior que "perdió"
un campo casi siempre lo perdió ahí.

### Paso 4 — ¿el filtro está donde tiene que estar?

Con el pipeline ya correcto, la otra familia de problemas de la fase:

```js
> db.tickets.aggregate([
    { $group: { _id: "$status", total: { $sum: 1 } } },
    { $match: { total: { $gt: 100 } } }        // ✅ esto es un HAVING
  ])
```

**Qué descarta.** Descarta la confusión más común de quien viene de SQL: un
`$match` **antes** del `$group` es el `WHERE` —y debe ir lo más al principio
posible, para que use índices—, y un `$match` **después** es el `HAVING`. No son
la misma etapa en distinto sitio: son dos filtros distintos con costes muy
distintos. Un `$match` que podía ir primero y quedó tercero se regala un
COLLSCAN.

### Paso 5 — el pipeline que revienta con 100 MB

Último síntoma de la fase, y el que conviene leer como diagnóstico y no como
obstáculo:

```
MongoServerError: Sort exceeded memory limit of 104857600 bytes,
but did not opt in to external sorting.
```

**Qué descarta.** Descarta el bug: el pipeline está bien escrito, y lo que hay es
un `$sort` sobre demasiados documentos. `allowDiskUse: true` lo desbloquea —y si
lo estás poniendo en un endpoint que se llama en cada carga de pantalla, acabas
de confesar que eso era un proceso por lotes disfrazado de consulta. La salida
suele ser filtrar antes, o aceptar que es un batch y sacarlo del camino
caliente.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Un `GROUP BY` que colapsa a una fila | Falta el `$` : agrupaste por el literal |
| El `_id` de la salida trae el nombre de un campo | La misma huella: revisa cada referencia a campo |
| Una etapa perdió campos que sí existían | El `$group` solo propaga lo que declaras |
| El pipeline va lentísimo | `$match` tarde: debería ir lo más al principio posible |
| `$unwind` que multiplica millones de documentos | Falta el `$match` previo (Fase 5) |
| Error de 100 MB en un `$sort` | Sin `allowDiskUse`; y si lo necesitas en caliente, era un batch |
| El `$facet` no usa el índice | El filtro indexable quedó dentro en vez de antes |
| Reescribiste un `find` como pipeline y va peor | Sin `$group`/`$unwind`/transformación, `find` + índices gana |

---

## ⚰️ Los callejones

**"El pipeline está roto, lo reescribo entero."** Es la reacción natural ante un
resultado absurdo, y tira información: el pipeline heredado funcionaba en algún
momento, y el `_id` de su salida te está diciendo exactamente qué se rompió.
Corre por etapas antes de reescribir; en el 80% de los casos el arreglo es un
carácter.

**"Es un bug de Mongo, un `GROUP BY` no puede devolver eso."** Devuelve
exactamente lo que se le pidió. El instinto SQL ayuda a **reconocer** el síntoma
—esto huele a agrupar por constante— y estorba si lo lleva a esperar un error de
sintaxis que acá no existe: agrupar por un literal es legal.

**"Le agrego un índice al `$group`."** Los índices ayudan al `$match` y al `$sort`
que van **antes**; el `$group` en sí no se indexa. Si el pipeline es lento, mira
el orden de las etapas antes de crear nada — y si el `explain()` ya está limpio,
el problema es el modelo (Fase 5).

---

## 🧠 El patrón transferible

**Cuando una etapa dé algo raro, mira su salida antes que su código.** El `_id`
de un `$group` es una confesión: si trae el nombre literal de un campo en lugar
de un valor de tus datos, te comiste un `$`. Y ese hábito —leer la salida como
evidencia, no como resultado— es lo mismo que hace la
[pieza de la Fase 2](forense-fase-02.md) con los conteos.

Lo que se transfiere a cualquier sistema de transformación de datos, sea un
pipeline de Mongo, un ETL o una cadena de `map`/`reduce`: **la unidad de
depuración no es el programa, es la etapa.** Correr una etapa, mirar dos
documentos, añadir la siguiente. Es lento de escribir y rapidísimo de depurar, y
es exactamente lo contrario de lo que hace todo el mundo la primera vez.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 9](09-aggregation.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 09](cuaderno-incidentes.md); y la relación entre pipelines y modelo,
en la [pieza de la Fase 5](forense-fase-05.md).
EOF
wc -l forense-fase-09.md

# --- 2026-09-10T01:58:15 · Promote phase 10 inline piece to file
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat > forense-fase-10.md <<'EOF'
# 🕵️ Forense Fase 10 — "El request se queda girando para siempre" ⭐

> **Sale de:** [Fase 10 — Express, el vehículo](10-express-el-vehiculo.md) ·
> **Herramientas:** los logs de morgan, `curl`, y la pestaña Network del
> frontend · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** el request entra, no vuelve, y no hay error en
> ninguna parte.

Esta pieza promueve a archivo el recorrido que la Fase 10 ya traía en su sección
6 y le añade la otra mitad de la fase: **la frontera**. Las dos cosas que se
rompen acá son el request que desaparece y el contrato que se cumple a medias, y
las dos fallan en silencio — que es lo que las hace caras.

---

## 🎫 Los dos tickets

> **1.** "La pantalla de detalle se queda cargando para siempre con ciertos
> tickets. No sale error, no sale 404, se queda con la ruedita. Otros tickets
> abren bien."
>
> **2.** "Apuntamos el frontend al backend nuevo y el dashboard sale vacío. Pero
> si hago `curl` a la API, los tickets están ahí."

El segundo es el incidente de costura por excelencia del paquete, y su
diagnóstico está en el paso 4.

---

## 🧭 La ruta

Del más barato al más caro: el log de morgan ya está escrito, `curl` cuesta diez
segundos, y el código es lo último. Y hay que leer el log **al revés** de como
sugiere el instinto.

### Paso 1 — mira el log de morgan, y su ausencia

```
GET /tickets 200 41.271 ms - 12843
GET /tickets/5f8a1c2e4b3d2f0012a4e991
```

La segunda línea nunca se completa.

**Qué descarta.** Es el paso que hay que leer con cuidado, porque contesta al
revés de lo que uno espera: en `morgan("dev")` la línea se imprime **cuando la
respuesta se cierra**. Que no haya línea **no significa que el request no
llegó**: significa que nunca se contestó. El handler entró y no salió. Descarta,
de paso, la red y el frontend.

### Paso 2 — ¿es este handler o es el servidor entero?

```bash
curl -i -m 5 http://localhost:4000/tickets/5f8a1c2e4b3d2f0012a4e991
curl -i http://localhost:4000/health
```

```
curl: (28) Operation timed out after 5001 milliseconds with 0 bytes received
HTTP/1.1 200 OK
{"ok":true,"db":"up"}
```

**Qué descarta.** Descarta que el proceso esté caído o bloqueado: atiende otras
rutas sin problema. El problema es **un** handler, no el servidor. Si `/health`
también colgara, la investigación se iría al pool de conexiones — paso 5.

### Paso 3 — el `await` sin red

Ahora sí, el código, y solo el handler que falla:

```js
router.get("/tickets/:id", async function (req, res) {
  var ticket = await service.getById(req.params.id);   // ⚠️ si esto lanza…
  res.json(serialize(ticket));
});
```

**Qué descarta.** Cierra el caso. **Express 4 no captura el rechazo de una
promesa** en un handler async: la excepción no llega al middleware de errores, el
handler muere en silencio y el request queda colgado. No es un 500 — es un
*no-response*. Confírmalo envolviendo el handler en `asyncHandler` o añadiendo
`try { … } catch (err) { next(err) }`: el mismo request pasa a devolver el 500
del middleware central —o el 404 limpio, si era eso— y morgan por fin imprime su
línea.

### Paso 4 — el frontend vacío con `curl` en verde

Segundo ticket, otra rama, misma fase. Compara lo que devuelve la API con lo que
el contrato promete:

```bash
curl -s http://localhost:4000/tickets | head -c 200
```

```json
{"data":[{"_id":"5f8a1c2e4b3d2f0012a4e991","title":"La impresora no imprime",
"createdAt":"2020-03-10T10:00:00.000Z"}]}
```

**Qué descarta.** Descarta Mongo, el service y la red: los datos están y son
correctos. Lo que falla es la **frontera**, y hay dos delitos en esa única línea:

- el **envelope reflejo** `{ data: [...] }`, cuando el frontend hace `res.data`
  de axios y espera el recurso directo — rompe todo, silenciosamente;
- el `_id` sin traducir a `id`, que es lo que
  [`00-audit-contrato.md`](00-audit-contrato.md) contrata y de lo que vive cada
  `:key` del frontend.

Ninguna de las dos produce un error: producen una pantalla vacía en el otro
extremo del sistema.

### Paso 5 — el servidor que se degrada solo

Si el síntoma no es un endpoint sino todo, a los pocos minutos:

```
MongoServerError: connection pool exhausted
```

```bash
grep -rn "MongoClient.connect" src/
```

```
src/routes/tickets.js:12:  var client = await MongoClient.connect(uri);
```

**Qué descarta.** Descarta el código de negocio: es infraestructura. Un
`MongoClient.connect` por request abre una conexión nueva cada vez y agota el
pool en minutos. El cliente se crea **una vez** al arrancar y se comparte — es el
mismo principio del singleton del socket del Curso 01, con otra librería.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Request en `pending` eterno, sin línea en morgan | Handler async sin `next(err)`: entró y no salió |
| 500 sin detalle en todos los errores | El middleware de error está, pero nadie le pasa nada |
| El frontend no muestra nada y `curl` sí trae datos | La frontera: envelope de más, o `_id` sin serializar |
| Fechas que el frontend no sabe formatear | `Date` crudo en vez de ISO en el serializer |
| Campos internos visibles en la API | Se devolvió el documento crudo: `history`, `schemaVersion` |
| Conexiones agotadas a los pocos minutos | Un `MongoClient.connect` por request |
| `?q=` que revienta con ciertos textos | Regex sin escapar: funciona hasta el primer `(` |
| `_sort=id` que no ordena | Falta traducir `id` → `_id` en el sort |
| Un id malformado devuelve 500 en vez de 404 | Falta validar el hex antes de construir el `ObjectId` |
| CORS bloqueando desde el navegador y `curl` bien | Falta el middleware de CORS: una hora perdida culpando al código |

---

## ⚰️ Los callejones

**"El servidor se cayó."** El paso 2 lo descarta en diez segundos: `/health`
responde. Un proceso Node que atiende una ruta y cuelga en otra no está caído, y
la diferencia cambia por completo dónde buscar.

**"Mongo está lento."** Es la conclusión que salta cuando algo tarda, y acá es
falsa: si el request estuviera esperando a Mongo, la consulta aparecería en
`db.currentOp()`. No aparece, porque nunca se llegó a hacer o porque ya terminó y
el que no volvió fue el handler.

**"Le pongo un timeout al frontend y listo."** Convierte un cuelgue en un error
—que es una mejora real de experiencia— y no arregla nada del servidor: el
handler sigue muriendo en silencio y el request colgado sigue consumiendo un
socket. Es un parche legítimo mientras arreglas la causa, no en lugar de
arreglarla.

**"El frontend está mal, que se adapte al envelope."** Es el callejón más caro
del paquete, porque parece razonable y viola el contrato: el frontend se escribió
contra `00-audit-contrato.md` y el backend nuevo se comprometió a honrarlo. Si de
verdad el envelope es mejor, se cambia el contrato primero — no la API en
silencio.

---

## 🧠 El patrón transferible

**Un fallo silencioso es una decisión de diseño de alguien, casi siempre del
framework.** Express 4 no captura promesas rechazadas porque nació antes de
`async/await`, y esa decisión convierte un error de negocio en un request que
desaparece. Cuando llegues a un stack nuevo, la pregunta que más rinde es
justamente ésa: **¿qué se traga este framework, y dónde reaparece?**

Y el segundo patrón, propio de las fronteras: **un contrato que se cumple a
medias no da error, da una pantalla vacía a tres capas de distancia.** Por eso el
desempate del paso 4 —`curl` contra la API, comparando con el contrato escrito—
vale más que cualquier hipótesis: separa "el dato no está" de "el dato está y no
tiene la forma pactada", que son dos investigaciones completamente distintas.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 10](10-express-el-vehiculo.md); el contrato completo en
[`00-audit-contrato.md`](00-audit-contrato.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); y el caso completo en el
[incidente 10](cuaderno-incidentes.md), que es de costura y trae el frontend ya
construido.
EOF
wc -l forense-fase-10.md

# --- 2026-09-10T01:59:53 · Write course 02 pieces for phases 12 and 13
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat > forense-fase-12.md <<'EOF'
# 🕵️ Forense Fase 12 — "Por socket llega distinto que por HTTP"

> **Sale de:** [Fase 12 — El backend habla](12-el-backend-habla.md) ·
> **Herramientas:** el cliente de socket y `curl` lado a lado, y el log del
> servidor · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** la misma información llega con dos formas
> distintas según por dónde entre, y solo una de las dos rompe la pantalla.

Un backend que habla por dos canales tiene **dos fronteras**, y casi siempre solo
la primera está bien vigilada. Esta pieza va de esa asimetría: el serializer que
todo el mundo aplica al responder un HTTP y nadie recuerda aplicar al emitir un
evento.

---

## 🎫 El ticket

> "Los tickets que llegan en vivo salen mal en la pantalla: el enlace no
> funciona y la fecha aparece rarísima. Si recargo la página, el mismo ticket se
> ve perfecto. Solo pasa con los que llegan solos."
>
> — agente de soporte · **Ambiente:** UAT

"Solo pasa con los que llegan solos" delimita el caso entero: los datos que
entran por HTTP están bien, los que entran por socket no. Dos caminos, un solo
destino.

---

## 🧭 La ruta

Del más barato al más caro: comparar los dos canales cuesta dos comandos, el log
del servidor está escrito, y el código es lo último.

### Paso 1 — pon los dos canales lado a lado

```bash
curl -s http://localhost:4000/tickets/5f8a1c2e4b3d2f0012a4e991
```

```json
{"id":"5f8a1c2e4b3d2f0012a4e991","title":"La impresora no imprime",
 "createdAt":"2020-03-10T10:00:00.000Z","status":"open"}
```

Y en la consola del navegador, escuchando el evento:

```js
> socket.on("ticket:created", function (t) { console.log(t); })
{ _id: "5f8a1c2e4b3d2f0012a4e991", title: "La impresora no imprime",
  createdAt: "2020-03-10T10:00:00.000Z", status: "open", history: [ … ],
  schemaVersion: 2 }
```

**Qué descarta.** Descarta el frontend y cierra medio caso en el primer paso.
Por HTTP llega `id`; por socket llega `_id` y, de regalo, campos internos que el
contrato no menciona. El enlace no funciona porque el componente construye la
ruta con `ticket.id`, que por este camino es `undefined`.

### Paso 2 — ¿dónde se emite?

```bash
grep -rn "emit(" src/ | grep -v node_modules
```

```
src/realtime/index.js:18:  io.emit(event, payload);
src/services/tickets.service.js:64:  realtime.emit("ticket:created", doc);
```

**Qué descarta.** Descarta el transporte: el evento sale bien, con el payload que
le dan. Lo que falta es la traducción — `doc` es el documento **crudo** de Mongo,
y el serializer que la [Fase 10](forense-fase-10.md) aplica en cada respuesta
HTTP no se aplicó acá. Una frontera vigilada, la otra no.

### Paso 3 — ¿se emite antes o después de escribir?

Con el mismo `grep` a la vista, mira el orden dentro de la función:

```js
realtime.emit("ticket:created", doc);        // ⚠️ antes
var result = await tickets.insertOne(doc);
```

**Qué descarta.** Descarta que sea solo un problema de forma. Emitir antes de
persistir reconstruye el **cliente mentiroso** del Curso 01 con más pasos: si la
escritura falla, todos los navegadores ya recibieron un ticket que no existe. El
orden correcto —escribir y después anunciar— es justamente la deuda 💸 que esta
fase viene a pagar, y hacerlo al revés la deja sin pagar.

### Paso 4 — el evento que llega dos veces

Otro reporte del mismo día, distinta causa:

```
Toast: "Nuevo ticket #47"
Toast: "Nuevo ticket #47"
```

```bash
lsof -i :4000
```

```
node    2211  oskar  … TCP *:4000 (LISTEN)
```

**Qué descarta.** Si hay un solo proceso escuchando y el evento igual llega
doble, el sospechoso es el **relé tonto** heredado: el servidor de sockets de
veinte líneas que el frontend traía sigue encendido y rebotando lo que el cliente
emite, mientras el backend nuevo emite lo suyo. Dos emisores para el mismo
hecho. Apagar el relé es parte de la fase, y olvidarlo produce exactamente este
síntoma.

Si el proceso viejo ya no está, la causa es la del Curso 01: handlers suscritos
sin dar de baja.

### Paso 5 — el socket conecta y no llega nada

Última rama, y la que más tiempo hace perder porque no se parece a un problema
de versiones:

```
(el cliente reintenta, sin mensajes claros)
```

```bash
grep -n "socket.io" package.json
```

```
"socket.io": "^4.5.0"          ← servidor
"socket.io-client": "2.4.0"    ← el del frontend, Curso 01
```

**Qué descarta.** Descarta tu código entero: el handshake de socket.io **3.x/4.x
no es compatible con el cliente 2.x**, y el fallo se manifiesta como silencio,
no como error. Media jornada garantizada si no lo conoces. El servidor tiene que
hablar la versión del cliente que ya existe, y ése es el criterio del curso: el
frontend heredado no se toca.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Por socket llega `_id` y por HTTP llega `id` | Falta el serializer en el emit |
| Campos internos que aparecen solo en vivo | Se emitió el documento crudo |
| Aparece un ticket que no está en la base | Se emitió antes de persistir |
| El mismo evento llega dos veces | Dos emisores: el relé viejo sigue encendido |
| El socket conecta y no llega nada | Versiones desparejadas: servidor 3.x/4.x contra cliente 2.4 |
| Dependencia circular al importar `io` | El singleton de `realtime/` existe para eso |
| El servidor se queda sin memoria al servir un adjunto | Se cargó el archivo entero en vez de usar el stream |
| Uploads que tumban el proceso | multer sin `limits`: es un vector de denegación de servicio |
| Adjuntos huérfanos en GridFS | La metadata va en el `openUploadStream`, no en un update posterior |

---

## ⚰️ Los callejones

**"El frontend está mal escrito."** El frontend hace lo que el contrato dice, y
el paso 1 lo demuestra: por HTTP funciona. Cuando el mismo componente pinta bien
un dato y mal el otro, el problema no es el componente — es que le llegaron dos
formas distintas de la misma cosa.

**"Emito el documento crudo y que el frontend elija lo que necesita."** Es
tentador y rompe el contrato en silencio: obliga a cada consumidor a conocer la
forma interna de tu base, y el día que cambies un campo interno romperás
pantallas que no sabías que lo usaban. **El payload de un evento es una respuesta
de API**, con la misma frontera y el mismo serializer.

**"Actualizo el cliente de socket.io a la 4 y listo."** Eso es modificar el
frontend heredado, que es exactamente lo que el paquete no hace: la promesa es
que se cambia el `baseURL` y la aplicación no se entera. El backend se adapta al
cliente que existe.

---

## 🧠 El patrón transferible

**Cada canal de salida es una frontera, y todas necesitan el mismo guardián.** Es
fácil recordar el serializer en el sitio donde se escribió la primera vez —el
handler HTTP— y olvidarlo en el segundo canal, que suele añadirse meses después:
un socket, una cola, un webhook, un correo. El resultado es siempre el mismo:
consumidores que reciben dos versiones de la verdad y bugs que solo pasan "cuando
llega en vivo".

Y la regla de oro del tiempo real, que ya venías arrastrando desde el Curso 01:
**anuncia lo que ya es cierto.** Emitir antes de confirmar la escritura es
prometer en nombre de una operación que todavía puede fallar — y quien escuche no
tiene forma de saber que le mentiste.

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 12](12-el-backend-habla.md); el contrato en
[`00-audit-contrato.md`](00-audit-contrato.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); y el caso completo en el
[incidente 11](cuaderno-incidentes.md), que es de costura y autocontenido.
EOF
cat > forense-fase-13.md <<'EOF'
# 🕵️ Forense Fase 13 — "Verde en mi máquina, rojo en CI"

> **Sale de:** [Fase 13 — Testing de API](13-testing-de-api.md) ·
> **Herramientas:** la salida de la suite, el log del `globalSetup`, y
> `serverInfo().version` · **Recorrido:** cinco pasos
>
> **El síntoma, en una línea:** la misma suite, el mismo commit, dos resultados
> distintos según dónde corra.

Esta pieza promueve a archivo el post-mortem que la Fase 13 ya traía en su
sección 6, con la estructura de ocho puntos del curso y su regla: **se analiza el
sistema, no a la persona.** Nadie rompió nada; el sistema permitía dos motores
distintos, y el arreglo es que deje de permitirlo.

---

## 🎫 El ticket

> "La suite pasa en local siempre y en CI falla una de cada tres corridas. Falla
> en `services/`, en los asserts del `$ne` y en el del upsert que colisiona. No
> hemos cambiado ese código en dos semanas."
>
> — el compañero que montó el pipeline · **Ambiente:** local y CI

---

## 🧭 La ruta

Del más barato al más caro: primero se comprueba **contra qué** estás
ejecutando, después se reproduce, y el código de los tests es lo último — porque
en este caso no tiene la culpa.

### Paso 1 — ¿contra qué motor corre cada entorno?

En la suite, o en el log del arranque del `globalSetup`:

```js
> await db.admin().serverInfo().version
'4.4.18'        // tu equipo
```

```
CI  ›  mongodb-memory-server: downloading mongod 7.0.5 …
```

**Qué descarta.** Descarta el código, los tests y la lógica de negocio de una
sola vez. Los dos entornos están midiendo **motores distintos**, y el
comportamiento de precondiciones atómicas e índices únicos —justo lo que fallaba—
cambia entre versiones. El test no es *flaky*: es correcto, y está midiendo dos
cosas.

### Paso 2 — reproducirlo en tu propia máquina

```bash
rm -rf ~/.cache/mongodb-binaries    # o la caché que use tu instalación
npx jest test/services
```

```
FAIL  test/services/tickets.service.spec.js
```

**Qué descarta.** Descarta que sea "cosa de CI", que es la conclusión cómoda y la
que deja el bug vivo. En una máquina limpia, sin binario cacheado y sin
`binary.version` fijado, `mongodb-memory-server` descarga **el más nuevo
disponible** — y tu laptop solo se salvaba porque tenía el 4.4 cacheado desde la
Fase 0.

### Paso 3 — la causa raíz, escrita como corresponde

```js
// test/globalSetup.js
module.exports = async function () {
  var server = await MongoMemoryServer.create({
    binary: { version: "4.4.18" }        // ← esto es lo que faltaba
  });
  …
};
```

**Qué descarta.** Cierra el caso: el default del paquete es traer lo último, y
nadie lo declaró. El arreglo no es un `retry` ni marcar el test como flaky, es
**fijar el binario en el repositorio** —no en la máquina de quien lo corrió
primero— y cachearlo en CI por su versión exacta, nunca por "latest".

Y la prueba de regresión que impide la reincidencia, que es un test trivial y
vale su peso en oro:

```js
it("corre contra el motor del curso", async function () {
  var info = await db.admin().serverInfo();
  expect(info.version).toMatch(/^4\.4/);
});
```

Si alguien "moderniza" el binario, grita ese test antes que los de lógica — y
grita diciendo la verdad, no un fallo de negocio que despista.

### Paso 4 — el otro flaky: el que depende del orden

Si el motor ya está fijado y el rojo persiste, cambia el sospechoso:

```bash
npx jest test/services --runInBand
```

```
PASS  test/services/tickets.service.spec.js
```

**Qué descarta.** Si en serie pasa y en paralelo falla, el problema es
**aislamiento**: suites que comparten nombres de colección sobre la misma base
efímera, o un `deleteMany` en `afterEach` que deja el resultado a merced del
orden. Se resuelve con una base por suite, no con `--runInBand` permanente —eso
esconde el problema y te cobra el tiempo en cada corrida.

### Paso 5 — el test que nunca falla

Aprovecha la investigación para comprobar lo contrario, que no reporta nadie:

```js
it("detecta el doble take", async function () {
  await Promise.all([take(id, "ana"), take(id, "beto")]);
  expect(await countAssigned(id)).toBe(1);
});
```

```
PASS
```

Rompe a propósito la precondición del filtro (Fase 6) y vuelve a correr:

```
PASS        // ⚠️ sigue verde
```

**Qué descarta.** Descarta el valor de ese verde. Una carrera es
**probabilística**: con una sola ronda, el verde es suerte. Un test de
concurrencia serio repite la operación decenas de veces, y si no lo hace, no está
probando la carrera — está probando que dos llamadas seguidas funcionan.

---

## 🩺 Diagnóstico por síntoma

| Lo que ves | Dónde empezar |
|---|---|
| Verde en local, rojo intermitente en CI | Versión del binario sin fijar: dos motores distintos |
| Falla en paralelo y pasa con `--runInBand` | Aislamiento: base o colecciones compartidas entre suites |
| Un test que nunca falla aunque rompas el código | Async sin `await`, o una sola ronda en un test de carrera |
| La suite tarda una eternidad | Un memory-server por test en vez de uno por suite |
| Tests verdes que no prueban nada | Se mockeó la colección: tu mock no reproduce `$ne` ni el upsert |
| Asserts que fallan por la forma del documento | Decide qué piso pruebas: documento crudo o contrato serializado |
| 100% de coverage y bugs en producción | El coverage detecta lo no probado; no certifica lo probado |
| Ruido de sockets en los tests de service | El singleton `realtime` con su no-op ya te protege |

---

## ⚰️ Los callejones

**"Es un test flaky, lo marco como tal y sigo."** Es la puerta de salida más
rápida y la que más caro sale: un test intermitente marcado como flaky deja de
mirarse, y el día que falle por una razón real nadie se va a enterar. Antes de
etiquetarlo, contesta la pregunta del paso 1 — contra qué está corriendo.

**"Mockeamos Mongo y se acabaron los problemas de entorno."** Y con ellos se
acaba el valor de la suite: un mock jamás va a reproducir un upsert que colisiona
ni un `$ne` que incluye ausentes, que es exactamente lo que estos tests
comprueban. Base real efímera — pero **la misma** base real que la de producción,
que es la lección de esta pieza.

**"En CI ponemos la última versión, que es más segura."** Más nueva no es más
parecida a tu producción. Si el backend va a correr en 4.4, testear en 7 es
testear otro sistema: verde en CI y rojo donde importa.

---

## 🧠 El patrón transferible

**Un test que da resultados distintos en dos sitios no es inestable: está
midiendo dos sistemas.** Antes de sospechar del test, enumera qué cambia entre
los dos entornos — versión del motor, zona horaria, orden de ejecución,
paralelismo, datos previos — y fija lo que puedas fijar. Casi siempre hay una sola
variable suelta, y casi siempre está en un default que nadie declaró.

Y la regla que se lleva uno a cualquier proyecto: **lo que no está escrito en el
repositorio, no existe.** El binario cacheado en la laptop del primero que corrió
la suite es configuración invisible, y la configuración invisible es la causa
raíz favorita de los bugs que "solo pasan en CI".

**Sigue por acá:** el resumen en la sección 6 de la
[Fase 13](13-testing-de-api.md); el índice de síntomas en
[`forense-master.md`](forense-master.md); el caso completo en el
[incidente 12](cuaderno-incidentes.md); y la carrera que estos tests intentan
cazar, en la [pieza de la Fase 6](forense-fase-06.md).
EOF
wc -l forense-fase-12.md forense-fase-13.md; ls forense-*.md | wc -l

# --- 2026-09-10T02:00:06 · Check links and stray characters in all pieces
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs
for f in 01-vue2-legacy/forense-*.md 02-complement-mongodb-backend/forense-*.md; do d=$(dirname $f); grep -o '](\.\{0,2\}[^)]*\.md[^)]*)' $f | sed 's/](//;s/)$//;s/#.*//' | sort -u | while read p; do [ -e "$d/$p" ] || echo "ROTO: $f -> $p"; done; done | sort | uniq -c | sort -rn | head
echo "=== no ascii raros ==="
LC_ALL=C grep -l '[\xE4-\xE9][\x80-\xBF][\x80-\xBF]' 01-vue2-legacy/forense-*.md 02-complement-mongodb-backend/forense-*.md 2>/dev/null | head

# --- 2026-09-10T02:01:01 · Create course 01 incident notebook header and index
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat > cuaderno-incidentes.md <<'EOF'
# 📓 Cuaderno de incidentes — Curso 01 · Vue 2 Legacy

> Doce tickets vagos, como llegan de verdad: en palabras de quien los sufre, sin
> pasos de reproducción y con la mitad de la información. Cada uno trae su
> preparación, tres pistas plegadas, sitio para tu investigación y una solución
> de referencia.

**El trato.** La solución viene incluida y está plegada por una razón: abrirla
antes de tiempo no te perjudica a mí, te perjudica a ti. El músculo que esto
entrena —leer un síntoma ambiguo y convertirlo en una pregunta con respuesta— no
se desarrolla leyendo respuestas. Si llevas cuarenta minutos atascado, abre la
pista 1. Si llevas otros veinte, la 2. Y si abres la solución, léela **después**
de haber escrito tu hipótesis, aunque sea la equivocada: comparar tu camino con
el de referencia es la mitad del valor.

Este cuaderno es del **Curso 01** y se resuelve entero sin salir de él. No cita
ninguna fase del Curso 02 ni necesita Mongo, Express ni Docker.

---

## 🧭 Cómo se trabaja un incidente

El método es el de [`forense-master.md`](forense-master.md), y las cuatro
preguntas van siempre en este orden, porque cada una cuesta un orden de magnitud
más que la anterior:

1. **¿Se reproduce, y con qué?** ¿Con un flag del inyector de caos, con un dato
   distinto, o hace falta otro código?
2. **¿Qué dice la evidencia observable, antes que el código?** Network, Vue
   DevTools, la consola.
3. **¿En qué capa está?** Componente, store, servicio HTTP o mock.
4. **¿De qué lado de la frontera está?** Lo que el mock promete contra lo que tu
   código asume.

### Las tres formas de tener el sistema roto

Cada incidente dice cuál usa, y usa **la más barata que sirve**:

```bash
CHAOS=malformed npm run mock            # 1 · un flag del inyector (Fase 3)
cp mock/db.incidente-05.json db.json    # 2 · un db.json alterno
git switch -c incidente/07 fase-07-metricas-minimas   # 3 · una rama, solo si hay que romper código
```

> ⚠️ Antes de pisar `db.json`, guarda el tuyo: `git checkout -- db.json` te
> devuelve el que commiteaste; `npm run mock:reset` lo regenera desde la semilla
> y se lleva por delante tus escenarios. La diferencia está en
> [la convención de git §🧹](../prompts/convencion-de-git-y-tags.md).

### La convención de commits

El asunto sigue este formato, para que `git log --oneline` se lea como la línea
de tiempo de la investigación:

```
incidente(05): abre — la etiqueta no aparece en la tabla
incidente(05): repro — solo con tickets que vienen sin el campo tags
incidente(05): hipótesis descartada — no es el mock, el PATCH devuelve todo
incidente(05): causa — la propiedad se agrega después de que el objeto entró
incidente(05): fix — Vue.set en el punto de actualización
incidente(05): cierre — test de regresión y post-mortem
```

Los verbos son fijos: `abre`, `repro`, `hipótesis`, `hipótesis descartada`,
`causa`, `fix`, `cierre`. **Commitea también los callejones sin salida**: un log
con seis commits de investigación y uno de fix es un registro honesto; uno que
solo muestra el fix no le sirve a nadie, y menos a ti dentro de seis meses.

Y marca el par de tags de la convención §🚑:

```bash
git tag -a inc/f05/etiqueta-invisible-roto -m "Síntoma, repro y la prueba en rojo."
# …el fix…
git tag -a inc/f05/etiqueta-invisible-fix  -m "Causa raíz, fix, y la prueba en verde."
```

### Estados

| Estado | Significado |
|---|---|
| ⬜ Sin empezar | Todavía no lo tocaste |
| 🔴 Abierto | Leído, sin reproducir |
| 🟡 En análisis | Reproducido, causa raíz sin confirmar |
| 🟢 Cerrado | Fix aplicado y prueba de regresión pasando |
| ⚪ Descartado | No se reproduce, y está documentado por qué |

---

## 📋 Índice

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| 01 | 0 | "Clonaste el repo y no me arranca, a ti sí te funciona" | Build | 🟢 | ⬜ |
| 02 | 3 | "A veces carga y a veces se queda pensando" | Integración (mock) | 🟢 | ⬜ |
| 03 | 2 | "Me sacó al login a mitad de la mañana, sin decir nada" | Estado | 🟡 | ⬜ |
| 04 | 4 | "Pongo el filtro y la tabla se queda con lo de antes" | Estado | 🟡 | ⬜ |
| 05 | 5 | "Le puse la etiqueta y la tabla no se enteró" | Reactividad | 🟡 | ⬜ |
| 06 | 6 | "Volví atrás en el asistente y perdí la descripción" | Formularios y wizard | 🟡 | ⬜ |
| 07 | 7 | "A la media hora la laptop suena como un avión" | Reactividad | 🟠 | ⬜ |
| 08 | 8 | "Se me duplican los tickets cuando entra uno nuevo" | Tiempo real | 🟠 | ⬜ |
| 09 | 9 | "Tomé el ticket y a mi compañera le sigue apareciendo libre" | Estado | 🟠 | ⬜ |
| 10 | 10 | "El contador del menú dice una cosa y la tabla otra" | Estado (Vuex) | 🟠 | ⬜ |
| 11 | 11 | "El test pasa solo cuando lo corro aislado" | Testing | 🔴 | ⬜ |
| 12 | 10 | "En el servidor de pruebas se comporta distinto que en mi máquina" | Build | 🔴 | ⬜ |

---

## 🧪 Incidentes

EOF
wc -l cuaderno-incidentes.md

# --- 2026-09-10T02:02:13 · Write incidents 1 and 2 of course 01
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 01 — "Clonaste el repo y no me arranca, a ti sí te funciona"

> **Fase:** 0 · **Categoría:** Build · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-40 min

### 🎫 El ticket

> "Me pasaron el proyecto para que empiece a mantenerlo. Corrí `npm install` y
> `npm run serve` como dice el README y me sale un muro de texto rojo que habla
> de un compilador y de plantillas. En la máquina de la persona que me lo pasó
> arranca perfecto, lo vi con mis propios ojos."

**Reportado por:** alguien que se incorpora al equipo · **Ambiente:** su máquina

### 🎯 Qué se te pide

Que arranque, y que puedas **explicar en una frase** por qué no arrancaba — la
frase importa más que el arreglo, porque este error vuelve. No vale "reinstalé
todo y ya funciona": si esa fue tu solución, no sabes qué pasó y va a repetirse
en la máquina del siguiente.

### 🔧 Preparación

La más barata de las tres: una rama, porque hay que romper el `package.json`.

```bash
git switch -c incidente/01 fase-00-setup-hola-mundo
npm install vue-template-compiler@2.6.12 --save-exact --save-dev
npm run serve
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No mires el código de la aplicación: no lo has tocado y el error aparece antes
de que se ejecute nada tuyo. Lee la **primera** línea del muro, no la última. Y
antes de leerla siquiera, contesta la pregunta más barata del track: ¿qué versión
de Node estás usando, y cuál dice el proyecto que hay que usar?

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

El error menciona dos paquetes por su nombre y sus dos versiones. Ponlas una
debajo de la otra:

```bash
npm ls vue vue-template-compiler
```

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué relación tiene que haber entre esas dos versiones? No "compatibles". La
palabra exacta que usa la Fase 0 es otra, y es más fuerte.

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** `vue@2.6.14` y `vue-template-compiler@2.6.12` en el mismo
proyecto. El compilador de plantillas y el runtime tienen que ser **idénticos**,
no compatibles: cada versión de Vue 2 genera funciones de render con una forma
que su runtime espera exactamente. El propio error lo dice, con el detalle que lo
vuelve peligroso:

```
Vue packages version mismatch:

- vue@2.6.14
- vue-template-compiler@2.6.12

This may cause things to work incorrectly. Make sure to use the same version
for both.
```

Fíjate en *"may cause things to work incorrectly"*: a veces compila igual y el
fallo aparece tres fases después, en un componente al azar. Por eso conviene
tratarlo como un error duro aunque el mensaje suene tibio.

Y el "a ti sí te funciona" tiene explicación: quien te pasó el proyecto instaló
sus dependencias cuando el `package.json` estaba sano, y su `node_modules` no se
va a mover hasta que alguien reinstale.

**Parche mínimo** — el del viernes a las seis:

```bash
npm install vue@2.6.14 vue-template-compiler@2.6.14 --save-exact
npm run serve
```

**La refactorización correcta.** El parche arregla hoy; el problema de fondo es
que el proyecto **permite** que esas dos versiones se separen. Tres cosas lo
impiden, y ninguna cuesta nada:

- fijar las dos con versión exacta, sin `^`, que es lo que la Fase 0 explica al
  diseccionar el acento circunflejo que npm escribió sin preguntarte;
- commitear el `package-lock.json` (si no está, ésta es la conversación);
- un `.nvmrc` con la versión de Node del proyecto, y el hábito de `nvm use`,
  porque la mitad de los "no me arranca" restantes son de Node y no de Vue.

**Prueba de regresión.** No es un test unitario: es una comprobación de arranque.

```json
{
  "scripts": {
    "check:versions": "node -e \"var p=require('./package.json');var a=p.dependencies.vue,b=p.devDependencies['vue-template-compiler'];if(a!==b){console.error('vue '+a+' != vue-template-compiler '+b);process.exit(1)}\""
  }
}
```

Corre `npm run check:versions` en el `preserve` o en el pipeline y el
desalineamiento deja de poder llegar a otra máquina.

**Prevención.** Documenta en el README las dos líneas que hay que ejecutar para
verificar el entorno antes de reportar nada: `node -v` contra `.nvmrc`, y
`npm ls vue vue-template-compiler`. Es el paso 1 y 2 de la
[pieza forense de la Fase 0](forense-fase-00.md), y convierte este incidente en
un minuto en vez de una tarde.

**Por qué llegó a producción.** Nadie hizo nada mal. `npm install
vue-template-compiler` sin más trae la última de la línea, el `^` del
`package.json` permite que suba sola, y el mensaje de error usa un condicional
—*"puede causar"*— que invita a ignorarlo. El sistema permitía que las dos
versiones se separaran sin que nadie se enterara hasta la siguiente instalación
limpia; el arreglo es que deje de permitirlo.

**Si tu causa fue distinta a ésta.** Si tu muro hablaba de `gyp ERR!`, tu
problema era el Node y se resuelve con `nvm use` — igual de válido, y aparece en
el mismo sitio de la pieza forense. Si era `EADDRINUSE`, tenías un proceso zombi
en el puerto y ni siquiera era un problema del proyecto. Los tres se descartan en
los dos primeros pasos del recorrido, y ése es justamente el punto.

</details>

---

## Incidente 02 — "A veces carga y a veces se queda pensando"

> **Fase:** 3 · **Categoría:** Integración (mock) · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-50 min

### 🎫 El ticket

> "La lista de tickets a veces carga y a veces se queda cargando para siempre.
> No sale ningún error, se queda con la ruedita dando vueltas. Si le doy F5
> varias veces al final entra. Ah, y a veces entra pero sale vacía como si no
> hubiera tickets, y sí hay."

**Reportado por:** agente de soporte · **Ambiente:** desarrollo

### 🎯 Qué se te pide

Dos cosas, y la segunda es la que de verdad cuenta:

1. Determinar **cuántos problemas distintos** hay en ese ticket. Un reporte no
   es un bug: puede ser dos.
2. Decir, con evidencia, si tu código puede distinguir "el servidor no está" de
   "el servidor está y no contestó". Si la respuesta es no —y lo es— explica qué
   habría que cambiar para que sí, y decide si vale la pena.

Este incidente **no termina necesariamente en un fix del bug**: termina en un
diagnóstico correcto y en una mejora de diagnosticabilidad. Es un entregable
legítimo, y de los más formativos.

### 🔧 Preparación

La forma preferida: un flag del inyector de caos de la Fase 3. No toca tu código
ni tus datos, y se apaga al reiniciar el mock.

```bash
CHAOS=timeout npm run mock     # para el primer síntoma
CHAOS=empty npm run mock       # para el segundo
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No abras un archivo todavía. La pestaña Network contesta las dos mitades del
ticket, y contesta cosas distintas según cómo se vea la fila del request: hay
tres estados posibles y conviene saber nombrarlos.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Con el mock en `timeout`, mira el estado de la petición y después mira tu
componente: ¿en qué punto del ciclo `loading → datos/error` se quedó, y qué
callback no llegó a ejecutarse nunca?

Con el mock en `empty`, la petición es un `200` impecable. La pregunta es otra:
¿tu vista puede distinguir esa respuesta de una lista legítimamente vacía?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Sin `timeout` configurado en axios, ¿cuánto tiempo espera una petición? Y con el
servidor apagado del todo, ¿qué valor tiene `error.response` dentro de tu
`.catch`? Compáralo con el caso de CORS.

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Son **dos** problemas, y el reporte los mezcla porque desde la
pantalla se parecen:

1. *El spinner eterno.* El servidor recibió la petición y no contestó. Sin
   `timeout` en el `apiClient`, axios espera indefinidamente: ni `.then`, ni
   `.catch`, ni `.finally` se ejecutan, así que `loading` se queda en `true`
   para siempre. En Network la fila queda en `(pending)`, que es la firma
   inconfundible.
2. *La lista vacía.* El servidor contestó `200` con `[]`. El sistema funcionó
   perfectamente y la vista no tiene forma de distinguir "no hay tickets" de "no
   llegaron tickets", porque las dos cosas producen `tickets = []`.

Y el hallazgo incómodo que hay que dejar escrito: con el servidor apagado, con
CORS bloqueando y con un timeout, tu `catch` recibe **lo mismo**
(`error.response` es `undefined` en los tres). Desde el código del cliente son
indistinguibles; solo Network y la consola los separan.

**Parche mínimo:**

```js
// services/apiClient.js
var apiClient = axios.create({
  baseURL: "http://localhost:3000",
  timeout: 8000    // el cuelgue silencioso pasa a ser un error contable
});
```

**La refactorización correcta.** El `timeout` convierte el cuelgue en un error,
pero no resuelve la ambigüedad del segundo síntoma. La vista necesita tres
estados y hoy tiene dos:

```js
// views/TicketsView.vue — en el .then del servicio
.then(function (tickets) {
  self.tickets = tickets;
  self.loaded = true;      // "sí hubo respuesta", distinto de "hay datos"
})
```

Con `loaded` y `tickets.length` la plantilla puede decir tres cosas distintas:
"cargando", "no hay tickets registrados" y "no se pudieron cargar los tickets".
Tres mensajes, tres situaciones — y el usuario deja de reportar una sola cosa
ambigua.

**Prueba de regresión.**

```js
// tests/unit/TicketsView.spec.js
it("distingue lista vacía de fallo de carga", function () {
  var wrapper = shallowMount(TicketsView, { … });
  wrapper.setData({ loading: false, loaded: true, tickets: [] });
  expect(wrapper.text()).toContain("No hay tickets");
  wrapper.setData({ loading: false, loaded: false, error: "…" });
  expect(wrapper.text()).not.toContain("No hay tickets");
});
```

**Prevención.** El inyector de caos de la Fase 3 pasa a ser parte del ritual:
antes de dar por cerrada una vista que hace HTTP, se prueba con `CHAOS=timeout`,
`CHAOS=empty` y `CHAOS=500`. Tres comandos, y cubren la familia entera.

**Por qué llegó a producción.** Porque en desarrollo el mock siempre contesta, y
contesta rápido. Los tres estados de una vista se escriben mirando el camino
feliz, y los caminos infelices no tienen quien los ejercite hasta que un usuario
los encuentra. No es descuido de nadie: es la ausencia de una herramienta que
ahora existe.

**Si tu causa fue distinta a ésta.** Si en tu reproducción viste
`(failed)` en vez de `(pending)`, tenías el mock apagado —o CORS— y el camino es
el del paso 3 de la [pieza forense de la Fase 3](forense-fase-03.md). Si viste un
`200` con cuerpo raro y un `tickets.filter is not a function`, estabas en
`CHAOS=malformed`, que es otro incidente con la misma cara.

</details>

---

EOF
grep -c "^## Incidente" cuaderno-incidentes.md; wc -l cuaderno-incidentes.md

# --- 2026-09-10T02:03:34 · Write incidents 3 and 4 of course 01
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 03 — "Me sacó al login a mitad de la mañana, sin decir nada"

> **Fase:** 2 · **Categoría:** Estado · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min

### 🎫 El ticket

> "Estaba trabajando normal, hice clic en un ticket de la lista y me apareció la
> pantalla de login otra vez. Sin ningún mensaje. Lo raro es que arriba a la
> derecha seguía apareciendo mi nombre hasta que hice clic. Volví a entrar y
> siguió todo normal. Me pasó dos veces esta semana."

**Reportado por:** agente de soporte · **Ambiente:** desarrollo y UAT

### 🎯 Qué se te pide

Reproducirlo a voluntad —el "dos veces esta semana" tiene que convertirse en "las
veces que yo quiera"—, decir en qué **capa** vive el problema, y contestar por
escrito una pregunta de diseño: **¿cuál es la fuente de verdad de la sesión en
esta aplicación?** Si tu respuesta tiene más de un elemento, ahí está el bug.

Ojo con el detalle del nombre en el header: no es adorno del reporte, es la
evidencia principal.

### 🔧 Preparación

No hace falta romper código ni datos: basta con provocar el estado inconsistente
desde la consola del navegador, que es exactamente lo que un script de terceros,
una extensión o un `logout` a medias harían.

```js
> localStorage.removeItem("token")   // el usuario no hace esto; el sistema sí
```

Después navega a cualquier ruta protegida.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

En esta fase todavía no hay servidor, así que no hay 401 que valga: solo hay un
actor en toda la aplicación con poder para mandarte a `/login`. Búscalo y léelo
entero, incluidas las dos condiciones de su `if`.

Y mira, en paralelo, DevTools → Application → Local Storage.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Compara, al mismo tiempo, dos sitios donde vive la sesión: lo que hay en
`localStorage` y lo que dice el módulo `auth` del store en Vue DevTools. ¿Coinciden?

Si no coinciden, la pregunta ya no es "quién borró el token" sino "por qué el
sistema tiene dos copias y quién manda".

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El header lee la sesión de un sitio y el guard la lee de otro. ¿Cuál de los dos
se entera cuando el otro cambia?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** La sesión vive en **dos sitios que nadie sincroniza**:

- `router/index.js` — el guard `beforeEach` lee `localStorage.getItem("token")`;
- `store/modules/auth.js` — el store tiene su propia copia en memoria, que es la
  que alimenta el header.

Cuando el token desaparece de `localStorage` sin pasar por `clearSession()` —una
extensión, un script, una pestaña que cerró sesión, un `logout` a medias— el
store no se entera: sigue mostrando tu nombre. El guard, en cambio, lo mira en
cada navegación, y en cuanto navegas te manda a `/login` con un `next("/login")`
que **no muestra nada, no loguea nada y no deja rastro en Network**. De ahí las
dos rarezas del reporte: el silencio y el nombre que seguía ahí.

La Fase 2 declara esto sin esconderlo, en su nota legacy honesta: el guard y el
interceptor leen `localStorage` directamente aunque el store también tenga el
token, "porque es exactamente lo que vas a encontrar en bases legacy reales". Es
una 💸 deuda declarada, y este incidente es su factura.

**Parche mínimo** — el del viernes a las seis:

```js
// router/index.js
router.beforeEach(function (to, from, next) {
  var token = localStorage.getItem("token");
  var requiresAuth = to.matched.some(function (record) {
    return record.meta.requiresAuth;
  });

  if (requiresAuth && !token) {
    // Antes de expulsar, deja el sistema coherente y di por qué te vas.
    store.commit("auth/CLEAR_SESSION");
    next({ path: "/login", query: { reason: "session-expired" } });
    return;
  }
  next();
});
```

Con eso el header deja de mentir y el login puede mostrar *"Tu sesión se cerró,
vuelve a entrar"*, que es la diferencia entre un misterio y un aviso.

**La refactorización correcta.** El parche sincroniza dos copias; lo correcto es
que haya una. El `authService` pasa a ser la única puerta a `localStorage` —ya
tiene `saveSession`, `clearSession` y `getStoredSession`— y tanto el guard como
el interceptor le preguntan a él, no al almacenamiento. Es lo que propone el
ejercicio 24 de la fase, y a partir de ahí la pregunta *"¿cuál es la fuente de
verdad?"* tiene una sola respuesta escrita en un solo archivo.

Queda una segunda deuda 💸 en pie, y conviene dejarla anotada en
`SECURITY-NOTES.md` en vez de fingir que este fix la cubre: **el guard comprueba
que el token exista, no que sea válido.** Con un `localStorage.setItem("token",
"cualquier-cosa")` entras igual. Eso no se puede arreglar en el frontend: hace
falta un servidor que conteste 401.

**Prueba de regresión.**

```js
// tests/unit/router-guard.spec.js
it("limpia el store cuando expulsa por falta de token", function () {
  localStorage.setItem("token", "mock-jwt-token-123");
  store.commit("auth/SET_SESSION", { token: "mock-jwt-token-123", user: { … } });

  localStorage.removeItem("token");
  var next = jest.fn();
  guard({ path: "/tickets", matched: [{ meta: { requiresAuth: true } }] }, {}, next);

  expect(store.state.auth.token).toBe(null);
  expect(next).toHaveBeenCalledWith(
    expect.objectContaining({ path: "/login" })
  );
});
```

**Prevención.** Una regla de revisión, corta y verificable: **ningún archivo
fuera de `authService.js` puede nombrar `localStorage`**. Es un `grep` en el
pipeline, y cierra la puerta por la que entró este bug.

```bash
grep -rn "localStorage" src/ | grep -v "services/authService.js"
```

**Por qué llegó a producción.** Porque la duplicación estaba **documentada** y
justificada: evita problemas de orden de inicialización entre router y store, y
es el patrón que se ve en bases reales de la época. La decisión fue razonable; lo
que faltó fue el segundo movimiento —dejar escrito quién manda cuando las dos
copias discrepan— y una expulsión silenciosa que no le contaba a nadie lo que
había pasado. Ninguna persona se equivocó: el sistema permitía una incoherencia
y no tenía forma de reportarla.

**Si tu causa fue distinta a ésta.** Si concluiste "expiró el token", buena
hipótesis y falsa en esta fase: el token es la cadena literal
`"mock-jwt-token-123"` y no caduca. Si llegaste a "el guard corre antes que el
store", eso importa al arrancar la aplicación, no al navegar con todo montado —
la evidencia que lo tumba es el store poblado en DevTools.

</details>

---

## Incidente 04 — "Pongo el filtro y la tabla se queda con lo de antes"

> **Fase:** 4 · **Categoría:** Estado · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min

### 🎫 El ticket

> "Selecciono 'Abiertos' en el desplegable de estado y la tabla sigue mostrando
> todos los tickets. Pero si después escribo cualquier cosa en el buscador, ahí
> sí se actualiza y además ya sale filtrada por abiertos. Y el contador de arriba
> dice 'Mostrando 8 de 8' cuando abajo se ven 3 filas."

**Reportado por:** coordinadora de soporte · **Ambiente:** desarrollo

### 🎯 Qué se te pide

Localizar la capa y explicar **por qué un control funciona y el otro no**, que es
la parte del reporte que contiene la respuesta. Y una segunda entrega, más
valiosa que el fix: buscar si el mismo patrón está en otro sitio del proyecto y
dejarlo anotado, porque esta familia de bugs nunca viene sola.

### 🔧 Preparación

Una rama: hay que romper código, y es el anti-patrón que la Fase 4 nombra como
"la fuente #1 de que la tabla no refleje lo que hay".

```bash
git switch -c incidente/04 fase-04-dashboard-tickets
```

En `views/TicketsView.vue`, saca `filteredTickets` de `computed`, decláralo en
`data` como `[]`, y sincronízalo con un watcher sobre `search`:

```js
data: function () {
  return { tickets: [], search: "", statusFilter: "", filteredTickets: [] };
},
watch: {
  search: function () {
    var self = this;
    this.filteredTickets = this.tickets.filter(function (t) {
      return t.title.toLowerCase().indexOf(self.search.toLowerCase()) !== -1 &&
             (self.statusFilter === "" || t.status === self.statusFilter);
    });
  }
}
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Empieza por el final de la cadena y ve hacia atrás. En Vue DevTools, mira las
**props** que recibe la tabla antes y después de cambiar el filtro de estado.
Si no cambian, la tabla está pintando fielmente lo que le dan y el problema está
más arriba.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Con la vista seleccionada en DevTools, fíjate en **qué sección** del panel
aparece `filteredTickets`. No es lo mismo estar en `data` que en `computed`, y la
diferencia explica el ticket entero.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Cuántas entradas alimentan ese cálculo, y cuántas tienen quien las escuche?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** `filteredTickets` es un **dato derivado guardado como dato
crudo**. Vive en `data`, así que solo cambia cuando alguien le asigna, y el único
que le asigna es un watcher sobre `search`. `statusFilter` no tiene quien lo
escuche: cambiarlo actualiza el estado —DevTools lo confirma— y no dispara
ningún recálculo. Teclear en el buscador "arregla" el filtro de estado porque el
watcher recalcula todo de nuevo, incluida la condición que ya estaba puesta.

El contador descuadrado es el mismo bug visto desde otro consumidor: "Mostrando
X de Y" lee `filteredTickets.length` en un momento y la tabla recibe la prop en
otro, y como la copia se actualiza a mano, hay instantes en que ninguno de los
dos coincide.

**Parche mínimo:**

```js
watch: {
  search: function () { this.applyFilters(); },
  statusFilter: function () { this.applyFilters(); }   // el que faltaba
}
```

Funciona, y es exactamente lo que hay que **no** dejar así: acabas de sincronizar
la copia con dos entradas, y el día que llegue un tercer filtro —el de prioridad
del ejercicio 9— vuelve el mismo ticket con otra ropa.

**La refactorización correcta.** El derivado vuelve a ser un `computed` y los
watchers desaparecen:

```js
computed: {
  filteredTickets: function () {
    var self = this;
    return this.tickets.filter(function (t) {
      var matchesSearch = t.title.toLowerCase().indexOf(self.search.toLowerCase()) !== -1;
      var matchesStatus = self.statusFilter === "" || t.status === self.statusFilter;
      return matchesSearch && matchesStatus;
    });
  }
}
```

Vue anota qué leyó el computed —`tickets`, `search`, `statusFilter`— y lo marca
sucio cuando cualquiera cambia. Un filtro nuevo entra en la condición y se
actualiza solo: no hay nada que sincronizar porque no hay copia.

**Prueba de regresión.** El test que importa no prueba el computed —eso lo
garantiza Vue— sino el **comportamiento** que se rompió:

```js
// tests/unit/TicketsView.spec.js
it("refleja el filtro de estado sin necesidad de tocar la búsqueda", function () {
  var wrapper = shallowMount(TicketsView, { … });
  wrapper.setData({ tickets: fixtures.mixed, search: "", statusFilter: "" });
  expect(wrapper.vm.filteredTickets).toHaveLength(8);

  wrapper.setData({ statusFilter: "open" });
  expect(wrapper.vm.filteredTickets).toHaveLength(3);
});
```

**Prevención.** Una pregunta en la revisión de código, que cabe en una línea:
**¿este valor es un hecho o es una consecuencia?** Los hechos van a `data`; las
consecuencias, a `computed`. Y una señal de alarma barata: un `watch` que
**escribe** en `data` casi siempre es un `computed` mal escrito. Búscalos:

```bash
grep -rn "watch:" -A 6 src/views src/components | grep -n "this\.\w* ="
```

**Por qué llegó a producción.** Casi siempre por rendimiento mal entendido:
alguien vio que el computed se recalcula en cada tecla —cosa cierta, y visible
con 5.000 tickets— y "optimizó" guardando el resultado. La intuición era
razonable; la solución correcta a ese problema era un `debounce` sobre la
entrada, no una copia del derivado. El sistema no tenía forma de avisar de que la
copia se había quedado atrás: un `data` desactualizado se ve exactamente igual
que uno correcto.

**Si tu causa fue distinta a ésta.** Si concluiste "falta `:key` en el `v-for`",
la evidencia que lo tumba es el paso 1: la prop llegó con la misma longitud, así
que el problema no es qué fila es cuál. Y si acabaste poniendo un
`this.$forceUpdate()`, funciona y es la peor salida posible — repinta con la copia
vieja y convierte un bug reproducible en uno intermitente.

</details>

---

EOF
grep -c "^## Incidente" cuaderno-incidentes.md; wc -l cuaderno-incidentes.md

# --- 2026-09-10T02:04:47 · Write incidents 5 and 6 of course 01
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 05 — "Le puse la etiqueta y la tabla no se enteró"

> **Fase:** 5 · **Categoría:** Reactividad · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min

### 🎫 El ticket

> "Abro el ticket #3, le agrego la etiqueta 'facturación' desde el formulario de
> edición, le doy guardar y me dice que se guardó. Pero en la tabla el ticket
> sigue sin etiqueta. Si recargo con F5 ahí sí aparece. A veces me pasa y a veces
> no, no sé de qué depende."

**Reportado por:** agente de soporte · **Ambiente:** desarrollo y UAT

### 🎯 Qué se te pide

Reproducirlo —el "a veces sí y a veces no" es un dato, no ruido del reporte:
averigua **de qué depende** antes de tocar nada—, decir en qué capa vive, y
aplicar el parche mínimo. Y después, la parte que separa el arreglo del
entendimiento: explicar por qué el mismo código funciona con unos tickets y no
con otros.

### 🔧 Preparación

Un `db.json` alterno: el bug solo se ve con tickets que **no traen** el campo
`tags` desde el mock, y la semilla actual se lo pone a todos.

```bash
git checkout -- db.json          # guarda antes lo que tengas
cp mock/db.incidente-05.json db.json
```

El archivo alterno es el `db.seed.json` con una sola diferencia: a los tickets
1 y 3 se les quitó por completo la clave `tags` (no vacía: **ausente**).

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

El dato correcto ya está en la aplicación. Compara, en Vue DevTools, lo que dice
el objeto del ticket en el estado con lo que pinta la fila. No es un problema de
red: Network no tiene nada que contarte aquí, y comprobarlo cuesta cinco
segundos.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

De los tickets de la tabla, unos se actualizan y otros no. Mira qué tienen en
común los que **sí**. Fíjate en la respuesta del mock —el objeto tal como llega—,
no en el que arma el formulario.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿En qué momento exacto de la vida de ese objeto apareció la propiedad `tags`?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Vue 2 hace reactivas las propiedades que **existen en el momento
en que el objeto entra en `data`**. Los tickets que el mock devuelve sin `tags`
entran sin esa propiedad, y el `ticket.tags = […]` posterior crea una propiedad
que ningún getter/setter vigila. El dato está —por eso DevTools lo muestra— y la
tabla nunca se entera. Con F5 el ticket vuelve a entrar, esta vez con `tags`
porque el mock ya lo guardó, y todo funciona: de ahí el "a veces".

Es la limitación de reactividad más famosa de Vue 2, la que Vue 3 resolvió con
Proxies, y la que explica que exista `Vue.set`.

**Parche mínimo** — el del viernes a las seis:

```js
// views/TicketsView.vue — al aplicar el ticket actualizado
onTicketUpdated: function (updated) {
  var index = this.tickets.findIndex(function (t) { return t.id === updated.id; });
  // splice y no tickets[index] = updated: la asignación por índice en un array
  // tampoco es reactiva en Vue 2. Son las dos caras de la misma limitación.
  if (index === -1) {
    this.tickets.push(updated);
  } else {
    this.tickets.splice(index, 1, updated);
  }
}
```

**La refactorización correcta.** El problema de fondo no es el `splice`: es que
el frontend acepta del mock tickets con **forma incompleta**. Normalizar en la
frontera hace que la limitación de reactividad no pueda dispararse nunca:

```js
// services/ticketService.js
function normalizeTicket(raw) {
  return {
    id: raw.id,
    title: raw.title || "",
    description: raw.description || "",
    status: raw.status || "open",
    priority: raw.priority || "medium",
    assignee: raw.assignee || null,
    tags: raw.tags || []          // ← el campo existe SIEMPRE
  };
}

function getTickets(params) {
  return apiClient.get("/tickets", { params: params }).then(function (res) {
    return res.data.map(normalizeTicket);
  });
}
```

Con eso, cada ticket entra al estado con todas sus propiedades declaradas, y la
tabla se entera de cualquier cambio sin ceremonias. **Es la misma idea que un
DTO en tu backend de siempre:** la frontera es el sitio donde los datos ajenos se
convierten en datos con forma conocida.

**Prueba de regresión.**

```js
// tests/unit/ticketService.spec.js
it("normaliza los tickets que llegan sin tags", function () {
  apiClient.get.mockResolvedValue({ data: [{ id: 1, title: "X", status: "open" }] });
  return ticketService.getTickets().then(function (tickets) {
    expect(tickets[0].tags).toEqual([]);
    expect(Object.prototype.hasOwnProperty.call(tickets[0], "tags")).toBe(true);
  });
});
```

**Prevención.** Dos hábitos, los dos baratos: normalizar en el servicio todo lo
que venga de fuera, y desconfiar de cualquier `objeto.campoNuevo = valor` sobre
algo que ya vive en el estado. El segundo se puede buscar a ojo en una revisión;
el primero se escribe una vez por servicio y protege para siempre.

**Por qué llegó a producción.** Porque en desarrollo la semilla es completa: todos
los tickets del `db.json` traen todos los campos, así que la propiedad siempre
existía cuando el objeto entraba y el bug era invisible. El primer ticket sin
`tags` lo creó un usuario meses después, por un camino que no ponía el campo.
Nadie se equivocó al escribir el código; el sistema confiaba en una forma de dato
que nadie hacía cumplir.

**Si tu causa fue distinta a ésta.** Si tu conclusión fue "el PATCH no devuelve
el ticket completo", compruébalo en Network: json-server devuelve el documento
entero, y esa evidencia lo descarta. Si acabaste en "hay que recargar la lista
tras guardar", funciona y esconde el bug detrás de un viaje a la red — y el
mismo error volverá en la primera pantalla donde recargar no sea aceptable.

</details>

---

## Incidente 06 — "Volví atrás en el asistente y perdí la descripción"

> **Fase:** 6 · **Categoría:** Formularios y wizard · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min

### 🎫 El ticket

> "Estoy creando un ticket con el asistente. Lleno el paso 1, paso al 2, me doy
> cuenta de que el título estaba mal y le doy 'Atrás'. El título sigue ahí, pero
> la descripción se borró. Y los avisos rojos de los campos mal llenados también
> desaparecieron, aunque siguen mal. Además, hoy me dejó llegar al final con el
> paso 2 en blanco y me creó el ticket incompleto."

**Reportado por:** agente de soporte · **Ambiente:** desarrollo

### 🎯 Qué se te pide

Son **dos** problemas en un solo ticket y hay que separarlos: lo que se pierde al
volver, y lo que el asistente deja pasar. Para el primero, explica por qué una
parte sobrevive y otra no —esa asimetría es el diagnóstico—. Para el segundo,
decide dónde tiene que vivir la validación y defiéndelo en dos líneas.

### 🔧 Preparación

Una rama: hay que quitar dos cosas que la fase pone a propósito.

```bash
git switch -c incidente/06 fase-06-wizard-minimo
```

En `views/TicketWizardView.vue`: quita el `<keep-alive>` que envuelve al
`<component :is>`, y en el método que avanza de paso, quita la llamada a
`validate()` del paso actual (deja solo la validación final).

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Pon un `console.log` en `created` del primer paso y navega adelante y atrás
mirando la consola. Lo que veas ahí contesta la primera mitad del ticket sin
abrir ningún archivo más.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Compara, en Vue DevTools, el `draft` del componente padre con el `form` del paso.
¿Qué campos coinciden y cuáles no? ¿Y en qué momento el paso le entrega sus datos
al padre?

Para la segunda mitad: ¿quién decide si se puede avanzar, y cuándo se lo
pregunta al paso?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`$v` —el estado de validación— ¿de quién es? ¿Del asistente o del paso?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Dos causas independientes que el reporte junta porque se ven en
la misma pantalla:

1. *Lo que se pierde.* `<component :is>` **destruye y monta** por diseño: al
   avanzar, el componente del paso 1 deja de existir; al volver, nace uno nuevo
   y vacío. Lo que sobrevive es lo que el paso ya había **entregado** al `draft`
   del padre —el título, validado y entregado al avanzar— y lo que no llegó a
   entregarse muere con el componente. El estado de validación (`$v`) es del
   componente, así que nace virgen: por eso los avisos rojos desaparecen aunque
   el campo siga mal.
2. *Lo que deja pasar.* La validación se hace solo al final, así que avanzar de
   paso no pregunta nada. El usuario descubre en el paso 3 que el 2 estaba mal —
   o directamente no lo descubre, y el ticket se crea incompleto.

**Parche mínimo:**

```vue
<keep-alive>
  <component :is="currentStepComponent" ref="stepComponent" />
</keep-alive>
```

```js
goNext: function () {
  var step = this.$refs.stepComponent;
  if (step.validate && !step.validate()) { return; }   // valida por paso
  this.draft = Object.assign({}, this.draft, step.getData());
  this.currentStep = this.currentStep + 1;
}
```

**La refactorización correcta.** Con `keep-alive` los pasos dejan de morir, y eso
cambia una regla del ciclo de vida que hay que escribir en el código o alguien la
va a pisar: `created` y `mounted` **ya no se repiten**. Si un paso necesita
refrescar algo al volver, el hook es `activated`. Conviene dejarlo comentado
justo ahí, porque es el efecto secundario que sorprende a todo el mundo.

Y una decisión de diseño que va con el segundo problema: **validar al avanzar,
nunca al retroceder**. Bloquear "Atrás" con un paso inválido es una de las peores
experiencias posibles — atrapas al usuario en un paso que no sabe arreglar.

**Prueba de regresión.**

```js
// tests/unit/TicketWizardView.spec.js
it("no avanza si el paso actual es inválido", function () {
  var wrapper = shallowMount(TicketWizardView, { … });
  wrapper.vm.$refs.stepComponent = { validate: function () { return false; },
                                     getData: function () { return {}; } };
  wrapper.vm.goNext();
  expect(wrapper.vm.currentStep).toBe(1);
});

it("conserva lo entregado al volver atrás", function () { … });
```

**Prevención.** Cuando una pantalla intercambie componentes dinámicamente,
escribe en el código —en un comentario de dos líneas— **qué muere con cada
intercambio**. Es el tipo de conocimiento que se pierde en cuanto el autor
original cambia de proyecto, y que reaparece como este ticket.

**Por qué llegó a producción.** Porque en el camino feliz no se nota: quien
prueba el asistente lo recorre hacia adelante, llena todo bien y crea el ticket.
Volver atrás con datos a medias es un camino que solo aparece cuando lo usa
gente de verdad. Y la validación al final parecía razonable —"valido cuando
tenga todo"— hasta que alguien llegó al paso 3 con el 1 roto.

**Si tu causa fue distinta a ésta.** Si concluiste que "se borra el borrador",
compruébalo en DevTools: el `draft` del padre está intacto, y esa evidencia
manda. Si tu fix fue meter el borrador en Vuex, resuelve otro problema —el de
pasos en rutas distintas— y deja este igual: `$v` seguiría muriendo con el
componente, porque nunca estuvo en el borrador.

</details>

---

EOF
grep -c "^## Incidente" cuaderno-incidentes.md; wc -l cuaderno-incidentes.md

# --- 2026-09-10T02:06:15 · Write incidents 7 and 8 of course 01
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 07 — "A la media hora la laptop suena como un avión"

> **Fase:** 7 · **Categoría:** Reactividad · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1-1,5 h

### 🎫 El ticket

> "El sistema arranca bien pero se va poniendo lento durante la mañana. Sobre
> todo si entro y salgo varias veces de la pantalla de métricas: después todo va
> pesado, hasta escribir en el buscador se siente con retraso, y al rato se
> enciende el ventilador. Cierro la pestaña, la vuelvo a abrir y queda como
> nueva. No sale ningún error."

**Reportado por:** coordinadora de soporte · **Ambiente:** desarrollo y UAT

### 🎯 Qué se te pide

Un bug de degradación no se diagnostica buscando qué se rompe, sino **qué se
acumula**. Se te pide: reproducirlo de forma medible (un número antes y un número
después, no una sensación), identificar las **dos** causas —hay dos, y son
independientes—, y arreglar las dos. El entregable incluye la medición: sin ella
no puedes demostrar que lo arreglaste.

### 🔧 Preparación

Una rama, y dos roturas que la fase advierte por separado:

```bash
git switch -c incidente/07 fase-07-metricas-minimas
```

En `components/metrics/StatusDoughnut.vue` y en `AgentBarChart.vue`:

1. mueve la instancia del chart a `data` (`data: function () { return { chart: null }; }`
   y `this.chart = new Chart(...)` en `mounted`);
2. comenta el hook `beforeDestroy` entero.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Empieza por lo gratis: entra y sal de `/metrics` cinco veces con la consola
abierta. Si aparece un error de chart.js, tienes media investigación resuelta.
Si no aparece nada, estás ante la versión silenciosa y hay que medir.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

En Vue DevTools, selecciona el componente del gráfico y mira **qué aparece en el
panel de datos**. Si la instancia de la librería está ahí dentro, pregúntate qué
le hace Vue a todo lo que vive en `data`.

Y para lo que se acumula: DevTools → Memory → *Heap snapshot*, uno al cargar y
otro después de entrar y salir cinco veces. Filtra por `Chart`.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Quién le avisa a chart.js de que tu componente murió?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Dos, independientes, y cada una basta para producir el síntoma:

1. *La instancia en `data`.* Vue 2 observa recursivamente todo lo que pongas ahí:
   recorre el objeto entero y le pone getters y setters a cada propiedad. Una
   instancia de chart.js es un objeto enorme con referencias circulares al
   canvas, al contexto y a sus datasets internos — envolverlo cuesta memoria,
   cuesta CPU en cada cambio y puede romper la librería, que no espera que sus
   propiedades internas estén interceptadas.
2. *La ausencia de `beforeDestroy`.* Nadie llama a `chart.destroy()`, así que
   cada visita a la vista deja un gráfico vivo: con sus listeners de `resize`
   atados a `window`, sus animaciones agendadas y su canvas referenciado, de modo
   que el recolector de basura no puede llevarse nada. Cinco visitas, cinco
   charts trabajando en cada repintado. Ése es el ventilador.

**Parche mínimo** — el del viernes a las seis:

```js
// components/metrics/StatusDoughnut.vue
mounted: function () {
  // Propiedad de instancia FUERA de data: Vue no la observa.
  this.chart = new Chart(this.$refs.canvas, this.buildConfig());
},
beforeDestroy: function () {
  if (this.chart) {
    this.chart.destroy();   // el aviso que la librería no puede darse sola
    this.chart = null;
  }
}
```

**La refactorización correcta.** El patrón se repite en los dos gráficos y se va
a repetir en el siguiente, así que se extrae una vez y se deja de discutir. La
fase lo propone como mixin —muy de la época— y es el sitio natural para el
contrato de tres tablones: nacimiento en `mounted`, actualización en `watch`,
muerte en `beforeDestroy`.

```js
// mixins/chartLifecycle.js
export default {
  mounted: function () { this.chart = this.createChart(); },
  beforeDestroy: function () { if (this.chart) { this.chart.destroy(); this.chart = null; } },
  watch: {
    chartData: {
      deep: true,
      handler: function () {
        if (!this.chart) { return; }
        this.chart.data = this.buildData();
        this.chart.update();          // update, no recrear
      }
    }
  }
};
```

Y una advertencia que hay que dejar escrita en el mixin: si algún día el
componente vive dentro de un `<keep-alive>` (Fase 6), `beforeDestroy` **no
corre** y hay que usar `deactivated`. Es exactamente el mismo bug con otro ciclo
de vida.

**Prueba de regresión.**

```js
// tests/unit/StatusDoughnut.spec.js
it("destruye la instancia del chart al desmontarse", function () {
  var destroy = jest.fn();
  Chart.mockImplementation(function () { return { destroy: destroy, update: jest.fn() }; });

  var wrapper = shallowMount(StatusDoughnut, { propsData: { tickets: [] } });
  wrapper.destroy();

  expect(destroy).toHaveBeenCalledTimes(1);
});

it("no expone la instancia como dato reactivo", function () {
  var wrapper = shallowMount(StatusDoughnut, { propsData: { tickets: [] } });
  expect(Object.keys(wrapper.vm.$data)).not.toContain("chart");
});
```

**Prevención.** Una regla de revisión con nombre propio: **todo lo que se crea en
`mounted` y vive fuera de Vue, se destruye en `beforeDestroy`**. Charts, mapas,
editores, `setInterval`, listeners de `window`, suscripciones a un socket. Y una
comprobación de dos segundos en cada revisión de un componente que integre una
librería: buscar `destroy`, `clearInterval` o `off` en el archivo. Si no
aparecen, hay una pregunta que hacer.

**Por qué llegó a producción.** Porque nada falla. El componente funciona
perfectamente la primera vez, la segunda y la décima; lo único que cambia es
cuánta memoria queda. Los bugs de acumulación no tienen un momento de fallo que
alguien pueda reportar, así que se manifiestan como una queja difusa —"va
lento"— que llega semanas después y nadie asocia con una pantalla concreta. La
instancia en `data`, además, es el camino que sugiere el propio framework: es
donde uno pondría cualquier otra cosa.

**Si tu causa fue distinta a ésta.** Si tu conclusión fue "son demasiados
tickets", el snapshot lo desmiente: lo que crece son instancias de `Chart`, no
filas — y el sistema va peor con **los mismos datos** que hace diez minutos. Si
te encontraste con `Canvas is already in use`, encontraste la versión ruidosa del
mismo bug y llegaste por el camino corto: es igual de válido, dilo así en el
post-mortem.

</details>

---

## Incidente 08 — "Se me duplican los tickets cuando entra uno nuevo"

> **Fase:** 8 · **Categoría:** Tiempo real · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1-1,5 h

### 🎫 El ticket

> "Cuando alguien crea un ticket, a mí me aparece en la lista dos veces. A veces
> tres. Me pasa sobre todo al final de la mañana, cuando ya llevo un rato usando
> el sistema y he ido entrando y saliendo de las pantallas. Si recargo la página
> queda uno solo, bien."

**Reportado por:** agente de soporte · **Ambiente:** desarrollo y UAT

### 🎯 Qué se te pide

Reproducirlo de forma **determinista** —"al final de la mañana" tiene que
convertirse en tres pasos concretos—, localizar la capa y arreglarlo. Y una
segunda entrega que es la valiosa: el sistema tiene una 💸 deuda declarada que
este incidente roza. Encuéntrala, explica en dos líneas por qué es correcta hoy y
qué haría falta para pagarla.

### 🔧 Preparación

Una rama, con la rotura que la propia fase propone como experimento:

```bash
git switch -c incidente/08 fase-08-websockets-minimos
```

En `views/TicketsView.vue`, comenta la línea del `off` dentro de
`beforeDestroy`. Después: entra a `/tickets`, sal a otra vista, vuelve; repítelo
tres veces y crea un ticket desde otro navegador.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Cuenta. ¿Cuántas veces llega el evento y cuántas veces se aplica? No es la misma
pregunta, y la pestaña **WS** de Network contesta la primera sin ambigüedad: un
solo frame o varios.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Si el frame llega **una** vez y la fila aparece tres, el problema no es el
servidor ni la red: es cuántos oyentes tiene ese evento en tu navegador. ¿Qué
pasa cada vez que entras a la vista? ¿Y cada vez que sales?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Para dar de baja a un oyente hace falta pasar **la misma referencia** que se dio
de alta. ¿La tuya lo es?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** El evento llega **una** vez —la pestaña WS lo confirma: un solo
frame— y se aplica N veces, una por cada vez que la vista se montó sin darse de
baja al salir. Cada `mounted` suscribe un handler nuevo al singleton del socket y
cada `beforeDestroy` que no llama a `off` deja el anterior vivo. Los handlers
zombis sobreviven al componente, y como el singleton del socket vive fuera de
Vue, nadie los limpia.

El "al final de la mañana" es el contador de navegaciones: tres entradas a la
vista, tres filas por ticket.

Hay una variante del mismo bug que produce el síntoma **aunque el `off` esté
escrito**:

```js
mounted: function () {
  socketService.on("ticket:created", this.onTicketCreated.bind(this));   // ⚠️
},
beforeDestroy: function () {
  socketService.off("ticket:created", this.onTicketCreated.bind(this));  // ⚠️ otra función
}
```

Cada `.bind(this)` crea una **función nueva**: el `off` intenta dar de baja a
alguien que nunca se suscribió, y no falla ni avisa. Por eso la fase guarda la
referencia:

**Parche mínimo:**

```js
mounted: function () {
  this.loadTickets();
  this.onCreatedHandler = this.onTicketCreated.bind(this);   // UNA referencia
  socketService.on("ticket:created", this.onCreatedHandler);
},
beforeDestroy: function () {
  socketService.off("ticket:created", this.onCreatedHandler); // la MISMA
}
```

**La refactorización correcta.** Mientras cada vista se suscriba por su cuenta,
este bug puede volver en la siguiente pantalla que escuche sockets — y el Curso
01 ya tiene dos (`TicketsView` y el panel de soporte). La solución estructural es
la de la Fase 10: **el socket alimenta al store una sola vez**, mediante un
plugin de Vuex, y las vistas dejan de suscribirse. Un solo punto de alta, ningún
punto de baja que olvidar, y todas las vistas conectadas se enteran gratis.

Como defensa adicional, el handler puede volverse idempotente:

```js
onTicketCreated: function (ticket) {
  var exists = this.tickets.some(function (t) { return t.id === ticket.id; });
  if (exists) { return; }
  this.tickets.unshift(ticket);
}
```

Eso no arregla la fuga de handlers —sigue habiendo tres— pero impide que se note
en los datos, que es lo que le importa al usuario mientras haces el arreglo de
verdad.

**Prueba de regresión.**

```js
// tests/unit/TicketsView.spec.js
it("da de baja el handler al desmontarse", function () {
  var wrapper = shallowMount(TicketsView, { … });
  var handler = wrapper.vm.onCreatedHandler;
  wrapper.destroy();
  expect(socketService.off).toHaveBeenCalledWith("ticket:created", handler);
});

it("no duplica un ticket que ya está en la lista", function () {
  var wrapper = shallowMount(TicketsView, { … });
  wrapper.setData({ tickets: [{ id: 7, title: "X" }] });
  wrapper.vm.onTicketCreated({ id: 7, title: "X" });
  expect(wrapper.vm.tickets).toHaveLength(1);
});
```

**Prevención.** La regla del [incidente 07](#incidente-07--a-la-media-hora-la-laptop-suena-como-un-avión)
otra vez, y no es casualidad: **alta y baja simétricas, con la misma
referencia**. Búscalo con un `grep` en cada revisión de un componente que
escuche algo:

```bash
grep -rn "\.on(" src/ | grep -v node_modules   # y por cada uno, su .off
```

**La deuda que este incidente roza.** Mientras investigas vas a encontrarte con
que el evento `ticket:created` **lo emite el cliente que creó el ticket**, no el
servidor: el servidor de sockets es un relé de veinte líneas que rebota lo que le
llega. Está declarado en la fase como 💸 *el cliente mentiroso*. Es correcto hoy,
porque no hay un backend que persista y anuncie; y su consecuencia es
comprobable en un segundo desde la consola:

```js
> socketService.emit("ticket:created", { id: 999, title: "No existe", status: "open" })
```

Los demás navegadores anuncian un ticket que no está en ninguna base. Para
pagarla hace falta que quien confirma la escritura sea quien anuncia — y eso
llega el día que exista un backend de verdad detrás del `baseURL`.

**Por qué llegó a producción.** Porque el `off` no tiene un fallo visible cuando
falta: la primera vez que usas la vista todo funciona. El bug necesita
**navegación repetida** para manifestarse, y nadie prueba "entrar y salir tres
veces de la misma pantalla" antes de dar por buena una funcionalidad. Y la
variante del `.bind(this)` es peor: el código *parece* correcto, tiene su alta y
su baja simétricas a la vista, y no lo es.

**Si tu causa fue distinta a ésta.** Si viste **varios frames** en la pestaña WS,
tu bug es otro: hay varias conexiones abiertas, probablemente porque alguien
conecta en el `mounted` de cada vista en vez de una vez por sesión. Es un
hallazgo legítimo y el arreglo va en `App.vue`, ligando la conexión a la sesión.

</details>

---

EOF
grep -c "^## Incidente" cuaderno-incidentes.md; wc -l cuaderno-incidentes.md

# --- 2026-09-10T02:07:50 · Write incidents 9 and 10 of course 01
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 09 — "Tomé el ticket y a mi compañera le sigue apareciendo libre"

> **Fase:** 9 · **Categoría:** Estado · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1-1,5 h

### 🎫 El ticket

> "Tomé el ticket #12 en el panel de soporte. En mi pantalla quedó asignado a mí
> y pasó a 'En progreso'. Ana dice que en la suya sigue apareciendo sin asignar,
> en la cola de pendientes, y ella no ha recargado. Lo peor: hace un rato lo
> tomamos los dos casi a la vez y a los dos nos dijo que era nuestro.
>
> Otra cosa, quizá no tenga que ver: a veces cambio el estado desde el panel
> grande de la derecha y el panel se queda mostrando el estado anterior, aunque
> en la lista de la izquierda sí cambió."

**Reportado por:** agente de soporte · **Ambiente:** UAT, dos usuarios reales

### 🎯 Qué se te pide

Este ticket trae **tres** síntomas y solo dos tienen arreglo en este curso.
Sepáralos:

1. El cambio que no viaja a la otra pantalla.
2. El panel de la derecha que se queda con datos viejos.
3. Los dos agentes que tomaron el mismo ticket.

Para los dos primeros, causa raíz y fix. Para el tercero, **demuestra que no se
puede arreglar bien desde el frontend** y di qué haría falta. Terminar en "esto
no es un bug del cliente, es una garantía que falta en el servidor" es un
entregable completo y de los más útiles que vas a escribir.

### 🔧 Preparación

Sin romper nada: los tres síntomas están en el sistema tal como lo dejó la fase.
Necesitas dos navegadores (uno normal y uno en incógnito), los dos con sesión.

```bash
npm run dev        # mock + sockets + frontend
```

Para el tercer síntoma, dos pestañas con el detalle del mismo ticket libre y
hacer clic en "Tomar" casi a la vez.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Para el primer síntoma, el desempate más barato del track: que Ana recargue con
F5. Lo que veas después de esa recarga parte el problema en dos mitades muy
distintas, y una de las dos queda descartada para siempre.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Mira la pestaña **WS** de Network mientras tomas el ticket. Y después mira qué
eventos conoce el sistema entero:

```bash
grep -rn "socketService.emit\|socketService.on" src/
```

Para el segundo síntoma, compara en Vue DevTools el objeto que tiene la lista con
el que tiene el panel de la derecha. ¿Son el mismo objeto?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Primer síntoma: ¿cuántos tipos de evento emite esta aplicación, y qué acción del
usuario dispara cada uno?

Tercero: entre que tu código comprueba que el ticket está libre y que escribe la
asignación, ¿qué impide que pase algo?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Tres, independientes:

1. *El cambio no viaja.* No hay bug: **el sistema solo emite `ticket:created`**.
   Tomar un ticket es un PATCH y ningún PATCH anuncia nada, así que el sistema
   está vivo a medias — las altas se propagan, las modificaciones no. El F5 de
   Ana lo demuestra: el dato estaba guardado, lo que faltó fue el aviso.
2. *El panel con datos viejos.* El panel guarda el **objeto** del ticket
   seleccionado en vez del `id`. Cuando la lista se actualiza con la respuesta del
   PATCH, el elemento del arreglo se reemplaza por uno nuevo y la copia del panel
   se queda apuntando al viejo. En DevTools se ve directo:
   `selectedTicket === tickets[i]` da `false`.
3. *El doble "tomar".* Entre el `findOne`-equivalente del cliente —comprobar que
   `assignee` está vacío— y el PATCH que escribe hay una ventana, y los dos
   navegadores pasaron por ella. **json-server no tiene forma de rechazar el
   segundo**: aplica el PATCH que le llega, sin condiciones.

**Parche mínimo:**

```js
// views/SupportView.vue — el panel deja de guardar el objeto
data: function () {
  return { tickets: [], selectedId: null };
},
computed: {
  selectedTicket: function () {
    var id = this.selectedId;
    return this.tickets.find(function (t) { return t.id === id; }) || null;
  }
}
```

```js
// tras el PATCH de tomar, anunciar el cambio como se anuncia el alta
.then(function (updated) {
  self.onTicketUpdated(updated);
  socketService.emit("ticket:updated", updated);
})
```

Y el oyente correspondiente en las vistas que muestran listas, con la misma
disciplina de alta y baja del [incidente 08](#incidente-08--se-me-duplican-los-tickets-cuando-entra-uno-nuevo).

**La refactorización correcta.** El parche del `ticket:updated` funciona y
**consolida una deuda**: ahora hay dos eventos que emite el cliente, o sea dos
sitios donde cualquiera puede anunciar algo falso. Vale la pena escribirlo en
`SECURITY-NOTES.md` tal cual: *el que anuncia no es el que persiste*. La
refactorización correcta de verdad no cabe en este curso —requiere un servidor
que confirme la escritura y emita— y por eso este incidente termina en un
diagnóstico y una nota, no en una solución completa.

Lo que sí se refactoriza aquí es el segundo síntoma: **guardar identificadores,
nunca objetos**, y derivar el resto. Con eso, master y detail no pueden
discrepar.

Sobre el tercer síntoma, la demostración que se pide: el cliente puede
**reducir** la ventana releyendo el ticket justo antes del PATCH y abortando si
ya tiene `assignee` —el ejercicio 20 de la fase lo propone—, y eso convierte el
caso frecuente en un mensaje decente ("Ana se te adelantó"). Pero la ventana
sigue existiendo, más pequeña. La única solución real es que la escritura lleve
la **precondición dentro**: *asigna este ticket solo si sigue sin asignar*. Eso
lo tiene que ofrecer el servidor; json-server no lo hace.

**Prueba de regresión.**

```js
// tests/unit/SupportView.spec.js
it("el detalle refleja el ticket actualizado sin cambiar de selección", function () {
  var wrapper = shallowMount(SupportView, { … });
  wrapper.setData({ tickets: [{ id: 12, status: "open", assignee: null }], selectedId: 12 });

  wrapper.vm.onTicketUpdated({ id: 12, status: "in_progress", assignee: "soporte1" });

  expect(wrapper.vm.selectedTicket.status).toBe("in_progress");
  expect(wrapper.vm.selectedTicket.assignee).toBe("soporte1");
});
```

**Prevención.** Dos reglas, las dos verificables en una revisión: **guarda ids, no
objetos**, y **si un cambio de estado importa a más de una pantalla, tiene que
anunciarse**. Un inventario de eventos —qué acciones producen aviso y cuáles
no— en el README del proyecto evita descubrir el hueco cuando lo reporta un
usuario.

**Por qué llegó a producción.** Porque el tiempo real se construyó para el caso
que se veía bonito en la demo: el ticket nuevo que aparece solo, con su toast. Los
cambios de estado no se anunciaron porque nadie los pidió, y el sistema "en vivo"
pasó a estarlo a medias sin que quedara escrito en ninguna parte. Y la carrera
del doble "tomar" no podía verse en desarrollo: hace falta que dos personas hagan
clic a la vez, cosa que no ocurre cuando el equipo es una persona probando.

**Si tu causa fue distinta a ésta.** Si concluiste "el socket se desconectó", la
pestaña WS lo desmiente: la conexión está viva y los tickets nuevos siguen
llegando. Si tu explicación del segundo síntoma fue "falta `:key`", ojo: el
`:key` sobre el panel resuelve **otro** problema de la misma pantalla —los
comentarios del ticket anterior que se ven medio segundo— y no éste.

</details>

---

## Incidente 10 — "El contador del menú dice una cosa y la tabla otra"

> **Fase:** 10 · **Categoría:** Estado (Vuex) · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1-1,5 h

### 🎫 El ticket

> "El menú de la izquierda dice 'Tickets (8)' y cuando entro a la lista hay 11.
> A veces coinciden. Si recargo la página quedan iguales un rato y después se
> vuelven a descuadrar. También me pasó que el spinner de carga se quedó
> encendido en una pantalla en la que ya se veían los datos."

**Reportado por:** coordinadora de soporte · **Ambiente:** desarrollo

### 🎯 Qué se te pide

Encontrar **quién cambia el estado sin dejar rastro** y demostrarlo con
evidencia, no con lectura de código. La herramienta que resuelve este incidente
lleva dos fases instalada y casi nadie la abre; parte del entregable es que
aprendas a leerla.

Y una segunda pregunta, corta: ¿por qué el spinner que se queda encendido
pertenece a este mismo incidente?

### 🔧 Preparación

Una rama con dos roturas pequeñas:

```bash
git switch -c incidente/10 fase-10-vuex-a-fondo
```

1. En `store/index.js`, pon `strict: false`.
2. En `store/modules/ui.js`, comenta `namespaced: true`.
3. En el componente del menú lateral, escribe el contador directamente contra el
   estado: `this.$store.state.tickets.items.push(...)` en algún punto de carga —o
   más simple, haz que una vista modifique `state.tickets.items` sin pasar por
   una mutation.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Vue DevTools tiene una pestaña que hasta ahora no has usado en serio. Ábrela,
reproduce el descuadre, y mira **qué aparece y qué no aparece** en la lista de
mutations mientras el número cambia.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Si el estado cambia y no hay ninguna entrada nueva, la pregunta es quién escribió
sin pasar por el único sitio autorizado. Hay un ajuste del store que convierte
eso en un error inmediato en desarrollo: búscalo y enciéndelo.

Para el spinner: fíjate en el **nombre completo** de las mutations. ¿Todas
llevan el prefijo de su módulo?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Dos módulos con una mutation que se llama igual, y uno de los dos sin declarar su
espacio de nombres. ¿A cuál de los dos le llega el commit?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Dos problemas que comparten familia:

1. *El contador descuadrado.* Alguien escribe en el state **fuera de una
   mutation**. El registro de DevTools lo delata por omisión: el número cambia y
   no aparece ninguna entrada nueva. Con `strict: true` eso deja de ser
   invisible:

   ```
   Error: [vuex] do not mutate vuex store state outside mutation handlers.
   ```

2. *El spinner eterno.* El módulo `ui` perdió su `namespaced: true`, así que su
   mutation `SET_LOADING` vive en el espacio global junto a la del módulo
   `tickets`. Un `commit("SET_LOADING", false)` llega al que Vuex resuelva
   primero, y el otro se queda encendido. **No hay error**: para Vuex le pediste
   algo que existe.

**Parche mínimo:**

```js
// store/index.js
export default new Vuex.Store({
  modules: { tickets: tickets, ui: ui },
  strict: process.env.NODE_ENV !== "production"   // caro: solo en desarrollo
});
```

```js
// store/modules/ui.js
export default {
  namespaced: true,     // sin esto, sus mutations son de todos y de nadie
  state: state,
  mutations: mutations
};
```

Y el sitio que escribía directo pasa por su mutation:

```js
// antes:  this.$store.state.tickets.items.push(ticket);
this.$store.commit("tickets/UPSERT_TICKET", ticket);
```

**La refactorización correcta.** El parche cierra los dos casos; lo que evita que
vuelvan es una regla de arquitectura escrita y comprobable: **el state solo se
escribe desde mutations, y todos los módulos son `namespaced`.** Lo segundo se
audita con un `grep`; lo primero, con `strict` encendido y una pasada por la
aplicación entera —que es el ejercicio 1 de la fase y debería dar cero
advertencias.

Mientras estás ahí, vale la pena revisar la reincidencia que la fase nombra: las
actions que no devuelven su Promise. Es la misma familia de fallos silenciosos y
produce el mismo tipo de reporte ("la pantalla no reacciona después de guardar").

**Prueba de regresión.**

```js
// tests/unit/store-ui.spec.js
it("el módulo ui está namespaced", function () {
  var store = new Vuex.Store({ modules: { ui: ui, tickets: tickets }, strict: true });
  store.commit("ui/SET_LOADING", true);
  expect(store.state.ui.loading).toBe(true);
  expect(store.state.tickets.loading).toBe(false);   // no se pisaron
});

it("strict caza la escritura directa", function () {
  var store = new Vuex.Store({ modules: { tickets: tickets }, strict: true });
  expect(function () { store.state.tickets.items.push({ id: 1 }); }).toThrow();
});
```

**Prevención.** Tres líneas en la revisión de código, y ninguna cuesta tiempo:

```bash
grep -rn "\$store.state" src/ | grep -v "mapState"    # escrituras directas sospechosas
grep -rLn "namespaced" src/store/modules/             # módulos sin espacio de nombres
```

Y `strict` encendido en desarrollo, siempre. Su coste es real —clona y compara el
estado en cada cambio— y por eso está apagado en producción; su valor es que
convierte un bug invisible en un error con stack trace.

**Por qué llegó a producción.** Porque las dos causas son **silenciosas por
diseño**. Escribir en el state sin mutation funciona: Vuex no lo impide, solo
puede avisarte si se lo pides. Y un módulo sin `namespaced` no es un error de
configuración, es una opción legítima que en un proyecto pequeño hasta se usa a
propósito. Los dos fallos aparecen cuando el proyecto crece lo suficiente para
que dos módulos compartan un nombre — y para entonces nadie recuerda la decisión.

**Si tu causa fue distinta a ésta.** Si tu contador se descuadraba por una acción
con caché que devolvía datos viejos, comprueba el registro: una lectura cacheada
**no produce mutations**, así que si ves `SET_TICKETS` con datos raros no fue la
caché. Y si concluiste "hay que sacar Vuex", ojo con el razonamiento: sin Vuex
este bug seguiría existiendo y no habrías tenido registro para encontrarlo.

</details>

---

EOF
grep -c "^## Incidente" cuaderno-incidentes.md; wc -l cuaderno-incidentes.md

# --- 2026-09-10T02:09:33 · Write incidents 11-12 plus retrospective for course 01
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/01-vue2-legacy
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 11 — "El test pasa solo cuando lo corro aislado"

> **Fase:** 11 · **Categoría:** Testing · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

### 🎫 El ticket

> "El test del servicio de tickets falla desde ayer. Si lo corro solo con `-t`
> pasa perfecto; con la suite entera falla. Yo no toqué ese archivo, toqué el de
> los badges. Ya borré `node_modules` y reinstalé, igual.
>
> Y ya que estamos: hay un test del dashboard que nunca ha fallado en la vida, ni
> cuando rompimos el filtro a propósito la semana pasada. ¿Eso está bien?"

**Reportado por:** un compañero del equipo · **Ambiente:** local y CI

### 🎯 Qué se te pide

Dos entregables, y el segundo vale más que el primero:

1. Arreglar el test que depende del orden, con causa raíz nombrada.
2. Demostrar si el test "que nunca falla" prueba algo. La técnica para
   demostrarlo cabe en una frase y la vas a usar el resto de tu vida
   profesional; si el test resulta ser decorativo, arréglalo o bórralo — las dos
   son respuestas válidas, "dejarlo por si acaso" no.

### 🔧 Preparación

Una rama, con las dos roturas:

```bash
git switch -c incidente/11 fase-11-testing-minimo
```

1. En `tests/unit/store-tickets.spec.js`, comenta el `jest.clearAllMocks()` del
   `beforeEach` y mueve la creación del store fuera del `beforeEach` (que se
   cree una sola vez para todo el archivo).
2. En `tests/unit/TicketsView.spec.js`, quita el `return` de la Promise en el
   test de carga:
   `it("carga tickets", function () { wrapper.vm.loadTickets(); expect(...); })`.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes que el código de los tests, confirma el fenómeno con dos comandos: el test
solo, y la suite en serie. Si en serie también falla, el paralelismo no era la
causa — solo el mensajero.

Y lee el mensaje de fallo entero: cuando dice "esperaba 1 llamada, recibí 3", ya
te está contando media historia.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

¿Qué sobrevive entre un test y el siguiente? Hay dos candidatos en este proyecto:
los mocks (que acumulan llamadas) y cualquier cosa creada **fuera** del
`beforeEach`.

Para el segundo problema: rompe a propósito lo que el test dice probar y vuelve a
correrlo.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Un test que llama a una función asíncrona y afirma en la línea siguiente, ¿sobre
qué estado está afirmando?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Dos patologías con la misma raíz —**estado que sobrevive donde no
debía**— y síntomas opuestos:

1. *El test que depende del orden.* Los mocks son objetos vivos que acumulan
   llamadas: sin `jest.clearAllMocks()` entre tests, el segundo hereda el
   historial del primero y `toHaveBeenCalledTimes(1)` recibe 3. Y el store creado
   una sola vez para todo el archivo arrastra los datos que dejaron los tests
   anteriores, así que la action con caché decide **no** llamar al servicio
   —"ya tengo datos"— y el contador vuelve a no cuadrar. Corrido solo, el archivo
   empieza limpio y todo pasa.

2. *El test que nunca falla.* No hay `return` de la Promise, así que Jest da el
   test por terminado antes de que se resuelva: la aserción corre sobre el estado
   inicial. Rompe el filtro, rompe el servicio, rompe lo que quieras — sigue
   verde. **No es un test: es decoración.**

**Parche mínimo:**

```js
// tests/unit/store-tickets.spec.js
var store;
beforeEach(function () {
  jest.clearAllMocks();          // que un test no herede llamadas del anterior
  store = createStore();         // ni estado del anterior
});
```

```js
// tests/unit/TicketsView.spec.js
it("carga los tickets al montarse", function () {
  ticketService.getTickets.mockResolvedValue([{ id: 1, title: "X", status: "open" }]);
  var wrapper = shallowMount(TicketsView, { … });

  return wrapper.vm.loadTickets().then(function () {   // ← el return que faltaba
    expect(wrapper.vm.tickets).toHaveLength(1);
    expect(wrapper.vm.loading).toBe(false);
  });
});
```

**La refactorización correcta.** El parche arregla dos archivos; lo que evita la
reincidencia es que **cada test construya su propio mundo**. Una fábrica
`createStore()` en los helpers, un `beforeEach` que la use, y la regla de que
nada con estado se declare en el ámbito del archivo. Con eso, el orden de
ejecución deja de importar y `--runInBand` vuelve a ser lo que debe: una
herramienta de diagnóstico, no un parche permanente.

Y para el verde falso, la disciplina que lo hace imposible: **todo test que toque
código asíncrono devuelve algo** —la Promise, o usa `async/await`—. Es
verificable con una regla de ESLint (`jest/valid-expect-in-promise`,
`require-await`), que es mejor que confiar en la revisión humana.

**Prueba de regresión.** Acá la prueba de regresión es peculiar y vale la pena
entenderla: **el test de que el test funciona** es romper el código de producción
y comprobar que se pone rojo.

```bash
# rompe a propósito el filtro y corre la suite
git stash list                      # asegúrate de poder volver
# … edita computed filteredTickets para que devuelva siempre this.tickets …
npx vue-cli-service test:unit
# debe FALLAR. Si pasa, el test no prueba nada.
git checkout -- src/views/TicketsView.vue
```

**Prevención.** Dos hábitos:

- **Rompe a propósito lo que el test dice probar**, al escribirlo. Un minuto, y
  te dice si la red de seguridad existe o es un dibujo de una red.
- Un `grep` de revisión para el verde falso más común:

  ```bash
  grep -rn "it(" -A 3 tests/unit | grep -B 1 "\.then(" | grep -v "return"
  ```

**Por qué llegó a producción.** Porque los dos fallos **se ven como éxito**. Un
test que pasa por el orden pasa la mayor parte del tiempo, y cuando falla se
etiqueta como flaky y se salta. Un test que nunca falla es, para cualquier
tablero de CI, un test perfecto. Ninguna herramienta del proyecto podía
distinguirlos de los buenos: la única forma de saberlo es romper el código a
propósito, y eso no lo hace nadie salvo que sea un hábito instalado.

**Si tu causa fue distinta a ésta.** Si tu test fallaba por selectores acoplados
al DOM —`find(".col-md-6 > div:nth-child(2)")` que se rompe al cambiar la
maquetación— es otro de los errores comunes de la fase y también hay que
arreglarlo, con `data-testid`. Pero fíjate en la diferencia: ese falla
**siempre** después del cambio, no según con quién corra. Los intermitentes son
de estado compartido; los constantes, de acoplamiento.

</details>

---

## Incidente 12 — "En el servidor de pruebas se comporta distinto que en mi máquina"

> **Fase:** 10 · **Categoría:** Build · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

### 🎫 El ticket

> "Subimos la versión nueva a UAT y el dashboard se comporta raro: los contadores
> de arriba a veces se quedan con números viejos y el orden de la tabla cambia
> solo al filtrar. En mi máquina, con `npm run serve`, no pasa nunca. Lo he
> probado veinte veces. Y en UAT tampoco sale ningún error en la consola."

**Reportado por:** el compañero que hizo el despliegue · **Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir en tu máquina un bug que **solo existe en el build de producción**, lo
cual ya es la mitad del trabajo y la parte que casi nadie sabe hacer. Después:
causa raíz, fix, y una explicación en tres líneas de por qué la consola de UAT
está limpia. El entregable incluye el comando exacto con el que reprodujiste.

### 🔧 Preparación

No hace falta romper nada: el bug ya está en el proyecto, esperando el build.
Necesitas ejecutar la aplicación **compilada**, no el servidor de desarrollo.

```bash
npm run build
npx serve -s dist -l 5000     # o cualquier servidor estático
```

Y como escenario, un componente que escriba en el store sin pasar por una
mutation. Si no lo tienes, la rama del [incidente 10](#incidente-10--el-contador-del-menú-dice-una-cosa-y-la-tabla-otra)
te sirve tal cual: es exactamente esa rotura, vista desde el otro lado.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes de buscar el bug, busca **la diferencia**. Enumera qué cambia entre
`npm run serve` y el build: no son diez cosas, son tres o cuatro, y una de ellas
está escrita en el `store/index.js` que llevas dos fases mirando.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

`process.env.NODE_ENV` no vale lo mismo en los dos entornos. Busca en el proyecto
todo lo que dependa de esa variable y pregúntate qué deja de hacer cada cosa en
producción.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el vigilante solo está de guardia en desarrollo, ¿qué pasa en producción con
lo que él impedía? ¿Deja de ocurrir, o deja de avisarse?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** El bug existe en los dos entornos; lo que cambia es **quién
avisa**. En `store/index.js`:

```js
strict: process.env.NODE_ENV !== "production",   // caro: solo en dev
```

En desarrollo, `strict` lanza un error inmediato en cuanto alguien escribe en el
state fuera de una mutation, así que el bug se caza al primer intento y nunca
llega a manifestarse como dato incorrecto. En el build de producción `strict`
está apagado —cuesta caro, y por eso se apaga—, la escritura furtiva ocurre en
silencio, y sus consecuencias aparecen mucho después y lejos: contadores que no
cuadran, listas que se reordenan solas, y una consola impecable.

Hay un segundo efecto de la misma variable que conviene conocer, porque explica
el resto del "en mi máquina no pasa": **los warnings de Vue solo existen en
desarrollo.** El aviso de mutación de props, el de `:key` duplicada y compañía
desaparecen del bundle de producción. No es que el problema no exista: es que el
build no habla.

**Parche mínimo.** El fix es el del incidente 10 —la escritura pasa por su
mutation— pero el hallazgo de **este** incidente es otro y merece su propia
línea: el ritual de despliegue tiene que incluir una pasada por el build.

```json
{
  "scripts": {
    "preview": "npm run build && npx serve -s dist -l 5000"
  }
}
```

**La refactorización correcta.** Dos movimientos, y el segundo es el valioso:

1. Eliminar la causa (escritura fuera de mutation) y dejar `strict` encendido en
   desarrollo, que es donde tiene que cazarla.
2. Aceptar que **desarrollo y producción son entornos distintos** y tratarlos
   como tales: un paso de `preview` antes de cada despliegue, y una lista corta
   de lo que cambia entre los dos —`strict`, los warnings de Vue, la minificación,
   los source maps— pegada en el README. Esa lista es lo que convierte "en mi
   máquina funciona" en una hipótesis comprobable en vez de una discusión.

**Prueba de regresión.** El test del incidente 10 (`strict` caza la escritura
directa) cubre la causa. Para el entorno, lo que corresponde no es un test sino
una comprobación en el pipeline: que el build se genere y se sirva en CI, y que
al menos un recorrido básico se ejecute contra `dist`, no contra el dev server.

**Prevención.** Una frase, y conviene que esté escrita donde alguien la lea:
**nunca confíes en que "en producción va bien" porque en desarrollo no salió
ningún error.** Es literalmente al revés: producción es el entorno con menos
avisos. Todo lo que dependa de `NODE_ENV` merece una línea en la documentación
del proyecto diciendo qué se pierde.

**Por qué llegó a producción.** Porque el sistema está diseñado para que el
vigilante sea caro y solo esté en desarrollo — que es una decisión correcta, no
un descuido. El error de diseño no fue apagar `strict`, fue **no tener un paso
que ejercitara el build antes del despliegue**. Y el "lo probé veinte veces" del
reporte es cierto y no sirve: veinte veces en el entorno equivocado.

**Si tu causa fue distinta a ésta.** Si tu diferencia entre entornos resultó ser
otra —una variable de `baseURL` distinta, una ruta que solo funciona con el
`historyApiFallback` del dev server, un warning de reactividad que en producción
no sale— has encontrado un miembro legítimo de la misma familia. La lección es la
misma: enumera las diferencias del entorno **antes** de buscar el bug, porque el
bug casi siempre es viejo y lo nuevo es quién lo tapaba.

</details>

---

## 🪞 Retrospectiva

Cuando cierres varios incidentes, vuelve acá y llénala. No es un formalismo: la
lista de causas raíz de un sistema tiene forma, y verla es lo que convierte doce
casos sueltos en criterio.

| ID | Capa donde vivía | Pista que lo resolvió | Cuánto tardaste | Lo habrías visto antes si… |
|---|---|---|---|---|
| 01 | | | | |
| 02 | | | | |
| 03 | | | | |
| 04 | | | | |
| 05 | | | | |
| 06 | | | | |
| 07 | | | | |
| 08 | | | | |
| 09 | | | | |
| 10 | | | | |
| 11 | | | | |
| 12 | | | | |

Tres preguntas para cuando la tabla esté llena:

- **¿Qué capa concentró más incidentes?** Si es el estado —y lo va a ser—, ya
  sabes dónde mirar primero la próxima vez que un ticket sea vago.
- **¿Cuántos se resolvieron sin abrir un archivo de código?** En un curso bien
  hecho son más de la mitad, y ése es el número que justifica todo el track.
- **¿Cuántos terminaron en una deuda 💸 declarada en vez de en un bug?** Saber
  distinguir "esto está mal" de "esto está incompleto a propósito" es la
  diferencia entre un dev senior y uno que reescribe lo que no entiende.

---

## 📌 Pendientes

Lo que salió de los incidentes y no se arregló acá, con el motivo.

- **La sesión no es válida, solo existe** (incidente 03). El guard comprueba que
  el token esté, no que sirva. No se puede arreglar en el frontend: hace falta un
  servidor que conteste 401. Anotado en `SECURITY-NOTES.md`.
- **El que anuncia no es el que persiste** (incidentes 08 y 09). Los eventos de
  socket los emite el cliente que hizo el cambio, así que cualquiera puede
  anunciar algo falso. Correcto mientras el servidor sea un relé; se paga el día
  que exista un backend que confirme la escritura y emita.
- **La carrera del doble "tomar"** (incidente 09). El cliente puede reducir la
  ventana, no cerrarla. Hace falta que la escritura lleve la precondición dentro,
  y eso lo tiene que ofrecer el servidor.
- **`reporter` y `createdAt` los pone el navegador** (fases 5 y 6). Reglas de
  negocio en la capa equivocada, declaradas 💸 desde su fase. Mismo motivo: sin
  backend no hay dónde ponerlas bien.

> 🧭 Los cuatro pendientes tienen algo en común, y no es casualidad: **son
> exactamente los límites de un frontend que le habla a un mock.** Que estén
> escritos, con nombre y motivo, es lo que distingue una deuda técnica de un
> descuido.
EOF
grep -c "^## Incidente" cuaderno-incidentes.md; wc -l cuaderno-incidentes.md

# --- 2026-09-10T02:09:49 · Check unbounded growth in phase 3 and contract details
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
grep -n "history\|16 *MB\|sin techo\|crece" 03-embeber-vs-referenciar.md | head -15; echo "=== contrato clave ==="; sed -n '95,120p' 00-audit-contrato.md

# --- 2026-09-10T02:10:44 · Create course 02 notebook with first incident
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat > cuaderno-incidentes.md <<'EOF'
# 📓 Cuaderno de incidentes — Curso 02 · MongoDB para cerebros SQL

> Doce tickets vagos, como llegan de verdad: en palabras de quien los sufre, sin
> pasos de reproducción y con la mitad de la información. Cada uno trae su
> preparación, tres pistas plegadas, sitio para tu investigación y una solución
> de referencia.

**El trato.** La solución viene incluida y está plegada por una razón: abrirla
antes de tiempo solo te perjudica a ti. Si llevas cuarenta minutos atascado, abre
la pista 1. Si llevas otros veinte, la 2. Y cuando abras la solución, léela
**después** de haber escrito tu hipótesis, aunque sea la equivocada.

Este cuaderno es del **Curso 02** y sus incidentes son autocontenidos. Los dos
casos de costura —el frontend hablándole al backend— **no exigen haber hecho el
Curso 01**: parten de un frontend ya construido que se entrega listo para correr.

---

## 🧭 Cómo se trabaja un incidente

El método es el de [`forense-master.md`](forense-master.md), y las cuatro
preguntas van siempre en este orden, porque cada una cuesta un orden de magnitud
más que la anterior:

1. **¿Se reproduce, y con qué?** ¿Con otro dato, con más volumen, o hace falta
   otro código? En este curso la variante de volumen es decisiva: la mitad de los
   bugs de modelado no existen hasta que hay datos de verdad.
2. **¿Qué dice la evidencia observable, antes que el código?** El documento crudo
   en `mongosh`, el `explain()`, la línea de morgan que no apareció.
3. **¿En qué capa está?** Ruta, controller, service o el propio Mongo. Y la
   pregunta que este curso agrega: ¿está en la **consulta** o en el **modelo**?
4. **¿De qué lado de la frontera está?** El contrato de
   [`00-audit-contrato.md`](00-audit-contrato.md): `_id` ↔ `id`, `Date` ↔ ISO, la
   forma de cada respuesta.

### Las tres formas de tener el sistema roto

Cada incidente dice cuál usa, y usa **la más barata que sirve**:

```bash
node scripts/seed.incidente-04.js       # 1 · un seed alterno (lo más común acá)
node scripts/generate.js --tickets 100000   # 2 · volumen, cuando el bug lo necesita
git switch -c incidente/06 fase-06-atomicidad-transacciones-consistencia   # 3 · una rama
```

> ⚠️ Antes de sembrar un escenario, ten a mano cómo volver: `npm run seed`
> regenera la base del curso, y `docker compose down -v && docker compose up -d`
> la deja de cero ([A01](a01-docker.md)).

### La convención de commits

```
incidente(06): abre — dos agentes tomaron el mismo ticket
incidente(06): repro — dos sesiones de mongosh, sin carga
incidente(06): hipótesis descartada — no es la transacción, es un solo documento
incidente(06): causa — findOne + updateOne: la precondición no está en el filtro
incidente(06): fix — precondición en el filtro, matchedCount 0 → 409
incidente(06): cierre — test de concurrencia con 50 rondas y post-mortem
```

Los verbos son fijos: `abre`, `repro`, `hipótesis`, `hipótesis descartada`,
`causa`, `fix`, `cierre`. **Commitea también los callejones sin salida.** Y marca
el par de tags de la [convención §🚑](../prompts/convencion-de-git-y-tags.md):

```bash
git tag -a inc/f06/doble-take-roto -m "Síntoma, repro y la prueba en rojo."
git tag -a inc/f06/doble-take-fix  -m "Causa raíz, fix, y la prueba en verde."
```

### Estados

| Estado | Significado |
|---|---|
| ⬜ Sin empezar | Todavía no lo tocaste |
| 🔴 Abierto | Leído, sin reproducir |
| 🟡 En análisis | Reproducido, causa raíz sin confirmar |
| 🟢 Cerrado | Fix aplicado y prueba de regresión pasando |
| ⚪ Descartado | No se reproduce, y está documentado por qué |

---

## 📋 Índice

| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| 01 | 0 | "El contenedor está arriba y nadie conecta" | Operación | 🟢 | ⬜ |
| 02 | 1 | "El ticket está en la base y mi script no lo encuentra" | Consultas | 🟡 | ⬜ |
| 03 | 2 | "El reporte de sin asignar da dos números distintos" | Consultas | 🟡 | ⬜ |
| 04 | 3 | "Hay tickets que tardan diez veces más que los demás" | Modelado | 🟡 | ⬜ |
| 05 | 5 | "El tablero tarda cuatro segundos y antes iba bien" | Modelado | 🟠 | ⬜ |
| 06 | 6 | "Dos agentes tomaron el mismo ticket" | Atomicidad | 🟠 | ⬜ |
| 07 | 7 | "Creamos el índice y sigue igual de lento" | Índices | 🟠 | ⬜ |
| 08 | 8 | "La migración pasó el conteo y los reportes salen mal" | Modelado | 🟠 | ⬜ |
| 09 | 9 | "El reporte por estado devuelve una sola línea" | Consultas | 🟠 | ⬜ |
| 10 | 10 | "Apunté el frontend al backend nuevo y no se ve nada" | Contrato | 🔴 | ⬜ |
| 11 | 12 | "En vivo llega mal y al recargar se ve bien" | Contrato | 🔴 | ⬜ |
| 12 | 13 | "Verde en mi máquina, rojo en CI" | Testing | 🔴 | ⬜ |

---

## 🧪 Incidentes

## Incidente 01 — "El contenedor está arriba y nadie conecta"

> **Fase:** 0 · **Categoría:** Operación · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-40 min

### 🎫 El ticket

> "Levanté el compose como dice el README. `docker compose ps` dice que está
> corriendo. Pero ni Compass ni mongosh conectan, y la API tampoco arranca. Ayer
> funcionaba, hoy reinicié la máquina y ya no. No cambié nada."

**Reportado por:** alguien que se incorpora al proyecto · **Ambiente:** local

### 🎯 Qué se te pide

Que conecte, y una explicación de **por qué el cliente no podía saber la causa**.
Este incidente entrena el reflejo más rentable de la operación: leer el log del
servidor antes que el mensaje de error del cliente.

### 🔧 Preparación

La más barata: provocar la situación real, que es tener dos servidores peleando
por el mismo puerto.

```bash
# levanta un proceso cualquiera ocupando el 27017 antes del compose
docker run -d --name mongo-intruso -p 27017:27017 mongo:4.4
docker compose up -d
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

El cliente solo sabe que no lo dejaron entrar; el motivo está del otro lado. Hay
un comando que te enseña lo que el servidor intentó hacer al arrancar, y lo dice
en texto plano.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

`docker compose ps` puede decir "up" y el proceso estar reiniciándose en bucle.
Mira el log completo desde el arranque y busca las palabras `listener` y
`address`.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Quién más está escuchando en el 27017 de tu máquina?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** El `mongod` del compose no llegó a escuchar porque el puerto
27017 ya estaba ocupado. En el log:

```
mongo_1  | {"s":"E","c":"NETWORK","msg":"Failed to set up listener",
mongo_1  |  "attr":{"error":"Address already in use"}}
mongo_1  | {"s":"I","c":"CONTROL","msg":"now exiting"}
```

Y el "ayer funcionaba" tiene explicación exacta: el reinicio de la máquina
arrancó el `mongod` **nativo** instalado como servicio, que ayer no estaba
levantado. Dos servidores compitiendo; el de Docker llega segundo y se va.

**Parche mínimo:**

```bash
docker rm -f mongo-intruso          # o detén el servicio nativo
docker compose up -d
docker compose logs --tail 20 mongo
```

**La refactorización correcta.** Dos movimientos que hacen imposible la
repetición:

1. Publicar el puerto en uno propio del proyecto y dejarlo en el `.env`:
   `27018:27017`. El servicio nativo de tu máquina deja de ser un competidor.
2. Un `healthcheck` en el compose para que "arriba" signifique "contesta", no
   "el contenedor existe":

   ```yaml
   healthcheck:
     test: ["CMD", "mongo", "--eval", "db.runCommand({ping:1})"]
     interval: 10s
     retries: 5
   ```

**Prueba de regresión.** Un script de diagnóstico de tres líneas en el repo, que
es lo que le pasas al siguiente que reporte esto:

```bash
# scripts/doctor.sh
docker compose ps
docker compose logs --tail 30 mongo | grep -i "listener\|address\|exiting" || echo "log limpio"
docker compose exec -T mongo mongosh --quiet --eval 'db.runCommand({ping:1})'
```

**Prevención.** En el README, la regla de oro de este incidente escrita como
procedimiento: **ante cualquier "no conecta", el primer comando es el log del
servidor, no el cliente.** Y una nota sobre el `mongod` nativo, que es el
competidor invisible en las máquinas de quien ya trabajaba con Mongo.

**Por qué llegó a producción.** Nadie se equivocó: el compose estaba bien, el
README estaba bien, y el sistema no tenía forma de avisar de que había otro
proceso en el puerto salvo en un log que nadie mira. El fallo fue de
**observabilidad**, no de configuración — y por eso el arreglo estructural es el
`healthcheck`, que convierte un estado mentiroso ("up") en uno útil.

**Si tu causa fue distinta a ésta.** Si tu log estaba limpio y el ping funcionaba
**dentro** del contenedor pero no fuera, tu problema es la publicación del
puerto, y ese diagnóstico está en el paso 3 de la
[pieza forense de la Fase 0](forense-fase-00.md). Si al conectar viste las
colecciones vacías, era el volumen: los datos siguen en la ruta vieja.

</details>

---

EOF
grep -c "^## Incidente" cuaderno-incidentes.md; wc -l cuaderno-incidentes.md

# --- 2026-09-10T02:11:51 · Write incidents 2 and 3 of course 02
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 02 — "El ticket está en la base y mi script no lo encuentra"

> **Fase:** 1 · **Categoría:** Consultas · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-50 min

### 🎫 El ticket

> "Estoy haciendo un script de reporte. Copio el `_id` de un ticket desde
> Compass, lo pego en mi `find` y me devuelve vacío. El ticket está ahí, lo estoy
> viendo. Y el reporte por rango de fechas de marzo me trae tickets de julio.
> Vengo de Oracle y esto no me cuadra."

**Reportado por:** un compañero que se está pasando a Mongo · **Ambiente:** local

### 🎯 Qué se te pide

Los dos síntomas tienen la **misma raíz** y hay que decirlo así en el
post-mortem: es la mitad del valor del incidente. Se te pide arreglar el script,
y además escribir un pequeño auditor que detecte el problema de fondo en toda la
colección, porque si pasó con dos campos puede estar pasando con más.

### 🔧 Preparación

Un seed alterno que reproduce una base heredada realista: la mitad de los tickets
con `createdAt` como `Date` y la otra mitad como string ISO, tal como quedan
cuando alguien importó un `db.json` sin convertir.

```bash
node scripts/seed.incidente-02.js
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Mira el documento **crudo** en `mongosh`, no en la interfaz gráfica. Fíjate en lo
que hay alrededor de cada valor: unas comillas de más o de menos cambian el caso
entero.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Compara qué **tipo** tiene el valor guardado y qué tipo tiene el valor con el que
comparas. En Mongo, comparar tipos distintos no es un error: es un `false`.

```js
db.tickets.findOne({}, { createdAt: 1 })
db.tickets.countDocuments({ createdAt: { $type: "string" } })
```

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Un `_id` se **imprime** como 24 caracteres hexadecimales. ¿Se **guarda** como
eso?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** La misma en los dos casos: **se compara contra el tipo
equivocado, y Mongo no avisa.**

1. Un `_id` es un `ObjectId`, no la cadena con la que se imprime.
   `find({ _id: "5f8a…" })` compara un `ObjectId` con un string: no coincide
   nunca, y devuelve el conjunto vacío que corresponde. En Oracle esto habría
   sido un error de tipos; acá es un resultado legítimo.
2. Las fechas del seed heredado están **mezcladas**: unas como `Date` y otras
   como string ISO. Un `$gte: ISODate("2020-03-01")` solo compara contra las
   primeras, y entre strings el orden lexicográfico del ISO *parece* funcionar
   —hasta que llega una sin zona horaria o con otro formato—. Por eso el rango de
   marzo trae julio: mezcla dos universos de comparación.

**Parche mínimo:**

```js
db.tickets.find({ _id: ObjectId("5f8a1c2e4b3d2f0012a4e991") })
db.tickets.find({ createdAt: { $gte: ISODate("2020-03-01"), $lt: ISODate("2020-04-01") } })
```

**La refactorización correcta.** El parche arregla la consulta y deja la base
enferma. Dos movimientos:

1. **Normalizar los datos**, con un script idempotente y con `--dry` primero:

   ```js
   // scripts/fix-dates.js
   db.tickets.find({ createdAt: { $type: "string" } }).forEach(function (doc) {
     db.tickets.updateOne(
       { _id: doc._id },
       { $set: { createdAt: new Date(doc.createdAt) } }
     );
   });
   ```

2. **Impedir que vuelva**, con el validator de la Fase 4 exigiendo
   `bsonType: "date"`. La regla del motor aplica a todos los clientes: tu API, el
   script del compañero y mongosh.

Y el auditor que se pedía, que es la pieza que se lleva uno al trabajo real:

```js
// scripts/audit-types.js — un conteo por campo sospechoso
["createdAt", "priority", "status", "assignee"].forEach(function (field) {
  var types = db.tickets.aggregate([
    { $group: { _id: { $type: "$" + field }, n: { $sum: 1 } } }
  ]).toArray();
  print(field + ": " + JSON.stringify(types));
});
```

**Prueba de regresión.**

```js
// test/data-integrity.spec.js
it("no quedan fechas guardadas como texto", async function () {
  var n = await db.collection("tickets").countDocuments({ createdAt: { $type: "string" } });
  expect(n).toBe(0);
});
```

**Prevención.** Correr el auditor de tipos como parte del pipeline sobre la base
de pruebas. En una base sin esquema, **un conteo por tipo es la prueba unitaria
de los datos**, y cuesta segundos.

**Por qué llegó a producción.** Porque el `db.json` heredado del Curso 01 traía
las fechas como texto —en JSON no hay otra cosa— y el primer seed las insertó
tal cual. Nadie hizo nada raro: la conversión no estaba en ninguna parte porque
en el mundo relacional la columna la habría rechazado. La base aceptó los dos
tipos sin decir nada, y los reportes empezaron a mentir meses después.

**Si tu causa fue distinta a ésta.** Si tu script devolvía vacío pero por estar en
otra base o por un typo en el nombre de la colección, has encontrado el otro
gran silencio de Mongo: no existe el error "la tabla no existe", solo colecciones
fantasma que responden `0`. Está en el paso 2 de la
[pieza forense de la Fase 1](forense-fase-01.md).

</details>

---

## Incidente 03 — "El reporte de sin asignar da dos números distintos"

> **Fase:** 2 · **Categoría:** Consultas · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min

### 🎫 El ticket

> "El reporte de tickets sin asignar me da 34 y el que hice yo a mano en Compass
> da 41. Los dos filtran por lo mismo, ninguno da error. Necesito saber cuál
> mando al comité del jueves."

**Reportado por:** el analista de reportes · **Ambiente:** UAT

### 🎯 Qué se te pide

La pregunta correcta no es cuál está bien: es **qué está contando cada uno**.
Se te pide reproducir la diferencia, explicar el mecanismo con una tabla, y
—esto es lo importante— **convertirlo en una pregunta de negocio**: ¿"sin
asignar" incluye a los tickets que nunca tuvieron el campo? Con la respuesta
elegida y escrita, entonces sí, el filtro.

### 🔧 Preparación

Un seed alterno con los tres estados presentes, que es lo que produce una base
heredada de verdad:

```bash
node scripts/seed.incidente-03.js
```

Siembra tickets con `assignee: "soporte1"`, con `assignee: null` explícito, y
otros **sin el campo**.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No compares consultas: compara **conteos**. Escribe las dos versiones y cuenta
las dos. La diferencia entre los números es el tamaño exacto del malentendido.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

En SQL toda fila tiene todas las columnas. Acá no. Cuenta cuántos documentos
tienen el campo y cuántos no:

```js
db.tickets.countDocuments({ assignee: { $exists: false } })
```

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Tu instinto dice que `= NULL` no matchea nada. Pruébalo. Se equivoca, y se
equivoca en la dirección contraria a la que esperas.

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Ninguno de los dos filtros está mal escrito: **cuentan cosas
distintas**, porque en Mongo hay tres estados donde tu instinto relacional ve
dos.

| Filtro | Con valor | `null` explícito | Campo ausente |
|---|---|---|---|
| `{ assignee: null }` | ✗ | ✅ | ✅ **también** |
| `{ assignee: { $type: "null" } }` | ✗ | ✅ | ✗ |
| `{ assignee: { $exists: false } }` | ✗ | ✗ | ✅ |
| `{ assignee: { $ne: null } }` | ✅ | ✗ | ✗ |

El reporte de 41 usaba `{ assignee: null }` —que incluye los ausentes— y el de 34
usaba `$type: "null"`. Los 7 de diferencia son tickets que nunca tuvieron el
campo, casi siempre porque los creó una versión anterior del sistema.

**Parche mínimo.** Depende de la respuesta de negocio, y por eso el fix se
escribe **después** de contestarla. Si "sin asignar" es cualquier ticket que no
tiene a nadie trabajándolo —lo habitual—, la versión correcta es la laxa, y
conviene dejar el porqué en el código:

```js
// "Sin asignar" incluye los tickets sin el campo: son de la versión vieja
// del sistema y operativamente están igual de libres. Decidido con el comité,
// 2020-04. No cambiar sin volver a preguntar.
var UNASSIGNED = { assignee: null };
```

**La refactorización correcta.** Dos cosas, y la segunda es la que evita el
siguiente reporte descuadrado:

1. **Un solo sitio** donde viva la definición de cada concepto del negocio
   —"sin asignar", "activo", "vencido"— y que todos los reportes importen. Dos
   analistas escribiendo el mismo filtro a mano es la fábrica de este incidente.
2. **Normalizar la ausencia**: un script idempotente que ponga `assignee: null`
   explícito donde falte, más el validator de la Fase 4 con `required` para que
   el campo no pueda volver a faltar. Con eso los tres estados se reducen a dos y
   la trampa desaparece de raíz.

**Prueba de regresión.**

```js
it("el filtro de sin asignar cubre null explícito y campo ausente", async function () {
  await col.insertMany([
    { title: "A", assignee: "soporte1" },
    { title: "B", assignee: null },
    { title: "C" }
  ]);
  expect(await col.countDocuments(UNASSIGNED)).toBe(2);
});
```

**Prevención.** Una regla para los reportes heredados, barata y demoledora:
**escribe cada filtro de dos formas y cuenta las dos.** Si los números difieren,
acabas de encontrar una pregunta de negocio que nadie había contestado — y es
mejor encontrarla tú que el comité del jueves.

**Por qué llegó a producción.** Porque los dos filtros son correctos, los dos son
razonables, y ninguna herramienta puede decir cuál querías. La migración desde el
mundo relacional trajo intacto el reflejo de que un campo o tiene valor o es
nulo; el tercer estado no existía en el modelo mental de nadie, y el sistema no
tenía cómo señalarlo.

**Si tu causa fue distinta a ésta.** Si la diferencia venía de `$ne` —"asignados
a alguien que no es soporte1" contra "no asignados a soporte1"— es la misma
trampa por el otro lado, y también es un hallazgo legítimo: `$ne` incluye a los
ausentes. Si venía de `count()` contra `countDocuments()`, encontraste un tercer
miembro de la familia: el primero puede estimar.

</details>

---

EOF
grep -c "^## Incidente" cuaderno-incidentes.md; wc -l cuaderno-incidentes.md

# --- 2026-09-10T02:13:08 · Write incidents 4 and 5 of course 02
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 04 — "Hay tickets que tardan diez veces más que los demás"

> **Fase:** 3 · **Categoría:** Modelado · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1-1,5 h

### 🎫 El ticket

> "Casi todos los tickets abren al instante, pero hay unos pocos que tardan
> varios segundos y a veces se queda la pantalla en blanco. Son siempre los
> mismos: los más viejos, los que llevan meses abiertos y se han pasado entre
> varios agentes. Los recién creados van rápido."

**Reportado por:** coordinadora de soporte · **Ambiente:** UAT

### 🎯 Qué se te pide

Medir en vez de opinar: hace falta un número que distinga un ticket "normal" de
uno "lento". Después, decir **qué decisión de modelado** produce esa asimetría y
si tiene techo. Y por último, la parte que este curso pide siempre: si hay que
cambiar el modelo, defiende el cambio con el criterio de la fase, no con gusto
personal.

### 🔧 Preparación

Un seed alterno con la distribución realista de una base heredada: la mayoría de
tickets con historial corto y unos pocos con historial gigante.

```bash
node scripts/seed.incidente-04.js     # 10.000 tickets, 20 con history de ~15.000 entradas
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No mires la consulta todavía: mira los **documentos**. Compara el tamaño de uno
de los lentos con el de uno normal.

```js
Object.bsonsize(db.tickets.findOne({ _id: ObjectId("…") }))
```

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

¿Qué campo hace la diferencia de tamaño? ¿Y quién lo lee? Cuando la API devuelve
un ticket para pintar la pantalla de detalle, ¿necesita ese campo?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El array crece con cada cambio de estado del ticket. ¿Cuál es su techo?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** El array `history` está **embebido y no tiene techo**. Cada
transición de estado le añade una entrada, y en tickets que llevan meses vivos
—y que pasaron por varios agentes, con automatismos que también escriben— el
array crece hasta que el documento pesa cientos de KB o más. Como Mongo lee y
escribe el **documento entero**, cada lectura de esos tickets mueve todo ese peso
aunque la pantalla solo pinte el título y el estado.

```js
> Object.bsonsize(db.tickets.findOne({ legacyId: 41 }))
2841
> Object.bsonsize(db.tickets.findOne({ legacyId: 7 }))
1874203
```

La Fase 3 lo nombra entre sus vetos físicos: **arrays sin techo**. El límite duro
de 16 MB por documento es el final del camino —y ahí el ticket deja de poder
guardarse—, pero mucho antes de llegar el rendimiento ya se degradó.

Importante para el post-mortem: el diseño **no era irrazonable**. El historial se
lee junto con el ticket, es del ticket, no se consulta transversalmente. Cumplía
los tres criterios de embeber… salvo el del techo, que es el que veta.

**Parche mínimo** — el del viernes a las seis, que no cambia el modelo:

```js
// La API deja de arrastrar el historial en el listado y en el detalle
db.tickets.find({ status: "open" }, { history: 0 })
```

Con una proyección que excluya `history`, la pantalla vuelve a ir rápida. El
documento sigue siendo enorme —cada escritura lo sigue pagando— pero el síntoma
desaparece, y a veces eso es exactamente lo que hay que hacer un viernes.

**La refactorización correcta.** Sacar el historial a su propia colección, con
referencia al ticket:

```js
// ticket_events
{ _id: ObjectId("…"), ticketId: ObjectId("…"), at: ISODate("…"),
  from: "open", to: "in_progress", by: "soporte1" }
```

Y con eso:

- el ticket vuelve a pesar lo que pesa un ticket, y su lectura no depende de su
  edad;
- el historial se pagina —que es lo que la pantalla necesita: las últimas diez
  entradas, no quince mil—;
- se pierde la atomicidad regalada que tenías al hacer `$push` al array y `$set`
  del estado en **una** operación. Eso hay que decirlo en voz alta: es una
  contrapartida real, y la Fase 6 explica cómo recuperar la garantía cuando de
  verdad haga falta.

La migración es idempotente y va en dos pasos: copiar cada entrada del array a la
colección nueva con su `ticketId`, verificar por muestreo, y solo entonces
`$unset` del campo.

**Prueba de regresión.**

```js
it("ningún ticket supera el techo de tamaño acordado", async function () {
  var big = await col.aggregate([
    { $project: { size: { $bsonSize: "$$ROOT" } } },
    { $match: { size: { $gt: 100 * 1024 } } }
  ]).toArray();
  expect(big).toHaveLength(0);
});
```

(En 4.4 `$bsonSize` está disponible; si tu pipeline no lo admite, el mismo test se
escribe con `Object.bsonsize` en un script de auditoría.)

**Prevención.** La pregunta del techo entra en la plantilla de decisiones de
modelado —`DATA-MODEL.md`— y se contesta con un número, no con "no debería
crecer mucho": **¿cuál es el p99 del tamaño de este array a un año?** Si la
respuesta es "no lo sé", la decisión es referenciar.

**Por qué llegó a producción.** Porque el diseño se validó con datos de
desarrollo, donde todos los tickets tienen dos o tres transiciones. Un array sin
techo se comporta perfectamente hasta que el tiempo lo llena, y el tiempo tarda
meses en llegar. Nadie se equivocó al embeber: faltó preguntar por el techo, que
es la única de las cuatro preguntas de modelado que **no se puede contestar
mirando la aplicación de hoy**.

**Si tu causa fue distinta a ésta.** Si tu conclusión fue "faltan índices",
compruébalo con `explain()`: el acceso por `_id` ya usa el índice y sigue lento,
porque el coste no está en encontrar el documento sino en moverlo. Es
exactamente el caso donde afinar índices no arregla nada, y la
[pieza de la Fase 7](forense-fase-07.md) lo llama el meta-error de esa fase.

</details>

---

## Incidente 05 — "El tablero tarda cuatro segundos y antes iba bien"

> **Fase:** 5 · **Categoría:** Modelado · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

### 🎫 El ticket

> "El tablero de soporte tarda como cuatro segundos en abrir. Antes iba bien. No
> hemos tocado esa pantalla en meses, solo se ha ido llenando de tickets y
> comentarios. Y es peor a primera hora, cuando entramos todos."

**Reportado por:** coordinadora de soporte · **Ambiente:** UAT

### 🎯 Qué se te pide

Que la pantalla vuelva a ir rápida, con **números antes y después medidos en las
mismas condiciones**. Y una respuesta escrita a la pregunta que la fase pone
sobre la mesa: ¿esto se arregla con una consulta mejor, o el modelo está
pidiendo otra cosa? Las dos respuestas son legítimas; lo que no vale es no
haberla hecho.

### 🔧 Preparación

Volumen: este bug no existe con datos de juguete.

```bash
node scripts/generate.js --tickets 100000 --comments 400000
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Antes de medir ninguna consulta, **cuéntalas**. Abre la pantalla una vez y mira
cuántas líneas aparecen en el log de la API.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Si son muchas y todas rápidas, el problema no es ninguna de ellas. Si es una sola
y lenta, mira su `explain("executionStats")` y compara `totalDocsExamined` con
`nReturned`.

Y presta atención al **orden de las etapas** del pipeline: ¿en qué momento se
filtra?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Cuántos documentos se unen antes de que el filtro descarte la mayoría?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Dos capas del mismo problema, y conviene separarlas:

1. *El pipeline une antes de filtrar.* El `$match` por `status` está **después**
   del `$lookup` con comentarios, así que el motor une los 100.000 tickets con
   sus 400.000 comentarios y luego se queda con los abiertos:

   ```
   nReturned: 41230, totalDocsExamined: 100000, executionTimeMillis: 3184
   ```

   Moviendo el `$match` al principio, la misma consulta baja a cientos de
   milisegundos. Es el `WHERE` que tu instinto SQL jamás habría puesto al final,
   y acá se escribe así porque el pipeline se lee como una receta.

2. *El modelo pide otra cosa.* Aun con el orden corregido, la pantalla necesita
   tickets **con su conteo de comentarios**, y calcularlo en cada carga es unir
   dos colecciones grandes para producir un número. Eso no es una consulta: es un
   dato derivado que nadie guardó.

**Parche mínimo:**

```js
db.tickets.aggregate([
  { $match: { status: "open" } },                 // primero, siempre
  { $sort: { createdAt: -1 } },
  { $limit: 50 },                                 // y solo lo que la pantalla pinta
  { $lookup: { from: "comments", localField: "_id", foreignField: "ticketId", as: "comments" } }
])
```

**La refactorización correcta.** Un contador denormalizado en el ticket:

```js
{ _id: ObjectId("…"), title: "…", status: "open", commentCount: 12 }
```

Se mantiene con `$inc` en la misma operación que inserta el comentario, y con
eso la pantalla deja de unir nada. Pero **denormalizar sin protocolo es peor que
no denormalizar**, así que la decisión viene con tres compromisos escritos:

- **quién escribe** el contador (solo el service de comentarios, un único sitio);
- **cuánta divergencia se tolera** y por cuánto tiempo;
- **cómo se reconcilia** — un job que recuente, acotado por `updatedAt`, no
  recorriendo la colección entera cada noche.

Sin esas tres frases en `DATA-MODEL.md`, el contador se desincroniza y nadie sabe
cuál es la verdad.

**Prueba de regresión.** Una de corrección y una de coste:

```js
it("mantiene el contador al insertar un comentario", async function () {
  await service.addComment(ticketId, { body: "hola" });
  var t = await col.findOne({ _id: ticketId });
  expect(t.commentCount).toBe(1);
});

it("el listado no examina más documentos de los que devuelve", async function () {
  var stats = await explainList({ status: "open", limit: 50 });
  expect(stats.totalDocsExamined).toBeLessThanOrEqual(stats.nReturned * 2);
});
```

Ese segundo test es de los más útiles que vas a escribir: **una aserción sobre el
plan de ejecución** falla el día que alguien reordene las etapas, mucho antes de
que un usuario lo note.

**Prevención.** Dos hábitos: medir el listado principal con volumen real en cada
cambio del pipeline, y tratar cada `$lookup` nuevo como una pregunta sobre el
modelo —¿estos datos se leen siempre juntos?— antes que como una consulta.

**Por qué llegó a producción.** Porque con mil tickets el pipeline mal ordenado
tarda 30 ms y nadie lo nota. El coste de unir antes de filtrar crece con el
volumen, no con el código, así que el sistema se degrada solo mientras todo el
mundo hace su trabajo bien. Y el `$lookup` se escribió porque se parecía al JOIN
que había en el sistema anterior — el instinto correcto en el sitio equivocado.

**Si tu causa fue distinta a ésta.** Si tu log mostraba decenas de peticiones en
vez de una lenta, encontraste el N+1 clásico y el arreglo es agrupar en una
consulta —no necesariamente un `$lookup`: un `$in` con los ids suele ganar—. Si
tu `$unwind` hizo desaparecer los tickets sin comentarios, encontraste el LEFT
que se volvió INNER: falta `preserveNullAndEmptyArrays`.

</details>

---

EOF
grep -c "^## Incidente" cuaderno-incidentes.md; wc -l cuaderno-incidentes.md

# --- 2026-09-10T02:14:21 · Write incidents 6 and 7 of course 02
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 06 — "Dos agentes tomaron el mismo ticket"

> **Fase:** 6 · **Categoría:** Atomicidad · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

### 🎫 El ticket

> "Ana y yo tomamos el mismo ticket casi al mismo tiempo. A los dos nos dijo que
> quedó asignado, sin ningún error. En el listado aparece asignado a Ana y en mi
> pantalla aparezco yo. Pasa poco, pero cuando pasa nos enteramos tarde y
> duplicamos trabajo."

**Reportado por:** agente de soporte · **Ambiente:** UAT, dos usuarios reales

### 🎯 Qué se te pide

Reproducirlo **de forma determinista** —"pasa poco" tiene que convertirse en "las
veces que yo quiera"—, arreglarlo, y distinguir en el contrato dos respuestas que
hoy se confunden. Y una decisión razonada: ¿hace falta una transacción? Contesta
con argumentos; la respuesta correcta sorprende a casi todo el mundo que viene de
SQL.

### 🔧 Preparación

Ni volumen ni caos: dos sesiones de `mongosh` bastan. Y para el caso del código,
una rama.

```bash
git switch -c incidente/06 fase-06-atomicidad-transacciones-consistencia
node scripts/seed.incidente-06.js     # deja el ticket de prueba sin asignar
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Mira lo que **devolvió** cada escritura, no lo que quedó en la base:
`matchedCount` y `modifiedCount` tienen la mitad de la historia.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Busca en el service la forma característica: una lectura, una comprobación, y una
escritura. Entre la primera y la tercera hay un hueco. ¿Qué lo protege?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

La condición "solo si sigue libre", ¿dónde está escrita? ¿En un `if` o en el
filtro del update?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** El service hace **read-modify-write**:

```js
var ticket = await tickets.findOne({ _id: id });
if (ticket.assignee) { throw new ConflictError("Ya está asignado"); }
await tickets.updateOne({ _id: id }, { $set: { assignee: user, status: "in_progress" } });
```

Entre el `findOne` y el `updateOne` hay una ventana. Los dos procesos leyeron
"sin asignar", los dos pasaron la comprobación y los dos escribieron: la segunda
escritura pisó a la primera con todo el derecho, porque su filtro solo dice "este
ticket", y ese ticket existe. **No hubo una carrera perdida: hubo dos carreras
ganadas.**

En tu motor de siempre, un `SELECT … FOR UPDATE` dentro de la transacción
implícita del framework tapaba esto sin que tuvieras que pensarlo. Acá no hay
nada puesto.

**Parche mínimo** — la precondición se muda al filtro:

```js
var result = await tickets.updateOne(
  { _id: id, assignee: null },                                   // ← la condición, adentro
  { $set: { assignee: user, status: "in_progress" } }
);
if (result.matchedCount === 0) { … }
```

Una escritura sobre **un** documento ya es atómica: con la condición dentro del
filtro, comprobar y escribir dejan de ser dos operaciones. El segundo agente
recibe `matchedCount: 0` y se entera.

**La refactorización correcta.** El parche arregla la carrera; el contrato
necesita además distinguir dos respuestas que hoy son la misma:

```js
if (result.matchedCount === 0) {
  var exists = await tickets.countDocuments({ _id: id });
  if (!exists) { throw new NotFoundError(); }        // 404: no existe
  throw new ConflictError("Ana se te adelantó");     // 409: existe y no cumple
}
```

`matchedCount: 0` **no significa "no existe"**: puede existir y no cumplir la
precondición. Colapsarlas en un 404 produce el reporte gemelo —*"me dice que el
ticket no existe y ahí está"*— y le quita al usuario la única información útil.

Y la respuesta a la pregunta de la transacción: **no hace falta**. Es un solo
documento, y envolverlo en `withTransaction` paga sesión, límite de 60 s y
riesgo de conflictos por una garantía que ya tenías. Las transacciones son para
cuando de verdad hay que tocar dos colecciones — y entonces hay que acordarse de
pasar `{ session }` a **todas** las operaciones, porque la que se olvide corre
fuera, sin error y sin aviso.

**Prueba de regresión.** Y acá está la parte que casi nadie hace bien: una
carrera es **probabilística**, así que un test de una sola ronda no prueba nada.

```js
it("solo un agente puede tomar el ticket, en 50 rondas", async function () {
  for (var i = 0; i < 50; i++) {
    var id = await seedFreeTicket();
    var results = await Promise.all([
      service.take(id, "ana"),
      service.take(id, "beto")
    ].map(function (p) { return p.catch(function (e) { return e; }); }));

    var ok = results.filter(function (r) { return !(r instanceof Error); });
    expect(ok).toHaveLength(1);
  }
});
```

**Prevención.** Una regla que cabe en la revisión de código: **si un `if` decide
si se puede escribir, esa condición pertenece al filtro de la escritura.** Y un
`grep` que encuentra los sospechosos:

```bash
grep -rn "findOne" -A 6 src/services/ | grep -n "updateOne\|updateMany"
```

**Por qué llegó a producción.** Porque en desarrollo eres un usuario haciendo una
cosa a la vez, y el código *parece* correcto: la comprobación está escrita, es
explícita y se lee bien. El sistema no tenía forma de avisar de que esa
comprobación no valía nada bajo concurrencia — y la concurrencia solo aparece
cuando el sistema tiene usuarios de verdad. Nadie escribió mal el `if`; faltaba
la traducción de un reflejo que en el mundo relacional era gratuito.

**Si tu causa fue distinta a ésta.** Si tu caso era un contador que quedaba corto
(`doc.n++; save()`), es la misma familia con otro disfraz y el arreglo es `$inc`.
Si era una transacción a la que le faltaba una escritura, encontraste el fallo
más traicionero de la fase: la operación sin `{ session }` corre fuera y el
todo-o-nada queda agujereado sin un solo error.

</details>

---

## Incidente 07 — "Creamos el índice y sigue igual de lento"

> **Fase:** 7 · **Categoría:** Índices · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1-1,5 h

### 🎫 El ticket

> "Nos dijeron que el listado iba lento por falta de índice. Creamos el índice,
> lo vemos en Compass, y va exactamente igual. ¿Hay que reiniciar Mongo? ¿O
> creamos el índice mal?"

**Reportado por:** el compañero que está optimizando · **Ambiente:** UAT

### 🎯 Qué se te pide

Explicar **por qué el índice no se usa** con evidencia del plan de ejecución, no
con teoría; corregirlo; y medir antes y después en las mismas condiciones. Y una
segunda entrega que separa a quien entiende índices de quien los crea: revisar si
el resto de índices de la colección sirven para algo, y borrar los que no —con el
argumento de cuánto cuestan en escritura.

### 🔧 Preparación

Volumen y un índice mal orientado:

```bash
node scripts/generate.js --tickets 100000
```

```js
db.tickets.createIndex({ createdAt: -1, status: 1 })   // el compuesto al revés
```

Y la consulta que sufre es la del contrato: filtrar por `status` y ordenar por
`createdAt` descendente.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

`explain()` a secas no sirve: pídele estadísticas de ejecución y mira dos
números, no la etiqueta de la etapa.

```js
db.tickets.find({ status: "open" }).sort({ createdAt: -1 })
  .explain("executionStats").executionStats
```

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Pon el índice y la consulta uno debajo del otro. ¿Por qué campo empieza cada uno?

Y busca en el plan si aparece una etapa `SORT`: si el índice sirviera para
ordenar, no haría falta.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Un índice compuesto se puede usar empezando por su primera clave. Tu consulta,
¿filtra por esa primera clave?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** El compuesto está **al revés** para esta consulta. Con
`{ createdAt: -1, status: 1 }`, el prefijo izquierdo es `createdAt`, y la consulta
no filtra por ese campo: no hay por dónde entrar al índice. El plan lo dice:

```
totalKeysExamined: 0, totalDocsExamined: 100000, stage: 'COLLSCAN'
```

Es exactamente la regla de prefijo izquierdo que ya conoces de tu motor
relacional; lo único nuevo es dónde leerla.

**Parche mínimo:**

```js
db.tickets.createIndex({ status: 1, createdAt: -1 })
```

```
totalKeysExamined: 20, totalDocsExamined: 20, executionTimeMillis: 3
```

Con el filtro entrando por el prefijo, el orden sale gratis del propio índice: la
etapa `SORT` desaparece, que es la señal de que el compuesto quedó bien
orientado.

**La refactorización correcta.** Un índice no se diseña por campo, se diseña
**por consulta del contrato**. El movimiento correcto es inventariar las
consultas que la API hace de verdad —listado con `status`, búsqueda por `q`,
detalle por `_id`, comentarios por `ticketId`— y tener un índice por patrón, no
uno por campo "importante".

Y la contrapartida, que hay que medir y no suponer: **cada índice se paga en cada
escritura.** Antes de dejar cinco índices en una colección que recibe inserts
constantes, mide el coste:

```js
// mismo lote de inserts, con y sin el índice nuevo
var t0 = Date.now();
db.tickets.insertMany(batch);
print(Date.now() - t0);
```

**Prueba de regresión.** Una aserción sobre el plan, que es lo que impide la
reincidencia:

```js
it("el listado principal usa el índice y no examina de más", async function () {
  var stats = (await col.find({ status: "open" }).sort({ createdAt: -1 }).limit(20)
    .explain("executionStats")).executionStats;

  expect(stats.totalDocsExamined).toBeLessThanOrEqual(20);
  expect(JSON.stringify(stats.executionStages)).not.toContain("COLLSCAN");
});
```

**Prevención.** Tres reglas de lectura del plan, que valen para cualquier motor:

- mira **`totalDocsExamined` frente a `nReturned`**, no la etapa;
- una etapa `SORT` en una consulta que ordena por un campo indexado es una
  bandera roja;
- mide siempre con las mismas condiciones de caché, o los números mienten.

**Por qué llegó a producción.** Porque el índice se creó a partir de una
intuición correcta —"esta consulta necesita índice"— sin mirar el plan ni la
consulta real. Y porque `createIndex` **nunca falla por estar mal orientado**:
crea el índice, lo ocupa en disco, lo cobra en cada escritura y no sirve para
nada. El sistema no tiene forma de decirte "este índice no lo usa nadie" salvo que
se lo preguntes (`$indexStats`).

**Si tu causa fue distinta a ésta.** Si tu plan decía `IXSCAN` y aun así iba
lento, mira la razón examinados/devueltos: un IXSCAN que examina 90.000 para
devolver 20 es un COLLSCAN con corbata, y suele ser un regex flotante. Si el
índice era correcto y la pantalla seguía lenta, felicidades: encontraste el
meta-error de la fase — lo lento es el modelo, y eso es el
[incidente 05](#incidente-05--el-tablero-tarda-cuatro-segundos-y-antes-iba-bien).

</details>

---

EOF
grep -c "^## Incidente" cuaderno-incidentes.md; wc -l cuaderno-incidentes.md

# --- 2026-09-10T02:15:32 · Write incidents 8 and 9 of course 02
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 08 — "La migración pasó el conteo y los reportes salen mal"

> **Fase:** 8 · **Categoría:** Modelado · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

### 🎫 El ticket

> "La migración de `soporte_v1` a `soporte_v2` terminó anoche y el reporte dice
> 100.000 de 100.000. Pero hoy el tablero muestra tickets cerrados como si
> estuvieran abiertos, y a varios les cambió el agente asignado. Los totales por
> estado no cuadran con los de la semana pasada."

**Reportado por:** el analista de reportes · **Ambiente:** la base migrada

### 🎯 Qué se te pide

Encontrar qué se rompió, arreglarlo **sin volver a empezar de cero** si es
posible, y —la parte que de verdad importa— escribir el procedimiento de
verificación que tendría que haber existido. Un conteo no es una verificación, y
este incidente es la demostración.

### 🔧 Preparación

Un seed de las dos bases y una migración con el bug puesto:

```bash
node scripts/seed.soporte-v1.js
node scripts/migrate.incidente-08.js     # migra con el mapa de estados corrido
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

No mires el script todavía. Toma cinco documentos del origen y sus equivalentes
en el destino, y ponlos uno al lado del otro campo por campo.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Fíjate en los campos que en el origen eran **códigos numéricos** y en el destino
son texto. ¿La correspondencia es la que debería? Prueba con el documento cuyo
código era el más bajo y con el del más alto.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si los ids del origen empiezan en 1 y tu arreglo de traducción empieza en 0,
¿qué le pasa a cada estado?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Dos, y la segunda solo aparece si miras las referencias:

1. *El mapa de estados corrido una posición.* El script traduce
   `status_id → status` indexando un arreglo desde 0, y los ids del origen
   empiezan en 1. Todos los tickets quedaron con el estado anterior al suyo. Los
   conteos globales **coinciden** porque el corrimiento es uniforme —hay la misma
   cantidad de documentos en cada grupo, solo que con la etiqueta cambiada—, y
   por eso ninguna verificación por cantidad lo detectó.

   ```js
   // origen
   { ticket_id: 1, status_id: 4, assignee_id: 12 }
   // destino
   { legacyId: 1, status: 'open', assignee: 'ana' }     // status_id 4 era 'closed'
   ```

2. *Referencias en `null`.* `tickets` se migró **antes** que `users`, así que el
   script no tenía el mapa `user_id → username` y resolvió a `null` sin quejarse.
   De ahí los agentes que "cambiaron".

**Parche mínimo.** El mapa se corrige y se vuelve a aplicar **solo sobre lo
migrado**, sin repetir la migración entera:

```js
// scripts/fix-08-status.js — idempotente: usa el origen como verdad
db.getSiblingDB("soporte_v1").tickets.find({}, { ticket_id: 1, status_id: 1 })
  .forEach(function (src) {
    db.tickets.updateOne(
      { legacyId: src.ticket_id },
      { $set: { status: STATUS_MAP[src.status_id] } }    // mapa por CLAVE, no por índice
    );
  });
```

Fíjate en el detalle que evita la reincidencia: el mapa deja de ser un arreglo
posicional y pasa a ser un objeto con claves explícitas. Un off-by-one no se
arregla restando uno, se arregla eliminando la aritmética.

**La refactorización correcta.** El script de migración es **código de
producción** y le faltaban tres cosas que no cuestan casi nada:

- **`--dry`**, que imprime qué haría sin hacerlo;
- **idempotencia**, para poder volver a correrlo sobre el resultado anterior sin
  duplicar ni corromper (upsert por una clave estable como `legacyId`);
- **verificación propia**, que es el corazón de este incidente:

```js
// scripts/verify-migration.js
var sample = srcTickets.aggregate([{ $sample: { size: 50 } }]).toArray();
sample.forEach(function (src) {
  var dst = dstTickets.findOne({ legacyId: src.ticket_id });
  assertEqual(STATUS_MAP[src.status_id], dst.status, "status " + src.ticket_id);
  assertEqual(USER_MAP[src.assignee_id] || null, dst.assignee, "assignee " + src.ticket_id);
});
// más los extremos, que son donde viven los off-by-one:
["min status_id", "max status_id", "assignee_id null", "createdAt más antiguo"]
```

Y el orden de ejecución deja de ser implícito: **los referenciados primero**
(`users`), y el script de tickets falla ruidosamente si el mapa está vacío en vez
de resolver a `null`.

**Prueba de regresión.**

```js
it("no quedan tickets con estado fuera del enum", async function () {
  var n = await col.countDocuments({ status: { $nin: ["open","in_progress","resolved","closed"] } });
  expect(n).toBe(0);
});

it("la distribución por estado coincide con el origen", async function () {
  for (var id in STATUS_MAP) {
    expect(await dst.countDocuments({ status: STATUS_MAP[id] }))
      .toBe(await src.countDocuments({ status_id: Number(id) }));
  }
});
```

Ese segundo test es el que habría atrapado el bug: compara **por grupo**, no el
total.

**Prevención.** Una frase en el procedimiento de migración, y que sea condición
para dar por buena cualquiera: **verificar por muestreo campo a campo, incluyendo
los extremos, además de los conteos.** Veinte documentos bien elegidos —el más
viejo, el más nuevo, los que tenían nulos, los que tenían referencias— encuentran
el 90% de los errores de transformación.

**Por qué llegó a producción.** Porque la verificación que existía —conteo origen
contra conteo destino— es la que todo el mundo escribe, y es la que **casi
cualquier bug de transformación respeta**. El número de documentos es la
propiedad más fácil de preservar y la que menos información aporta. Nadie hizo
trampa ni fue descuidado: se verificó lo que se sabía verificar, de noche y con
gente esperando.

**Si tu causa fue distinta a ésta.** Si tu migración se quedó sin memoria, el
hallazgo es otro y también está en la fase: cargar 300.000 documentos en memoria
en vez de usar cursor y lotes. Y si tus números de "antes y después" no
convencían a nadie, revisa las condiciones de medición: una con caché caliente y
otra fría no comparan nada.

</details>

---

## Incidente 09 — "El reporte por estado devuelve una sola línea"

> **Fase:** 9 · **Categoría:** Consultas · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-60 min

### 🎫 El ticket

> "El reporte de tickets por estado dejó de funcionar. No da error, pero en vez
> de la tabla con una fila por estado sale una sola línea con el total de todo.
> Lo heredé de quien se fue, no lo he tocado."

**Reportado por:** el analista de reportes · **Ambiente:** desarrollo

### 🎯 Qué se te pide

Localizar la herida —y hay un detalle en la salida que te la confiesa— y arreglar
el pipeline. Después, la parte transferible: describir el **método** con el que
habrías encontrado esto en la primera etapa, sin leer el pipeline entero. Ese
método vale más que el arreglo, porque el siguiente pipeline roto no se va a
parecer a éste.

### 🔧 Preparación

No hace falta romper nada ni sembrar nada: el pipeline heredado se pega tal cual
en `mongosh`.

```js
db.tickets.aggregate([
  { $group: { _id: "status", total: { $sum: 1 } } }
])
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Mira la salida, no el código. El documento que devuelve tiene un campo que te está
diciendo por qué agrupó así.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

El `_id` de la salida: ¿trae un **valor de tus datos** o el **nombre de un
campo**?

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

En el lenguaje del pipeline, ¿qué diferencia hay entre `"status"` y `"$status"`?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** `_id: "status"` es el **literal** de cuatro letras, no una
referencia al campo. Mongo agrupó por esa constante: un solo grupo, todos los
documentos dentro. Y la salida lo confiesa:

```js
// [ { "_id" : "status", "total" : 100000 } ]
```

Ese `_id` que sale con el nombre del campo en vez de un valor de tus datos es la
**huella dactilar** del bug. Tu ojo de SQL ya lo había traducido: un `GROUP BY`
que colapsa a una fila es un `GROUP BY <constante>`.

No hay error porque no hay nada ilegal: agrupar por un literal es una operación
válida, solo que inútil.

**Parche mínimo** — un carácter:

```js
db.tickets.aggregate([
  { $group: { _id: "$status", total: { $sum: 1 } } }
])
// [ { "_id":"open", "total":41230 }, { "_id":"closed", "total":38110 }, … ]
```

**La refactorización correcta.** El pipeline de un reporte que alguien va a
firmar merece dos cosas más:

```js
db.tickets.aggregate([
  { $match: { createdAt: { $gte: from, $lt: to } } },   // filtra primero: usa índice
  { $group: { _id: "$status", total: { $sum: 1 } } },
  { $sort: { total: -1 } },
  { $project: { _id: 0, status: "$_id", total: 1 } }    // forma estable para el consumidor
])
```

El `$match` al principio no es cosmético: es la diferencia entre usar el índice y
regalarse un COLLSCAN. Y el `$project` final le da al reporte una forma con
nombres propios, en vez de exponer el `_id` técnico del `$group`.

**Prueba de regresión.**

```js
it("agrupa por el valor del estado, no por el literal", async function () {
  var rows = await service.countByStatus();
  expect(rows.length).toBeGreaterThan(1);
  expect(rows.map(function (r) { return r.status; })).toEqual(
    expect.arrayContaining(["open", "closed"])
  );
});
```

Fíjate en la primera aserción: **más de una fila** es exactamente la invariante
que se rompió, y es trivial de escribir.

**Prevención.** El método que se pedía, y que caza esta familia entera: **corre el
pipeline etapa por etapa, mirando dos documentos.**

```js
db.tickets.aggregate([{ $match: { … } }, { $limit: 2 }]).toArray()
// añade una etapa, vuelve a mirar; añade otra, vuelve a mirar
```

La unidad de depuración de un pipeline no es el pipeline: es la etapa. Con este
hábito, el bug de hoy se detecta en la primera, antes de que el `$group` mienta
en silencio.

**Por qué llegó a producción.** Porque el pipeline **funciona**: no lanza, no
avisa, y devuelve un número que además es correcto —el total sí es 100.000—.
Quien lo escribió venía de SQL, donde `GROUP BY status` no necesita ningún
prefijo, y el lenguaje de agregación usa el mismo texto para dos cosas distintas
según lleve `$` o no. La revisión de código tampoco podía verlo: un carácter
ausente en una cadena.

**Si tu causa fue distinta a ésta.** Si tu pipeline perdía campos después del
`$group`, encontraste otra propiedad importante: el `$group` **no propaga** lo que
no declaras. Y si el tuyo reventaba con el error de 100 MB en un `$sort`, no
tenías un bug sino un batch disfrazado de consulta.

</details>

---

EOF
grep -c "^## Incidente" cuaderno-incidentes.md; wc -l cuaderno-incidentes.md

# --- 2026-09-10T02:16:58 · Write costura incidents 10 and 11 of course 02
cd /Users/oskar/Developer/Learning/courses-ia-generated/vue2-legacy-for-backend-devs/02-complement-mongodb-backend
cat >> cuaderno-incidentes.md <<'EOF'
## Incidente 10 — "Apunté el frontend al backend nuevo y no se ve nada"

> **Fase:** 10 · **Categoría:** Contrato · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

> 🧩 **Incidente de costura, autocontenido.** No hace falta haber escrito el
> frontend ni haber hecho el Curso 01: se te entrega ya construido y solo tienes
> que levantarlo.

### 🎫 El ticket

> "Cambiamos la URL del frontend para que apunte al backend nuevo en vez del
> mock y la pantalla de tickets sale vacía. Dice 'No hay tickets'. Pero si hago
> `curl` a la API los tickets están todos ahí. Volvimos al mock y todo bien, así
> que el frontend no está roto."

**Reportado por:** el compañero que hizo el cambio · **Ambiente:** desarrollo

### 🎯 Qué se te pide

Que el frontend funcione contra tu backend **sin tocar una línea del frontend**.
Esa restricción no es un capricho: es la promesa del paquete —*se cambia el
`baseURL` y la aplicación no se entera*— y es también la situación real cuando el
cliente lo mantiene otro equipo.

Entregable: la lista de **todas** las diferencias entre lo que tu API devuelve y
lo que el contrato promete, no solo la primera que encuentres. Suelen ser tres o
cuatro y se arreglan juntas.

### 🔧 Preparación

El frontend se entrega construido, con su `db.json` y su mock por si necesitas
comparar contra el comportamiento original:

```bash
git clone <repo-del-frontend> mini-jira-front && cd mini-jira-front
npm ci
npm run mock            # el mock original, en :3000 — tu referencia
npm run serve           # el frontend, en :8080
```

Y para el incidente, apúntalo a tu backend cambiando **solo** el `baseURL`:

```js
// src/services/apiClient.js — la única línea que se toca en todo el frontend
baseURL: "http://localhost:4000"
```

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Tienes la mejor herramienta de diagnóstico posible y casi nadie la usa: **el
sistema que sí funcionaba**. Pide lo mismo a los dos servidores y compara las
dos respuestas carácter por carácter.

```bash
curl -s http://localhost:3000/tickets | head -c 300   # el mock
curl -s http://localhost:4000/tickets | head -c 300   # el tuyo
```

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Compara tres cosas en ese orden: la **forma de la respuesta** (¿es un arreglo, o
un objeto que envuelve al arreglo?), los **nombres de los campos**, y los
**tipos** de cada valor.

Y después mira el frontend —solo mirar— para ver qué hace con lo que recibe:
`res.data` de axios, y `ticket.id` en la clave de la lista y en las rutas.

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Con qué campo construye el frontend el enlace al detalle? ¿Existe ese campo en
lo que tú devuelves?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Tres incumplimientos del contrato, en una sola respuesta, y
ninguno produce un error:

```json
// lo que devuelve tu backend
{"data":[{"_id":"5f8a1c2e4b3d2f0012a4e991","title":"La impresora no imprime",
"createdAt":{"$date":"2020-03-10T10:00:00Z"},"history":[…],"schemaVersion":2}]}

// lo que promete 00-audit-contrato.md
[{"id":"5f8a1c2e4b3d2f0012a4e991","title":"La impresora no imprime",
"createdAt":"2020-03-10T10:00:00.000Z","status":"open","priority":"high"}]
```

1. **El envelope reflejo.** Devuelves `{ data: [...] }` y el contrato dice
   arreglo plano. El frontend hace `res.data` de axios —que ya es el cuerpo— y
   se encuentra un objeto donde esperaba una lista: `tickets` queda con algo que
   no tiene `length`, y la vista muestra su estado vacío. **Silencioso.**
2. **`_id` en vez de `id`.** Aunque el envelope se arregle, cada fila necesita
   `ticket.id` para su `:key` y para construir `/tickets/:id`. Con `_id`, las
   claves son `undefined` y los enlaces no llevan a ninguna parte.
3. **Fechas y campos internos.** `createdAt` viaja como objeto de fecha en vez de
   string ISO, y encima van `history` y `schemaVersion`, que el contrato no
   menciona y el frontend no pidió.

**Parche mínimo** — la frontera, que ya existía a medias:

```js
// src/api/serializers.js
function serializeTicket(doc) {
  return {
    id: doc._id.toString(),                    // la base habla Mongo…
    title: doc.title,
    description: doc.description,
    status: doc.status,
    priority: doc.priority,
    assignee: doc.assignee,
    reporter: doc.reporter,
    createdAt: doc.createdAt.toISOString()     // …la API habla el contrato
  };
}
```

```js
// el controller devuelve el recurso, sin envolver
res.json(docs.map(serializeTicket));
```

**La refactorización correcta.** El parche arregla el listado; el contrato tiene
más superficie —detalle, comentarios, POST, PATCH, DELETE— y cada endpoint puede
incumplirlo por su cuenta. Dos movimientos:

1. **Un solo serializer por recurso**, usado por todos los controllers, y la
   regla de que **ningún handler devuelve un documento crudo**. Es fácil de
   auditar: `grep -rn "res.json(doc" src/`.
2. **Una suite de contrato** que compare tu API contra el contrato escrito, no
   contra tus expectativas:

   ```js
   it("GET /tickets devuelve un arreglo plano con id string", async function () {
     var res = await request(app).get("/tickets").expect(200);
     expect(Array.isArray(res.body)).toBe(true);
     expect(typeof res.body[0].id).toBe("string");
     expect(res.body[0]._id).toBeUndefined();
     expect(res.body[0].history).toBeUndefined();
     expect(res.body[0].createdAt).toMatch(/^\d{4}-\d{2}-\d{2}T/);
   });
   ```

**Prueba de regresión.** La de arriba, más la verificación de extremo a extremo
que cierra la promesa del paquete: apagar el mock, apuntar el frontend al backend
y comprobar que ninguna vista se entera.

**Prevención.** El contrato deja de ser un documento y pasa a ser **tests**. Un
`.md` que describe una API es una intención; una suite que la comprueba es una
garantía. Y una regla para los cambios futuros: si de verdad hace falta cambiar
la forma de una respuesta, **se cambia el contrato primero** y se avisa a quien
lo consume. Un envelope añadido en silencio rompe pantallas que no sabías que
existían.

**Por qué llegó a producción.** Porque las tres diferencias son **mejoras** desde
la perspectiva de quien escribe el backend. El envelope `{ data: … }` es una
convención muy razonable —deja sitio para metadatos de paginación—, devolver
`_id` es lo natural en Mongo, y mandar el documento entero parece generoso.
Ninguna produce un error y todas rompen al consumidor. El sistema no tenía cómo
avisar porque **nadie estaba comprobando el contrato**: existía escrito y no
ejecutable.

**Si tu causa fue distinta a ésta.** Si tu pantalla salía vacía por CORS, es un
diagnóstico legítimo y la evidencia está en la consola del navegador, no en el
`catch` — con `curl` funcionando y el navegador no, la respuesta es siempre ésa.
Si el listado funcionaba y el detalle daba 500 con ciertos ids, encontraste otro
punto de la frontera: un id malformado tiene que ser 404, no una excepción al
construir el `ObjectId`.

</details>

---

## Incidente 11 — "En vivo llega mal y al recargar se ve bien"

> **Fase:** 12 · **Categoría:** Contrato · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 1,5-2 h

> 🧩 **Incidente de costura, autocontenido.** El frontend se entrega construido;
> no hace falta haber hecho el Curso 01 ni haberlo escrito.

### 🎫 El ticket

> "Los tickets que aparecen solos en la pantalla, sin recargar, salen mal: el
> enlace no lleva a ninguna parte y la fecha se ve rarísima. Si recargo, ese
> mismo ticket se ve perfecto. Y desde ayer, además, cada ticket nuevo me sale
> dos veces."

**Reportado por:** agente de soporte · **Ambiente:** UAT

### 🎯 Qué se te pide

Son **dos** problemas y hay que separarlos: la forma de lo que llega en vivo, y
la cantidad de veces que llega. Para el primero, causa raíz y fix. Para el
segundo, identificar cuántos emisores hay en el sistema y por qué existe el
sobrante.

Y una comprobación de diseño que este curso pide siempre: verificar **en qué
orden** ocurren la escritura y el anuncio.

### 🔧 Preparación

El mismo frontend construido del incidente anterior, apuntado a tu backend, y tu
servidor con sockets levantado:

```bash
cd mini-jira-front && npm ci && npm run serve      # frontend en :8080
npm run dev                                        # tu backend, con sockets
```

Dos navegadores con sesión abierta; el ticket se crea en uno y se observa en el
otro.

---

<details><summary>💡 <b>Pista 1</b> — dónde mirar</summary>

Pon los dos canales lado a lado. Pide el mismo ticket por HTTP y mira el payload
que llega por el socket:

```js
socket.on("ticket:created", function (t) { console.log(t); });
```

Si las dos formas no coinciden, ya sabes qué mitad del ticket estás resolviendo.

</details>

<details><summary>💡 <b>Pista 2</b> — qué mirar</summary>

Para el duplicado: cuenta **frames**, no filas. Si por el socket llega un solo
frame y la fila aparece dos veces, el problema está en el cliente; si llegan dos
frames, hay dos emisores.

```bash
grep -rn "emit(" src/ | grep -v node_modules
lsof -i :4000
```

</details>

<details><summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Lo que sale por el socket, ¿pasó por el mismo sitio por el que pasa lo que sale
por HTTP?

</details>

---

### 📝 Tu investigación

**Reproducción**

**Evidencia observable**

**Hipótesis (❌ descartada / ✅ confirmada)**

**Tu causa raíz**

**Tu fix**

---

<details><summary>✅ <b>Solución de referencia</b></summary>

**Causa raíz.** Dos, independientes:

1. *La forma.* El emit manda el **documento crudo** de Mongo: `_id` en vez de
   `id`, la fecha como `Date` en vez de ISO, y campos internos de propina. El
   serializer que la Fase 10 aplica religiosamente en cada respuesta HTTP no se
   aplicó al segundo canal. Por eso al recargar se ve bien: esa vez el dato entró
   por HTTP, que sí tiene guardián.

   ```js
   realtime.emit("ticket:created", doc);            // ⚠️ crudo
   realtime.emit("ticket:created", serializeTicket(doc));   // ✅
   ```

2. *El duplicado.* Hay **dos emisores**: tu backend nuevo emite tras persistir, y
   el relé de sockets que el frontend traía —un servidor de veinte líneas que
   rebota lo que le llega— sigue encendido en el mismo puerto. Cada creación
   produce dos anuncios del mismo hecho.

Y mientras investigas, comprueba el **orden**: si el `emit` está antes del
`insertOne`, estás anunciando algo que todavía puede fallar. Eso reconstruye,
con más pasos, el problema que el frontend tenía cuando el que anunciaba era el
cliente.

**Parche mínimo:**

```js
// services/tickets.service.js
var result = await tickets.insertOne(doc);          // primero se persiste…
realtime.emit("ticket:created", serializeTicket(doc));   // …después se anuncia
```

Y apagar el relé heredado, que es una línea en el `package.json` del frontend y
un proceso menos corriendo.

**La refactorización correcta.** El problema de fondo es que **el sistema tiene
dos fronteras y solo una tiene guardián**. La solución estructural es que el
único camino de salida de un recurso sea el serializer, venga por donde venga:

```js
// realtime/index.js — el módulo de tiempo real no acepta documentos crudos
function emitTicket(event, doc) {
  io.emit(event, serializeTicket(doc));
}
```

Con esa firma, emitir el documento crudo deja de ser posible por accidente. Y una
regla que hay que dejar escrita: **el payload de un evento es una respuesta de
API**, con el mismo contrato y las mismas garantías.

**Prueba de regresión.**

```js
it("el evento de socket lleva la misma forma que la respuesta HTTP", async function () {
  var received = await captureNextEvent("ticket:created", function () {
    return request(app).post("/tickets").send(validPayload).expect(201);
  });

  expect(received.id).toEqual(expect.any(String));
  expect(received._id).toBeUndefined();
  expect(received.createdAt).toMatch(/^\d{4}-\d{2}-\d{2}T/);
  expect(received.history).toBeUndefined();
});

it("emite después de escribir, no antes", async function () {
  tickets.insertOne = jest.fn().mockRejectedValue(new Error("boom"));
  await expect(service.create(validPayload)).rejects.toThrow();
  expect(realtime.emit).not.toHaveBeenCalled();
});
```

Ese segundo test es corto y vale por toda la discusión de diseño: si la escritura
falla, nadie se enteró de nada.

**Prevención.** Un inventario de canales de salida en el README del backend
—HTTP, sockets, y lo que venga después: colas, webhooks, exportaciones— con una
columna que diga quién aplica el serializer en cada uno. Es la lista que evita
que el tercer canal repita esta historia.

**Por qué llegó a producción.** Porque el segundo canal se añadió meses después
del primero, en otra fase y con otra cabeza. El serializer estaba en los
controllers, que es donde se escribió cuando solo había HTTP, y al añadir sockets
nadie pensó en él: el módulo de tiempo real recibía documentos y los mandaba, que
es lo que parece que tiene que hacer. Y el relé viejo siguió encendido porque
apagarlo era responsabilidad de nadie en concreto — estaba en el otro repo.

**Si tu causa fue distinta a ésta.** Si tu socket no conectaba en absoluto, mira
las versiones: un servidor socket.io 3.x/4.x contra el cliente 2.4 del frontend
heredado produce **silencio**, no un error. Y si el duplicado venía de un solo
emisor, el sobrante está en el cliente: handlers suscritos sin dar de baja al
navegar.

</details>

---

EOF
grep -c "^## Incidente" cuaderno-incidentes.md; wc -l cuaderno-incidentes.md

