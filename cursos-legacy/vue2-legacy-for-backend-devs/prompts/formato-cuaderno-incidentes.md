# 📓 Formato del cuaderno de incidentes
## Paquete Mini Jira — Curso 01 (Vue 2 legacy) + Curso 02 (MongoDB/Express)

Este documento **no es** un cuaderno: es su especificación. Define cómo se construyen los
dos `cuaderno-incidentes.md` del paquete —uno en `01-vue2-legacy/`, otro en
`02-complement-mongodb-backend/`—, que son el entregable de los chats correspondientes.

Se lee después de la [guía de estilo](guia-de-estilo-y-convenciones.md) y del
[formato de las piezas forenses](formato-piezas-forenses.md), y no repite nada de los dos.

> 🧭 **Un solo archivo por curso, sin excepción.** Nada de `incidente-NN.md` sueltos: el
> estudiante trabaja sin instructor y necesita índice, enunciado, pistas, solución y su
> propia bitácora a un scroll de distancia. **Los IDs son globales dentro de su curso y
> nunca se reasignan**, aunque un incidente se retire.

> 📝 **Este paquete no cuenta horas.** El presupuesto es **12 incidentes por cuaderno, 24
> en total**. Cada incidente lleva su propio tiempo sugerido, que es otra cosa: sirve para
> que sepas cuándo estás atascado de verdad, no para llenar un calendario.

---

## 1. Los dos cuadernos son independientes

Es la decisión que más condiciona el contenido, y no es administrativa.

**Los cursos se pueden tomar por separado.** Hay estudiantes que harán solo el Curso 01,
porque van a mantener un frontend Vue 2 y Mongo no les toca. Y el Curso 02 se puede
empezar directo, sin haber escrito una línea del frontend. Los dos cuadernos tienen que
funcionar en ese escenario.

De ahí salen tres reglas duras:

- **El cuaderno del Curso 01 no cita ni una fase del Curso 02.** Puede nombrar una deuda 💸
  y decir que se paga "cuando exista un backend de verdad" —eso es honesto y cierra el
  bucle—, pero ningún incidente se resuelve leyendo el otro curso.
- **Los incidentes de costura viven en el Curso 02 y son autocontenidos.** Entregan el
  frontend ya construido como punto de partida —una rama, un repo clonado, lo que el
  incidente diga— y se resuelven sin haber hecho el Curso 01.
- **Los IDs no se comparten.** Cada curso numera desde `01`. El incidente 05 del Curso 01 y
  el 05 del Curso 02 no tienen nada que ver, igual que sus tags `inc/…` viven en repos
  distintos.

Y hay una razón operativa además de la pedagógica: los incidentes se preparan con
`git switch -c incidente/07 fase-04-dashboard-tickets`, un comando que no existe si el tag
está en el otro repositorio.

---

## 2. Qué hace distinto a cada cuaderno

**El del Curso 01** entrena algo que ningún otro curso del repositorio entrena: **la
reactividad de Vue 2 como fuente de bugs silenciosos**. La propiedad añadida a un objeto
que ya vive en el store, la asignación por índice en un array, el warn que solo sale en
desarrollo. Son bugs donde el dato es correcto, la petición es correcta, y la pantalla
miente — y no se parecen a nada de lo que el lector vio en backend.

**El del Curso 02** entrena lo contrario: bugs donde la pantalla dice la verdad y el
problema está en el modelo. El `$lookup` que parecía gratis, los dos agentes que tomaron el
mismo ticket, el índice creado que nadie usa. Su hilo conductor es `soporte_v1`, el
anti-patrón medido de las fases 3 a 8.

**Y los dos comparten la costura**, que es material exclusivo de este paquete: el momento
en que un frontend escrito contra json-server se enfrenta a un backend real. El `id`
numérico que ahora es un string hex, el evento de socket que cambió de emisor, el `DELETE`
que devolvía `{}`. Nada de eso es un bug de nadie: es un contrato mal leído, que es el
incidente más común en la vida real y el que menos se enseña.

---

## 3. Estructura del archivo

En este orden, y solo en este:

1. **Encabezado** — título, el presupuesto de 12 incidentes, y la frase que fija el trato:
   la solución viene incluida, y abrirla antes de tiempo solo te perjudica a ti.
2. **🧭 Cómo se trabaja un incidente** — el método, las tres formas de llegar al sistema
   roto (§6), la convención de commits (§7) y la tabla de estados (§8).
3. **📋 Índice** — la tabla de los 12 IDs (§4).
4. **🧪 Incidentes** — una entrada por incidente, con el bloque completo de §9. Se repite
   entero cada vez: nada de "ver incidente 03". Se leen salteados y con semanas de
   diferencia.
5. **🪞 Retrospectiva** — §10.
6. **📌 Pendientes que salieron de los incidentes** — §11.

---

## 4. El índice y la reserva de IDs

El índice se actualiza en el mismo commit que abre o cierra un incidente. Un ⬜ significa
que el enunciado todavía no está redactado abajo — **la fila existe desde el momento en que
una fase reserva el ID**, en su bloque `### 📌 Reservas para el cuaderno de incidentes`.

```markdown
| ID | Fase | Título | Categoría | Dif. | Estado |
|---|---|---|---|---|---|
| 05 | 5 | "Le puse etiqueta al ticket y la tabla no se enteró" | Reactividad | 🟡 | ⬜ |
```

> ⚖️ **Divergencia declarada respecto de la guía §3.** La guía limita las tablas a tres
> columnas, porque su regla apunta a las **comparativas**, donde una celda necesita
> explicación y una lista se lee mejor. Ésta no es una comparativa: es una tabla de
> control, seis campos atómicos que se escanean de un vistazo y se ordenan mentalmente por
> cualquiera de ellos. Una lista con subtítulos aquí sería ilegible. La divergencia se
> limita a **este índice y al de la retrospectiva**; el resto del cuaderno sigue la regla.

El título va **en palabras del usuario**, no en lenguaje técnico. *"Tomé el ticket y a mi
compañero le sigue apareciendo libre"* es un buen título; *"race condition en `takeTicket`"*
es la respuesta, y va dentro de la solución.

### Cómo se reparten los 12

Las fases exactas las fijan las reservas de cada fase, pero el reparto no se negocia. La
progresión sigue el arco del curso: los primeros son de una capa, los últimos cruzan
varias.

**Curso 01** — cuatro tramos de tres:

- **Fases 0–3 · tres incidentes 🟢🟢🟡.** El arranque que falla con un error que habla de
  otra cosa, el mock caído que parece un bug del frontend, y el token borrado a mano del
  que la aplicación se entera tarde.
- **Fases 4–6 · tres incidentes 🟡.** La lista que se pinta con los datos de antes, la
  propiedad que el store tiene y la tabla no muestra, el wizard que deja avanzar con un
  paso vacío.
- **Fases 7–9 · tres incidentes 🟠.** La pestaña que se va arrastrando hasta que el
  ventilador se dispara, el evento de socket que duplica filas, y el doble "tomar" que
  ninguno de los dos agentes ve.
- **Fases 10–11 · tres incidentes 🟠🔴🔴.** El módulo de Vuex que se pisa a sí mismo, el
  test que pasa solo cuando corre aislado, y el bug que solo existe en el build de
  producción.

**Curso 02** — cuatro tramos de tres:

- **Fases 0–2 · tres incidentes 🟢🟡.** El contenedor que arranca y no responde, la
  consulta traducida literalmente desde SQL, el filtro que devuelve de más.
- **Fases 3–6 · tres incidentes 🟡🟠.** El documento que crece sin techo, el `$lookup` que
  parecía gratis, y los dos agentes que tomaron el mismo ticket.
- **Fases 7–9 · tres incidentes 🟠.** El índice creado que `explain()` ignora, el arco de
  `soporte_v1` con números, el pipeline que colapsa a una sola fila.
- **Fases 10–13 · tres incidentes 🔴, dos de ellos de costura.** El frontend que no muestra
  nada mientras `curl` sí devuelve los tickets, el evento de socket que ahora llega dos
  veces, y la suite que pasa en local y falla en CI.

### Cuotas mínimas

Para que cada cuaderno cubra de verdad el corazón de su curso:

- **Curso 01** — al menos **2 de reactividad de Vue 2**, **2 de Vuex** y **2 que aterricen
  una deuda 💸 declarada** en alguna fase.
- **Curso 02** — al menos **2 de atomicidad o concurrencia**, **2 del anti-patrón
  `soporte_v1`** y **2 de costura**, estos últimos autocontenidos según §1.

Si al escribir un incidente resulta que no tiene una causa raíz propia —que es la única
razón válida para que un incidente exista—, **no se fuerza**: se retira, se documenta por
qué en 📌 Pendientes, y su ID **no se reasigna**.

**Las cuotas se cuentan por causa raíz, no por etiqueta.** La categoría del índice nombra
el **síntoma**, porque es por donde el estudiante entra a buscar; la cuota mide de qué va
el incidente por dentro. Dos ejemplos reales de este paquete, para que nadie los "corrija"
más adelante:

- El incidente 12 del Curso 01 está etiquetado **Build** —"en el servidor de pruebas se
  comporta distinto que en mi máquina"— y su causa raíz vive en `store/index.js`: el
  `strict` del store que solo corre en desarrollo. **Cuenta para la cuota de Vuex**, y su
  etiqueta se queda como está.
- El incidente 05 del Curso 02 está etiquetado **Modelado** y es el anti-patrón
  `soporte_v1` en estado puro, aunque solo el 08 lo llame por su nombre. **Cuenta para esa
  cuota.**

> ⚖️ **Divergencia declarada — la cuota de concurrencia del Curso 02.** La regla de arriba
> pide **2 de atomicidad o concurrencia** y el cuaderno del Curso 02 entrega **1**: el
> incidente 06, el doble "tomar". Se declara aquí en vez de cumplirse, y el motivo es el
> propio material: **este curso concentra la concurrencia en la Fase 6 por diseño**, y
> ninguna otra fase produce una segunda causa raíz de carrera que sea suya. Las candidatas
> se revisaron una por una y todas fallaban por lo mismo — el índice que `explain()` ignora
> (F7) es de plan de consulta, la migración (F8) es de verificación, el CI (F13) es de
> configuración invisible—: convertir cualquiera de ellas en un caso de concurrencia
> exigiría **inventarle** una carrera al sistema, que es exactamente lo que el párrafo
> anterior prohíbe. Entre una cuota cumplida con un incidente forzado y una cuota declarada
> con su motivo, este paquete elige lo segundo.
>
> Lo que la cuota quería garantizar —que el estudiante salga sabiendo diagnosticar una
> carrera— **sí se cumple**, y por tres vías fuera del cuaderno: la
> [pieza forense de la Fase 6](../02-complement-mongodb-backend/forense-fase-06.md), que
> recorre la reproducción con dos sesiones de `mongosh`; el **duelo de 20 rondas** de la
> Fase 13, que la convierte en un test que se repite; y el `409` de punta a punta del
> ejercicio 22 de esa misma fase. La cuota se escribió antes que el material y midió el
> sitio equivocado.
>
> **Alcance:** esta divergencia vale solo para la cuota de concurrencia del Curso 02. Las
> otras cinco —las tres del Curso 01 y las dos restantes del 02— se cumplen y siguen siendo
> obligatorias.

### Categorías

**Curso 01:** reactividad · estado (Vuex) · integración (mock) · formularios y wizard ·
tiempo real (sockets) · convivencia con framework de ruta · UI · testing · build.

**Curso 02:** modelado (embeber/referenciar) · consultas y `explain()` · atomicidad y
concurrencia · índices · contrato · auth · operación · testing.

### Dificultad

🟢 fácil · 🟡 intermedio · 🟠 difícil · 🔴 muy difícil. Cada incidente lleva además un
**tiempo sugerido** —de 20-40 min los 🟢 hasta un par de horas los 🔴—, porque sin él el
estudiante no sabe cuándo está atascado de verdad y cuándo simplemente le está costando lo
que tiene que costar.

---

## 5. Los cursos son independientes, también acá

Ya está dicho en §1 y se repite en el checklist, porque es la regla que más fácil se olvida:
el paquete se lee como una unidad y la tentación de encadenar los dos cuadernos es
constante. Antes de dar por bueno un incidente, la pregunta es: **¿se puede resolver sin
abrir el otro curso?** Si la respuesta es no, o el incidente cambia o cambia de cuaderno.

---

## 6. Cómo llega el sistema roto a tu máquina

Cada incidente lo dice en su bloque **🔧 Preparación**, y hay exactamente tres formas. El
orden no es casual: **se usa siempre la más barata que sirva**, porque una preparación
complicada es una excusa para saltarse el incidente.

**1 · Un flag del inyector de caos** (Curso 01, Fase 3), cuando el fallo es de red o de
respuesta. Es la preferida: no toca tu código, no toca tus datos, y se apaga sola al
reiniciar el mock.

```bash
CHAOS=malformed npm run mock
```

**2 · Un `db.json` alterno**, cuando el bug está en el dato y no en el código: un ticket que
llega sin el campo `tags`, un comentario cuyo ticket ya no existe. Se llaman
`db.incidente-NN.json`, viven junto al `db.json`, y se activan copiando. En el Curso 02 el
equivalente es un seed alterno, `scripts/seed.incidente-NN.js`.

```bash
cp db.incidente-05.json db.json    # guarda el tuyo antes, o corre npm run mock:reset después
```

**3 · Una rama de git**, y solo cuando haya que romper código. Sale del tag de la fase
correspondiente, así que se crea sin buscar nada:

```bash
git switch -c incidente/07 fase-04-dashboard-tickets
# …y el commit de la rama trae el cambio mínimo que produce el síntoma
```

> 🔑 **La regla, y sirve mucho más allá de este cuaderno:** cuando alguien te pida
> reproducir un bug, la primera pregunta es *"¿esto se reproduce con un flag, con un dato,
> o hace falta otro código?"*. Averiguarlo te ahorra la mitad del camino antes de leer una
> línea.

---

## 7. La convención de commits

El asunto sigue este formato, para que `git log --oneline` se lea como la línea de tiempo
de la investigación:

```
incidente(05): abre — la etiqueta no aparece en la tabla
incidente(05): repro — solo pasa con tickets que vienen sin el campo tags
incidente(05): hipótesis descartada — no es el mock, el PATCH devuelve el ticket completo
incidente(05): causa — la propiedad se agrega después de que el objeto entró al store
incidente(05): fix — Vue.set en la mutation UPSERT_TICKET
incidente(05): cierre — test de regresión y post-mortem
```

Los verbos son fijos: `abre`, `repro`, `hipótesis`, `hipótesis descartada`, `causa`, `fix`,
`cierre`.

**Commitea también los callejones sin salida.** Un `git log` con seis commits de
investigación y uno de fix es un registro honesto; uno que muestra solo el fix no le sirve
a nadie, y menos a ti dentro de seis meses.

Y como el fix de casi todos estos incidentes es de una o dos líneas, márcalo además con el
par de tags de [`convencion-de-git-y-tags.md`](convencion-de-git-y-tags.md) §🚑:

```bash
git tag -a inc/f05/etiqueta-invisible-roto -m "Síntoma, repro y la prueba en rojo."
# …el fix…
git tag -a inc/f05/etiqueta-invisible-fix  -m "Causa raíz, fix, y la prueba en verde."

git diff inc/f05/etiqueta-invisible-roto inc/f05/etiqueta-invisible-fix
git tag -n99 -l 'inc/*'
```

Cuando la solución de un incidente **salda una deuda 💸 declarada**, se dice y se usa el tag
`deuda/<slug>-pagada` de la misma convención: es el mismo mecanismo, no uno paralelo.

> 💡 Para releer la historia de un incidente:
> `git log --oneline --grep "incidente(05)"`

**Regla del archivo: se agrega, no se corrige.** Una hipótesis que resultó falsa no se
borra: se marca como descartada, con la evidencia que la tumbó.

---

## 8. Estados

| Estado | Significado |
|---|---|
| ⬜ Sin empezar | Todavía no lo tocaste |
| 🔴 Abierto | Leído, sin reproducir |
| 🟡 En análisis | Reproducido, causa raíz sin confirmar |
| 🟢 Cerrado | Fix aplicado y prueba de regresión pasando |
| ⚪ Descartado | No se reproduce, y está documentado por qué |

---

## 9. La plantilla de un incidente

Se copia entera para cada entrada.

> ⚖️ **Divergencia declarada respecto de la guía §3.** La guía dice *"Markdown siempre.
> Nada de HTML embebido salvo que no haya alternativa"*, y acá no la hay: las pistas y la
> solución tienen que **poder ocultarse**, o el ejercicio se arruina con solo bajar la
> vista. Los `<details>` son la única excepción del paquete, y se limitan a este uso.

````markdown
## Incidente {{NN}} — {{Título en palabras del usuario}}

> **Fase:** {{N}} · **Categoría:** {{categoría}} · **Dificultad:** {{🟢🟡🟠🔴}}
> **Estado:** ⬜ Sin empezar · **Abierto:** {{—}} · **Cerrado:** {{—}}
> **Tiempo sugerido:** {{20-40 min}}

### 🎫 El ticket

{{El reporte tal como llegó, con su vaguedad incluida. Dos o tres frases en lenguaje de
negocio, escritas por alguien que no sabe qué es una mutation ni un índice compuesto. "A
veces pasa" es un dato legítimo, no un defecto del reporte.}}

**Reportado por:** {{rol — agente de soporte, coordinador, reportador, alguien de sistemas}}
**Ambiente:** {{desarrollo / UAT / ambos}}

### 🎯 Qué se te pide

{{Una o dos líneas con el entregable concreto: reproducir y localizar la capa, o reproducir
y aplicar el hotfix mínimo, o explicar por qué NO se reproduce. No todos los incidentes
terminan en fix, y el que termina en "esto no es un bug, y acá está la evidencia" es de los
más formativos.}}

### 🔧 Preparación

{{Cuál de las tres formas de §6, y por qué esa.}}

```bash
{{CHAOS=malformed npm run mock | cp db.incidente-NN.json db.json | git switch -c incidente/NN fase-NN-slug}}
```

---

<details>
<summary>💡 <b>Pista 1</b> — dónde mirar (ábrela si llevas 20 min sin una idea nueva)</summary>

{{Señala la capa y la herramienta, sin decir qué vas a encontrar: "esto se ve en Network
antes que en la consola", "el store ya tiene el dato correcto; compara lo que guarda con lo
que pinta la tabla".}}

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

{{Esto lo escribes tú, antes de abrir la solución. Es la parte que se versiona y la que vas
a releer en la retrospectiva.}}

**Reproducción**
{{Pasos numerados y exactos, con datos concretos: qué ticket, qué agente, qué estado, qué
hora y en qué zona horaria. Si no lo lograste, escribe qué intentaste — no reproducir
también es un resultado.}}

**Evidencia observable**
{{Lo que viste, no lo que supones: consola, Network, Vue DevTools, logs del mock, mongosh,
`explain()`. Texto, no capturas: el texto se versiona.}}

```
{{payload, error o traza}}
```

**Hipótesis**
- ❌ Descartada: {{qué creíste y qué evidencia la tumbó}}.
- ✅ Confirmada: {{la que sobrevivió}}.

**Tu causa raíz**
{{Archivo y línea, o la decisión de diseño culpable.}}

**En qué capa vivía**
{{Componente / store / servicio HTTP / mock — o ruta / controller / service / Mongo. Es la
pregunta 3 del método, y anotarla es lo que después hace útil la retrospectiva.}}

**Tu fix**
{{El parche mínimo que aplicarías un viernes a las seis, escrito en el estilo del archivo
que tocaste. Aparte, en una línea, la refactorización correcta que harías con calma.}}

---

<details>
<summary>✅ <b>Solución de referencia</b> — ábrela después de escribir la tuya</summary>

**Causa raíz**

{{Hasta el archivo y la línea. Si la causa es una decisión de diseño, se nombra la decisión
y se explica en qué momento de la vida de Mini Jira tenía sentido.}}

**Parche mínimo**

```js
{{el hotfix, con comentarios en español, identificadores en inglés, y en el estilo del
archivo que se toca: Options API y function () {} en el Curso 01, driver nativo en el 02}}
```

**La refactorización correcta**

{{Qué haría alguien con tiempo y pruebas. Si la deuda que originó el bug está marcada 💸 en
alguna fase, decir en cuál se paga — y si es del otro curso, decirlo sin exigir haberlo
hecho.}}

**Prueba de regresión**

{{El test que falla antes del fix y pasa después. Código, no descripción.}}

```js
{{spec}}
```

**Prevención**

{{Test, validación en la frontera del servicio, normalización del payload, índice, feature
flag o alerta.}}

**Por qué llegó a producción**

{{Post-mortem sereno: qué del sistema o del proceso lo permitió. Se analiza el sistema,
nunca a la persona. Acá el humor baja un punto — un post-mortem no es el lugar del chiste.}}

**Si tu causa fue distinta a ésta**

{{Los diagnósticos alternativos plausibles y por qué el síntoma también encaja con ellos.
Que tu fix funcione y tu causa no coincida es información: casi siempre significa que
tapaste el síntoma en una capa más arriba.}}

</details>
````

---

## 10. La retrospectiva

Cierra el archivo. Se llena al terminar, de una sola vez, releyendo tu propio `git log`:

- **Cuántos abriste, cuántos cerraste, cuántos quedaron ⚪.**
- **Cuántas veces tu causa raíz coincidió con la de referencia**, y en cuáles no. El patrón
  importa más que el número.
- **En qué capa te costó más.** Es la métrica propia de este paquete, y sale directamente
  del campo "en qué capa vivía" de cada incidente: si el 70 % de tu tiempo se fue buscando
  en el componente lo que estaba en el store, eso es un dato sobre cómo lees código, no
  sobre estos doce bugs.
- **Cuántas veces el síntoma estaba en una capa y la causa en otra.** Es la definición
  práctica de un bug difícil.
- **Qué pista abriste antes de tiempo y por qué.** Sin culpa: es un dato sobre dónde te
  falta confianza, no sobre tu disciplina.
- **Tu checklist de hotfix**, de una página, reescrita con lo que aprendiste. Es lo único
  de este archivo que te llevas a un sistema que no es Mini Jira.

---

## 11. Pendientes que salieron de los incidentes

Lo que apareció investigando y no cabía en el fix, con el ID que lo originó:

```markdown
- **[05]** {{pendiente}} → sugerido para {{apéndice / fase / ejercicio 🔥}}.
```

Acá van también los incidentes retirados, con el motivo, para que su ID quede
explícitamente muerto y nadie lo reutilice.

---

## 12. Checklist antes de dar por cerrado un cuaderno

- [ ] 12 incidentes, con el reparto por tramos y dificultad de §4.
- [ ] Las cuotas mínimas de categoría se cumplen (§4).
- [ ] **Independencia:** ningún incidente del Curso 01 cita el Curso 02, y los de costura
      del Curso 02 se resuelven sin haber hecho el Curso 01 (§1).
- [ ] Todos los IDs del índice tienen entrada abajo, y ninguno se reasignó. Los retirados
      están en 📌 Pendientes con su motivo.
- [ ] Cada incidente dice cuál de las tres formas de preparación usa, y usa la más barata
      que sirve (§6).
- [ ] Cada solución trae parche mínimo, refactorización correcta, prueba de regresión **en
      código**, prevención y post-mortem sin culpabilización.
- [ ] Los títulos están en palabras del usuario, no en lenguaje técnico.
- [ ] Nada contradice el contrato de
      [`00-audit-contrato.md`](../02-complement-mongodb-backend/00-audit-contrato.md):
      forma de las respuestas, enums `status` y `priority`, nombres de evento de socket,
      mapeo `id` ↔ `_id`.
- [ ] Todo el código en inglés, comentarios en español, y el parche escrito en el estilo del
      archivo que toca.
- [ ] Español latinoamericano con tuteo, cero voseo — y ojo con los tickets, que están
      escritos en voz de usuario y son donde más se cuela (guía §4.7).
- [ ] Cada `.md` citado existe con ese nombre exacto (guía §13.2).
- [ ] La retrospectiva y los pendientes están al final, en ese orden.
