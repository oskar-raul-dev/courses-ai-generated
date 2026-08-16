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
