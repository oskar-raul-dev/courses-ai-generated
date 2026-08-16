# 💬 Fase 8 — WebSockets mínimos

## 🎯 Propósito

Hasta hoy, el Mini Jira solo se entera de las cosas cuando pregunta: cada GET
es un "¿hay algo nuevo?". En esta fase el servidor gana voz propia: montamos
un **mini servidor socket.io de ~30 líneas** y el dashboard se entera de los
tickets nuevos **en vivo**, sin recargar nada.

Prueba estrella de la fase: dos pestañas del navegador abiertas; creas un
ticket en una, y en la otra aparece solo, con notificación incluida. 🪄

Lo que realmente se aprende:

- qué es un WebSocket y por qué mata al polling (adiós, `setInterval` del
  ejercicio 26 de la Fase 4);
- **socket.io 2.x**: el estándar de facto de la época, con su modelo de
  eventos `emit`/`on`/`broadcast`;
- **dos ciclos de vida distintos que no hay que confundir**: el socket vive
  lo que la *sesión*; cada listener vive lo que su *componente*;
- todo lo de la Fase 7, reaplicado: el socket es otra instancia imperativa
  que va **fuera de `data`** y se limpia religiosamente.

> La regla de la fase: conectar es asunto de la sesión;
> escuchar es asunto de cada componente. Y todo lo que se suscribe, se
> desuscribe.

---

## ✅ Qué queda listo al terminar

- servidor socket.io corriendo en `localhost:4000` (script `npm run sockets`);
- `socketService.js`: singleton que encapsula conectar, desconectar, emitir y
  escuchar;
- conexión ligada a la sesión: se abre al login, se cierra al logout;
- al crear un ticket (formulario o wizard), las **demás** pestañas/usuarios:
  - ven una notificación toast con el título del ticket,
  - y si están en el dashboard, la fila aparece en la tabla al instante;
- indicador "🟢 en vivo / 🔴 sin conexión" en el header;
- listeners con alta y baja simétricas (mounted/beforeDestroy).

## 🚫 Qué NO entra todavía

- reconexión robusta con backoff configurado a mano (socket.io trae una
  default; afinarla es ejercicio 🟠);
- salas/rooms por agente o por ticket (ejercicio 🟠);
- autenticación del socket (el server acepta a cualquiera — ejercicio 🔴);
- sincronización total (updates/deletes en vivo — ejercicios);
- escalar más allá de un proceso (Redis adapter y compañía: fuera de alcance).

---

## 🧠 Concepto 1: polling vs WebSocket

| | 🔁 Polling (`setInterval` + GET) | 🔌 WebSocket |
|---|---|---|
| Modelo | el cliente pregunta cada N segundos | conexión persistente; el servidor **empuja** |
| Latencia de la noticia | hasta N segundos | milisegundos |
| Costo con nada nuevo | un request completo (headers, handshake TLS…) cada N seg, casi siempre para un "no" | prácticamente cero: la conexión duerme |
| Costo servidor con 500 usuarios | 500 × requests/min aunque no pase nada | 500 conexiones abiertas, tráfico solo al haber eventos |
| Complejidad | trivial | conexión, reconexión, estado, limpieza |
| Atraviesa proxies viejos | siempre | casi siempre (y para eso existe socket.io 👇) |
| Típico en legacy | dashboards internos "que se refresquen solos" | chats, notificaciones, colaboración |

El polling no es pecado — para un dashboard interno con 10 usuarios y datos
que cambian cada hora, es la solución honesta. Se vuelve pecado cuando la
frecuencia sube y la escala también: 500 usuarios × 1 GET cada 5s = 6.000
requests/minuto para descubrir que no pasó nada.

## 🧠 Concepto 2: ¿por qué socket.io y no WebSocket a pelo?

El navegador trae `new WebSocket(url)` nativo. socket.io (2018–2021,
versión 2.x) se impuso encima por lo que regala:

- **fallbacks automáticos**: si el WebSocket no puede establecerse (proxies
  corporativos hostiles, muy relevante en la época), degrada a long-polling
  sin que tu código se entere;
- **reconexión automática** con reintentos y backoff de fábrica;
- **eventos con nombre**: `socket.on("ticket:created", cb)` en vez de
  parsear a mano todo por un único `onmessage`;
- **broadcast y rooms**: reenviar a todos-menos-uno o a grupos, en una línea.

El costo: cliente y servidor deben hablar socket.io (no es WebSocket puro
interoperable), y **la versión de cliente y servidor deben ser compatibles**
— mezclar cliente 2.x con servidor 3.x/4.x produce errores crípticos de
handshake. En legacy, revisar esas dos versiones es el primer paso de
cualquier bug de sockets.

### El modelo mental de eventos

```
cliente A                    servidor                     cliente B
   │                            │                            │
   │── emit("ticket:created") ─→│                            │
   │                            │── broadcast.emit(...) ────→│  (a todos MENOS A)
   │                            │                            │── on("ticket:created", cb)
```

Tres verbos y ya:

- `socket.emit(evento, payload)` → enviar al otro lado;
- `socket.on(evento, cb)` → escuchar;
- en el server, `socket.broadcast.emit(...)` → reenviar a todos menos al
  emisor (vs `io.emit(...)`: a todos, emisor incluido).

---

## 🧩 Mini repaso: los `.vue` de esta fase (lo nuevo respecto a la Fase 7)

### `watch` con `immediate: true`

Un watch normal solo dispara **cuando el valor cambia**. Con `immediate`,
dispara también **al crearse el componente**, con el valor actual:

```js
watch: {
  isAuthenticated: {
    immediate: true, // evalúa YA al montar, no solo en futuros cambios
    handler: function (isAuth) {
      if (isAuth) socketService.connect();
      else socketService.disconnect();
    }
  }
}
```

Sin `immediate`, el usuario que **recarga la página ya logueado** nunca
conectaría el socket: `isAuthenticated` arranca en `true` y jamás "cambia".
Es el modificador exacto para "reacciona a los cambios *y* al estado
inicial" — y su ausencia es un bug legacy clásico de los difíciles de ver.

### Los métodos de arreglo SÍ son reactivos (alivio de la Fase 4)

En la Fase 4 asustamos con los límites de la reactividad: asignar por índice
(`this.tickets[3] = t`) no es reactivo. La otra mitad de la historia: Vue 2
**parchea** los 7 métodos mutadores de Array — `push`, `pop`, `shift`,
`unshift`, `splice`, `sort`, `reverse` — para que sí disparen reactividad.

```js
this.tickets.unshift(newTicket); // ✅ la tabla se repinta sola
this.tickets[0] = newTicket;     // ❌ Vue ni se entera
```

Por eso el handler del socket hará `unshift` con toda confianza.

### El event bus — fauna legacy que DEBES reconocer

En apps Vue 2 de la época verás por todas partes este patrón para comunicar
componentes lejanos:

```js
// eventBus.js
import Vue from "vue";
export default new Vue(); // una instancia Vue vacía usada solo como bus

// emisor:               bus.$emit("algo", payload);
// receptor (mounted):   bus.$on("algo", this.handler);
// receptor (beforeDestroy): bus.$off("algo", this.handler);
```

Funciona porque toda instancia Vue trae `$emit/$on/$off`. Y degenera
igual de rápido: eventos volando sin rastro de quién emite ni quién escucha
("event soup"). Nuestro `socketService` expone `on/off` con la misma forma
deliberadamente — el patrón de suscripción es idéntico, pero acotado a
eventos del servidor. En el ejercicio 20 harás un bus y sentirás ambos lados.
Dato de época: `$on/$off` entre componentes **también murió en Vue 3**.

### Módulos ES como singletons

```js
// socketService.js
var socket = null; // ← variable a nivel de MÓDULO
```

Los módulos ES se evalúan **una sola vez**: no importa cuántos archivos hagan
`import socketService`, todos comparten ese mismo `socket`. Es el singleton
más barato de JavaScript, y es exactamente lo que ya venía pasando con
`apiClient` desde la Fase 2 — solo que ahora lo nombramos. Un socket por
sesión, no uno por componente: el módulo lo garantiza gratis.

---

## 💻 Código de la fase

### Instalación (¡versiones emparejadas!)

```bash
npm install socket.io-client@2.4.0
npm install --save-dev socket.io@2.4.1
```

### 1. El servidor: `server/socket-server.js` (las 30 líneas prometidas)

```js
// Mini servidor de eventos. NO toca la base de datos:
// solo repite lo que un cliente anuncia hacia los demás. Un megáfono. 📣
var http = require("http");
var socketIo = require("socket.io");

var server = http.createServer();
var io = socketIo(server, {
  origins: "*:*" // CORS estilo socket.io 2.x (en 3.x/4.x cambió a `cors: {}`)
});

io.on("connection", function (socket) {
  console.log("🟢 cliente conectado:", socket.id);

  socket.on("ticket:created", function (ticket) {
    console.log("📨 ticket:created →", ticket.id, ticket.title);
    // a todos MENOS quien lo creó (él ya lo sabe: acaba de hacer el POST)
    socket.broadcast.emit("ticket:created", ticket);
  });

  socket.on("disconnect", function () {
    console.log("🔴 cliente desconectado:", socket.id);
  });
});

server.listen(4000, function () {
  console.log("Socket server escuchando en http://localhost:4000");
});
```

Decisión de diseño que hay que decir en voz alta: **el servidor es un relé
tonto**. El ticket ya se persistió por HTTP (json-server); el socket solo
difunde la noticia. En un backend real, el propio servidor emitiría el evento
al confirmar el INSERT — aquí lo emite el cliente que creó, y el server lo
rebota. Es la simulación honesta con el mínimo de piezas. (El ejercicio 24
explora qué pasa cuando el cliente-anunciante miente.)

**✅ Buenas prácticas del lado servidor (aunque sea de juguete):**
- Los `console.log` de connect/disconnect/eventos no son ruido: son la
  **observabilidad mínima** de un sistema de sockets. Cuando "no llega el
  evento", la primera pregunta es ¿llegó al server? — y estos logs la
  responden en un vistazo.
- El nombre del evento usa la convención `recurso:acción`
  (`ticket:created`): con 2 eventos da igual, con 20 es la diferencia entre
  un catálogo y una sopa. Definir la convención en el evento UNO es gratis;
  renombrar 20 después no.
- El server no interpreta el payload: lo rebota tal cual. Un relé que empieza
  a "arreglar" datos se convierte en un segundo backend sin dueño — si hay
  lógica que aplicar, pertenece al backend de datos, no al megáfono.

Script en `package.json` — y ya son tres terminales, así que el `concurrently`
del ejercicio 15 de la Fase 3 pasa de opcional a recomendado:

```json
{
  "scripts": {
    "serve": "vue-cli-service serve",
    "mock": "json-server --watch db.json --port 3000",
    "sockets": "node server/socket-server.js",
    "dev": "concurrently \"npm run mock\" \"npm run sockets\" \"npm run serve\""
  }
}
```

### 2. `services/socketService.js` — el singleton del cliente

```js
import io from "socket.io-client";

var SOCKET_URL = "http://localhost:4000";
var socket = null; // singleton a nivel de módulo

function connect() {
  if (socket) return; // idempotente: llamar dos veces no abre dos sockets
  socket = io(SOCKET_URL);
}

function disconnect() {
  if (!socket) return;
  socket.disconnect();
  socket = null;
}

function on(event, callback) {
  if (socket) socket.on(event, callback);
}

function off(event, callback) {
  if (socket) socket.off(event, callback);
}

function emit(event, payload) {
  if (socket) socket.emit(event, payload);
}

function isConnected() {
  return !!(socket && socket.connected);
}

export default {
  connect: connect,
  disconnect: disconnect,
  on: on,
  off: off,
  emit: emit,
  isConnected: isConnected
};
```

**🔎 Qué hace, función por función:**

| Función | Su trabajo |
|---|---|
| `connect()` | crea el socket **si no existe** — llamarla dos veces (login + immediate, o doble render) no abre dos conexiones |
| `disconnect()` | cierra y **anula** la referencia: el próximo login parte de cero, sin socket a medio morir |
| `on/off` | pasan derecho al socket, con guard — son la superficie que usan los componentes |
| `emit` | envía si hay conexión; si no, silencia (decisión discutible a propósito: el ejercicio 21 la revisa) |
| `isConnected()` | estado consultable sin exponer el socket crudo |

Mismo rol que `apiClient` para HTTP: **nadie más en la app importa
socket.io-client**. El día que cambie la URL, la librería o haya que meter
auth en el handshake, se toca un archivo.

**✅ Buenas prácticas aplicadas:**
- **Idempotencia en las operaciones de ciclo de vida** (`connect` con guard,
  `disconnect` con guard): el código que gestiona recursos externos debe
  tolerar llamadas repetidas, porque en una SPA con watchers, guards y
  recargas, las llamadas repetidas OCURREN. Diseñar para "me van a llamar dos
  veces" ahorra una familia entera de bugs.
- El servicio expone **verbos del dominio de eventos** (on/off/emit), no el
  objeto socket. Si expusiera `getSocket()`, en seis meses habría
  `socket.io`-ismos regados por veinte componentes y cambiar de librería
  sería reescribir la app. Encapsular = poder cambiar de opinión barato.
- `socket = null` tras desconectar no es cosmético: una referencia colgante a
  un socket cerrado hace que `isConnected()` mienta y que los guards de
  `on/emit` registren cosas sobre un muerto.

### 3. Conexión ligada a la sesión: `App.vue`

```js
// agregar al export default de App.vue
import socketService from "./services/socketService";

computed: {
  showLayout: function () {
    return this.$route.path !== "/login";
  },
  isAuthenticated: function () {
    return this.$store.getters["auth/isAuthenticated"];
  }
},
watch: {
  isAuthenticated: {
    immediate: true, // cubre la recarga con sesión ya activa
    handler: function (isAuth) {
      if (isAuth) {
        socketService.connect();
      } else {
        socketService.disconnect();
      }
    }
  }
}
```

Login → el getter cambia a `true` → conecta. Logout → `false` → desconecta.
Recarga con sesión → `immediate` conecta. Un solo lugar decide la vida del
socket, y es el mismo lugar que ya decidía el layout: la raíz.

**✅ Por qué este diseño y no otro:**
- El watch reacciona al **getter del store**, no a los eventos de
  login/logout directamente: da igual CÓMO cambie la sesión (login normal,
  logout, un futuro 401 que limpie sesión, otra pestaña) — si el estado dice
  "sin sesión", el socket se cierra. Reaccionar al estado en vez de a las
  acciones cubre caminos que aún no existen.
- La alternativa (conectar dentro de las actions `login`/`logout` del store)
  también se ve mucho en legacy y funciona — pero acopla el store de auth a
  la infraestructura de sockets. El ejercicio 17 te hace probar ambas y
  elegir con argumentos.
- `App.vue` es el único componente que **jamás se desmonta** mientras la app
  vive: por eso es el hogar natural de recursos con vida de sesión. Poner
  este watch en cualquier vista sería atar el socket a una pantalla.

### 4. El toast global: `components/common/LiveToast.vue`

```vue
<template>
  <div
    v-if="visible"
    class="position-fixed"
    style="bottom: 20px; right: 20px; z-index: 1050; min-width: 300px;"
  >
    <div class="card shadow border-primary" style="cursor: pointer;" @click="go">
      <div class="card-body py-2 px-3">
        <strong>🎫 Nuevo ticket #{{ ticket.id }}</strong>
        <div class="small text-muted">{{ ticket.title }}</div>
      </div>
    </div>
  </div>
</template>

<script>
import socketService from "../../services/socketService";

export default {
  name: "LiveToast",
  data: function () {
    return { ticket: null, visible: false };
  },
  mounted: function () {
    // guardamos la referencia enlazada para poder darla de baja idéntica
    this.handler = this.onTicketCreated.bind(this);
    socketService.on("ticket:created", this.handler);
  },
  beforeDestroy: function () {
    socketService.off("ticket:created", this.handler);
    clearTimeout(this.timer);
  },
  methods: {
    onTicketCreated: function (ticket) {
      this.ticket = ticket;
      this.visible = true;
      clearTimeout(this.timer);
      this.timer = setTimeout(this.hide.bind(this), 5000); // timer NO reactivo
    },
    hide: function () {
      this.visible = false;
    },
    go: function () {
      this.hide();
      this.$router.push("/tickets/" + this.ticket.id);
    }
  }
};
</script>
```

Y en el template de `App.vue`, dentro del bloque con layout:

```vue
<live-toast />
```

**🔎 Qué hace, paso a paso:**

1. Al montar, se suscribe a `ticket:created` — pero antes guarda en
   `this.handler` la versión enlazada (`bind(this)`) del método.
2. Cuando llega un evento: guarda el ticket, se hace visible, y **reinicia**
   el temporizador de auto-ocultado (`clearTimeout` + `setTimeout`): si
   llegan dos tickets seguidos, el toast muestra el último y el reloj parte
   de cero, en vez de ocultarse a mitad del segundo.
3. Clic en el toast → oculta y navega al detalle.
4. Al destruirse: baja del evento con **la misma referencia** y mata el timer
   pendiente (un `setTimeout` huérfano ejecutando `hide()` sobre un
   componente muerto es un error de consola gratis).

Nota el detalle del `bind(this)` guardado en `this.handler`: para que
`off` funcione, hay que darle **exactamente la misma referencia de función**
que se le dio a `on`. Un `.bind()` nuevo en cada llamada crea funciones
distintas y el `off` no da de baja nada — el origen del 80% de los listeners
zombis en legacy.

**✅ Buenas prácticas aplicadas:**
- `this.handler` y `this.timer` son propiedades **no reactivas** (asignadas
  fuera de `data`) — correcto por partida doble: no se pintan en el template,
  y una función/ID de timer no tiene nada que observar. La lección de la
  Fase 7, aplicada a cosas pequeñas: no todo lo que la instancia guarda es
  estado de UI.
- La limpieza de `beforeDestroy` es **simétrica y completa**: todo lo que
  `mounted` + los handlers crearon (suscripción, timer). Checklist mental al
  escribir cualquier `mounted`: "¿qué de esto sobrevivirá al componente si no
  lo mato yo?"
- `position-fixed` + `z-index` alto en el propio componente: el toast no
  depende de dónde lo pongas en el árbol de `App.vue` para verse bien.
  Componentes de overlay que se auto-posicionan son más portables.
- El toast **completo** es clicable (el card, no un botoncito "ver"): en
  notificaciones fugaces, el área de clic generosa es la diferencia entre
  útil y frustrante.

### 5. El dashboard escucha: `views/TicketsView.vue`

```js
import socketService from "../services/socketService";

// en mounted, además de loadTickets():
mounted: function () {
  this.loadTickets();
  this.onCreatedHandler = this.onTicketCreated.bind(this);
  socketService.on("ticket:created", this.onCreatedHandler);
},
beforeDestroy: function () {
  socketService.off("ticket:created", this.onCreatedHandler);
},

// en methods:
onTicketCreated: function (ticket) {
  // unshift es uno de los 7 métodos parcheados: reactividad garantizada
  this.tickets.unshift(ticket);
  // y la cadena de la Fase 4 hace el resto: filteredTickets → summary → tabla
}
```

Fíjate en la belleza: el handler mete el ticket al **estado crudo** y toda la
maquinaria declarativa de la Fase 4 (computed → tarjetas → tabla → badges)
se actualiza sola. Si el ticket no pasa los filtros activos, no se muestra —
correcto y gratis.

### 6. Quien crea, anuncia

En `TicketCreateView.vue` **y** en el `finish()` del wizard (Fase 6), tras el
POST exitoso:

```js
.then(function (created) {
  socketService.emit("ticket:created", created); // 📣 anunciar a los demás
  self.$router.push("/tickets/" + created.id);
})
```

### 7. Indicador de conexión en el header

```vue
<!-- AppHeader.vue, junto al usuario -->
<span class="mr-3 small" :title="live ? 'Conectado en tiempo real' : 'Sin conexión en vivo'">
  {{ live ? "🟢 en vivo" : "🔴" }}
</span>
```

```js
// AppHeader.vue
import socketService from "../../services/socketService";

data: function () {
  return { live: false };
},
mounted: function () {
  var self = this;
  // sondeo barato del estado; los eventos connect/disconnect finos son el ej. 9
  this.liveTimer = setInterval(function () {
    self.live = socketService.isConnected();
  }, 2000);
},
beforeDestroy: function () {
  clearInterval(this.liveTimer);
}
```

(Sí, un `setInterval` en la fase que entierra al polling — para un check
local sin red, es proporcional. El ejercicio 9 lo reemplaza por los eventos
`connect`/`disconnect` del propio socket, como debe ser.)

---

## 🔄 Los flujos de la fase, paso a paso

### 🔌 Conexión (los dos caminos)

```
CAMINO A — login en vivo:
1. login OK → mutation SET_SESSION → getter isAuthenticated pasa a true
2. el watch de App.vue dispara → socketService.connect()
3. io(SOCKET_URL) inicia el handshake:
   └─ socket.io negocia transporte (websocket, o polling si algo lo bloquea)
   └─ el server dispara "connection" → log 🟢 con el socket.id
4. desde ya, cualquier on() registrado recibe eventos

CAMINO B — recarga con sesión activa:
1. el store se hidrata desde localStorage (Fase 2) → isAuthenticated YA es true
2. sin immediate: true, el watch nunca dispararía (el valor no "cambia") 💀
3. con immediate: dispara al montar App → connect() → mismo handshake
```

### 📣 El broadcast (la prueba de las dos pestañas)

```
PESTAÑA A (crea)                              PESTAÑA B (mira el dashboard)
1. wizard/form → POST /tickets ✓
2. .then → emit("ticket:created", created) ──→ SERVIDOR
3. router.push al detalle                      │ socket.broadcast.emit(...)
                                               ↓ (a todos menos A)
                                    4. socketService entrega el evento a
                                       CADA listener registrado:
                                       ├─ LiveToast.onTicketCreated
                                       │   └─ visible=true → toast 5s
                                       └─ TicketsView.onTicketCreated
                                           └─ tickets.unshift(ticket)
                                               └─ cadena reactiva de la F4:
                                                  summary +1, fila nueva arriba
```

Dos suscriptores independientes al mismo evento, cada uno con su ciclo de
vida: el toast vive lo que `App` (siempre); la actualización de tabla vive lo
que `TicketsView` (solo si estás ahí). Esa independencia es el argumento de
diseño de exponer `on/off` en el servicio en vez de un handler centralizado.

Y nota qué recibió la pestaña A: **nada**. El `broadcast` excluye al emisor a
propósito — A ya tiene el ticket (lo creó) y ya navegó al detalle. Si el
server usara `io.emit`, A vería un toast de su propio ticket: el clásico
"¿por qué me notifico a mí mismo?" del legacy.

### 🧹 Las dos limpiezas (no confundirlas)

```
LIMPIEZA DE LISTENER (al salir de la vista):
1. navegar fuera de /tickets → beforeDestroy de TicketsView
2. socketService.off("ticket:created", this.onCreatedHandler)
   └─ MISMA referencia que en el on (por eso se guardó en this.onCreatedHandler)
3. el socket SIGUE conectado: el toast global sigue funcionando

LIMPIEZA DE SOCKET (al cerrar sesión):
1. logout → CLEAR_SESSION → isAuthenticated = false
2. watch de App.vue → socketService.disconnect()
3. socket.disconnect() cierra la conexión → server loguea 🔴
4. socket = null → el próximo login parte limpio
```

¿Qué pasa si olvidas la limpieza de listener? Entra a `/tickets`, sal, vuelve
a entrar 3 veces. Ahora hay 4 handlers vivos escuchando el mismo evento
(3 zombis de instancias destruidas + el actual): un ticket nuevo hace **4
unshift** sobre… bueno, los zombis apuntan a componentes muertos, así que en
el mejor caso desperdician memoria y en el peor lanzan errores sobre estado
inexistente. El ejercicio 6 te lo hace presenciar.

---

## ⚠️ Errores comunes

- listeners sin `off` → handlers zombis duplicados tras navegar (el bug #1 de
  sockets en legacy, y el más fácil de introducir);
- `.bind(this)` inline en el `on` y otro en el `off` → referencias distintas,
  el `off` no desuscribe nada (por eso guardamos `this.handler`);
- guardar el socket en `data` → misma película de terror que el chart de la
  Fase 7, con final idéntico;
- conectar en `mounted` de cada vista que usa sockets → una conexión por
  vista, servidor lleno de fantasmas;
- versiones cliente/servidor de socket.io desparejadas → handshake fallando
  con errores que no mencionan versiones;
- confiar ciegamente en el payload del socket como fuente de verdad (viene de
  otro **cliente**, no del servidor de datos — ejercicio 24);
- olvidar levantar el socket server y no manejar el estado desconectado → la
  app "funciona" pero nadie se entera de nada, silenciosamente;
- emitir antes de que el socket conecte (nuestro `emit` con guard lo silencia;
  ¿es lo correcto? — ejercicio 21 discute encolar).

---

## 🧪 Ejercicios (26)

**🟢 Fácil (1–8)**

1. Abre dos navegadores (o normal + incógnito), loguéate en ambos, crea un
   ticket en uno y captura el momento estrella en el otro. 📸
2. Agrega al toast la prioridad con el `TicketPriorityBadge` de la Fase 4.
3. Haz que el toast de tickets `high` use borde rojo y dure 10 segundos.
4. Loguea en el server la hora de cada evento con `new Date().toISOString()`.
5. Apaga el socket server con la app abierta y observa la consola del
   navegador: documenta qué hace socket.io solo (spoiler: reintenta).
6. Provoca los zombis: comenta el `off` de `TicketsView`, entra/sal de la
   vista 3 veces, crea un ticket desde otra pestaña y mira la consola.
   Restaura el `off` y anota el síntoma.
7. Agrega el evento `ticket:created` también al flujo del formulario simple
   si en el ejercicio 13 de la Fase 6 decidiste conservarlo.
8. Muestra en el server un contador de clientes conectados
   (`io.engine.clientsCount` o contando en connection/disconnect).

**🟡 Intermedio (9–17)**

9. Reemplaza el `setInterval` del indicador del header por suscripción a los
   eventos nativos `connect` y `disconnect` del socket (tendrás que exponerlos
   en `socketService` — cuidado con registrarlos antes de que exista el
   socket).
10. Evento `ticket:updated`: al editar un ticket (Fase 5), emite; el server
    rebota; el dashboard actualiza la fila en sitio. ⚠️ Recuerda la Fase 4:
    `this.tickets[i] = t` NO es reactivo — usa `splice(i, 1, t)` o
    `this.$set`.
11. Evento `ticket:deleted`: al eliminar, las otras pestañas quitan la fila.
    Si un usuario está VIENDO el detalle del ticket borrado, muéstrale un
    aviso "Este ticket fue eliminado" y redirígelo en 3 segundos.
12. Notificación sonora opcional para tickets `high`: un beep corto con la
    Web Audio API y un toggle 🔔/🔕 en el header (persistido en localStorage).
13. Centro de notificaciones: en vez de un toast fugaz, acumula las últimas
    10 en un dropdown del header con contador de no-leídas. El estado vive
    en… decide tú: ¿componente o store? Justifica con la tabla de la Fase 6.
14. El toast actual se pisa si llegan 2 tickets seguidos. Conviértelo en una
    pila de hasta 3 toasts apilados verticalmente.
15. Muestra "conectando…" (🟡) como tercer estado del indicador, usando el
    evento `reconnecting` de socket.io 2.x.
16. Latencia visible: cada 10s el cliente emite `ping:custom` con
    `Date.now()`; el server responde `pong:custom` con el mismo timestamp;
    muestra los ms junto al indicador 🟢.
17. Mueve la conexión del socket del watch de `App.vue` a las actions
    `login`/`logout` del store de auth. Compara: ¿qué se ganó, qué se acopló?
    Vuelve a la versión que prefieras y defiende la decisión en un comentario.

**🟠 Difícil (18–23)**

18. Rooms por rol: al conectar, el cliente emite `join` con su rol (del
    store); el server hace `socket.join(rol)`. Los tickets `high` se emiten
    solo a la room `agent` (`io.to("agent").emit(...)`). Verifica con un
    usuario reporter que NO le llegan.
19. "Alguien está escribiendo…": en los comentarios del detalle (ejercicio 12
    de la Fase 3), emite `comment:typing` con debounce al teclear; los demás
    espectadores del MISMO ticket ven el indicador (necesitas una room por
    ticket: `join`/`leave` en mounted/beforeDestroy del detalle).
20. Implementa el event bus clásico (`new Vue()`) y refactoriza: el ÚNICO
    suscriptor del socket es `App.vue`, que re-emite por el bus; toast y
    dashboard escuchan el bus. Compara con la suscripción directa en 5
    líneas: ¿qué mejoró (un solo punto socket) y qué empeoró (una
    indirección más)?
21. Cola de emisión offline: si `emit` se llama sin conexión, encola en el
    servicio y despacha al reconectar (evento `connect`). Piensa el caso
    borde: ¿y si el usuario cierra la pestaña con cola pendiente?
22. Server-side watch: haz que el socket server observe `db.json` con
    `fs.watch` y emita `tickets:changed` genérico cuando el archivo cambie.
    El dashboard, al recibirlo, re-fetchea. Compara este diseño "aviso tonto
    + re-fetch" contra "payload completo por socket": tabla de 3 pros y 3
    contras de cada uno.
23. Reconexión con re-sincronización: al evento `connect` DESPUÉS de una
    desconexión (no el inicial), el dashboard debe re-fetchear tickets —
    todo lo que pasó mientras estuvo caído se perdió. Detecta "reconexión vs
    conexión inicial" con una bandera en el servicio.

**🔴 Muy difícil (24–26)**

24. El cliente mentiroso: desde la consola del navegador, emite a mano
    `socket.emit("ticket:created", {id: 999, title: "HACKED", priority: "high"})`
    y observa el caos en las otras pestañas (toast de un ticket que no existe
    en la base). Mitígalo: al recibir `ticket:created`, el dashboard verifica
    con `GET /tickets/:id` antes de mostrar nada. Escribe la moraleja en
    `SECURITY-NOTES.md`: *eventos de clientes son rumores; la base de datos
    es la fuente de verdad*.
25. Handshake autenticado: el cliente conecta con
    `io(URL, { query: { token: ... } })`; el server, en un middleware
    `io.use()`, rechaza conexiones sin token (con el token mock basta el
    string exacto; con el JWT falso del ejercicio 25 de la Fase 2, decodifica
    y valida `exp`). Prueba conectar sin token desde consola y verifica el
    rechazo.
26. Presencia en vivo: mantén en el server un mapa `socket.id → username`
    (enviado en el handshake del ej. 25); emite `presence:changed` con la
    lista de usuarios conectados en cada connect/disconnect; muestra en el
    sidebar "En línea: Ana, Carlos". Maneja el multi-pestaña (mismo usuario,
    dos sockets) sin duplicarlo en la lista. Acabas de construir la base de
    todo sistema de presencia — evalúa cuánta complejidad costó algo que
    parecía trivial.

---

## 📚 Referencias

**Documentación oficial**

- socket.io 2.x — docs de la época: https://socket.io/docs/v2/
- socket.io 2.x — cliente: https://socket.io/docs/v2/client-api/
- socket.io 2.x — servidor (broadcast, rooms): https://socket.io/docs/v2/server-api/
- MDN — WebSocket (el estándar debajo):
  https://developer.mozilla.org/en-US/docs/Web/API/WebSocket
- Vue 2 — reactividad de arreglos (métodos parcheados):
  https://v2.vuejs.org/v2/guide/list.html#Mutation-Methods
- Vue 2 — watch con immediate: https://v2.vuejs.org/v2/api/#watch

**Video / apoyo**

- Fireship — WebSockets in 100 Seconds: https://www.youtube.com/watch?v=1BfCnjr_Vjg
- Traversy Media — Socket.io Crash Course (verifica era 2.x):
  buscar en YouTube "socket.io crash course 2019"

**Orden de lectura sugerido:** MDN WebSocket (solo la introducción) →
socket.io v2 docs (Getting Started + Emit cheatsheet) → volver al código.
Rooms solo si haces los ejercicios 🟠.

---

## 🚀 Cierre

El Mini Jira ya no pregunta: escucha. Y tú te llevas:

- el criterio **polling vs push** con números en la mano,
- el modelo de eventos de socket.io (`emit`/`on`/`broadcast`) y su servidor
  de 30 líneas,
- la separación limpia de **dos ciclos de vida**: socket = sesión (un watch
  con `immediate` en la raíz), listener = componente (on/off simétricos),
- y la regla de la referencia idéntica en `off` que mata a los zombis antes
  de que nazcan.

La señal de que quedó bien:

> "puedo agregar un evento en vivo nuevo tocando: un emit donde ocurre,
> una línea en el server, y un on/off donde interesa. Y sé exactamente
> cuántos listeners hay vivos en cada momento."

**Siguiente parada:** 🎧 Fase 9 — Panel de soporte: la vista de agente que
integra TODO — cola, asignación, comentarios, estados y eventos en vivo.
Fase de síntesis: casi nada nuevo que aprender, todo por componer.
