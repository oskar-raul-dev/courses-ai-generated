# 🆕 NX4 — Crear: página SSR nueva (timeline de actividad)

> Nuxt puro. Sin traducir nada. La primera fase de toda la ruta que **no mira al
> Mini Jira a pelo por encima del hombro** — construye algo que a pelo no podías.

**Consume:** F8 (WebSockets). **Apoya en:** NX2 (`<client-only>`, `process.client`,
la auth por cookie), NX3 (`asyncData`, el contexto, `error()`). **No migra nada.**

---

## 🎯 Propósito

Hasta aquí la ruta NX ha sido demolición controlada: NX2 rompió la app y la
recompuso, NX3 le quitó a Vuex el monopolio de cargar datos. Todo era el mismo
Mini Jira **puesto sobre otro suelo**.

En NX4 dejas de reconstruir y **construyes**: una página que no existe en el curso
base, el **timeline de actividad de un ticket** — el historial de qué le pasó,
quién lo tocó y cuándo. Y la construyes aprovechando lo único que Nuxt te regala y
que a pelo nunca tuviste: **renderizado en servidor de verdad**.

La lección no es "otra página más". Es un **híbrido que ninguna de las otras rutas
puede enseñar**:

- el timeline **se renderiza en el servidor** con `asyncData` → el navegador
  recibe el HTML **ya pintado**, con todo el historial dentro;
- y **acto seguido se actualiza en vivo** por socket → eso solo pasa **en el
  cliente**, en `mounted()`.

SSR para el estado inicial, cliente para el tiempo real, **en la misma página, sin
que el usuario vea la costura**. Ese cruce es el corazón de la fase.

Y de paso, tres cosas que solo tienen sentido cuando hay un servidor renderizando:
`head()` (meta tags dinámicos por ticket, lo que una SPA no puede darle a un
crawler), `validate()` (rechazar un id inválido **antes** de renderizar nada) y las
transiciones de página de Nuxt.

> La regla de la fase: **el servidor pinta el pasado, el cliente pinta lo que llega
> después.** Si confundes de quién es cada mitad, o duplicas el trabajo, o te
> rompes la hidratación.

---

## ✅ Qué queda listo al terminar

- Ruta nueva `/tickets/:id/activity`, resuelta desde `pages/tickets/_id/activity.vue`
  (ruta **anidada** dentro de `pages/tickets/_id/`).
- Colección nueva `activity` en `db.json`, con su `activityService`.
- El timeline **llega renderizado desde el servidor**: `curl` a la URL devuelve el
  HTML con los eventos dentro, sin ejecutar una línea de JS en el cliente.
- El timeline **se actualiza en vivo**: si otro usuario cambia el estado del ticket,
  aparece una entrada nueva arriba, sin recargar — pero **solo tras hidratar**.
- `head()` inyectando `<title>` y `<meta>` dinámicos con el título del ticket.
  Demostrado con `curl`: los meta ya vienen en el HTML del servidor.
- `validate()` rechazando `/tickets/abc/activity` con un 404 **antes** de tocar la
  API o renderizar.
- Una transición de página suave al entrar/salir del timeline.
- La **deuda del historial** documentada: quién lo genera de verdad (el backend) y
  qué estamos falseando desde el front.

## 🚫 Qué NO entra todavía

- Paginación / scroll infinito del historial (un ticket viejo puede tener 300
  eventos — ejercicio 🟠).
- Filtrar el timeline por tipo de evento en el servidor (ejercicio 🟡).
- Persistir en el backend los eventos que emitimos desde el front — **seguimos sin
  backend de verdad**, y esa es la deuda 💸.
- Autorización real: quién puede ver el historial de qué ticket (mock, como toda la
  auth del curso).
- Optimistic UI al crear el evento (lo dejamos como ejercicio 🔴).
- Rutas de wizard como `/nuevo/paso-1` — se **discute** en el ejercicio 🔴, no se
  implementa aquí.

---

## 🧠 Concepto 1: el híbrido SSR + tiempo real (la fase entera cabe aquí)

Una SPA a pelo (el Mini Jira del tronco) solo sabe hacer una cosa con los datos:
**pedirlos desde el cliente, después de montar**. Por eso siempre ves el parpadeo
"cargando…" → datos. El servidor manda un cascarón vacío y el navegador lo rellena.

Nuxt te da una segunda opción que a pelo no existía: **pedir los datos en el
servidor, antes de renderizar**, y mandar el HTML ya lleno. Eso es `asyncData`, que
ya viste en NX3.

Pero el timeline necesita **las dos cosas a la vez**, y ahí está la lección:

```
        SERVIDOR (una vez, por request)          CLIENTE (tras hidratar, para siempre)
        ────────────────────────────────         ────────────────────────────────────
        asyncData(context)                        mounted()
          └─ GET /activity?ticketId=1               └─ socketService.on("activity:new", ...)
             → llega el HISTORIAL COMPLETO             → cada evento nuevo: unshift al array
             → se pinta en el HTML                     → la lista se repinta sola

        ⏱ el PASADO                                ⏱ el FUTURO
```

La clave mental: **son dos fuentes que llenan el mismo array**, en dos momentos y
dos entornos distintos.

- `asyncData` corre en el servidor (o en el cliente al navegar client-side), **no
  tiene `this`**, y devuelve el estado inicial: `{ activity: [...] }`.
- `mounted()` corre **solo en el cliente**, sí tiene `this`, y **añade** encima:
  `this.activity.unshift(evento)`.

Por qué `unshift` y no reasignar: es exactamente la lección de F8. Vue 2 parchea
los métodos mutadores de array, así que `unshift` dispara reactividad; `this.activity[0] = x`
no. Aquí es doblemente importante, porque el array **nació en el servidor** y el
cliente lo está mutando tras la hidratación — si mutas mal, no se repinta y parece
que el socket no llega.

Y el error mortal de la fase: **no vuelvas a pedir el historial en `mounted()`**.
`asyncData` ya lo trajo y ya está pintado. Si `mounted()` hace otro GET del historial
completo, tendrás el clásico doble fetch de SSR: pagas el render en el servidor y lo
tiras a la basura en el cliente. `mounted()` **solo** se suscribe al socket para lo
que llegue **de ahora en adelante**.

## 🧠 Concepto 2: `head()` — lo que SSR le regala a un crawler

En una SPA, el `<head>` que ve el crawler de un buscador (o el bot que genera la
tarjeta de preview cuando pegas un link en Slack) es el `<head>` **vacío** del
`index.html`, porque el JS que lo rellenaría aún no corrió. Por eso las SPAs
sufrieron años con el SEO.

Con SSR, el servidor ejecuta tu `head()` **antes** de mandar el HTML, así que los
meta tags viajan ya puestos. Nuxt expone `head()` como una función del componente
(función, no objeto, para que pueda leer `this` y ser dinámica):

```js
head: function () {
  return {
    title: "Actividad · " + this.ticket.title,
    meta: [
      {
        hid: "description", // hid evita duplicados al fusionar con el head global
        name: "description",
        content: "Historial del ticket #" + this.ticket.id + ": " + this.ticket.title
      }
    ]
  };
}
```

**La demostración de la fase** (hazla, no la creas): levanta Nuxt en modo servidor y

```bash
curl -s http://localhost:3000/tickets/1/activity | grep -i "<title>\|description"
```

Verás el `<title>` y el `<meta name="description">` **con el título real del ticket
dentro del HTML crudo**, sin que el navegador haya ejecutado nada. Eso es
literalmente imposible en el Mini Jira a pelo. Guárdate ese `curl`: es la prueba
tangible de por qué alguien elige pagar el coste de SSR.

## 🧠 Concepto 3: `validate()` — el portero que actúa antes de renderizar

`asyncData` ya sabe manejar un ticket que no existe (llama a `error({ statusCode: 404 })`).
Pero hay una clase de fallo más barata de atajar: la **ruta mal formada**.
`/tickets/abc/activity` no tiene sentido — `abc` no es un id. No hace falta pegarle
a la API para saberlo.

`validate()` corre **antes que `asyncData`, antes de instanciar el componente, antes
de renderizar nada**. Recibe el contexto, devuelve un booleano:

```js
validate: function (context) {
  // solo ids numéricos pasan; cualquier otra cosa → 404 sin tocar la API
  return /^\d+$/.test(context.params.id);
}
```

Si devuelve `false`, Nuxt muestra la página de error con 404 y **jamás corre
`asyncData`**. Es un filtro de forma, no de existencia: valida que la URL tenga
pinta de válida, no que el recurso exista (de eso se encarga `asyncData` con su
`error()`). Los dos juntos cubren las dos preguntas: *¿la URL tiene sentido?*
(`validate`) y *¿el recurso existe?* (`asyncData`).

---

## 💻 Código mínimo

### 1. El modelo nuevo — `db.json`

Añade la colección `activity` (json-server la sirve en `/activity` automáticamente):

```json
{
  "activity": [
    {
      "id": 1,
      "ticketId": 1,
      "type": "status_change",
      "actor": "agente1",
      "from": "open",
      "to": "in_progress",
      "at": "2020-03-10T11:00:00Z"
    },
    {
      "id": 2,
      "ticketId": 1,
      "type": "comment_added",
      "actor": "usuario1",
      "from": null,
      "to": "¿Alguna novedad?",
      "at": "2020-03-10T12:30:00Z"
    }
  ]
}
```

🔎 **Qué hace cada campo:** `type` es el verbo (`status_change`, `assignee_change`,
`comment_added`…); `from`/`to` es el antes/después (en un comentario, `from` es
`null` y `to` es el texto — reutilizamos la forma en vez de inventar un campo por
tipo); `at` es el ISO 8601 que ya usa todo el curso.

💸 **Deuda (la gorda de la fase):** en un sistema real, **nadie escribe a mano en
`activity`**. El historial lo genera el **backend**, con triggers de base de datos o
eventos de dominio: cuando el `UPDATE tickets SET status=...` se confirma, el mismo
backend inserta la fila de `activity` y **emite el socket**. json-server no hace
nada de eso: es un JSON tonto. *"Aquí lo emitimos desde el front al guardar; en
producción llega solo, y el front solo lo pinta. Si algún día ves código de front
que **construye** entradas de historial, es un olor: alguien está haciendo en el
navegador el trabajo del servidor."*

### 2. El servicio — `services/activityService.js`

Idéntico en forma a los servicios del tronco. axios se inyecta desde el plugin de
Nuxt (NX1), pero el servicio no lo sabe ni le importa:

```js
// services/activityService.js
import apiClient from "./apiClient"; // el mismo patrón del tronco

function getByTicket(ticketId) {
  // json-server filtra por query string: /activity?ticketId=1&_sort=at&_order=desc
  return apiClient
    .get("/activity", { params: { ticketId: ticketId, _sort: "at", _order: "desc" } })
    .then(function (res) { return res.data; });
}

export default {
  getByTicket: getByTicket
};
```

🔎 **`_sort` y `_order`** son de json-server, no de tu backend real. En producción
el orden lo decide el `ORDER BY` del servidor; lo dejamos aquí para que el timeline
llegue ya ordenado desde el mock. 💸 (deuda menor, mencionar y seguir).

### 3. La página — `pages/tickets/_id/activity.vue`

Aquí vive **todo el híbrido**. Léela entera antes de escribirla:

```vue
<template>
  <!-- transición de página de Nuxt: el name casa con el CSS de más abajo -->
  <div class="activity-page">
    <h1>Actividad · {{ ticket.title }}</h1>
    <p class="text-muted">Ticket #{{ ticket.id }}</p>

    <!-- indicador en vivo: reutiliza la idea del header de F8 -->
    <span v-if="isLive" class="badge badge-success">🟢 en vivo</span>
    <span v-else class="badge badge-secondary">🔴 histórico</span>

    <!-- maquetado A MANO con Bootstrap (sigue cargado). NO hay componente
         de timeline del framework: Nuxt no es UI. Esto es lo propio de NX4. -->
    <ul class="list-unstyled timeline mt-3">
      <li v-for="ev in activity" :key="ev.id" class="timeline-item">
        <span class="timeline-dot" :class="'dot-' + ev.type"></span>
        <strong>{{ ev.actor }}</strong>
        <span>{{ describir(ev) }}</span>
        <time class="text-muted">{{ formatear(ev.at) }}</time>
      </li>
    </ul>
  </div>
</template>

<script>
import activityService from "@/services/activityService";
import ticketService from "@/services/ticketService";
import socketService from "@/services/socketService";

export default {
  // ── 1. PORTERO: corre antes que nada. Rechaza ids no numéricos sin tocar la API.
  validate: function (context) {
    return /^\d+$/.test(context.params.id);
  },

  // ── 2. SERVIDOR: el PASADO. Corre en Node, sin `this`, antes de renderizar.
  async asyncData(context) {
    var id = context.params.id;
    try {
      // dos llamadas en paralelo: el ticket (para el título/head) y su historial
      var results = await Promise.all([
        ticketService.getById(id),
        activityService.getByTicket(id)
      ]);
      return {
        ticket: results[0],
        activity: results[1] // ← el array llega YA lleno y se pinta en el HTML
      };
    } catch (e) {
      // el recurso no existe → 404 renderizado en el servidor
      context.error({ statusCode: 404, message: "Ticket no encontrado" });
    }
  },

  // `data` solo declara lo que NO viene del servidor: el estado de conexión.
  // `ticket` y `activity` los inyecta asyncData y se fusionan aquí.
  data: function () {
    return {
      isLive: false
    };
  },

  // ── 3. head DINÁMICO: corre en el servidor, viaja en el HTML. SEO/preview.
  head: function () {
    return {
      title: "Actividad · " + this.ticket.title,
      meta: [
        {
          hid: "description",
          name: "description",
          content: "Historial del ticket #" + this.ticket.id + ": " + this.ticket.title
        }
      ]
    };
  },

  // ── 4. CLIENTE: el FUTURO. Solo aquí, solo tras hidratar. Toca el socket.
  mounted: function () {
    // ❗ NO re-fetcheamos el historial: asyncData ya lo trajo y ya está pintado.
    // mounted SOLO se suscribe a lo que llegue DE AHORA EN ADELANTE.
    socketService.on("activity:new", this.onNuevaActividad);
    this.isLive = socketService.isConnected();
  },

  // baja simétrica: todo lo que se suscribe, se desuscribe (regla de F8).
  beforeDestroy: function () {
    socketService.off("activity:new", this.onNuevaActividad);
  },

  methods: {
    onNuevaActividad: function (ev) {
      // solo eventos de ESTE ticket (el socket difunde los de todos)
      if (String(ev.ticketId) !== String(this.ticket.id)) return;
      // unshift = reactivo en Vue 2 (F8). Reasignar por índice NO lo sería.
      this.activity.unshift(ev);
    },
    describir: function (ev) {
      if (ev.type === "status_change") return "cambió el estado de " + ev.from + " a " + ev.to;
      if (ev.type === "assignee_change") return "reasignó a " + ev.to;
      if (ev.type === "comment_added") return "comentó: " + ev.to;
      return ev.type;
    },
    formatear: function (iso) {
      return new Date(iso).toLocaleString();
    }
  }
};
</script>

<style scoped>
/* transición de página de Nuxt: nombra la transición en nuxt.config.js
   (pageTransition: 'fade') o por página con `transition: 'fade'` en el
   export. Estas clases las aplica Nuxt solo. */
.fade-enter-active, .fade-leave-active { transition: opacity 0.25s; }
.fade-enter, .fade-leave-to { opacity: 0; }

.timeline-item { padding: 0.5rem 0 0.5rem 1.5rem; border-left: 2px solid #dee2e6; position: relative; }
.timeline-dot { position: absolute; left: -6px; width: 10px; height: 10px; border-radius: 50%; background: #6c757d; }
.dot-status_change { background: #ffc107; }
.dot-comment_added { background: #17a2b8; }
</style>
```

🔎 **El `formatear` con `toLocaleString()` es una trampa de hidratación esperando a
pasar** — el servidor (Node, zona horaria del servidor, locale del servidor) y el
cliente (navegador, otra zona, otro locale) pueden formatear la **misma** fecha
distinto, y ahí tienes un mismatch de hidratación silencioso (NX2). En el ejercicio
9 lo provocas y lo arreglas. Por ahora, funciona "de milagro" si tu servidor y tu
navegador comparten locale — que es justo cómo se cuelan estos bugs en local y
explotan en producción.

### 4. Emitir el evento al guardar (el lado que falsea la deuda)

En producción esto **no existe en el front**. Pero como json-server no genera
historial, lo emitimos nosotros al cambiar un estado (p. ej. en la vista de detalle
o en el panel de soporte de F9):

```js
// al confirmar un cambio de estado del ticket:
var evento = {
  id: Date.now(),          // 💸 id de mentira; el backend real daría uno de verdad
  ticketId: this.ticket.id,
  type: "status_change",
  actor: this.usuarioActual.username,
  from: estadoAnterior,
  to: nuevoEstado,
  at: new Date().toISOString()
};
socketService.emit("activity:new", evento); // el server lo rebota (broadcast, F8)
```

Y una línea en el server socket de F8 para rebotarlo (mismo patrón que
`ticket:created`):

```js
socket.on("activity:new", function (ev) {
  socket.broadcast.emit("activity:new", ev); // a todos menos al emisor
});
```

💸 **La costura que estás viendo es la deuda hecha código:** el front está
*construyendo* la entrada de historial (`Date.now()` como id, `new Date()` como
timestamp). Eso es trabajo del servidor. Escríbelo en un comentario `// 💸 esto lo
hace el backend en prod` para que el que mantenga esto en 3 años sepa que es un
andamio, no arquitectura.

---

## ⚠️ Errores comunes

- **Re-fetchear el historial en `mounted()`.** El pecado capital de la fase: pagas
  el render en el servidor y lo tiras. `asyncData` trae el pasado; `mounted()` solo
  escucha el futuro. Si ves un GET del historial completo en `mounted`, bórralo.
- **Suscribir el socket en `asyncData` o `created()`.** `asyncData` y `created()`
  corren **también en el servidor**, donde no hay socket ni `window`. El socket va
  en `mounted()`, punto. (Es NX2 otra vez: lo que toca red viva o el navegador vive
  en `mounted`.)
- **`this.activity[0] = ev` en el handler del socket.** No es reactivo (F8). El
  evento "llega" pero la lista no se repinta, y jurarás que el socket está roto.
  `unshift`.
- **`head` como objeto en vez de función.** Si lo escribes `head: { title: ... }`
  no puede leer `this.ticket` y peta o sale vacío. Debe ser `head: function () { return {...} }`.
- **Olvidar `hid` en los meta.** Sin `hid`, Nuxt no puede deduplicar y acabas con
  dos `<meta name="description">` (el global y el tuyo). Buscador confundido.
- **Validar existencia en `validate()`.** `validate` es para la **forma** de la URL,
  no para pegarle a la API. Si metes un `await fetch` ahí para ver si el ticket
  existe, estás duplicando lo que `asyncData` ya hace con `error()`. Deja a cada uno
  su trabajo.
- **`toLocaleString()` / `Date.now()` / `Math.random()` en el template o en data
  compartida.** Servidor y cliente producen valores distintos → hidratación rota
  (NX2). Formatea de forma determinista o hazlo en `mounted`.
- **Suscribir sin `beforeDestroy`.** Zombis de F8: navegas dentro/fuera del timeline
  y acumulas handlers. Alta y baja simétricas, con la **misma referencia**
  (`this.onNuevaActividad`, no una arrow inline distinta en cada lado).

---

## 🧪 Ejercicios (28)

### 🟢 Fácil (1–8)

1. Levanta la página y hazle `curl -s http://localhost:3000/tickets/1/activity | grep -i title`.
   Pega la salida. Confirma que el `<title>` con el nombre del ticket **viaja en el
   HTML del servidor**. Ahora hazlo contra el Mini Jira a pelo (`vue-cli-service serve`)
   y compara: ¿qué `<title>` sale ahí?
2. Añade tres entradas más a `activity` en `db.json` (un `assignee_change`, dos
   `comment_added`) y verifica que aparecen ordenadas por fecha descendente sin
   tocar el componente (lo ordena `_sort`/`_order` del servicio).
3. Cambia el `describir()` para que `assignee_change` diga "asignó el ticket a X".
4. Pinta el `type` con un color de punto distinto por cada tipo (ya hay dos en el
   CSS; añade `assignee_change`).
5. Visita `/tickets/999/activity` (id que no existe). Documenta qué ves y **de dónde
   sale el 404**: ¿de `validate` o de `asyncData`? Justifícalo.
6. Visita `/tickets/abc/activity`. Documenta qué ves y de dónde sale el 404 **esta
   vez**. Explica la diferencia con el ejercicio 5 en una frase.
7. Añade un `<meta property="og:title">` al `head()` para la preview de Slack/redes.
   Verifícalo con `curl`.
8. Añade el enlace "Ver actividad" en la vista de detalle del ticket, apuntando a la
   ruta anidada. Confirma que navegar **dentro de la app** (client-side) no dispara
   `curl`-visible SSR, pero recargar (F5) sí.

### 🟡 Intermedio (9–18)

9. **El bug de hidratación de la fecha.** Cambia el locale de tu navegador (o usa
   `toLocaleString('en-US')` en el template) y observa el warning de hidratación en
   consola. Arréglalo: formatea la fecha de forma determinista (mismo output en
   servidor y cliente) — por ejemplo, un helper que produzca `YYYY-MM-DD HH:mm` fijo,
   o formatea en `mounted`. Explica por qué tu arreglo elimina el mismatch.
10. Muestra un contador "N eventos" en el `<h1>` que se actualice al llegar eventos
    en vivo. ¿En qué momento nace ese número — servidor o cliente? Justifícalo.
11. Filtra el timeline por tipo con botones (Todos / Cambios de estado / Comentarios).
    ¿El filtro vive en el cliente o le pides al servidor `?type=...`? Elige y defiende
    en 3 líneas (pista: piensa en el `curl` y el SEO).
12. Haz que el indicador 🟢/🔴 reaccione de verdad a `connect`/`disconnect` del socket
    (como el ejercicio 9 de F8), en vez de leer `isConnected()` una sola vez en
    `mounted`.
13. Añade una transición de página `fade` global en `nuxt.config.js` y compárala con
    declararla por-página con `transition: 'fade'` en el export del componente.
    ¿Cuándo querrías una distinta solo para esta ruta?
14. `head()` con `titleTemplate`: que todas las páginas terminen en " · Mini Jira"
    salvo que la página diga lo contrario. Muévelo al layout y deja que `activity.vue`
    lo herede.
15. Cuando llega un evento en vivo, resáltalo (animación de fondo que se desvanece)
    para que el usuario note qué es nuevo. Cuida que la animación NO cause mismatch
    de hidratación (¿por qué no lo causaría, si solo corre en cliente?).
16. Extrae la lista del timeline a un componente `<ActivityTimeline :items="activity">`.
    Ojo: `asyncData` y `head` **solo funcionan en páginas**, no en componentes. ¿Qué
    se queda en la página y qué baja al componente? Dibuja la frontera.
17. Añade `assignee_change` al flujo de emisión: cuando en el panel de F9 reasignes
    un ticket, emite el evento y velo aparecer en vivo en el timeline de otra pestaña.
18. Mide el TTFB (time to first byte) de la página SSR con `curl -w "%{time_starttransfer}"`
    y compáralo con el mismo dato del Mini Jira a pelo (que manda cascarón vacío y
    luego fetchea). Interpreta: ¿quién muestra contenido antes, y a costa de qué en
    el servidor?

### 🟠 Difícil (19–24)

19. **Historial largo.** Un ticket con 300 eventos manda un HTML gigante desde el
    servidor. Pagina: `asyncData` trae los últimos 20 (`_limit=20`), y un botón
    "cargar más antiguos" trae el resto **desde el cliente** (fetch normal, no
    asyncData). Piensa el orden: los viejos van abajo, los nuevos en vivo arriba —
    ¿cómo evitas duplicar el evento que ya tenías si el socket lo reenvía mientras
    paginabas?
20. **Reconexión y huecos.** Mientras el usuario tenía la pestaña abierta pero el
    socket caído, pasaron 3 cambios de estado. Al reconectar (evento `connect` tras
    una desconexión, como el ejercicio 23 de F8), **re-pide el historial** desde el
    cliente y **fusiónalo** con lo que ya tenías sin duplicar. ¿Por qué aquí sí
    re-fetcheas, si en `mounted` estaba prohibido?
21. **Deduplicación honesta.** Los ids que emites desde el front (`Date.now()`)
    pueden colisionar si dos usuarios emiten en el mismo milisegundo. Detéctalo:
    ¿qué pasa con `:key="ev.id"` si hay dos iguales? Propón una clave estable que no
    dependa del backend (que no tienes).
22. **`fetch()` vs `asyncData` para esto.** Reescribe la carga usando `fetch()` (que
    llena el store) en vez de `asyncData` (que llena `data`). Conecta con NX3: ¿el
    timeline pertenece al store global o es estado local de la página? Defiéndelo por
    escrito — el timeline de un ticket concreto no es como la lista de tickets.
23. **El cliente mentiroso, versión historial.** Desde la consola, emite a mano
    `socket.emit("activity:new", {ticketId:1, type:"status_change", to:"closed", actor:"HACKER"})`.
    Aparece en el timeline de las otras pestañas un cierre que **nunca pasó en la
    base**. Es el ejercicio 24 de F8 aplicado aquí. Mitígalo (¿verificar contra
    `GET /activity/:id`? ¿O el evento es tan efímero que no vale la pena?) y anota la
    decisión — no toda mitigación de F8 traslada 1:1.
24. **Meta social real.** Añade `og:title`, `og:description` y `twitter:card` con
    datos del ticket, y verifica con una herramienta de preview (o `curl` +
    inspección) que un bot vería la info correcta **sin ejecutar JS**. Escribe dos
    frases sobre por qué esto era imposible en el Mini Jira a pelo.

### 🔴 Muy difícil (25–28)

25. **[OBLIGATORIO] El wizard (F6) en Nuxt: ¿rutas o componente?** Nuxt te **empuja**
    a convertir cada paso en una ruta (`pages/nuevo/paso-1.vue`, `paso-2.vue`,
    `paso-3.vue`), porque en Nuxt `pages/` **es** el router y crear rutas es gratis.
    En F6 defendiste que el wizard fuera **un componente con estado local** (el
    borrador vive en el componente, no en el store, no en la URL). Ahora Nuxt te
    tienta con lo contrario. **Decide y defiende por escrito**, respondiendo:
    - Si cada paso es una ruta, **¿dónde vive el borrador entre pasos?** (spoiler:
      ya no en el componente — cada ruta monta y desmonta el suyo). ¿Store? ¿Query
      string? ¿Cada opción qué te cuesta?
    - **El botón "atrás" del navegador**: con rutas, "atrás" te saca del paso 2 al
      paso 1 (¿bien?), o del wizard entero a la página anterior (¿mal?). Con
      componente, "atrás" te saca del wizard de golpe. ¿Cuál es el comportamiento
      que el usuario espera de un formulario de alta?
    - **SSR del borrador**: si el paso 2 es una ruta y el usuario recarga en el paso
      2, ¿qué renderiza el servidor? ¿Un formulario a medio llenar que el servidor no
      conoce? ¿Rediriges al paso 1?
    - Cierra enlazando **explícitamente** con la decisión que defendiste en F6:
      ¿Nuxt cambia tu respuesta o la confirma? "Nuxt lo hace fácil" no es "Nuxt tiene
      razón". Un párrafo de veredicto.
26. **Optimistic timeline.** Cuando *tú* cambias el estado, no esperes al rebote del
    socket: pinta el evento inmediatamente (optimista) y reconcília cuando/ si vuelve
    por el socket. Maneja el caso en que el emit falla (socket caído): ¿revertir?
    ¿marcar "pendiente"? Diseña la máquina de estados del evento optimista (pending →
    confirmed / failed) y dibújala en ASCII.
27. **Streaming del pasado + presente sin costura visible.** Objetivo: que el usuario
    **nunca** vea un salto entre "lo que vino del servidor" y "lo que llega en vivo".
    Audita tu página: ¿hay algún instante entre la hidratación y el `mounted` en que
    un evento en vivo podría perderse (llega al socket antes de que te suscribas)?
    Diseña la defensa (¿buffer en el servicio? ¿re-sync al suscribir?). Este es el
    hueco de carrera que separa un timeline de juguete de uno de producción.
28. **La deuda, saldada de mentira pero bien documentada.** Escribe
    `ACTIVITY-BACKEND.md`: describe cómo generaría el historial un backend real
    (trigger de BD vs evento de dominio en la capa de aplicación), quién emitiría el
    socket (el backend, no el front), y **qué código de tu front hay que borrar** el
    día que ese backend exista (la construcción de eventos con `Date.now()`, el
    `socket.emit` desde el cliente, el rebote en el server de F8). El objetivo: que
    el que herede esto sepa **exactamente qué es andamio y qué es edificio**.

---

## 📚 Referencias

**Documentación oficial (Nuxt 2 — ojo al dominio)**

- Nuxt 2 — `asyncData`: https://v2.nuxt.com/docs/features/data-fetching/
- Nuxt 2 — `head()` / meta tags: https://v2.nuxt.com/docs/components-glossary/head/
- Nuxt 2 — `validate()`: https://v2.nuxt.com/docs/components-glossary/validate/
- Nuxt 2 — rutas anidadas y dinámicas: https://v2.nuxt.com/docs/features/file-system-routing/
- Nuxt 2 — transiciones de página: https://v2.nuxt.com/docs/features/transitions/
- Nuxt 2 — el contexto: https://v2.nuxt.com/docs/internals-glossary/context/

> ⚠️ **`v2.nuxt.com`, no `nuxt.com`.** El dominio raíz sirve documentación de Nuxt
> 3 (Vue 3), que no es tu framework. Si un ejemplo usa `<script setup>`, `useAsyncData`
> o Composition API, estás en la doc equivocada.

**Del propio curso (repaso obligado antes de esta fase)**

- F8 — WebSockets: el `socketService` (`on`/`off`/`emit`), la regla de los dos
  ciclos de vida, `unshift` reactivo. Todo eso se reusa tal cual aquí.
- NX2 — hidratación, `mounted` vs `created`, `<client-only>`, mismatch de fechas.
- NX3 — `asyncData`, el contexto sin `this`, `error()`, `fetch` vs `asyncData`.

**Apoyo**

- Vue 2 — reactividad de arreglos (por qué `unshift` sí y el índice no):
  https://v2.vuejs.org/v2/guide/list.html#Mutation-Methods
- MDN — `curl` no, pero sí para entender el head social: Open Graph protocol,
  https://ogp.me/

**Orden de lectura sugerido:** relee el Concepto 1 de esta fase → doc de `asyncData`
de Nuxt 2 (ya la viste en NX3) → doc de `head()` → escribe la página → haz el `curl`
del ejercicio 1 **antes** de seguir (es la prueba de que entendiste SSR).

---

## 🚀 Cierre

El timeline es la primera cosa de toda la ruta NX que **no existía**. No tradujiste
un `QTable`, no reescribiste un formulario: construiste una página que hace algo que
el Mini Jira a pelo **no podía hacer** — mandar HTML lleno desde el servidor, con
sus meta tags puestos para un crawler, y luego seguir viva por socket en el cliente.

Te llevas:

- el **híbrido** SSR + tiempo real como patrón: `asyncData` pinta el pasado en el
  servidor, `mounted` escucha el futuro en el cliente, **y no se pisan**;
- `head()` dinámico y la prueba de `curl` de por qué SSR le gana a la SPA en SEO y
  previews;
- `validate()` como portero de forma, complementario al `error()` de existencia;
- y la conciencia, ya afilada, de qué mitad de tu código es **andamio que el backend
  real borraría** (la deuda del historial) y qué mitad es edificio.

**Y aquí termina la ruta NX** — y termina distinto a Quasar y Vuetify, a propósito.
En Q y VU el proyecto final es un **híbrido de UI**: media app en Bootstrap, media
en el framework, conviviendo. Cambiaste de **vocabulario** — aprendiste a decir
`QTable` donde antes escribías `<table>`.

Aquí no. El proyecto final de NX es un **Mini Jira reconstruido sobre otro modelo de
ejecución**. El vocabulario es el mismo — sigues escribiendo Options API, `function () {}`,
Vuex, componentes `.vue` — pero **cambió de cabeza**: tu código ya no corre solo en
un navegador, corre primero en un Node sin `window` y luego se hidrata en el cliente,
y tú sabes exactamente qué parte pasa dónde y por qué.

La señal de que quedó bien:

> "me sueltan en una app Nuxt 2 en producción, veo un `asyncData` y un `mounted` en
> la misma página, y sé sin dudar cuál corre en el servidor, cuál en el cliente, cuál
> puede tocar `window` y cuál rompería la hidratación si lo hiciera. Y cuando algo
> pinta distinto entre el HTML crudo y lo que veo en pantalla, sé que la palabra que
> estoy buscando es *hidratación*."
