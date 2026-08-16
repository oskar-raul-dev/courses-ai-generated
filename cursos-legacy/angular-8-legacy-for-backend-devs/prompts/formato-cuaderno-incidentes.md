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
> corregido en `prompts/alcance-del-proyecto.md` §6, en
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

> 🧰 **El contenido de cada preparación está en
> [`preparaciones-de-incidentes.md`](preparaciones-de-incidentes.md)**, escrito el
> 11/09/2026: qué línea rompe cada una de las nueve ramas, qué registros lleva cada
> uno de los tres `db.incidente-NN.json`, y cómo comprobar que la preparación
> reproduce el síntoma. Es material de autoría y **no se enlaza desde el cuaderno**:
> es la respuesta.

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

> ✅ **Escrito el 11/09/2026.** Los veintiún enunciados están en
> `cuaderno-incidentes.md`, con el reparto 7 / 7 / 4 / 3 y la escala
> 2 🟢 · 8 🟡 · 9 🟠 · 2 🔴 de §3, verificados contra el índice fila por fila. Las
> tres formas de preparación de §5 se usaron diez veces la rama, tres veces el
> `db.incidente-NN.json` y tres el flag de caos —sin inventar ni un modo que la
> Fase 4 no construya—, y cinco incidentes no necesitan ninguna porque el
> comportamiento vive en el código tal como se escribió. El 22 sigue **sin dar de
> alta**, con dos candidatos anotados: el `setTextColor` que no se revierte (desde
> el 15) y el `undefined` del slice lazy que la Fase 6 dejó apuntado.

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

✅ **Escrito el 10/09/2026.** Este formato aplicó igual a
**`cuaderno-incidentes-be.md`**, el cuaderno del track opcional de backend
(Java 8 + Spring Boot 2.1 + MongoDB): mismo esqueleto de incidente, mismas pistas
plegadas, mismo post-mortem sin culpabilización.

> 🪦 **Y por eso `prompts/plantilla-de-incidente-be.md` no se escribió**, aunque
> `propuesta-fases-backend.md` §9 lo dejaba abierto ("si el formato diverge del
> base"). No diverge: la plantilla de §8 se copió literal. Lo único propio del
> track son las cuatro formas de preparación y la excepción de `be-11`, que ya
> están declaradas aquí abajo. **Un archivo de plantilla que duplicara §8 sería
> dos fuentes de verdad para lo mismo**, que es justo lo que este documento
> existe para evitar.

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
- **La preparación del sistema roto** no usa el `db.json`: el dato vive en Mongo.
  La §5 se reescribió entera para el track y quedó en **cuatro** formas, de la
  más barata a la más cara: (1) un flag del inyector de caos, el mismo de la
  Fase 4 reimplementado en Java; (2) una colección sembrada a propósito, con
  guiones `dump/seed-incidente-be-NN.js`; (3) **una línea del `.env`**, que es la
  forma propia del track y la que casi nadie considera —solo la usa `be-11`—; y
  (4) una rama de git. Las ramas llevan namespace propio, `incidente-be/NN`, y
  salen del tag `be-fase-*` con el slug completo; los tags de fase viven en ese
  namespace para que `git tag -l 'fase-*'` siga siendo el índice limpio del track
  base. Todo registrado en `00-convencion-de-git-y-tags.md` §🔥.
- ⚠️ **El incidente `be-11` no tiene par `-roto` / `-fix`.** Es el de la fase
  `be07` —la subida de versión que nadie decidió— y su `git diff` está vacío a
  propósito, porque su causa está en una línea del `.env` (`MONGO_TAG`) y no en el
  árbol de fuentes. No es un incumplimiento del formato: es el contenido del
  incidente, y en un curso construido sobre el `git diff` como factura de la deuda
  es exactamente la lección —*`git log`, `git blame` y el último despliegue no
  siempre tienen la respuesta*—. El enunciado tiene que decirlo **al resolverlo**,
  no antes.
