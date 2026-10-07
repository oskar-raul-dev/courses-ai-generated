# Comandos Bash de la sesión 5d4ed58d-ca5c-4efb-aaa8-eb9512597a47, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-10T01:19:50 · Read course README and list prompts directory
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && cat README.md && echo "=== PROMPTS ===" && ls -la prompts/

# --- 2026-09-10T01:19:55 · Count lines per file and show base incident notebook headings
wc -l *.md | sort -n | tail -60 && echo "=== INDICE CUADERNO BASE ===" && grep -n "^#\{1,3\} " cuaderno-incidentes.md | head -50

# --- 2026-09-10T01:25:56 · List courses and search for forensic/incident files across repo
cd /Users/oskar/Developer/Learning/courses-ia-generated && ls -d */ && echo "=== forense en react16 fases ===" && grep -c "forense" react-16-legacy-for-backend-devs/*.md | grep -v ":0" && echo "=== cuadernos en el repo ===" && find . -iname "*incidente*" -not -path "./.git/*"

# --- 2026-09-10T01:26:04 · Compare incident notebooks across courses
wc -l angular-16-legacy-for-backend-devs/cuaderno-incidentes.md angular-8-legacy-for-backend-devs/cuaderno-incidentes.md vue2-legacy-for-backend-devs/prompts/formato-cuaderno-incidentes.md angular-16-legacy-for-backend-devs/prompts/formato-cuaderno-incidentes.md react-16-legacy-for-backend-devs/cuaderno-incidentes*.md && echo "=== vue2 files ===" && ls vue2-legacy-for-backend-devs/ && echo "=== forense en vue2/ang8/ang16 (conteo de archivos con 'pieza forense') ===" && grep -rl "pieza forense" --include="*.md" vue2-legacy-for-backend-devs angular-8-legacy-for-backend-devs angular-16-legacy-for-backend-devs | wc -l

# --- 2026-09-10T01:26:09 · Read vue2 forensic content plan file
wc -l vue2-legacy-for-backend-devs/contenido_forense.md && sed -n '1,120p' vue2-legacy-for-backend-devs/contenido_forense.md

# --- 2026-09-10T01:26:25 · List level-2 headings of base phases
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && echo "=== Encabezados nivel 2 de cada fase base ===" && for f in 0*.md 1*.md; do echo "--- $f"; grep -n "^## " "$f"; done

# --- 2026-09-10T01:26:32 · Inspect forensic subsections and incident reservations
echo "=== subsecciones h3 dentro de sección 6 (base) ===" && for f in 00-setup*.md 01-*.md 02-*.md 03-*.md 04-*.md 05-*.md 06-*.md 07-*.md 08-*.md 09-*.md 10-*.md 11-*.md; do echo "--- $f"; awk '/^## ⚠️ 6\./{f=1} /^## 🧪 7\./{f=0} f&&/^### /' "$f"; done; echo; echo "=== reservas de incidentes ==="; grep -rn "Reservas\|INC-\|inc/" --include="*.md" . | grep -v cuaderno-incidentes | head -40

# --- 2026-09-10T01:26:39 · Check which phases carry reservation blocks and inspect phase 03 ending
grep -n "Reservas para el cuaderno" *.md; echo "=== 03 cierre ==="; sed -n '851,917p' 03-mock-api-express-caos.md

# --- 2026-09-10T01:26:42 · Read base incident notebook in full
cat -n cuaderno-incidentes.md

# --- 2026-09-10T01:26:50 · Compare with angular-16 layout and search react style guide
cd /Users/oskar/Developer/Learning/courses-ia-generated && echo "=== ang16 files ===" && ls angular-16-legacy-for-backend-devs/ | head -60 && echo "=== react guia: forense/cuaderno ===" && grep -n "forense\|cuaderno\|incidente" react-16-legacy-for-backend-devs/prompts/guia-de-estilo-y-convenciones.md | head -60

# --- 2026-09-10T01:26:54 · Read key style guide sections
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && sed -n '480,530p;725,800p;805,845p;910,930p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-10T01:27:06 · Measure inline forensic sections and inspect angular forensic files
echo "=== tamaño de la sección 6 por fase base (líneas) ===" && for f in 00-setup*.md 01-*.md 02-*.md 03-*.md 04-*.md 05-*.md 06-*.md 07-*.md 08-*.md 09-*.md 10-*.md 11-*.md; do n=$(awk '/^## ⚠️ 6\./{f=1} /^## 🧪 7\./{f=0} f' "$f" | wc -l); p=$(awk '/[Pp]ieza forense/{f=1} /^## 🧪 7\./{f=0} f' "$f" | wc -l); echo "$f  sec6=$n  desde-pieza=$p"; done; echo "=== ang16 forense-master h2 ==="; head -40 ../angular-16-legacy-for-backend-devs/forense-master.md; echo "=== ang16 forense-fase-06 h2 ==="; grep -n "^#\{1,3\} " ../angular-16-legacy-for-backend-devs/forense-fase-06.md; wc -l ../angular-16-legacy-for-backend-devs/forense-fase-*.md | tail -3

# --- 2026-09-10T01:27:24 · Extract all incident reservation blocks
for f in 00-setup*.md 01-*.md 02-*.md 03-*.md 04-*.md 05-*.md 06-*.md 07-*.md 08-*.md 09-*.md 10-*.md 11-*.md; do echo "=============== $f"; awk '/^### Reservas para el cuaderno/{f=1} f' "$f"; done

# --- 2026-09-10T01:27:30 · Inspect BE notebook structure and per-incident size
grep -n "^## Incidente\|^### 🩺\|síntoma\|^# " cuaderno-incidentes-be.md | head -40; echo "=== líneas por incidente BE ==="; awk '/^## Incidente/{if(t)print t" -> "n; t=$0; n=0} {n++} END{print t" -> "n}' cuaderno-incidentes-be.md

# --- 2026-09-10T01:27:39 · Inspect BE incident template headings
grep -n "^#\{1,4\} \|^> " prompts/plantilla-de-incidente-be.md | head -40; echo "=== BE cuaderno cabecera 1-130 (solo h2/h3) ==="; grep -n "^#\{1,3\} " cuaderno-incidentes-be.md | sed -n '1,20p'

# --- 2026-09-10T01:28:18 · Check git convention incident section and branch naming usage
sed -n '218,262p' 00-convencion-de-git-y-tags.md; echo "=== 'incidente/' en el curso ==="; grep -rn "incidente/" --include="*.md" . | head

# --- 2026-09-10T01:32:18 · Write the disposable execution plan file
cat > /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs/completado_cuaderno_incidentes.md <<'PLANEOF'
# 📓 Completado del cuaderno de incidentes — React 16 · plan de ejecución

> ⚠️ **Documento desechable.** Material de trabajo. **No se commitea, no se enlaza desde
> ninguna documentación, no se cita desde ninguna fase.** Cuando P0…P4 estén cerrados,
> **este archivo se borra**: lo de §5.1 tiene que haber migrado a
> `prompts/plantilla-de-incidente.md`, lo de §5.2 al propio `cuaderno-incidentes.md`,
> y las decisiones D1–D6 a `prompts/guia-de-estilo-y-convenciones.md` §15.
>
> Fecha: 2026-09-09 · Alcance: `react-16-legacy-for-backend-devs/` (track base)
> Referencia comparativa: `cuaderno-incidentes-be.md` (mismo curso, terminado) y
> `angular-16-legacy-for-backend-devs/` (aparato forense completo).
>
> **Estado: veredicto cerrado (§1–§3), decisiones D1–D6 propuestas y pendientes de
> confirmación (§4).** Confirmadas esas seis, §6 se ejecuta sin más consultas.

---

## 1. 🔍 Veredicto en dos frases

**El cuaderno va, y no es una decisión de diseño: es una deuda que seis documentos ya
facturaron.** El aparato forense **no** necesita archivos aparte al estilo Angular —las
12 fases cumplen su sección 6 sin excepción—, pero sí le faltan dos piezas baratas: un
**índice 🩺 de síntomas** que sirva de puerta de entrada, y la **plantilla base extraída**
a su propio archivo antes de que el Incidente 01 la pise.

---

## 2. 🧨 Por qué el cuaderno va: seis bucles abiertos

No estamos importando una idea de Angular. Estamos entregando lo que este curso ya vendió.

**Bucle 1 — el README.** Anuncia *"veinte tickets vagos —como llegan en la vida real— con
pistas escalonadas y solución de referencia colapsada"* y a renglón seguido tiene que
poner un ⚠️ admitiendo que no están redactados. Un README que desmiente su propia tabla.

**Bucle 2 — la guía de estilo §13.** Define la estructura de post-mortem de ocho puntos y
dice *"Cada incidente sigue esta estructura"*. No hay ni un incidente base que la siga.

**Bucle 3 — la guía de estilo §15.** Ya se auto-diagnosticó: *"El cuaderno de incidentes
está vacío… Es el hueco de autocontención más grande del curso… Prioridad alta."* El plan
existe; falta ejecutarlo.

**Bucle 4 — la convención de git.** `00-convencion-de-git-y-tags.md:218-262` dedica una
sección entera (`## 🚑 Incidentes: acá el tag sí es contenido`) al par
`inc/<ID>/<slug>-roto` / `-fix`, **con el incidente 14 redactado como ejemplo**, y remata:
*"`git tag -n99 -l 'inc/*'` te devuelve el cuaderno de incidentes entero"*. Hoy devuelve
vacío. Y su §📝 final define las ramas `incidente/NN` "que el cuaderno usa en la sección
🔧 Preparación de cada incidente" — una sección que no existe en ningún incidente base.

**Bucle 5 — las doce fases.** Las 12 cierran con `### Reservas para el cuaderno de
incidentes`, con ID, título en palabras del usuario, categoría, dificultad **y la semilla
técnica** (de qué error común o de qué pieza forense sale). Es el trabajo caro ya hecho:
lo que falta es redactar, no diseñar.

**Bucle 6 — el que más duele.** `cuaderno-incidentes-be.md` está **terminado** (3.822
líneas, 16 incidentes) y su índice incluye una tabla de "hermanos" que remite a los
incidentes **08, 11, 16, 18, 19 y 20** del track base. Un documento cerrado apuntando a
seis filas ⬜. Y el cuaderno base le devuelve el gesto en su §🔥 con la misma tabla.

---

## 3. 🕵️ Por qué el forense NO va como archivos aparte (y qué sí falta)

### 3.1 Aquí no hay incumplimiento

La comparación natural sería `vue2-legacy-for-backend-devs/contenido_forense.md`, pero
ese caso era distinto: allí **29 de 33 fases incumplían** la plantilla obligatoria. Aquí:

| | Track base | Track BE |
|---|---|---|
| Fases con `## ⚠️ 6. Errores comunes y pieza forense` | **12 / 12** | **10 / 10** |
| Con subsección `Pieza forense` real dentro | **12 / 12** | **10 / 10** |
| Con bloque `### Reservas para el cuaderno` | **12 / 12** | vía bloque 🏷️ |

Y la guía de estilo §9 define la pieza forense **inline, dentro de la sección 6**. Nunca
prometió `forense-master.md` ni `forense-fase-NN.md`. No hay bucle abierto que cerrar.

### 3.2 Por qué no replicar el aparato de Angular

Angular-16 tiene `forense-master.md` (112 líneas) + 15 × `forense-fase-NN.md` (~200 c/u,
3.126 líneas). Cuatro razones para **no** traerlo a React 16:

1. **Es alcance nuevo, no deuda.** Nada lo prometió; agregarlo es ampliar el curso.
2. **Duplica.** El terreno que cubriría un `forense-fase-06.md` ya lo cubren la sección 6
   de la Fase 6, el apéndice `A7-redux-observable-epica-por-epica.md`, `A11-marble-testing.md`
   y los incidentes 13, 14 y 15. Tres documentos diciendo lo mismo envejecen desincronizados.
3. **Las horas.** `cuaderno-incidentes.md:5-6` declara que *"el tiempo de los incidentes ya
   está contado dentro de las 96 h"*. 3.000 líneas más reabren un presupuesto que la guía
   §15 ya marca como no resuelto ("Presupuesto horario… Sigue abierto").
4. **Content lock.** `CLAUDE.md` pide que los cambios estructurales sean raros en un curso
   ya distribuido. Doce archivos nuevos con numeración propia no son un cambio raro.

### 3.3 Lo que sí falta, y es barato

**(a) La puerta de entrada por síntoma.** Las piezas inline miden 20–81 líneas (mediana
~31) y cada una vive anclada a su fase. No existe ningún índice que vaya de *síntoma →
capa → herramienta*. El curso promete entrenar "recibir un ticket vago y encontrar la capa
culpable", y hoy el único índice es por ID y fase — que solo ayuda a quien **ya sabe** de
qué fase es su problema. Angular-16 resuelve esto en `forense-master.md` §1 (el método de
cuatro preguntas) y §3 (el índice de síntomas transversal).
→ **Se replica el contenido, no el archivo**: va dentro de `cuaderno-incidentes.md`, antes
del índice por ID. Ver D1.

**(b) La plantilla base no tiene archivo.** `prompts/plantilla-de-incidente-be.md` existe;
su hermano base no. La plantilla del track base vive **dentro** del cuaderno, como
"Incidente 01" con placeholders `{{…}}` (líneas 191-332). Ese slot tiene que llenarse con
el incidente real de la Fase 0, así que la plantilla se destruye al escribir el primero.
→ **Se extrae antes de tocar nada.** Ver D2. Y por la convención de `CLAUDE.md`, el sufijo
`-be` del archivo existente ya implicaba este hermano.

**(c) Las piezas inline son delgadas — y no se tocan.** 31 líneas de mediana contra ~200
de Angular. La compensación de diseño era el cuaderno; con el cuaderno vacío, hoy el
músculo central del curso no lo entrena nadie. **Al llenar el cuaderno, la compensación
opera y las piezas quedan bien dimensionadas.** No se engordan: se enlazan (P4).

---

## 4. ⚖️ Decisiones a cerrar antes de ejecutar

> Marca cada una ✅ / ✏️ (modificada) / ❌ antes de lanzar P1.

**D1 — El índice de síntomas: ¿archivo propio o dentro del cuaderno?**
→ **Recomendado: dentro de `cuaderno-incidentes.md`**, como sección nueva `## 🩺 Entrar
por el síntoma` entre "Estados" y "📋 Índice". Motivo: el cuaderno declara ser *"el único
archivo de incidentes del curso"* y un `forense-master.md` lo desmentiría en la primera
línea. Tamaño objetivo: 45-70 líneas (el método de cuatro preguntas, adaptado a las capas
de React —componente / store / epic / interceptor / mock / build—, más una tabla
síntoma → primera herramienta → incidentes candidatos).
Se replica después en `cuaderno-incidentes-be.md` con las capas del backend (P4). ⬜

**D2 — Extracción de la plantilla base.**
→ **Recomendado: sí, a `prompts/plantilla-de-incidente.md`**, copiando la estructura del
Incidente 01 actual tal cual (encabezado con metadatos, 🎫 El ticket, 🎯 Qué se te pide,
🔧 Preparación, tres pistas plegadas, 📝 Tu investigación, ✅ Solución de referencia con
sus siete bloques) y añadiendo una sección "Recordatorios al rellenar" como la del
hermano BE. **Es bloqueante: va antes de P1.** ⬜

**D3 — Longitud por incidente.** Los BE promedian 225 líneas (188–299). El track base
tiene 4 incidentes 🟢/fáciles que no justifican ese tamaño. → **Escala recomendada:**
🟢 110-140 · 🟡 150-190 · 🟠 190-230 · 🔴 y ⭐ 250-300.
Total proyectado: **≈ 3.900 líneas** (cuaderno final ~4.300, comparable al BE y al de
Angular-16, que tiene 3.916 con 20 incidentes). ⬜

**D4 — ¿Cuántos incidentes no terminan en fix?** El track BE tiene 6 de 16 que no cierran
en un commit, y el README lo vende como diferencial. La plantilla base ya lo admite ("No
todos los incidentes terminan en fix"), pero ninguna reserva lo declara.
→ **Recomendado: 3 de 20**, elegidos porque sus propias semillas ya lo piden:
- **02** (*en la máquina de al lado compila y en la mía no*) → cierra en **documentación**:
  la causa es la arquitectura de la máquina, el desenlace es una nota en `A3-node-y-npm.md`
  y un `.nvmrc`, no un fix de código.
- **10** (*la lista se queda cargando para siempre*) → cierra en **⚪ no se reproduce**: su
  reserva ya dice *"con `CHAOS_LEVEL=off` no se reproduce nunca, y esa es la mitad de la
  lección"*. Enseña a responder "no reproduce" con evidencia en vez de con encogimiento.
- **20** (*el test pasa en mi máquina y falla en la de al lado*) → cierra en **decisión**:
  se abre en Fase 10 y su reserva dice explícitamente que se cierra en Fase 11, con el
  criterio hotfix-vs-refactor. El entregable es la decisión, no el parche.
⬜

**D5 — Mecanismo de preparación.** El cuaderno BE usa `git checkout incidente/be-NN`. El
base tiene tres palancas y conviene que se usen las tres, no una sola: la rama
`incidente/NN` (código roto), el `CHAOS_LEVEL` del mock de Fase 3 (`off`/`low`/`high`) y
el estado de `db.json` (qué rifa, qué números, a qué hora).
→ **Recomendado:** todo incidente declara las tres en 🔧 Preparación, aunque alguna diga
"no aplica"; los que dependen de latencia (07, 15, 17) **exigen** `CHAOS_LEVEL=high`, y
los de tiempo (16, 20) **exigen** decir la zona horaria del navegador. ⬜

**D6 — Consistencia de los seis hermanos.** Los incidentes 08, 11, 16, 18, 19 y 20 tienen
un hermano BE ya redactado que describe qué cambia. Al redactarlos hay que **leer primero
el hermano** y respetar su descripción del contraste, o el cuaderno BE queda mintiendo.
→ **Recomendado: sí, y además cada uno de los seis lleva en su encabezado la línea
`· Hermano del incidente be-NN`**, simétrica a la que ya llevan allá. ⬜

---

## 5. 📦 Paquetes de trabajo, en orden

### P0 — Cerrar D1–D6 (humano, 15 min)
Sin esto no se lanza nada: D2 y D3 cambian la forma de los veinte enunciados.

### P1 — `prompts/plantilla-de-incidente.md` (1 archivo nuevo, ~180 líneas)
Extraer la plantilla del Incidente 01 antes de que se pise. Commit propio, un solo archivo.

### P2 — Los veinte enunciados (≈ 3.900 líneas en `cuaderno-incidentes.md`)
En **cinco lotes por afinidad de capa**, no de a uno: los incidentes de la misma capa
comparten herramienta forense y se contradicen si se escriben sueltos.

| Lote | IDs | Capa / eje | Líneas est. | Prompt |
|---|---|---|---|---|
| L1 | 01, 02, 03, 04 | Entorno y routing (los 🟢, arranque suave) | ~550 | §6.2 |
| L2 | 05, 06, 07, 08 | Auth e integración (interceptor + caos) | ~700 | §6.3 |
| L3 | 09, 10, 11, 12 | Store y concurrencia (incluye ⭐ 11) | ~800 | §6.4 |
| L4 | 13, 14, 15, 17 | RxJS / epics (los cuatro caros, incluye ⭐ 14) | ~900 | §6.5 |
| L5 | 16, 18, 19, 20 | Tiempo, dinero, performance y testing | ~850 | §6.6 |

Un commit por lote: `incidentes: redacta L3 (09-12) — store y concurrencia`.

### P3 — El índice 🩺 de síntomas (≈ 60 líneas dentro del cuaderno)
**Va después de P2, no antes**: el índice de síntomas se escribe leyendo los veinte
enunciados terminados, o inventa síntomas que no coinciden con los tickets.

### P4 — Costura y cierre (≈ 15 ediciones pequeñas)
- Las 20 filas del índice pasan de ⬜ a listar el enunciado redactado.
- Las 12 fases: la sección 6 enlaza sus incidentes **por ID con ancla real**, y los
  bloques `### Reservas` pasan de "aunque el enunciado todavía no esté redactado" a
  "redactado en `cuaderno-incidentes.md`".
- `README.md`: se borra el callout ⚠️ "Estado del cuaderno" y se ajusta la frase del
  track BE que hoy dice "el cuaderno del track BE **sí** está completo".
- `prompts/guia-de-estilo-y-convenciones.md` §15: la viñeta "El cuaderno de incidentes
  está vacío" se tacha con `~~ ~~` y pasa a la lista de resueltos, como se hizo con las
  tablas anchas.
- `cuaderno-incidentes-be.md`: réplica del índice 🩺 con las capas del backend (D1).
- Verificación: `grep -c "^## Incidente" cuaderno-incidentes.md` → 20.

---

## 6. 🤖 Prompts listos para ejecutar

> Todos comparten el mismo **preámbulo**. Pégalo al inicio de cada uno.

### 6.0 Preámbulo común

```
Trabajas en react-16-legacy-for-backend-devs/. Antes de escribir una línea, lee:

1. prompts/guia-de-estilo-y-convenciones.md — manda sobre CLAUDE.md. En especial
   §2 (tuteo latinoamericano, cero voseo), §3 (prosa antes que listas; tablas de
   hasta 4 columnas), §4 (identificadores en inglés, comentarios y UI en español),
   §13 (la estructura de post-mortem de ocho puntos) y §14 (checklist de cierre).
2. cuaderno-incidentes.md — sus §"Cómo se trabaja un incidente", "Convención de
   commits", "Estados" e "Índice". El índice es contrato: título, categoría y
   dificultad de cada ID ya están fijados y NO se cambian.
3. cuaderno-incidentes-be.md — es el modelo de calidad y de tono. Está terminado.
   Lee dos incidentes completos antes de escribir (be-09 y be-05).
4. prompts/plantilla-de-incidente.md — la estructura exacta a rellenar.
5. prompts/decisiones-y-versiones.md — fuente de verdad de versiones. Si un número
   aparece en dos sitios y no coinciden, gana ese archivo.
6. prompts/diccionario-codigo-ingles.md — nombres del dominio en inglés.

Reglas que no se negocian:
- El ID nunca se reasigna y el título del índice se respeta palabra por palabra.
- Cada incidente se lee solo: nada de "ver incidente 01". Se repite estructura.
- El ticket va en lenguaje de negocio, escrito por alguien que no sabe qué es un
  epic, con su vaguedad incluida. "A veces no carga" es un dato, no un defecto.
- Las tres pistas son escalonadas: dónde mirar / qué mirar / la pregunta cuya
  respuesta es la causa. La 1 no nombra el archivo; la 3 no da el fix.
- El bloque "📝 Tu investigación" queda VACÍO, con sus placeholders {{...}}: lo
  llena el estudiante. Lo que redactas es el enunciado y la solución colapsada.
- La solución de referencia lleva sus siete bloques completos: causa raíz hasta el
  archivo y la línea, parche mínimo (código), la refactorización correcta, prueba
  de regresión (código, no descripción), prevención, "por qué llegó a producción"
  (post-mortem sereno, sin culpabilización, el humor baja un punto) y "si tu causa
  fue distinta a esta".
- Todo el código corre con el stack fijado: React 16.14, react-scripts 4.0.3,
  Redux Toolkit 1.8.6, redux-observable 1.2.0, RxJS 6.6.7, Router 5.3.4, axios
  0.21.4, Jest 26, RTL 11, Node 14.21.3. Nada de React 18 ni RxJS 7 salvo como
  comparación marcada 🔥.
- 🔧 Preparación declara SIEMPRE las tres palancas: rama incidente/NN, valor de
  CHAOS_LEVEL y el estado de db.json (qué rifa, qué números, a qué hora, en qué
  zona horaria). Si alguna no aplica, se dice.
- Longitud por dificultad: 🟢 110-140 líneas · 🟡 150-190 · 🟠 190-230 · 🔴/⭐ 250-300.
- Escribes en cuaderno-incidentes.md, insertando entre "# 🧪 Incidentes" y
  "# 🪞 Retrospectiva del mes", en orden de ID. No toques el índice todavía.
```

### 6.1 P1 — Extraer la plantilla base

```
[preámbulo]

Crea prompts/plantilla-de-incidente.md a partir del bloque "Incidente 01" que hoy
vive en cuaderno-incidentes.md (líneas ~191-332), que es una plantilla con
placeholders, no un incidente real.

- Copia la estructura tal cual: encabezado de metadatos (Fase, Categoría,
  Dificultad, Estado, Abierto, Cerrado, Tiempo sugerido), 🎫 El ticket, 🎯 Qué se
  te pide, 🔧 Preparación, las tres pistas en <details>, 📝 Tu investigación y la
  ✅ Solución de referencia con sus siete bloques.
- Añade al encabezado la línea opcional "· Hermano del incidente be-NN, con otra
  causa raíz", simétrica a la del track BE.
- Añade en 🔧 Preparación las tres palancas obligatorias (rama, CHAOS_LEVEL, db.json).
- Cierra con una sección "Recordatorios al rellenar", tomando como modelo la de
  prompts/plantilla-de-incidente-be.md pero con las herramientas del navegador:
  consola, Network, React DevTools, Redux DevTools, logs del mock.
- Este archivo es la plantilla del TRACK BASE; el -be es su hermano. Que cada uno
  diga en su cabecera que el otro existe y en qué se diferencian.

No toques todavía cuaderno-incidentes.md: el bloque "Incidente 01" placeholder se
elimina en el lote L1, cuando lo reemplace el incidente real.
```

### 6.2 L1 — Incidentes 01-04 · entorno y routing

```
[preámbulo]

Redacta los incidentes 01, 02, 03 y 04, y ELIMINA el bloque placeholder
"Incidente 01 — {{Título...}}" y el "Incidente 02 — {{...}}" que hoy ocupan su
lugar (ya migraron a prompts/plantilla-de-incidente.md en P1).

Lee antes, completas, las fases que los producen y sus bloques de reserva:
00-setup-hola-mundo-cra.md (§6 y §Reservas) y 01-estructura-base-router-5.md
(íd.), más A3-node-y-npm.md y A5-class-components-vs-hooks.md.

01 — "Bajé el repo y npm start explota antes de abrir nada" · Entorno · 🟢 · ~120 líneas.
   Semilla: el error 0308010C:digital envelope routines::unsupported de §6 de la
   Fase 0. Causa: Node 17+ con webpack 4 de react-scripts 4. Parche mínimo:
   NODE_OPTIONS=--openssl-legacy-provider. Refactor correcto: fijar Node 14.21.3
   con .nvmrc y engines. Es el primer incidente del curso: enseña a leer un stack
   trace de build, que es la capa que el resto del cuaderno no toca.

02 — "En la máquina de al lado compila y en la mía no" · Entorno · 🟢 · ~130 líneas.
   Semilla: node-sass en Apple Silicon y un node_modules compartido entre
   arquitecturas. D4: ESTE NO TERMINA EN FIX. El desenlace es documentación —una
   nota en A3, un .nvmrc, y la instrucción de borrar node_modules— y hay que decir
   explícitamente que ese desenlace es tan válido como un commit.

03 — "Hago clic en el menú y se recarga toda la aplicación" · UI/routing · 🟢 · ~115 líneas.
   Semilla: error común #3 de la Fase 1, <a href> en vez de <Link>. La evidencia
   está en la pestaña Network (documento completo recargado) y en que el store se
   vacía. Enseña que "se recarga" es observable antes de abrir un archivo.

04 — "Entro al detalle de otra rifa y sigo viendo la anterior" · UI/routing · 🟡 · ~170 líneas.
   Semilla: useState inicializado con la rifa y sin useEffect que reaccione al
   cambio de :id. IMPORTANTE: admite una segunda causa plausible (key mal puesta
   en la lista) y su reserva dice que esa ambigüedad es lo que lo hace formativo.
   El bloque "Si tu causa fue distinta a esta" es aquí el más importante del
   incidente: desarrolla las dos y di cómo se distinguen con evidencia.
```

### 6.3 L2 — Incidentes 05-08 · auth e integración

```
[preámbulo]

Redacta los incidentes 05, 06, 07 y 08. Lee antes 02-autenticacion-minima.md y
03-mock-api-express-caos.md completas (§5, §6 y §Reservas).

05 — "Las peticiones salen sin token y el servidor las rebota" · Auth · 🟡 · ~155 líneas.
   Semilla: error común #1 de Fase 2 — interceptor mal registrado, o registrado
   después de la primera petición. La evidencia son los headers en Network.

06 — "Cerré sesión pero la pantalla sigue mostrando mi usuario" · Auth · 🟡 · ~170 líneas.
   Semilla: cruza el authSlice sin persistencia 💸 con el loop de redirección del
   error común #2. Su reserva dice que "se resuelve con Redux DevTools antes que
   con código": la pieza forense de esa fase (§6.2, correlación por requestId) es
   la herramienta, y hay que usarla en la solución, no solo mencionarla.

07 — "A veces no carga y no dice nada" · Integración · 🟡 · ~180 líneas.
   EL TICKET VAGO CANÓNICO DEL CURSO. Semilla: el timeout de §6 de Fase 3, la
   petición pendiente más de 5 s sin que la UI diga nada. Exige CHAOS_LEVEL=high.
   La lección explícita: "a veces" es un dato sobre la reproducibilidad, no un
   defecto del reporte. Este incidente tiene que enseñar la pregunta "¿se
   reproduce con un flag, con un dato, o hace falta otro código?".

08 — "Me saca a login al azar mientras estoy trabajando" · Integración · 🟡 · ~175 líneas.
   Semilla: el 401 aleatorio del middleware de caos cruzado con el interceptor
   global que se estrena en Fase 3. HERMANO de be-08 (D6): allá la causa es un exp
   real de JWT sin renovación; acá es el caos. LEE be-08 primero y respeta cómo
   describe el contraste. Encabezado con "· Hermano del incidente be-08".
```

### 6.4 L3 — Incidentes 09-12 · store y concurrencia

```
[preámbulo]

Redacta los incidentes 09, 10, 11 y 12. Lee antes 04-rifas-crud.md y
05-venta-de-numeros.md completas, más A6-redux-clasico-vs-toolkit.md.

09 — "Guardo la rifa, se recarga la página y pierdo todo" · Store · 🟢 · ~125 líneas.
   Semilla: e.preventDefault() olvidado en el submit. Su reserva subraya lo
   formativo: el síntoma ("se borró todo") no se parece en nada a la causa. Que la
   solución lo diga con esas palabras.

10 — "La lista de rifas se queda cargando para siempre" · Store · 🟡 · ~165 líneas.
   Semilla: el slice que solo maneja fulfilled y nunca rejected. D4: ESTE NO
   TERMINA EN FIX NECESARIAMENTE — con CHAOS_LEVEL=off no se reproduce jamás, y
   "esa es la mitad de la lección". El entregable es un diagnóstico de "no
   reproduce, y acá está la evidencia de por qué y de con qué SÍ reproduciría",
   con el estado ⚪ como desenlace legítimo. El fix aparece igual, pero después de
   demostrar la condición.

11 ⭐ — "Vendimos el número 0347 dos veces" · Concurrencia · 🔴 · ~290 líneas.
   LA PIEZA CENTRAL DEL CURSO. Semilla: dos actores, un número, un reducer sin
   guarda de estado de origen. Se ve en Redux DevTools antes que en el código.
   Clave pedagógica: su fix mínimo (la guarda en el reducer) es DISTINTO de su fix
   correcto (la cancelación en el origen, que solo llega en Fase 6) — es el mejor
   ejemplo del curso de la distinción parche/refactor que atraviesa el cuaderno.
   HERMANO de be-09 (D6), el arquetipo del cruce: allá índice único y transacción.
   Lee be-09 completo antes de escribir. Encabezado con "⭐" y "· Hermano de be-09".

12 — "Un número que ya estaba vendido volvió solo a disponible" · Concurrencia · 🟠 · ~200 líneas.
   Semilla: DOS causas que producen el mismo síntoma — rollbackSale que revierte a
   ciegas, y el timer de reserva que sobrevive al desmontaje. Distinguirlas ES el
   ejercicio. Estructura las pistas para que no delaten cuál de las dos es;
   desarrolla ambas en la solución y da el experimento que las separa.
```

### 6.5 L4 — Incidentes 13, 14, 15, 17 · RxJS / epics

```
[preámbulo]

Redacta los incidentes 13, 14, 15 y 17 (el 16 va en L5 aunque sea de Fase 7: es
de tiempo, no de epics). Lee antes 06-redux-observable-a-fondo.md y
07-cierre-polling-resultado.md completas, más A7-redux-observable-epica-por-epica.md
y A11-marble-testing.md.

Estos cuatro son los que el alcance §7 marca como mínimo obligatorio, y los cuatro
son INVISIBLES EN LA CONSOLA. El hilo común: la ausencia de error es el síntoma.
Cada uno tiene que decir con qué se caza, porque no es leyendo código.
Los cuatro llevan prueba de regresión con MARBLES, no con RTL.

13 — "Falló una venta y desde entonces no funciona ninguna" · 🟠 · ~200 líneas.
   Semilla: sin catchError, el primer error mata el epic entero y la consola calla.
   El silencio es el síntoma. Se caza notando que el epic dejó de emitir.

14 ⭐ — "Cerré sesión y el servidor sigue recibiendo peticiones" · 🟠 · ~260 líneas.
   La suscripción zombi del boardRefreshEpic sin takeUntil. Se caza en NETWORK, no
   en el código. Su fix es UNA LÍNEA: el mejor ejemplo del curso de "bug caro,
   parche barato, causa invisible". OJO: 00-convencion-de-git-y-tags.md:230-246 ya
   redactó los mensajes de los tags inc/14/suscripcion-zombi-roto y -fix, con
   síntoma, repro, evidencia, causa raíz y regresión. El incidente TIENE QUE SER
   CONSISTENTE con ese texto palabra por palabra: takeUntil dentro del mergeMap en
   vez de al final del pipe, y el marble test que verifica que el observable
   completa al llegar el logout. Es la única fuente ya publicada de un incidente.

15 — "Escribo el número rápido y me valida uno viejo" · 🟠 · ~205 líneas.
   Semilla: mergeMap donde iba switchMap en la validación. Las respuestas viejas
   pisan a las nuevas y el resultado DEPENDE DE LA LATENCIA: exige CHAOS_LEVEL=high
   y el enunciado tiene que decir que con caos apagado no se ve.

17 — "El resultado nunca llega y no aparece ningún error" · 🟠 · ~215 líneas.
   Semilla: catchError colocado FUERA del timer — el primer 500 de la lotería mata
   el polling en silencio. Convive con una segunda causa plausible: tratar el 204
   como error. Distinguirlas es el ejercicio; ambas van desarrolladas.
```

### 6.6 L5 — Incidentes 16, 18, 19, 20 · tiempo, dinero, performance, testing

```
[preámbulo]

Redacta los incidentes 16, 18, 19 y 20. Lee antes 07-cierre-polling-resultado.md,
08-liquidacion-calculo-premio.md, 09-dashboard.md, 10-testing-minimo.md y
11-cierre-puente-react-moderno.md, más A10-aritmetica-de-dinero.md.

LOS CUATRO TIENEN HERMANO EN EL TRACK BE (be-12, be-13, be-05 y be-15). Lee los
cuatro hermanos completos antes de escribir y respeta cómo describen el contraste;
el índice del cuaderno base ya publicó qué cambia en cada par. Encabezado con
"· Hermano del incidente be-NN".

16 — "La rifa siguió vendiendo después de la hora de cierre" · Tiempo · 🟠 · ~210 líneas.
   Semilla: comparar componentes de fecha en vez de instantes. El síntoma CAMBIA
   según la zona horaria del navegador, así que el enunciado DEBE decir en qué TZ
   estaba el cliente, o no se reproduce. Hermano de be-12 (allá: la autoridad del
   reloj del servidor; acá: el reloj del navegador).

18 — "La liquidación da un centavo de diferencia" · Dinero · 🟠 · ~195 líneas.
   Semilla: la pieza forense de floats contra enteros — calculateTotalCollectedBroken
   con numberPriceInPesos: 0.1 y tres números vendidos. Datos exactos, reproducible
   al centavo. La lección es la DESPROPORCIÓN: síntoma de un centavo, causa
   estructural. Hermano de be-13 (allá: el cliente calculando con datos viejos).

19 — "El dashboard se arrastra al final del día" · Performance · 🟠 · ~200 líneas.
   Semilla: useMemo con dependencias que se recrean en cada render — la
   memoización existe y no sirve. Solo se nota CON VOLUMEN: el enunciado tiene que
   decir cuántas rifas y cuántos números hacen falta para verlo, y el db.json de
   preparación tiene que traerlos. Herramienta: React DevTools Profiler.
   Hermano de be-05 (allá: el pool de conexiones agotado).

20 — "El test pasa en mi máquina y falla en la de al lado" · Testing · 🔴 · ~270 líneas.
   Semilla: el ejercicio 🟠 23 de Fase 10 — un MetricCard de fechas que depende del
   reloj y de la zona horaria de quien corre el test. ÚNICO INCIDENTE QUE NO SE
   REPRODUCE EN LA APLICACIÓN SINO EN LA SUITE, y por eso cierra el arco: el test
   también es código que se mantiene. D4: SE ABRE EN FASE 10 Y CIERRA EN FASE 11,
   y su desenlace es una DECISIÓN (hotfix con jest fake timers vs. refactor a
   inyección del reloj), no un parche. Hermano de be-15 (allá: el motor de la base).
```

### 6.7 P3 — El índice 🩺 de síntomas

```
[preámbulo]

Con los veinte incidentes ya redactados, agrega a cuaderno-incidentes.md una
sección nueva "## 🩺 Entrar por el síntoma", ubicada entre "### Estados" y
"## 📋 Índice". 45-70 líneas. NO crees un archivo nuevo: el cuaderno declara ser
el único archivo de incidentes del curso.

Modelo de referencia: angular-16-legacy-for-backend-devs/forense-master.md §1 y §3.
Adáptalo, no lo copies: allí las capas son plantilla/servicio/interceptor/guard;
acá son componente / store / epic / interceptor / mock / build.

Dos partes:

(a) El método, en prosa, tres o cuatro preguntas EN ORDEN, con el argumento de por
    qué ese orden (cada una cuesta un orden de magnitud más que la anterior):
    ¿se reproduce, y con qué —un flag de CHAOS_LEVEL, un dato de db.json, o hace
    falta otro código—? · ¿qué dice la evidencia observable antes que el código? ·
    ¿en qué capa está? · ¿de qué era es el archivo que voy a tocar (las tres eras
    de 00-historia-del-sistema.md)? Esta última es la pregunta propia de este
    curso, porque el sistema mezcla clases con hooks y connect() con useSelector.

(b) Una tabla de cuatro columnas: síntoma tal como llega | primera herramienta |
    capa más probable | incidentes candidatos (por ID). Una fila por familia de
    síntoma, no por incidente: "a veces no carga", "me saca a login", "veo datos
    de otra cosa", "se quedó cargando", "el número se vendió dos veces", "sigue
    pasando después de cerrar sesión", "la cuenta no cuadra", "va lento al final
    del día", "verde en mi máquina, rojo en la de al lado", "no arranca".

Y la regla que resume el método, como callout 🧭: "funciona en mi máquina", "a
veces pasa" y "desde ayer" no describen un bug, describen una DIFERENCIA; el
trabajo es encontrar cuál.

Cierra replicando la sección en cuaderno-incidentes-be.md con las capas del
backend (handler / repositorio / transacción / migración / contenedor / pipeline)
y sus herramientas (log estructurado, EXPLAIN, pg_stat_activity, go test -race).
```

### 6.8 P4 — Costura y cierre

```
[preámbulo]

El cuaderno ya tiene sus veinte incidentes y su índice de síntomas. Cierra los
bucles que quedaron abiertos apuntando a él. Ediciones pequeñas, un commit.

1. cuaderno-incidentes.md, tabla del índice: las veinte filas pasan de ⬜ a ⬜ pero
   con el título definitivo del enunciado redactado (el estado ⬜ es del ESTUDIANTE,
   no del autor: no lo toques). Verifica que título, categoría y dificultad de cada
   fila coinciden con el encabezado del incidente. Y borra del preámbulo del índice
   la frase "Un ⬜ significa que el enunciado todavía no está redactado abajo".

2. Las 12 fases: en su sección 6, donde hoy mencionan los incidentes, que enlacen
   por ancla real (cuaderno-incidentes.md#incidente-NN--slug). Y en el bloque
   "### Reservas para el cuaderno de incidentes", cambia "aunque el enunciado
   todavía no esté redactado" por la constancia de que ya lo está.

3. README.md: elimina el callout "> ⚠️ Estado del cuaderno" entero. Reescribe el
   párrafo del cuaderno base para que describa lo que hay, y ajusta la frase del
   track BE que hoy contrasta ("el cuaderno del track BE sí está completo"), que
   deja de tener sentido.

4. prompts/guia-de-estilo-y-convenciones.md §15: tacha con ~~ ~~ la viñeta "El
   cuaderno de incidentes está vacío" y muévela al párrafo de resueltos, con el
   mismo formato que se usó para "Tablas anchas heredadas". Añade a §13 una línea
   remitiendo a prompts/plantilla-de-incidente.md como la forma canónica.

5. 00-convencion-de-git-y-tags.md: verifica que el ejemplo del incidente 14
   (líneas 230-246) coincide con el incidente 14 redactado. Si divergen, gana el
   archivo publicado y se corrige el incidente, no al revés.

6. Verificación final:
   - grep -c "^## Incidente" cuaderno-incidentes.md  → 20
   - ningún "{{" queda en cuaderno-incidentes.md fuera del bloque "Tu investigación"
   - los seis hermanos (08, 11, 16, 18, 19, 20) llevan su línea "· Hermano de be-NN"
   - cero voseo: grep -nE "\b(tenés|podés|querés|hacé|mirá|fijate|sabés|vos)\b"
```

---

## 7. ✅ Antes de borrar este archivo

- [ ] D1–D6 confirmadas y sus resoluciones anotadas en la guía de estilo §15.
- [ ] `prompts/plantilla-de-incidente.md` existe y el placeholder salió del cuaderno.
- [ ] Los 20 incidentes redactados (`grep -c "^## Incidente"` → 20).
- [ ] El índice 🩺 está en los dos cuadernos.
- [ ] README y guía §15 ya no describen el hueco.
- [ ] Este archivo **no** quedó referenciado desde ningún `.md` del curso
      (`grep -rn "completado_cuaderno_incidentes" --include="*.md" .` → solo él mismo).
- [ ] `rm completado_cuaderno_incidentes.md`
PLANEOF
wc -l /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs/completado_cuaderno_incidentes.md

# --- 2026-09-10T01:32:23 · Check for gitignore
cd /Users/oskar/Developer/Learning/courses-ia-generated && cat .gitignore 2>/dev/null || echo "(sin .gitignore)"

# --- 2026-09-10T01:35:05 · Cross-check incident 14 descriptions across documents
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs && echo "=== A) cuaderno-incidentes.md (convención de commits) ===" && sed -n '53,60p;69,76p' cuaderno-incidentes.md && echo && echo "=== B) 00-convencion-de-git-y-tags.md ===" && sed -n '232,246p' 00-convencion-de-git-y-tags.md && echo && echo "=== C) Fase 06, reserva ===" && sed -n '634,639p' 06-redux-observable-a-fondo.md && echo && echo "=== D) boardRefreshEpic / takeUntil en las fases ===" && grep -rn "boardRefreshEpic" --include="*.md" . | head -20

# --- 2026-09-10T01:35:10 · Read boardRefreshEpic broken and fixed versions
sed -n '455,500p' 06-redux-observable-a-fondo.md; echo "=== versión corregida F7 ==="; sed -n '505,540p' 07-cierre-polling-resultado.md

# --- 2026-09-10T01:45:45 · Verify endpoint shape and read the BE incident template
grep -rn "raffles/\${\|/numbers\|fetchNumbers = \|apiClient.get" --include="*.md" 05-venta-de-numeros.md 06-redux-observable-a-fondo.md | head -12; echo "=== plantilla BE completa ==="; cat prompts/plantilla-de-incidente-be.md

# --- 2026-09-10T01:45:57 · Fix the incident 14 tag example in the git convention
python3 - <<'PY'
import io
p = "00-convencion-de-git-y-tags.md"
s = io.open(p, encoding="utf-8").read()
old = '''git tag -a inc/14/suscripcion-zombi-fix -m "Causa raíz: boardRefreshEpic con
el takeUntil dentro del mergeMap en vez de al final del pipe. Fix: takeUntil
(LOGOUT, STOP_BOARD_REFRESH) cerrando el pipe externo. Regresión: marble test
que verifica que el observable completa al llegar el logout."'''
new = '''git tag -a inc/14/suscripcion-zombi-fix -m "Causa raíz: boardRefreshEpic sin
takeUntil: el interval que abre el switchMap no se cancela nunca. Fix:
takeUntil(STOP_BOARD_REFRESH, LOGOUT) último en el pipe interno. Regresión:
marble test que verifica que el observable completa al llegar el logout."'''
assert s.count(old) == 1, s.count(old)
io.open(p, "w", encoding="utf-8").write(s.replace(old, new))
print("ok")
PY
sed -n '236,246p' 00-convencion-de-git-y-tags.md

# --- 2026-09-10T01:46:56 · Create the base incident template
cat > prompts/plantilla-de-incidente.md <<'TPLEOF'
# 🧩 Plantilla de incidente — track base
## Tutorial React 16 — Rifas y chances

Copia este esqueleto al redactar un incidente de `cuaderno-incidentes.md` y rellena los
`{{placeholders}}`. Borra las notas entre paréntesis antes de entregar.

Vivía embebida dentro del propio cuaderno, como "Incidente 01" con placeholders. Se
extrajo acá porque ese lugar lo ocupa el incidente real de la Fase 0, y una plantilla que
se destruye al escribir el primer caso no es una plantilla. Su hermana de backend es
`plantilla-de-incidente-be.md`: **la estructura es la misma y no se toca** —ticket → qué se
te pide → preparación → tres pistas escalonadas → tu investigación → solución de referencia
colapsada—; allá cambian las herramientas y el vocabulario, por la misma razón que cambia
la pieza forense de cada fase (`guia-de-estilo-y-convenciones.md` §16.4).

> 🔄 **Convención de idioma.** El ticket, la narrativa, las pistas y los comentarios de
> código van en **español latinoamericano con tuteo**. Los identificadores, endpoints,
> constantes y acciones van en **inglés** (`diccionario-codigo-ingles.md`).

---

## Las tres palancas de la preparación

Un incidente que no se reproduce no es un incidente: es una anécdota. En el track base hay
exactamente tres formas de dejar el laboratorio en el estado roto de partida, y **todo
incidente declara las tres**, aunque alguna diga "no aplica". Omitir una es la causa número
uno de un enunciado irreproducible.

**1. La rama `incidente/NN`.** Lleva el código al estado roto. Es distinta de los tags
`inc/<ID>/<slug>-roto|-fix`, que marcan **tu** recorrido resolviéndolo: la rama te lleva al
problema, los tags cuentan cómo saliste (`00-convencion-de-git-y-tags.md`, §🚑 y su nota 📝).

**2. El `CHAOS_LEVEL` del mock.** `off`, `low` o `high`, como los define la Fase 3. Los
bugs que dependen de latencia o de fallos intermitentes **solo** aparecen con `high`, y el
enunciado tiene que decirlo o el estudiante concluirá que el ticket estaba equivocado. Al
revés también cuenta: un incidente que se reproduce con `off` es un bug determinista, y
decirlo es media pista.

**3. El estado de `db.json`.** Qué rifa, qué números, en qué estado, a qué hora de cierre y
**en qué zona horaria**. Los incidentes de tiempo son irreproducibles sin la TZ del
navegador declarada, y los de rendimiento lo son sin volumen: si hace falta sembrar
doscientas rifas, el incidente trae el script que las siembra.

---

## La escala de longitud

Un incidente 🟢 con doscientas líneas aburre; uno 🔴 con ciento veinte miente sobre lo que
cuesta. La proporción es parte del contrato con el estudiante:

| Dificultad | Líneas | Tiempo sugerido |
|---|---|---|
| 🟢 fácil | 110-140 | 20-30 min |
| 🟡 intermedio | 150-190 | 30-45 min |
| 🟠 difícil | 190-230 | 45-70 min |
| 🔴 y ⭐ | 250-300 | 60-90 min |

---

```markdown
## Incidente {{NN}} — {{Título en palabras del usuario}}

> **Fase:** {{N}} · **Categoría:** {{entorno / UI-routing / autenticación / integración / estado (store) / concurrencia / RxJS-epics / tiempo / dinero / performance / testing}} · **Dificultad:** {{🟢🟡🟠🔴}}
> **Estado:** ⬜ Sin empezar · **Abierto:** {{—}} · **Cerrado:** {{—}}
> **Tiempo sugerido:** {{20-40 min}}
> {{⭐ si es de los dos más formativos}} {{· Hermano del incidente be-{{NN}}, con otra causa raíz}}

### 🎫 El ticket

{{El reporte tal como llegó, con su vaguedad incluida. Dos o tres frases en lenguaje de
negocio, escritas por alguien que no sabe qué es un epic. "A veces no carga" es un dato
legítimo sobre la reproducibilidad, no un defecto del reporte. Si el reporte trae una
teoría del usuario sobre la causa —y suelen traerla—, consérvala: descartarla es parte del
trabajo.}}

**Reportado por:** {{rol — vendedor de rifas, supervisor, tesorería, soporte}}
**Ambiente:** {{desarrollo / UAT / PROD / varios}}

### 🎯 Qué se te pide

{{Una o dos líneas con el entregable concreto: reproducir y localizar la capa, o reproducir
y aplicar el hotfix mínimo, o explicar por qué no se reproduce. No todos los incidentes
terminan en fix.}}

### 🔧 Preparación

{{Las tres palancas, siempre las tres. Si alguna no aplica, se dice: "CHAOS_LEVEL: da igual,
el bug es determinista" es información, el silencio no.}}

- **Rama:** {{incidente/NN}}
- **Caos:** {{off / low / high — y por qué}}
- **Datos:** {{qué rifa, qué números, en qué estado, a qué hora de cierre, en qué zona horaria}}

```bash
{{git checkout incidente/NN
CHAOS_LEVEL=high npm run mock}}
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

{{Señala la capa y la herramienta, sin decir qué vas a encontrar: "esto se ve en la pestaña
Network antes que en la consola" o "el store ya tiene la respuesta; compara la acción que
entra con el estado que sale". No nombra el archivo.}}

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

{{Acota al archivo o al momento exacto, todavía sin nombrar la causa.}}

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

{{La pregunta cuya respuesta es la causa raíz. No la respuesta.}}

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución. Es la parte que se versiona y la que vas
a releer en la retrospectiva del mes. Se entrega VACÍA, con sus placeholders intactos.}}

**Reproducción**
{{Pasos numerados y exactos, con datos concretos: qué rifa, qué número, en qué estado, a
qué hora y en qué zona horaria. Si no lo lograste, escribe qué intentaste — no reproducir
también es un resultado.}}

**Evidencia observable**
{{Lo que viste, no lo que supones: consola, Network, React DevTools, Redux DevTools, logs
del mock. Texto, no capturas: el texto se versiona y se busca.}}

```
{{payload, error o secuencia de acciones despachadas}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea, o la decisión de diseño culpable. En qué capa vive: componente, store,
epic, interceptor, mock o build.}}

**Tu fix**
{{El parche mínimo que aplicarías un viernes a las seis. Aparte, en una línea, la
refactorización correcta que harías con calma.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

{{Hasta el archivo y la línea. Si la causa es una decisión de diseño, se nombra la decisión
y se explica por qué en su momento tenía sentido — 📝 nota de época, con la era de
`00-historia-del-sistema.md` que la produjo. Si la deuda está declarada en
`A12-mapa-de-deuda-tecnica.md`, se cita la entrada.}}

**Parche mínimo**

```javascript
{{el hotfix, con identificadores en inglés y comentarios en español}}
```

**La refactorización correcta** (que en este curso solo se paga si la Fase 11 la marca 💸)

{{Qué haría alguien con tiempo y pruebas, y por qué acá no se hace todavía.}}

**Prueba de regresión**

{{El test que falla antes del fix y pasa después. Código, no descripción. Si el bug es de
cancelación o de timing en un epic, va con marbles (`A11-marble-testing.md`); si es de
render, con RTL.}}

```javascript
{{test}}
```

**Prevención**

{{Test, validación en el reducer, guarda en el epic, o alerta. Lo que evita que el mismo
bug vuelva por otra puerta.}}

**Por qué llegó a producción**

{{Post-mortem sereno: qué del sistema o del proceso lo permitió. Se analiza el sistema,
nunca a la persona. Acá el humor baja un punto.}}

**Si tu causa fue distinta a esta**

{{Los diagnósticos alternativos plausibles y por qué el síntoma también encaja con ellos.
Que tu fix funcione y tu causa no coincida es información: casi siempre significa que
tapaste el síntoma una capa más arriba.}}

</details>
```

---

## Recordatorios al rellenar

- **El ID nunca se reasigna.** El rango del track base es `01` a `20` y está reservado desde
  las doce fases que los producen; el rango `be-01`–`be-16` es del track opcional y vive en
  otro archivo. Título, categoría y dificultad ya están fijados en el índice del cuaderno:
  se respetan palabra por palabra.
- **La fase indicada es la que hay que haber terminado** para poder resolverlo, no
  necesariamente la que introdujo el bug.
- **Cada incidente se lee solo.** Nada de "ver incidente 01": se repite la estructura entera
  aunque canse, porque se leen salteados y con semanas de diferencia.
- **Cada incidente tiene que poder resolverse con el laboratorio del alumno**, sin datos ni
  servicios externos (autocontención, guía §11).
- **Tres de los veinte no terminan en un commit** —el **02** cierra en documentación, el
  **10** en ⚪ "no se reproduce, y acá está la evidencia", el **20** en una decisión de la
  Fase 11— y esos tres tienen que decir explícitamente que ese desenlace es tan válido como
  un fix. Es el desenlace que menos se practica y el que más aparece en la vida real.
- **Los seis hermanos del track BE se marcan** en el encabezado: **08** (be-08), **11**
  (be-09), **16** (be-12), **18** (be-13), **19** (be-05) y **20** (be-15). Antes de
  redactar uno, se lee su hermano: aquel archivo ya está publicado y describe qué cambia
  entre las dos capas. Si divergen, gana el hermano publicado.
- **Todo el código corre con el stack fijado** (`decisiones-y-versiones.md`): React 16.14,
  react-scripts 4.0.3, Redux Toolkit 1.8.6, redux-observable 1.2.0, RxJS 6.6.7, Router
  5.3.4, axios 0.21.4, Jest 26, RTL 11, Node 14.21.3.
- **Nada de culpabilización** en el post-mortem, ni siquiera implícita (guía §13).
TPLEOF
wc -l prompts/plantilla-de-incidente.md

# --- 2026-09-10T01:47:06 · Update the BE template's stale cross-reference
python3 - <<'PY'
import io
p = "prompts/plantilla-de-incidente-be.md"
s = io.open(p, encoding="utf-8").read()
old = """Es la variante backend de la plantilla que `cuaderno-incidentes.md` lleva
embebida. **La estructura es la misma y no se toca**"""
new = """Es la variante backend de `plantilla-de-incidente.md`, la del track base.
**La estructura es la misma y no se toca**"""
assert s.count(old) == 1
io.open(p, "w", encoding="utf-8").write(s.replace(old, new))
print("ok")
PY
sed -n '4,14p' prompts/plantilla-de-incidente-be.md

# --- 2026-09-10T01:48:03 · Update the plan file with closed decisions and the H3 condition table
python3 - <<'PY'
import io
p = "completado_cuaderno_incidentes.md"
s = io.open(p, encoding="utf-8").read()
def rep(old, new, n=1):
    global s
    assert s.count(old) == n, (s.count(old), old[:60])
    s = s.replace(old, new)

# 1. Estado de la cabecera
rep("""> **Estado: veredicto cerrado (§1–§3), decisiones D1–D6 propuestas y pendientes de
> confirmación (§4).** Confirmadas esas seis, §6 se ejecuta sin más consultas.""",
"""> **Estado: veredicto cerrado (§1–§3), decisiones D1–D6 CERRADAS (§4), y ejecutados
> H1 (corrección del incidente 14) y H2 (extracción de la plantilla).** Lo que queda
> es §6.2–§6.8: los cinco lotes, el índice 🩺 y la costura. Se ejecutan sin más consultas.""")

# 2. Decisiones cerradas
rep("""Se replica después en `cuaderno-incidentes-be.md` con las capas del backend (P4). ⬜""",
"""Se replica después en `cuaderno-incidentes-be.md` con las capas del backend (P4). ✅ **CERRADA**""")
rep("""hermano BE. **Es bloqueante: va antes de P1.** ⬜""",
"""hermano BE. **Es bloqueante: va antes de P1.** ✅ **CERRADA Y EJECUTADA** —
`prompts/plantilla-de-incidente.md`, 231 líneas. Incorpora además D3, D4, D5 y D6, y la
referencia cruzada del hermano `-be` quedó actualizada.""")
rep("""Total proyectado: **≈ 3.900 líneas** (cuaderno final ~4.300, comparable al BE y al de
Angular-16, que tiene 3.916 con 20 incidentes). ⬜""",
"""Total proyectado: **≈ 3.900 líneas** (cuaderno final ~4.300, comparable al BE y al de
Angular-16, que tiene 3.916 con 20 incidentes). ✅ **CERRADA** — la tabla vive en la
plantilla, con su tiempo sugerido por tramo.""")
rep("""  criterio hotfix-vs-refactor. El entregable es la decisión, no el parche.
⬜""",
"""  criterio hotfix-vs-refactor. El entregable es la decisión, no el parche.
✅ **CERRADA: los tres.** Cada uno declara explícitamente que su desenlace vale tanto
como un fix.""")
rep("""los de tiempo (16, 20) **exigen** decir la zona horaria del navegador. ⬜""",
"""los de tiempo (16, 20) **exigen** decir la zona horaria del navegador. ✅ **CERRADA** —
la plantilla las convierte en tres viñetas obligatorias de 🔧 Preparación, y §4bis fija
cuál aplica a cada incidente.""")
rep("""→ **Recomendado: sí, y además cada uno de los seis lleva en su encabezado la línea
`· Hermano del incidente be-NN`**, simétrica a la que ya llevan allá. ⬜""",
"""→ **Recomendado: sí, y además cada uno de los seis lleva en su encabezado la línea
`· Hermano del incidente be-NN`**, simétrica a la que ya llevan allá. ✅ **CERRADA** —
y con la regla de desempate: si divergen, gana el hermano ya publicado.""")

# 3. Nueva sección §4bis: ficha de condiciones (H3) + registro de H1
rep("""---

## 5. 📦 Paquetes de trabajo, en orden""",
"""---

## 4bis. 🔬 Ficha de condiciones de reproducción (hallazgo H3)

Seis de los veinte no se reproducen si el enunciado calla una condición. Esta tabla es
contrato para los lotes: el incidente que no la respete es irreproducible y hay que
reescribirlo entero.

| ID | Condición que el enunciado DEBE declarar | Si falta |
|---|---|---|
| 07 | `CHAOS_LEVEL=high` — el timeout de 5 s solo lo inyecta el caos alto | "a mí no me pasa" |
| 15 | `CHAOS_LEVEL=high` — sin latencia, la respuesta vieja nunca pisa a la nueva | el `mergeMap` parece correcto |
| 17 | `CHAOS_LEVEL=high` en el mock de lotería (`3002`) — hace falta un 500 | el polling nunca muere |
| 16 | La zona horaria del navegador, explícita | el síntoma cambia de signo |
| 20 | La TZ **y** la hora de la máquina que corre la suite | el test pasa en las dos |
| 19 | El volumen: cuántas rifas y cuántos números | el `useMemo` inútil no se nota |

**El 19 arrastra trabajo extra.** Ninguna fase siembra hoy un `db.json` con volumen
suficiente para que la memoización rota se note en el Profiler. El lote L5 tiene que
generar ese script de siembra y dejarlo en la 🔧 Preparación del incidente; sin él, el
enunciado pide observar algo invisible.

### Registro de H1 — el incidente 14, cerrado

`00-convencion-de-git-y-tags.md:240-243` describía el bug de tres formas incompatibles con
el código publicado: decía que el `takeUntil` existía y estaba mal puesto (`06-…md:462-476`
no tiene ninguno), decía `mergeMap` donde el epic usa `switchMap`, y mandaba el fix al
**pipe externo** — lo contrario de la regla que la propia Fase 6 enseña en su error común
#3 (*"`takeUntil` casi siempre va último en el pipe interno"*) y de lo que hace la versión
corregida de `07-…md:508-528`. Corregido: causa = falta el `takeUntil`; fix = último en el
pipe interno. **El mensaje del tag `-roto` se verificó y es correcto**: `GET
/raffles/3/numbers` coincide con el endpoint real (`05-venta-de-numeros.md:175`).

Queda una ambigüedad menor, deliberadamente sin tocar para no ampliar el alcance:
`cuaderno-incidentes.md:58` dice *"takeUntil(...) al final del pipe"* sin aclarar que es el
interno. No es incorrecto, pero conviene precisarlo en P4, cuando ese archivo se toque igual.

---

## 5. 📦 Paquetes de trabajo, en orden""")

# 4. P1 hecho
rep("""### P1 — `prompts/plantilla-de-incidente.md` (1 archivo nuevo, ~180 líneas)
Extraer la plantilla del Incidente 01 antes de que se pise. Commit propio, un solo archivo.""",
"""### ~~P1 — `prompts/plantilla-de-incidente.md`~~ ✅ HECHO (231 líneas)
Incluye las tres palancas de preparación, la escala de longitud, los tres desenlaces sin
fix y los seis hermanos. **El placeholder "Incidente 01" sigue dentro de
`cuaderno-incidentes.md` y lo elimina el lote L1**, que es quien ocupa ese lugar.""")

# 5. Corregir el prompt de L4 (incidente 14) a la causa canónica
rep("""14 ⭐ — "Cerré sesión y el servidor sigue recibiendo peticiones" · 🟠 · ~260 líneas.
   La suscripción zombi del boardRefreshEpic sin takeUntil. Se caza en NETWORK, no
   en el código. Su fix es UNA LÍNEA: el mejor ejemplo del curso de "bug caro,
   parche barato, causa invisible". OJO: 00-convencion-de-git-y-tags.md:230-246 ya
   redactó los mensajes de los tags inc/14/suscripcion-zombi-roto y -fix, con
   síntoma, repro, evidencia, causa raíz y regresión. El incidente TIENE QUE SER
   CONSISTENTE con ese texto palabra por palabra: takeUntil dentro del mergeMap en
   vez de al final del pipe, y el marble test que verifica que el observable
   completa al llegar el logout. Es la única fuente ya publicada de un incidente.""",
"""14 ⭐ — "Cerré sesión y el servidor sigue recibiendo peticiones" · 🟠 · ~260 líneas.
   La suscripción zombi del boardRefreshEpic. Se caza en NETWORK, no en el código.
   Su fix es UNA LÍNEA: el mejor ejemplo del curso de "bug caro, parche barato,
   causa invisible".
   CAUSA CANÓNICA, ya alineada en tres documentos: el epic de 06-…md:462-476 NO
   TIENE takeUntil — el interval que abre el switchMap no se cancela nunca. El fix
   es takeUntil(STOP_BOARD_REFRESH, LOGOUT) ÚLTIMO EN EL PIPE INTERNO, tal como lo
   hace la versión corregida de 07-…md:508-528 y como manda el error común #3 de la
   Fase 6. NO lo pongas en el pipe externo.
   OJO: 00-convencion-de-git-y-tags.md:230-246 ya publica los mensajes de los tags
   inc/14/suscripcion-zombi-roto y -fix con síntoma, repro, evidencia, causa raíz y
   regresión. El incidente TIENE QUE SER CONSISTENTE con ese texto: es la única
   fuente publicada de un incidente de este cuaderno. Reprodúcelo, no lo reinventes.
   Y como el bug es el mismo del ejercicio 18 de la Fase 6, lo que este incidente
   aporta NO es el bug sino el marco: el ticket vago, la caza en Network, el marble
   de regresión y el post-mortem. Que el enunciado no lo disimule.""")

# 6. Checklist final
rep("""- [ ] D1–D6 confirmadas y sus resoluciones anotadas en la guía de estilo §15.
- [ ] `prompts/plantilla-de-incidente.md` existe y el placeholder salió del cuaderno.""",
"""- [x] D1–D6 confirmadas. **Falta** anotar sus resoluciones en la guía de estilo §15 (P4).
- [x] H1: `00-convencion-de-git-y-tags.md` describe el incidente 14 como lo describe el código.
- [x] H2: `prompts/plantilla-de-incidente.md` existe. **Falta** que el placeholder salga
      del cuaderno (lo hace L1).
- [ ] H3: los seis incidentes de la ficha §4bis declaran su condición, y el 19 trae su
      script de siembra.""")
io.open(p, "w", encoding="utf-8").write(s)
print("ok")
PY
wc -l completado_cuaderno_incidentes.md

# --- 2026-09-10T01:48:11 · Lint new files and confirm changed file set
echo "=== voseo ==="; grep -nE "\b(tenés|podés|querés|hacé|mirá|fijate|sabés|vos|deberías ver vos|ordenador|vale,)\b" prompts/plantilla-de-incidente.md completado_cuaderno_incidentes.md 00-convencion-de-git-y-tags.md || echo "limpio"; echo "=== referencias a la plantilla nueva ==="; grep -rn "plantilla-de-incidente.md" --include="*.md" . ; echo "=== git status ==="; cd .. && git status --short | grep -E "react-16.*(plantilla|convencion|completado)"

# --- 2026-09-10T01:48:19 · Mark the P1 prompt as already executed
cd react-16-legacy-for-backend-devs && python3 - <<'PY'
import io
p="completado_cuaderno_incidentes.md"; s=io.open(p,encoding="utf-8").read()
old="### 6.1 P1 — Extraer la plantilla base\n"
new="### 6.1 P1 — Extraer la plantilla base ✅ YA EJECUTADO (se conserva como registro)\n"
assert s.count(old)==1
io.open(p,"w",encoding="utf-8").write(s.replace(old,new)); print("ok")
PY

# --- 2026-09-10T01:49:23 · Read section 6 of phases 0 and 1
sed -n '414,455p' 00-setup-hola-mundo-cra.md; echo "=========== FASE 01 §6"; sed -n '492,525p' 01-estructura-base-router-5.md

# --- 2026-09-10T01:49:34 · Read the three eras of the system
sed -n '56,130p' 00-historia-del-sistema.md

# --- 2026-09-10T01:53:58 · Draft incidents 01-04
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L1.md <<'L1EOF'
## Incidente 01 — Bajé el repo y `npm start` explota antes de abrir nada

> **Fase:** 0 · **Categoría:** Entorno · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-30 min

### 🎫 El ticket

Me pasaron el repositorio el lunes. Seguí el README paso por paso, hice el `npm
install` y cuando corro `npm start` se muere solo, con un montón de letras y
números que no significan nada para mí. No llegué a ver la aplicación ni una vez.
En la máquina de mi compañero arranca sin problema, y estamos en el mismo commit.

**Reportado por:** nuevo integrante del equipo, primer día
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Reproducir, localizar en qué capa vive la causa —adelanto: no está en `src/`— y
aplicar el hotfix que lo desbloquee hoy. Después, en una línea aparte, cuál es la
corrección correcta. En este incidente las dos no son lo mismo, y la Fase 0 tiene
opinión al respecto.

### 🔧 Preparación

- **Rama:** `incidente/01`
- **Caos:** no aplica. En Fase 0 todavía no existe el mock, y el fallo es
  determinista: pasa siempre o no pasa nunca.
- **Datos:** no aplica.

La rama trae el `.nvmrc` borrado a propósito, que es justo lo que hace que el
problema dependa de con qué Node estés parado.

```bash
git checkout incidente/01
nvm use 20        # o cualquier Node 17+; ese es el detonante
npm install
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

El error no lo produce tu código: lee el volcado entero y fíjate si alguna línea
menciona un archivo de `src/`. Ninguna. Antes de abrir un editor, pregúntate qué
es lo único que puede diferir entre tu máquina y la de tu compañero si el
repositorio y el commit son idénticos.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Lee el volcado hasta el final, no las tres primeras líneas. El módulo que falla
pertenece a webpack, y hay dos palabras que se repiten: `digital envelope` y
`openssl`. Ahora corre `node --version` en tu máquina y en la de tu compañero.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué versión de OpenSSL trae Node 17 en adelante, qué algoritmo de hash usa
webpack 4 para nombrar sus módulos, y qué pasó con ese algoritmo en OpenSSL 3?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados y exactos. Anota tu versión de Node y tu sistema operativo:
en este incidente son el dato, no el contexto.}}

**Evidencia observable**
{{El volcado completo, en texto. No la captura: el texto se busca.}}

```
{{el error tal cual salió por la terminal}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{¿En qué capa vive? Componente, store, epic, mock, build… o ninguna de esas.}}

**Tu fix**
{{El parche mínimo del viernes a las seis. Aparte, la corrección correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

No hay archivo culpable. La causa es una incompatibilidad entre el **runtime** y
una dependencia de build: Node 17 y posteriores traen OpenSSL 3, que retiró MD4
del proveedor por defecto, y el webpack 4 que empaqueta `react-scripts@4.0.3` usa
justamente MD4 para hashear los identificadores de módulo. El resultado es
`error:0308010C:digital envelope routines::unsupported`, a veces disfrazado de
`ERR_OSSL_EVP_UNSUPPORTED`.

> 📝 **Nota de época.** `react-scripts@4.0.3` es de 2021, cuando Node 14 era LTS y
> nadie tenía OpenSSL 3 en su máquina. El sistema se congeló en 2023
> (`00-historia-del-sistema.md` §3, cierre de la Era 3) con esa combinación
> funcionando. No envejeció el proyecto: envejeció el mundo alrededor.

**Parche mínimo**

```bash
# El viernes a las seis, para desbloquear a alguien que necesita trabajar hoy.
NODE_OPTIONS=--openssl-legacy-provider npm start
```

Y conviene decirlo con todas las letras, porque la Fase 0 ya lo advirtió: **esto
no es el fix**. Es reactivar un proveedor criptográfico obsoleto en toda la
sesión de Node para que un hasher de 2016 siga funcionando. Sirve para hoy.

**La refactorización correcta**

Usar la versión de Node de producción, que es la única que garantiza que lo que
compila en tu máquina es lo que compila en el pipeline:

```bash
echo "14.21.3" > .nvmrc
nvm use          # ahora lee el archivo, no tu memoria
```

Y dejarlo declarado en `package.json`, para que el error deje de ser críptico:

```json
"engines": { "node": "14.21.3" }
```

**Prueba de regresión**

Acá no hay test de Jest que valga: el fallo ocurre antes de que exista un
proceso de pruebas. La regresión es una comprobación de entorno que corre antes
del arranque.

```javascript
// scripts/checkNodeVersion.js — se engancha en el prestart del package.json.
const fs = require('fs');

const expected = fs.readFileSync('.nvmrc', 'utf8').trim();
const actual = process.versions.node;

if (actual !== expected) {
  console.error(
    `\n⛔ Este proyecto necesita Node ${expected} y estás en ${actual}.` +
    `\n   Corre "nvm use" desde la raíz del repositorio.\n`
  );
  process.exit(1);
}
```

**Prevención**

El script de arriba en `prestart` y `pretest`, el `.nvmrc` versionado, y el
pipeline usando esa misma versión. Un mensaje de error que dice qué hacer vale
más que cualquier página de documentación.

**Por qué llegó a producción**

No llegó: es un fallo de incorporación, y esos no tienen dueño. Quien ya tiene el
entorno armado no lo reproduce nunca, así que el problema solo lo sufre quien
llega — y quien llega todavía no tiene el crédito para decir que algo del equipo
está mal. El sistema no falló. Falló que la versión de Node viviera en la
memoria colectiva del equipo en lugar de en un archivo del repositorio.

**Si tu causa fue distinta a esta**

Si concluiste *"el `node_modules` quedó corrupto"* y borrarlo y reinstalar te lo
arregló, revisa qué Node tenías activo en ese segundo intento: es muy probable
que un `nvm use` de otra terminal te hubiera cambiado de versión sin que lo
notaras, y estés atribuyendo el arreglo a la reinstalación. Si concluiste *"falta
una dependencia"*, el `npm ci` habría fallado antes, en la instalación, y con
otro mensaje.

</details>

---

## Incidente 02 — En la máquina de al lado compila y en la mía no

> **Fase:** 0 · **Categoría:** Entorno · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 25-35 min

### 🎫 El ticket

Somos dos haciendo exactamente lo mismo. A ella el proyecto le instala y le
compila; a mí me revienta el `npm install` con errores de un tal `node-gyp`.
Probamos borrar la carpeta y reinstalar tres veces, igual. Al final le copié su
carpeta `node_modules` por USB y ahí sí me arrancó. Lo raro es que desde ese día
a ella empezó a pasarle lo mismo que a mí.

**Reportado por:** dos desarrolladores del equipo
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Reproducir, y sobre todo **explicar el fenómeno del USB**: por qué copiar
`node_modules` arregló una máquina y rompió la otra. Ese es el entregable.

> ⚠️ **Este incidente no termina en un commit de código, y no es un defecto del
> enunciado.** Termina en una nota de documentación y en una regla de equipo. Es
> uno de los tres del cuaderno con ese desenlace, y en la vida real es el
> desenlace más frecuente de los problemas de entorno: nadie te va a aceptar un
> *pull request* que arregle la CPU de tu compañero.

### 🔧 Preparación

- **Rama:** `incidente/02`, que restituye `node-sass` en el `package.json`
- **Caos:** no aplica.
- **Datos:** no aplica.
- **Hace falta un dato que no es del repositorio:** dos máquinas con arquitecturas
  distintas, o una máquina y un contenedor. Si solo tienes una, el contenedor
  hace de segunda: `docker run --rm -it -v "$PWD":/app -w /app node:14 bash`.

```bash
git checkout incidente/02
node -p process.arch      # anota esto: es la mitad del diagnóstico
rm -rf node_modules
npm install
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

El error no es de JavaScript. Es de un compilador de C++ que se llama `node-gyp`.
Pregúntate qué hace un compilador de C++ dentro de un proyecto que por ahora solo
pinta tarjetas de rifas, y qué paquete lo está invocando.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El paquete es `node-sass`. Busca su tabla de compatibilidad —qué versión de
`node-sass` con qué versión de Node— y crúzala con lo que te devolvió
`node -p process.arch`.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si `node_modules` contiene binarios compilados para una arquitectura de CPU
concreta, ¿qué es exactamente lo que copiaste por USB, y qué tenía que pasar la
próxima vez que cualquiera de las dos máquinas reinstalara?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados. Anota `process.arch`, `node --version` y el sistema operativo
de las dos máquinas: sin esos tres datos el incidente no se puede contar.}}

**Evidencia observable**
{{La salida de `npm install` desde la primera línea de `node-gyp`.}}

```
{{el error de compilación}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{¿Es del código, de la dependencia, de la máquina, o del procedimiento?}}

**Tu fix**
{{Y si tu conclusión es que no hay fix de código, escríbelo así, con esas
palabras, y di qué entregas en su lugar.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Dos causas encadenadas, y la segunda es la interesante.

La primera: el `package.json` heredado trae **`node-sass`**, que no es JavaScript
sino un envoltorio de LibSass que hay que **compilar** en cada máquina. Para las
combinaciones de Node y arquitectura que tienen binario precompilado, el
instalador lo baja y listo; para las que no —y `arm64` de Apple Silicon es la que
más falta— intenta compilarlo con `node-gyp` y falla.

La segunda, la del USB: **`node_modules` no es código fuente, es un artefacto de
compilación**. Al copiarlo llevaste binarios compilados para una arquitectura a
una máquina de otra. Funcionó por casualidad —o funcionó a medias, hasta que algo
tocó ese binario— y la máquina que lo entregó quedó contaminada en cuanto alguien
volvió a instalar sobre esa carpeta mezclada. Es exactamente el mismo mecanismo
del `node_modules` del host montado dentro de un contenedor, que
`A9-entornos-y-contenedores.md` §7 documenta como el error de entorno que más
caro sale.

**El desenlace, que no es un parche**

El cambio de dependencia —`node-sass` fuera, `sass` (dart-sass, JavaScript puro,
sin compilar nada) adentro— **ya está tomado como decisión del stack en la Fase
0**, y por eso el `package.json` del curso no lo trae. Sobre el código vigente
este bug no puede volver. Lo que este incidente entrega es lo otro, que es lo que
sí se transfiere:

1. **Una nota en `A3-node-y-npm.md`**: qué es un paquete con binario nativo, cómo
   se reconoce en el `package.json` antes de instalarlo, y por qué `sass` le gana
   a `node-sass` en un proyecto congelado.
2. **El `.nvmrc`** con `14.21.3`, que también resuelve la mitad del incidente 01.
3. **Una regla, escrita donde el equipo la lea:** `node_modules` **jamás** se
   copia entre máquinas ni se sube al repositorio. Se reconstruye con `npm ci`,
   que además respeta el `package-lock.json` al pie de la letra.

Y decir *"esto no se arregla con un commit"* es una respuesta profesional
completa. Practícala: cuesta más de lo que parece.

**Prueba de regresión**

No hay test que atrape esto, porque el fallo ocurre antes de que exista una suite.
Lo que hace las veces de regresión es un `npm ci` sobre un `node_modules`
inexistente, corriendo en la arquitectura objetivo dentro del pipeline. Si eso
pasa en limpio, el bug no puede reaparecer por esta puerta.

**Prevención**

`node_modules` en el `.gitignore` (ya lo está), `engines` en el `package.json`,
`.nvmrc` versionado, `npm ci` en vez de `npm install` en cualquier entorno
automatizado, y la sección §7 de `A9` enlazada desde el README para el día que
alguien monte un contenedor.

**Por qué llegó a producción**

No llegó a producción, y aun así costó dos días de trabajo de dos personas. Lo que
lo permitió no fue una decisión mala sino una ausencia: nadie escribió nunca cuál
era el procedimiento para preparar una máquina, así que cada quien improvisó, y
la improvisación más razonable del mundo —*"copiémosle la carpeta que a ella le
anda"*— era justo la que rompía las dos. El análisis acá no es sobre las dos
personas: es sobre un equipo que dejó el procedimiento sin escribir.

**Si tu causa fue distinta a esta**

Si dijiste *"es el proxy corporativo o el registro de npm"*, la instalación habría
fallado al **descargar**, con un error de red y sin llegar nunca a invocar el
compilador. Si dijiste *"falta Python o las herramientas de compilación"*, vas
bien encaminado pero te quedaste a mitad: instalarlas puede hacer que compile, y
eso tapa el síntoma dejándote una dependencia nativa que volverá a morder en la
próxima máquina distinta.

</details>

---

## Incidente 03 — Hago clic en el menú y se recarga toda la aplicación

> **Fase:** 1 · **Categoría:** UI / routing · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-30 min

### 🎫 El ticket

Desde que tocaron el menú de arriba, cada vez que hago clic en "Rifas" la pantalla
se pone en blanco un segundo y después carga. Antes era instantáneo. Y hay algo
peor: si estaba llenando el formulario de una rifa y hago clic en el menú, cuando
vuelvo se me borró todo lo que había escrito.

**Reportado por:** supervisor de ventas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar la línea culpable y aplicar el hotfix. Y como ejercicio
aparte: explicar por qué *"se me borra lo que estaba escribiendo"* es la mejor
frase del ticket, mucho mejor que *"se pone en blanco"*.

### 🔧 Preparación

- **Rama:** `incidente/03`
- **Caos:** no aplica; es determinista y se reproduce el 100% de las veces.
- **Datos:** no aplica; con las rifas de demostración alcanza.

```bash
git checkout incidente/03
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No abras el código todavía. Abre DevTools en la pestaña **Network**, marca
*Preserve log*, y haz clic en el menú. Cuenta cuántas peticiones aparecen y de
qué **tipo** son. Después haz lo mismo navegando desde un enlace de la tabla de
rifas, que no tiene el problema, y compara las dos listas.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/components/Navbar.jsx`. Los enlaces de ese componente no son todos iguales:
míralos uno por uno y agrúpalos en dos familias. El que parpadea está en una de
las dos.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué hace el navegador, por su cuenta y antes de que React se entere de nada, con
un `<a href="/raffles">`? ¿Y qué le queda al árbol de componentes que estaba
montado en memoria después de eso?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados y exactos, incluyendo desde qué pantalla saliste.}}

**Evidencia observable**
{{Lo que muestra Network con *Preserve log* activo, en texto.}}

```
{{las peticiones, con su tipo y su tamaño}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. ¿En qué capa vive: componente, store, epic, mock o build?}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/components/Navbar.jsx`: el enlace del menú es un `<a href="/raffles">` en vez
de un `<Link to="/raffles">`. Es el error común #3 de la Fase 1.

Un ancla común es una instrucción para el **navegador**, no para React Router: el
navegador pide el documento al servidor, recibe el `index.html`, descarta la
página que tenía y arranca de cero. El árbol de React se destruye entero y se
vuelve a montar, el `bundle.js` se vuelve a evaluar, y todo lo que vivía en
memoria —el estado de cada componente, incluido el formulario a medio llenar— se
va con él. Router 5 nunca llega a intervenir: para cuando su `history` podría
haber interceptado el clic, el documento ya se está descargando.

Por eso *"se me borra lo que estaba escribiendo"* es la mejor pista del ticket:
"se pone en blanco" también lo produciría un error de render o una pantalla lenta,
pero **perder el estado en memoria solo pasa si el árbol se destruyó**. El
supervisor, sin saberlo, te entregó el diagnóstico.

> 📝 **Nota de época.** El `Navbar` es de la Era 1 (2019), escrito por el
> contratista contra la fecha del sorteo de diciembre
> (`00-historia-del-sistema.md` §3). Un `<a href>` era lo natural para alguien que
> venía de páginas server-side y estaba aprendiendo Router sobre la marcha.

**Evidencia que lo confirma**

En Network con *Preserve log*: aparece una petición de tipo `document` seguida del
`bundle.js` completo y de los estilos. Navegando con un `<Link>` correcto la lista
no crece ni una fila: cero peticiones, porque no hay nada que pedir.

**Parche mínimo**

```javascript
// src/components/Navbar.jsx
import { Link } from 'react-router-dom';

// ❌ antes: <a href="/raffles">Rifas</a>
// ✅ ahora: el clic lo maneja Router, no el navegador.
<Link to="/raffles">Rifas</Link>
```

**La refactorización correcta**

`NavLink` en vez de `Link` para los enlaces del menú, que además resuelve marcar
cuál está activo sin comparar rutas a mano:

```javascript
<NavLink to="/raffles" activeClassName="active">Rifas</NavLink>
```

Y una regla de lint que prohíba `<a href>` con rutas internas, porque este bug se
reintroduce solo: es una etiqueta de tres caracteres que nadie mira en una
revisión de código sobre estilos.

**Prueba de regresión**

En jsdom un ancla no recarga nada —simplemente no navega—, y eso juega a nuestro
favor: el test falla antes del fix porque la ruta **no cambia**, y pasa después
porque `Link` sí la cambia.

```javascript
// src/components/Navbar.test.jsx
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { MemoryRouter, Route } from 'react-router-dom';
import Navbar from './Navbar';

test('el menú navega sin recargar el documento', () => {
  let currentPath = null;

  render(
    <MemoryRouter initialEntries={['/']}>
      <Navbar />
      <Route path="*" render={({ location }) => {
        currentPath = location.pathname;
        return null;
      }} />
    </MemoryRouter>
  );

  userEvent.click(screen.getByText('Rifas'));

  // Con <a href> la ruta del router no se entera: sigue en "/".
  expect(currentPath).toBe('/raffles');
});
```

**Prevención**

La regla de lint, y un test como el de arriba por cada enlace del menú. Es de los
pocos casos donde una prueba de tres líneas cubre una familia entera de fallos.

**Por qué llegó a producción**

Porque el enlace **funciona**: te lleva a la pantalla correcta. El costo es
invisible en una demostración de dos clics sobre una aplicación recién cargada, y
solo se manifiesta cuando alguien tiene trabajo a medio hacer en memoria — es
decir, con usuarios reales y nunca con quien lo programó. Ninguna revisión de
código mira las etiquetas de un `Navbar` cuando el cambio venía titulado "ajustes
de estilo del menú".

**Si tu causa fue distinta a esta**

Si dijiste *"el servidor está lento"*, mide: el parpadeo es idéntico con el
servidor local y con el de UAT, porque el costo no es la red sino volver a montar
la aplicación entera. Si dijiste *"falta memoización"*, ojo con la distinción que
vale para todo el curso: un **re-render** es que React vuelva a pintar un
componente vivo; un **remontaje** es que lo destruya y lo cree de nuevo. La
memoización actúa sobre lo primero y no puede hacer nada contra lo segundo.

</details>

---

## Incidente 04 — Entro al detalle de otra rifa y sigo viendo la anterior

> **Fase:** 1 · **Categoría:** UI / routing · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min

### 🎫 El ticket

Tengo la lista de rifas. Abro la de Navidad, la miro, vuelvo atrás y abro la de
Año Nuevo… y me sigue mostrando la de Navidad. Arriba, en la barra del navegador,
dice que estoy en la 2, pero abajo el nombre y los datos son los de la 1. Si
aprieto F5 ahí sí aparece la correcta. Yo creo que se confunde por los nombres
parecidos.

**Reportado por:** vendedor de rifas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir y decidir **cuál de dos causas plausibles** lo está provocando. Las dos
producen exactamente este síntoma y las dos se "arreglan" con cambios distintos
que funcionan. El entregable no es el parche: es la evidencia que descarta una de
las dos.

Y de paso, descartar la teoría del vendedor. Los tickets suelen traer una, casi
siempre es incorrecta, y desmontarla con evidencia en vez de ignorarla es parte
del trabajo.

### 🔧 Preparación

- **Rama:** `incidente/04`
- **Caos:** no aplica; determinista.
- **Datos:** hacen falta al menos dos rifas en `mock/raffles.js` con nombres bien
  distintos —`Rifa de Navidad` con `id: 1` y `Rifa de Año Nuevo` con `id: 2`— para
  que el síntoma sea inconfundible. La rama ya las trae.

```bash
git checkout incidente/04
npm start
# Navega: /raffles → detalle de la 1 → atrás → detalle de la 2
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

React DevTools, pestaña **Components**, selecciona `RaffleDetailPage` y déjala
seleccionada mientras navegas de una rifa a la otra. Mirá dos cosas **al mismo
tiempo** en el panel derecho: lo que trae `useParams` y lo que hay en el estado.
Uno de los dos cambia y el otro no. Cuál es cuál te dice casi todo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Activa **"Highlight updates when components render"** en las opciones de React
DevTools y navega otra vez. La pregunta que separa las dos causas es una sola:
¿el componente **se re-renderiza** al cambiar de rifa, o ni se entera?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el componente sí se re-renderiza y el estado sigue viejo: ¿quién tenía que
haber actualizado ese estado, y cuántas veces corre en la vida de un componente
la función que le pasas a `useState`?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados. Di explícitamente si navegaste con los enlaces de la lista o
escribiendo la URL a mano: no es lo mismo y una de las dos no reproduce.}}

**Evidencia observable**
{{Lo que muestra React DevTools: params y estado, lado a lado, antes y después de
navegar. Y si el borde de *highlight* se encendió o no.}}

```
{{params.id = ...   ·   state.raffle = ...}}
```

**Hipótesis**
- ❌ Descartada: {{cuál de las dos causas plausibles descartaste, y con qué}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta. Y si encontraste más de
un cambio que hace desaparecer el síntoma, anótalos todos: eso importa.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/pages/RaffleDetailPage.jsx` guarda la rifa en estado local, inicializado con
el `id` de la URL, y nadie lo vuelve a tocar:

```javascript
// ❌ El inicializador de useState corre UNA sola vez, en el primer montaje.
const { id } = useParams();
const [raffle, setRaffle] = useState(findRaffle(id));
```

Al navegar de `/raffles/1` a `/raffles/2`, Router 5 renderiza el mismo componente
en la misma posición del árbol, así que React **reutiliza la instancia**: no la
desmonta, la vuelve a renderizar con parámetros nuevos. `useParams` devuelve
`"2"`, el componente se re-renderiza… y `useState` ignora por completo el
argumento que le pasas a partir del segundo render. El estado se quedó con la
rifa 1, para siempre.

Es, textualmente, el "rompe a propósito" de la pieza forense de la Fase 1.

Y explica el F5: recargar destruye la aplicación y la monta de nuevo, así que el
inicializador vuelve a correr —esta vez con el `id` correcto— y todo parece
funcionar. **Que un F5 lo arregle es la firma del estado que no se sincroniza.**

**La otra causa plausible, y cómo se descartan**

La segunda hipótesis razonable es que el componente **ni siquiera se re-renderiza**
porque React lo está tratando como "el mismo" nodo y algo aguas arriba —una lista
con `key={index}`, un `React.memo` mal puesto— le impide enterarse del cambio.
Produce el mismo síntoma exacto.

Se separan con una sola observación, la de la pista 2: **activa *Highlight
updates* y navega**. Si el borde se enciende, el componente se re-renderizó y la
causa es el estado congelado. Si no se enciende, ni llegó a re-renderizar y hay
que subir en el árbol.

Lo que vuelve formativo a este incidente es que **los dos fixes funcionan**. Poner
`key={id}` en la `Route` fuerza a React a desmontar y montar de nuevo, el
inicializador vuelve a correr y el síntoma desaparece — sin que hayas tocado la
causa. Eso es tapar el problema una capa más arriba, y se paga el día que el
componente tenga además un formulario o un filtro en estado local: el remontaje se
los lleva puestos, y vas a estar depurando el incidente 03 otra vez, con otra
puerta de entrada.

**Parche mínimo**

```javascript
// El estado sigue existiendo, pero ahora alguien lo sincroniza.
useEffect(() => {
  setRaffle(findRaffle(id));
}, [id]);
```

**La refactorización correcta**

No guardar en estado algo que es **derivado** de la URL. La rifa no es información
del usuario: es una función del `id`, y se calcula en el render.

```javascript
const { id } = useParams();
const raffle = findRaffle(id);   // sin useState, sin useEffect, sin sincronizar
```

El estado local se reserva para lo que el usuario cambia y el sistema no puede
recalcular. Esta es la versión de una línea de una regla que vale para todo el
curso, y que en Fase 4 vuelve con el store de por medio.

**Prueba de regresión**

```javascript
// src/pages/RaffleDetailPage.test.jsx
import { render, screen } from '@testing-library/react';
import { MemoryRouter, Route } from 'react-router-dom';
import RaffleDetailPage from './RaffleDetailPage';

test('al cambiar el id de la ruta, muestra la rifa nueva', () => {
  const { rerender } = render(
    <MemoryRouter initialEntries={['/raffles/1']}>
      <Route path="/raffles/:id" component={RaffleDetailPage} />
    </MemoryRouter>
  );
  expect(screen.getByText('Rifa de Navidad')).toBeInTheDocument();

  // Sin desmontar: es exactamente lo que hace Router al navegar.
  rerender(
    <MemoryRouter initialEntries={['/raffles/2']}>
      <Route path="/raffles/:id" component={RaffleDetailPage} />
    </MemoryRouter>
  );
  expect(screen.getByText('Rifa de Año Nuevo')).toBeInTheDocument();
});
```

El detalle que hace útil este test es que **no desmonta**. Un test que renderice
dos veces desde cero pasa incluso con el bug presente, y te deja tranquilo con el
error adentro.

**Prevención**

Una regla de revisión fácil de aplicar: si el argumento de un `useState` depende
de props, de `useParams` o del store, hay que justificar por qué no se calcula en
el render. Y si de verdad hace falta copiarlo a estado, el `useEffect` que lo
sincroniza va pegado, en la línea siguiente, no doscientas líneas abajo.

**Por qué llegó a producción**

Porque el F5 lo tapa, y quien lo escribió probó recargando. El bug solo aparece
navegando dentro de la aplicación, que es justamente lo que hace un usuario y lo
que no hace quien está programando con el editor al lado y guardando cada treinta
segundos.

Hay además una razón de fondo, y es de época: copiar datos a estado local en el
montaje es el patrón natural de un *class component* de la Era 1, donde se hacía
en `componentDidMount`. El error clásico de entonces era olvidar
`componentDidUpdate`; el de hoy es olvidar el `useEffect` con su dependencia. **Es
el mismo bug con otra sintaxis**, y la traducción entre las dos formas está en
`A5-class-components-vs-hooks.md`.

**Si tu causa fue distinta a esta**

Si tu diagnóstico fue *"los nombres se confunden"*, esa era la teoría del ticket:
cámbiale el nombre a una de las dos rifas por algo irreconocible y el síntoma
sigue igual. Descartada con evidencia, en treinta segundos. Si dijiste *"falta un
`exact` en la ruta"*, mira la URL: el error común #2 de la Fase 1 te dejaría
viendo el **listado**, no un detalle equivocado. Y si tu fix fue `key={id}` en la
`Route` y funcionó, lee otra vez el apartado de arriba: funciona, no es la causa,
y tiene un costo que hoy no se nota.

</details>
L1EOF
wc -l /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L1.md

# --- 2026-09-10T01:54:10 · Measure each drafted incident
awk '/^## Incidente/{if(t)print t" -> "n; t=$0; n=0} {n++} END{print t" -> "n}' /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L1.md

# --- 2026-09-10T01:54:34 · Splice L1 into the notebook and correct the length scale
SCR=/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad
python3 - <<PY
import io
p="cuaderno-incidentes.md"; s=io.open(p,encoding="utf-8").read()
new=io.open("$SCR/L1.md",encoding="utf-8").read().rstrip("\n")
start=s.index("## Incidente 01 — {{")
end=s.index("# 🪞 Retrospectiva del mes")
s=s[:start]+new+"\n\n---\n\n"+s[end:]
io.open(p,"w",encoding="utf-8").write(s); print("spliced")
PY
python3 - <<'PY'
import io
p="prompts/plantilla-de-incidente.md"; s=io.open(p,encoding="utf-8").read()
old="""| Dificultad | Líneas | Tiempo sugerido |
|---|---|---|
| 🟢 fácil | 110-140 | 20-30 min |
| 🟡 intermedio | 150-190 | 30-45 min |
| 🟠 difícil | 190-230 | 45-70 min |
| 🔴 y ⭐ | 250-300 | 60-90 min |"""
new="""| Dificultad | Líneas | Tiempo sugerido |
|---|---|---|
| 🟢 fácil | 150-200 | 20-30 min |
| 🟡 intermedio | 190-240 | 30-45 min |
| 🟠 difícil | 220-270 | 45-70 min |
| 🔴 y ⭐ | 260-310 | 60-90 min |

> 📝 **Por qué el piso es 150 y no 110.** El andamiaje de la estructura
> —encabezado, ticket, qué se te pide, preparación, tres pistas, la investigación
> vacía y los siete bloques de la solución— cuesta unas noventa líneas antes de
> escribir una sola idea. Un incidente 🟢 de ciento veinte líneas no es más breve:
> es uno al que le faltan bloques. El cuaderno del track BE, con la misma
> estructura, tiene su mínimo en 188."""
assert s.count(old)==1
io.open(p,"w",encoding="utf-8").write(s.replace(old,new)); print("escala corregida")
PY
grep -c "^## Incidente" cuaderno-incidentes.md; wc -l cuaderno-incidentes.md; grep -n "{{" cuaderno-incidentes.md | grep -v "Esto lo escribes\|Pasos numerados\|qué creíste\|la que sobrevivió\|Archivo y línea\|El parche mínimo\|el error\|payload\|params.id\|las peticiones\|el volcado\|el error de\|Y si tu conclusión\|Lo que muestra\|¿En qué capa\|¿Es del código\|Di explícitamente\|El detalle\|cuál de las dos\|Anota\|La salida" | head

# --- 2026-09-10T01:54:44 · Read section 6 of phases 2 and 3
sed -n '601,645p' 02-autenticacion-minima.md; echo "============ FASE 03 §6"; sed -n '694,742p' 03-mock-api-express-caos.md

# --- 2026-09-10T01:59:05 · Draft incidents 05-08
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L2.md <<'L2EOF'
## Incidente 05 — Las peticiones salen sin token y el servidor las rebota

> **Fase:** 2 · **Categoría:** Autenticación · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 30-40 min

### 🎫 El ticket

Entro con mi usuario y mi contraseña y me deja pasar sin problema: veo el menú y
arriba a la derecha aparece mi nombre. Pero apenas hago clic en cualquier rifa me
dice que no tengo permiso. Es raro, porque acabo de entrar. Probé cerrando y
volviendo a entrar y pasa lo mismo.

**Reportado por:** vendedor de rifas
**Ambiente:** desarrollo

### 🎯 Qué se te pide

Reproducir y localizar la capa. Hay una contradicción en el sistema —dos fuentes
que dicen cosas distintas sobre la misma sesión— y encontrarla es el noventa por
ciento del trabajo. El fix es de una línea.

### 🔧 Preparación

- **Rama:** `incidente/05`
- **Caos:** `off`. Este bug es determinista y con caos encendido se confunde con
  el incidente 08: apágalo antes de empezar.
- **Datos:** el `db.json` de la fase, con al menos un usuario válido.

```bash
git checkout incidente/05
CHAOS_LEVEL=off npm run mock
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Hay dos lugares donde este sistema guarda la verdad sobre tu sesión, y todavía no
sabes si dicen lo mismo. Uno es el store: míralo en Redux DevTools después de
loguearte. El otro es lo que efectivamente sale por el cable: míralo en Network,
en **Request Headers** —no en Response—, de cualquier petición a una rifa.
Compáralos antes de abrir un archivo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/api/apiClient.js`. El interceptor de petición lee el token de algún lado.
No mires *qué* lee: mira **en qué momento de la vida del módulo** se ejecuta esa
lectura.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Cuántas veces se ejecuta el cuerpo de un módulo de JavaScript, y cuántas veces se
ejecuta la función que le pasas a `interceptors.request.use`? ¿Y qué había en el
store la única vez que corrió la primera?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados y exactos.}}

**Evidencia observable**
{{Los dos lados de la contradicción, uno al lado del otro: lo que dice
`state.auth.token` en Redux DevTools y lo que dice el header `Authorization` en
Network.}}

```
{{store: ...    ·    Request Headers: ...}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. ¿En qué capa vive: componente, store, epic, interceptor o mock?}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/api/apiClient.js`. El token se lee **en el cuerpo del módulo**, no dentro del
interceptor:

```javascript
// ❌ Esto corre UNA vez: cuando alguien importa este módulo por primera vez.
const token = store.getState().auth.token;

apiClient.interceptors.request.use((config) => {
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});
```

El cuerpo de un módulo de JavaScript se evalúa una sola vez, en el primer
`import`. Y `apiClient` se importa cuando arranca la aplicación —mucho antes de
que exista un usuario—, así que `token` queda congelado en `null` para siempre. El
interceptor, en cambio, corre en **cada** petición… leyendo una variable que ya no
va a cambiar nunca.

De ahí la contradicción que la pista 1 te hace ver: el store tiene el token
correcto (el login funcionó, `auth/login/fulfilled` lo dejó ahí) y la petición
sale sin `Authorization`. Es el error común #1 de la Fase 2.

> 🧠 **La forma del bug, que vale más que el bug.** "Leí el valor una vez y lo
> guardé" es una familia entera de fallos, no un caso. Vas a reencontrarla en el
> incidente 04 con `useState`, y en el 19 con `useMemo`. Cambia la sintaxis, no el
> error: **capturar un valor que todavía no existe y no volver a preguntar.**

**Parche mínimo**

```javascript
apiClient.interceptors.request.use((config) => {
  // Ahora se lee en cada petición, que es cuando importa.
  const token = store.getState().auth.token;
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});
```

**La refactorización correcta**

Que el interceptor no conozca el store. Un `getToken()` exportado por el módulo de
autenticación es el único que sabe dónde vive el token, y el día que se mueva a
`sessionStorage` —o a una cookie, o a un contexto— cambia un archivo y no diez:

```javascript
import { getToken } from '../features/auth/authService';

apiClient.interceptors.request.use((config) => {
  const token = getToken();
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});
```

**Prueba de regresión**

```javascript
// src/api/apiClient.test.js
import apiClient from './apiClient';
import store from '../store';
import { loginSucceeded } from '../features/auth/authSlice';

test('el interceptor adjunta el token que hay en el store AHORA', async () => {
  // El cliente ya se importó (y con el bug, ya capturó null). Recién ahora
  // aparece la sesión: es exactamente el orden de la vida real.
  store.dispatch(loginSucceeded({ user: { id: 1 }, token: 'tok-123' }));

  const config = await apiClient.interceptors.request.handlers[0].fulfilled({
    headers: {},
  });

  expect(config.headers.Authorization).toBe('Bearer tok-123');
});
```

El detalle que hace útil este test es el **orden**: el módulo se importa antes del
login. Un test que despache el login primero pasa incluso con el bug adentro.

**Prevención**

Una regla de revisión concreta: `store.getState()` no se llama nunca en el nivel
superior de un módulo. Si aparece ahí, o está congelando un valor o está creando
una dependencia circular con el store; las dos cosas terminan mal.

**Por qué llegó a producción**

Por una optimización que nadie pidió. Leer el store en cada petición parecía
derrochador —"¿para qué preguntar mil veces lo mismo?"— y sacarlo afuera parecía
la versión limpia. Cuesta nanosegundos y compra correctitud. En un sistema con
sesión, **el estado es justamente lo que cambia**, y guardar una foto de algo que
cambia es la definición del bug.

Y sobrevivió porque el login sí funciona: la pantalla se ve bien, el nombre
aparece, no hay error rojo en ningún lado. Lo único roto está en un header que
nadie mira si no lo va a buscar.

**Si tu causa fue distinta a esta**

Si dijiste *"el backend no está validando bien el token"*, abre Request Headers:
el header no está. No se puede validar mal algo que no llegó. Si dijiste *"es
CORS"*, un fallo de CORS trae su propio mensaje en la consola y bloquea la
petición antes de que salga; acá la petición sale, llega y la rechazan con un
`401` bien formado. Y si tu fix fue guardar el token en una variable global que
el login actualiza, funciona — pero acabas de crear una segunda fuente de verdad
que se va a desincronizar del store el día que alguien despache `logout` sin
pasar por tu función.

</details>

---

## Incidente 06 — Cerré sesión pero la pantalla sigue mostrando mi usuario

> **Fase:** 2 · **Categoría:** Autenticación · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min

### 🎫 El ticket

Hago clic en "Cerrar sesión" y arriba a la derecha me sigue apareciendo mi nombre.
Si después hago clic en cualquier cosa me manda al login, pero el nombre sigue ahí
arriba, como si no me hubiera ido. Una vez, además, la pestaña se quedó titilando
sola y tuve que cerrarla a la fuerza. Me preocupa que en el kiosco compartido
quede la sesión de otro.

**Reportado por:** supervisor de ventas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir los dos síntomas —el nombre que se queda y el titileo— y decidir una
cosa antes de tocar código: **¿es un bug o son dos?** El entregable es esa
respuesta, con evidencia. Después, el fix de lo que corresponda.

Este incidente se resuelve mirando, no leyendo código. Si terminas con el editor
abierto antes de haber mirado Redux DevTools, vuelve atrás.

### 🔧 Preparación

- **Rama:** `incidente/06`
- **Caos:** `off`.
- **Datos:** el `db.json` de la fase. Loguéate con un usuario cuyo nombre se vea
  claramente en la barra superior.

```bash
git checkout incidente/06
CHAOS_LEVEL=off npm run mock
npm start
# Logueate, mira la barra superior, y recién ahí cierra sesión.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Redux DevTools, pestaña Redux. Cierra sesión con el panel abierto, selecciona la
acción que se despachó y abre la vista **Diff**. Esa vista te dice exactamente qué
claves del estado cambiaron. Cuéntalas y compáralas con las que *deberían* haber
cambiado.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Para el primer síntoma: el reducer de `logout` en `src/features/auth/authSlice.js`,
y qué campo lee la barra superior para pintar el nombre. Para el segundo: quién
envuelve la ruta `/login` en `src/App.jsx`. Son dos archivos distintos, y esa es
media respuesta.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si `selectIsAuthenticated` mira `token` y la barra superior mira `user`, ¿qué pasa
cuando el `logout` limpia uno solo de los dos? Y por separado: si `/login` exige
sesión para poder mostrarse, ¿a dónde te manda cuando no tienes sesión?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados para cada uno de los dos síntomas. Si uno de los dos no lo
lograste reproducir, dilo: puede que dependa de por dónde estabas navegando.}}

**Evidencia observable**
{{El *Diff* de Redux DevTools sobre la acción de logout, en texto.}}

```
{{qué claves cambiaron y cuáles no}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{¿Una o dos? Nómbralas por separado, con archivo y línea cada una.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

Son **dos bugs distintos** que el mismo clic destapa, y confundirlos en uno solo
lleva a un fix que arregla la mitad.

**Bug A — el logout limpia de a un campo.** `src/features/auth/authSlice.js`:

```javascript
// ❌ Se limpió lo que hacía falta para "salir"… y nada más.
logout(state) {
  state.token = null;
}
```

`selectIsAuthenticated` mira `token`, así que la protección de rutas funciona
perfecto y te saca. Pero la barra superior lee `state.auth.user`, que sigue con
tus datos adentro. Dos consumidores del mismo estado, cada uno mirando una clave
distinta, y el logout solo se acordó de una. El *Diff* de DevTools lo muestra en
un segundo: una sola clave en verde.

Y la preocupación del supervisor es correcta y no es paranoia: en un kiosco
compartido, el nombre del vendedor anterior queda a la vista. No es una fuga de
datos grave, pero es exactamente el tipo de detalle por el que un cliente pierde
la confianza en un sistema.

**Bug B — el titileo.** `src/App.jsx`: la ruta `/login` quedó envuelta en
`PrivateRoute`. Sin sesión, `PrivateRoute` te redirige a `/login`… que exige
sesión… que te redirige a `/login`. Es el error común #2 de la Fase 2, y explica
por qué el nombre se queda **visible**: sin el bucle, el redirect es tan rápido que
apenas se alcanza a ver.

> 📝 **Nota de época.** El `authSlice` es de la Era 2 (2020-2021), escrito con
> Redux Toolkit por el equipo interno. Immer permite mutar el borrador campo por
> campo, y eso —que es una comodidad enorme— hace que "limpiar el estado" se
> escriba naturalmente como una lista de asignaciones. Cada campo nuevo que alguien
> agregue al slice de aquí en adelante nace olvidado en el logout.

**Parche mínimo**

```javascript
// authSlice.js — que no quede nada.
logout() {
  return initialState;
}
```

```javascript
// App.jsx — /login es pública, siempre.
<Route path="/login" component={LoginPage} />
```

**La refactorización correcta**

El parche de arriba **ya es** la corrección correcta para el bug A, y conviene
notarlo porque no siempre pasa: `return initialState` no arregla un campo, arregla
la familia entera —incluidos los campos que todavía no existen—. Cuando el parche
mínimo y el refactor coinciden, se aplica sin pensarlo.

Lo que sí queda pendiente es más grande y no se paga acá: **el estado de sesión no
sobrevive a un F5** (deuda 💸 de esta fase), así que hoy recargar la página es un
logout involuntario. La persistencia llega en la Fase 3, y con ella un tercer
hermano de este bug: limpiar el store y olvidarse del almacenamiento.

**Prueba de regresión**

```javascript
// src/features/auth/authSlice.test.js
import reducer, { logout, initialState } from './authSlice';

test('logout deja el estado exactamente como al principio', () => {
  const loggedIn = {
    ...initialState,
    user: { id: 7, name: 'Ana' },
    token: 'tok-123',
  };

  // Comparar contra initialState ENTERO, no campo por campo: así el test
  // también protege los campos que alguien agregue el año que viene.
  expect(reducer(loggedIn, logout())).toEqual(initialState);
});
```

**Prevención**

Dos reglas baratas. La primera: todo reducer que "limpia" devuelve el
`initialState` completo, nunca una lista de asignaciones. La segunda: un test que
recorra las rutas y verifique que `/login` no está envuelta en `PrivateRoute` —una
línea, y cierra para siempre una clase de bug que cuelga la pestaña del usuario.

**Por qué llegó a producción**

Porque el logout **cumple su objetivo**: te saca. Quien lo escribió probó lo que
había que probar —cerrar sesión y comprobar que ya no se puede entrar a una rifa—
y eso funciona. Nadie mira el resto del estado después de una acción que "anduvo".

El bucle de `/login` es de la misma familia: se agregó la protección de rutas de
una pasada, envolviendo todo lo que había, y `/login` cayó adentro por estar en la
misma lista. Es un error de copiar y pegar en un archivo de configuración, del
tipo que ninguna revisión de código detecta porque el diff se ve perfectamente
razonable.

**Si tu causa fue distinta a esta**

Si dijiste *"no se limpia el `localStorage`"*, en esta fase todavía no hay
persistencia —llega en la Fase 3—, así que no puede ser eso; pero si tu aplicación
ya la tiene porque avanzaste, acabas de encontrar el tercer hermano y vale la pena
anotarlo. Si dijiste *"falta un `window.location.reload()` después del logout"*,
funciona y es un martillazo: recargar la aplicación entera para limpiar dos campos
del store descarta también todo lo demás, y te va a morder en la Fase 4 cuando
haya un formulario abierto. Y si diagnosticaste solo uno de los dos bugs, no está
mal: quiere decir que reprodujiste uno solo. Vuelve y busca el otro.

</details>

---

## Incidente 07 — A veces no carga y no dice nada

> **Fase:** 3 · **Categoría:** Integración · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 40-50 min

### 🎫 El ticket

A veces no carga y no dice nada. Me pasa como una de cada cinco veces, no sé bien.
Abro la lista de rifas y me quedo mirando la pantalla, y no aparece nada: ni las
rifas ni un error ni un cartel ni nada. Si recargo, generalmente sale bien. A mi
compañera también le pasa pero menos.

**Reportado por:** vendedor de rifas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducirlo **cuando tú quieras**, no cuando le toque al azar. Ese es el
entregable principal: un procedimiento determinista. Después, localizar la capa y
aplicar el fix.

> 🧭 **Este es el ticket vago canónico del curso**, y por eso conviene decir en voz
> alta lo que va a sonar raro: *"a veces"* y *"una de cada cinco"* son los dos
> datos **más valiosos** del reporte, no sus defectos. Una frecuencia es una pista
> sobre el mecanismo. Un reporte que dijera "no carga" a secas sería mucho peor.

### 🔧 Preparación

- **Rama:** ninguna. Este incidente no necesita código roto: el bug ya está en la
  aplicación que construiste, esperando la condición que lo despierta.
- **Caos:** `CHAOS_LEVEL=high` en el mock del puerto `3001`. **Obligatorio.** Con
  `low` tarda mucho en aparecer y con `off` no aparece jamás.
- **Datos:** el `db.json` de la fase, con varias rifas cargadas.

```bash
CHAOS_LEVEL=high npm run mock
npm start
# Abre /raffles y recarga varias veces hasta que te toque.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Antes de la aplicación, mira **el mock**. "Una de cada cinco veces" es una
probabilidad, y hay un archivo en este proyecto donde esa probabilidad está
escrita y donde se decide qué tipo de fallo toca. Encontrarlo convierte el azar en
un interruptor.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Network, con la columna **Status** y la columna **Time** a la vista. Ordena por
Time y reproduce el fallo. Vas a encontrar una petición que no tiene status,
porque no terminó. Ahora la pregunta es de la otra orilla: ¿cuánto tiempo está
dispuesto a esperar el cliente?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Cuál es el valor por defecto de `timeout` en axios, y qué significa ese valor?
¿Y en qué estado se queda un `createAsyncThunk` cuya promesa nunca se resuelve ni
se rechaza?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Acá lo que se evalúa es que sea determinista. "Recargar hasta que pase" no es
un procedimiento de reproducción: es esperar.}}

**Evidencia observable**
{{La fila de Network de la petición que no termina, y el estado del store mientras
tanto.}}

```
{{status, time, y qué dice state.raffles.loading}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Ojo: puede que el archivo culpable sea uno donde *falta* algo.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Cómo se reproduce sin esperar al azar**

En `mock/server.js`, haz que el selector de fallo devuelva siempre el que te
interesa:

```javascript
// Temporalmente, para investigar. Revertir al terminar.
function pickFailureType() {
  return 'timeout';
}
```

Ahora el fallo es un interruptor. **Convertir "a veces" en "siempre" es la primera
mitad de cualquier investigación de intermitencias**, y casi nunca requiere tocar
la aplicación: requiere entender qué la rodea.

**Causa raíz**

El mock, con `CHAOS_LEVEL=high`, inyecta un fallo de tipo *timeout*: recibe la
petición y sencillamente **no responde nunca**. Del otro lado, `src/api/apiClient.js`
crea el cliente de axios sin la opción `timeout`, y el valor por defecto de axios
es `0`, que significa *esperar indefinidamente*.

La consecuencia en cadena: la promesa del `createAsyncThunk` no se resuelve ni se
rechaza, la acción `raffles/fetchAll/pending` queda como la última despachada,
`loading` se queda en `true` y `error` en `null`. La pantalla no muestra rifas
porque no llegaron, y no muestra un error porque —desde el punto de vista de la
aplicación— **no hubo ningún error: la petición sigue en curso**.

> 🧠 **El silencio no es un olvido, es un estado.** La lectura fácil de este bug es
> "la aplicación se olvidó de avisar". La correcta es que la aplicación está
> reportando fielmente lo que cree: que sigue cargando. El defecto no está en el
> mensaje que falta: está en que nadie decidió cuánto es demasiado.

Es el error común #2 de la Fase 3.

**Parche mínimo**

```javascript
// src/api/apiClient.js
const apiClient = axios.create({
  baseURL: process.env.REACT_APP_API_URL,
  timeout: 5000,   // pasado este punto, es un error y se trata como tal
});
```

Con eso axios aborta la petición con `ECONNABORTED`, el thunk cae en `rejected`,
`loading` vuelve a `false` y la pantalla puede mostrar el error que ya sabía
mostrar.

**La refactorización correcta**

Dos capas más, ninguna de las cuales se paga en esta fase:

1. Un interceptor de respuesta que traduzca `ECONNABORTED` a un mensaje que un
   vendedor entienda —"el servidor no respondió a tiempo, intenta de nuevo"— en
   vez del texto crudo de axios.
2. Reintento con espera creciente para las lecturas, que son idempotentes y se
   pueden repetir sin riesgo. Eso **no** se hace acá: requiere cancelación de
   verdad, y la cancelación de verdad es RxJS. Llega en la Fase 7, con `timer` y
   `takeUntil`.

**Prueba de regresión**

```javascript
// src/features/raffles/raffleSlice.test.js
import MockAdapter from 'axios-mock-adapter';
import apiClient from '../../api/apiClient';
import store from '../../store';
import { fetchAllRaffles } from './raffleSlice';

test('una petición que nunca responde termina en rejected, no colgada', async () => {
  const mock = new MockAdapter(apiClient);
  mock.onGet('/raffles').timeout();   // simula exactamente el caos del mock

  await store.dispatch(fetchAllRaffles());

  const state = store.getState().raffles;
  expect(state.loading).toBe(false);   // con el bug, se queda en true para siempre
  expect(state.error).not.toBeNull();
});
```

**Prevención**

El `timeout` va en la **creación del cliente**, no en cada llamada: puesto por
llamada, el primer endpoint que alguien agregue mañana nace sin él. Y toda
pantalla que cargue datos necesita tres estados dibujados, no dos: cargando,
error, y vacío. La mayoría de las pantallas legacy tienen dos, y el tercero es el
que se descubre en producción.

**Por qué llegó a producción**

Porque en desarrollo todo responde en tres milisegundos, y un `timeout` es
invisible mientras no haga falta. Pero el mecanismo de fondo merece un párrafo
propio: **este bug no se escribió, se dejó de escribir.** No hay una línea
equivocada que un revisor pudiera haber señalado; hay una opción ausente cuyo
valor por defecto —"esperar para siempre"— nadie eligió conscientemente. Los
errores de configuración por omisión son los más difíciles de encontrar en una
revisión de código, porque no aparecen en el diff.

Y llegó también porque el síntoma es amable: no hay pantalla roja, no hay
excepción, no hay nada en la consola. Solo un usuario esperando, que después de un
rato recarga y sigue trabajando. Nadie abre un ticket por eso hasta que pasa
cincuenta veces por día.

**Si tu causa fue distinta a esta**

Si dijiste *"el servidor está lento"*, mídelo: lento tiene un final, esto no lo
tiene. Deja la pestaña abierta diez minutos y la petición va a seguir ahí. Si
dijiste *"es un 500 que no se está manejando"*, el 500 del caos **sí** llega, sí
rechaza el thunk y sí deja rastro en la consola: es un fallo distinto del mismo
mock, y compararlos lado a lado es un ejercicio de veinte minutos que vale la
pena. Y si tu fix fue poner un `setTimeout` en el componente para mostrar un
cartel a los cinco segundos, tapaste el síntoma con precisión quirúrgica: la
petición sigue viva, sigue ocupando una conexión y va a resolver —o no— cuando se
le antoje, con el usuario ya en otra pantalla.

</details>

---

## Incidente 08 — Me saca a login al azar mientras estoy trabajando

> **Fase:** 3 · **Categoría:** Integración · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min
> · Hermano del incidente `be-08`, con otra causa raíz

### 🎫 El ticket

Estoy cargando una rifa nueva y de golpe me tira a la pantalla de login, sin
avisar nada. No pasa siempre, pasa de a ratos. Pierdo todo lo que había escrito y
tengo que empezar de nuevo. Vuelvo a entrar con la misma clave de siempre y entra
perfecto, así que mi usuario está bien. Alguien me dijo que "se cae la sesión",
pero no sé qué quiere decir eso.

**Reportado por:** vendedor de rifas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducirlo de forma controlada y responder una pregunta incómoda: **¿es un bug
del sistema, o el sistema haciendo exactamente lo que debe?** Y si es lo segundo
—adelanto: en parte lo es—, decidir qué se arregla de todos modos.

### 🔧 Preparación

- **Rama:** ninguna; el comportamiento ya está en tu aplicación.
- **Caos:** `CHAOS_LEVEL=high` en `3001`. **Obligatorio**: el `401` aleatorio solo
  lo inyecta el caos alto sobre rutas protegidas.
- **Datos:** el `db.json` de la fase. Empieza el formulario de una rifa nueva y
  escribe algo antes de que te eche: parte del incidente es medir qué se pierde.

```bash
CHAOS_LEVEL=high npm run mock
npm start
# Abre el formulario de rifa nueva, escribe, y sigue navegando hasta que te saque.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Hay dos capas capaces de producir esto: la que **emite** el `401` y la que
**reacciona** al `401`. Empieza por la primera, y hazlo con la herramienta de la
Fase 2: agarra el `request-id` que el interceptor escribe en la consola y búscalo
en el log del mock. Vas a ver quién lo generó y por qué.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`mock/server.js`: el middleware de caos, la lista `PROTECTED_ROUTES` y el valor de
`CHAOS_LEVEL`. Después, y solo después, el interceptor de respuesta en
`src/api/apiClient.js`.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si el `401` es deliberado y correcto —y lo es—, entonces el defecto está en otra
parte. ¿Qué perdió exactamente el usuario, qué no se le dijo, y a dónde volvió
después de loguearse de nuevo?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, con el `CHAOS_LEVEL` que usaste. Anota también qué habías
escrito en el formulario antes de que te echara.}}

**Evidencia observable**
{{El `request-id` de la consola y su línea correspondiente en el log del mock.
Esos dos, juntos, son la prueba de quién emitió el `401`.}}

```
{{consola del navegador   ·   log del mock}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Y una respuesta explícita: ¿el sistema se equivocó, o hizo lo correcto?}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El `401` lo inyecta a propósito el middleware de caos de `mock/server.js` sobre las
rutas de `PROTECTED_ROUTES`, para simular un token vencido. Eso **no es el bug**:
es la Fase 3 haciendo su trabajo, y es el error común #3 de esa fase. Un backend
real hace exactamente lo mismo cuando la sesión expira.

El defecto está una capa más allá, en cómo reacciona el interceptor de respuesta:
despacha `logout`, redirige a `/login` y ahí termina su participación. No dice por
qué, no recuerda a dónde ibas, y no hace nada con lo que estabas escribiendo.

> 🧠 **El sistema detectó bien y comunicó mal.** Es una distinción que vale para
> toda tu carrera: la detección y la comunicación son dos responsabilidades
> separadas, y la segunda casi nunca se prueba. Un `401` correctamente manejado que
> deja al usuario sin explicación y sin su trabajo sigue siendo un incidente,
> aunque cada línea de código haga lo que dice.

> 📝 **Nota de época.** El interceptor global es de la Era 2 (2020-2021). Entonces
> la sesión duraba ocho horas y un `401` inesperado era tan raro que ocuparse de
> "avisar bien" parecía sobre-ingeniería. La suposición no era tonta: era correcta
> para el mundo de 2020, y dejó de serlo cuando el sistema empezó a vivir en un
> kiosco con red mala.

**Parche mínimo**

Que el redirect lleve el motivo y el origen:

```javascript
// src/api/apiClient.js — en el interceptor de respuesta, ante un 401.
store.dispatch(logout());
history.replace('/login', {
  reason: 'session-expired',
  from: history.location.pathname,
});
```

Y que `LoginPage` lea ese estado: muestra *"Tu sesión venció. Vuelve a entrar."* en
vez de un formulario mudo, y después del login te devuelve a `from` en lugar de
dejarte en el inicio. Son unas diez líneas entre los dos archivos, y cambian por
completo la experiencia de un fallo que va a seguir ocurriendo.

**La refactorización correcta**

No perder el trabajo. Antes de redirigir, el borrador del formulario se guarda —en
el store o en `sessionStorage`— y se restituye al volver. Es más código y más
casos límite, y por eso no se paga en esta fase; pero es lo que convierte un
`401` de catástrofe en molestia.

Y una distinción que hoy el sistema no hace: **un `401` de credenciales
equivocadas y un `401` de sesión vencida no son lo mismo** y no merecen el mismo
mensaje. El primero es culpa de quien escribe; el segundo, de nadie.

**Prueba de regresión**

```javascript
// src/api/apiClient.test.js
test('un 401 informa el motivo y de dónde venías', async () => {
  const mock = new MockAdapter(apiClient);
  mock.onGet('/raffles').reply(401);
  history.push('/raffles/7/numbers');

  await apiClient.get('/raffles').catch(() => {});

  expect(store.getState().auth.token).toBeNull();
  expect(history.location.pathname).toBe('/login');
  expect(history.location.state).toEqual({
    reason: 'session-expired',
    from: '/raffles/7/numbers',
  });
});
```

**Prevención**

Una regla de una línea, y sorprendentemente rara: **ningún redirect automático sin
motivo**. Si el sistema mueve al usuario de pantalla por su cuenta, tiene que
poder explicar por qué. Y un único lugar que maneje el `401` —el interceptor—, para
que la explicación no dependa de qué componente disparó la petición.

**Por qué llegó a producción**

Porque *"te saca a login"* **es** el comportamiento correcto, y por eso nadie lo
revisó nunca. Los defectos que viven adentro de un comportamiento correcto son los
más difíciles de ver: no hay excepción, no hay log rojo, no hay test en rojo. Solo
un usuario que perdió veinte minutos de trabajo y que, encima, no tiene vocabulario
para reportarlo —fíjate que el ticket dice *"alguien me dijo que se cae la sesión,
pero no sé qué quiere decir eso"*—.

**Si tu causa fue distinta a esta**

Si dijiste *"el token está mal generado"* o *"el interceptor de la Fase 2 no
adjunta el token"*, eso es el incidente 05, y se descarta en un segundo: apaga el
caos con `CHAOS_LEVEL=off` y el síntoma desaparece por completo. Si desaparece, era
el caos; si persiste, era el token.

**Y acá vive el cruce con el track BE.** El incidente `be-08` —*"a algunos los saca
de la sesión al mediodía y a otros nunca"*— tiene este mismo síntoma con otra causa
raíz: allá el `401` es **real**, lo produce un `exp` de JWT sin renovación, y por
eso el fallo tiene **patrón horario**. Esa es la forma de distinguirlos en la vida
real: si las expulsiones se concentran en una franja del día, sospecha de
expiración; si están repartidas uniformemente, sospecha de fallo aleatorio o de
infraestructura. Un mismo síntoma, dos capas, dos investigaciones distintas.

</details>
L2EOF
awk '/^## Incidente/{if(t)print t" -> "n; t=$0; n=0} {n++} END{print t" -> "n}' /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L2.md

# --- 2026-09-10T01:59:15 · Splice L2 and read sources for L3
SCR=/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad
python3 - <<PY
import io
p="cuaderno-incidentes.md"; s=io.open(p,encoding="utf-8").read()
new=io.open("$SCR/L2.md",encoding="utf-8").read().rstrip("\n")
m="# 🪞 Retrospectiva del mes"
i=s.index(m)
s=s[:i]+new+"\n\n---\n\n"+s[i:]
io.open(p,"w",encoding="utf-8").write(s); print("L2 spliced")
PY
grep -c "^## Incidente" cuaderno-incidentes.md; echo "--- fuentes L3 ---"; sed -n '713,745p' 04-rifas-crud.md; echo "=========== FASE 05 §6"; sed -n '548,590p' 05-venta-de-numeros.md

# --- 2026-09-10T02:02:20 · Draft incidents 09 and 10
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L3a.md <<'L3EOF'
## Incidente 09 — Guardo la rifa, se recarga la página y pierdo todo

> **Fase:** 4 · **Categoría:** Estado (store) · **Dificultad:** 🟢
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 20-30 min

### 🎫 El ticket

Cargo la rifa nueva con todos los datos, le doy a "Guardar" y la pantalla
parpadea y se me borra todo el formulario. Vuelvo a la lista y la rifa no está.
Es como si se reiniciara el programa entero. Lo raro es que a veces, si vuelvo un
rato después, la rifa sí está cargada. Ya la creé tres veces por las dudas y
ahora tengo dos repetidas.

**Reportado por:** supervisor de ventas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar la línea y aplicar el fix. Y como ejercicio aparte:
explicar por qué el síntoma que reporta el usuario —"se borró todo"— no se parece
en nada a la causa, y por qué las rifas duplicadas son consecuencia del mismo bug.

### 🔧 Preparación

- **Rama:** `incidente/09`
- **Caos:** `off`. Con caos encendido el ruido de los fallos aleatorios tapa la
  señal, que acá es limpísima.
- **Datos:** el `db.json` de la fase. Llena el formulario entero antes de guardar:
  parte del incidente es ver qué se pierde.

```bash
git checkout incidente/09
CHAOS_LEVEL=off npm run mock
npm start
# /raffles → "Nueva rifa" → llena todo → Guardar
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Network, con *Preserve log* marcado —sin eso no vas a ver nada, porque justamente
se limpia—. Guarda la rifa y cuenta las peticiones. Además de tu `POST`, hay otra.
Mira su **método** y su **tipo**, y mira la barra de direcciones del navegador
justo después de guardar.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/raffles/RaffleForm.jsx`, y en particular las dos primeras líneas de
`handleSubmit`. Comparalo con cualquier otro `handleSubmit` que hayas escrito.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué hace un `<form>` de HTML cuando alguien lo envía y nadie se lo impide? Esa
pregunta no es sobre React: es sobre el navegador, y ahí está la respuesta.

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados. Anota qué había en la barra de direcciones antes y después de
hacer clic en Guardar: es la evidencia más contundente de este incidente.}}

**Evidencia observable**
{{Las peticiones de Network con *Preserve log*, y la URL resultante.}}

```
{{método, tipo y URL de cada petición}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/features/raffles/RaffleForm.jsx`: `handleSubmit` no llama a
`e.preventDefault()`.

```javascript
// ❌ El thunk sale… y el navegador hace lo suyo al mismo tiempo.
function handleSubmit(e) {
  dispatch(createRaffle(form));
}
```

Un `<form>` de HTML, si nadie lo detiene, envía sus campos por su cuenta: el
navegador arma una petición de documento a la misma URL con los valores en el
*query string*, la ejecuta y **recarga la página entera**. React se desmonta, el
store —que vive en memoria y no se persiste— se vacía, y el formulario vuelve en
blanco. Es el error común #4 de la Fase 4.

La evidencia definitiva está en la barra de direcciones: después de guardar dice
algo como `/raffles/new?name=Rifa+de+Navidad&closesAt=2024-12-20`. Los datos del
usuario, ahí a la vista. Nunca se "borraron": se fueron a la URL.

> 🧠 **Por qué el síntoma no se parece a la causa.** El usuario reporta "se borró
> todo", que suena a un problema de guardado o de estado. La causa es una llamada
> ausente en un manejador de eventos, tres capas más abajo, que ni siquiera es de
> React. Este incidente es corto a propósito, y aun así es de los más formativos
> del cuaderno: **la distancia entre lo que el usuario describe y donde vive la
> causa es la razón de ser de todo este oficio.**

Y las rifas duplicadas son el mismo bug: el `POST` del thunk **sí sale**, y a veces
alcanza a completarse antes de que la recarga lo cancele. De ahí el "a veces sí
está" del ticket. El usuario, viendo la pantalla en blanco, vuelve a cargarla, y
la segunda también entra. Es una carrera entre tu petición y el navegador
descargando la página de abajo.

**Parche mínimo**

```javascript
function handleSubmit(e) {
  e.preventDefault();          // el navegador no tiene nada que hacer acá
  dispatch(createRaffle(form));
}
```

**La refactorización correcta**

El parche es correcto y suficiente, pero se reintroduce solo: cada formulario
nuevo nace con la misma posibilidad de olvidarlo. Lo que cierra la puerta es que
nadie tenga que acordarse — un componente `<Form onSubmit={…}>` propio, que llame
al `preventDefault` y delegue después:

```javascript
// src/components/Form.jsx
export function Form({ onSubmit, children, ...rest }) {
  return (
    <form
      onSubmit={(e) => { e.preventDefault(); onSubmit(e); }}
      {...rest}
    >
      {children}
    </form>
  );
}
```

**Prueba de regresión**

```javascript
// src/features/raffles/RaffleForm.test.jsx
import { render, screen, fireEvent, createEvent } from '@testing-library/react';

test('el submit no deja que el navegador recargue', () => {
  render(<RaffleForm />);
  const form = screen.getByTestId('raffle-form');

  const submitEvent = createEvent.submit(form);
  fireEvent(form, submitEvent);

  // Con el bug, defaultPrevented es false y el navegador se lleva la página.
  expect(submitEvent.defaultPrevented).toBe(true);
});
```

**Prevención**

Una regla de lint de las que valen la pena: prohibir `<form>` sin `onSubmit`, y
prohibir un `onSubmit` cuyo cuerpo no empiece con `preventDefault` —salvo que use
el componente `Form` de arriba—. Es de los pocos errores que una herramienta puede
detectar con certeza absoluta.

**Por qué llegó a producción**

Por una historia banal que se repite en todos lados: durante el desarrollo el
botón "Guardar" era un `<button type="button">` con un `onClick`, y funcionaba
perfecto. Después alguien pidió que se pudiera enviar con Enter, se cambió a
`type="submit"` —que es la forma correcta y accesible de hacerlo— y nadie volvió a
probar el flujo completo, porque "solo cambié el tipo de un botón". El cambio de
una palabra activó un comportamiento del navegador que llevaba dormido desde 1995.

**Si tu causa fue distinta a esta**

Si dijiste *"el thunk no está guardando"*, mira Network: el `POST` sale y a veces
hasta responde `201`. Si dijiste *"falta persistir el store"* tienes razón en que
es una deuda real —el store no sobrevive a un F5 y eso se paga en otra parte—,
pero no es la causa: sin la recarga, no habría nada que persistir. Y si tu fix fue
`window.location.reload()` después de guardar para "refrescar la lista", acabas de
convertir el bug en una funcionalidad.

</details>

---

## Incidente 10 — La lista de rifas se queda cargando para siempre

> **Fase:** 4 · **Categoría:** Estado (store) · **Dificultad:** 🟡
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 35-45 min

### 🎫 El ticket

Reenvío lo que nos llegó de tres vendedores distintos esta semana: la lista de
rifas se queda con el cartel de "Cargando rifas…" y ahí se queda, para siempre. Hay
que recargar. Yo lo probé diez veces en mi máquina y anda perfecto, así que no sé
si están exagerando o si hay algo raro en las máquinas del kiosco.

**Reportado por:** soporte, reenviando reportes de UAT
**Ambiente:** UAT (en desarrollo "no pasa")

### 🎯 Qué se te pide

Este incidente tiene **dos entregables, en orden**, y el primero es el que casi
nadie practica.

1. **Decidir si se reproduce, con evidencia.** Si con lo que tienes montado no
   pasa, el resultado legítimo es cerrarlo en ⚪ *Descartado* con un reporte que
   diga qué probaste, cuántas veces, en qué condiciones, y —lo más importante—
   **qué le preguntas a quien lo reportó**. Escribe ese reporte de verdad, aunque
   te dé pereza: es el entregable.
2. **Recién después**, encontrar la condición que lo despierta, reabrirlo y
   arreglarlo.

> 🧭 **"No se reproduce" es una conclusión, no una excusa** — pero solo si viene
> con la evidencia y con la pregunta de vuelta. Sin eso es un encogimiento de
> hombros, y es la forma más común de que un incidente real muera sin resolverse.

### 🔧 Preparación

- **Rama:** ninguna. El bug ya está en tu aplicación.
- **Caos:** empieza en `off` **a propósito**, que es donde vive la primera mitad
  de la lección. La segunda mitad necesita `high`.
- **Datos:** el `db.json` de la fase, con varias rifas.

```bash
CHAOS_LEVEL=off npm run mock     # primera vuelta: intenta reproducirlo así
npm start
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Si con el caos apagado no lo reproduces, la pregunta no es *"¿dónde está el bug?"*
sino *"¿qué tiene el ambiente de ellos que el mío no tiene?"*. Enumera las
diferencias entre tu máquina y un kiosco de UAT antes de abrir un archivo: red,
datos, uso simultáneo, configuración del mock.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Con `CHAOS_LEVEL=high`, abre Redux DevTools y recarga hasta que la carga falle.
Mira la última acción despachada y su panel **Diff**: te va a decir qué pasó con
`loadingList` y qué pasó con `error`. Una de las dos cosas no pasó.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Un `createAsyncThunk` genera tres acciones. ¿Cuántas de las tres tiene registradas
el `extraReducers` de `raffleSlice`?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Primero el intento fallido, con sus condiciones y su número de intentos. Después,
si llegaste, el procedimiento que sí lo despierta. Los dos: el primero es tan
entregable como el segundo.}}

**Tu reporte de "no reproduce"**
{{Escríbelo como se lo mandarías a soporte: qué probaste, con qué configuración,
cuántas veces, y qué tres datos necesitas de quien lo reportó.}}

**Evidencia observable**
{{El Diff de la última acción, y el valor de `loadingList` después de ella.}}

```
{{acción, y qué cambió}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Ojo: puede que lo culpable sea algo que no está escrito.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Por qué no se reproduce en desarrollo**

Porque el ambiente de desarrollo **no falla nunca**. Con `CHAOS_LEVEL=off` el mock
responde siempre `200`, y el camino de código que tiene el bug es el que solo se
recorre cuando algo sale mal. Una rama que únicamente se ejecuta ante un fallo, en
un ambiente donde nunca hay fallos, es una rama que **jamás se ejecutó** — ni
siquiera una vez, ni durante el desarrollo ni durante la revisión.

Ese es el motivo por el que la Fase 3 construyó un mock que falla a propósito. No
es una excentricidad didáctica: es la única forma de que ese código exista de
verdad antes de que un usuario lo descubra.

**Causa raíz**

`src/features/raffles/raffleSlice.js`: el `extraReducers` registra `pending` y
`fulfilled`, y no registra `rejected`.

```javascript
// ❌ Dos de tres. La que falta es justo la del día malo.
extraReducers: (builder) => {
  builder
    .addCase(fetchAllRaffles.pending,   (state) => { state.loadingList = true; })
    .addCase(fetchAllRaffles.fulfilled, (state, action) => {
      state.loadingList = false;
      state.items = action.payload;
    });
}
```

Cuando el mock devuelve `500`, el thunk despacha `raffles/fetchAll/rejected`,
nadie la escucha, `loadingList` se queda en `true` y la pantalla sigue mostrando
"Cargando rifas…" indefinidamente. Es el error común #1 de la Fase 4, y la fase lo
llama "el más común y el más caro".

**Parche mínimo**

```javascript
.addCase(fetchAllRaffles.rejected, (state, action) => {
  state.loadingList = false;
  state.error = action.payload ?? 'No pudimos cargar las rifas.';
});
```

La Fase 4 es explícita sobre cómo llamar a esto: **no es un refactor, es completar
el thunk**. Un thunk con dos de sus tres estados manejados está a medio escribir.

**La refactorización correcta**

Que olvidarse deje de ser posible. Un ayudante que registre los tres casos de
cualquier thunk de una sola vez:

```javascript
// src/store/registerThunk.js
export function registerThunk(builder, thunk, { loadingKey, onSuccess }) {
  builder
    .addCase(thunk.pending,   (s) => { s[loadingKey] = true; s.error = null; })
    .addCase(thunk.fulfilled, (s, a) => { s[loadingKey] = false; onSuccess(s, a); })
    .addCase(thunk.rejected,  (s, a) => { s[loadingKey] = false; s.error = a.payload; });
}
```

Con eso, el `rejected` no se olvida porque no se escribe.

**Prueba de regresión**

```javascript
// src/features/raffles/raffleSlice.test.js
test('un 500 apaga el loading y deja un error legible', async () => {
  const mock = new MockAdapter(apiClient);
  mock.onGet('/raffles').reply(500);

  await store.dispatch(fetchAllRaffles());

  const state = store.getState().raffles;
  expect(state.loadingList).toBe(false);   // con el bug: true, para siempre
  expect(state.error).toBeTruthy();
});
```

**Prevención**

El ayudante de arriba, y una prueba por thunk que ejercite el camino del fallo. La
regla general, que vale más que este caso: **todo estado de carga necesita un test
que lo apague**. Encenderlo lo prueba el camino feliz solo; apagarlo, nunca.

**Por qué llegó a producción**

Por la razón que el propio ticket deja escrita sin querer: *"yo lo probé diez veces
en mi máquina y anda perfecto"*. Esa frase suele leerse como pereza, y casi nunca
lo es — acá describe un hecho técnico exacto: **el ambiente donde se programa no
produce las condiciones donde vive el bug**. Diez intentos en desarrollo son diez
recorridos por el mismo camino feliz.

Y el segundo motivo es cultural: cerrar el ticket cuando la funcionalidad "anda"
es lo que se premia. Escribir la rama del error cuesta cinco minutos, no se ve en
la demostración, y nadie la agradece hasta el día que salva un turno entero.

**Si tu causa fue distinta a esta**

Si dijiste *"el backend no responde"*, ese es el **incidente 07**, y se distinguen
en un vistazo a Network: en el 07 hay una petición **sin status**, todavía
pendiente, que nunca termina; acá la petición **terminó**, con un `500` bien
visible en rojo. Mismo síntoma en la pantalla —una espera que no acaba—, dos
lugares totalmente distintos. Tener los dos en el cuaderno y saber separarlos con
una sola columna de DevTools es exactamente el músculo que este curso entrena.

Si dijiste *"falta un `try/catch` en el componente"*, el componente no es el
problema: está pintando fielmente un `loadingList` que dice `true`. Y si tu fix
fue un `setTimeout` que apaga el cargando a los diez segundos, escondiste el error
y además le mentiste al usuario: la carga no terminó, se rindió en silencio.

</details>
L3EOF
awk '/^## Incidente/{if(t)print t" -> "n; t=$0; n=0} {n++} END{print t" -> "n}' /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L3a.md

# --- 2026-09-10T02:04:32 · Draft incidents 11 and 12
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L3b.md <<'L3EOF'
## Incidente 11 ⭐ — Vendimos el número 0347 dos veces

> **Fase:** 5 · **Categoría:** Concurrencia · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 70-90 min
> ⭐ Uno de los dos incidentes más formativos del curso · Hermano del incidente `be-09`, con otra causa raíz

### 🎫 El ticket

Tenemos dos comprobantes del número 0347 de la Rifa de Navidad, a nombre de dos
personas distintas, emitidos con dos minutos de diferencia. Los dos pagaron y los
dos tienen su papel. El sorteo es el viernes. Necesito saber qué pasó, si hay más
números en la misma situación, y a cuál de los dos señores le vamos a tener que
explicar que su número no vale.

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducir la secuencia **en el store** —no en el backend—, nombrarla, y separar
con claridad el parche mínimo del fix correcto. En este incidente los dos no viven
en la misma fase, y esa es media lección.

Y una advertencia que conviene leer antes de empezar: es tentador concluir que el
backend aceptó dos ventas. **Verifícalo antes de creerlo.** Si esa hipótesis
resulta falsa —y lo va a ser—, el lugar donde vive la causa cambia por completo.

### 🔧 Preparación

- **Rama:** `incidente/11`
- **Caos:** `CHAOS_LEVEL=high`. Hace falta latencia: sin ella la ventana entre las
  dos ventas es demasiado angosta para que la aciertes con el mouse.
- **Datos:** la Rifa de Navidad (`id: 1`) en estado `open`, con el número `0347` en
  `reserved`. La rama lo deja así.
- **Además:** dos pestañas del navegador sobre el mismo tablero. No hace falta que
  sean usuarios distintos; alcanza con que sean dos operaciones simultáneas.

```bash
git checkout incidente/11
CHAOS_LEVEL=high npm run mock
npm start
# Dos pestañas en /raffles/1/numbers. Vender el 0347 en las dos, casi a la vez.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No abras el código todavía. Reproduce con las dos pestañas, y después lee la lista
de acciones de Redux DevTools **de arriba abajo, entera**, como si fuera el
extracto de una cuenta bancaria donde falta plata. La secuencia completa te cuenta
la historia sin que tengas que interpretarla.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Hay una acción, casi al final de la secuencia, que **revierte algo que otra acción
ya había confirmado**. Selecciónala y usa *time-travel* para pararte justo antes:
mira en qué estado estaba el número `0347` en ese instante exacto, y compáralo con
el valor al que la acción lo está devolviendo.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

`rollbackSale` recibe un `previousStatus`. ¿En qué momento se capturó ese valor, y
qué le pasó al número entre esa captura y el instante en que el rollback se
ejecuta?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados y exactos: qué rifa, qué número, en qué estado de partida, con
qué `CHAOS_LEVEL`, y cuánta separación hubo entre los dos clics. Si tardaste
varios intentos, anota cuántos: la frecuencia es parte de la descripción de una
carrera.}}

**Evidencia observable**
{{La secuencia completa de acciones de Redux DevTools, en texto, con el payload de
cada una. Es la prueba central de este incidente; sin ella no hay diagnóstico.}}

```
{{la secuencia de acciones, en orden}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó. Anota especialmente si
  pasaste por "el backend aceptó las dos" y cómo la descartaste}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Y en qué capa vive: componente, store, epic, interceptor o mock.}}

**Tu fix**
{{El parche mínimo del viernes a las seis. Aparte, la refactorización correcta, y
por qué no se puede hacer todavía.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Lo primero: el backend se defendió bien**

Antes que nada, la hipótesis que hay que descartar. Mira el log del mock: la
segunda venta recibió un **`409`**. El servidor detectó el conflicto y lo rechazó,
tal como la Fase 5 lo diseñó. **El backend hizo su trabajo.**

Eso reubica la investigación entera. No estamos buscando por qué el servidor
aceptó dos ventas: estamos buscando por qué, habiéndolas rechazado correctamente,
igual terminaron existiendo dos comprobantes.

**Causa raíz**

La secuencia, tal como se lee en Redux DevTools:

```
sales/sellNumber/pending
numberSoldOptimistic     { number: '0347' }      ← pestaña A pinta sold
sales/sellNumber/pending
numberSoldOptimistic     { number: '0347' }      ← pestaña B, sin guarda de origen
sales/sellNumber/fulfilled                       ← A ganó: venta real, confirmada
sales/sellNumber/rejected  { type: 'conflict' }  ← B perdió: el 409
rollbackSale  { number: '0347', previousStatus: 'reserved' }   ← ⚠️ acá
```

Son dos defectos encadenados, y el segundo es el grave.

**El primero**, cosmético: `numberSoldOptimistic` asigna `sold` sin verificar el
estado de origen. La pestaña B repinta un número que ya estaba vendido. Es el
error común #1 de la Fase 5 y por sí solo no habría causado el incidente.

**El segundo**, el que produce los dos comprobantes: `rollbackSale` revierte al
`previousStatus` que se capturó **antes** de que existiera la venta ganadora. Para
cuando el rollback se ejecuta, el `0347` ya estaba vendido de verdad, con
confirmación del servidor — y el rollback lo devuelve a `reserved` igual, pisando
una venta legítima. Es el error común #2 de la fase.

Y ahí nace el segundo comprobante: la UI vuelve a mostrar el `0347` como
disponible para reservar. Alguien lo vende otra vez, esta vez sin carrera y sin
`409`, porque han pasado dos minutos y el backend… también lo rechaza. Pero el
vendedor ya imprimió el papel mirando la pantalla.

> 🧠 **Lo que hay que llevarse.** El fallo no fue no detectar el conflicto: fue
> **deshacer la detección**. El sistema tenía la información correcta y la
> descartó al revertir a ciegas. En concurrencia, el rollback es tan peligroso como
> la operación que revierte, y casi nunca se le presta la mitad de atención.

> 📝 **Nota de época.** Esto es de la Era 2 (2020-2021), y
> `00-historia-del-sistema.md` §3 lo nombra sin rodeos: cuando la venta pasó de un
> kiosco a tres, aparecieron los números vendidos dos veces, y la solución de
> entonces fue optimista —pintar al instante y revertir si el servidor protesta—.
> Funciona el 99% de las veces. Este incidente es el 1% restante, y no fue una
> mala decisión: fue una decisión correcta con un caso límite mal cerrado.

**Parche mínimo**

Que el `fulfilled` deje constancia de que la venta fue confirmada, y que el
rollback la respete:

```javascript
// saleSlice.js
[sellNumber.fulfilled]: (state, action) => {
  const { number } = action.payload;
  state.byNumber[number] = 'sold';
  state.confirmed[number] = true;        // esta venta la ratificó el servidor
},

rollbackSale(state, action) {
  const { number, previousStatus } = action.payload;
  // No se revierte lo que otro actor ya confirmó.
  if (state.confirmed[number]) return;
  state.byNumber[number] = previousStatus;
},
```

Y la guarda de origen, que es de una línea y cuesta nada:

```javascript
numberSoldOptimistic(state, action) {
  const { number } = action.payload;
  if (state.byNumber[number] !== 'reserved') return;   // solo desde reserved
  state.byNumber[number] = 'sold';
},
```

**La refactorización correcta** (que en este curso no se paga en esta fase)

No revertir localmente: cuando llega un `409`, el cliente no sabe cuál es el estado
verdadero del número, así que **no debería inventarlo**. Lo correcto es
re-sincronizar ese número desde el servidor y pintar lo que el servidor diga. Un
`409` no es "volvé a como estabas": es "tu foto del mundo está vieja".

Y estructuralmente hay dos piezas más, ninguna disponible todavía:

1. **Cancelar la operación perdedora en el origen**, con un `switchMap` por número
   en un epic. Eso es Fase 6, y es la razón por la que este incidente se enuncia en
   la 5 y termina de entenderse en la 6.
2. **La unicidad garantizada por el servidor**: un índice único y una transacción,
   que es lo único que cierra la ventana de verdad. Eso es el track BE (`be05`), y
   es también el incidente hermano.

> 🧭 **Y la conclusión honesta, que conviene decir en voz alta:** ninguna guarda en
> el frontend elimina esta carrera. La achica. La ventana entre "leí el estado" y
> "escribí el estado" existe en cuanto hay dos clientes, y solo se cierra donde hay
> un único árbitro. Todo lo que hagas acá es mitigación.

**Prueba de regresión**

```javascript
// src/features/sales/saleSlice.test.js
test('el rollback del perdedor no pisa la venta confirmada del ganador', () => {
  let state = reducer(undefined, setNumberStatus({ number: '0347', status: 'reserved' }));

  state = reducer(state, numberSoldOptimistic({ number: '0347' }));   // A
  state = reducer(state, numberSoldOptimistic({ number: '0347' }));   // B
  state = reducer(state, sellNumber.fulfilled({ number: '0347' }));   // A gana
  state = reducer(state, rollbackSale({ number: '0347', previousStatus: 'reserved' })); // B

  expect(state.byNumber['0347']).toBe('sold');   // con el bug: 'reserved'
});
```

Es un test de reducer puro, sin red y sin componentes: la secuencia exacta que
viste en DevTools, escrita como código. Reproducir una carrera de forma
determinista es difícil en la aplicación y trivial en el reducer, y ese es el
argumento más fuerte a favor de mantener la lógica de estado separada de la UI.

**Prevención**

Una máquina de estados explícita, con las transiciones permitidas declaradas en un
solo lugar, en vez de asignaciones sueltas repartidas por el slice:

```javascript
const ALLOWED = {
  available: ['reserved'],
  reserved:  ['sold', 'available'],
  sold:      [],                      // vendido es terminal: de acá no se vuelve
};
```

Con `sold` declarado como estado terminal, **el bug es inexpresable**: el rollback
no tiene a dónde ir. Es más código que la guarda, y a cambio protege también los
caminos que todavía no existen.

**Por qué llegó a producción**

Porque el camino que falla necesita tres condiciones simultáneas —dos actores, el
mismo número, y latencia suficiente para que las respuestas se crucen— y ninguna
de las tres ocurre en la máquina de quien programa. Con un kiosco no pasaba nunca;
con tres empezó a pasar, y para entonces el código llevaba un año funcionando y
nadie lo miraba.

Y hay una causa más de fondo, que no es de este código sino del proyecto: **no hay
tests**. La Era 1 no dejó ninguno (`00-historia-del-sistema.md` §3), y sin una
suite donde escribir la secuencia de arriba, la única forma de descubrir esta
carrera es que la sufra tesorería.

El análisis no es sobre quien escribió el rollback. Un rollback a ciegas es el
comportamiento razonable por defecto y está en la mitad de los tutoriales de
actualización optimista que había en 2020.

**Si tu causa fue distinta a esta**

Si concluiste *"el backend aceptó dos ventas"*, el log del mock lo desmiente: hay
un `409`. Es la hipótesis más natural del mundo y descartarla con evidencia, en
vez de asumirla, es la mitad del valor de este incidente.

Si tu fix fue **bloquear el botón de vender mientras hay una venta en curso**,
funciona para las dos pestañas del mismo navegador y no hace nada contra dos
kioscos distintos, que es el caso real del ticket. Tapaste el síntoma en la capa
de la UI.

**Y acá está el cruce más importante del curso.** El incidente `be-09` del track BE
—*"vendimos tres números dos veces, y solo los redondos"*— tiene el mismo síntoma y
la causa **opuesta**: allá el backend **no** se defiende, porque falta el índice
único, y las dos ventas entran de verdad en la base. Acá el backend se defiende
bien y el frontend arruina la defensa. Mismo comprobante duplicado, dos culpables
en orillas contrarias del cable. Si vas a hacer el track BE, resolver estos dos en
pareja enseña más sobre concurrencia que cualquier explicación.

</details>

---

## Incidente 12 — Un número que ya estaba vendido volvió solo a disponible

> **Fase:** 5 · **Categoría:** Concurrencia · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min

### 🎫 El ticket

Un número que ya estaba vendido volvió solo a disponible. Nadie lo tocó, yo estaba
mirando la pantalla. Estaba pintado como vendido y al rato apareció otra vez en
blanco, como si nunca lo hubieran comprado. Fue en la Rifa de Navidad. Y me parece
que también lo vi en otra rifa el martes, pero no estoy seguro.

**Reportado por:** vendedor de rifas
**Ambiente:** UAT

### 🎯 Qué se te pide

**Dos causas distintas producen exactamente este síntoma.** El entregable de este
incidente no es el parche: es determinar cuál de las dos estás viendo, con la
evidencia que descarta la otra. El fix, una vez que sabes cuál es, es de una línea
en ambos casos.

Y no ignores la última frase del ticket —*"me parece que también lo vi en otra
rifa"*—. Los vendedores suelen disculparse por lo que no recuerdan bien; ese detalle
inseguro es, en este incidente, el que más información trae.

### 🔧 Preparación

- **Rama:** `incidente/12`
- **Caos:** `low`. Con `high` se mezclan los fallos de venta y cuesta separar las
  dos causas; con `off` no se reproduce una de ellas.
- **Datos:** dos rifas en `open`, la 1 y la 2, cada una con algún número en
  `reserved` y alguno en `sold`. La rama las deja así.
- **Y algo que no es un dato sino una instrucción:** parte del procedimiento es
  **esperar sin tocar nada**. Deja el tablero quieto varios minutos.

```bash
git checkout incidente/12
CHAOS_LEVEL=low npm run mock
npm start
# Reserva un número en la rifa 1, navega a la rifa 2, y espera mirando DevTools.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Redux DevTools abierto, y paciencia: deja de interactuar con la aplicación durante
unos minutos, mirando la lista de acciones. Si aparece una acción que **nadie
pidió**, ya sabes por dónde va. Y mira Network al mismo tiempo: si esa acción no
tiene ninguna petición al lado, nació dentro del navegador.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El **payload** de esa acción huérfana: ¿de qué rifa habla? Compáralo con la rifa
que tienes en pantalla. Y en el otro camino: ¿qué acción viene inmediatamente
después de un `sellNumber/rejected`?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Una de las dos causas llega **tarde, desde otro lado**; la otra llega **a tiempo,
con información vieja**. Una aparece en silencio minutos después; la otra, al
instante de una venta fallida. ¿Cuál de las dos viste?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, incluyendo cuántos minutos esperaste y en qué rifa estabas
parado cuando apareció el síntoma. Ese último dato decide el diagnóstico.}}

**Evidencia observable**
{{La acción huérfana con su payload completo, y si hubo o no una petición en
Network en ese mismo instante.}}

```
{{acción, payload, y qué había en Network}}
```

**Hipótesis**
- ❌ Descartada: {{cuál de las dos causas descartaste, y con qué evidencia}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Las dos causas, y cómo se separan**

**Causa A — el temporizador que sobrevivió al desmontaje.** El `setTimeout` que
expira una reserva se crea en el `useEffect` del tablero y no se cancela al
desmontarlo. Navegas de la rifa 1 a la rifa 2, el temporizador de la rifa 1 sigue
vivo y minutos después dispara `reservationExpired` con el número de la rifa vieja.
Y como el reducer indexa por número —`state.byNumber['0347']`— y no por rifa, la
expiración de la rifa 1 se aplica sobre el tablero de la rifa 2, si comparten ese
número. Es el error común #3 de la Fase 5, con un agravante de diseño encima.

Ahí está la frase del ticket que parecía un titubeo: *"también lo vi en otra
rifa"*. No era una confusión del vendedor. Era el bug describiéndose solo.

**Causa B — el rollback a ciegas.** Es el error común #2 de la Fase 5 y el segundo
defecto del incidente 11: tras un `sellNumber/rejected`, `rollbackSale` devuelve el
número a un `previousStatus` capturado antes, sin comprobar qué pasó entre medio.

**Cómo se distinguen, en un vistazo:**

| | Causa A — temporizador huérfano | Causa B — rollback a ciegas |
|---|---|---|
| Acción que aparece | `reservationExpired` | `rollbackSale` |
| Cuándo | minutos después, sin que hagas nada | al instante, tras una venta fallida |
| En Network | **nada**: no hay petición asociada | un `409` o un `500` justo antes |
| El payload | menciona **otra** rifa | menciona la rifa en pantalla |

La columna de Network es la más rápida: **una acción sin petición al lado nació
dentro del navegador**, y eso descarta la mitad de las hipótesis de un plumazo.

**Parche mínimo**

Para A, limpiar al desmontar:

```javascript
useEffect(() => {
  scheduleExpiration(raffleId, number);
  return () => cancelAllExpirations();   // el temporizador muere con el tablero
}, [raffleId]);
```

Para B, la guarda del incidente 11.

**La refactorización correcta**

Para A hay dos capas, y conviene no confundirlas:

1. **Que el temporizador no sea responsabilidad del componente.** Un `setTimeout`
   dentro de un `useEffect` obliga a acordarse de limpiarlo, y acordarse no es una
   estrategia. En la Fase 6 esto se convierte en un epic que se apaga solo con
   `takeUntil`, y el problema deja de existir en vez de quedar resuelto.
2. **Que el estado se indexe por rifa y número**, no por número a secas. Que la
   expiración de una rifa pueda tocar el tablero de otra no es un accidente del
   temporizador: es una clave mal elegida. Con `state.byNumber['1:0347']` el bug
   pierde el vehículo.

**Prueba de regresión**

```javascript
// src/features/sales/NumberBoard.test.jsx
jest.useFakeTimers();

test('al desmontar el tablero, sus expiraciones no disparan nada', () => {
  const { unmount } = render(<NumberBoard raffleId={1} />);
  act(() => { fireEvent.click(screen.getByTestId('cell-0347')); });  // reserva

  unmount();
  const before = store.getState().sales.byNumber;

  act(() => { jest.advanceTimersByTime(5 * 60 * 1000); });

  // Con el bug, acá apareció un reservationExpired de la rifa 1.
  expect(store.getState().sales.byNumber).toEqual(before);
});
```

`jest.advanceTimersByTime` es lo que vuelve barato probar esto: el bug tarda
minutos en la vida real y milisegundos en la suite.

**Prevención**

Una regla que vale para todo el curso y para todo lo que escribas después: **todo
lo que se agenda se cancela, en el mismo archivo donde se agendó**. Si un
`useEffect` crea un `setTimeout`, un `setInterval` o una suscripción y no devuelve
una función de limpieza, es un defecto — no un descuido de estilo. Y como
prevención estructural, la clave compuesta por rifa y número.

**Por qué llegó a producción**

Porque los temporizadores no dejan rastro. Un `setTimeout` huérfano no lanza
excepciones, no escribe en la consola, no aparece en ningún log, y su efecto ocurre
**minutos después** del código que lo creó. Esa distancia entre causa y efecto es
lo que vuelve carísima esta familia de bugs: cuando el síntoma aparece, quien lo
ve ya está en otra pantalla haciendo otra cosa, y no tiene ninguna razón para
sospechar de algo que hizo hace cinco minutos.

Es, exactamente, el problema que empujó al equipo hacia `redux-observable` en 2022
(`00-historia-del-sistema.md` §3, Era 3). La cancelación dejó de ser algo que había
que recordar y pasó a ser algo que el operador hace por vos. A cambio, la Era 3
trajo su propia familia de bugs invisibles — que son los incidentes 13, 14, 15 y
17.

**Si tu causa fue distinta a esta**

Si dijiste *"el backend liberó la reserva por su cuenta"*, mira Network en el
instante del síntoma: no salió ninguna petición. La acción se despachó desde el
navegador. Si dijiste *"otro vendedor lo liberó desde su máquina"*, plausible y
falso en este sistema: la aplicación no tiene ningún canal por el que le lleguen
cambios de otros clientes —no hay websockets ni polling del tablero todavía—, así
que nada de lo que haga otro puede modificar tu store sin que tú preguntes. Notar
eso, por sí solo, ya elimina una familia entera de hipótesis.
L3EOF
awk '/^## Incidente/{if(t)print t" -> "n; t=$0; n=0} {n++} END{print t" -> "n}' /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L3b.md

# --- 2026-09-10T02:04:43 · Fix unclosed details and splice L3
SCR=/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad
printf '\n</details>\n' >> $SCR/L3b.md
python3 - <<PY
import io
p="cuaderno-incidentes.md"; s=io.open(p,encoding="utf-8").read()
a=io.open("$SCR/L3a.md",encoding="utf-8").read().rstrip("\n")
b=io.open("$SCR/L3b.md",encoding="utf-8").read().rstrip("\n")
new=a+"\n\n---\n\n"+b
m="# 🪞 Retrospectiva del mes"; i=s.index(m)
s=s[:i]+new+"\n\n---\n\n"+s[i:]
io.open(p,"w",encoding="utf-8").write(s); print("L3 spliced")
PY
grep -c "^## Incidente" cuaderno-incidentes.md
echo "=== balance de details ==="; grep -c "<details>" cuaderno-incidentes.md; grep -c "</details>" cuaderno-incidentes.md

# --- 2026-09-10T02:04:52 · Read epics code and phase 7 section 6
sed -n '200,300p' 06-redux-observable-a-fondo.md; echo "=========== FASE 07 §6"; sed -n '535,556p' 07-cierre-polling-resultado.md; echo "=========== pollingEpic"; sed -n '440,502p' 07-cierre-polling-resultado.md

# --- 2026-09-10T02:08:10 · Draft incidents 13 and 14
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L4a.md <<'L4EOF'
## Incidente 13 — Falló una venta y desde entonces no funciona ninguna

> **Fase:** 6 · **Categoría:** RxJS / epics · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min

### 🎫 El ticket

Vendí un número, me salió un cartel de error rojo, y desde ese momento no puedo
vender nada más. Le doy al botón y no pasa absolutamente nada: ni se vende, ni me
da error, ni se queda cargando. Nada. Cierro el navegador, vuelvo a entrar y anda
otra vez, hasta que se repite. Perdí media mañana entre cierre y cierre del
navegador.

**Reportado por:** vendedor de rifas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar y arreglar. Y explicar la parte del ticket que suena
imposible: **por qué el sistema no da ningún error**. En este incidente el
silencio no es un detalle: es el síntoma principal.

Antes de terminar, comprueba una cosa más que el ticket no menciona: ¿solo dejó de
funcionar la venta, o algo más se apagó junto con ella?

### 🔧 Preparación

- **Rama:** `incidente/13`
- **Caos:** `CHAOS_LEVEL=high`. Hace falta que una venta falle de verdad; con `off`
  no hay forma de encender el problema.
- **Datos:** una rifa en `open` con varios números `reserved`, para poder intentar
  varias ventas seguidas.

```bash
git checkout incidente/13
CHAOS_LEVEL=high npm run mock
npm start
# Vende hasta que una falle. Después intenta vender otro número cualquiera.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Redux DevTools abierto. Después del primer fallo, haz clic en vender otro número y
responde dos preguntas por separado: ¿se despachó la acción `SELL_NUMBER`? ¿Y pasó
algo **después** de ella? Si la respuesta es "sí" y "no", ya tienes acotada la capa
a una sola: la que escucha las acciones y no reaccionó.

Y mira Network al mismo tiempo: cuenta cuántas peticiones salieron.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/sales/epics/sellNumberEpic.js`, y al lado
`src/features/sales/epics/validateNumberEpic.js`. Los dos hacen una petición
dentro de un `switchMap`. Uno tiene un operador que el otro no.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué le pasa a un Observable cuando un error lo recorre entero sin que nadie lo
atrape? ¿Y qué le queda al epic que estaba suscrito a `action$` a través de ese
Observable?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados. Anota cuántas ventas hiciste antes de la que falló, y qué
intentaste después.}}

**Evidencia observable**
{{Las acciones de Redux DevTools después del fallo, y —muy importante— cuántas
peticiones salieron por Network en cada intento posterior.}}

```
{{acciones despachadas   ·   peticiones en Network}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Y una respuesta explícita: ¿qué dejó de existir exactamente?}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`sellNumberEpic` no tiene `catchError` dentro de su `switchMap`. Cuando la petición
de venta falla, el error no lo atrapa nadie, sube por el pipe hasta el `rootEpic`
y **completa el Observable con error**. A partir de ese instante, el epic ya no
está suscrito a `action$`.

Y ahí está la explicación del silencio, que es lo que más cuesta aceptar: el epic
no falló. **Dejó de existir.** Las acciones `SELL_NUMBER` se siguen despachando —lo
ves en DevTools, ahí están— y no hay nadie del otro lado escuchándolas. Un
componente que despacha a un epic muerto se comporta exactamente igual que un
componente que despacha a un epic que decidió no hacer nada: sin excepción, sin
log, sin nada.

La evidencia definitiva es la que pedía la pista 1: **cero peticiones en Network**
en los intentos posteriores. No es que el servidor rechace la venta; es que la
venta nunca sale de la aplicación.

Es el error común #1 de la Fase 6.

**Y la parte que el ticket no menciona**

`combineEpics` combina los epics con un `merge`. Un error que mata a uno mata el
stream combinado, y con él **todos los demás epics**. Si lo comprobaste, viste que
la validación del número en tiempo real también dejó de responder, y la expiración
de reservas también. El vendedor solo reportó lo que estaba haciendo en ese
momento; el daño fue mucho mayor y nadie lo notó.

Ese detalle vale por sí solo el incidente: **el alcance de un fallo casi nunca
coincide con el alcance del reporte.**

> 🧠 **El patrón a memorizar.** En RxJS, un error no es un evento que se maneja: es
> una **terminación**. La analogía de backend que hay que abandonar acá es la
> excepción atrapada en un `try/catch` dentro de un bucle, donde la iteración
> siguiente ocurre igual. Un epic no es un bucle: es una suscripción, y una
> suscripción que termina no vuelve sola.

**Parche mínimo**

El `catchError` va **dentro** del `switchMap`, envolviendo al Observable interno —el
de la petición—, no al externo:

```javascript
switchMap((action) => {
  const { raffleId, number, participant } = action.payload;
  return from(
    apiClient.post(`/raffles/${raffleId}/numbers/${number}/sell`, { participant })
  ).pipe(
    map((response) => numberSoldOptimistic({ /* … */ })),
    // Acá muere el error: mata solo a esta venta, no al epic.
    catchError((error) => of(rollbackSale({ raffleId, number, error: toReadableError(error) })))
  );
})
```

Si lo pones afuera del `switchMap`, atrapas el error y **igual pierdes el stream
externo**: el epic emite el rollback una vez y después se completa. Se ve arreglado
en la primera prueba y vuelve a fallar en la segunda, que es la peor forma
posible de arreglar algo.

**La refactorización correcta**

La de arriba ya es la corrección correcta para este epic. Lo que corresponde
agregar aparte es una red de seguridad para el resto, porque este error va a
volver a ocurrir en algún epic que alguien escriba el año que viene:

```javascript
// src/app/rootEpic.js
export const rootEpic = (action$, store$, deps) =>
  combineEpics(/* … */)(action$, store$, deps).pipe(
    catchError((error, source) => {
      console.error('[rootEpic] un epic murió y fue resucitado:', error);
      return source;      // re-suscribe: el sistema sigue vivo
    })
  );
```

Con eso, un epic mal escrito degrada una operación en vez de apagar la aplicación
entera. Y el `console.error` convierte un fallo invisible en uno que deja rastro,
que es la mitad del problema de este incidente.

**Prueba de regresión**

```javascript
// src/features/sales/epics/sellNumberEpic.test.js
import { TestScheduler } from 'rxjs/testing';
import { ActionsObservable } from 'redux-observable';

test('una venta que falla no mata el epic: la siguiente se sigue atendiendo', () => {
  const scheduler = new TestScheduler((actual, expected) =>
    expect(actual).toEqual(expected)
  );

  scheduler.run(({ hot, expectObservable }) => {
    const action$ = new ActionsObservable(
      hot('a 20ms b', { a: sellNumber('0347'), b: sellNumber('0348') })
    );
    // La primera petición falla, la segunda funciona.
    const output$ = sellNumberEpic(action$, null, { api: apiThatFailsOnce() });

    // Con el bug, el segundo marble no aparece: el epic ya estaba muerto.
    expectObservable(output$).toBe('10ms r 20ms s', {
      r: rollbackSale({ number: '0347' }),
      s: numberSoldOptimistic({ number: '0348' }),
    });
  });
});
```

Lo que hace útil este test es la **segunda** venta. Un test que solo compruebe que
el fallo produce un rollback pasa con el bug adentro: el rollback llega, y recién
la operación siguiente revela que no quedó nadie escuchando. El detalle de cómo se
leen estos diagramas está en `A11-marble-testing.md`.

**Prevención**

Una regla mecánica, verificable en revisión de código: **todo Observable interno
que haga entrada/salida lleva su `catchError` adentro del operador de aplanamiento
que lo creó.** Más el `catchError` del `rootEpic` como red. Y un test de
supervivencia —dos operaciones, la primera falla— por cada epic que atienda algo
repetible.

**Por qué llegó a producción**

Por una creencia razonable y equivocada: *"los errores ya los maneja el interceptor
de axios"*. Y es cierto para lo que el interceptor hace —traducir el `401`,
normalizar el mensaje— pero el interceptor vive en la capa de transporte y no sabe
nada del ciclo de vida de un Observable. Rechaza la promesa, como debe. Lo que pasa
después de ese rechazo es asunto del epic, y nadie lo había pensado.

Y sobrevivió porque el síntoma es absurdo: *"le doy al botón y no pasa nada"* suena
a problema de interfaz, y quien lo investigó por ahí no encontró nada raro, porque
efectivamente no lo hay. El botón funciona perfecto.

**Si tu causa fue distinta a esta**

Si dijiste *"el botón se deshabilitó y no se volvió a habilitar"*, míralo en el
inspector: está habilitado, y el `onClick` se ejecuta. Si dijiste *"el backend está
rechazando todo"*, la prueba está en Network: **no sale ninguna petición**, así que
el backend ni se entera. Y si tu fix fue recargar la aplicación desde el código
—un `window.location.reload()` en el `catch`—, automatizaste lo que ya hacía el
vendedor a mano y le pusiste el mismo costo: todo el estado en memoria, perdido.

</details>

---

## Incidente 14 ⭐ — Cerré sesión y el servidor sigue recibiendo peticiones

> **Fase:** 6 · **Categoría:** RxJS / epics · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 55-70 min
> ⭐ Uno de los dos incidentes más formativos del curso

### 🎫 El ticket

Nos avisó el proveedor de infraestructura que estamos haciendo como cuatro veces
más peticiones de las que correspondería para la cantidad de gente que usa el
sistema. Miramos el log del servidor y hay pedidos de tableros de rifas a las tres
de la mañana, cuando no hay nadie trabajando. Vienen sin token y son de usuarios
que cerraron sesión hacía horas. Nadie se quejó nunca de nada: la aplicación
funciona bien.

**Reportado por:** infraestructura, a partir de la factura
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducirlo en Network en menos de un minuto, localizar la línea y aplicar el fix
—que es de una línea— y escribir el post-mortem completo. Este es **el** incidente
que el curso usa como ejemplo de la convención de tags: cuando lo cierres, el par
`inc/14/suscripcion-zombi-roto` / `-fix` tiene que existir, y sus mensajes están
redactados como referencia en `00-convencion-de-git-y-tags.md` §🚑.

Y hay una pregunta de fondo que conviene contestar por escrito: **¿por qué nadie
se quejó nunca?**

### 🔧 Preparación

- **Rama:** `incidente/14`, que trae el `boardRefreshEpic` en su versión con leak
  (la de §5.8 de la Fase 6).
- **Caos:** `off`. Este bug no necesita que nada falle; al contrario, el caos solo
  agrega ruido a Network justo donde hay que mirar.
- **Datos:** una rifa en `open`, la 3, para tener su tablero.

```bash
git checkout incidente/14
CHAOS_LEVEL=off npm run mock
npm start
# Login → abrir el tablero de la rifa 3 → logout → NO TOCAR NADA y mirar Network.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No lo busques en el código: es de los pocos bugs que se ven antes de leer nada.
Abre Network, filtra por `numbers`, cierra sesión y **quédate quieto mirando la
pestaña**. La aplicación no se está usando. Si algo aparece igual, ese algo es el
incidente.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/sales/epics/boardRefreshEpic.js`. Pon su `.pipe()` al lado del de
`reservationExpirationEpic`, que sí se apaga. Los dos crean un stream que emite
para siempre; uno de los dos tiene una instrucción de apagado.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

El `interval` que abre el `switchMap` emite cada cinco segundos hasta el fin de los
tiempos. ¿Quién le dice que pare, y —esta es la parte que decide si tu fix va a
funcionar— **en cuál de los dos pipes** tendría que estar esa instrucción?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados. Anota cuántos minutos dejaste la pestaña quieta y cuántas
peticiones contaste en ese tiempo: ese número es el que convierte este incidente
en dinero.}}

**Evidencia observable**
{{Las filas de Network después del logout, con su URL, su cadencia y sus headers.
La ausencia del `Authorization` es parte de la prueba.}}

```
{{las peticiones que no deberían existir}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea.}}

**Tu fix**
{{El parche mínimo. Y responde: ¿por qué ahí y no en el otro pipe?}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`src/features/sales/epics/boardRefreshEpic.js` **no tiene `takeUntil`**. El
`interval(5000)` que abre el `switchMap` emite indefinidamente, y nadie lo corta
nunca:

```javascript
// ❌ VERSIÓN CON LEAK (Fase 6, §5.8)
export const boardRefreshEpic = (action$) =>
  action$.pipe(
    ofType('START_BOARD_REFRESH'),
    switchMap(({ payload }) =>
      interval(5000).pipe(map(() => fetchNumbers(payload.raffleId)))
    )   // <-- acá falta el takeUntil. Ese es el leak.
  );
```

Desmontar el tablero no hace nada, y ahí está el salto conceptual de toda la Fase
6: **un epic no tiene ciclo de vida atado a la interfaz**. Vive en el middleware,
que se monta una vez con la aplicación. El componente que despachó
`START_BOARD_REFRESH` puede desaparecer, el usuario puede cerrar sesión, puede
navegar a otra sección — el `interval` sigue emitiendo, porque nada de eso es una
señal para él. Sigue emitiendo hasta que se cierra la pestaña, que es exactamente
lo que dice el log de las tres de la mañana: máquinas de kiosco que quedaron
prendidas.

Y las peticiones salen **sin token** porque el interceptor lee el store en cada
petición y el store ya no tiene sesión (ver el incidente 05). Un `401` por cada
tick, cada cinco segundos, toda la noche. La aplicación las descarta en silencio;
el servidor las atiende igual, y las cobra.

**Parche mínimo**

```javascript
switchMap(({ payload }) =>
  interval(5000).pipe(
    map(() => fetchNumbers(payload.raffleId)),
    // Última línea del pipe INTERNO: corta este interval, no el epic.
    takeUntil(action$.pipe(ofType('STOP_BOARD_REFRESH', logout.type)))
  )
)
```

**Y por qué va en el pipe interno, que es la mitad de la lección**

`takeUntil` corta **todo lo que está antes de él en el pipe donde vive**. Si lo
pones en el pipe externo —cerrando el `action$.pipe(...)` del epic—, funciona una
vez: el primer logout apaga el `interval`… y también apaga el epic entero. El
usuario vuelve a entrar, abre un tablero, y el refresco ya no arranca nunca más,
porque no queda nadie escuchando `START_BOARD_REFRESH`.

Habrías cambiado un leak por un epic muerto, que es exactamente el **incidente
13**. Dos bugs opuestos, la misma línea, dos ubicaciones distintas dentro del
mismo `.pipe()`. Es el error común #3 de la Fase 6 y la razón por la que la regla
práctica es: **`takeUntil` casi siempre va último, y en el pipe interno**.

**La refactorización correcta**

La versión de producción, que la Fase 7 consolida en §5.10 al pagar esta deuda 💸:
`timer(0, 5000)` en lugar de `interval(5000)` —para refrescar de entrada, sin
esperar el primer intervalo— y el mismo `takeUntil` con todas las señales que
tengan sentido para el tablero: `STOP_BOARD_REFRESH`, `logout`, el cierre de la
rifa. Mismo esqueleto que el `pollingEpic`.

**Prueba de regresión**

```javascript
// src/features/sales/epics/boardRefreshEpic.test.js
import { TestScheduler } from 'rxjs/testing';
import { ActionsObservable } from 'redux-observable';

test('el refresco del tablero completa al llegar el logout', () => {
  const scheduler = new TestScheduler((actual, expected) =>
    expect(actual).toEqual(expected)
  );

  scheduler.run(({ hot, expectObservable }) => {
    const action$ = new ActionsObservable(
      hot('a 12s b', { a: startBoardRefresh({ raffleId: 3 }), b: logout() })
    );

    // Dos ticks (5s y 10s) y después NADA: el "|" es el punto del test.
    expectObservable(boardRefreshEpic(action$)).toBe('5s x 4999ms y 2s |', {
      x: fetchNumbers(3),
      y: fetchNumbers(3),
    });
  });
});
```

> 🧭 **Lo que se prueba acá no es que el epic emita: es que el epic
> DEJE de emitir.** Esa barra vertical al final del diagrama es todo el test. Es la
> única forma práctica de verificar una cancelación, y es la razón por la que
> `A11-marble-testing.md` existe: sin marbles, "comprobar que algo no pasa nunca
> más" requiere esperar para siempre.

**Prevención**

Una regla concreta: **todo epic que crea un stream infinito** —`interval`, `timer`,
`fromEvent`, un websocket— **declara su `takeUntil` en el mismo pipe donde lo
creó**, y lleva un test de cancelación como el de arriba. Son dos líneas de
prevención contra una familia de bugs que no da ninguna otra señal.

Y una operativa que cuesta cinco minutos: revisar el volumen de peticiones por
usuario activo, una vez al mes. Este incidente lo encontró una factura; podría
haberlo encontrado un gráfico.

**Por qué llegó a producción**

Porque **no rompe nada**. La aplicación funciona perfecto, el usuario no percibe
absolutamente nada, no hay error en ninguna consola, y el `takeUntil` faltante no
produce ningún síntoma el día que se escribe. El costo aparece meses después, lo
paga otra área, y llega expresado en una unidad —una factura de infraestructura—
que nadie asocia con una línea de código.

Ahí está la respuesta a la pregunta del enunciado: nadie se quejó porque **no hay
nadie a quien le duela**. El usuario no lo sufre, el desarrollador no lo ve, y el
que lo paga no sabe leer un pipe de RxJS. Es la definición del bug caro con parche
barato, y por eso el curso lo marca con ⭐.

Es también, exactamente, el problema que empujó al equipo a adoptar
`redux-observable` en 2022 (`00-historia-del-sistema.md` §3, Era 3): un
`setInterval` que seguía preguntando después del logout, para siempre. La
herramienta que vino a resolverlo trae la solución —`takeUntil`— y también la forma
de olvidarla.

**Si tu causa fue distinta a esta**

Si dijiste *"el componente del tablero no se desmonta"*, compruébalo con React
DevTools: se desmonta perfectamente. Y aunque no lo hiciera, daría igual — el
`interval` no vive en el componente. Interiorizar eso es el objetivo del incidente:
en un sistema con epics, **desmontar la interfaz no cancela nada**.

Si dijiste *"falta limpiar el `useEffect`"*, ese diagnóstico es correcto para el
**incidente 12**, donde el temporizador sí vive en el componente. Tener los dos en
el cuaderno y saber cuál es cuál —el mismo síntoma de "algo sigue vivo", en dos
capas distintas— es una de las distinciones más útiles que te llevas del curso.

</details>
L4EOF
awk '/^## Incidente/{if(t)print t" -> "n; t=$0; n=0} {n++} END{print t" -> "n}' /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L4a.md

# --- 2026-09-10T02:10:03 · Draft incidents 15 and 17
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L4b.md <<'L4EOF'
## Incidente 15 — Escribo el número rápido y me valida uno viejo

> **Fase:** 6 · **Categoría:** RxJS / epics · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min

### 🎫 El ticket

Cuando escribo el número que quiero vender, el cartelito de al lado me dice
cualquier cosa. Escribo 0347 y me dice que el 034 está vendido. Si escribo
despacio, letra por letra, anda bien. Ayer no le vendí un número a un cliente
porque el cartel decía que no estaba disponible, y después resulta que sí lo
estaba. Perdimos la venta.

**Reportado por:** vendedor de rifas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir, localizar y arreglar. Y explicar dos cosas que el ticket regala:
**por qué escribir despacio lo arregla**, y por qué eso descarta de entrada la
mitad de las hipótesis.

Ojo: en el pipe de este epic hay **dos** cosas cambiadas respecto de la versión
que escribiste en la Fase 6, y solo una de las dos causa la respuesta equivocada.
Separarlas es parte del trabajo.

### 🔧 Preparación

- **Rama:** `incidente/15`
- **Caos:** `CHAOS_LEVEL=high`. **Obligatorio**, y acá el motivo es preciso: el bug
  no existe sin latencia variable. Con el mock respondiendo en tres milisegundos,
  las respuestas vuelven en el mismo orden en que salieron y el problema es
  invisible. Este incidente **no se puede reproducir con `off`**, por mucho que
  escribas rápido.
- **Datos:** una rifa en `open` donde el número `034` esté `sold` y el `0347` esté
  `available`. La rama los deja así, y esa combinación es la que hace el síntoma
  inconfundible.

```bash
git checkout incidente/15
CHAOS_LEVEL=high npm run mock
npm start
# En el campo de venta, escribe 0347 a velocidad normal. Repite unas cuantas veces.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No es un problema del campo de texto. Escribe con Network abierto y mira dos
columnas: cuántas peticiones salieron, y la columna **Time** de cada una. Después
ordénalas por el momento en que **volvieron**, no por el momento en que salieron.
Ahí está todo.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/sales/epics/validateNumberEpic.js`. Compara su operador de
aplanamiento con el de `sellNumberEpic`. Y fíjate qué le pasó al primer operador
del pipe, el que controlaba cada cuánto se dispara la validación.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Si dos peticiones están en vuelo al mismo tiempo y la primera tarda más que la
segunda, ¿cuál de las dos respuestas llega última? ¿Y cuál de las dos termina
pintando el store?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados. Anota a qué velocidad escribiste y cuántos intentos hicieron
falta: en un bug que depende de latencia, la frecuencia es parte de la descripción.}}

**Evidencia observable**
{{Las peticiones de Network con su tiempo de respuesta, y las acciones
`numberValidationSucceeded` en el orden en que llegaron al store.}}

```
{{qué salió, qué volvió, y en qué orden}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Y de los dos cambios que hay en ese pipe, cuál es la causa y
cuál es solo un amplificador.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`validateNumberEpic` usa `mergeMap` donde corresponde `switchMap`.

`mergeMap` mantiene **todas** las peticiones en vuelo a la vez y deja pasar sus
respuestas en el orden en que lleguen. Con latencia variable —que es lo que hace el
caos y lo que hace cualquier red real— la respuesta de `034` puede volver después
de la de `0347`, y como el reducer aplica lo último que recibe, el estado del
número viejo pisa al del nuevo. El campo dice `0347`, el cartel describe el `034`.

Es el error común #2 de la Fase 6, y la fase es tajante sobre cómo llamarlo: **no
es cosmético, es corrección contra bug.**

**Los dos cambios, y cuál es cuál**

El otro cambio en ese pipe es que `debounceTime(300)` fue reducido —alguien lo
bajó porque "se sentía lento"—. Eso **no es la causa**: es un amplificador. El
debounce controla *cuántas* validaciones se disparan; el operador de aplanamiento
controla *cuál gana*. Compruébalo en dos pasos:

- Restituye el `debounceTime(300)` y deja el `mergeMap`: el bug **sigue apareciendo**,
  solo que necesitas hacer una pausa de poco más de trescientos milisegundos en
  mitad del número. Menos frecuente, igual de incorrecto.
- Deja el debounce corto y pon `switchMap`: se disparan muchas peticiones —derroche
  de red— y **el resultado siempre es correcto**.

De ahí sale la conclusión que vale para el resto de tu carrera: **el debounce es una
optimización, el operador de aplanamiento es una decisión de correctitud.** Se
parecen porque los dos "reducen peticiones", y no son lo mismo.

**Y por qué escribir despacio lo arregla**

Porque con pausas largas solo hay una petición en vuelo por vez, y una petición
sola no puede cruzarse con nadie. Esa frase del ticket —*"si escribo despacio anda
bien"*— es un regalo: descarta de un plumazo el campo de texto, el reducer, el
componente y el backend. Ninguno de ellos se comporta distinto según la velocidad
de tipeo. **Lo único que cambia con la velocidad es cuántas cosas ocurren a la
vez**, y eso solo apunta a concurrencia.

**Parche mínimo**

```javascript
// src/features/sales/epics/validateNumberEpic.js
action$.pipe(
  ofType(numberValidationRequested.type),
  debounceTime(300),
  // switchMap: cada número nuevo CANCELA la validación anterior en vuelo.
  switchMap((action) => { /* … la petición, igual que antes … */ })
)
```

**La refactorización correcta**

`switchMap` con el `debounceTime(300)` restituido es la versión correcta y es la
que la Fase 6 ya tenía escrita. Lo que se puede agregar aparte, y que revela algo
más profundo, es una guarda en el reducer:

```javascript
numberValidationSucceeded(state, action) {
  // Ignora la respuesta de un número que ya no es el que el usuario está mirando.
  if (action.payload.number !== state.currentInput) return;
  state.validation = action.payload.status;
}
```

Es cinturón además de tirantes, y sobre todo es un olor a diseño que conviene
nombrar: **la acción no lleva ninguna identidad de la petición que la originó**.
Sin esa identidad, el store no tiene forma de saber si lo que le llega es actual o
llegó tarde, y depende por completo de que el epic haya cancelado bien.

**Prueba de regresión**

```javascript
// src/features/sales/epics/validateNumberEpic.test.js
test('la respuesta lenta de un número viejo no pisa a la del número nuevo', () => {
  const scheduler = new TestScheduler((actual, expected) =>
    expect(actual).toEqual(expected)
  );

  scheduler.run(({ hot, cold, expectObservable }) => {
    const action$ = new ActionsObservable(
      hot('a 400ms b', {
        a: numberValidationRequested({ number: '034' }),
        b: numberValidationRequested({ number: '0347' }),
      })
    );
    // El '034' tarda 900ms; el '0347', 100ms. Se cruzan a propósito.
    const api = { get: (n) => (n === '034' ? cold('900ms r') : cold('100ms r')) };

    // Solo debe emitir la validación del 0347. Con mergeMap aparecen las dos,
    // y la del 034 llega DESPUÉS.
    expectObservable(validateNumberEpic(action$, null, { api })).toBe(
      '801ms s', { s: numberValidationSucceeded({ number: '0347' }) }
    );
  });
});
```

Reproducir una inversión de orden en la aplicación requiere suerte y caos;
reproducirla con marbles es escribir dos números distintos. Ese es el argumento
entero a favor de `A11-marble-testing.md`.

**Prevención**

Una regla por defecto que resuelve el noventa por ciento de los casos:
**`switchMap` cuando solo importa el último resultado** —búsquedas, validaciones,
autocompletado, cualquier cosa atada a lo que el usuario está mirando ahora
mismo—; **`mergeMap` solo cuando cada operación es independiente y sus resultados
no se pisan** —enviar eventos, registrar métricas—. Y si en una revisión de código
aparece un `mergeMap`, que su autor tenga que decir en voz alta por qué no es
`switchMap`.

**Por qué llegó a producción**

Porque en la máquina de quien lo escribió la latencia es de tres milisegundos y
**las respuestas siempre vuelven en orden**. El orden de llegada no es una
propiedad del código: es una propiedad de la red. Y el código se escribe sobre una
red que en la práctica no existe.

Y sobrevivió porque el síntoma parece un problema de la interfaz —"el cartelito
dice cualquier cosa"— y porque es intermitente, así que quien fue a mirarlo escribió
el número una vez, despacio, vio que funcionaba, y cerró el ticket.

El costo real, en cambio, no es cosmético en absoluto: el ticket dice que se
perdió una venta. Un cartel que miente sobre la disponibilidad de un número es, en
este negocio, una decisión comercial tomada con datos falsos.

**Si tu causa fue distinta a esta**

Si dijiste *"es el debounce"*, lee arriba: cambia la frecuencia, no la
correctitud. Es la hipótesis más común y es una media verdad, que en depuración es
peor que una hipótesis equivocada — porque tocarla mejora el síntoma lo suficiente
como para dar por cerrado el caso.

Si dijiste *"el input pierde caracteres"*, mira el payload de las acciones
`numberValidationRequested`: están todas, completas y en orden. Lo que se desordena
es la vuelta, no la ida. Y si tu fix fue deshabilitar el campo mientras hay una
validación en curso, funciona y hace la aplicación notablemente peor de usar:
convertiste un problema de concurrencia en un problema de ergonomía.

</details>

---

## Incidente 17 — El resultado nunca llega y no aparece ningún error

> **Fase:** 7 · **Categoría:** RxJS / epics · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min

### 🎫 El ticket

Cerramos la rifa de las 8 de la noche y el sistema tenía que traer solo el
resultado de la lotería. Nunca lo trajo. Estuvimos hasta las 9 mirando la pantalla,
que decía "esperando resultado" todo el tiempo. Al final lo cargamos a mano
mirando la página de la lotería. En ningún momento salió ningún error ni ningún
aviso: solo decía esperando.

**Reportado por:** supervisor de ventas
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducir y decidir cuál de **dos causas plausibles** produjo este caso concreto.
Las dos dejan al usuario mirando "esperando resultado"; se distinguen con una sola
observación. Después, el fix.

### 🔧 Preparación

- **Rama:** `incidente/17`
- **Caos:** `CHAOS_LEVEL=high`, y **en el mock de la lotería, el del puerto
  `3002`** —no en el `3001`—. Hace falta que un tick reciba un `500`; sin eso el
  bug no se enciende. Es el error más común al preparar este incidente: subir el
  caos en el mock equivocado y concluir que no se reproduce.
- **Datos:** una rifa que acabe de pasar a `closed`, con el resultado ya disponible
  en el mock de lotería.

```bash
git checkout incidente/17
CHAOS_LEVEL=high npm run mock:lottery     # el 3002, no el 3001
npm start
# Cierra la rifa y deja la pantalla de resultado abierta, mirando Network.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Network, filtrado por `results`. No mires si hay errores: **cuenta los `GET` y fíjate
en qué momento dejan de salir**. Un polling sano deja un rastro regular en la
pestaña. La hora exacta en la que ese rastro se corta es el dato que decide todo el
diagnóstico.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`src/features/raffles/epics/pollingEpic.js`. Localiza el `catchError` y responde
una sola pregunta: ¿está adentro del tick, o envuelve al `timer` entero?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Cuando un `catchError` se dispara, emite su valor de reemplazo y **completa el
stream que envuelve**. Si lo que envuelve es el `timer`, ¿qué queda vivo después
del primer error?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, con el `CHAOS_LEVEL` y —explícitamente— **en qué mock** lo
pusiste.}}

**Evidencia observable**
{{La secuencia de `GET /results` con sus horas y sus status, y el momento exacto en
que dejan de aparecer.}}

```
{{los ticks, hasta que se cortan}}
```

**Hipótesis**
- ❌ Descartada: {{cuál de las dos causas descartaste, y con qué evidencia}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Las dos causas, y la observación que las separa**

**Causa A — el `catchError` envuelve al `timer`.** Cuando el primer `500` de la
lotería llega, el `catchError` lo atrapa, emite su acción de reemplazo y —esto es
lo que importa— **completa el stream que envuelve**, que es el `timer` entero. El
polling muere ahí. No hay más ticks, no hay más peticiones, y el store se queda
con el último estado que tenía: "esperando resultado". Es el error común #2 de la
Fase 7, y es el error #1 de la Fase 6 aplicado al polling: **el `catchError` mata
lo que envuelve.**

**Causa B — el `204` tratado como error.** La lotería devuelve `204` cuando el
sorteo todavía no salió, que es información legítima y frecuente: significa "sigue
preguntando". Si el epic lo trata como fallo, el store se llena de `pollingFailed`
mientras no pasa nada malo. Es el error común #4 de la Fase 7.

**Se distinguen con una sola columna de Network:**

| | Causa A — `catchError` mal ubicado | Causa B — el `204` como error |
|---|---|---|
| Los `GET /results` | **paran** y no vuelven nunca | **siguen saliendo** cada 3 s |
| En el store | nada nuevo tras el corte | `pollingFailed` acumulándose |
| Qué ve el usuario | "esperando resultado" | "esperando resultado" |

La pantalla dice lo mismo en los dos casos. La red no. **Cuando dos causas producen
la misma interfaz, la evidencia tiene que venir de una capa donde se comporten
distinto**, y esa es la razón por la que la pista 1 te manda a contar peticiones en
lugar de a buscar errores.

En este incidente concreto —el de las ocho de la noche— es la **causa A**: los
`GET` se cortan y no vuelven.

**Parche mínimo**

El `catchError` va adentro del tick, envolviendo la petición y no al `timer`:

```javascript
timer(0, POLLING_INTERVAL_MS).pipe(
  mergeMap(() =>
    from(apiLottery.get(`/results/${raffleId}`)).pipe(
      filter((res) => res.status === 200 && res.data),
      map((res) => resultReceived(res.data)),
      // Muere el tick, no el polling: el siguiente sale igual.
      catchError((error) => of(pollingFailed(toReadableError(error))))
    )
  ),
  takeUntil(/* … */)
)
```

**La refactorización correcta**

Dos cosas más, y la segunda es la que este incidente deja al descubierto:

1. **Reintento con espera creciente por tick**, que la Fase 7 ya trae: `500`, `1s`,
   `2s` antes de rendirse con ese tick. Un `500` aislado deja de tener consecuencia
   alguna.
2. **Un límite al "esperar"**. Si pasaron veinte minutos desde el cierre y no hay
   resultado, el sistema tiene que decirlo. Hoy "esperando resultado" significa las
   dos cosas a la vez: *"todavía no salió"* y *"me morí hace una hora"*. **Un
   estado que también significa su propio fallo es un defecto de diseño de
   estados**, y es literalmente el mismo defecto del incidente 07 una capa más
   arriba: nadie decidió cuánto es demasiado.

**Prueba de regresión**

```javascript
// src/features/raffles/epics/pollingEpic.test.js
test('un tick que falla no mata el polling: el siguiente sale igual', () => {
  const scheduler = new TestScheduler((actual, expected) =>
    expect(actual).toEqual(expected)
  );

  scheduler.run(({ hot, expectObservable }) => {
    const action$ = new ActionsObservable(hot('a', { a: startPolling({ raffleId: 1 }) }));
    // Primer tick: 500. Segundo tick: el resultado.
    const api = apiThatFailsOnce();

    // Con el bug, después de la 'f' no hay nada más: el timer murió.
    expectObservable(pollingEpic(action$, null, { api })).toBe('f 2999ms r', {
      f: pollingFailed(expect.anything()),
      r: resultReceived(expect.anything()),
    });
  });
});
```

Igual que en el incidente 13, lo que hace útil al test es **el segundo tick**. Un
test que solo verifique que un `500` produce un `pollingFailed` pasa con el bug
adentro.

**Prevención**

La regla, que conviene memorizar con estas palabras: **el `catchError` va donde
quieras que el error muera, y casi siempre eso es el Observable interno.** Ponerlo
más afuera no es "más seguro": es más destructivo.

Y para los epics de vida larga, un test de supervivencia obligatorio: un fallo, y
después la comprobación de que el siguiente ciclo ocurre igual.

**Por qué llegó a producción**

Porque el polling se probó contra una lotería sana, que es la única que existe en
la máquina de quien programa. El `500` de un tercero es exactamente el evento que
no puedes provocar en desarrollo si no construiste antes un mock que falle a
propósito — que es la razón entera por la que la Fase 3 existe.

Y llegó, sobre todo, porque el fallo se disfrazó de comportamiento normal. "Esperando
resultado" es un mensaje legítimo, tranquilizador, que el supervisor miró durante
una hora sin motivo para desconfiar. Los fallos que se ven iguales que el
funcionamiento correcto no generan tickets: generan gente esperando.

**Si tu causa fue distinta a esta**

Si dijiste *"la lotería no publicó el resultado"*, revisa el mock: el resultado
estaba ahí, con un `200` y su ganador, esperando a que alguien fuera a buscarlo.
Nadie fue. Si dijiste *"el `takeUntil` cortó de más"* —que sería el error común #3
de la Fase 7— es una hipótesis excelente y se descarta mirando **qué** ocurrió justo
antes del último `GET`: con un `takeUntil` de más, el corte coincide con un evento
concreto (el cierre, el logout, recibir el resultado); acá coincide con un `500`.
El momento del corte te dice quién lo cortó.

</details>
L4EOF
awk '/^## Incidente/{if(t)print t" -> "n; t=$0; n=0} {n++} END{print t" -> "n}' /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L4b.md

# --- 2026-09-10T02:10:12 · Read section 6 of phases 8, 9 and 10
sed -n '589,640p' 08-liquidacion-calculo-premio.md; echo "=========== FASE 09 §6"; sed -n '491,521p' 09-dashboard.md; echo "=========== FASE 10 §6"; sed -n '487,507p' 10-testing-minimo.md

# --- 2026-09-10T02:10:19 · Find dangling forensic references and exercise 23
grep -rn "Forense — Fase\|forense-fase" --include="*.md" . | grep -v completado_; echo "=== ej 23 fase 10 ==="; sed -n '507,560p' 10-testing-minimo.md | grep -n "23\.\|MetricCard" 

# --- 2026-09-10T02:11:17 · Draft incident 16
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L5a.md <<'L5EOF'
## Incidente 16 — La rifa siguió vendiendo después de la hora de cierre

> **Fase:** 7 · **Categoría:** Tiempo · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min
> · Hermano del incidente `be-12`, con otra causa raíz

### 🎫 El ticket

La Rifa de Navidad cerraba a las 8 de la noche y el sistema siguió aceptando
ventas después. Tenemos catorce números vendidos con hora posterior al cierre, y
uno de ellos salió sorteado. El vendedor de la costa dice que a él le cerró a la
hora que correspondía; el de la capital dice que le siguió dejando vender un rato
más. No sé si eso tiene algo que ver.

**Reportado por:** tesorería
**Ambiente:** PROD

### 🎯 Qué se te pide

Reproducir y localizar. Y prestarle atención a la última frase del ticket, que
parece un comentario al pasar y es el dato central: **dos vendedores en lugares
distintos vieron cerrar la misma rifa en momentos distintos.**

> ⚠️ **Sin declarar la zona horaria del navegador, este incidente no se
> reproduce.** No es un detalle de la preparación: es el mecanismo del bug. Si
> intentas reproducirlo sin fijar la zona horaria, vas a concluir que no pasa.

### 🔧 Preparación

- **Rama:** `incidente/16`
- **Caos:** `off`. El bug es determinista una vez que la zona horaria está fijada.
- **Datos:** una rifa con `closesAt` en `2024-12-20T20:00:00-05:00` y números
  disponibles para vender. La rama la deja cargada.
- **Zona horaria del navegador:** hay que cambiarla, y ahí está el experimento. En
  Chrome: DevTools → menú de tres puntos → More tools → Sensors → Location, o más
  simple, arrancar el navegador con la variable de entorno:

```bash
git checkout incidente/16
CHAOS_LEVEL=off npm run mock
TZ=America/Bogota npm start        # -05:00, la del cierre
# Y después, la misma prueba con:
TZ=America/Argentina/Buenos_Aires npm start    # -03:00
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Antes del código, haz el experimento que el ticket describe sin saberlo: reproduce
la misma venta, sobre la misma rifa, con dos zonas horarias distintas en el
navegador. Si el resultado cambia, ya sabes que la causa está en cómo se compara
el tiempo, y no en el estado de la rifa.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

La guarda que decide si una rifa admite ventas. Busca dónde se compara la hora de
cierre con la hora actual, y mira **con qué** se comparan: ¿dos instantes, o dos
pedazos de fecha?

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

¿Qué devuelve `new Date('2024-12-20T20:00:00-05:00').getHours()` en un navegador
configurado en `-03:00`? Escríbelo en la consola antes de contestar de memoria.

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, y **obligatorio**: la zona horaria del navegador en cada
intento, y el `closesAt` exacto de la rifa con su offset.}}

**Evidencia observable**
{{El resultado del mismo experimento en dos zonas horarias, lado a lado.}}

```
{{TZ=...  → vendió / no vendió    ·    TZ=...  → vendió / no vendió}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

La guarda de cierre desarma la fecha en componentes en vez de comparar instantes:

```javascript
// ❌ getHours() devuelve la hora EN LA ZONA DEL NAVEGADOR, no en la del cierre.
const closing = new Date(raffle.closesAt);
if (new Date().getHours() < closing.getHours()) {
  // …permitir la venta
}
```

Un instante en el tiempo es un número absoluto: el momento en que ocurre el cierre
es el mismo para todo el mundo. Pero `getHours()` no devuelve ese número: devuelve
cómo **se ve** ese instante desde donde está el reloj que pregunta. Las 20:00 de
`-05:00` son las 22:00 en `-03:00`, y por eso el vendedor de la capital pudo seguir
vendiendo dos horas más que el de la costa. Es el error común #1 de la Fase 7.

Y por eso el comentario final del ticket —*"no sé si eso tiene algo que ver"*— era
el diagnóstico entero. **Cuando dos usuarios ven comportamientos distintos frente
al mismo dato, la diferencia está en sus máquinas, no en el dato.** Es la misma
forma de razonar del incidente 02 y del 20, en tres capas completamente distintas.

**Parche mínimo**

Comparar instantes contra instantes, que es lo que hace `isPastClosing`:

```javascript
// src/features/raffles/closing.js
export function isPastClosing(closesAt) {
  return Date.now() >= new Date(closesAt).getTime();
}
```

`getTime()` devuelve milisegundos desde la época, en UTC, idéntico en todo el
planeta. La zona horaria deja de participar de la decisión y pasa a ser lo único
que debería haber sido siempre: un asunto de **presentación**.

**La refactorización correcta**

Dos capas, y la segunda es la importante:

1. **Centralizar toda comparación de tiempo en `closing.js`** y prohibir
   `getHours()`, `getDate()` y `getMonth()` en el resto del código con una regla de
   lint. Desarmar una fecha es legítimo para mostrarla y nunca para decidir con
   ella.
2. **Que la hora la decida el servidor.** Hoy la guarda usa el reloj del navegador,
   y el reloj del navegador lo controla el usuario: adelantarlo dos horas es un
   ajuste de la configuración del sistema operativo. Toda esta guarda es una
   comodidad de la interfaz, no una garantía. La garantía tiene que estar del otro
   lado del cable, y eso es la deuda 💸 de `serverNow` que la Fase 7 declara y no
   paga.

**Prueba de regresión**

```javascript
// src/features/raffles/closing.test.js
describe('isPastClosing', () => {
  const closesAt = '2024-12-20T20:00:00-05:00';   // 01:00 UTC del 21

  test.each([
    'America/Bogota',                  // -05:00
    'America/Argentina/Buenos_Aires',  // -03:00
    'Europe/Madrid',                   // +01:00
    'Asia/Tokyo',                      // +09:00
  ])('da el mismo resultado en %s', (tz) => {
    process.env.TZ = tz;
    // Un instante indiscutiblemente posterior al cierre.
    jest.setSystemTime(new Date('2024-12-21T02:00:00Z'));

    expect(isPastClosing(closesAt)).toBe(true);
  });
});
```

La forma del test es la lección: **la misma aserción, repetida en cuatro zonas
horarias**. Un test de tiempo que corre en una sola zona no prueba nada sobre
tiempo; prueba sobre la máquina que lo corrió — y eso lleva directo al incidente 20.

**Prevención**

La regla de lint contra los desarmadores de fecha, los cuatro casos de prueba por
zona, y una convención de datos que ahorra la mitad de estos bugs: **todas las
fechas viajan y se guardan con offset explícito** (`2024-12-20T20:00:00-05:00`),
nunca como `2024-12-20 20:00`. Una fecha sin offset no es un instante: es un texto
que cada máquina interpreta como quiere.

**Por qué llegó a producción**

Porque todo el equipo está en la misma zona horaria, y en una sola zona horaria
este código **es correcto**. No hay ninguna prueba, ninguna revisión y ninguna demo
que pueda revelar el error mientras todos los relojes coincidan. El bug estuvo
latente desde el primer día y se activó el día que se vendió una rifa desde otra
provincia — sin que cambiara una línea de código.

Y llegó, además, porque el descuadre es pequeño y tardío: dos horas de más en un
cierre no llaman la atención hasta que alguien cruza las horas de venta con la
hora de cierre, que es algo que solo pasa cuando ya hay un problema.

**Si tu causa fue distinta a esta**

Si dijiste *"el estado de la rifa no se actualizó a `closed`"*, es una hipótesis
buena y hay que descartarla mirando el store: el `status` puede estar correcto y la
venta pasar igual, porque la guarda de la hora dura es independiente del enum. De
hecho la Fase 7 lo dice explícitamente al explicar por qué el selector **no** llama
a `isPastClosing`: el enum es del store, la hora es del reloj, y son dos preguntas
distintas.

**Y acá está el cruce con el track BE.** El incidente `be-12` —*"vendimos doscientos
números después del cierre"*— tiene el mismo síntoma con la causa una capa más
abajo: allá la comparación de instantes está bien hecha, y el problema es **quién
tiene autoridad sobre la hora**. Acá el navegador se equivoca al interpretar el
instante; allá el navegador acierta y aun así no debería ser él quien decida. Si
haces el track BE, este par enseña la diferencia entre *calcular bien el tiempo* y
*tener derecho a decidir sobre el tiempo*.

</details>
L5EOF
echo ok

# --- 2026-09-10T02:13:23 · Draft incidents 18 and 19
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L5b.md <<'L5EOF'
## Incidente 18 — La liquidación da un centavo de diferencia

> **Fase:** 8 · **Categoría:** Dinero · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 45-60 min
> · Hermano del incidente `be-13`, con otra causa raíz

### 🎫 El ticket

La liquidación de la rifa chica de la semana pasada da un centavo de diferencia
contra lo que sumamos a mano. Un centavo. Ya sé que suena a nada y que van a
decirme que lo redondee, pero necesito entender de dónde sale antes de firmarla,
porque si es un centavo con tres números, no sé cuánto es con diez mil.

**Reportado por:** tesorería
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir con los datos exactos del reporte, localizar el cálculo culpable y
arreglarlo. Y contestarle a tesorería la pregunta que hizo, que es la correcta:
**¿cuánto es este error con diez mil números?**

Este incidente es el más chico del cuaderno en tamaño del síntoma y de los más
grandes en tamaño de la causa. Esa desproporción es la lección entera.

### 🔧 Preparación

- **Rama:** `incidente/18`
- **Caos:** `off`. No hay ninguna red involucrada en el error: es aritmética.
- **Datos, y son exactos:** una rifa con `numberPriceInPesos: 0.1` y **tres**
  números vendidos. Sí, diez centavos por número: es el precio más ridículo
  posible y es justo el que hace visible el problema en el primer decimal.

```bash
git checkout incidente/18
CHAOS_LEVEL=off npm run mock
npm start
# Liquida esa rifa y compara el total con lo que dan tres veces diez centavos.
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

No hace falta la aplicación. Abre una consola de Node y escribe `0.1 + 0.1 + 0.1`.
Mira el resultado con atención, hasta el último dígito. Si eso te sorprende, ya
tienes la causa; si no te sorprende, ya sabes dónde buscarla en el código.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

`calculateTotalCollected` y todo lo que la alimenta. La Fase 8 pide una regla:
**el dinero vive en centavos enteros**. Busca el punto exacto del recorrido donde
esa regla se rompe — dónde entra un número con coma, o dónde una división deja de
ser entera.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Un número de punto flotante de doble precisión no puede representar 0,1 de forma
exacta, del mismo modo que en decimal no puedes escribir un tercio con una
cantidad finita de dígitos. ¿Qué pasa entonces cuando sumas tres de esos, y qué
pasa cuando multiplicas el resultado por cien para "pasarlo a centavos"?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, con los valores exactos: precio, cantidad de números y el total
que esperabas contra el que salió.}}

**Evidencia observable**
{{El resultado de correr la función pura en la consola, con esos mismos datos.
Este es el único incidente del cuaderno donde la evidencia decisiva no está en el
navegador.}}

```
{{entrada, salida esperada, salida real, con todos sus decimales}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Y en cuál de las cuatro capas de auditoría de la Fase 8 apareció:
el cálculo, sus entradas, el estado o la presentación.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta. Y la respuesta a
tesorería: cuánto es el error con diez mil números.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`calculateTotalCollectedBroken` hace la aritmética en pesos con decimales y
convierte a centavos al final:

```javascript
// ❌ 0.1 no existe en binario. Ni 0.2. Ni 0.3.
const totalInPesos = soldNumbers.length * raffle.numberPriceInPesos;
const totalInCents = Math.round(totalInPesos * 100);
```

En la consola:

```
> 0.1 + 0.1 + 0.1
0.30000000000000004
> 3 * 0.1 * 100
30.000000000000004
```

Un `double` de la IEEE 754 no puede representar 0,1 exactamente, igual que en
decimal no puedes escribir un tercio con dígitos finitos. La representación real
es un poquito mayor, y al multiplicar por cien ese poquito sale a la superficie. El
`Math.round` a veces lo tapa y a veces no, según hacia qué lado caiga el error —y
eso explica que la diferencia aparezca en unas liquidaciones y en otras no—.

La causa está en la **primera** de las cuatro capas de auditoría de la Fase 8: la
función pura. Y por eso el diagnóstico se hace en una consola de Node, sin abrir el
navegador. Cuando el descuadre aparece ahí, no es React, no es Redux y no es la
red: es aritmética, y terminaste.

**La respuesta a tesorería**

Es la pregunta más importante del ticket y merece un número, no una tranquilización.
El error de representación no es constante ni crece de forma predecible: **depende
de los valores**, y puede cancelarse o acumularse. Con tres números da un centavo;
con diez mil puede dar cero, o puede dar decenas — y, lo que es peor, el mismo
cálculo con los mismos datos da siempre lo mismo, así que parece estable hasta que
un día no lo es.

La respuesta honesta no es *"con diez mil números serían N centavos"*. Es: **este
cálculo no tiene una cota de error que podamos prometer, y por eso hay que sacar el
float en vez de acotarlo.**

> 🧠 **La desproporción es el mensaje.** El síntoma mide un centavo. La causa es
> que el sistema entero está haciendo aritmética de dinero sobre un tipo que no
> puede representar dinero. Un ticket pequeño puede tener una causa estructural, y
> la magnitud del síntoma no dice nada sobre la magnitud del problema. En dinero,
> esa confusión es especialmente cara: **el redondeo esconde el error justo lo
> suficiente como para que nadie lo investigue.**

**Parche mínimo**

Enteros de punta a punta. El precio se guarda en centavos, y no hay ninguna
multiplicación por cien en ningún lado:

```javascript
// El dato entra en centavos y no vuelve a salir de ahí.
const totalInCents = soldNumbers.length * raffle.numberPriceInCents;   // 3 * 10 = 30
```

La Fase 8 es explícita sobre cómo llamar a esto: **no es refactor, es sacar el
float de la línea que lo metió.**

**La refactorización correcta**

Que el float no pueda entrar. Tres piezas:

1. **Un solo tipo de dinero en todo el sistema**, en centavos enteros, con el
   sufijo en el nombre (`numberPriceInCents`, `prizeAmountInCents`). El nombre es
   la mitad de la prevención: `price` a secas no le dice a nadie en qué unidad
   está.
2. **`formatCents` con su aserción de entero**, que es la alarma: si explota, no es
   un bug de `formatCents` sino la prueba de que un cálculo de más arriba devolvió
   un decimal. Es el error común #2 de la Fase 8 y conviene resistir la tentación
   de "arreglarlo" ablandando la aserción.
3. **Repartos con resto explícito.** Al dividir un premio entre ganadores, la
   división entera deja un resto que hay que asignar a alguien por una regla
   escrita, no perderlo en un redondeo. La mecánica está en
   `A10-aritmetica-de-dinero.md`.

**Prueba de regresión**

```javascript
// src/features/settlements/money.test.js
test('el total de tres números a diez centavos es exactamente 30', () => {
  const raffle = { numberPriceInCents: 10 };
  const sold = ['0001', '0002', '0003'];

  const total = calculateTotalCollected(raffle, sold);

  expect(total).toBe(30);              // no toBeCloseTo: exacto o nada
  expect(Number.isInteger(total)).toBe(true);
});
```

El detalle que hace útil este test es lo que **no** usa. `toBeCloseTo` es la
herramienta correcta para medir cosas del mundo físico y la herramienta
equivocada para el dinero: un test de dinero que tolera aproximaciones es un test
que aprueba justamente el bug que tiene que impedir.

**Prevención**

La aserción de entero en la frontera de presentación, el sufijo de unidad en todos
los nombres, y una regla de lint que prohíba multiplicar o dividir cualquier
identificador que termine en `Cents` sin pasar por los ayudantes de `money.js`. Y
un test de propiedad barato: para cualquier precio entero y cualquier cantidad, el
total tiene que ser entero.

**Por qué llegó a producción**

Porque durante años los precios fueron números redondos —mil pesos, dos mil
quinientos—, y con valores así el error de representación se esconde debajo del
redondeo y nunca sale. El bug estuvo escrito y latente durante toda la vida del
sistema, y lo despertó una decisión de negocio: la rifa chica, con números a diez
centavos, que nadie consultó con nadie porque no tenía por qué consultarla.

Y sobrevivió, sobre todo, por una reacción cultural que el ticket anticipa con una
lucidez notable: *"van a decirme que lo redondee"*. En la mayoría de los equipos,
un centavo de diferencia se cierra como "error de redondeo, no es nada". La persona
de tesorería que se negó a firmar hasta entenderlo hizo exactamente lo correcto, y
es la razón por la que este incidente existe.

**Si tu causa fue distinta a esta**

Si dijiste *"falta redondear"*, ese es el reflejo que hay que desarmar: redondear
**es** la causa de que el error se vuelva invisible en unos casos y visible en
otros. Agregar más redondeo no arregla la aritmética, la disfraza mejor. Si dijiste
*"el margen negativo también está mal"* —el error común #4 de la Fase 8—, cuidado:
un margen negativo es un hecho, no un defecto. La casa pagó más premio del que
recaudó, y esconderlo con un `Math.max(0, margin)` es falsear la liquidación.

**Y acá está el cruce con el track BE.** El incidente `be-13` —*"la liquidación dice
340.000 y las ventas suman 355.000"*— tiene un descuadre parecido y una causa
distinta: allá la aritmética está bien y lo que falla es **la fuente de los
datos**, un cliente calculando con una foto vieja. Acá los datos son correctos y el
cálculo los arruina. Cuando una cifra no cuadra, esas son las dos preguntas, en
este orden: *¿el cálculo está mal?* y *¿los datos que entraron eran los de ahora?*

</details>

---

## Incidente 19 — El dashboard se arrastra al final del día

> **Fase:** 9 · **Categoría:** Performance · **Dificultad:** 🟠
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 50-65 min
> · Hermano del incidente `be-05`, con otra causa raíz

### 🎫 El ticket

El tablero de control se arrastra a partir de las seis de la tarde. A la mañana
vuela y a la tarde tengo que esperar dos o tres segundos cada vez que hago clic en
algo, y el ventilador de la máquina se pone a soplar. Al otro día a primera hora
vuelve a andar bien. Las máquinas son las mismas de siempre.

**Reportado por:** supervisor de ventas
**Ambiente:** UAT

### 🎯 Qué se te pide

Reproducir —que en este incidente es la mitad difícil, porque hace falta volumen—,
medir con el Profiler, y arreglar. Y explicar por qué "a la mañana vuela y a la
tarde no" es una descripción precisa del mecanismo, no una exageración.

### 🔧 Preparación

- **Rama:** `incidente/19`
- **Caos:** `off`. El caos agrega latencia de red y acá lo que se mide es tiempo de
  render: mezclarlos hace imposible leer el Profiler.
- **Datos, y son el corazón del incidente:** hace falta **volumen**. Con las tres
  rifas de demostración no se nota nada, y esa es exactamente la razón por la que
  el bug llegó a producción. La rama trae un script que siembra un día completo de
  ventas:

```bash
git checkout incidente/19
node scripts/seedHeavyDay.js       # 40 rifas · ~12.000 números vendidos
CHAOS_LEVEL=off npm run mock
npm start
# Abre /dashboard y cambia de rifa varias veces con el Profiler grabando.
```

> 🧭 Si el script no existe en tu repositorio todavía, escríbelo: es parte del
> incidente. Un bug de rendimiento sin datos que lo despierten es un bug que no
> puedes investigar, y armar el juego de datos es tan trabajo forense como leer el
> Profiler.

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

React DevTools → **Profiler**. Graba, interactúa con el tablero, frena, y mira dos
cosas: qué componentes se volvieron a renderizar y —el panel te lo dice— **por
qué**. Un componente que se re-renderiza porque cambió una parte del store que no
usa es una señal fuerte.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

Pon un `console.count('computeTopNumbers')` dentro de la función pura, temporalmente,
y cuenta cuántas veces corre por cada interacción. Compara ese número con cuántas
veces **debería** correr, que es: solo cuando cambian los datos de los que depende.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

La memoización está puesta. Mira su array de dependencias con mucha atención y
pregúntate: ese valor que está ahí adentro, ¿es el mismo objeto entre un render y
el siguiente, o es uno nuevo con el mismo contenido?

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, y **obligatorio**: cuántas rifas y cuántos números vendidos hay
en el `db.json` con el que reprodujiste. Sin ese número, tu reproducción no la
puede repetir nadie.}}

**Evidencia observable**
{{Los tiempos del Profiler y el número del `console.count`. Este incidente se
diagnostica con dos números, no con una impresión.}}

```
{{render de X ms   ·   computeTopNumbers corrió N veces}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea.}}

**Tu fix**
{{El parche mínimo. Aparte, la refactorización correcta.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

`DashboardPage` memoiza un cálculo caro con una dependencia que se **crea nueva en
cada render**:

```javascript
// ❌ Object.values(...) devuelve un array nuevo cada vez que corre esta línea.
const topNumbers = useMemo(
  () => computeTopNumbers(byNumber),
  [Object.values(byNumber)]
);
```

`useMemo` compara sus dependencias por identidad referencial. Un array recién
creado nunca es idéntico al de la vuelta anterior, aunque tenga exactamente el
mismo contenido, así que la caché se invalida **siempre**. El `console.count` lo
muestra sin ambigüedad: `computeTopNumbers` corre en cada render.

**La memoización existe y no sirve para nada.** Es peor que no tenerla, porque paga
el costo del cálculo y además el de mantener y comparar la caché — y, sobre todo,
porque parece resuelto. Nadie va a sospechar de un `useMemo` que está ahí,
prolijamente escrito, en la línea correcta. Es el error común #1 de la Fase 9.

**Y por qué "a la mañana vuela y a la tarde no"**

Porque el costo de `computeTopNumbers` crece con la cantidad de números vendidos, y
esa cantidad crece a lo largo del día. A las nueve de la mañana el cálculo inútil
tarda un milisegundo y nadie lo nota; a las seis de la tarde, con doce mil ventas
en el store, tarda cientos de milisegundos y ocurre en cada render.

La observación del supervisor es exacta: **no cambió la aplicación, cambió el
tamaño de los datos**. Un bug de rendimiento casi nunca es "el sistema está lento";
es "hay una operación cuyo costo depende de algo que crece". Y por eso el ticket
trae la hora del día: es la variable independiente, servida en bandeja.

> 🧠 **Este es el mismo error del incidente 05 con otra sintaxis.** Allá se
> capturaba un valor una sola vez y no se volvía a preguntar; acá se pregunta
> siempre porque la clave de comparación nunca coincide. Los dos son fallos de
> *identidad*: confundir "el mismo contenido" con "el mismo objeto" es una de las
> dos o tres confusiones que producen más bugs en JavaScript.

**Parche mínimo**

Depender del objeto del store, que sí mantiene su referencia mientras no cambie:

```javascript
const topNumbers = useMemo(() => computeTopNumbers(byNumber), [byNumber]);
```

**La refactorización correcta**

Sacar el cálculo del componente. Un `createSelector` de Reselect memoiza contra el
store, garantiza referencia estable y —lo más importante— **el cálculo del dominio
deja de vivir en la capa de presentación**:

```javascript
// src/features/sales/selectors.js
export const selectTopSoldNumbers = createSelector(
  [(state) => state.sales.byNumber],
  computeTopNumbers
);
```

```javascript
// DashboardPage.jsx — sin useMemo, sin dependencias que vigilar.
const topNumbers = useSelector(selectTopSoldNumbers);
```

La Fase 9 es clara en que esta es la corrección correcta y no un lujo: el
`useMemo` bien puesto arregla este caso, y el selector hace que el caso no pueda
volver a existir desde ningún otro componente que necesite el mismo dato.

**Prueba de regresión**

```javascript
// src/features/sales/selectors.test.js
test('el selector no recalcula si los datos no cambiaron', () => {
  const state = { sales: { byNumber: { '0347': 'sold' } } };

  const first = selectTopSoldNumbers(state);
  const second = selectTopSoldNumbers(state);

  // toBe, no toEqual: lo que se prueba es la IDENTIDAD, no el valor.
  expect(second).toBe(first);
});
```

`toEqual` acá pasaría siempre, incluso con la memoización rota, porque dos
recálculos del mismo dato dan el mismo contenido. Es el error común #3 de la Fase
10, y es la trampa más silenciosa de los tests de memoización: un test verde que no
prueba nada.

**Prevención**

Una regla concreta para las revisiones de código: **en el array de dependencias de
un `useMemo` o un `useCallback` no puede aparecer una llamada a función**.
`[Object.values(x)]`, `[items.filter(…)]`, `[{ id }]` son todos el mismo error. Si
la dependencia hay que calcularla, o se memoiza también, o —mejor— el cálculo entero
se va a un selector.

Y una operativa: medir el tablero con el juego de datos de un día cargado, no con
tres rifas de ejemplo. Un banco de datos realista debería ser parte del repositorio,
no algo que se improvisa el día del incidente.

**Por qué llegó a producción**

Porque en desarrollo hay tres rifas. El `useMemo` se agregó de buena fe —alguien vio
un cálculo caro y lo memoizó, que es exactamente lo que hay que hacer—, se probó, la
pantalla anduvo rápido, y ahí terminó todo. **Con datos de juguete, la memoización
rota y la memoización correcta se comportan igual.** No hay forma de distinguirlas
mirando la pantalla; solo el `console.count` o el Profiler las separan, y nadie los
abre cuando algo va rápido.

Y el segundo motivo es que el rendimiento se degrada gradualmente. No hay un día en
que "se rompió": hay meses en que fue empeorando, y cada semana el sistema estuvo
apenas un poco peor que la anterior, que es la velocidad exacta a la que un equipo
se acostumbra a cualquier cosa.

**Si tu causa fue distinta a esta**

Si dijiste *"faltan `React.memo` en los componentes hijos"*, puede ser cierto y no
es lo principal: mide primero. Agregar memoización sin medir es cómo se llega a este
bug, no cómo se sale de él. Si dijiste *"hay que paginar la tabla"*, también es
razonable y no cambia nada mientras el cálculo se rehaga en cada render: estarías
pintando menos filas y calculando lo mismo. Y si tu fix fue subir el intervalo del
refresco para que haya menos renders, tapaste el síntoma reduciendo la frecuencia
con la que se manifiesta.

**Y acá está el cruce con el track BE.** El incidente `be-05` —*"todo funciona hasta
que hay gente"*— comparte el patrón *"anda bien hasta que crece"* y la causa vive
del otro lado del cable: el pool de conexiones agotado. Cuando algo se degrada con
el volumen, las dos preguntas son *¿qué crece?* y *¿en qué orilla está el recurso
que se acabó?* — acá es tiempo de CPU en el navegador, allá son conexiones a la
base.

</details>
L5EOF
echo ok

# --- 2026-09-10T02:15:13 · Draft incident 20 and measure L5
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L5c.md <<'L5EOF'
## Incidente 20 — El test pasa en mi máquina y falla en la de al lado

> **Fase:** 10 (se abre) · 11 (se cierra) · **Categoría:** Testing · **Dificultad:** 🔴
> **Estado:** ⬜ Sin empezar · **Abierto:** — · **Cerrado:** —
> **Tiempo sugerido:** 70-90 min
> · Hermano del incidente `be-15`, con otra causa raíz

### 🎫 El ticket

Subí un cambio que no toca nada de fechas y el pipeline se puso en rojo con un test
de `MetricCard` que yo ni miré. En mi máquina pasa. Le pedí a un compañero que lo
corriera y a él también le pasa. En el servidor de integración falla siempre.
Llevamos tres días sin poder integrar nada y ya hay dos personas corriendo la suite
con el test salteado para poder trabajar.

**Reportado por:** el propio equipo
**Ambiente:** CI (en desarrollo "pasa")

### 🎯 Qué se te pide

Este incidente cierra el arco del cuaderno y es el único que **no se reproduce en
la aplicación sino en la suite de pruebas**. El entregable tiene tres partes, y la
tercera es la que importa:

1. Reproducirlo **en tu máquina**, que —adelanto— no se logra tocando el código.
2. Localizar la causa, y contestar una pregunta que suena filosófica y es
   perfectamente práctica: **¿el test está mal, o el test tiene razón?**
3. **Tomar una decisión y escribirla**: hotfix o refactorización, con sus
   consecuencias. Este es uno de los tres incidentes del cuaderno que **no termina
   en un parche**, sino en un documento que alguien firma.

> 🧭 **Se abre en la Fase 10 y se cierra en la Fase 11.** La Fase 10 te da las
> herramientas para reproducirlo; el criterio para decidir —cuándo un parche es
> profesional y cuándo es una tapadera— es lo que aporta la Fase 11. Si llegaste
> acá desde la 10, reprodúcelo y déjalo en 🟡 En análisis.

### 🔧 Preparación

- **Rama:** `incidente/20`
- **Caos:** no aplica; no hay red en juego.
- **Datos:** ninguno del `db.json`. Lo que hace falta es cambiar **tu máquina**, y
  ahí está la primera lección: la reproducción de este incidente no se consigue
  editando archivos.
- **Y hay que declarar dos cosas** que en el resto del cuaderno son contexto y acá
  son el mecanismo: **la zona horaria** y **la hora del sistema** de la máquina que
  corre la suite.

```bash
git checkout incidente/20
npm test -- MetricCard                          # tu zona horaria: pasa
TZ=UTC npm test -- MetricCard                   # la del runner: falla
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

Ni el test ni el código cambiaron, así que lo que cambió es **dónde corre**. Antes
de abrir un archivo, escribe la lista de todo lo que difiere entre tu máquina y el
servidor de integración: sistema operativo, versión de Node, configuración
regional, **zona horaria**, hora del sistema. Después tacha las que no puedan
afectar a un componente que muestra una fecha.

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

El `MetricCard` de fechas y lo que le llega por props. La pregunta concreta:
**¿quién decide qué día es "hoy"?** Busca de dónde sale ese dato y cuántas veces
podría dar respuestas distintas para el mismo instante.

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

Corre el test con `TZ=UTC` delante. Si cambia el resultado, la pregunta ya no es
"por qué falla el test" sino **"por qué el resultado del componente depende de la
máquina que lo ejecuta"**.

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución.}}

**Reproducción**
{{Pasos numerados, y **obligatorio**: la zona horaria y la hora del sistema en cada
intento, tuyas y las del runner. Sin esos cuatro datos este incidente no se puede
contar.}}

**Evidencia observable**
{{La salida del test en las dos configuraciones, con el texto esperado y el
recibido.}}

```
{{TZ=...  → verde     ·     TZ=UTC  → esperaba "20/12", recibió "21/12"}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó. Anota especialmente si
  pasaste por "es un test flaky" y cómo lo descartaste}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea. Y la respuesta a la pregunta: ¿el test está mal o tiene razón?}}

**Tu decisión**
{{Acá no va un parche: va una decisión argumentada. Cuál de los dos caminos tomas,
qué te cuesta, qué queda sin resolver, quién tiene que estar de acuerdo, y en qué
fase se paga lo que dejas pendiente. Escríbelo como se lo mandarías a tu equipo.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

El `MetricCard` de fechas calcula "hoy" con `new Date()` adentro del componente y
lo formatea con la zona horaria de la máquina. El test asegura un texto concreto.
En tu máquina, en `-05:00`, el instante de la prueba cae el día 20; en el runner,
que corre en `UTC` —el valor por defecto de prácticamente todos los servidores de
integración—, el mismo instante cae el día 21. El test dice que esperaba `20/12` y
recibió `21/12`, y las dos afirmaciones son correctas.

**Y ahora la pregunta del enunciado: el test tiene razón.**

Esto es lo que hay que llevarse del incidente. La lectura cómoda es "el test es
frágil, arreglemos el test". La lectura correcta es que el test **descubrió un
defecto real del componente**: su salida depende de estado ambiente —el reloj y la
zona horaria de quien lo ejecuta— que nadie le pasó y que nadie eligió. Ese mismo
defecto, en producción, es el incidente 16 en otra pantalla: dos usuarios en
provincias distintas ven cosas distintas sobre el mismo dato.

> 🧠 **Un test no es flaky solo porque falle donde no esperabas.** Descarta esa
> hipótesis con un número: en el runner falla el **100%** de las veces, y en tu
> máquina el **0%**. Eso no es aleatoriedad: es un resultado perfectamente
> determinista en dos ambientes distintos. Flaky sería fallar a veces en el
> **mismo** ambiente. Confundir las dos cosas lleva directo a la peor decisión
> posible, que es reintentar el test hasta que pase.

Y el detalle más grave del ticket no es el rojo: es que **dos personas ya lo están
salteando**. Un test que el equipo aprende a ignorar es peor que un test que no
existe, porque sigue contando en la cobertura y ya no protege nada. Cada día que
el rojo sobrevive, más gente aprende a convivir con él.

**La decisión, que es el entregable**

**Opción A — el hotfix.** Fijar el ambiente de la suite: la zona horaria y el reloj,
en la configuración de Jest.

```javascript
// jest.setup.js
process.env.TZ = 'America/Bogota';
jest.useFakeTimers().setSystemTime(new Date('2024-12-20T15:00:00-05:00'));
```

Cuesta quince minutos, desbloquea el pipeline hoy y **no arregla nada**: el
componente sigue siendo no determinista en producción. Peor todavía, fijar una sola
zona horaria en los tests **esconde la familia entera de errores del incidente
16**, porque garantiza que ninguna prueba vuelva a ejercitar otra zona.

**Opción B — la refactorización.** Que el reloj sea una dependencia explícita: el
`MetricCard` recibe `now` por props o por contexto, y no llama a `new Date()` nunca.
El componente se vuelve una función pura de sus entradas, el test deja de depender
de la máquina, y de paso queda abierto el camino para pagar la deuda 💸 de
`serverNow` que la Fase 7 declaró: que la hora de referencia venga del servidor y
no del navegador.

Cuesta más, toca varios componentes y no se termina en una tarde.

**La decisión recomendada, y por qué**

Aplicar **A hoy**, con dos condiciones que son las que la separan de una tapadera:

1. **La suite corre en más de una zona horaria**, no en una fija. Es una matriz de
   dos o tres valores en el pipeline, y convierte el hotfix en algo que además
   protege:

```javascript
// jest.setup.js — la zona la decide el pipeline, no el archivo.
process.env.TZ = process.env.TEST_TZ || 'UTC';
```

2. **Queda anotado en `A12-mapa-de-deuda-tecnica.md`** con su fecha y su destino, y
   **B se agenda en la Fase 11**, que es donde el curso paga deuda. Una deuda que
   no está escrita no es una deuda: es un olvido con buena intención.

Y la parte que casi nunca se hace: **escribirlo**. Que quede dicho que se eligió el
parche a sabiendas, qué queda sin resolver y cuándo se paga. Un hotfix documentado
y agendado es una decisión profesional; el mismo hotfix sin escribir es cómo nace
la deuda que nadie recuerda haber contraído.

> 🧭 **Y esto es lo que distingue a este incidente de los otros diecinueve.** Acá no
> hay un `git diff` que sea la respuesta. El entregable es un párrafo, una entrada
> en el mapa de deuda y un acuerdo. En un equipo de mantenimiento real, buena parte
> del trabajo termina así — y casi nunca se practica.

**Prueba de regresión**

```javascript
// src/features/dashboard/MetricCard.test.jsx
describe.each(['UTC', 'America/Bogota', 'Asia/Tokyo'])('en %s', (tz) => {
  beforeAll(() => { process.env.TZ = tz; });

  test('muestra la fecha del cierre, no la de la máquina', () => {
    render(<MetricCard label="Cierre" date="2024-12-20T20:00:00-05:00" now={FIXED_NOW} />);

    // El mismo texto en las tres zonas: eso es lo que se está probando.
    expect(screen.getByText('20/12/2024')).toBeInTheDocument();
  });
});
```

Igual que en el incidente 16, la forma del test **es** la corrección: la misma
aserción repetida en varias zonas horarias. Un test de fechas que corre en una sola
zona no prueba nada sobre fechas.

**Prevención**

Tres cosas, en orden de valor. La matriz de zonas horarias en el pipeline, que es
lo único que impide que esto vuelva. Una regla de revisión: **`new Date()` no se
llama dentro de un componente** — el reloj es una dependencia y se inyecta como
cualquier otra. Y una política sobre los tests rojos: un test que falla se arregla
o se borra, con su motivo; saltearlo no es una tercera opción.

**Por qué llegó a producción**

Porque nadie decidió nunca cuál era la zona horaria de la suite, y el valor por
defecto es "la de quien la corra". Mientras la suite solo corrió en las máquinas
del equipo —todas en la misma zona— la ambigüedad no tuvo consecuencias. El día que
se creó el pipeline se agregó un ejecutor más, en UTC, y la divergencia nació ahí:
**no la produjo un cambio de código, la produjo un cambio de participantes.**

Y el segundo motivo es que el sistema no tuvo tests durante años
(`00-historia-del-sistema.md` §3: la Era 1 no dejó ninguno). Una suite joven sobre
un código viejo va a encontrar defectos que llevaban años ahí, y los va a reportar
todos juntos, en forma de rojos que parecen problemas de la suite. Sostener que el
test tiene razón, en ese contexto, requiere más carácter que conocimiento.

**Si tu causa fue distinta a esta**

Si dijiste *"es flaky, hay que reintentarlo"*, mira arriba: 100% y 0% no es
aleatoriedad. Si dijiste *"el runner tiene mal la hora"*, no: el runner tiene la
hora perfectamente bien, en UTC, que es la configuración correcta para un servidor.
El que hace una suposición indebida es el componente. Y si tu fix fue cambiar el
texto esperado del test para que coincida con lo que devuelve el runner, dejaste el
pipeline en verde y el componente roto en las dos zonas — y ahora el test miente en
tu máquina.

**Y acá está el cruce con el track BE.** El incidente `be-15` —*"la suite lleva tres
semanas en verde y ayer se rompió producción"*— es el mismo patrón con otro
sustituto: allá lo que engaña no es el reloj sino **el motor de la base**, con la
suite corriendo contra SQLite y producción contra PostgreSQL. Los dos incidentes
enseñan lo mismo desde orillas opuestas: **una prueba solo vale lo que valga su
parecido con el ambiente real**, y cada diferencia que aceptas —el reloj, la zona,
el motor, la latencia— es una clase de bug que tu suite no va a encontrar jamás.

Y hay una simetría que vale la pena notar: en `be-15` la suite estaba **verde** y
mentía; acá está **roja** y dice la verdad. La reacción instintiva es desconfiar del
rojo y confiar en el verde, y en los dos casos es la reacción equivocada.

</details>
L5EOF
awk '/^## Incidente/{if(t)print t" -> "n; t=$0; n=0} {n++} END{print t" -> "n}' /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L5a.md /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L5b.md /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad/L5c.md

# --- 2026-09-10T02:15:27 · Splice L4 and L5 in ID order and verify
SCR=/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad
python3 - <<PY
import io
def r(f): return io.open("$SCR/"+f,encoding="utf-8").read().strip("\n")
l4a, l4b, l5a, l5b, l5c = r("L4a.md"), r("L4b.md"), r("L5a.md"), r("L5b.md"), r("L5c.md")
i = l4b.index("## Incidente 17")
inc15 = l4b[:i].rstrip().rstrip("-").rstrip()
inc17 = l4b[i:]
bloque = "\n\n---\n\n".join([l4a, inc15, l5a, inc17, l5b, l5c])
p="cuaderno-incidentes.md"; s=io.open(p,encoding="utf-8").read()
m="# 🪞 Retrospectiva del mes"; j=s.index(m)
s=s[:j]+bloque+"\n\n---\n\n"+s[j:]
io.open(p,"w",encoding="utf-8").write(s); print("L4+L5 spliced")
PY
echo "=== incidentes y orden ==="; grep -n "^## Incidente" cuaderno-incidentes.md
echo "=== details ==="; grep -c "<details>" cuaderno-incidentes.md; grep -c "</details>" cuaderno-incidentes.md
wc -l cuaderno-incidentes.md

# --- 2026-09-10T02:16:11 · Insert the symptom index into the notebook
SCR=/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad
cat > $SCR/sintomas.md <<'SEOF'
## 🩺 Entrar por el síntoma

Nadie llega a una investigación sabiendo de qué fase es su problema. Llega con una
frase vaga y con prisa. Por eso el índice que de verdad se usa no es el de más
abajo, ordenado por ID, sino este: **el que va del síntoma a la primera
herramienta**.

### El método: cuatro preguntas, siempre en este orden

El orden no es una preferencia. Cada pregunta cuesta bastante más que la anterior,
y contestar las baratas primero descarta la mitad de las caras.

**1. ¿Se reproduce, y con qué?** Antes de abrir un archivo: ¿esto aparece con un
**flag** —el `CHAOS_LEVEL` del mock—, con un **dato** distinto en `db.json`, con una
**configuración de la máquina** (zona horaria, versión de Node), o hace falta **otro
código**? Las cuatro respuestas llevan a investigaciones distintas, y averiguar
cuál te ahorra la mitad del camino. Es la misma pregunta que ordena la sección 🔧
Preparación de cada incidente.

**2. ¿Qué dice la evidencia observable, antes que el código?** Una petición en
Network, un header, el *Diff* de una acción en Redux DevTools, un `console.count`.
La mayoría de los incidentes de este cuaderno se localizan acá, y ninguno de ellos
necesita abrir un editor para eso. **El código es el paso cuatro, no el primero.**

**3. ¿En qué capa vive?** Componente, store, epic, interceptor, mock o build. Nombrar
la capa **es** el entregable de una investigación; el fix suele ser de una línea y
viene después. Un truco que resuelve muchos casos: si aparece una acción en Redux
DevTools y **no hay ninguna petición al lado en Network**, nació dentro del
navegador.

**4. ¿De qué era es el archivo que voy a tocar?** 🧬 Esta es la pregunta propia de
este sistema y no existiría en uno escrito de una sola vez. Un fix sobre un *class
component* con `connect()` se escribe como el resto de ese archivo; uno sobre un
slice de Redux Toolkit, con las convenciones de 2021; uno sobre un epic, con las de
2022. Las tres eras están en `00-historia-del-sistema.md` §3, y el traductor entre
las dos primeras es `A5-class-components-vs-hooks.md`.

> 🧭 **La regla que resume las cuatro:** *"funciona en mi máquina", "a veces pasa" y
> "desde ayer" no describen un bug: describen una **diferencia**.* Todo el trabajo
> consiste en encontrar cuál.

### La tabla, del síntoma a la primera herramienta

| Lo que llega en el ticket | Primero mira | Capa más probable | Candidatos |
|---|---|---|---|
| "No arranca / explota antes de abrir" | la terminal, entera | build, entorno | 01, 02 |
| "Anda en tu máquina y en la mía no" | zona horaria, `node -v`, `process.arch` | entorno, suite | 02, 16, 20 |
| "Parpadea y pierdo lo que escribí" | Network, *Preserve log* | componente | 03, 09 |
| "Veo datos de otra cosa" | React DevTools: props contra estado | componente, epic | 04, 15 |
| "Me dice que no tengo permiso" | Network → **Request** Headers | interceptor | 05 |
| "Cerré sesión y algo quedó" | Redux DevTools → *Diff* | store, epic | 06, 14 |
| "A veces no carga y no dice nada" | Network: la fila **sin status** | transporte, store | 07, 10, 17 |
| "Me saca a login sin avisar" | el `request-id`, en los dos lados | mock, interceptor | 08 |
| "Se quedó cargando para siempre" | Redux DevTools: la última acción | store | 10, 07 |
| "Se vendió dos veces" | Redux DevTools: la secuencia entera | store, epic | 11 |
| "Cambió solo, nadie lo tocó" | espera sin tocar nada, mirando DevTools | temporizador, epic | 12, 14 |
| "Falló una vez y no anda más" | Network: ¿sale **alguna** petición? | epic | 13 |
| "Sigue pasando después de salir" | Network, en reposo | epic | 14, 12 |
| "La cuenta no cuadra" | la función pura, en una consola de Node | cálculo | 18 |
| "Va lento al final del día" | Profiler + `console.count` | componente, selector | 19 |
| "Verde en mi máquina, rojo en CI" | `TZ=UTC npm test` | suite, componente | 20 |

Una advertencia sobre la última columna: es una lista de **candidatos**, no un
diagnóstico. Dos incidentes de este cuaderno pueden compartir síntoma y no
compartir nada más — el 07 y el 10 son el caso arquetípico, y se separan con una
sola columna de Network—. Empezar por el candidato equivocado no es un problema
mientras la evidencia te saque de ahí rápido; empezar por el código sí lo es.
SEOF
python3 - <<PY
import io
p="cuaderno-incidentes.md"; s=io.open(p,encoding="utf-8").read()
new=io.open("$SCR/sintomas.md",encoding="utf-8").read().strip("\n")
m="## 📋 Índice"; i=s.index(m)
s=s[:i]+new+"\n\n---\n\n"+s[i:]
io.open(p,"w",encoding="utf-8").write(s); print("índice de síntomas insertado")
PY
grep -n "^## 🩺\|^## 📋\|^### Estados" cuaderno-incidentes.md | head

# --- 2026-09-10T02:16:31 · Apply first batch of P4 edits
python3 - <<'PY'
import io, glob, re
def edit(path, pairs, n_expect=None):
    s = io.open(path, encoding="utf-8").read(); orig = s
    for old, new in pairs:
        c = s.count(old)
        if c == 0:
            print(f"  !! NO ENCONTRADO en {path}: {old[:55]!r}"); continue
        s = s.replace(old, new)
    if s != orig:
        io.open(path, "w", encoding="utf-8").write(s); print(f"  ✓ {path}")

print("1. preámbulo del índice + pipe interno")
edit("cuaderno-incidentes.md", [
 ("""Los veinte IDs quedaron reservados por las fases que los producen, y el título es
el que va a llegar en el ticket — con su vaguedad incluida. Un ⬜ significa que el
enunciado todavía no está redactado abajo; el ID **nunca** se reasigna, así que la
fila existe desde ya.""",
  """Los veinte IDs vienen reservados por las fases que los producen, y el título es el
que va a llegar en el ticket — con su vaguedad incluida. Los veinte enunciados
están redactados más abajo; el ⬜ de la última columna es **tu** estado, no el del
archivo, y arranca en "sin empezar". El ID **nunca** se reasigna."""),
 ("incidente(14): fix — takeUntil(LOGOUT, STOP_BOARD_REFRESH) al final del pipe",
  "incidente(14): fix — takeUntil(STOP_BOARD_REFRESH, LOGOUT) al final del pipe interno"),
 ("incidente(14): causa — boardRefreshEpic sin takeUntil en el pipe interno",
  "incidente(14): causa — boardRefreshEpic sin takeUntil: el interval nunca se corta"),
])

print("2. las doce fases: reservas ya redactadas")
old_res = """Los IDs quedan reservados en `cuaderno-incidentes.md` desde ya, aunque el
enunciado todavía no esté redactado. El ID nunca se reasigna."""
new_res = """Los IDs quedan reservados en `cuaderno-incidentes.md`, donde el enunciado ya
está redactado con sus pistas y su solución de referencia. El ID nunca se reasigna."""
for f in sorted(glob.glob("0*.md") + glob.glob("1*.md")):
    s = io.open(f, encoding="utf-8").read()
    if old_res in s:
        io.open(f,"w",encoding="utf-8").write(s.replace(old_res, new_res)); print(f"  ✓ {f}")

print("3. fase 09: referencia colgada")
edit("09-dashboard.md", [
 ("Ver **Forense — Fase 09** y los incidentes 🟠 de performance / re-renders excesivos del cuaderno.",
  "El recorrido completo está en el incidente **19** de `cuaderno-incidentes.md`, que trae además el juego de datos con volumen suficiente para que el problema se vea."),
])
PY

# --- 2026-09-10T02:16:49 · Update README and style guide
python3 - <<'PY'
import io
def edit(path, pairs):
    s = io.open(path, encoding="utf-8").read(); orig=s
    for old,new in pairs:
        if s.count(old)!=1: print(f"  !! {path}: {s.count(old)} coincidencias de {old[:50]!r}"); continue
        s = s.replace(old,new)
    if s!=orig: io.open(path,"w",encoding="utf-8").write(s); print(f"  ✓ {path}")

print("4. README")
edit("README.md", [
("""> ⚠️ **Estado del cuaderno.** Los veinte IDs están reservados y trazados desde
> las fases que los producen, pero **los enunciados todavía no están
> redactados**: el archivo tiene la plantilla y el índice, no los incidentes. Es
> el hueco conocido más grande del curso. Mientras tanto, cada fase trae sus
> propios ejercicios de diagnóstico y su
> pieza forense, que cubren el mismo músculo con menos ceremonia.
>
> El cuaderno del **track BE opcional** (`cuaderno-incidentes-be.md`) sí está
> completo: sus dieciséis incidentes están redactados, y seis de ellos son
> hermanos de los de arriba — mismo síntoma, otra capa, otra causa raíz.""",
"""Y una puerta de entrada que se usa más que el índice: la sección 🩺 **"Entrar por
el síntoma"**, con el método de cuatro preguntas y una tabla que va de la frase del
ticket —*"a veces no carga"*, *"verde en mi máquina, rojo en la de al lado"*— a la
primera herramienta que hay que abrir. Porque nadie llega a una investigación
sabiendo de qué fase es su problema.

> 🧭 **Tres de los veinte no terminan en un commit.** Uno cierra en documentación,
> otro en un *"no se reproduce, y acá está la evidencia"*, y el último —el que
> cierra el curso— en una decisión de equipo que hay que escribir y firmar. Ese
> desenlace es tan real como un fix y casi nunca se practica."""),
])

print("5. guía de estilo §15")
edit("prompts/guia-de-estilo-y-convenciones.md", [
("""- **El cuaderno de incidentes está vacío.** Los veinte IDs están reservados y
  trazados desde las fases que los producen, pero ningún enunciado está
  redactado: el archivo tiene índice y plantilla. Es el hueco de autocontención
  más grande del curso y está marcado como tal en el README. → Redactar los
  veinte siguiendo la estructura de ocho puntos de §13. Prioridad alta.""",
"""- ~~**El cuaderno de incidentes está vacío.**~~ **Resuelto.** Los veinte
  enunciados están redactados siguiendo la estructura de ocho puntos de §13, con
  sus tres pistas escalonadas y su solución de referencia colapsada. Se agregó
  además la sección 🩺 "Entrar por el síntoma" —método de cuatro preguntas y tabla
  de síntoma a herramienta—, que el cuaderno del track BE replica. La plantilla,
  que vivía embebida en el archivo como "Incidente 01", se extrajo a
  `prompts/plantilla-de-incidente.md`; su hermana de backend es
  `plantilla-de-incidente-be.md`."""),
])
PY
grep -n "cuaderno del \*\*track BE\|Estado del cuaderno" README.md | head

# --- 2026-09-10T02:16:56 · Check README BE notebook paragraph
grep -n "redactados de punta a punta" -A4 -B6 README.md

# --- 2026-09-10T02:17:03 · Fix README emphasis and read BE notebook method section
python3 - <<'PY'
import io
p="README.md"; s=io.open(p,encoding="utf-8").read()
s=s.replace("el contenedor o en el pipeline—, **redactados de punta a punta**, con pistas",
            "el contenedor o en el pipeline—, con pistas")
io.open(p,"w",encoding="utf-8").write(s); print("✓ README")
PY
sed -n '54,90p' cuaderno-incidentes-be.md

# --- 2026-09-10T02:17:34 · Add symptom index to BE notebook and run final verification
SCR=/private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/5d4ed58d-ca5c-4efb-aaa8-eb9512597a47/scratchpad
cat > $SCR/sintomas-be.md <<'SEOF'
## 🩺 Entrar por el síntoma

El método de las tres preguntas de arriba te dice **de qué lado del cable** está la
causa. Esta tabla es el paso siguiente: una vez que sabes que es de este lado, por
dónde empezar a mirar.

| Lo que llega en el ticket | Primero mira | Capa más probable | Candidatos |
|---|---|---|---|
| "En Network sí, en la consola no" | el header, en las dos orillas | contrato | be-01 |
| "Falta un dato que sí cargamos" | el `INSERT` real, en `psql` | store, esquema | be-02, be-07 |
| "Se cae solo y vuelve" | `docker logs`, el código de salida | despliegue | be-03, be-16 |
| "La hora salió corrida" | el tipo de la columna, en `\d` | esquema, zona | be-04, be-11 |
| "Anda hasta que hay gente" | `pg_stat_activity` | pool, transacción | be-05 |
| "A veces sale en blanco" | `go test -race` | concurrencia | be-06 |
| "Los saca de la sesión" | el `exp` del token, decodificado | autenticación | be-08 |
| "Se vendió dos veces" | los índices de la tabla, en `\d` | base de datos | be-09 |
| "Quedó reservado para siempre" | qué proceso libera, y cuándo | transacciones | be-10 |
| "Siguió vendiendo tras el cierre" | quién evalúa la hora | autoridad del reloj | be-12 |
| "La cuenta no cuadra" | de cuándo son los datos que entraron | contrato, transacción | be-13, be-14 |
| "Verde en la suite, rojo en PROD" | contra qué motor corre la suite | pruebas | be-15 |
| "La imagen de ayer no arranca" | qué cambió si el código no cambió | despliegue | be-16 |

Dos advertencias. La primera: la última columna son **candidatos**, no un
diagnóstico — `be-13` y `be-14` comparten síntoma y no comparten causa. La segunda,
y es la propia de este track: **seis de estos sixteen tienen un hermano en el
cuaderno base con el mismo síntoma y otra causa raíz**, así que antes de dar por
cerrada una hipótesis conviene preguntarse si el síntoma que estás viendo no será
el de la otra orilla. El cruce está en la sección de hermanos, más abajo.
SEOF
python3 - <<PY
import io
p="cuaderno-incidentes-be.md"; s=io.open(p,encoding="utf-8").read()
new=io.open("$SCR/sintomas-be.md",encoding="utf-8").read().strip("\n").replace("sixteen","dieciséis")
m="## 📋 Índice"; i=s.index(m)
s=s[:i]+new+"\n\n---\n\n"+s[i:]
io.open(p,"w",encoding="utf-8").write(s); print("✓ índice de síntomas BE")
PY
echo "=== verificación final ==="
grep -c "^## Incidente" cuaderno-incidentes.md
grep -c "<details>" cuaderno-incidentes.md; grep -c "</details>" cuaderno-incidentes.md
echo "--- voseo ---"; grep -rnE "\b(tenés|podés|querés|hacé|mirá|fijate|sabés|acordate|andá|dejá)\b" cuaderno-incidentes.md prompts/plantilla-de-incidente.md || echo "limpio"
echo "--- placeholders fuera de Tu investigación ---"; grep -n "{{" cuaderno-incidentes.md | wc -l
echo "--- líneas ---"; wc -l cuaderno-incidentes.md cuaderno-incidentes-be.md

# --- 2026-09-10T02:17:43 · Search for voseo forms without word boundaries
grep -rnoE "(Mirá|mirá|Fijate|fijate|tenés|podés|querés|Hacé|hacé|sabés|Andá|andá|Dejá|dejá|Anotá|anotá|Escribí|escribí|Compará|compará|Revisá|revisá|Poné|poné|Abrí|abrí|Corré|corré|Buscá|buscá|Leé|leé)" cuaderno-incidentes.md prompts/plantilla-de-incidente.md | sort | uniq -c

# --- 2026-09-10T02:17:49 · Inspect each potential voseo occurrence in context
for n in 141 445 621 625 887 2146 2521 2595 3311; do echo "--- $n"; sed -n "${n}p" cuaderno-incidentes.md; done

# --- 2026-09-10T02:18:03 · Fix voseo and verify all cross-referenced files exist
python3 - <<'PY'
import io
p="cuaderno-incidentes.md"; s=io.open(p,encoding="utf-8").read()
old="seleccionada mientras navegas de una rifa a la otra. Mirá dos cosas **al mismo"
new="seleccionada mientras navegas de una rifa a la otra. Mira dos cosas **al mismo"
assert s.count(old)==1
io.open(p,"w",encoding="utf-8").write(s.replace(old,new)); print("✓ voseo corregido (1 caso)")
PY
echo "=== re-escaneo, imperativos de voseo reales ==="
grep -rnoE "(^|[ (>*])(Mirá|Fijate|Tené|Podé|Hacé|Andá|Dejá|Anotá|Escribí|Compará|Revisá|Poné|Abrí|Corré|Buscá|Leé|Probá|Usá|Ponete|Acordate|Tomá|Elegí|Segui|Seguí)([ ,.]|$)" cuaderno-incidentes.md cuaderno-incidentes-be.md prompts/plantilla-de-incidente.md README.md prompts/guia-de-estilo-y-convenciones.md || echo "limpio"
echo "=== enlaces a archivos citados en los incidentes ==="
for f in A5-class-components-vs-hooks.md A10-aritmetica-de-dinero.md A11-marble-testing.md A12-mapa-de-deuda-tecnica.md A3-node-y-npm.md A9-entornos-y-contenedores.md 00-historia-del-sistema.md 00-convencion-de-git-y-tags.md cuaderno-incidentes-be.md prompts/plantilla-de-incidente.md; do [ -f "$f" ] && echo "ok $f" || echo "FALTA $f"; done

# --- 2026-09-10T02:18:08 · Inspect line 269 context
sed -n '267,271p' cuaderno-incidentes.md

# --- 2026-09-10T02:18:15 · Verify no stale claims remain and list changed files
echo "=== ¿queda algo que diga que el cuaderno está vacío? ==="
grep -rn "todavía no está\|todavía no esté\|no están redactados\|cuaderno de incidentes está vacío\|enunciado todavía" --include="*.md" . | grep -v completado_ || echo "nada"
echo
echo "=== estructura final del cuaderno ==="
grep -n "^# \|^## 🩺\|^## 📋\|^## 🧭" cuaderno-incidentes.md | head -12
echo
echo "=== archivos tocados en esta tanda ==="
cd .. && git status --short | grep react-16

# --- 2026-09-10T02:18:36 · Update plan file and print final incident sizes
cd react-16-legacy-for-backend-devs && python3 - <<'PY'
import io
# La banda 🟢 real quedó en 180-210; ajusto la plantilla a lo medido.
p="prompts/plantilla-de-incidente.md"; s=io.open(p,encoding="utf-8").read()
s=s.replace("| 🟢 fácil | 150-200 | 20-30 min |","| 🟢 fácil | 170-215 | 20-30 min |")
io.open(p,"w",encoding="utf-8").write(s)

p="completado_cuaderno_incidentes.md"; s=io.open(p,encoding="utf-8").read()
s=s.replace("""> **Estado: veredicto cerrado (§1–§3), decisiones D1–D6 CERRADAS (§4), y ejecutados
> H1 (corrección del incidente 14) y H2 (extracción de la plantilla).** Lo que queda
> es §6.2–§6.8: los cinco lotes, el índice 🩺 y la costura. Se ejecutan sin más consultas.""",
"""> **Estado: TODO EJECUTADO.** Veredicto (§1–§3), decisiones D1–D6, hallazgos H1–H3,
> los cinco lotes (20 incidentes, 4.906 líneas), el índice 🩺 en los dos cuadernos y
> la costura de P4. **Este archivo ya cumplió su función: se puede borrar.** Lo que
> queda anotado abajo es solo el registro de lo que se decidió y por qué, por si
> hace falta reconstruir el razonamiento antes de que se pierda.""")
s=s.replace("""- [ ] H3: los seis incidentes de la ficha §4bis declaran su condición, y el 19 trae su
      script de siembra.""",
"""- [x] H3: los seis incidentes de la ficha §4bis declaran su condición en 🔧 Preparación.
      El 19 pide `scripts/seedHeavyDay.js` (40 rifas · ~12.000 números) — **el script
      todavía no existe en el repositorio**: el incidente instruye a escribirlo como
      parte del trabajo, y eso es deliberado, pero si se prefiere entregarlo hecho,
      es lo único pendiente del lote L5.
- [x] Los 20 incidentes redactados y en orden de ID (`grep -c "^## Incidente"` → 20).
- [x] El índice 🩺 está en los dos cuadernos.
- [x] README y guía §15 ya no describen el hueco; las 12 fases dicen que el enunciado
      ya está redactado.
- [x] Referencia colgada `Ver **Forense — Fase 09**` (un archivo que nunca existió)
      reemplazada por el enlace al incidente 19.""")
io.open(p,"w",encoding="utf-8").write(s); print("✓ plan actualizado")
PY
awk '/^## Incidente/{if(t)print t" -> "n; t=$0; n=0} {n++} END{print t" -> "n}' cuaderno-incidentes.md

# --- 2026-09-10T02:25:28 · Check markdown links and file citations
python3 - <<'PY'
import re, os, glob, collections
files = sorted([f for f in glob.glob("*.md")] + glob.glob("prompts/*.md"))
files = [f for f in files if f != "completado_cuaderno_incidentes.md"]
print(f"archivos revisados: {len(files)}\n")

# 1. enlaces markdown [x](y.md)
bad = []
for f in files:
    base = os.path.dirname(f)
    for m in re.finditer(r'\[([^\]]*)\]\(([^)]+)\)', open(f, encoding='utf-8').read()):
        target = m.group(2).split('#')[0]
        if not target or target.startswith(('http','mailto:')): continue
        p = os.path.normpath(os.path.join(base, target))
        if not os.path.exists(p):
            bad.append((f, m.group(2)))
print("== 1. ENLACES MARKDOWN ROTOS ==")
print("\n".join(f"  {f} -> {t}" for f,t in bad) or "  ninguno")

# 2. nombres de archivo .md citados entre backticks
bad2 = collections.Counter()
for f in files:
    for m in re.finditer(r'`([A-Za-z0-9_./-]+\.md)`', open(f, encoding='utf-8').read()):
        t = m.group(1)
        cands = [t, os.path.join("prompts", os.path.basename(t)), os.path.basename(t)]
        if not any(os.path.exists(c) for c in cands):
            bad2[(f, t)] += 1
print("\n== 2. ARCHIVOS .md CITADOS QUE NO EXISTEN ==")
print("\n".join(f"  {f}: `{t}` ({n}x)" for (f,t),n in sorted(bad2.items())) or "  ninguno")
PY

# --- 2026-09-10T02:25:44 · Verify the systematic broken filename references
echo "=== historia-del-sistema.md (archivo real: 00-historia-del-sistema.md) ==="
grep -rn '`historia-del-sistema\.md`' --include="*.md" . | grep -v completado_ | head -20
echo
echo "=== alcance-del-proyecto.md (archivo real: 00-alcance-del-proyecto.md) ==="
grep -rn '`alcance-del-proyecto\.md`\|`ALCANCE-DEL-PROYECTO\.md`\|`Alcance-del-proyecto\.md`' --include="*.md" . | grep -v completado_ | head -20
echo
echo "=== DECISIONES-CONFIRMADAS ==="
grep -rn 'DECISIONES-CONFIRMADAS' --include="*.md" . | grep -v completado_

# --- 2026-09-10T02:26:17 · Cross-check incident index against headers and hermanos
python3 - <<'PY'
import re, io
s = io.open("cuaderno-incidentes.md", encoding="utf-8").read()

# índice
rows = re.findall(r'^\| (\d{2}) \| ([\d\-]+) \| (.+?) \| (.+?) \| (.+?) \| (.+?) \|$', s, re.M)
idx = {r[0]: {'fase': r[1], 'titulo': r[2].strip(), 'cat': r[3].strip(), 'dif': r[4].strip()} for r in rows}
print(f"filas del índice: {len(idx)}")

# encabezados
heads = re.findall(r'^## Incidente (\d{2})( ⭐)? — (.+?)\n\n> \*\*Fase:\*\* (.+?) · \*\*Categoría:\*\* (.+?) · \*\*Dificultad:\*\* (.+?)\n', s, re.M)
print(f"encabezados parseados: {len(heads)}\n")

print("== 3. ÍNDICE vs ENCABEZADO ==")
prob = 0
for hid, star, htit, hfase, hcat, hdif in heads:
    i = idx.get(hid)
    if not i: print(f"  {hid}: no está en el índice"); prob+=1; continue
    tit_idx = i['titulo'].replace(' ⭐','')
    if tit_idx != htit:
        print(f"  {hid} TÍTULO difiere:\n      índice: {tit_idx}\n      cuerpo: {htit}"); prob+=1
    if i['dif'] != hdif.strip():
        print(f"  {hid} DIFICULTAD: índice {i['dif']} vs cuerpo {hdif}"); prob+=1
    ci, ch = i['cat'].lower(), hcat.lower()
    if ci.replace(' / ','-').replace(' ','') not in ch.replace(' / ','-').replace(' ','').replace('(store)','(store)'):
        print(f"  {hid} CATEGORÍA: índice '{i['cat']}' vs cuerpo '{hcat}'"); prob+=1
    fi = i['fase']; fh = hfase.strip()
    if not fh.startswith(fi.split('-')[0]):
        print(f"  {hid} FASE: índice '{fi}' vs cuerpo '{fh}'"); prob+=1
    if star and '⭐' not in i['titulo']:
        print(f"  {hid}: ⭐ en el cuerpo pero no en el índice"); prob+=1
    if '⭐' in i['titulo'] and not star:
        print(f"  {hid}: ⭐ en el índice pero no en el cuerpo"); prob+=1
print(f"  ({prob} discrepancias)" if prob else "  sin discrepancias")

print("\n== 4. HERMANOS ==")
tabla = re.findall(r'^\| (\d{2}) — .+? \| `?(be-\d\d)`? ?⭐? \| ', s, re.M)
print(f"  declarados en la tabla del índice: {sorted(t[0] for t in tabla)} -> {dict(tabla)}")
enc = re.findall(r'## Incidente (\d{2}).*?\n(?:.*?\n){0,8}?> · Hermano del incidente `(be-\d\d)`', s)
print(f"  marcados en encabezado:            {dict(enc)}")
falt = set(dict(tabla)) - set(dict(enc))
sob  = set(dict(enc)) - set(dict(tabla))
if falt: print(f"  ⚠️ en la tabla y NO en el encabezado: {sorted(falt)}")
if sob:  print(f"  ⚠️ en el encabezado y NO en la tabla: {sorted(sob)}")
for k in set(dict(tabla)) & set(dict(enc)):
    if dict(tabla)[k] != dict(enc)[k]: print(f"  ⚠️ {k}: tabla dice {dict(tabla)[k]}, encabezado dice {dict(enc)[k]}")
PY

# --- 2026-09-10T02:26:34 · Check template compliance, tag blocks and appendices
grep -n "Hermano del incidente" cuaderno-incidentes.md | head
echo
python3 - <<'PY'
import re, io, glob, os
base = sorted(glob.glob("0[0-9]-*.md")+glob.glob("1[01]-*.md"))
base = [f for f in base if not f.startswith(("00-alcance","00-historia","00-convencion"))]
be = sorted(glob.glob("be0*.md"))
apx = sorted(glob.glob("A[0-9]*.md")+glob.glob("be-a-*.md"))

print("== 5. PLANTILLA DE 9 SECCIONES ==")
need = ["1. Propósito","2. Qué queda listo","3. Qué queda fuera","4. Conceptos mínimos",
        "5. Implementación","6. Errores comunes y pieza forense","7. Ejercicios","8. Referencias","9. Cierre"]
for f in base+be:
    s = io.open(f,encoding="utf-8").read()
    h2 = re.findall(r'^## .*$', s, re.M)
    nums = [re.search(r'(\d)\.', h) for h in h2]
    got = [int(m.group(1)) for m in nums if m]
    missing = [n for n in range(1,10) if n not in got]
    forense = "ieza forense" in s
    ejer = re.search(r'## 🧪 \d\. Ejercicios \((\d+)\)', s)
    flag = []
    if missing: flag.append(f"faltan secciones {missing}")
    if not forense: flag.append("SIN pieza forense")
    if not ejer: flag.append("sin conteo de ejercicios en el título")
    elif not (25 <= int(ejer.group(1)) <= 35): flag.append(f"ejercicios={ejer.group(1)} fuera de 25-35")
    if flag: print(f"  {f}: {'; '.join(flag)}")
print("  (las fases no listadas cumplen)")

print("\n== 6. BLOQUE 🏷️ DEL TAG ==")
for f in base+be:
    s = io.open(f,encoding="utf-8").read()
    slug = f[:-3]
    m = re.search(r'git tag -a (fase-[a-z0-9-]+)', s)
    if not m: print(f"  {f}: SIN bloque de tag")
    elif m.group(1) != "fase-"+slug: print(f"  {f}: tag '{m.group(1)}' != 'fase-{slug}'")
print("  (las fases no listadas cumplen)")

print("\n== 7. APÉNDICES: ¿declaran que no llevan tag? ==")
for f in apx:
    s = io.open(f,encoding="utf-8").read()
    if "🏷️" not in s: print(f"  {f}: sin bloque 🏷️")
print("  (los apéndices no listados lo tienen)")
PY

# --- 2026-09-10T02:26:52 · Check wide tables, voseo and regionalisms
python3 - <<'PY'
import re, io, glob
files = sorted(glob.glob("*.md")+glob.glob("prompts/*.md"))
files = [f for f in files if f!="completado_cuaderno_incidentes.md"]

print("== 8. TABLAS DE MÁS DE 4 COLUMNAS (§3 de la guía) ==")
for f in files:
    for i,l in enumerate(io.open(f,encoding="utf-8"),1):
        if l.strip().startswith('|') and re.match(r'^\|[\s:\-|]+\|$', l.strip()):
            n = l.strip().strip('|').count('|')+1
            if n>4: print(f"  {f}:{i} → {n} columnas")

print("\n== 9. VOSEO (imperativos, sin \\b) ==")
pat = re.compile(r'(?:^|[ (>*«"])(Mirá|Fijate|Tenés|Podés|Querés|Hacé|Andá|Dejá|Anotá|Escribí|Compará|Revisá|Poné|Abrí|Corré|Buscá|Leé|Probá|Usá|Acordate|Tomá|Elegí|Seguí|Cerrá|Volvé|Sabés|Vení|Pedí|Contá|Agregá|Quitá|Cambiá|Guardá)(?=[ ,.;:!?)]|$)')
hits=0
for f in files:
    for i,l in enumerate(io.open(f,encoding="utf-8"),1):
        for m in pat.finditer(l):
            print(f"  {f}:{i} → {m.group(1)}"); hits+=1
print("  ninguno" if not hits else f"  ({hits})")

print("\n== 10. ESPAÑA / REGIONALISMOS ==")
pat2 = re.compile(r'\b(ordenador|vosotros|vale\b|móvil|fichero|ratón|zumo|coger el)\b', re.I)
h2=0
for f in files:
    for i,l in enumerate(io.open(f,encoding="utf-8"),1):
        for m in pat2.finditer(l):
            print(f"  {f}:{i} → {m.group(0)}"); h2+=1
print("  ninguno" if not h2 else f"  ({h2})")
PY

# --- 2026-09-10T02:27:09 · Verify false positives and check wide table exceptions
echo "=== muestra de 'vale' ==="; sed -n '428p;831p' cuaderno-incidentes.md; sed -n '13p' 00-convencion-de-git-y-tags.md
echo; echo "=== 'móvil' ==="; sed -n '453p' A1-bootstrap-4-y-sass.md; sed -n '478p;570p' be09-empaquetado-ambientes-y-pipeline.md; sed -n '105p' prompts/guia-de-estilo-y-convenciones.md
echo; echo "=== tablas anchas, cabecera ==="
sed -n '280,281p' be-a-02-receta-de-imagen-y-compose.md; echo "---"; sed -n '122,123p' be09-empaquetado-ambientes-y-pipeline.md; echo "---"; sed -n '320,321p' be09-empaquetado-ambientes-y-pipeline.md; echo "---"; sed -n '117,118p' cuaderno-incidentes-be.md; echo "---"; sed -n '318,319p' prompts/diccionario-codigo-ingles.md
echo; echo "=== ¿la guía documenta estas excepciones? ==="; grep -n "seis columnas\|excepción deliberada a §3\|cinco columnas\|siete columnas" prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-10T02:27:38 · Cross-check phase-incident references, BE siblings and anchors
python3 - <<'PY'
import re, io, glob
print("== 11. FASES → INCIDENTES: ¿los IDs que citan existen y son de esa fase? ==")
idx = {}
s = io.open("cuaderno-incidentes.md",encoding="utf-8").read()
for m in re.finditer(r'^\| (\d{2}) \| ([\d\-]+) \|', s, re.M): idx[m.group(1)] = m.group(2)
fases = {"00-setup-hola-mundo-cra.md":"0","01-estructura-base-router-5.md":"1","02-autenticacion-minima.md":"2",
 "03-mock-api-express-caos.md":"3","04-rifas-crud.md":"4","05-venta-de-numeros.md":"5","06-redux-observable-a-fondo.md":"6",
 "07-cierre-polling-resultado.md":"7","08-liquidacion-calculo-premio.md":"8","09-dashboard.md":"9",
 "10-testing-minimo.md":"10-11","11-cierre-puente-react-moderno.md":"10-11"}
for f, fase in fases.items():
    txt = io.open(f,encoding="utf-8").read()
    ids = set(re.findall(r'incidentes? \*\*(\d{2})\*\*|incidente \*\*(\d{2})\*\*|\*\*(\d{2})\*\* (?:⭐ )?— \*', txt))
    ids = {x for t in ids for x in t if x}
    ids |= set(re.findall(r'incidente ⭐ (\d{2})|incidentes? (\d{2}) y (\d{2})', txt) and [] or [])
    for i in sorted(ids):
        if i not in idx: print(f"  {f}: cita el incidente {i}, que NO existe")
        elif idx[i] != fase and not (fase=="10-11" and idx[i]=="10-11"):
            print(f"  {f} (fase {fase}): cita el incidente {i}, que el índice asigna a la fase {idx[i]}")
print("  (sin discrepancias en lo detectable)")

print("\n== 12. CUADERNO BE: tabla de hermanos vs cuaderno base ==")
b = io.open("cuaderno-incidentes-be.md",encoding="utf-8").read()
pares_be = re.findall(r'incidente \*\*(\d{2}) del track base\*\*', b)
print(f"  el cuaderno BE remite a los incidentes base: {sorted(set(pares_be))}")
declar = re.findall(r'^\| (\d{2}) — .+? \| `?(be-\d\d)', s, re.M)
print(f"  el cuaderno base declara hermanos:          {sorted(dict(declar))}")

print("\n== 13. ANCLAS #… en enlaces internos ==")
import os
for f in sorted(glob.glob("*.md")+glob.glob("prompts/*.md")):
    if f=="completado_cuaderno_incidentes.md": continue
    txt = io.open(f,encoding="utf-8").read()
    for m in re.finditer(r'\]\(([^)]*#[^)]+)\)', txt):
        tgt = m.group(1)
        path, anchor = tgt.split('#',1)
        p = os.path.normpath(os.path.join(os.path.dirname(f), path)) if path else f
        if not os.path.exists(p): print(f"  {f}: destino inexistente {tgt}"); continue
        heads = [re.sub(r'[^a-z0-9\s-]','',h.lower()).strip().replace(' ','-')
                 for h in re.findall(r'^#+ (.+)$', io.open(p,encoding="utf-8").read(), re.M)]
        if anchor.lower() not in heads: print(f"  {f}: ancla '{anchor}' no encontrada en {p}")
print("  (sin anclas rotas detectadas)")
PY

# --- 2026-09-10T02:27:53 · Re-run anchor check with correct unicode slugifier
python3 - <<'PY'
import re, io, glob, os, unicodedata, collections
def slug(h):
    h = h.strip()
    h = ''.join(c for c in h if unicodedata.category(c)[0] in 'LNZ' or c in '- _')
    h = h.lower().strip().replace(' ', '-')
    return re.sub(r'-+','-',h).strip('-')
cache={}
def heads(p):
    if p not in cache:
        cache[p]=collections.Counter(slug(h) for h in re.findall(r'^#+ (.+)$', io.open(p,encoding="utf-8").read(), re.M))
    return cache[p]
bad=0
for f in sorted(glob.glob("*.md")+glob.glob("prompts/*.md")):
    if f=="completado_cuaderno_incidentes.md": continue
    for m in re.finditer(r'\]\(([^)]*#[^)]+)\)', io.open(f,encoding="utf-8").read()):
        path, anchor = m.group(1).split('#',1)
        if path.startswith('http'): continue
        p = os.path.normpath(os.path.join(os.path.dirname(f), path)) if path else f
        if not os.path.exists(p): print(f"  {f}: destino inexistente {m.group(1)}"); bad+=1; continue
        a = anchor.lower()
        hs = heads(p)
        if a not in hs:
            near = [h for h in hs if a[:18] in h or h[:18] in a]
            print(f"  {f}: ancla rota '#{anchor}' en {os.path.basename(p)}" + (f"  ¿será '#{near[0]}'?" if near else "")); bad+=1
print(f"\n  anclas rotas: {bad}")
PY

# --- 2026-09-10T02:28:16 · Anchor check with GitHub's real slug algorithm
python3 - <<'PY'
import re, io, glob, os, unicodedata
def gh_slug(h):
    h = h.strip().lower()
    out=[]
    for c in h:
        if c in ' -_' : out.append('-' if c==' ' else c)
        elif unicodedata.category(c)[0] in ('L','N') or c=='_': out.append(c)
    return ''.join(out)
cache={}
def heads(p):
    if p not in cache:
        seen={}; res=set()
        for h in re.findall(r'^#+ (.+)$', io.open(p,encoding="utf-8").read(), re.M):
            s=gh_slug(h); n=seen.get(s,0); seen[s]=n+1
            res.add(s if n==0 else f"{s}-{n}")
        cache[p]=res
    return cache[p]
bad=[]
for f in sorted(glob.glob("*.md")+glob.glob("prompts/*.md")):
    if f=="completado_cuaderno_incidentes.md": continue
    for m in re.finditer(r'\]\(([^)]*#[^)]+)\)', io.open(f,encoding="utf-8").read()):
        path, anchor = m.group(1).split('#',1)
        if path.startswith('http'): continue
        p = os.path.normpath(os.path.join(os.path.dirname(f), path)) if path else f
        if not os.path.exists(p): bad.append((f,m.group(1),"destino inexistente")); continue
        if anchor.lower() not in heads(p):
            cand=[h for h in heads(p) if anchor.lower()[:20] in h or h[:20] in anchor.lower()]
            bad.append((f,'#'+anchor, f"¿'#{cand[0]}'?" if cand else "sin candidato"))
for f,a,s in bad: print(f"  {f}: {a}  → {s}")
print(f"\n  anclas realmente rotas: {len(bad)}")
PY

# --- 2026-09-10T02:28:26 · Inspect the four broken anchors
echo "=== A2 ==="; grep -n "^#.*[Ee]jercicio" A2-mini-design-system.md; grep -n "#11-ejercicios" A2-mini-design-system.md
echo "=== A4 ==="; grep -n "^#.*[Tt]abla" A4-cra-por-dentro.md; grep -n "8-️-tabla" A4-cra-por-dentro.md
echo "=== A6 ==="; grep -n "^## 9\." A6-redux-clasico-vs-toolkit.md; grep -n "useselectoruse dispatch" A6-redux-clasico-vs-toolkit.md
echo "=== A7 ==="; grep -n "^#.*[Mm]arble" A7-redux-observable-epica-por-epica.md; grep -n "marble-testing-con-rxjs-marbles" A7-redux-observable-epica-por-epica.md

# --- 2026-09-10T02:28:38 · Inspect A7 marble section and TOC
sed -n '635,645p' A7-redux-observable-epica-por-epica.md; echo "--- TOC de A7 ---"; sed -n '45,60p' A7-redux-observable-epica-por-epica.md

# --- 2026-09-10T02:29:08 · Fix file references, relative links and broken anchors
python3 - <<'PY'
import re, io, glob
files = [f for f in sorted(glob.glob("*.md")+glob.glob("prompts/*.md")) if f!="completado_cuaderno_incidentes.md"]

print("== A. referencias sin el prefijo 00- ==")
tot=0
for f in files:
    s = io.open(f,encoding="utf-8").read(); o=s
    # solo las que NO vengan ya con 00- delante
    s = re.sub(r'(?<!00-)(?<!\w)historia-del-sistema\.md', '00-historia-del-sistema.md', s)
    s = re.sub(r'(?<!00-)(?<!\w)alcance-del-proyecto\.md', '00-alcance-del-proyecto.md', s)
    if s!=o:
        n = len(re.findall(r'00-(?:historia-del-sistema|alcance-del-proyecto)\.md', s)) - len(re.findall(r'00-(?:historia-del-sistema|alcance-del-proyecto)\.md', o))
        io.open(f,"w",encoding="utf-8").write(s); print(f"  ✓ {f}  ({n})"); tot+=n
print(f"  total: {tot} referencias corregidas")

print("\n== B. enlaces relativos desde prompts/ ==")
for f in ["prompts/guia-de-estilo-y-convenciones.md","prompts/plantilla-de-fase.md"]:
    s=io.open(f,encoding="utf-8").read(); o=s
    s=s.replace("](00-convencion-de-git-y-tags.md)","](../00-convencion-de-git-y-tags.md)")
    if s!=o: io.open(f,"w",encoding="utf-8").write(s); print(f"  ✓ {f}")

print("\n== C. anclas rotas ==")
fixes = [
 ("A2-mini-design-system.md", "[Ejercicios](#11-ejercicios)", "[Ejercicios](#11--ejercicios-9)"),
 ("A4-cra-por-dentro.md", "(#8-️-tabla-cuándo-hacer-qué)", "(#8--tabla-cuándo-hacer-qué)"),
 ("A6-redux-clasico-vs-toolkit.md", "(#9-conectar-el-componente-connect-vs-useselectoruse dispatch)",
  "(#9-conectar-el-componente-connect-vs-useselectorusedispatch)"),
 ("A7-redux-observable-epica-por-epica.md",
  "- [🔬 Marble testing con rxjs-marbles: sintaxis mínima](#-marble-testing-con-rxjs-marbles-sintaxis-mínima)",
  "- [🔬 Marble testing → **A11**](#-marble-testing--a11)"),
]
for f,old,new in fixes:
    s=io.open(f,encoding="utf-8").read()
    if s.count(old)!=1: print(f"  !! {f}: {s.count(old)} coincidencias"); continue
    io.open(f,"w",encoding="utf-8").write(s.replace(old,new)); print(f"  ✓ {f}")
PY

# --- 2026-09-10T02:29:23 · Verify no double prefixes and re-check all links and anchors
echo "=== ¿se creó algún 00-00- ? ==="; grep -rn "00-00-" --include="*.md" . || echo "ninguno"
echo; echo "=== las líneas ilustrativas de la guía siguen intactas ==="; sed -n '706,708p' prompts/guia-de-estilo-y-convenciones.md
echo; echo "=== re-verificación de enlaces y anclas ==="
python3 - <<'PY'
import re, io, glob, os, unicodedata
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
bad=0
for f in [x for x in sorted(glob.glob("*.md")+glob.glob("prompts/*.md")) if x!="completado_cuaderno_incidentes.md"]:
    txt=io.open(f,encoding="utf-8").read()
    for m in re.finditer(r'\[([^\]]*)\]\(([^)]+)\)', txt):
        t=m.group(2)
        if t.startswith(('http','mailto:')): continue
        path,_,anchor = t.partition('#')
        p = os.path.normpath(os.path.join(os.path.dirname(f), path)) if path else f
        if not os.path.exists(p): print(f"  ROTO {f} -> {t}"); bad+=1; continue
        if anchor and anchor.lower() not in heads(p): print(f"  ANCLA {f} -> {t}"); bad+=1
print(f"  enlaces/anclas rotos: {bad}")
PY

# --- 2026-09-10T02:29:43 · Document table exceptions and run final citation sweep
python3 - <<'PY'
import io
p="prompts/guia-de-estilo-y-convenciones.md"; s=io.open(p,encoding="utf-8").read()
old = """- **El índice del cuaderno de incidentes es una tabla de seis columnas.** Es una
  excepción deliberada a §3: un registro de veinte filas donde ninguna celda
  necesita explicación es el caso arquetípico de tabla, y como lista se volvería
  ilegible. Queda documentado acá para que no se "corrija" por error."""
new = """- **Seis tablas superan las cuatro columnas, y las seis son excepciones
  deliberadas a §3.** La regla de §3 apunta a las tablas *narrativas* —aquellas
  cuyas celdas necesitan una frase para entenderse—, y ninguna de estas lo es: son
  **registros**, con celdas de una o dos palabras, donde pasar a lista con
  subtítulos las volvería ilegibles. Quedan documentadas acá para que no se
  "corrijan" por error:
  - los **índices de los dos cuadernos de incidentes** (seis columnas: ID, fase,
    título, categoría, dificultad, estado). Es el caso arquetípico de tabla;
  - las dos **matrices de variables por ambiente** (`be-a-02` §7 y `be09` §3), de
    cinco columnas, una por ambiente. Son las hermanas de la matriz de entornos de
    la Fase 0 que sí se convirtió a lista, y se conservan porque aquí las celdas
    son valores, no párrafos;
  - la **tabla de mediciones** de `be09` §8, cinco columnas de cifras;
  - la **tabla de cumplimiento por archivo** de `diccionario-codigo-ingles.md`, de
    siete columnas. Es material de autoría, no de lectura, y funciona como
    checklist."""
assert s.count(old)==1
io.open(p,"w",encoding="utf-8").write(s.replace(old,new)); print("✓ excepciones de tablas documentadas")
PY
echo
echo "=== barrido final: .md citados que no existen (solo los reales) ==="
python3 - <<'PY'
import re, io, glob, os, collections
bad=collections.Counter()
for f in [x for x in sorted(glob.glob("*.md")+glob.glob("prompts/*.md")) if x!="completado_cuaderno_incidentes.md"]:
    for m in re.finditer(r'`([A-Za-z0-9_./-]+\.md)`', io.open(f,encoding="utf-8").read()):
        t=m.group(1)
        if re.search(r'(NN|AN|tema|slug|CLAUDE)', t): continue          # patrones de nombre, no referencias
        if t.startswith('server/') or t in ('CONTRACT.md','concurrencia.md','dinero.md','regla-del-motor.md','VEREDICTO.md'):
            continue                                                     # artefactos que el alumno crea
        if not any(os.path.exists(c) for c in (t, os.path.join("prompts",os.path.basename(t)), os.path.basename(t))):
            bad[(f,t)]+=1
for (f,t),n in sorted(bad.items()): print(f"  {f}: `{t}` ({n}x)")
print("  ninguna" if not bad else f"  ({sum(bad.values())})")
PY

# --- 2026-09-10T02:29:53 · Verify server artifacts are framed as student deliverables
grep -n "CONTRACT.md" be00-el-contrato-auditoria-del-mock.md | head -4; echo "---"; grep -n "server/evidence" be02-la-costura-de-datos.md | head -3; echo "--- ¿se dice que los creas tú? ---"; grep -rn "lo escribes tú\|lo creas\|vas a escribir\|entregable de esta fase\|Escribe.*CONTRACT\|crea .*evidence" be00-el-contrato-auditoria-del-mock.md be02-la-costura-de-datos.md | head -5

# --- 2026-09-10T02:30:09 · Check phase section 6 incident links and read notebook tail
echo "=== ¿cada §6 menciona sus incidentes? (checklist §14 de la guía) ==="
python3 - <<'PY'
import re, io
fases = {"00-setup-hola-mundo-cra.md":["01","02"],"01-estructura-base-router-5.md":["03","04"],
"02-autenticacion-minima.md":["05","06"],"03-mock-api-express-caos.md":["07","08"],
"04-rifas-crud.md":["09","10"],"05-venta-de-numeros.md":["11","12"],
"06-redux-observable-a-fondo.md":["13","14","15"],"07-cierre-polling-resultado.md":["16","17"],
"08-liquidacion-calculo-premio.md":["18"],"09-dashboard.md":["19"],"10-testing-minimo.md":["20"]}
for f, ids in fases.items():
    s=io.open(f,encoding="utf-8").read()
    m=re.search(r'^## ⚠️ 6\..*?(?=^## 🧪 7\.)', s, re.M|re.S)
    sec6 = m.group(0) if m else ""
    falt=[i for i in ids if re.search(rf'\*\*{i}\*\*', sec6) is None]
    print(f"  {f}: {'✓ menciona ' + ', '.join(ids) if not falt else '⚠️ §6 NO menciona ' + ', '.join(falt)}")
PY
echo
echo "=== cierre del cuaderno: retrospectiva y pendientes ==="
sed -n '/^# 🪞 Retrospectiva/,$p' cuaderno-incidentes.md

# --- 2026-09-10T02:30:26 · Inspect the end of section 6 in the phases missing incident links
for f in 01-estructura-base-router-5.md 04-rifas-crud.md 05-venta-de-numeros.md 06-redux-observable-a-fondo.md 07-cierre-polling-resultado.md 10-testing-minimo.md; do echo "=========== $f — últimas líneas de §6"; python3 -c "
import re,io,sys
s=io.open('$f',encoding='utf-8').read()
m=re.search(r'^## ⚠️ 6\..*?(?=^## 🧪 7\.)', s, re.M|re.S)
print('\n'.join(m.group(0).rstrip().split('\n')[-4:]))
"; done

# --- 2026-09-10T02:30:49 · Add incident pointers to section 6 and re-verify
python3 - <<'PY'
import re, io
adds = {
"01-estructura-base-router-5.md": (
 "Es el germen del clásico \"los datos viejos se quedan pegados\" que vas a ver en serio con el store más adelante.",
 "\n\n> 📓 De esta fase salen los incidentes **03** y **04** de `cuaderno-incidentes.md`. El 04 es justamente el bug de arriba, llegando como llega en la vida real: en palabras de un vendedor que no sabe qué es un `useState`."),
"04-rifas-crud.md": (
 "Esa es la firma visual del bug más común de la fase.",
 "\n\n> 📓 De esta fase salen los incidentes **09** y **10** de `cuaderno-incidentes.md`. El 10 es el que acabas de provocar; el 09 es más chico y más desconcertante, porque su síntoma no se parece en nada a su causa."),
"05-venta-de-numeros.md": (
 "Un bug que sabes describir es un bug medio muerto.",
 "\n\n> 📓 De esta fase salen los incidentes ⭐ **11** y **12** de `cuaderno-incidentes.md`. El 11 es la secuencia de arriba llegando desde tesorería con dos comprobantes en la mano; el 12 tiene el mismo síntoma con **dos** causas posibles, y distinguirlas es el ejercicio."),
"06-redux-observable-a-fondo.md": (
 "Este es uno de los ≥4 incidentes de RxJS/epics del curso. Su post-mortem (sin culpabilización) es material del ejercicio 30.",
 "\n\n> 📓 De esta fase salen los incidentes **13**, **14** ⭐ y **15** de `cuaderno-incidentes.md`, los tres invisibles en la consola: el epic que muere en silencio, la suscripción que sobrevive al logout y la respuesta vieja que pisa a la nueva. El 14 es el que el curso usa como ejemplo del par de tags `inc/…-roto` / `-fix`."),
"07-cierre-polling-resultado.md": (
 "Escribe el post-mortem (plantilla Guía de Estilo §12) de por qué un `takeUntil` incompleto es indistinguible de uno correcto hasta que miras la red.",
 "\n\n> 📓 De esta fase salen los incidentes **16** y **17** de `cuaderno-incidentes.md`. El 16 no se reproduce si no declaras la zona horaria del navegador, y el 17 comparte síntoma con dos causas distintas que se separan contando peticiones en Network."),
"10-testing-minimo.md": (
 "Ese diff es la forma más limpia de *ver* un memory leak de suscripción.",
 "\n\n> 📓 De esta fase sale el incidente **20** de `cuaderno-incidentes.md`, el único que no se reproduce en la aplicación sino en la suite — y el único que no termina en un parche, sino en una decisión que se escribe. Se abre acá y se cierra en la Fase 11."),
}
for f,(anchor,add) in adds.items():
    s=io.open(f,encoding="utf-8").read()
    if s.count(anchor)!=1: print(f"  !! {f}: {s.count(anchor)} coincidencias"); continue
    io.open(f,"w",encoding="utf-8").write(s.replace(anchor, anchor+add)); print(f"  ✓ {f}")
PY
echo
echo "=== re-verificación del checklist §14 ==="
python3 - <<'PY'
import re, io
fases = {"00-setup-hola-mundo-cra.md":["01","02"],"01-estructura-base-router-5.md":["03","04"],
"02-autenticacion-minima.md":["05","06"],"03-mock-api-express-caos.md":["07","08"],
"04-rifas-crud.md":["09","10"],"05-venta-de-numeros.md":["11","12"],
"06-redux-observable-a-fondo.md":["13","14","15"],"07-cierre-polling-resultado.md":["16","17"],
"08-liquidacion-calculo-premio.md":["18"],"09-dashboard.md":["19"],"10-testing-minimo.md":["20"]}
ok=True
for f,ids in fases.items():
    s=io.open(f,encoding="utf-8").read()
    m=re.search(r'^## ⚠️ 6\..*?(?=^## 🧪 7\.)', s, re.M|re.S); sec6=m.group(0) if m else ""
    falt=[i for i in ids if not re.search(rf'\*\*{i}\*\*', sec6)]
    if falt: print(f"  ⚠️ {f}: {falt}"); ok=False
print("  las 11 fases enlazan sus incidentes desde §6" if ok else "")
PY

# --- 2026-09-10T02:30:59 · Check BE phases link their incidents from section 6
echo "=== ¿las fases BE enlazan sus incidentes? ==="
python3 - <<'PY'
import re, io, glob
s=io.open("cuaderno-incidentes-be.md",encoding="utf-8").read()
mapa={}
for m in re.finditer(r'^\| (be-\d\d) \| (be\d\d) \|', s, re.M): mapa.setdefault(m.group(2),[]).append(m.group(1))
for f in sorted(glob.glob("be0*.md")):
    fase=f[:4]
    txt=io.open(f,encoding="utf-8").read()
    m=re.search(r'^## ⚠️ 6\..*?(?=^## 🧪 7\.)', txt, re.M|re.S); sec6=m.group(0) if m else ""
    ids=mapa.get(fase,[])
    falt=[i for i in ids if i not in sec6]
    print(f"  {f}: produce {ids or '—'}" + (f"  ⚠️ §6 no menciona {falt}" if falt else "  ✓"))
PY

# --- 2026-09-10T02:31:07 · Read the BE notebook index rows
sed -n '/^## 📋 Índice/,/^### Los hermanos/p' cuaderno-incidentes-be.md | grep "^| be-"

# --- 2026-09-10T02:31:40 · Add incident pointers to BE phases and verify
python3 - <<'PY'
import re, io
ptr = {
"be00-el-contrato-auditoria-del-mock.md":
 "> 📓🔥 De esta fase salen los incidentes **be-01** y **be-02** de `cuaderno-incidentes-be.md`, los dos de contrato: uno donde el backend hace todo bien y el síntoma es invisible desde el lado que lo produce, y otro donde el dato que falta no lo perdió nadie — nunca se pidió.",
"be01-go-y-la-forma-del-monolito.md":
 "> 📓🔥 De esta fase sale el incidente **be-03** de `cuaderno-incidentes-be.md`: un proceso que se cae y vuelve tres veces al día sin que nadie se queje, porque el orquestador lo tapa.",
"be02-la-costura-de-datos.md":
 "> 📓🔥 De esta fase salen los incidentes **be-04** y **be-05** de `cuaderno-incidentes-be.md`. El be-05 es hermano del incidente **19** del track base —el mismo *\"anda bien hasta que crece\"*— con el recurso agotado en esta orilla del cable en vez de la otra.",
"be03-crud-y-el-reemplazo.md":
 "> 📓🔥 De esta fase salen los incidentes **be-06** y **be-07** de `cuaderno-incidentes-be.md`, los dos sobre lo mismo desde ángulos opuestos: un campo que a veces llega vacío y un campo que se perdió en silencio durante seis meses.",
"be04-identidad-real-jwt-y-un-cve.md":
 "> 📓🔥 De esta fase sale el incidente **be-08** de `cuaderno-incidentes-be.md`, hermano del **08** del track base. Mismo síntoma —te saca de la sesión sin avisar— y otra causa: allá el `401` es del caos y aparece repartido al azar; acá es un `exp` real y por eso tiene **patrón horario**.",
"be05-venta-concurrente.md":
 "> 📓🔥 De esta fase salen los incidentes **be-09** ⭐ y **be-10** de `cuaderno-incidentes-be.md`. El be-09 es el hermano del ⭐ **11** del track base y el cruce más formativo del curso: allá el backend se defiende con su `409` y el frontend arruina la defensa; acá el backend no se defiende, porque falta el índice único.",
"be06-hora-dura-y-la-autoridad-del-reloj.md":
 "> 📓🔥 De esta fase salen los incidentes **be-11** y **be-12** de `cuaderno-incidentes-be.md`. El be-12 es hermano del **16** del track base: allá el navegador interpreta mal el instante; acá lo interpreta bien y aun así no debería ser él quien decida.",
"be07-liquidacion-dinero-entero-y-transaccional.md":
 "> 📓🔥 De esta fase salen los incidentes **be-13** y **be-14** de `cuaderno-incidentes-be.md`. El be-13 es hermano del **18** del track base: allá el cálculo arruina datos correctos; acá el cálculo está bien y lo que falla es de cuándo son los datos que entraron.",
"be08-pruebas-y-la-regla-del-motor.md":
 "> 📓🔥 De esta fase sale el incidente **be-15** ⭐ de `cuaderno-incidentes-be.md`, hermano del **20** del track base. Los dos enseñan lo mismo desde orillas opuestas, y con una simetría que conviene notar: allá la suite está **roja** y dice la verdad; acá lleva tres semanas en **verde** y miente.",
"be09-empaquetado-ambientes-y-pipeline.md":
 "> 📓🔥 De esta fase sale el incidente **be-16** de `cuaderno-incidentes-be.md`: la imagen de ayer no arranca y el código no cambió — que es, palabra por palabra, la definición de una etiqueta móvil.",
}
for f, p in ptr.items():
    s = io.open(f, encoding="utf-8").read()
    m = re.search(r'^## 🧪 7\.', s, re.M)
    assert m, f
    s = s[:m.start()] + p + "\n\n---\n\n" + s[m.start():]
    io.open(f,"w",encoding="utf-8").write(s); print(f"  ✓ {f}")
PY
echo
echo "=== re-verificación track BE ==="
python3 - <<'PY'
import re, io, glob
s=io.open("cuaderno-incidentes-be.md",encoding="utf-8").read()
mapa={}
for m in re.finditer(r'^\| (be-\d\d)[^|]*\| (be\d\d) \|', s, re.M): mapa.setdefault(m.group(2),[]).append(m.group(1))
ok=True
for f in sorted(glob.glob("be0*.md")):
    txt=io.open(f,encoding="utf-8").read()
    m=re.search(r'^## ⚠️ 6\..*?(?=^## 🧪 7\.)', txt, re.M|re.S); sec6=m.group(0) if m else ""
    falt=[i for i in mapa.get(f[:4],[]) if f"**{i}**" not in sec6]
    if falt: print(f"  ⚠️ {f}: {falt}"); ok=False
print("  las 10 fases BE enlazan sus incidentes desde §6" if ok else "")
PY

# --- 2026-09-10T02:32:02 · Final complete verification sweep
python3 - <<'PY'
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
PY

# --- 2026-09-10T02:32:22 · Append review log to plan file
cat >> completado_cuaderno_incidentes.md <<'EOF'

---

## 8. 🔎 Revisión final de cierre (2026-09-09)

Barrido completo de las 65 piezas del curso —12 fases base, 13 apéndices, 10 fases BE,
10 apéndices BE, los dos cuadernos y los `prompts/`—. Lo que se corrigió:

| # | Hallazgo | Alcance |
|---|---|---|
| R1 | `historia-del-sistema.md` y `alcance-del-proyecto.md` citados sin su prefijo `00-` | 82 referencias en 18 archivos |
| R2 | Enlaces a la convención de git desde `prompts/` sin `../` | 2 archivos |
| R3 | Anclas rotas en los índices de apéndices | 4 (A2, A4, A6, A7) |
| R4 | Fases que no enlazaban sus incidentes desde §6 (§9 y checklist §14) | 6 base + 10 BE |
| R5 | Referencia colgada `Ver **Forense — Fase 09**` | 1 (ya en P4) |
| R6 | Seis tablas de más de cuatro columnas sin excepción declarada | documentadas en §15 |

**Verificación final, toda en verde:** 0 enlaces y 0 anclas rotos · 20 incidentes en
orden de ID con sus `<details>` balanceados · los 6 hermanos marcados en las dos
direcciones · índice 🩺 en los dos cuadernos · 0 voseo · las 22 fases cumplen la
plantilla de nueve secciones con su pieza forense.

**Falsos positivos descartados** (quedan anotados para no volver a investigarlos): las
118 apariciones de "vale" son el verbo *valer*; "móvil" es etiqueta de imagen o tamaño
de pantalla; `ordenador`/`vosotros` en la guía son su propia lista de prohibiciones;
`DECISIONES-CONFIRMADAS.md` es una mención histórica y `Alcance-del-proyecto.md` un
ejemplo ilustrativo de §12; los `server/*.md` son artefactos que el alumno produce y
están declarados en el checklist de cada fase BE.

**Decisión de no tocar:** los enlaces fase → incidente se hacen **por ID**, no por
ancla. Es lo que pide §9 literalmente, es uniforme en las 22 fases, y las anclas de los
títulos de incidente —con tildes, comillas y ⭐— son justo la clase de enlace frágil que
produjo R3.
EOF
echo "✓ registro de revisión añadido"; wc -l completado_cuaderno_incidentes.md

# --- 2026-09-10T02:40:07 · Verify actual state of the notebook and plan file
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
echo "== incidentes redactados =="; grep -c "^## Incidente " cuaderno-incidentes.md
echo "== placeholders {{Título / {{... =="; grep -n "^## Incidente .*{{" cuaderno-incidentes.md || echo "  ninguno"
echo "== líneas del cuaderno =="; wc -l < cuaderno-incidentes.md
echo "== índice 🩺 =="; grep -c "🩺 Entrar por el síntoma" cuaderno-incidentes.md cuaderno-incidentes-be.md
echo "== README: ¿sigue el callout del hueco? =="; grep -c "todavía no están" README.md || echo "  0"
echo "== guía §15 =="; grep -n "cuaderno de incidentes está vacío" prompts/guia-de-estilo-y-convenciones.md
echo "== plantilla =="; wc -l < prompts/plantilla-de-incidente.md
echo "== git: ¿alguien más tocó el plan? =="; git log --oneline -3 -- completado_cuaderno_incidentes.md 2>/dev/null || echo "  sin historial (untracked)"
echo "== mtime de los archivos clave =="; ls -lT completado_cuaderno_incidentes.md cuaderno-incidentes.md 2>/dev/null | awk '{print $6,$7,$8,$9,$10}'

# --- 2026-09-10T02:40:23 · Check style guide decisions record and pending items
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
echo "=== ¿D1–D6 quedaron anotadas en la guía §15? ==="
sed -n '810,835p' prompts/guia-de-estilo-y-convenciones.md
echo
echo "=== ¿existe el script de siembra del incidente 19? ==="
ls scripts/seedHeavyDay.js 2>/dev/null || echo "  NO existe (esperado: el incidente instruye a escribirlo)"
echo
echo "=== ¿el plan está referenciado desde algún .md? ==="
grep -rln "completado_cuaderno_incidentes" --include="*.md" . 

# --- 2026-09-10T02:40:50 · Final verification sweep with fresh numbers
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
python3 - <<'PY'
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
PY

# --- 2026-09-10T02:41:03 · Replace the stale section 7 with a retraction notice
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
python3 - <<'PY'
import io, re
p="completado_cuaderno_incidentes.md"; s=io.open(p,encoding="utf-8").read()
i=s.index("## 7. ✅ Antes de borrar este archivo")
j=s.index("## 8. 🔎 Revisión final de cierre")
nuevo = """## 7. ⚠️ Verificación obsoleta — RETIRADA

> Esta sección contenía una verificación fechada el 2026-09-09 que declaraba «P1 hecho,
> P2 sin empezar, P3 sin empezar, P4 sin empezar», con el cuaderno en 361 líneas y dos
> placeholders. **Ese texto describía el estado anterior al trabajo y quedó escrito
> encima al final** (su `mtime` era posterior al del propio cuaderno ya redactado).
>
> Era peligroso dejarlo: leído de buena fe, mandaba a rehacer 4.500 líneas ya escritas.
> El estado real, comprobado contra el árbol de trabajo, está en **§9**, que sustituye a
> esta sección punto por punto.

---

"""
s = s[:i] + nuevo + s[j:]
io.open(p,"w",encoding="utf-8").write(s); print("✓ §7 retirada y sustituida por un aviso")
PY
tail -3 completado_cuaderno_incidentes.md

# --- 2026-09-10T02:41:54 · Append complete verified checklist
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
cat >> completado_cuaderno_incidentes.md <<'EOF'

---

## 9. ✅ Checklist de cierre — estado real verificado

> 📌 **Verificado el 2026-09-09 contra el árbol de trabajo**, con los comandos que
> acompañan a cada ítem. Sustituye a la §7 retirada. Regla que usé al marcar: solo va
> `[x]` lo que un comando confirma; lo que depende de criterio va anotado, no marcado.

### 9.1 Decisiones (§4)

- [x] **D1 — índice de síntomas dentro del cuaderno, no en archivo propio.** Aplicada en
      los dos cuadernos. `grep -c "🩺 Entrar por el síntoma" cuaderno-incidentes*.md` → `1` y `1`.
- [x] **D2 — plantilla base extraída.** `prompts/plantilla-de-incidente.md`, 238 líneas,
      con su hermana `-be` apuntándole en la cabecera.
- [x] **D3 — escala de longitud por dificultad.** Vive en la plantilla, §"La escala de
      longitud". Se corrigió una vez sobre la marcha: el piso 🟢 pasó de 110 a 170 líneas
      porque el andamiaje de la estructura cuesta ~90 antes de escribir una idea, y quedó
      anotado el porqué.
- [x] **D4 — tres desenlaces sin commit (02, 10, 20).** Los tres lo declaran en su §🎯, y
      el README lo anuncia en su callout 🧭.
- [x] **D5 — las tres palancas de preparación.** Obligatorias en la plantilla; las seis
      condiciones críticas de §4bis están en el 🔧 Preparación de sus incidentes.
- [x] **D6 — los seis hermanos, con regla de desempate.**
      `grep -c "Hermano del incidente \`be-" cuaderno-incidentes.md` → `6`.

> 📝 **Dónde quedó registrada cada una.** `guia-de-estilo-y-convenciones.md` §15 recoge
> los resultados de D1, D2 y D6, que son los que cambian el mapa de documentos. D3, D4 y
> D5 son convenciones de autoría y viven en `prompts/plantilla-de-incidente.md`, que es su
> lugar canónico. **Es deliberado, no un olvido**: §15 es la sección de deuda conocida, no
> un registro de decisiones.

### 9.2 Hallazgos (§4bis)

- [x] **H1 — el incidente 14, alineado.** `00-convencion-de-git-y-tags.md:239-243` dice
      ahora *"sin takeUntil"* y *"último en el pipe interno"*, que es lo que hace la
      versión corregida de `07-…md:508-528`. Se verificó también el tag `-roto`: su
      `GET /raffles/3/numbers` coincide con el endpoint real.
- [x] **H2 — plantilla extraída y placeholder retirado.**
      `grep -c "^## Incidente .*{{" cuaderno-incidentes.md` → `0`.
- [x] **H3 — las seis condiciones declaradas.** 07, 15 y 17 exigen `CHAOS_LEVEL=high`
      (el 17, en el mock de lotería del `3002`); 16 y 20 exigen la zona horaria; 19 exige
      el volumen.
- [ ] **`scripts/seedHeavyDay.js` no existe.** **Es el único ítem abierto del plan, y es
      deliberado:** el incidente 19 instruye al alumno a escribirlo, porque armar el juego
      de datos que despierta un bug de rendimiento es tan trabajo forense como leer el
      Profiler. Si se prefiere entregarlo hecho, es media hora de trabajo.

### 9.3 Los veinte enunciados (P2)

- [x] **L1 · 01-04** entorno y routing · 816 líneas
- [x] **L2 · 05-08** auth e integración · 867 líneas
- [x] **L3 · 09-12** store y concurrencia, incluye ⭐ 11 · 954 líneas
- [x] **L4 · 13-15, 17** RxJS / epics, incluye ⭐ 14 · 985 líneas
- [x] **L5 · 16, 18-20** tiempo, dinero, performance, testing · 1.024 líneas
- [x] **Los 20, en orden de ID y sin huecos.**
      `grep -c "^## Incidente " cuaderno-incidentes.md` → `20`; secuencia `01…20` verificada.
- [x] **Estructura íntegra.** 80 bloques `<details>` abiertos y 80 cerrados: cuatro por
      incidente —tres pistas y la solución—, sin uno de más ni de menos.
- [x] **Índice contra encabezados.** Las 20 filas coinciden con su incidente en título,
      fase, categoría, dificultad y ⭐. Cero discrepancias.

### 9.4 Aparato forense (P3)

- [x] **Índice 🩺 en el cuaderno base**, entre "Estados" y "📋 Índice": método de cuatro
      preguntas y tabla de dieciséis familias de síntoma.
- [x] **Índice 🩺 en el cuaderno BE**, con las capas y herramientas del backend, sin
      repetir la pregunta del cable que ese archivo ya tenía.
- [x] **Las 22 fases conservan su pieza forense inline** en §6. `0 de 22` incumplen la
      plantilla de nueve secciones.
- [x] **Decidido y documentado: no se crean `forense-fase-NN.md`.** El razonamiento —es
      alcance nuevo, duplica, reabre el presupuesto de horas y choca con el *content
      lock*— está en §3.2 y no se revisa salvo que cambie el alcance del curso.

### 9.5 Costura (P4)

- [x] **Las 22 fases enlazan sus incidentes desde §6** (12 base + 10 BE). Era el hallazgo
      R4: dieciséis no lo hacían, invisible mientras el cuaderno estaba vacío.
- [x] **Los 12 bloques `### Reservas`** ya no dicen "aunque el enunciado todavía no esté
      redactado".
- [x] **README sin el callout del hueco.** `grep -c "todavía no están" README.md` → `0`.
      En su lugar describe el índice 🩺 y los tres desenlaces sin commit.
- [x] **Guía §15:** la viñeta del cuaderno vacío está tachada y movida a resueltos.
- [x] **Preámbulo del índice corregido:** el ⬜ se explica como estado *del estudiante*,
      no del archivo.

### 9.6 Revisión total del curso (§8)

- [x] **R1 · 82 referencias** a `00-historia-del-sistema.md` y `00-alcance-del-proyecto.md`
      sin su prefijo, en 18 archivos.
- [x] **R2 · 2 enlaces relativos** desde `prompts/` sin `../`.
- [x] **R3 · 4 anclas rotas** en los índices de A2, A4, A6 y A7.
- [x] **R4 · 16 fases** sin enlace a sus incidentes.
- [x] **R5 · 1 referencia colgada** a `Forense — Fase 09`, un archivo que nunca existió.
- [x] **R6 · 6 tablas anchas** sin excepción declarada, ahora documentadas en §15.

### 9.7 Verificación final, con sus comandos

| Comprobación | Resultado |
|---|---|
| Archivos revisados | **65** |
| Enlaces y anclas rotos | **0** |
| Incidentes base · BE | **20** · **16** |
| `<details>` balanceados | **80 / 80** |
| Hermanos marcados | **6** |
| Placeholders sin rellenar | **0** |
| Voseo en todo el curso | **0** |
| Fases que incumplen la plantilla | **0 de 22** |
| Líneas · cuaderno base / BE | **4.906** / **3.853** |

> ⚠️ **Dos verificadores míos dieron falsos resultados y hubo que rehacerlos**, y conviene
> saberlo antes de reutilizar estos comandos: el de anclas generaba el *slug* sin tildes
> (reportó 74 rotas donde había 4) y el de voseo usaba `\b` con caracteres acentuados
> (reportó "limpio" con un `Mirá` dentro). Las cifras de arriba son de las versiones
> corregidas. También se descartaron como falsos positivos las 118 apariciones de "vale"
> —el verbo *valer*— y los `server/*.md`, que son artefactos que el alumno produce.

### 9.8 Para dar el contenido por cerrado

- [x] Consistencia — índice contra encabezados, hermanos en las dos direcciones,
      metadatos, plantilla de nueve secciones, bloques de tag.
- [x] Continuidad y estilo — tuteo sin voseo, sin regionalismos de España, tono uniforme
      entre los veinte enunciados y con el cuaderno BE que sirvió de modelo.
- [x] Enlaces — 0 rotos sobre 65 archivos, anclas incluidas.
- [x] Archivos del cuaderno de incidentes — los dos completos, con su plantilla, su índice
      por ID y su índice por síntoma.
- [x] Forense — inline en las 22 fases, con puerta de entrada por síntoma y la decisión de
      no duplicarlo en archivos aparte, argumentada.
- [ ] `scripts/seedHeavyDay.js` — abierto a propósito (9.2).
- [x] **Este archivo no está referenciado desde ningún `.md` del curso.**
      `grep -rln "completado_cuaderno_incidentes" --include="*.md" .` → solo él mismo.
- [ ] `rm completado_cuaderno_incidentes.md` — cuando lo decidas. Es lo último que queda.
EOF
wc -l completado_cuaderno_incidentes.md; echo; grep -c "^- \[x\]" completado_cuaderno_incidentes.md; grep -c "^- \[ \]" completado_cuaderno_incidentes.md

# --- 2026-09-10T02:42:02 · Verify plan structure and open items
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
echo "=== estructura del plan ==="; grep -n "^## " completado_cuaderno_incidentes.md
echo; echo "=== los 3 ítems abiertos ==="; grep -n "^- \[ \]" completado_cuaderno_incidentes.md
echo; echo "=== suma de líneas por lote, contra lo medido ==="
awk '/^## Incidente/{if(t)print n; n=0} {n++} END{print n}' cuaderno-incidentes.md | tail -20 | paste -sd+ - | bc

# --- 2026-09-10T02:43:44 · Check remaining uncovered review dimensions
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
echo "=== 1. deuda declarada abierta en la guía §15 ==="
sed -n '/## 15/,/## 16/p' prompts/guia-de-estilo-y-convenciones.md | grep -n "^- \*\*" | grep -v "~~"
echo
echo "=== 2. secciones de Referencias por archivo ==="
python3 - <<'PY'
import glob, io, re
faltan=[]
for f in sorted(glob.glob("[0-9A]*.md")+glob.glob("be*.md")):
    if f.startswith(("00-alcance","00-historia","00-convencion")): continue
    s=io.open(f,encoding="utf-8").read()
    if not re.search(r'^#+ .*Referencias', s, re.M): faltan.append(f)
print("  sin sección de Referencias:", faltan or "ninguno")
PY
echo
echo "=== 3. URLs externas: cuántas y nunca verificadas ==="
grep -rhoE "https?://[^ )\`\"]+" --include="*.md" . | grep -v completado_ | sort -u | wc -l
echo
echo "=== 4. ejercicios en apéndices (la guía pide 5-10 cortos) ==="
python3 - <<'PY'
import glob, io, re
for f in sorted(glob.glob("A[0-9]*.md")+glob.glob("be-a-*.md")):
    s=io.open(f,encoding="utf-8").read()
    m=re.search(r'^#+ .*Ejercicios[^\n]*\((\d+)\)', s, re.M)
    print(f"  {f}: {m.group(1) if m else 'SIN conteo'}")
PY

# --- 2026-09-10T02:43:58 · Check hour budget consistency across documents
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
echo "=== ¿las cifras de horas coinciden entre documentos? ==="
grep -rn "96 h\|96 horas\|84 h\|84 horas" --include="*.md" . | grep -v completado_ | sed 's/:.*\(9[0-9] h\|9[0-9] horas\|84 h\|84 horas\)/ → \1/' | head -20
echo
echo "=== reparto por fase: ¿dónde vive? ==="
grep -rn "^| *0[0-9] *|.*h *|" --include="*.md" 00-alcance-del-proyecto.md prompts/*.md 2>/dev/null | head -8
grep -n "horas" 00-alcance-del-proyecto.md | head -8

# --- 2026-09-10T02:44:08 · Check whether per-phase hours exist and conflict
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
echo "=== ¿alguna fase declara sus propias horas? ==="
grep -rnoE "\*\*[0-9]{1,2} ?(h|horas)\*\*|\b[0-9]{1,2} horas\b" --include="*.md" 0*.md 1*.md be0*.md | grep -v "96\|84\|veinte minutos" | head -20
echo
echo "=== ¿existe un reparto por fase en algún documento? ==="
grep -rn "reparto\|horas por fase\|presupuesto" --include="*.md" 00-alcance-del-proyecto.md prompts/instrucciones-del-proyecto.md prompts/propuesta-fases-backend.md | head -10

# --- 2026-09-10T02:44:19 · Sum declared hours per phase against the stated totals
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
python3 - <<'PY'
import glob, io, re
def suma(pat, excl=()):
    t=0; det=[]
    for f in sorted(glob.glob(pat)):
        if f.startswith(excl): continue
        m=re.search(r'^\*\*(\d+) horas\*\*', io.open(f,encoding="utf-8").read(), re.M)
        if m: t+=int(m.group(1)); det.append(f"{f[:4]}={m.group(1)}")
        else: det.append(f"{f[:4]}=SIN")
    return t, det
b,db = suma("[01][0-9]-*.md", ("00-alcance","00-historia","00-convencion"))
e,de = suma("be0*.md")
print("BASE:", " ".join(db)); print(f"  suma = {b} h   (declarado: 96)  {'✅' if b==96 else '❌ NO CUADRA'}")
print("BE  :", " ".join(de)); print(f"  suma = {e} h   (declarado: 84)  {'✅' if e==84 else '❌ NO CUADRA'}")
PY

# --- 2026-09-10T02:44:26 · Inspect the header format of phases
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
sed -n '1,5p' 05-venta-de-numeros.md; echo "---"; sed -n '1,5p' be05-venta-concurrente.md

# --- 2026-09-10T02:44:32 · Sum phase hours with corrected regex
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
python3 - <<'PY'
import glob, io, re
def suma(pat, excl=()):
    t=0; det=[]
    for f in sorted(glob.glob(pat)):
        if f.startswith(excl): continue
        head="\n".join(io.open(f,encoding="utf-8").read().split("\n")[:6])
        m=re.search(r'\*\*(\d+) horas\*\*', head)
        if m: t+=int(m.group(1)); det.append(f"{f.split('-')[0]}={m.group(1)}")
        else: det.append(f"{f.split('-')[0]}=SIN")
    return t, det
b,db = suma("[01][0-9]-*.md", ("00-alcance","00-historia","00-convencion"))
e,de = suma("be0*.md")
print("BASE:", " ".join(db)); print(f"  suma = {b} h  ·  declarado 96  →  {'✅ cuadra' if b==96 else '❌ NO CUADRA'}")
print("BE  :", " ".join(de)); print(f"  suma = {e} h  ·  declarado 84  →  {'✅ cuadra' if e==84 else '❌ NO CUADRA'}")
PY

# --- 2026-09-10T02:44:50 · Close the hours budget debt in the style guide
cd /Users/oskar/Developer/Learning/courses-ia-generated/react-16-legacy-for-backend-devs
python3 - <<'PY'
import io
p="prompts/guia-de-estilo-y-convenciones.md"; s=io.open(p,encoding="utf-8").read()
old = """- **Presupuesto horario.** Las 96 h y el reparto por fase circulan en varios
  documentos sin una fuente única que mande. La fuente natural es
  `00-alcance-del-proyecto.md` (§1 y §7); falta que el resto la cite en vez de
  repetir el número. Sigue abierto."""
new = """- ~~**Presupuesto horario.**~~ **Resuelto.** La duda era si las cifras que
  circulan por varios documentos se contradecían. No se contradicen: las horas que
  declara cada fase en su cabecera suman **exactamente** los totales publicados —el
  track base `6+8+8+6+8+12+12+10+8+6+6+6 = 96 h`, y el track BE
  `6+8+10+10+8+10+8+6+10+8 = 84 h`—. Queda fijada la autoridad: manda
  `00-alcance-del-proyecto.md` (§1 y §7) para los totales, y la cabecera de cada
  fase para su tramo. Si alguna vez dejan de cuadrar, gana el alcance y se ajusta
  la fase."""
assert s.count(old)==1
io.open(p,"w",encoding="utf-8").write(s.replace(old,new)); print("✓ §15: presupuesto horario cerrado")
PY
echo; echo "=== deuda que queda abierta en la guía §15 ==="
sed -n '/## 15/,/## 16/p' prompts/guia-de-estilo-y-convenciones.md | grep "^- \*\*" | grep -v "~~"

# --- 2026-09-10T02:47:09 · Read existing memory entries
cat /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/track-be-react16-escrito.md 2>/dev/null; echo "=== MEMORY.md ==="; cat /Users/oskar/.claude/projects/-Users-oskar-Developer-Learning-courses-ia-generated/memory/MEMORY.md

