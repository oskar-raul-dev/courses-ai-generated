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
