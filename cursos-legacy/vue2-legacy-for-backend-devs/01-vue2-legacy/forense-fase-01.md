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
