# 💸 Apéndice A12 — Mapa de deuda técnica

> Tutorial React 16 — Rifas y chances · Registro vivo · **~1,5 horas** la primera lectura
> Lo produce: Fase 11 · Lo citan: Fases 1, 4, 5 y 11 · Lo alimentan todas · Se consulta antes de cada cambio.

Este archivo es el **inventario de decisiones deliberadas** del sistema. No lista
bugs: ninguna de estas líneas está rota. Lista sitios donde alguien eligió
conscientemente no hacer lo "correcto" todavía, porque el costo superaba al
beneficio en ese momento.

Es el artefacto más directamente transferible del curso. En un equipo real, este
archivo es lo que convierte "el código está lleno de cosas raras" en un backlog
priorizable, y lo que le permite a la persona que entra mañana responder la
pregunta que decide todo: **¿esto está así a propósito o por error?**

> 📝 **De dónde sale este apéndice, y por qué es un archivo aparte.** El mapa
> vivía dentro de la §5.1 de la Fase 11, y esa misma fase declaraba la
> incongruencia con una 💸 explícita: *"este mapa debería vivir en un archivo
> versionado, no en el `.md` de la última fase del tutorial"*. Extraerlo paga esa
> meta-deuda. Y hay una razón práctica encima de la coherencia: un inventario que
> vive en la última fase se lee una vez, y un inventario que no se relee no sirve
> de nada.

---

## 1. Cómo se lee este mapa

Cada entrada tiene cuatro partes, y **la cuarta es la que importa**:

- **Qué se hizo en su lugar** — la solución que está en el código hoy.
- **Por qué se dejó** — el razonamiento de quien decidió. Sin esto, la entrada
  es inútil: dentro de un año nadie recordará si fue criterio o pereza.
- **Qué la vuelve exigible** — el **disparador**. La condición concreta que
  convierte esta deuda en un bug con fecha.
- **Fase** — dónde está documentada en detalle.

El trabajo del equipo no es pagar todo. Es **vigilar los disparadores**.

Mientras el disparador no ocurra, pagar la deuda es trabajo sin retorno — peor,
es *riesgo* sin retorno, porque estás tocando código que funciona. El día que el
disparador ocurre, la deuda deja de ser deuda y pasa a ser un bug con fecha de
vencimiento.

> 🧭 **La distinción operativa que gobierna todo el archivo.** Deuda deliberada
> tiene un motivo documentado y, con frecuencia, un test que fija el
> comportamiento actual como *esperado* —el `formatCents` que **lanza** con un
> float, por ejemplo, que la Fase 10 testea como correcto—. "Arreglarlo" rompería
> algo que dependía de ese comportamiento. El descuido no tiene ni motivo ni
> test, y ahí sí se corrige sin preguntar. Confundir las dos es la forma más
> común de que un hotfix bienintencionado genere el próximo incidente.

---

## 2. El inventario

### 💸 `window.confirm` en el borrado de rifas

**Fase 4.** Se usa la confirmación nativa del navegador en vez de un modal de
Bootstrap.

Se dejó porque un modal es UI pura: no cambia una línea de lógica, y diferirlo
costaba cero. `window.confirm` es feo, bloquea el hilo y no se puede estilar,
pero funciona y es honesto sobre lo que hace.

**Se vuelve exigible** cuando aparezca un requisito de consistencia visual del
producto, o cuando el smoke test de Cypress necesite cubrir el flujo de borrado
—`cy` no puede interactuar con un `confirm` nativo sin stubbearlo.

---

### 💸 `raffleSlice` sin normalizar

**Fase 4** (declarada) / **Fase 8** (donde empieza a doler). Las rifas viven
como array en `items`, y el cruce rifa↔liquidación se hace con `find`, que es
O(n).

Se dejó porque con decenas de rifas el costo es literalmente imperceptible, y
`createEntityAdapter` habría metido una capa de indirección que en este tamaño
solo agrega ruido. La Fase 4 lo pensó y decidió que no.

**Se vuelve exigible** cuando el listado crezca a cientos o miles de rifas y el
render del dashboard se sienta lento. El síntoma va a aparecer primero en el
Profiler de la Fase 9, no en la tabla.

> 📖 `A6-redux-clasico-vs-toolkit.md` §8 tiene el `createEntityAdapter` listo
> para el día que toque.

---

### 💸 Dinero en enteros nativos, sin librería

**Fase 8.** `money.js` con `toCents`/`formatCents` como única frontera; sin
`dinero.js` ni `big.js`.

Se dejó porque los montos del dominio caben holgadamente en el entero seguro,
las operaciones son sumar, multiplicar por entero y dividir con resto, y hay una
sola moneda. Agregar una dependencia a un sistema congelado cuesta —una versión
más que auditar, un peer dependency más que puede romper el lock— y acá no
compraba nada.

**Se vuelve exigible** con varias monedas de subdivisión distinta, con conversión
de divisas, o con montos que puedan desbordar `Number.MAX_SAFE_INTEGER`.

> 📖 El razonamiento completo está en `A10-aritmetica-de-dinero.md` §7.

---

### 💸 Reloj del cliente sin `serverNow`

**Fase 7.** El cierre por hora dura se evalúa contra `Date.now()` del navegador.

Se dejó porque el desfase típico de un reloj de escritorio es de segundos, y
tolerable en desarrollo y UAT. Sincronizar con el servidor exige un endpoint de
hora, un cálculo de offset y una política de qué hacer cuando el offset es
grande: es una feature, no un ajuste.

**Se vuelve exigible** el día que un cliente con el reloj corrido venda después
del cierre real. Es una de las tres deudas que sobreviven al curso entero, y la
más probable de las tres.

> ⚠️ Ya tiene una manifestación visible: el ejercicio 🟠 23 de la Fase 10 falla
> en CI por zona horaria. Eso no es el test estando mal; es la deuda avisando.

---

### 💸 `selectIsRaffleClosed` sin unificar

**Fase 7.** La lógica de "esta rifa está cerrada" vive repetida en varios
selectores en vez de en uno solo.

Se dejó porque, en el momento de escribirla, nadie la reusaba lo suficiente como
para que la duplicación doliera. Unificar prematuramente también tiene costo:
crea un punto de acoplamiento entre consumidores que quizá necesiten cosas
distintas.

**Se vuelve exigible** en cuanto un tercer o cuarto consumidor necesite la misma
verdad. El síntoma de que ya pasó el punto: dos copias empiezan a divergir y
aparece un bug donde una pantalla dice "cerrada" y otra "abierta".

---

### 💸 Participantes sin slice propio

**Fase 5** (origen) / **Fase 9** (donde se nota). `byNumber` no guarda
`participantId`, así que `computeRecurringParticipants` devuelve `0` — con
honestidad, no fingiendo un cálculo.

Se dejó porque el modelo de datos no tiene identidad de participante y agregarla
es una feature de dominio completa: formulario de comprador, colección propia,
relación con la venta.

**Se vuelve exigible** el día que se agregue identidad de participante. Cuando
pase, hay que reimplementar el selector **y** su test — está fijado en el
ejercicio 17 de la Fase 10 para que no se olvide.

> 🧠 **Por qué devolver `0` y no ocultar el KPI.** Un indicador que muestra cero
> con una nota explicando por qué es información. Un indicador que desaparece es
> una pregunta sin respuesta para quien mire el dashboard dentro de seis meses.

---

### 💸 `RaffleDetailPage` sigue leyendo el array hardcodeado

**Fase 1** (origen) / **Fase 4** (donde se paga a medias). El listado de rifas
migró al store en la Fase 4, pero el detalle sigue importando `findRaffle` de
`src/mock/raffles.js`, así que la app tiene **dos fuentes de verdad** para la
misma entidad: el store para la lista, un array en memoria para el detalle.

Se dejó porque migrar el detalle exige `activeId` en `raffleSlice` —que recién
aparece en la Fase 7— y porque hacerlo en medio de la Fase 7, que ya tiene hora
dura y polling encima, sería exactamente el «ya que estoy» que este curso enseña
a no hacer.

**Se vuelve exigible** en cuanto alguien edite una rifa desde el listado y entre
al detalle: va a ver los datos viejos, porque el array nunca se enteró. Es un
bug con síntoma claro y causa poco obvia, del tipo que se reporta como «a veces
muestra información desactualizada».

> 🧠 **Por qué esta entrada vale más que las otras.** Es la única deuda del
> inventario que produce una **inconsistencia visible al usuario**, no solo un
> costo interno. Casi todo sistema en migración tiene una pantalla que se quedó
> atrás; lo que distingue a un equipo que la controla de uno que no es que la
> primera la tenga escrita en algún lado. Esta línea es esa escritura.

---

### 💸 Tipo `'stale'` reservado sin materializar

**Fase 7.** Está en el catálogo de `error.type` pero ningún código lo emite.

Se dejó porque se anticipó el caso —una respuesta que llega tarde y ya no
aplica— sin tener todavía el escenario concreto que lo dispara.

**Se vuelve exigible** cuando aparezca esa condición de dato viejo. Si nunca
aparece, **la deuda correcta es borrarlo**: un valor de enum que nadie emite es
una mentira en el catálogo, y alguien va a escribir un `case` para él.

---

### 💸 Registro manual de epics en `rootEpic.js`

**Fase 6.** Cada epic se importa a mano y se agrega a `combineEpics`.

Se dejó porque con seis epics el registro explícito se lee mejor que cualquier
barrel automático: abres el archivo y ves exactamente qué está corriendo.

**Se vuelve exigible** cuando el sistema crezca a decenas de epics y el archivo
se vuelva inmanejable. No antes: un import glob que descubre epics
automáticamente es cómodo hasta el día que uno no se registra y nadie entiende
por qué.

---

### ✅ Versiones de `rxjs-marbles` y `cypress` sin pinear — **pagada**

**Fase 10.** *Estaba* declarada como deuda: las versiones se dejaban al
`package-lock`.

**Se pagó** al crear `prompts/decisiones-y-versiones.md`: `rxjs-marbles@6.0.1` y
`cypress@10.11.0` van pineadas en `package.json`, y el porqué del pin de
`rxjs-marbles` —su major está atado al de RxJS— está documentado en D9.

Se deja la entrada tachada en vez de borrarla, porque un mapa de deuda que
solo muestra lo pendiente no le enseña a nadie cómo se paga.

---

### 💸 Smoke stubbeado en vez de servicios reales

**Fase 10.** El smoke de Cypress usa `cy.intercept` en vez de levantar
json-server efímero.

Se dejó porque el happy path no necesita backend real para dar señal, y un
smoke que depende de levantar dos servidores es un smoke que va a fallar por
motivos que no son el código.

**Se vuelve exigible** cuando se quiera cobertura de integración real y no solo
verificación del contrato de red.

---

### 💸 Token en `localStorage`, sin expiración ni firma

**Fase 2** (declarada) / **Fase 3** (persistida). El token es una string en el
`db.json`, se guarda en `localStorage` y no caduca.

Se dejó porque hacerlo bien es trabajo de backend —emitir un JWT firmado,
validarlo, rotar— y este curso es de frontend. Lo que sí se construyó es el
*andamiaje* correcto: un punto único de contacto con `localStorage`
(`authStorage.js`), para que cambiar de mecanismo el día de mañana toque un solo
archivo.

**Se vuelve exigible** el día que exista un backend de identidad real. Y hay que
decirlo con todas las letras: **fuera de un contexto pedagógico esto no es
deuda, es un hallazgo de seguridad.** Está acá porque el curso lo declara como
simplificación consciente, no porque sea aceptable en producción.

---

## 3. Las tres que sobreviven al curso

De todo el inventario, tres deudas no se pagan nunca dentro del curso y merecen
que se diga explícitamente:

**`serverNow`** — el reloj del cliente. Es la más probable de manifestarse y la
que tiene consecuencia económica directa (vender después del cierre).

**El slice de participantes** — bloquea un KPI del dashboard y no se puede pagar
sin cambiar el modelo de datos.

**La normalización de `raffleSlice`** — puramente de escala; hoy no duele.

Que estén declaradas como eternas es lo honesto. Una deuda eterna reconocida es
información útil; una deuda diferida cinco veces con promesas de "el próximo
sprint" es ruido que nadie vuelve a leer.

> 🧠 **La diferencia importa más de lo que parece.** "Esto no lo vamos a hacer, y
> estas son las condiciones bajo las que reconsideraríamos" es una decisión de
> ingeniería. "Esto lo hacemos más adelante" repetido durante dos años es la
> forma en que un backlog técnico se vuelve invisible hasta que explota.

---

## 4. Cómo se mantiene este archivo

**Cuando declares una deuda nueva** (una 💸 en cualquier fase o incidente),
agrégala acá con sus cuatro partes. Una 💸 que solo existe en un comentario del
código es una 💸 que nadie va a encontrar.

**Cuando pagues una**, no la borres: márcala ✅ con qué la disparó y cómo se
pagó, como la de `rxjs-marbles`. El registro de deudas pagadas es lo que enseña
a la siguiente persona cómo se paga una, y evita que alguien la reintroduzca sin
saber que ya se discutió.

**Cuando un disparador ocurra**, la entrada cambia de estado: deja de ser deuda y
pasa a ser un ticket. Ese es el único momento en que este archivo genera trabajo,
y es exactamente el momento en que debe generarlo.

**Revísalo antes de cada cambio grande.** Es cinco minutos y responde por
adelantado la pregunta que más tiempo hace perder en mantenimiento: *¿esto está
así a propósito?*

---

## 🧪 Ejercicios (6)

1. **🟢** Recorre las once fases buscando cada 💸 en el texto. Compara tu lista
   con el inventario de §2. Toda 💸 que encuentres y no esté acá es un hallazgo:
   agrégala con sus cuatro partes.
2. **🟢** Para cada entrada de §2, escribe en una línea **cómo detectarías** que
   su disparador ocurrió. Si para alguna no se te ocurre nada observable, ese
   disparador está mal formulado: reescríbelo.
3. **🟡** Ordena el inventario por riesgo real —probabilidad de que el disparador
   ocurra × costo si ocurre— y defiende tu orden en un párrafo. No hay respuesta
   única; lo que se evalúa es el criterio.
4. **🟠** Toma la deuda de `serverNow` y escribe el ticket completo que abrirías
   el día que se dispare: síntoma esperado, cómo reproducirlo, qué capa tocar,
   qué test escribir primero, y el estimado. Es el ejercicio que convierte una
   línea de inventario en trabajo ejecutable.
5. **🟠** Elige una entrada y escribe el **test que fija el comportamiento actual
   como esperado** (como el `formatCents` que lanza). Ese test es lo que impide
   que alguien "arregle" la deuda por accidente en un refactor.
6. **🔴** Para la deuda del token en `localStorage`, escribe el análisis que le
   presentarías a alguien de seguridad: qué expone exactamente, qué ataque
   habilita, qué mitigaciones existen del lado del frontend —y cuáles **no**
   pueden resolverse sin backend—. Distingue con claridad lo que es decisión de
   producto de lo que es limitación técnica. Es la conversación más difícil de
   este archivo y la que más se parece a un trabajo real.

---

## 📚 Referencias

**Del curso**
- Fase 11 §5.3 — el caso trabajado de hotfix mínimo frente a refactorización,
  que es la aplicación práctica de este archivo.
- `00-historia-del-sistema.md` §4 — por qué cada cosa quedó como quedó.
- `prompts/decisiones-y-versiones.md` — las decisiones que **no** son deuda, sino
  restricciones firmes del proyecto. La diferencia importa: una restricción no
  se paga, se respeta.

**Lectura de fondo**
- La metáfora original de la deuda técnica es de Ward Cunningham (1992), y su
  formulación es más precisa que el uso habitual: la deuda es lo que asumes
  conscientemente para entregar antes, sabiendo que pagarás intereses. Código
  malo por descuido no es deuda: es código malo.
- Martin Fowler escribió sobre el *Technical Debt Quadrant*, que cruza
  deliberado/inadvertido con prudente/temerario. Este archivo inventaría el
  cuadrante deliberado-prudente; los otros tres no se declaran, se descubren.

> ⚠️ Ambas referencias se citan de memoria: verifica autor, fecha y formulación
> exacta antes de citarlas en una discusión de equipo.

---

> **La señal de que este archivo hace su trabajo:** cuando alguien nuevo abra el
> proyecto, encuentre una línea rara, venga acá, la encuentre explicada — y no la
> toque.

---

> 🏷️ **Este apéndice no lleva tag propio.** Es material de consulta: si no
> cambia el repo, no hay nada que apuntar. Cuando de leerlo sí salga código
> —una deuda pagada o una nueva declarada—, commitéalo con el prefijo de la
> fase desde la que llegaste (`f06: …`), no con el del apéndice, para que el
> `git log --oneline --grep '^f06'` de esa fase siga estando completo. Y si el
> ejercicio produjo una medición, el número va en el mensaje del tag
> (`ej/a12/3`), que es donde no se pierde. Todo eso está en [`00-convencion-de-git-y-tags.md`](00-convencion-de-git-y-tags.md).
