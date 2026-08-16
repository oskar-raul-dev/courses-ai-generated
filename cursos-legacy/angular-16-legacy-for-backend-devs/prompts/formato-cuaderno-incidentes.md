# 📓 Formato del cuaderno de incidentes
## Tutorial Angular 16 — Inspecciones y certificaciones

Este documento **no es** el cuaderno: es su especificación. Define cómo se
construye `cuaderno-incidentes.md`, que es el único archivo de incidentes del
curso y el entregable del chat correspondiente.

> 🧭 **Un solo archivo, sin excepción.** El documento base preveía un
> `incidente-NN-*.md` por incidente. No se hace: el estudiante trabaja sin
> instructor y necesita índice, enunciado, pistas, solución y su propia bitácora a
> un scroll de distancia. **Los IDs son globales y nunca se reasignan**, aunque un
> incidente se retire.

**Presupuesto:** 20 incidentes, **14h** repartidas en el mes, ≈3.5h por semana.

---

## 1. Qué hace distinto a este cuaderno

Tres cosas, y las tres vienen de que CertCore es un sistema *migrado* y no un
sistema *viejo*:

1. **Al menos tres incidentes son de versionado de plantillas.** Es el corazón
   del sistema y la fuente real de tickets, y **ninguno de los tres se resuelve
   leyendo el mismo archivo que el anterior**: uno vive en la resolución por
   fecha, otro en las ventanas de vigencia, y el tercero en el formulario que se
   construye con la versión equivocada.

   > 📝 **Por qué tres y no cuatro, que es lo que decía este documento.** Al
   > cerrar las catorce fases, las reservas dieron 08 y 09 (Fase 7) y 10
   > (Fase 8): tres incidentes con tres causas raíz distintas. El cuarto sólo se
   > conseguía forzando la causa raíz de un incidente cuya fase ya la había
   > fijado en otra cosa —el PDF de la Fase 10 se arma desde la vista, no desde
   > la versión equivocada—, y un incidente con la categoría torcida enseña peor
   > que uno menos. La cifra se bajó a tres el día que se escribió el cuaderno.
2. **Al menos dos son de convivencia de estilos** 🧬: un standalone que no ve un
   provider de NgModule, un interceptor funcional y uno de clase corriendo los dos.
   Son incidentes que en el Track A no pueden existir.
3. **Al menos dos son de tipos bajo `strict`**: el `null` que se coló como
   `undefined`, el campo opcional que en realidad significaba otra cosa. La
   categoría existe porque el curso tiene `strict: true` y esos bugs se ven.

---

## 2. Estructura del archivo

`cuaderno-incidentes.md` se organiza en este orden, y sólo en este:

1. **Encabezado** — título, presupuesto horario, y la frase que fija el trato:
   la solución viene incluida y abrirla antes de tiempo sólo te perjudica a ti.
2. **🧭 Cómo se trabaja un incidente** — el método, las tres formas de llegar al
   sistema roto (§4), la convención de commits (§5) y la tabla de estados (§6).
3. **📋 Índice** — la tabla de los 20 IDs (§3).
4. **🧪 Incidentes** — una entrada por incidente, con el bloque completo de §7.
   Se repite entero cada vez: nada de "ver incidente 03". Se leen salteados y con
   semanas de diferencia.
5. **🪞 Retrospectiva del mes** — §8.
6. **📌 Pendientes que salieron de los incidentes** — §9.

---

## 3. El índice y la reserva de IDs

El índice se actualiza en el mismo commit que abre o cierra un incidente. La fila
existe desde el momento en que una fase reserva el ID, en su sección
📌 *Reservas para el cuaderno de incidentes*, y **los veinte enunciados ya están
escritos abajo**, cada uno con su preparación, sus tres pistas plegadas y su
solución de referencia. Por eso la columna de estado es del estudiante: un ⬜
quiere decir que todavía no lo tocó, y el ID **nunca** se reasigna, ni siquiera
si un incidente se retira.

Formato de la tabla:

```markdown
| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| 01 | 0 | Instalé todo y `ng serve` no arranca | Despliegue | 🟢 | ⬜ |
```

El título va **en palabras del usuario**, no en lenguaje técnico. *"La inspección
de marzo se ve distinta desde ayer"* es un buen título; *"resolución incorrecta de
`templateVersion`"* es la respuesta, y va en la solución.

### Distribución objetivo de los 20

Se reparte por semana y por dificultad; las fases exactas las fijan las reservas
de cada fase, pero el reparto no se negocia:

- **Semana 1** — fases 0-4 · **4-5 incidentes 🟢**: setup, endpoint mal escrito,
  CORS, el primer `Object is possibly 'null'`, un servicio de estado que devuelve
  el valor inicial para siempre.
- **Semana 2** — fases 5-8 · **5-6 incidentes 🟡**: standalone que no importa lo
  que usa, plantilla renderizada con la versión equivocada, `FormGroup` dinámico
  con controles huérfanos, autosave que se dispara en bucle.
- **Semana 3** — fases 9-11 · **5-6 incidentes 🟠**: hallazgo `critical` que no
  bloquea la emisión, certificado emitido con hallazgos pendientes, PDF con datos
  de hace dos minutos, dashboard que se arrastra al final del mes.
- **Semana 4** — fases 12-13 · **4-5 incidentes 🔴**: intermitentes, fuga de
  suscripción a `valueChanges`, el certificado que venció ayer para uno y hoy para
  otro, la imagen desplegada a PROD hablándole a UAT.

### Categorías

Máquina de estados · versionado normativo · tiempo · trazabilidad · formularios
dinámicos · estado (servicios) · convivencia de estilos 🧬 · tipos (strict) ·
integración · performance · UI · despliegue · testing.

### Dificultad

🟢 fácil · 🟡 intermedio · 🟠 difícil · 🔴 muy difícil. Va también un **tiempo
sugerido** por incidente (20-40 min los 🟢, hasta 2h los 🔴), porque sin él el
estudiante no sabe cuándo está atascado de verdad.

---

## 🕵️ El puente con el track forense

> 📝 **Esta sección no lleva número a propósito.** Se añadió después de que las
> quince fases estuvieran publicadas, y catorce de ellas citan este documento por
> número —`formato-cuaderno-incidentes.md` §4 para las formas de preparación, §7
> para la plantilla—. Numerarla habría corrido todo lo demás y roto esas catorce
> referencias por una mejora de encuadre. **La numeración de un documento rector
> es una interfaz publicada**; una sección sin número cuesta menos que un
> renombrado en cascada.

El cuaderno **da el ticket; el track forense da el método**, y los dos se enlazan
en las dos direcciones. Es la diferencia entre un banco de bugs y un curso de
diagnóstico.

- El encabezado del cuaderno manda al **índice de síntomas transversal** de
  [`forense-master.md`](../forense-master.md) §3 —el que cruza *"esto es lo que
  veo"* con *"empieza acá"*— para quien no sepa ni de qué fase es su problema, y
  al método de las cuatro preguntas de §1.
- Cada incidente enlaza en su cabecera la pieza `forense-fase-NN.md` que recorre
  su misma ruta, en el campo **Ruta forense** de la plantilla de §7. Cuando son
  dos piezas —el incidente 07, que es de convivencia y de pantalla en blanco a la
  vez— van las dos; cuando no hay ninguna, va un `—` y no se fuerza el enlace.
- El enlace recíproco ya existe: `formato-piezas-forenses.md` §8 obliga a cada
  pieza a cerrar con *«Incidentes del cuaderno que usan esta ruta»*, **por el ID
  que este índice les reserva**. Las dos listas tienen que decir lo mismo: si una
  pieza reclama un incidente, ese incidente la enlaza de vuelta.
- La 🔧 Preparación de un incidente **es** la respuesta a la pregunta 1 del método
  forense —*¿se reproduce con un flag, con un dato, o hace falta otro código?*—,
  ya escrita. Por eso la §4 tiene exactamente tres formas y no cuatro.

Lo que **no** se hace es reexplicar el método dentro de un incidente. Si un
párrafo del cuaderno se puede copiar de `forense-master.md`, sobra: se enlaza.

---

## 4. Cómo llega el sistema roto a la máquina del estudiante

Cada incidente lo dice en su bloque «🔧 Preparación», y hay exactamente tres
formas. El orden no es casual: **se usa siempre la más barata que sirva**, porque
una preparación complicada es una excusa para saltarse el incidente.

**1. Un flag del inyector de caos** (Fase 3), cuando el fallo es de red o de
respuesta. Es la preferida: no toca tu código, no toca tus datos, y se apaga sola
al reiniciar el mock. `CHAOS=malformed npm run mock` y ya estás dentro del
incidente.

**2. Un `db.json` alterno**, cuando el bug está en el dato y no en el código —dos
versiones de plantilla vigentes a la vez, un hallazgo al que le falta el campo que
decide—. Se llaman `db.incidente-NN.json`, viven **en `mock/`, junto al
`db.json`**, y se activan copiando: `cp mock/db.incidente-09.json mock/db.json`.
Guarda el tuyo antes, o corre `npm run seed` después para volver — el `seed.js` de
la Fase 3 regenera todo de forma estable entre corridas, así que volver no cuesta
nada.

> 🧰 **El contenido de cada preparación está en
> [`preparaciones-de-incidentes.md`](preparaciones-de-incidentes.md)**: qué línea
> rompe cada una de las dieciséis ramas, qué registros cambia cada uno de los dos
> `db.incidente-NN.json`, y cómo comprobar que la preparación reproduce el
> síntoma. Es material de autoría y **no se enlaza desde el cuaderno**: es la
> respuesta.

**3. Una rama de git**, y sólo cuando haya que romper código. Se llaman
`incidente/NN`, salen del commit donde terminaste la fase correspondiente, y traen
el cambio mínimo que produce el síntoma: una línea movida, un operador cambiado,
un `provider` en el sitio equivocado. `git checkout incidente/03`. Ese commit de
partida es justamente el tag que el estudiante puso al cerrar la fase, así que la
rama se crea sin buscar nada: `git switch -c incidente/03 fase-01`
(`00-convencion-de-git-y-tags.md`).

> 🧭 **La regla, y sirve más allá de este cuaderno:** cuando alguien te pida
> reproducir un bug, la primera pregunta es *"¿esto se reproduce con un flag, con
> un dato, o hace falta otro código?"*. Las tres respuestas llevan a
> investigaciones distintas, y averiguar cuál es te ahorra la mitad del camino
> antes de leer una línea.

---

## 5. Convención de commits

El asunto del commit sigue este formato, para que `git log --oneline` se lea como
la línea de tiempo de la investigación:

```
incidente(07): abre — la inspección de marzo se ve distinta desde ayer
incidente(07): repro — falla solo con inspecciones anteriores a la v2
incidente(07): hipótesis descartada — no es el editor, la v1 sigue intacta en db
incidente(07): causa — el resolver usa la versión vigente y no la ejecutada
incidente(07): fix — leer templateVersion de la inspección, no del template
incidente(07): cierre — test de regresión y post-mortem
```

Los verbos son fijos: `abre`, `repro`, `hipótesis`, `hipótesis descartada`,
`causa`, `fix`, `cierre`.

Commitea también los callejones sin salida. Un `git log` con seis commits de
investigación y uno de fix es un registro honesto; uno que muestra sólo el fix no
le sirve a nadie, y menos a ti dentro de seis meses.

Y como el fix de casi todos estos incidentes es de una o dos líneas, conviene
marcarlo además con el par de tags de
[`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md):
`inc/07/version-ejecutada-roto` con el síntoma reproducido y la regresión en
rojo, `inc/07/version-ejecutada-fix` con la causa raíz y el fix en verde. El
`git diff` entre los dos **es** el punto 5 del post-mortem, aislado del ruido de
la fase, y `git tag -n99 -l 'inc/*'` devuelve el cuaderno entero sin abrir un
archivo. El ID es el que el índice ya tiene reservado, nunca uno inventado.

> 💡 Para releer la historia de un incidente:
> `git log --oneline --grep "incidente(07)" -- cuaderno-incidentes.md`

Regla del archivo: se **agrega**, no se corrige. Una hipótesis que resultó falsa
no se borra, se marca como descartada con la evidencia que la tumbó.

---

## 6. Estados

| Estado | Significado |
|---|---|
| ⬜ Sin empezar | Todavía no lo tocaste |
| 🔴 Abierto | Leído, sin reproducir |
| 🟡 En análisis | Reproducido, causa raíz sin confirmar |
| 🟢 Cerrado | Fix aplicado y test de regresión pasando |
| ⚪ Descartado | No se reproduce, y está documentado por qué |

---

## 7. Plantilla de un incidente

Se copia entera para cada entrada. Los `<details>` son la única excepción
aceptada a la regla de "Markdown sin HTML" de la guía de estilo §3.

````markdown
## Incidente {{NN}} — {{Título en palabras del usuario}}

> **Fase:** {{N}} · **Categoría:** {{categoría}} · **Dificultad:** {{🟢🟡🟠🔴}}
> **Estado:** ⬜ Sin empezar · **Abierto:** {{—}} · **Cerrado:** {{—}}
> **Tiempo sugerido:** {{20-40 min}} · **Ruta forense:** {{el enlace a `forense-fase-NN.md`, los dos que correspondan, o —}}

### 🎫 El ticket

{{El reporte tal como llegó, con su vaguedad incluida. Dos o tres frases en
lenguaje de negocio, escritas por alguien que no sabe qué es un resolver. "A veces
se ve distinta" es un dato legítimo, no un defecto del reporte.}}

**Reportado por:** {{rol — inspector de campo, coordinador de certificaciones,
cliente}}
**Ambiente:** {{UAT / PROD / ambos}}

### 🎯 Qué se te pide

{{Una o dos líneas con el entregable concreto: reproducir y localizar la capa, o
reproducir y aplicar el hotfix mínimo, o explicar por qué no se reproduce. No
todos los incidentes terminan en fix.}}

### 🔧 Preparación

{{Cuál de las tres formas de §4, y por qué esa.}}

```bash
{{CHAOS=malformed npm run mock | cp db.incidente-NN.json db.json | git checkout incidente/NN}}
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

{{Señala la capa y la herramienta, sin decir qué vas a encontrar: "esto se ve en
el Network tab antes que en la consola" o "el servicio de estado ya tiene la
respuesta correcta; compara lo que emite con lo que pinta la plantilla".}}

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
{{Pasos numerados y exactos, con datos concretos: qué cliente, qué activo, qué
plantilla y en qué versión, qué hora y en qué zona horaria. Si no lo lograste,
escribe qué intentaste — no reproducir también es un resultado.}}

**Evidencia observable**
{{Lo que viste, no lo que supones: consola, Network, Angular DevTools, logs del
mock. Texto, no capturas: el texto se versiona.}}

```
{{payload, error o traza}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea, o la decisión de diseño culpable.}}

**Tu fix**
{{El parche mínimo que aplicarías un viernes a las seis, escrito en el estilo del
archivo que tocaste. Aparte, en una línea, la refactorización correcta que harías
con calma.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

{{Hasta el archivo y la línea. Si la causa es una decisión de diseño, se nombra la
decisión y se explica en qué momento de la vida de CertCore tenía sentido.}}

**Parche mínimo**

```typescript
{{el hotfix, con comentarios en español y en el estilo —nuevo o heredado— del
archivo que se toca}}
```

**La refactorización correcta**

{{Qué haría alguien con tiempo y pruebas. Si la deuda que originó el bug está
marcada 💸 en alguna fase, decir en cuál se paga.}}

**Prueba de regresión**

{{El test que falla antes del fix y pasa después. Código, no descripción.}}

```typescript
{{spec}}
```

**Prevención**

{{Test, guard de tipos, validación en el servicio de estado, feature flag o
alerta.}}

**Por qué llegó a producción**

{{Post-mortem sereno: qué del sistema o del proceso lo permitió. Se analiza el
sistema, nunca a la persona. Acá el humor baja un punto.}}

**Si tu causa fue distinta a esta**

{{Los diagnósticos alternativos plausibles y por qué el síntoma también encaja con
ellos. Que tu fix funcione y tu causa no coincida es información: casi siempre
significa que tapaste el síntoma en una capa más arriba.}}

</details>
````

---

## 8. Retrospectiva del mes

Cierra el archivo. Se llena al terminar, de una sola vez, releyendo el propio
`git log`:

- **Cuántos abriste, cuántos cerraste, cuántos quedaron ⚪.**
- **Cuántas veces tu causa raíz coincidió con la de referencia**, y en cuáles no.
  El patrón importa más que el número.
- **En qué capa te costó más**: plantilla, componente, servicio de estado, guard,
  interceptor, mock, build.
- **Cuántas veces el estilo te confundió** 🧬: cuántos incidentes perdiste tiempo
  buscando en un NgModule algo que vivía en un standalone, o al revés. Es la
  métrica propia de este track.
- **Qué pista abriste antes de tiempo y por qué**. Sin culpa; es un dato sobre
  dónde te falta confianza, no sobre tu disciplina.
- **Tu checklist de hotfix**, la de una página, reescrita con lo que aprendiste.
  Es lo único de este archivo que te llevas al trabajo real.

---

## 9. Pendientes que salieron de los incidentes

Lo que apareció investigando y no cabía en el fix, con el ID que lo originó:

```markdown
- **[06]** {{pendiente}} → sugerido para {{apéndice / fase / ejercicio 🔥}}.
```

---

## 10. Checklist antes de dar por cerrado el cuaderno

> ✅ **Escrito.** Los veinte enunciados están en `cuaderno-incidentes.md`, con el
> reparto **5 / 6 / 5 / 4** por semana y la escala **5 🟢 · 3 🟡 · 7 🟠 · 5 🔴**,
> verificados contra el índice fila por fila. Las tres formas de preparación de §4
> se usaron **dieciséis veces la rama, dos el `db.incidente-NN.json` y dos el flag
> de caos** —sin inventar ni un flag que la Fase 3 no construya: los seis son
> `latency`, `error`, `malformed`, `cors`, `expired` y `timeout`—.
>
> 🪦 **Y el checklist decía "al menos 4 de versionado de plantillas".** Son
> **tres** (08, 09, 10), y el número que manda es el del entregable. Las reservas
> de las Fases 7 y 8 dieron tres, y el cuarto habría que inventarlo: los tres que
> hay ya cubren las tres caras del invariante —leer la versión vigente en vez de
> la ejecutada, dos versiones vigentes a la vez, y el formulario que no se
> reconstruye—, así que un cuarto sería una variante de alguno. La línea de abajo
> se corrigió a tres y el README ya decía tres.

- [ ] 20 incidentes, con el reparto por semana y dificultad de §3.
- [ ] Al menos 3 de versionado de plantillas, 2 de convivencia de estilos 🧬 y
      2 de tipos bajo `strict`.
- [ ] Cada incidente enlaza su **Ruta forense**, y la pieza enlazada lo reclama de
      vuelta en su *«Incidentes del cuaderno que usan esta ruta»*.
- [ ] Todos los IDs del índice tienen entrada abajo, y ninguno se reasignó.
- [ ] Cada incidente dice cuál de las tres formas de preparación usa, y usa la
      más barata que sirve.
- [ ] Cada solución trae parche mínimo, refactorización correcta, test de
      regresión **en código**, prevención y post-mortem sin culpabilización.
- [ ] Los títulos están en palabras del usuario, no en lenguaje técnico.
- [ ] Todo el código en inglés, comentarios en español, `strict` respetado, y el
      parche escrito en el estilo del archivo que toca.
- [ ] La retrospectiva y los pendientes están al final, en ese orden.

---

## 🔥 El cuaderno del track de backend

Este formato aplica igual a **`cuaderno-incidentes-be.md`**, el cuaderno del track
opcional de backend: mismo esqueleto de incidente, mismas pistas plegadas, mismo
post-mortem sin culpabilización.

Cambian tres cosas, y las tres están declaradas en
`propuesta-fases-backend.md` §9:

- **Los IDs son `be-01` … `be-12`** y viven en un rango **independiente** del
  cuaderno base. Los dos no se cruzan ni se renumeran el uno al otro.
- **La preparación del sistema roto** no usa `mock/db.json`: el dato vive en
  PostgreSQL. La §4 se reescribe entera para el track y queda en **cuatro**
  formas, otra vez de la más barata a la más cara: (1) un flag del inyector de
  caos, el mismo de la Fase 3 reimplementado en PHP; (2) una tabla sembrada a
  propósito, con guiones `sql/seed-incidente-be-NN.sql`; (3) **una línea del
  `.env`**, que es la forma propia del track y la que casi nadie considera; y
  (4) una rama de git. Las ramas llevan namespace propio, **`incidente-be/NN`**, y
  salen del tag `be-fase-*` con el slug completo, según
  [`00-convencion-de-git-y-tags.md`](../00-convencion-de-git-y-tags.md) §🔥.
  El contenido de esas preparaciones vive en
  [`preparaciones-de-incidentes-be.md`](preparaciones-de-incidentes-be.md)
  —**escrito el 11/09/2026**—, aparte del documento equivalente del track base por
  la misma razón por la que los cuadernos están separados.

> ✅ **Escrito el 11/09/2026.** `cuaderno-incidentes-be.md` tiene sus doce
> incidentes, con la escala **2 🟡 · 7 🟠 · 3 🔴 y ningún 🟢** —declarada con su
> razón: después de diez fases del track base con sus incidentes no queda ninguno
> de principiante que dar—. De las cuatro formas de preparación se usaron **cuatro
> ramas, cinco guiones de `sql/`, una vez el `.env` y tres veces ninguna**; el flag
> del caos **no se usó**, y también está declarado por qué: el inyector ya se
> ejercita entero en be01 y en los ejercicios de la Fase 3 repetidos contra el
> backend nuevo, así que un incidente de caos sería una repetición.
>
> **Y dos divergencias más respecto de este formato, declaradas en el propio
> cuaderno:** (1) no hay campo *«Ruta forense»* que apunte a un archivo aparte,
> porque el track BE no tiene `forense-be-NN.md` —cada incidente enlaza la **§6 de
> su fase**, que cumple el mismo papel—; y (2) el reparto es **por bloque de
> fases, no por semana**, porque el track es opcional y a ritmo propio, así que
> repartirlo en semanas inventaría un calendario que nadie tiene.
>
> 🪦 **`prompts/plantilla-de-incidente-be.md` no se escribió**, y la propuesta lo
> dejaba abierto *"si el formato diverge"*. No diverge lo suficiente: la plantilla
> de §7 se usó tal cual, y lo propio del track —las cuatro formas de preparación y
> la excepción de `be-06`— ya vive en esta sección.
- ⚠️ **Uno de los incidentes no tiene par `-roto` / `-fix`.** El de la fase `be04`
  tiene el `git diff` vacío a propósito, porque su causa está en una línea del
  `.env` y no en el árbol de fuentes. No es un incumplimiento del formato: es el
  contenido del incidente, y el enunciado tiene que decirlo **al resolverlo**, no
  antes.
