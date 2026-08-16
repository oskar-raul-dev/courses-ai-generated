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
