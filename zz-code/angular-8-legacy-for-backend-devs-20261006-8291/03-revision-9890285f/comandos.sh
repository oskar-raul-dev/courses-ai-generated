# Comandos Bash de la sesión 9890285f-c3d2-451f-b4c1-bb3582ab905d, en orden. Una bitácora, no un script: no se corre entera.

# --- 2026-09-10T16:06:11 · List Angular 8 course files and sizes
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs && ls -la && echo "=== wc prompts ===" && wc -l prompts/*.md *.md

# --- 2026-09-10T16:06:15 · Read start of Angular 8 incident notebook
sed -n '1,120p' cuaderno-incidentes.md

# --- 2026-09-10T16:06:20 · Read rest of Angular 8 incident notebook
sed -n '120,355p' cuaderno-incidentes.md

# --- 2026-09-10T16:06:27 · Inspect Angular 16 prompts and notebook
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-16-legacy-for-backend-devs && ls prompts && echo "=== " && wc -l cuaderno-incidentes*.md prompts/*.md 2>/dev/null && echo "=== head cuaderno ===" && head -40 cuaderno-incidentes.md

# --- 2026-09-10T16:06:33 · Find notebook references in Angular 8 prompts
cd /Users/oskar/Developer/Learning/courses-ia-generated && grep -rn "cuaderno" angular-8-legacy-for-backend-devs/prompts/*.md | head -60

# --- 2026-09-10T16:06:40 · Compare style guide incident sections
echo "###### A8 guia 590-660" && sed -n '590,665p' angular-8-legacy-for-backend-devs/prompts/guia-de-estilo-y-convenciones.md && echo "###### A16 guia grep" && grep -n "cuaderno\|incidente" angular-16-legacy-for-backend-devs/prompts/guia-de-estilo-y-convenciones.md | head -40

# --- 2026-09-10T16:06:51 · Check React 16 course structure
ls react-16*/prompts 2>/dev/null; ls -d */ ; echo "--- react cuaderno ---"; ls react-16*/ 2>/dev/null | grep -i cuaderno

# --- 2026-09-10T16:06:56 · Check React 16 notebook and template sizes
wc -l react-16-legacy-for-backend-devs/cuaderno-incidentes*.md react-16-legacy-for-backend-devs/prompts/plantilla-de-incidente*.md

# --- 2026-09-10T17:41:12 · Read Angular 8 phases proposal
cd /Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs && echo "=== fases table ===" && sed -n '1,120p' prompts/propuesta-fases-y-alcance.md

# --- 2026-09-10T17:41:15 · Extract incident reservation tables from phases
grep -n "Reservas para el cuaderno" -A 22 0*.md 1*.md 2>/dev/null | grep -E "^\S+[-:]\s*\|" | head -60

# --- 2026-09-10T17:41:18 · Find reservation sections in phase files
grep -rn "Reservas para el cuaderno\|Reservas del cuaderno\|reserva.*cuaderno" *.md | head -30

# --- 2026-09-10T17:41:22 · Read all reservation blocks
for f in 05 06 07 08 09 10 11 12 13 14; do echo "########## $f"; awk '/Reservas para el cuaderno/,/^## |^---$/' ${f}-*.md | head -30; done

# --- 2026-09-10T17:41:28 · Find incident reservations in remaining phases
for f in 00 01 02 03 04 11 12; do echo "########## $f"; grep -n "incidente\*\*\|incidentes \*\*\|^- \*\*0[0-9]\*\*\|^- \*\*1[0-9]\*\*\|^- \*\*2[0-9]\*\*" ${f}-*.md | head -12; done

# --- 2026-09-10T17:41:34 · Read weekly distribution section
sed -n '/^## .*6\./,/^## .*7\./p' prompts/propuesta-fases-y-alcance.md | head -80; echo "=== grep semana ==="; grep -n "Semana [1-4]" prompts/propuesta-fases-y-alcance.md | head -20

# --- 2026-09-10T17:41:47 · Read tag conventions
grep -n "inc/\|fase-\|be-fase\|incidente/" 00-convencion-de-git-y-tags.md | head -50

# --- 2026-09-10T17:41:51 · Read BE tag namespace and BE notebook spec
sed -n '366,402p' 00-convencion-de-git-y-tags.md; echo "=== BE cuaderno spec ==="; sed -n '/cuaderno-incidentes-be/,+0p' prompts/propuesta-fases-backend.md | head; grep -n "be-01\|be-12\|sin par\|-roto" prompts/propuesta-fases-backend.md | head -20

# --- 2026-09-10T17:41:58 · Find BE incident ID reservations
grep -n "be-0[0-9]\|be-1[0-2]" prompts/propuesta-fases-backend.md prompts/prompts-backend-fase.md prompts/prompts-backend-apendice.md | grep -i "incident\|·" | head -30

# --- 2026-09-10T17:42:04 · Map BE phases to reserved incidents
grep -n "^## \|Incidentes reservados" prompts/prompts-backend-fase.md | head -40

# --- 2026-09-10T17:42:07 · List BE phase titles and locate empty-diff incident
grep -n "^## # Fase be" prompts/prompts-backend-fase.md; echo "=== be07 empty diff ==="; grep -n "be07\|MONGO_TAG\|\.env" prompts/propuesta-fases-backend.md | head -20

# --- 2026-09-10T17:42:13 · Read forensic format doc head and tail
sed -n '1,40p' prompts/formato-piezas-forenses.md; echo "=== tail ==="; sed -n '230,259p' prompts/formato-piezas-forenses.md

# --- 2026-09-10T17:42:17 · Check style guide sections and forense master TOC
grep -n "^## \|details\|HTML" prompts/guia-de-estilo-y-convenciones.md | head -40; echo "=== forense-master §3 ==="; grep -n "^## " forense-master.md | head

# --- 2026-09-10T17:42:23 · Read forensic method and mock conventions
sed -n '12,31p' forense-master.md; echo "=== mock path ==="; grep -rn "npm run mock\|mock/db.json\|CHAOS=" 04-mock-api-caos.md | head -12

# --- 2026-09-10T17:42:26 · Determine db.json path convention
grep -rn "db\.json" 04-mock-api-caos.md | grep -o "[a-z/]*db\.json" | sort | uniq -c | sort -rn | head

# --- 2026-09-10T17:42:29 · Check mock directory layout
grep -rn "mock/" 04-mock-api-caos.md | head -8

# --- 2026-09-10T17:42:31 · Locate mock file paths
grep -rn "db.json\|server.js\|npm run seed" 04-mock-api-caos.md | head -14

# --- 2026-09-10T17:42:35 · Check whether a seed script exists
grep -rn "npm run seed\|\"seed\"" *.md | head

# --- 2026-09-10T17:45:07 · Write the notebook format specification
cat > prompts/formato-cuaderno-incidentes.md <<'FIN'
# 📓 Formato del cuaderno de incidentes
## Tutorial Angular 8 — Laboratorio clínico

Este documento **no es** el cuaderno: es su especificación. Define cómo se
construye `cuaderno-incidentes.md`, que es el único archivo de incidentes del
track base y el entregable del chat correspondiente. La §🔥 final lo extiende a
`cuaderno-incidentes-be.md`, el cuaderno del track opcional de backend.

> 🧭 **Un solo archivo, sin excepción.** El documento base preveía un
> `incidente-NN-*.md` por incidente, y esa decisión se revirtió antes de escribir
> una sola entrada: el estudiante trabaja sin instructor y necesita índice,
> enunciado, pistas, solución y su propia bitácora a un scroll de distancia. Está
> corregido en `prompts/alcance-del-proyecto.md` §, en
> `prompts/propuesta-fases-y-alcance.md` §7 y en la Fase 13, que lo repite porque
> es donde más tienta partirlo. **Los IDs son globales y nunca se reasignan**,
> aunque un incidente se retire.

**Presupuesto:** 21 incidentes, **14h** repartidas en el mes, ≈3.5h por semana.
Está fuera de las 108h de las fases y así suma las 122h de
`propuesta-fases-y-alcance.md` §2.

**Fuentes de verdad de esta especificación**, en el orden de la §12 de la guía de
estilo: `prompts/alcance-del-proyecto.md`,
`prompts/propuesta-fases-y-alcance.md` §6,
`prompts/guia-de-estilo-y-convenciones.md` §13 —con
`00-convencion-de-git-y-tags.md` como anexo para todo lo que toque git, y
`prompts/formato-piezas-forenses.md` como su hermano para el track forense—, y las
quince fases ya publicadas, que son las que reservaron los IDs y fijaron el
código, los nombres y las salidas.

---

## 1. Qué hace distinto a este cuaderno

Tres cosas, y las tres salen de que LabCore es un sistema **de 2019 con NgRx y
tres idiomas**, no un sistema genérico con bugs genéricos:

1. **Cuatro incidentes son de estado (store).** Es la categoría más poblada del
   índice —03, 09, 14 y 21— y no es casualidad: la Fase 1 es la más densa del
   curso y el store es donde de verdad se rompen las cosas. **Ninguno de los
   cuatro se resuelve mirando el mismo archivo que el anterior**: uno vive en el
   reducer que no reacciona, otro en el filtro que se hace en el navegador, otro
   en el dato que el PDF leyó antes de tiempo, y el cuarto en un
   `route.snapshot` leído una sola vez en un componente que el router reusa.

   > 📝 **Por qué el 21 existe y no es parte del 10.** Durante un tiempo la lista
   > que no cambia al navegar viajó pegada al incidente 10, con el argumento de
   > que compartían la raíz. No la comparten: el 10 es un `switchMap` que cancela
   > una escritura en vuelo, el 21 es un snapshot de ruta. Comparten la
   > **sensación** del usuario —«no pasó lo que pedí»—, que es justamente lo que
   > un ticket transmite y lo que un diagnóstico tiene que separar. Meterlos en un
   > mismo post-mortem de ocho puntos obligaría a escribir dos causas raíz en la
   > casilla de una. La Fase 7 los separó y por eso el cuaderno tiene 21 y no 20.

2. **Tres incidentes son del núcleo clínico**: el resultado validado sin norma
   detrás (12, normativo), los dos analistas que firmaron el mismo resultado
   (13, concurrencia) y el asiento de auditoría que acusa a quien no estaba (17,
   trazabilidad). Son los que un curso de CRUD no puede producir, y los tres
   anclan deudas 💸 declaradas en su fase.

3. **Dos son de i18n**: la fecha con el locale del navegador en vez del de la app
   (04) y los acentos del PDF en francés (15). La categoría existe porque el
   curso monta tres idiomas desde la Fase 2, y esos bugs solo se ven cuando
   alguien cambia de idioma —que es exactamente cuando ya están en producción.

Y dos ausencias que también son decisiones: la **Fase 6** no toma ningún
incidente, porque su síntoma ya está reservado como candidato en el §📌 de A05; y
la **Fase 14** tampoco, porque es 🔥 opcional y *un incidente que solo pueden
resolver los estudiantes que hicieron una fase opcional no es un incidente del
curso*. Las dos dejaron anotado el mismo **candidato 22**, que **no está dado de
alta**: si algún día se abre, ese es su sitio.

---

## 2. Estructura del archivo

`cuaderno-incidentes.md` se organiza en este orden, y solo en este:

1. **Encabezado** — título, presupuesto horario, y la frase que fija el trato: la
   solución viene incluida y abrirla antes de tiempo solo te perjudica a ti.
2. **🧭 Cómo se trabaja un incidente** — el método, el puente al track forense
   (§4), las tres formas de llegar al sistema roto (§5), la convención de commits
   (§6) y la tabla de estados (§7).
3. **📋 Índice** — la tabla de los 21 IDs (§3).
4. **🧪 Incidentes** — una entrada por incidente, con el bloque completo de §8. Se
   repite entero cada vez: nada de "ver incidente 03". Se leen salteados y con
   semanas de diferencia.
5. **🪞 Retrospectiva del mes** — §9.
6. **📌 Pendientes que salieron de los incidentes** — §10.
7. **🔥 El cuaderno hermano del track de backend** — el puntero, en tres párrafos.

---

## 3. El índice y la reserva de IDs

El índice se actualiza en el mismo commit que abre o cierra un incidente. Un ⬜
significa que el enunciado todavía no está redactado abajo — **la fila existe
desde el momento en que una fase reserva el ID**, en su sección
📌 *Reservas para el cuaderno de incidentes*.

Formato de la tabla:

```markdown
| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| 01 | 0 | Guardé el paciente y la pantalla dice que no se pudo | Despliegue | 🟢 | ⬜ |
```

El título va **en palabras del usuario**, no en lenguaje técnico. *"A veces no
carga"* es un buen título —y es el del incidente 08—; *"json-server devuelve 500
intermitente con `fail=500@30`"* es la respuesta, y va en la solución.

### El reparto de los 21

Las fases ya lo fijaron al reservar sus IDs, y **ese reparto manda**: son
entregables cerrados y reasignar un ID partiría alguno de ellos.

- **Semana 1** — fases 0-4 · **7 incidentes** (01, 02, 03, 04, 05, 06, 08):
  setup, la máquina de al lado, el store que no se entera, la fecha en el idioma
  equivocado, la sesión que sobrevive en la otra pestaña, la respuesta malformada
  con `200` y el intermitente.
- **Semana 2** — fases 5-8 · **7 incidentes** (07, 09, 10, 11, 12, 13, 21): la
  baja lógica que sigue en la lista, la escritura cancelada, la custodia
  imposible, la norma que falta, la doble firma y la alerta del sábado.
- **Semana 3** — fases 9-11 · **4 incidentes** (14, 15, 16, 17): el informe con
  datos viejos, los acentos del PDF, el dashboard que se arrastra y el asiento de
  auditoría que acusa a quien no estaba.
- **Semana 4** — fases 12-13 · **3 incidentes** (18, 19, 20): el test que falla
  en la máquina de al lado, PROD hablándole a UAT y el 404 al recargar.

> 📝 **Esto no coincide con `propuesta-fases-y-alcance.md` §6, y el índice gana.**
> Aquel documento proyectaba 4-5 / 5-6 / 5-6 / 4-5 con una semana por color
> (🟢 la primera, 🔴 la última). Al cerrar las quince fases, las reservas dieron
> 7 / 7 / 4 / 3, y la escala real quedó **2 🟢 · 8 🟡 · 9 🟠 · 2 🔴**: el curso
> carga incidentes en las fases que producen material y se aligera al final,
> cuando el estudiante ya está desplegando. Forzar el reparto teórico exigiría
> inventar incidentes en fases que declararon no tener ninguno —la 6 y la 14, por
> escrito— o mover IDs entre fases cerradas. **Se escribe el reparto real y se
> dice por qué**, que es más honesto que una curva bonita.
>
> Lo que sí se conserva de §6 es la **progresión**: la semana 1 arranca con los
> dos únicos 🟢 y no tiene ningún 🔴, y los dos 🔴 están los dos en la semana 4.

### Categorías

Máquina de estados · concurrencia · tiempo · normativo · trazabilidad ·
integración · performance · UI · estado (store) · i18n · despliegue · testing.

Son doce y están cerradas en `propuesta-fases-y-alcance.md` §6. No se inventan
categorías nuevas al redactar: si un incidente no entra en ninguna, casi siempre
es que el enunciado mezcla dos incidentes.

### Dificultad

🟢 fácil · 🟡 intermedio · 🟠 difícil · 🔴 muy difícil. Va también un **tiempo
sugerido** por incidente (20-40 min los 🟢, hasta 2h los 🔴), porque sin él el
estudiante no sabe cuándo está atascado de verdad.

---

## 4. El puente con el track forense

El cuaderno **da el ticket; el track forense da el método**, y los dos se
enlazan en las dos direcciones. Es la diferencia entre un banco de bugs y un
curso de diagnóstico.

- El encabezado del cuaderno manda al **índice de síntomas transversal** de
  [`forense-master.md`](../forense-master.md) §3 —el que cruza *"esto es lo que
  veo"* con *"empieza acá"*— para quien no sepa ni de qué fase es su problema, y
  al método de las cuatro preguntas de §1.
- Cada incidente enlaza la pieza `forense-fase-NN.md` de su fase cuando esa pieza
  recorre la misma ruta. El enlace recíproco ya existe:
  `formato-piezas-forenses.md` §8 obliga a cada pieza a enlazar los incidentes que
  usan su ruta, **por el ID que este índice les reserva**.
- La 🔧 Preparación de un incidente **es** la respuesta a la pregunta 1 del
  método forense —*¿se reproduce con un flag, con un dato, o hace falta otro
  código?*—, ya escrita. Por eso la §5 tiene exactamente tres formas y no cuatro.

Lo que **no** se hace es reexplicar el método dentro de un incidente. Si un
párrafo del cuaderno se puede copiar de `forense-master.md`, sobra: se enlaza.

---

## 5. Cómo llega el sistema roto a la máquina del estudiante

Cada incidente lo dice en su bloque «🔧 Preparación», y hay exactamente tres
formas. El orden no es casual: **se usa siempre la más barata que sirva**, porque
una preparación complicada es una excusa para saltarse el incidente.

**1. Un flag del inyector de caos** (Fase 4), cuando el fallo es de red o de
respuesta. Es la preferida: no toca tu código, no toca tus datos, y se apaga sola
al reiniciar el mock. `CHAOS=malformed npm run mock` y ya estás dentro del
incidente 06. Los flags disponibles son los que construye la Fase 4 —`latency`,
`fail=NNN@P`, `timeout`, `expired`, `malformed`—, y **no se inventan flags
nuevos**: si un incidente necesita uno que no existe, la fase lo tendría que haber
construido y hay que revisar el enunciado.

**2. Un `db.json` alterno**, cuando el bug está en el dato y no en el código —una
muestra con la custodia imposible, un resultado validado sin norma detrás—. Se
llaman `db.incidente-NN.json`, viven junto al `db.json` en la raíz del proyecto, y
se activan copiando: `cp db.incidente-11.json db.json`. Guarda el tuyo antes, o
corre `npm run seed` después para volver — el `seed.js` de la Fase 5 regenera todo
de forma estable entre corridas, así que volver no cuesta nada.

**3. Una rama de git**, y solo cuando haya que romper código. Se llaman
`incidente/NN`, salen del commit donde terminaste la fase correspondiente, y traen
el cambio mínimo que produce el síntoma: una línea movida, un operador cambiado,
un selector mal escrito. Ese commit de partida es justamente el tag que el
estudiante puso al cerrar la fase, así que la rama se crea sin buscar nada:

```bash
git checkout -b incidente/06 fase-04-mock-api-caos
```

Ojo con el nombre del tag: en este curso los tags de fase llevan **el slug
completo del archivo** (`fase-04-mock-api-caos`, no `fase-04`), según
[`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md). Los
enunciados escriben el tag entero; abreviarlo produce un comando que no corre.

> 🧭 **La regla, y sirve más allá de este cuaderno:** cuando alguien te pida
> reproducir un bug, la primera pregunta es *"¿esto se reproduce con un flag, con
> un dato, o hace falta otro código?"*. Las tres respuestas llevan a
> investigaciones distintas, y averiguar cuál es te ahorra la mitad del camino
> antes de leer una línea.

---

## 6. Convención de commits

El asunto del commit sigue este formato, para que `git log --oneline` se lea como
la línea de tiempo de la investigación:

```
incidente(07): abre — resultados críticos sin alerta el sábado
incidente(07): repro — falla con TZ del navegador en UTC-5
incidente(07): hipótesis descartada — no es el effect, la acción sí se despacha
incidente(07): causa — comparación de fecha sin zona horaria en el selector
incidente(07): fix — normaliza a la TZ de la aplicación antes de comparar
incidente(07): cierre — test de regresión y post-mortem
```

Los verbos son fijos: `abre`, `repro`, `hipótesis`, `hipótesis descartada`,
`causa`, `fix`, `cierre`.

Commitea también los callejones sin salida. Un `git log` con seis commits de
investigación y uno de fix es un registro honesto; uno que muestra solo el fix no
le sirve a nadie, y menos a ti dentro de seis meses.

Y como el fix de casi todos estos incidentes es de una o dos líneas, conviene
marcarlo además con el par de tags de
[`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md):
`inc/07/alerta-del-sabado-roto` con el síntoma reproducido y la regresión en rojo,
`inc/07/alerta-del-sabado-fix` con la causa raíz y el fix en verde. El `git diff`
entre los dos **es** el punto 5 del post-mortem, aislado del ruido de la fase, y
`git tag -n99 -l 'inc/*'` devuelve el cuaderno entero sin abrir un archivo. El ID
es el que el índice ya tiene reservado, nunca uno inventado.

> 💡 Para releer la historia de un incidente:
> `git log --oneline --grep "incidente(07)" -- cuaderno-incidentes.md`

Regla del archivo: se **agrega**, no se corrige. Una hipótesis que resultó falsa
no se borra, se marca como descartada con la evidencia que la tumbó.

---

## 7. Estados

| Estado | Significado |
|---|---|
| ⬜ Sin empezar | Todavía no lo tocaste |
| 🔴 Abierto | Leído, sin reproducir |
| 🟡 En análisis | Reproducido, causa raíz sin confirmar |
| 🟢 Cerrado | Fix aplicado y test de regresión pasando |
| ⚪ Descartado | No se reproduce, y está documentado por qué |

---

## 8. Plantilla de un incidente

Se copia entera para cada entrada. Los `<details>` son la única excepción aceptada
a la regla de "Markdown siempre, nada de HTML embebido" de la guía de estilo §3, y
se acepta porque no hay alternativa: sin plegado, la solución se lee sin querer al
bajar por la página y el ejercicio desaparece.

````markdown
## Incidente {{NN}} — {{Título en palabras del usuario}}

> **Fase:** {{N}} · **Categoría:** {{categoría}} · **Dificultad:** {{🟢🟡🟠🔴}}
> **Estado:** ⬜ Sin empezar · **Abierto:** {{—}} · **Cerrado:** {{—}}
> **Tiempo sugerido:** {{20-40 min}} · **Ruta forense:** {{forense-fase-NN.md §N, o —}}

### 🎫 El ticket

{{El reporte tal como llegó, con su vaguedad incluida. Dos o tres frases en
lenguaje de negocio, escritas por alguien que no sabe qué es un effect. "A veces
no carga" es un dato legítimo, no un defecto del reporte.}}

**Reportado por:** {{rol — auxiliar de toma de muestras, analista, médico,
coordinador del laboratorio}}
**Ambiente:** {{UAT / PROD / ambos}}

### 🎯 Qué se te pide

{{Una o dos líneas con el entregable concreto: reproducir y localizar la capa, o
reproducir y aplicar el hotfix mínimo, o explicar por qué no se reproduce. No
todos los incidentes terminan en fix.}}

### 🔧 Preparación

{{Cuál de las tres formas de §5, y por qué esa.}}

```bash
{{CHAOS=malformed npm run mock | cp db.incidente-NN.json db.json | git checkout -b incidente/NN fase-NN-slug}}
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

{{Señala la capa y la herramienta, sin decir qué vas a encontrar: "esto se ve en
la pestaña Network antes que en la consola" o "el store ya tiene la respuesta
correcta; compara la acción que entra con el estado que sale".}}

</details>

<details>
<summary>💡 <b>Pista 2</b> — qué mirar</summary>

{{Acota al archivo o al momento exacto, todavía sin nombrar la causa.}}

</details>

<details>
<summary>💡 <b>Pista 3</b> — casi la respuesta</summary>

{{La pregunta cuya respuesta es la causa raíz.}}

</details>

---

### 📝 Tu investigación

{{Esto lo escribes tú, antes de abrir la solución. Es la parte que se versiona y
la que releerás en la retrospectiva del mes.}}

**Reproducción**
{{Pasos numerados y exactos, con datos concretos: qué paciente, qué orden, qué
estado de muestra, qué hora y en qué zona horaria. Si no lo lograste, escribe qué
intentaste — no reproducir también es un resultado.}}

**Evidencia observable**
{{Lo que viste, no lo que supones: consola, Network, Redux DevTools, logs del
mock. Texto, no capturas: el texto se versiona. Y en el orden de desconfianza que
instala la Fase 4 —pantalla, store, red—, porque el cuerpo de la respuesta es la
única capa que no interpreta nada.}}

```
{{payload, error o secuencia de acciones despachadas}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea, o la decisión de diseño culpable.}}

**Tu fix**
{{El parche mínimo que aplicarías un viernes a las seis, escrito en el estilo del
archivo que tocaste. Aparte, en una línea, la refactorización correcta que harías
con calma — distinguir las dos es una de las lecciones más transferibles del
curso.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

{{Hasta el archivo y la línea. Si la causa es una decisión de diseño, se nombra la
decisión y se explica por qué en 2019 tenía sentido.}}

**Parche mínimo**

```typescript
{{el hotfix, con comentarios en español y en el estilo del archivo que se toca:
TS-0 heredado —`strict: false`, `any` tolerado—, reducers en `switch`, y un solo
idioma para el `this` (§6 de la guía)}}
```

**La refactorización correcta** (que en Track A 💸 no se paga)

{{Qué haría alguien con tiempo y pruebas, y por qué acá no se hace. Si la deuda
que originó el bug está marcada 💸 en alguna fase, decir en cuál.}}

**Prueba de regresión**

{{El test que falla antes del fix y pasa después. Código, no descripción.}}

```typescript
{{spec}}
```

**Prevención**

{{Test, feature flag, alerta o validación en el reducer.}}

**Por qué llegó a producción**

{{Post-mortem sereno: qué del sistema o del proceso lo permitió. Se analiza el
sistema, nunca a la persona. Acá el humor baja un punto.}}

**Si tu causa fue distinta a esta**

{{Los diagnósticos alternativos plausibles y por qué el síntoma también encaja con
ellos. Que tu fix funcione y tu causa no coincida es información: casi siempre
significa que tapaste el síntoma en una capa más arriba.}}

</details>
````

Los ocho puntos de la guía de estilo §13 están todos ahí y en este orden: síntoma
(🎫), reproducción y evidencia (📝), causa raíz, corrección, prueba de regresión,
prevención y post-mortem (✅). Si al redactar falta alguno, el incidente no está
terminado aunque el fix funcione.

---

## 9. Retrospectiva del mes

Cierra el archivo. Se llena al terminar, de una sola vez, releyendo el propio
`git log`:

- **Cuántos abriste, cuántos cerraste, cuántos quedaron ⚪.**
- **Cuántas veces tu causa raíz coincidió con la de referencia**, y en cuáles no.
  El patrón importa más que el número.
- **En qué capa te costó más**: plantilla, componente, selector, reducer, effect,
  interceptor, mock, build, contenedor.
- **Cuántas veces le creíste a la pantalla o al store antes que a la red.** Es la
  métrica propia de este track: el orden de desconfianza —pantalla, store, red—
  se instala en la Fase 4 y se olvida a la primera urgencia.
- **Qué pista abriste antes de tiempo y por qué**. Sin culpa; es un dato sobre
  dónde te falta confianza, no sobre tu disciplina.
- **Tu checklist de hotfix**, la de una página, reescrita con lo que aprendiste.
  Es lo único de este archivo que te llevas al trabajo real.

---

## 10. Pendientes que salieron de los incidentes

Lo que apareció investigando y no cabía en el fix, con el ID que lo originó:

```markdown
- **[06]** {{pendiente}} → sugerido para {{apéndice / fase / ejercicio 🔥}}.
```

---

## 11. Checklist antes de dar por cerrado el cuaderno

- [ ] 21 incidentes, con el reparto por semana de §3 y la escala
      2 🟢 · 8 🟡 · 9 🟠 · 2 🔴.
- [ ] Cuatro de estado (store) con cuatro causas raíz distintas, tres del núcleo
      clínico (normativo, concurrencia, trazabilidad) y dos de i18n.
- [ ] Todos los IDs del índice tienen entrada abajo, ninguno se reasignó, y el 22
      sigue **sin dar de alta**.
- [ ] Cada incidente dice cuál de las tres formas de preparación usa, y usa la más
      barata que sirve. Cero flags de caos que la Fase 4 no construyó.
- [ ] Los tags de fase se escriben con el slug completo
      (`fase-04-mock-api-caos`), y los pares `inc/<ID>/…-roto` / `…-fix` usan el
      ID del índice.
- [ ] Cada solución trae parche mínimo, refactorización correcta —con la nota de
      que en Track A 💸 no se paga—, test de regresión **en código**, prevención y
      post-mortem sin culpabilización.
- [ ] Los títulos están en palabras del usuario, no en lenguaje técnico.
- [ ] Todo el código en inglés, comentarios en español, y el parche escrito en el
      estilo del archivo que toca: TS-0 heredado, `any` tolerado, reducers en
      `switch`, un solo idioma para el `this`.
- [ ] Coherencia de la ficción (§11 de la guía): todo archivo, acción o selector
      que se nombra está escrito en alguna fase y se puede abrir.
- [ ] Los incidentes enlazan su ruta forense cuando existe, y ninguna entrada
      reexplica el método de `forense-master.md` §1.
- [ ] La retrospectiva, los pendientes y el puntero al cuaderno BE están al final,
      en ese orden.

---

## 🔥 El cuaderno del track de backend

Este formato aplica igual a **`cuaderno-incidentes-be.md`**, el cuaderno del track
opcional de backend (Java 8 + Spring Boot 2.1 + MongoDB): mismo esqueleto de
incidente, mismas pistas plegadas, mismo post-mortem sin culpabilización.

Cambian cuatro cosas, y las cuatro están declaradas en
`prompts/propuesta-fases-backend.md`:

- **Son 12 incidentes y 8h**, con IDs `be-01` … `be-12` en un rango
  **independiente** del cuaderno base. Los dos no se cruzan ni se renumeran el uno
  al otro. Las reservas por fase están en `prompts/prompts-backend-fase.md`: `be01`
  toma `be-01`; `be02`, `be-02` y `be-03`; `be03`, `be-04` y `be-05`; `be04`,
  `be-06` y `be-07`; `be05`, `be-08` y `be-09`; `be06`, `be-10`; `be07`, `be-11`
  ⭐; `be08`, `be-12`. La fase `be00` no toma ninguno.
- **La separación es deliberada.** Quien haga solo el track base no tiene por qué
  recibir incidentes de Mongo mezclados con los suyos, y quien haga los dos sabe
  en todo momento de qué capa es el ticket que está leyendo — que es justamente el
  músculo que los dos cursos entrenan.
- **La preparación del sistema roto** no usa el `db.json`: usa el `.env`, una
  migración, o una colección sembrada a propósito. La sección §5 se reescribe
  entera para el track, y los tags viven en el namespace `be-fase-*` para que
  `git tag -l 'fase-*'` siga siendo el índice limpio del track base.
- ⚠️ **El incidente `be-11` no tiene par `-roto` / `-fix`.** Es el de la fase
  `be07` —la subida de versión que nadie decidió— y su `git diff` está vacío a
  propósito, porque su causa está en una línea del `.env` (`MONGO_TAG`) y no en el
  árbol de fuentes. No es un incumplimiento del formato: es el contenido del
  incidente, y en un curso construido sobre el `git diff` como factura de la deuda
  es exactamente la lección —*`git log`, `git blame` y el último despliegue no
  siempre tienen la respuesta*—. El enunciado tiene que decirlo **al resolverlo**,
  no antes.
FIN
wc -l prompts/formato-cuaderno-incidentes.md

# --- 2026-09-10T17:45:13 · Find section numbers for cited corrections
awk 'NR<160 && /^## /{s=$0} NR==155{print s}' prompts/alcance-del-proyecto.md; sed -n '275,290p' prompts/propuesta-fases-y-alcance.md

# --- 2026-09-10T17:45:19 · Fix dangling section reference
perl -0pi -e 's/en `prompts\/alcance-del-proyecto\.md` §, en\n> `prompts\/propuesta-fases-y-alcance\.md` §7/en `prompts\/alcance-del-proyecto.md` §6, en\n> `prompts\/propuesta-fases-y-alcance.md` §7/' prompts/formato-cuaderno-incidentes.md && sed -n '8,18p' prompts/formato-cuaderno-incidentes.md

# --- 2026-09-10T17:45:25 · Verify section containing the correction note
awk 'NR<285 && /^## /{s=$0; n=NR} NR==281{print n": "s}' prompts/propuesta-fases-y-alcance.md

# --- 2026-09-10T17:45:29 · Read style guide sources-of-truth block
sed -n '604,614p' prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-10T17:45:38 · Add spec pointers to the style guide
python3 - <<'PY'
import io
p='prompts/guia-de-estilo-y-convenciones.md'
s=io.open(p,encoding='utf-8').read()

old="""  que toque git, repos y tags, y `prompts/formato-piezas-forenses.md` como su anexo
  para el track forense—, (5) entregables ya aprobados de fases anteriores,"""
new="""  que toque git, repos y tags, `prompts/formato-piezas-forenses.md` como su anexo
  para el track forense y `prompts/formato-cuaderno-incidentes.md` como su anexo
  para el cuaderno de incidentes—, (5) entregables ya aprobados de fases anteriores,"""
assert s.count(old)==1
s=s.replace(old,new)

old2="""El tono acá baja un punto de humor. Un post-mortem es sereno y analítico —no
acartonado, pero tampoco el lugar para el chiste."""
new2="""El tono acá baja un punto de humor. Un post-mortem es sereno y analítico —no
acartonado, pero tampoco el lugar para el chiste.

Esos ocho puntos son el esqueleto; **el formato completo del archivo —el índice y
la reserva de IDs, las tres formas de repartir el sistema roto, la convención de
commits `incidente(NN):`, la plantilla con las pistas plegadas y el checklist de
cierre— está en `prompts/formato-cuaderno-incidentes.md`**, que es el anexo de
esta guía para todo lo que toque el cuaderno, y cubre también el
`cuaderno-incidentes-be.md` del track BE."""
assert s.count(old2)==1
s=s.replace(old2,new2)

io.open(p,'w',encoding='utf-8').write(s)
print("ok")
PY

# --- 2026-09-10T17:45:45 · Check HTML rule and pending section
sed -n '76,80p' prompts/guia-de-estilo-y-convenciones.md; echo "=== §15 ==="; sed -n '/^## 15\./,/^## 16\./p' prompts/guia-de-estilo-y-convenciones.md | head -30

# --- 2026-09-10T17:45:52 · Declare details exception in style guide
python3 - <<'PY'
import io
p='prompts/guia-de-estilo-y-convenciones.md'
s=io.open(p,encoding='utf-8').read()
old="- **Markdown siempre.** Nada de HTML embebido salvo que no haya alternativa.\n"
new=("- **Markdown siempre.** Nada de HTML embebido salvo que no haya alternativa. La\n"
     "  única excepción conocida y aceptada son los `<details>` del cuaderno de\n"
     "  incidentes: sin plegado, la solución se lee sin querer al bajar por la página\n"
     "  y el ejercicio desaparece (`prompts/formato-cuaderno-incidentes.md` §8).\n")
assert s.count(old)==1
s=s.replace(old,new)
io.open(p,'w',encoding='utf-8').write(s)
print("ok")
PY
grep -n "formato-cuaderno-incidentes" prompts/guia-de-estilo-y-convenciones.md

# --- 2026-09-10T17:46:00 · Verify headings and relative links
grep -n "^## \|^# " prompts/formato-cuaderno-incidentes.md; echo "=== links ==="; grep -o "(\.\./[a-z0-9.-]*)" prompts/formato-cuaderno-incidentes.md | sort -u | while read l; do f=$(echo "$l" | tr -d '()'); [ -f "$f" ] && echo "OK $f" || echo "MISSING $f"; done

# --- 2026-09-10T17:46:05 · Verify link targets exist at course root
for f in 00-convencion-de-git-y-tags.md forense-master.md; do [ -f "$f" ] && echo "OK $f"; done

# --- 2026-09-10T17:47:28 · Check all relative markdown links resolve
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/9890285f-c3d2-451f-b4c1-bb3582ab905d/scratchpad/links.py <<'PY'
import re,os,sys,collections
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
files=[f for f in sorted(os.listdir('.')) if f.endswith('.md')]
files+=['prompts/'+f for f in sorted(os.listdir('prompts')) if f.endswith('.md')]
link=re.compile(r'\[([^\]]*)\]\(([^)]+)\)')
bad=collections.defaultdict(list)
ext=collections.Counter()
for f in files:
    s=open(f,encoding='utf-8').read()
    for m in link.finditer(s):
        t=m.group(2).strip()
        if t.startswith('http'):
            ext[t]+=1; continue
        if t.startswith('#'): continue
        path=t.split('#')[0]
        base=os.path.dirname(f)
        full=os.path.normpath(os.path.join(base,path))
        if not os.path.exists(full):
            bad[f].append((m.group(1)[:40],t))
for f,v in bad.items():
    print("BROKEN",f)
    for a,b in v: print("   ",b,"   <-",a)
print("total externos:",sum(ext.values()),"unicos:",len(ext))
PY
python3 /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/9890285f-c3d2-451f-b4c1-bb3582ab905d/scratchpad/links.py

# --- 2026-09-10T17:47:35 · Count external URLs across the course
grep -roh "https\?://[^ )\`\"<>]*" --include="*.md" . | sed 's/[.,;]$//' | sort | uniq -c | sort -rn | awk '{print $1" "$2}' | head -40; echo "=== total ==="; grep -roh "https\?://[^ )\`\"<>]*" --include="*.md" . | wc -l

# --- 2026-09-10T17:47:45 · Check Angular doc version in URLs and list domains
echo "=== angular.io sin v8 ==="; grep -rn "https://angular\.io\|//angular\.io" --include="*.md" . | head -20; echo; echo "=== dominios ==="; grep -roh "https\?://[a-z0-9.-]*" --include="*.md" . | sort | uniq -c | sort -rn | head -30

# --- 2026-09-10T17:47:52 · Read forensic master index and symptom table
sed -n '1,11p;32,101p' forense-master.md

# --- 2026-09-10T17:48:00 · Map which documents reference each appendix
echo "=== menciones de apéndices por archivo (A01..A13 en cualquier forma) ==="; for n in 01 02 03 04 05 06 07 08 09 10 11 12 13; do c=$(grep -rl "[Aa]$n\b\|a$n-" --include="*.md" . 2>/dev/null | grep -v "^./a$n-" | tr '\n' ' '); echo "A$n <= $c"; done

# --- 2026-09-10T17:48:11 · Count internal links vs bare filename mentions
python3 - <<'PY'
import re,os
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
link=re.compile(r'\[[^\]]*\]\((?!http)([^)#]+)')
bare=re.compile(r'`((?:a\d\d|\d\d)-[a-z0-9-]+\.md|forense-[a-z0-9-]+\.md|cuaderno-incidentes(?:-be)?\.md)`')
rows=[]
for f in sorted(os.listdir('.')):
    if not f.endswith('.md'): continue
    s=open(f,encoding='utf-8').read()
    rows.append((f,len(link.findall(s)),len(bare.findall(s))))
print(f"{'archivo':34}{'links':>7}{'backticks':>11}")
for f,l,b in rows: print(f"{f:34}{l:>7}{b:>11}")
PY

# --- 2026-09-10T17:48:20 · Check style guide rules for appendix cross-references
grep -rn "apéndice\|Apéndice" prompts/guia-de-estilo-y-convenciones.md | head -20

# --- 2026-09-10T17:48:38 · Validate cross-document section citations
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/9890285f-c3d2-451f-b4c1-bb3582ab905d/scratchpad/secs.py <<'PY'
import re,os,glob
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
# build section inventory per file
def secs(f):
    out=set()
    for l in open(f,encoding='utf-8'):
        m=re.match(r'#{2,4}\s+(?:[^\w\s]*\s*)?(\d+)(?:\.(\d+))?',l)
        if m:
            out.add(m.group(1))
            if m.group(2): out.add(m.group(1)+'.'+m.group(2))
    return out
inv={}
for f in glob.glob('*.md')+glob.glob('prompts/*.md'):
    inv[os.path.basename(f)]=secs(f)

# find "<file> §N" or "§N de <file>"
pat1=re.compile(r'`?([a-z0-9][a-z0-9-]*\.md)`?[^.\n]{0,40}?§\s?(\d+(?:\.\d+)?)')
pat2=re.compile(r'§\s?(\d+(?:\.\d+)?)\s+de\s+`?([a-z0-9][a-z0-9-]*\.md)`?')
bad=[]
tot=0
for f in sorted(glob.glob('*.md')+glob.glob('prompts/*.md')):
    s=open(f,encoding='utf-8').read()
    hits=[(m.group(1),m.group(2)) for m in pat1.finditer(s)]+[(m.group(2),m.group(1)) for m in pat2.finditer(s)]
    for tgt,sec in hits:
        tot+=1
        b=os.path.basename(tgt)
        if b not in inv: bad.append((f,tgt,sec,'archivo inexistente')); continue
        if sec not in inv[b]: bad.append((f,tgt,sec,'sección inexistente; tiene: '+','.join(sorted(inv[b],key=lambda x:[int(y) for y in x.split('.')]))[:70]))
print("citas §archivo revisadas:",tot)
for r in bad: print(" ✗",r[0],"->",r[1],"§"+r[2],"|",r[3])
PY
python3 /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/9890285f-c3d2-451f-b4c1-bb3582ab905d/scratchpad/secs.py

# --- 2026-09-10T17:48:45 · Inspect git conventions doc headings
grep -n "^#\{1,3\} " 00-convencion-de-git-y-tags.md; echo "=== quién cita §8.1 / §10 ==="; grep -rn "convencion-de-git-y-tags.md.\{0,30\}§\|§8.1\|§10" prompts/prompts-de-redaccion.md prompts/propuesta-fases-backend.md | head

# --- 2026-09-10T17:49:05 · Audit forensic pieces against their format checklist
python3 - <<'PY'
import re,os,glob
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
print(f"{'pieza':20}{'lin':>5}{'pasos':>7}{'🧨':>4}{'inc':>5}{'patrón':>8}{'apend':>7}{'fase§6':>8}")
for f in sorted(glob.glob('forense-fase-*.md')):
    s=open(f,encoding='utf-8').read()
    n=len(s.splitlines())
    pasos=len(re.findall(r'^#{2,3}\s*(?:[^\w\s]*\s*)?Paso\s',s,re.M))
    if not pasos: pasos=len(re.findall(r'Paso \d',s))
    des='🧨' in s
    inc=sorted(set(re.findall(r'[Ii]ncidente\s+\**(\d\d)',s)))
    pat='transferible' in s.lower()
    ap=sorted(set(re.findall(r'\bA(\d\d)\b',s)))
    f6=bool(re.search(r'§\s?6|sección 6',s))
    print(f"{f:20}{n:>5}{pasos:>7}{'sí' if des else '·':>4}{','.join(inc) or '·':>5}{'sí' if pat else 'NO':>8}{','.join(ap) or '·':>7}{'sí' if f6 else 'NO':>8}")
PY

# --- 2026-09-10T17:49:15 · Check incident cross-references in forensic pieces
grep -c "cuaderno" forense-fase-*.md; echo "=== menciones reales ==="; grep -n "cuaderno\|[Ii]ncidente" forense-fase-*.md | grep -v "^forense-fase-03\|^forense-fase-11" | head -25

# --- 2026-09-10T17:49:31 · Check incident title wording in pieces 03, 11 and piece 05 header
grep -n "Incidentes del cuaderno" forense-fase-03.md forense-fase-11.md; echo "=== f05 cabecera ==="; sed -n '1,14p' forense-fase-05.md

# --- 2026-09-10T17:49:37 · Extract forensic hooks from phase section 6
for f in 00-setup-hola-mundo 01-estructura-base-ngrx 02-i18n 03-autenticacion 04-mock-api-caos; do echo "######## $f"; awk '/^## 6\.|^## ⚠️ 6|^## .*6\. .*[Ee]rrores/{p=1} p&&/forense-fase/{print NR": "$0} p&&/^## 7\./{exit}' $f.md | head -6; done

# --- 2026-09-10T17:49:46 · Verify phase-piece-master reciprocity
python3 - <<'PY'
import re,os,glob
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
fases={f[:2]:f for f in glob.glob('[0-9][0-9]-*.md') if not f.startswith('00-convencion') and not f.startswith('00-historia')}
print(f"{'fase':30}{'→pieza':>9}{'pieza→fase':>12}{'→master':>9}")
for n in sorted(fases):
    fase=fases[n]; pieza=f'forense-fase-{n}.md'
    s=open(fase,encoding='utf-8').read(); p=open(pieza,encoding='utf-8').read() if os.path.exists(pieza) else ''
    print(f"{fase:30}{('sí' if pieza in s else 'NO'):>9}{('sí' if fase in p else 'NO'):>12}{('sí' if 'forense-master' in p else 'NO'):>9}")
PY

# --- 2026-09-10T17:49:58 · Audit appendix structure and references
python3 - <<'PY'
import re,os,glob
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
print(f"{'apéndice':24}{'lin':>5}{'índice':>8}{'ejerc':>7}{'refs':>6}{'URLs':>6}{'🏷️':>4}{'👁️/✍️':>7}{'links':>6}")
for f in sorted(glob.glob('a[01][0-9]-*.md')):
    s=open(f,encoding='utf-8').read()
    n=len(s.splitlines())
    idx=bool(re.search(r'salto rápido|Índice|índice',s))
    ej=len(re.findall(r'^\s*\d+\.\s',s,re.M))
    ejs=bool(re.search(r'[Ee]jercicios',s))
    refs=bool(re.search(r'Referencias|Bibliograf|Para seguir',s))
    urls=len(re.findall(r'https?://',s))
    tag='🏷️' in s
    eyes=('👁️' in s or '✍️' in s)
    links=len(re.findall(r'\[[^\]]*\]\((?!http)',s))
    print(f"{f:24}{n:>5}{('sí' if idx else 'NO'):>8}{('sí' if ejs else 'NO'):>7}{('sí' if refs else 'NO'):>6}{urls:>6}{('sí' if tag else '·'):>4}{('sí' if eyes else '·'):>7}{links:>6}")
PY

# --- 2026-09-10T17:50:12 · Verify link count in appendix a01
grep -c "](\./\|](a\|](0\|](1\|](forense\|](cuaderno" a01-material.md; grep -o "\[[^]]*\]([^)h][^)]*)" a01-material.md | head -15

# --- 2026-09-10T17:50:31 · Validate all anchor links against headings
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/9890285f-c3d2-451f-b4c1-bb3582ab905d/scratchpad/anchors.py <<'PY'
import re,os,glob,unicodedata,collections
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
def slug(t):
    t=re.sub(r'`','',t)
    t=re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',t)   # links -> text
    t=re.sub(r'[*_]','',t)
    t=t.strip().lower()
    out=''.join(c for c in t if c.isalnum() or c in ' -_' or unicodedata.category(c).startswith('M'))
    return out.replace(' ','-')
def anchors(f):
    c=collections.Counter(); s=set()
    incode=False
    for l in open(f,encoding='utf-8'):
        if l.lstrip().startswith('```') or l.lstrip().startswith('````'): incode=not incode; continue
        if incode: continue
        m=re.match(r'(#{1,6})\s+(.*?)\s*$',l)
        if m:
            a=slug(m.group(2)); n=c[a]; c[a]+=1
            s.add(a if n==0 else f"{a}-{n}")
    return s
inv={}
for f in glob.glob('*.md')+glob.glob('prompts/*.md'): inv[f]=anchors(f)
bad=[];tot=0
for f in sorted(inv):
    s=open(f,encoding='utf-8').read()
    for m in re.finditer(r'\[[^\]]*\]\(([^)]*#[^)]+)\)',s):
        t=m.group(1)
        if t.startswith('http'): continue
        path,anc=t.split('#',1); tot+=1
        tgt=f if path in ('','./') else os.path.normpath(os.path.join(os.path.dirname(f),path))
        if tgt not in inv: bad.append((f,t,'archivo no encontrado')); continue
        if anc not in inv[tgt]: bad.append((f,t,'ancla inexistente'))
print("anclas revisadas:",tot,"| rotas:",len(bad))
for b in bad[:60]: print("  ✗",b[0],"->",b[1],"|",b[2])
PY
python3 /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/9890285f-c3d2-451f-b4c1-bb3582ab905d/scratchpad/anchors.py

# --- 2026-09-10T17:50:43 · Inspect suspect anchor headings
grep -n "Advertencias" a01-material.md | head -4 | cat -A | sed 's/\$$//' | cut -c1-120; echo "---- a07"; grep -n "^## 6\.\|locale_id\|LOCALE_ID" a07-i18n.md | head -5; echo "---- a13"; grep -n "^## 5\.\|node_modules" a13-docker-colima.md | head -5

# --- 2026-09-10T17:50:54 · Check a07 headings and byte-level emoji in headings
grep -n "^#\{2,3\} " a07-i18n.md | head -20; echo "=== bytes de Advertencias ==="; grep -n "Advertencias" a01-material.md | head -3 | hexdump -C | head -4

# --- 2026-09-10T17:51:06 · Compare warning-anchor byte forms across appendices
for f in a0*.md a1*.md; do printf "%-24s " "$f"; grep -o "](#[^)]*advertencias[^)]*)" "$f" | head -1 | hexdump -C | head -1 | cut -c11-60; done

# --- 2026-09-10T17:51:23 · Find all plain hyphen-leading anchors
grep -rno "](#-[a-záéíóúñ0-9-]*)" --include="*.md" . | head -20; echo "=== total plain #- ==="; grep -rc "](#-" --include="*.md" . | grep -v ":0"

# --- 2026-09-10T17:51:41 · Validate appendix section citations
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/9890285f-c3d2-451f-b4c1-bb3582ab905d/scratchpad/asec.py <<'PY'
import re,os,glob
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
ap={}
for f in glob.glob('a[01][0-9]-*.md'):
    n=f[1:3]; s=set()
    for l in open(f,encoding='utf-8'):
        m=re.match(r'#{2,3}\s+(\d+)(?:\.(\d+))?\.?\s',l)
        if m:
            s.add(m.group(1))
            if m.group(2): s.add(m.group(1)+'.'+m.group(2))
    ap[n]=(f,s)
pat=re.compile(r'\bA(\d\d)\b[^.\n]{0,25}?§\s?(\d+(?:\.\d+)?)')
tot=0;bad=[]
for f in sorted(glob.glob('*.md')+glob.glob('prompts/*.md')):
    for m in pat.finditer(open(f,encoding='utf-8').read()):
        n,sec=m.group(1),m.group(2); tot+=1
        if n not in ap: bad.append((f,n,sec,'apéndice inexistente')); continue
        if sec not in ap[n][1]: bad.append((f,n,sec,'no existe; tiene §'+','.join(sorted(ap[n][1],key=lambda x:[int(y) for y in x.split('.')]))))
print("citas 'ANN §N' revisadas:",tot,"| rotas:",len(bad))
for b in bad: print("  ✗",b[0],"-> A"+b[1],"§"+b[2],"|",b[3])
PY
python3 /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/9890285f-c3d2-451f-b4c1-bb3582ab905d/scratchpad/asec.py

# --- 2026-09-10T17:51:49 · Inspect a03 sections and the A03 §9 citations
grep -n "^#\{2,3\} " a03-node-npm.md; echo "=== qué dicen las citas ==="; grep -rn "A03 §9" --include="*.md" . | sed 's/^\(.\{0,150\}\).*/\1/'

# --- 2026-09-10T17:51:57 · Locate the node_modules portability rule in a03
grep -n "node_modules" a03-node-npm.md | sed 's/^\(.\{0,140\}\).*/\1/' | head -20

# --- 2026-09-10T17:52:14 · Validate phase section citations
cat > /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/9890285f-c3d2-451f-b4c1-bb3582ab905d/scratchpad/fsec.py <<'PY'
import re,os,glob
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
fa={}
for f in glob.glob('[0-9][0-9]-*.md'):
    if f.startswith(('00-convencion','00-historia')): continue
    n=str(int(f[:2])); s=set()
    for l in open(f,encoding='utf-8'):
        m=re.match(r'#{2,4}\s+(?:[^\w\s]*\s*)?(\d+)(?:\.(\d+))?\.?\s',l)
        if m:
            s.add(m.group(1))
            if m.group(2): s.add(m.group(1)+'.'+m.group(2))
    fa[n]=(f,s)
pat=re.compile(r'[Ff]ase\s+(\d{1,2})\s*§\s?(\d+(?:\.\d+)?)')
tot=0;bad=[]
for f in sorted(glob.glob('*.md')+glob.glob('prompts/*.md')):
    for m in pat.finditer(open(f,encoding='utf-8').read()):
        n,sec=m.group(1),m.group(2); tot+=1
        n=str(int(n))
        if n not in fa: bad.append((f,n,sec,'fase inexistente')); continue
        if sec not in fa[n][1]: bad.append((f,n,sec,fa[n][0]+' tiene §'+','.join(sorted(fa[n][1],key=lambda x:[int(y) for y in x.split('.')]))[:60]))
print("citas 'Fase N §M' revisadas:",tot,"| rotas:",len(bad))
for b in bad: print("  ✗",b[0],"-> Fase",b[1],"§"+b[2],"|",b[3])
PY
python3 /private/tmp/claude-501/-Users-oskar-Developer-Learning-courses-ia-generated/9890285f-c3d2-451f-b4c1-bb3582ab905d/scratchpad/fsec.py

# --- 2026-09-10T17:52:23 · Extract package version claims across the course
grep -rohE '"?(@?[a-z@/-]{3,28})"?[:@ ]+"?\^?~?[0-9]+\.[0-9]+\.[0-9x]+' --include="*.md" . | sed 's/"//g;s/: */@/;s/  */ /g' | sort | uniq -c | sort -rn | head -45

# --- 2026-09-10T17:52:31 · Read a03 explanation of the two Node lines
sed -n '43,79p' a03-node-npm.md

# --- 2026-09-10T17:52:40 · Check placeholders and exercise counts in appendices
echo "=== placeholders/TODO ==="; grep -rn "{{[^}]*}}\|TODO\|TBD\|XXX\|FIXME\|Lorem" --include="*.md" . | grep -v "^./cuaderno-incidentes.md\|^./prompts/" | grep -v "{{ *'" | head -15
echo; echo "=== ejercicios: título vs conteo real ==="
for f in a0*.md a1*.md; do
  t=$(grep -o "Ejercicios (\([0-9]*\))" "$f" | head -1 | grep -o "[0-9]*")
  r=$(awk '/^## .*Ejercicios/{p=1;next} p&&/^## /{exit} p&&/^[0-9]+\. /{c++} END{print c+0}' "$f")
  [ "$t" != "$r" ] && echo "  ✗ $f: título dice $t, hay $r" || echo "  ok $f ($t)"
done

# --- 2026-09-10T17:52:51 · Check standard blocks across appendices
echo "=== apéndices: bloques estándar ==="; printf "%-24s %s\n" archivo "quéFuera cuándoUsar advert refs ejerc pendientes tag"; for f in a0*.md a1*.md; do printf "%-24s" "$f"; for pat in "Qué queda fuera" "Cuándo usar qué" "⚠️ Advertencias" "📚 Referencias" "🧪 Ejercicios" "📌 Pendientes" "🏷️"; do grep -q "$pat" "$f" && printf "%10s" "sí" || printf "%10s" "NO"; done; echo; done

# --- 2026-09-10T17:52:57 · List a12 section headings
grep -n "^#\{2,3\} " a12-arm64-m1.md

# --- 2026-09-10T17:53:05 · Check standard blocks across forensic pieces
printf "%-22s %s\n" archivo "ticket qDescarta másBarato incidentes patrón deshacer"; for f in forense-fase-*.md; do printf "%-22s" "$f"; for pat in "🎫 El ticket" "Qué descarta" "más barato\|más barata\|de lo barato\|coste" "Incidentes del cuaderno" "patrón transferible\|Patrón transferible" "Deshacer"; do grep -qi "$pat" "$f" && printf "%12s" "sí" || printf "%12s" "NO"; done; echo; done

# --- 2026-09-10T17:53:13 · Inspect structure of pieces 02 and 08
echo "### f02 y f08: encabezados"; grep -n "^#\{2,3\} " forense-fase-02.md | head -14; echo "---"; grep -n "^#\{2,3\} " forense-fase-08.md | head -14

# --- 2026-09-10T17:53:20 · Check cost-ordering statement in flagged pieces
for f in forense-fase-00 forense-fase-03 forense-fase-06 forense-fase-08 forense-fase-09 forense-fase-11 forense-fase-12; do echo "### $f"; grep -in "orden\|primero\|antes de\|cuesta\|caro\|barat" $f.md | sed -n '1,3p' | sed 's/^\(.\{0,135\}\).*/\1/'; done

# --- 2026-09-10T17:53:28 · Check route cost statements in two-route pieces
sed -n '24,27p;88,92p' forense-fase-02.md; echo "=====f08"; sed -n '24,28p;104,108p' forense-fase-08.md

# --- 2026-09-10T17:53:35 · Read route 1 of piece 02 in full
sed -n '24,90p' forense-fase-02.md

# --- 2026-09-10T17:53:48 · Compare announced vs actual step counts
python3 - <<'PY'
import re,glob,os
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
num={'un':1,'dos':2,'tres':3,'cuatro':4,'cinco':5,'seis':6,'siete':7,'ocho':8,'nueve':9}
for f in sorted(glob.glob('forense-fase-*.md')):
    lines=open(f,encoding='utf-8').read().splitlines()
    # segment by Ruta headings if any
    segs=[];cur=('(única)',[])
    for l in lines:
        if re.match(r'^## .*Ruta \d',l): segs.append(cur); cur=(l.strip('# '),[])
        cur[1].append(l)
    segs.append(cur)
    for name,body in segs:
        txt='\n'.join(body)
        pasos=len(re.findall(r'^#{3}\s*Paso\s+\d',txt,re.M))
        if not pasos: continue
        m=re.search(r'\b('+'|'.join(num)+r')\s+pasos',txt,re.I)
        dec=num[m.group(1).lower()] if m else None
        flag='  ✗ DISCREPANCIA' if dec and dec!=pasos else ''
        print(f"{f:22}{name[:44]:46}anuncia={dec if dec else '—':<4}real={pasos}{flag}")
PY

# --- 2026-09-10T17:53:55 · Inspect step headings in the three discrepant pieces
for f in forense-fase-01 forense-fase-03 forense-fase-13; do echo "### $f"; grep -n "^### Paso\|pasos" $f.md | sed 's/^\(.\{0,120\}\).*/\1/'; done

# --- 2026-09-10T17:54:10 · Check for images and optional-phase marking
echo "=== imágenes/capturas ==="; grep -rn "!\[" --include="*.md" . | head; echo "(ninguna = ✓)"; echo; echo "=== 🔥 opcional en Fase 14 / A09 ==="; grep -rn "Fase 14" --include="forense-*.md" --include="a*.md" . | grep -vc "🔥"; grep -rn "Fase 14" --include="forense-*.md" --include="a*.md" . | grep -v "🔥" | sed 's/^\(.\{0,110\}\).*/\1/' | head

# --- 2026-09-10T17:54:18 · Read migration appendix headers
sed -n '1,14p' a10-migracion-8-9.md; echo "=========="; sed -n '1,14p' a11-migracion-9-16.md

# --- 2026-09-10T17:54:30 · Verify appendix usage declarations against actual phase references
python3 - <<'PY'
import re,glob,os
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
fases={}
for f in glob.glob('[0-9][0-9]-*.md'):
    if f.startswith(('00-convencion','00-historia')): continue
    fases[int(f[:2])]=open(f,encoding='utf-8').read()
for f in sorted(glob.glob('a[01][0-9]-*.md')):
    s=open(f,encoding='utf-8').read()
    n=f[1:3]
    m=re.search(r'Usado por:\s*(.+)',s)
    if not m: print(f"{f}: sin 'Usado por'"); continue
    decl=set(int(x) for x in re.findall(r'\b(\d{1,2})\b',m.group(1).split('·')[0]))
    real=set(k for k,v in fases.items() if re.search(r'\bA'+n+r'\b',v))
    falta=sorted(decl-real); extra=sorted(real-decl)
    st=[]
    if falta: st.append("declara y NO la cita: "+str(falta))
    if extra: st.append("la cita y no está declarada: "+str(extra))
    print(f"A{n}  decl={sorted(decl)}  real={sorted(real)}  {'  ⚠ '+' | '.join(st) if st else '✓'}")
PY

# --- 2026-09-10T17:54:40 · Inspect undeclared appendix citations
echo "--- A01 en Fase 0 y 12"; grep -n "A01" 00-setup-hola-mundo.md 12-testing-coverage.md | sed 's/^\(.\{0,125\}\).*/\1/'; echo "--- A03 en Fase 1 y 2"; grep -n "A03" 01-estructura-base-ngrx.md 02-i18n.md | sed 's/^\(.\{0,125\}\).*/\1/'; echo "--- A04 en Fase 0 y 9"; grep -n "A04" 00-setup-hola-mundo.md 09-entrega-pdf.md | sed 's/^\(.\{0,125\}\).*/\1/'

# --- 2026-09-10T17:54:50 · Check closing narrative of pieces 13 and 14
sed -n '200,215p' forense-fase-13.md; echo "===== f14 apertura"; sed -n '1,12p' forense-fase-14.md; echo "===== f14 cierre"; tail -8 forense-fase-14.md

# --- 2026-09-10T17:55:01 · Quantify linked vs unlinked cross-references
python3 - <<'PY'
import re,glob,os
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
print(f"{'archivo':24}{'menciones ANN':>15}{'de ellas link':>15}{'menciones Fase N':>18}{'link':>7}")
for f in sorted(glob.glob('a[01][0-9]-*.md'))+sorted(glob.glob('forense-fase-*.md')):
    s=open(f,encoding='utf-8').read()
    men=len(re.findall(r'\bA\d\d\b',s))
    lin=len(re.findall(r'\[[^\]]*A\d\d[^\]]*\]\(',s))+len(re.findall(r'\]\(\.?/?a\d\d-',s))
    fm=len(re.findall(r'\bFase\s+\d{1,2}\b',s))
    fl=len(re.findall(r'\]\(\.?/?\d\d-',s))
    print(f"{f:24}{men:>15}{lin:>15}{fm:>18}{fl:>7}")
PY

# --- 2026-09-10T17:55:21 · Check README coverage and orphan documents
python3 - <<'PY'
import re,glob,os
os.chdir('/Users/oskar/Developer/Learning/courses-ia-generated/angular-8-legacy-for-backend-devs')
r=open('README.md',encoding='utf-8').read()
falt=[f for f in sorted(glob.glob('*.md')) if f!='README.md' and f not in r]
print("archivos NO nombrados en README.md:")
for f in falt: print("   -",f)
print()
print("¿README enlaza (markdown) algo?:",len(re.findall(r'\]\((?!http)',r)))
print()
# quién enlaza analisis-forense-tutoriales
for f in glob.glob('*.md')+glob.glob('prompts/*.md'):
    if 'analisis-forense-tutoriales' in open(f,encoding='utf-8').read() and 'analisis' not in f:
        print("cita analisis-forense-tutoriales:",f)
PY

# --- 2026-09-10T17:55:26 · Inspect README appendix and forensic listings
grep -n "A0\|A1\|forense\|apéndice\|Apéndice" README.md | sed 's/^\(.\{0,130\}\).*/\1/' | head -30

# --- 2026-09-10T17:55:33 · Read README status and prompts listing
sed -n '138,150p;159,170p' README.md

# --- 2026-09-10T17:55:42 · Get exact line numbers for actionable defects
grep -n "](00-convencion-de-git-y-tags.md)" prompts/*.md; echo "---"; grep -n "00-alcance-del-proyecto\|forense-master.md.\{0,20\}§6" analisis-forense-tutoriales.md | sed 's/^\(.\{0,100\}\).*/\1/'; echo "--- f13 / f02 líneas"; grep -n "Seis pasos" forense-fase-13.md; grep -n "Cuatro pasos y cuatro causas\|El más caro de los cuatro" forense-fase-02.md

# --- 2026-09-10T17:55:53 · Verify cross-course reference target exists
ls ../react-16-legacy-for-backend-devs/ | head -20; echo "---"; ls ../react-16-legacy-for-backend-devs/00-alcance-del-proyecto.md 2>&1; sed -n '125,132p' analisis-forense-tutoriales.md | sed 's/^\(.\{0,120\}\).*/\1/'

# --- 2026-09-10T17:56:17 · Cross-check node-sass advice across appendices
echo "### node-sass / sass en a02, a12, a13"; grep -n "node-sass\|dart-sass\|\bsass\b" a02-bootstrap-sass.md a12-arm64-m1.md a13-docker-colima.md | grep -i "versión\|version\|4\.14\|1\.32\|module version\|reemplaz\|migra\|cambiar a" | sed 's/^\(.\{0,150\}\).*/\1/' | head -14

