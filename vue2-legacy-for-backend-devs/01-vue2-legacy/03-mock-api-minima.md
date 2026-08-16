# 🧪 Fase 3 — Mock API mínima

## 🎯 Propósito

Hasta ahora el Mini Jira vive de mentiras piadosas: tickets en un arreglo local
y un login síncrono. En esta fase montamos una **Mock API real** con
**json-server** y conectamos el frontend a ella por HTTP.

Esta es la fase donde **se pagan las dos deudas declaradas 💸** de la Fase 2:

1. **Stubby se jubila.** Cumplió su función en el Hello World de la Fase 0.
   Desde aquí, la Mock API oficial del curso es json-server en `localhost:3000`.
2. **El login se vuelve asíncrono.** La action de Vuex devolverá una Promise y
   el `try/catch` de `LoginView` migra a `.then/.catch`, tal como pasaría con
   un backend real.

La idea pedagógica:

> el frontend no debe saber si detrás hay un mock o un backend real.
> Si la capa de servicios está bien hecha, cambiar uno por otro es trivial.

---

## ✅ Qué queda listo al terminar

- json-server corriendo con un `db.json` de tickets, usuarios y comentarios;
- `ticketService.js` real: listar, obtener, crear, actualizar y borrar por HTTP;
- login asíncrono con estados de carga y error bien manejados;
- `TicketsView` consumiendo la API con `loading` y `error`;
- el interceptor de la Fase 2 adjuntando el token en cada request (verificable
  en la pestaña Network).

## 🚫 Qué NO entra todavía

- backend propio (Node/Express real);
- paginación server-side, búsqueda avanzada;
- manejo fino de errores por código HTTP (solo lo básico);
- tabla bonita con filtros y badges (eso es la Fase 4);
- validación real del token (el mock sigue siendo mock).

---

## 🧩 Mini repaso: la anatomía de los `.vue` que usan los ejemplos

Antes de conectar HTTP, un repaso exprés de las piezas de Vue 2 que aparecen
en el código de esta fase, para que ningún backend dev se pierda:

Un archivo `.vue` es un **Single File Component (SFC)**: template, lógica y
(opcionalmente) estilos en un solo archivo.

```vue
<template>   <!-- el HTML del componente, con directivas de Vue -->
<script>     <!-- la lógica: un objeto de opciones (Options API) -->
<style>      <!-- CSS opcional, puede ser scoped -->
```

Dentro del `<script>` exportamos un **objeto de opciones**. Las que usamos en
esta fase:

| Opción | Qué es | Ejemplo en esta fase |
|---|---|---|
| `data` | función que devuelve el **estado local reactivo** del componente. Si cambia, el template se repinta solo. | `tickets`, `loading`, `error` |
| `methods` | funciones del componente; dentro, `this` es el componente. | `loadTickets()`, `submitLogin()` |
| `computed` | valores **derivados** del estado, con caché automática. Se recalculan solo si cambia lo que usan. | `showLayout` en `App.vue` (Fase 2) |
| `mounted` | **hook de ciclo de vida**: se ejecuta cuando el componente ya está en el DOM. Es el lugar clásico para disparar la carga inicial de datos. | `mounted() { this.loadTickets(); }` |
| `components` | registra componentes hijos para usarlos en el template. | `PageTitle` |
| `props` | datos que el componente **recibe** de su padre (solo lectura). | `title` en `PageTitle` |

Y en los templates:

| Directiva | Qué hace |
|---|---|
| `v-if / v-else-if / v-else` | renderiza (o no) según condición — nuestro trío loading/error/data |
| `v-for` | repite un elemento por cada item (siempre con `:key`) |
| `v-model` | binding bidireccional input ↔ data |
| `@click`, `@submit.prevent` | escucha eventos (`.prevent` = `preventDefault()`) |
| `:to`, `:disabled` | atributo dinámico (atajo de `v-bind:`) |

**Regla mental para backend devs:** `data` es el estado, `methods` son los
handlers, `computed` son "getters con caché", `mounted` es tu
"post-constructor cuando ya hay DOM". Con eso lees el 90% de un componente
legacy.

> 📚 Si algo de esto te suena flojo, 15 minutos en la guía oficial bastan:
> https://v2.vuejs.org/v2/guide/instance.html (instancia y ciclo de vida) y
> https://v2.vuejs.org/v2/guide/computed.html (computed vs methods).

---

## 🧠 Concepto mínimo: ¿qué es json-server?

**json-server** toma un archivo JSON y lo convierte en una API REST completa
sin escribir una línea de backend. Con este `db.json`:

```json
{ "tickets": [ ... ] }
```

obtienes gratis:

| Método | Ruta | Qué hace |
|---|---|---|
| GET | `/tickets` | lista todos |
| GET | `/tickets/1` | uno por id |
| POST | `/tickets` | crea (asigna id solo) |
| PUT | `/tickets/1` | reemplaza completo |
| PATCH | `/tickets/1` | actualiza parcial |
| DELETE | `/tickets/1` | borra |

Y filtros de regalo:

```
GET /tickets?status=open              → filtro por campo
GET /tickets?_sort=createdAt&_order=desc  → ordenamiento
GET /tickets?q=impresora              → búsqueda de texto
GET /tickets?priority=high&status=open    → filtros combinados
```

Además **persiste los cambios en el archivo**: si haces un POST, el ticket
queda escrito en `db.json`. Perfecto para desarrollar como si hubiera backend.

> 📝 En la época 2018–2021 esto era pan de cada día: el backend "llegaba
> tarde" y el frontend avanzaba contra json-server con el contrato acordado.

---

## 📦 Instalación y arranque

### 1. Instalar (como dependencia de desarrollo)

```bash
npm install --save-dev json-server@0.16.3
```

### 2. Crear `db.json` en la raíz del proyecto

```json
{
  "tickets": [
    {
      "id": 1,
      "title": "La impresora no imprime",
      "description": "Otra vez. Tercera vez esta semana.",
      "status": "open",
      "priority": "high",
      "assignee": "soporte1",
      "reporter": "usuario1",
      "createdAt": "2020-03-10T10:00:00Z"
    },
    {
      "id": 2,
      "title": "No me llega el correo",
      "description": "Desde ayer en la tarde no recibo nada.",
      "status": "in_progress",
      "priority": "medium",
      "assignee": "soporte2",
      "reporter": "usuario2",
      "createdAt": "2020-03-11T09:30:00Z"
    },
    {
      "id": 3,
      "title": "Solicitud de acceso a carpeta compartida",
      "description": "Necesito acceso a la carpeta de Finanzas.",
      "status": "resolved",
      "priority": "low",
      "assignee": "soporte1",
      "reporter": "usuario3",
      "createdAt": "2020-03-08T14:15:00Z"
    }
  ],
  "users": [
    { "id": 1, "username": "admin", "name": "Usuario Demo", "role": "agent" },
    { "id": 2, "username": "soporte1", "name": "Ana Soporte", "role": "agent" },
    { "id": 3, "username": "usuario1", "name": "Carlos Usuario", "role": "reporter" }
  ],
  "comments": [
    {
      "id": 1,
      "ticketId": 1,
      "author": "soporte1",
      "body": "¿Probaste apagarla y prenderla?",
      "createdAt": "2020-03-10T10:30:00Z"
    }
  ]
}
```

### 3. Agregar el script en `package.json`

```json
{
  "scripts": {
    "serve": "vue-cli-service serve",
    "build": "vue-cli-service build",
    "mock": "json-server --watch db.json --port 3000"
  }
}
```

### 4. Flujo de trabajo diario (dos terminales)

```bash
# Terminal 1 — Mock API
npm run mock

# Terminal 2 — Frontend
npm run serve
```

### 5. Verificar antes de tocar código

Abre en el navegador o con curl:

```
http://localhost:3000/tickets
http://localhost:3000/tickets/1
http://localhost:3000/tickets?status=open
```

Si eso responde JSON, la Mock API está lista. json-server permite CORS por
defecto, así que no hay que configurar nada extra.

> 🪦 **Retiro formal de Stubby:** puedes borrar `stubby.yml` del proyecto (o
> dejarlo en una carpeta `docs/legacy/` como recuerdo). Todo lo HTTP pasa
> desde ahora por `apiClient` → `localhost:3000`.

---

## 🧰 ticketService real

El `apiClient.js` de la Fase 2 ya apuntaba a `localhost:3000` con el
interceptor de token. Ahora `ticketService.js` deja de mentir:

### `services/ticketService.js`

```js
import apiClient from "./apiClient";

function getTickets(params) {
  // params opcional: { status: "open", _sort: "createdAt", _order: "desc" }
  return apiClient.get("/tickets", { params: params }).then(function (res) {
    return res.data;
  });
}

function getTicketById(id) {
  return apiClient.get("/tickets/" + id).then(function (res) {
    return res.data;
  });
}

function createTicket(data) {
  return apiClient.post("/tickets", data).then(function (res) {
    return res.data;
  });
}

function updateTicket(id, data) {
  return apiClient.patch("/tickets/" + id, data).then(function (res) {
    return res.data;
  });
}

function deleteTicket(id) {
  return apiClient.delete("/tickets/" + id).then(function (res) {
    return res.data;
  });
}

export default {
  getTickets: getTickets,
  getTicketById: getTicketById,
  createTicket: createTicket,
  updateTicket: updateTicket,
  deleteTicket: deleteTicket
};
```

**Detalles con intención:**

- El servicio devuelve `res.data`, no la respuesta cruda de axios. Los
  componentes no deberían conocer la forma del objeto de axios.
- Usamos `PATCH` para actualizar (parcial) y dejamos `PUT` para cuando de
  verdad haga falta reemplazo completo.
- `getTickets(params)` acepta filtros: la Fase 4 lo va a aprovechar.

---

## 📋 TicketsView consumiendo la API

Versión mínima con los tres estados que toda vista que hace HTTP debe manejar:
**cargando, error, datos**. (La tabla bonita llega en la Fase 4; aquí lo que
importa es el patrón.)

### `views/TicketsView.vue`

```vue
<template>
  <section>
    <page-title title="Tickets" />

    <div v-if="loading" class="text-center my-5">
      <div class="spinner-border text-primary" role="status"></div>
      <p class="mt-2">Cargando tickets...</p>
    </div>

    <div v-else-if="error" class="alert alert-danger">
      {{ error }}
      <button class="btn btn-sm btn-outline-danger ml-2" @click="loadTickets">
        Reintentar
      </button>
    </div>

    <ul v-else class="list-group">
      <li
        v-for="ticket in tickets"
        :key="ticket.id"
        class="list-group-item d-flex justify-content-between"
      >
        <router-link :to="'/tickets/' + ticket.id">
          #{{ ticket.id }} — {{ ticket.title }}
        </router-link>
        <span>{{ ticket.status }}</span>
      </li>
    </ul>
  </section>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";
import ticketService from "../services/ticketService";

export default {
  name: "TicketsView",
  components: { PageTitle },
  data: function () {
    return {
      tickets: [],
      loading: false,
      error: ""
    };
  },
  mounted: function () {
    this.loadTickets();
  },
  methods: {
    loadTickets: function () {
      var self = this;
      this.loading = true;
      this.error = "";

      ticketService
        .getTickets()
        .then(function (tickets) {
          self.tickets = tickets;
        })
        .catch(function () {
          self.error = "No se pudieron cargar los tickets. ¿Está corriendo la Mock API?";
        })
        .finally(function () {
          self.loading = false;
        });
    }
  }
};
</script>
```

**El patrón a memorizar:** `loading = true` → llamar servicio → `.then` guarda
datos → `.catch` guarda error legible → `.finally` apaga el loading. Este
mismo esqueleto se repite en el 90% de las vistas legacy que vas a mantener.

> 📝 Nota de época: usamos `var self = this` + `function () {}` para mantener
> el sabor legacy. En bases reales verás también arrow functions o `.bind(this)`;
> los tres resuelven el mismo problema de `this`.

Prueba de fuego: apaga json-server (`Ctrl+C` en la terminal 1), recarga
`/tickets` y verifica que aparece el error con botón de reintento. Vuelve a
levantarlo, reintenta, y debería cargar.

---

## 💸 Pago de deuda: login asíncrono

En la Fase 2 dejamos declarado que la action `login` era síncrona solo porque
el mock lo permitía. Ahora la volvemos asíncrona **simulando latencia**, para
que el código quede con la forma exacta que tendrá contra un backend real.

### `services/authService.js` (solo cambia `login`)

```js
var MOCK_USER = {
  username: "admin",
  password: "1234",
  name: "Usuario Demo"
};

var FAKE_DELAY = 600; // ms — para que el loading se vea

function login(username, password) {
  return new Promise(function (resolve, reject) {
    setTimeout(function () {
      if (username === MOCK_USER.username && password === MOCK_USER.password) {
        resolve({
          token: "mock-jwt-token-123",
          user: { username: MOCK_USER.username, name: MOCK_USER.name }
        });
      } else {
        reject(new Error("Credenciales inválidas"));
      }
    }, FAKE_DELAY);
  });
}

// saveSession, clearSession y getStoredSession quedan igual que en la Fase 2
```

### `store/modules/auth.js` (la action devuelve la Promise)

```js
const actions = {
  // ✅ Deuda pagada: la action ahora es asíncrona y DEVUELVE la Promise.
  // Devolverla es clave: permite que la vista encadene .then/.catch.
  login: function (context, credentials) {
    return authService
      .login(credentials.username, credentials.password)
      .then(function (session) {
        authService.saveSession(session);
        context.commit("SET_SESSION", session);
        return session;
      });
  },
  logout: function (context) {
    authService.clearSession();
    context.commit("CLEAR_SESSION");
  }
};
```

### `views/LoginView.vue` (adiós try/catch, hola .then/.catch)

```vue
<template>
  <div class="container mt-5" style="max-width: 420px;">
    <page-title title="Iniciar sesión" />

    <form @submit.prevent="submitLogin" class="mt-4">
      <div class="form-group">
        <label>Usuario</label>
        <input v-model="form.username" class="form-control" :disabled="loading" />
      </div>

      <div class="form-group">
        <label>Contraseña</label>
        <input v-model="form.password" type="password" class="form-control" :disabled="loading" />
      </div>

      <div v-if="error" class="alert alert-danger">{{ error }}</div>

      <button class="btn btn-primary btn-block" :disabled="loading">
        {{ loading ? "Ingresando..." : "Ingresar" }}
      </button>
    </form>
  </div>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";

export default {
  name: "LoginView",
  components: { PageTitle },
  data: function () {
    return {
      form: { username: "", password: "" },
      error: "",
      loading: false
    };
  },
  methods: {
    submitLogin: function () {
      var self = this;
      this.error = "";

      if (!this.form.username || !this.form.password) {
        this.error = "Debe completar usuario y contraseña";
        return;
      }

      this.loading = true;

      this.$store
        .dispatch("auth/login", this.form)
        .then(function () {
          self.$router.push("/");
        })
        .catch(function (error) {
          self.error = error.message;
        })
        .finally(function () {
          self.loading = false;
        });
    }
  }
};
</script>
```

### 🤔 ¿Por qué `.then/.catch` y no el `try/catch` de antes?

Porque un `try/catch` síncrono **solo atrapa errores lanzados en el mismo
tick de ejecución**. Cuando la operación es asíncrona, el error ocurre
*después*, cuando el bloque `try` ya terminó y no hay nadie escuchando.
Míralo en código:

```js
// ❌ El bug clásico del legacy que pasó de mock a backend real
try {
  this.$store.dispatch("auth/login", this.form); // devuelve una Promise
  this.$router.push("/"); // 💥 se ejecuta SIEMPRE, antes de saber si el login funcionó
} catch (error) {
  // 💀 nunca entra aquí: el reject ocurre después, fuera del try.
  // Resultado: "Unhandled promise rejection" en consola y un usuario
  // "logueado" que rebota en el guard sin mensaje de error.
  this.error = error.message;
}

// ✅ La Promise lleva su propio canal de error
this.$store.dispatch("auth/login", this.form)
  .then(function () { /* éxito: recién AHORA sabemos que entró */ })
  .catch(function (error) { /* el reject cae aquí, garantizado */ });
```

O sea: no es que la Promise sea "mejor" en abstracto — es que **el error viaja
por el canal correcto**. El `try/catch` es para código síncrono; para código
asíncrono necesitas `.catch` (o `async/await`, que veremos abajo).

### 📊 Las tres formas de manejar lo asíncrono (y cuál usa este curso)

En una base legacy 2018–2021 te vas a encontrar las tres. Conviene saber leer
todas:

| | 1️⃣ Callbacks | 2️⃣ Promises (`.then/.catch`) | 3️⃣ `async/await` + `try/catch` |
|---|---|---|---|
| **Cómo se ve** | `login(user, pass, function(err, res) {...})` | `login().then(...).catch(...)` | `try { await login() } catch (e) {...}` |
| **Época típica** | pre-2015, jQuery `$.ajax` | 2015–2019, la era axios clásica | 2018+ (necesita Babel o Node moderno) |
| **Manejo de error** | por convención (`err` primero); fácil de olvidar | canal explícito con `.catch`, un solo `.catch` cubre toda la cadena | vuelve el `try/catch`, pero ahora **sí** atrapa (porque `await` "desempaqueta" el reject) |
| **Encadenar pasos** | 😱 pirámide de la perdición (callbacks anidados) | ✅ cadena plana de `.then` | ✅✅ se lee como código síncrono |
| **`finally`** | a mano, en cada rama | `.finally()` nativo | `finally {}` del try |
| **Legibilidad** | mala al crecer | buena | la mejor |
| **Trampa principal** | olvidar llamar el callback o llamarlo dos veces | **olvidar `return`** en la action/servicio → la cadena se rompe silenciosamente | **olvidar el `await`** → el try/catch vuelve a no atrapar nada (¡el mismo bug con otra ropa!) |
| **En este curso** | solo lo verás mencionado | ⭐ **el estándar del curso** | permitido desde la Fase 5 como alternativa |

**¿Por qué el curso usa `.then/.catch` como estándar?**

1. Es lo que domina en las bases legacy reales de la época: axios + `.then`
   está en todas partes; `async/await` aparece a cuentagotas y mezclado.
2. Te obliga a *ver* la Promise. Con `async/await` es fácil usar Promises sin
   entenderlas, y entonces la trampa del `await` olvidado te come vivo.
3. La migración mental es honesta: primero entiendes el canal de error de la
   Promise, después `async/await` es solo azúcar sintáctica encima.

> 💡 Nota fina: `async/await` con `try/catch` **sí funciona** porque `await`
> convierte el reject de la Promise en una excepción lanzada dentro del try.
> El `try/catch` de la Fase 2 fallaba porque no había `await` — exactamente la
> trampa de la última fila de la tabla. Mismo síntoma, misma lección:
> *el `try/catch` solo sirve si el error se lanza dentro de él*.

---

## 🔍 Verificación del interceptor

Con la sesión iniciada, abre DevTools → **Network**, recarga `/tickets` y
revisa el request a `localhost:3000/tickets`. En los request headers debe
aparecer:

```
Authorization: Bearer mock-jwt-token-123
```

json-server ignora ese header (no valida nada), pero el frontend ya está
enviando el token como lo haría contra un backend real. Esa es la gracia.

---

## 🖼️ Detalle de ticket contra la API

Ya que estamos, `TicketDetailView` también deja el mock:

### `views/TicketDetailView.vue`

```vue
<template>
  <section>
    <div v-if="loading" class="spinner-border text-primary"></div>

    <div v-else-if="error" class="alert alert-warning">{{ error }}</div>

    <div v-else-if="ticket">
      <page-title :title="'#' + ticket.id + ' — ' + ticket.title" />
      <p>{{ ticket.description }}</p>
      <p>
        <strong>Estado:</strong> {{ ticket.status }} ·
        <strong>Prioridad:</strong> {{ ticket.priority }} ·
        <strong>Asignado a:</strong> {{ ticket.assignee }}
      </p>
    </div>
  </section>
</template>

<script>
import PageTitle from "../components/common/PageTitle.vue";
import ticketService from "../services/ticketService";

export default {
  name: "TicketDetailView",
  components: { PageTitle },
  data: function () {
    return { ticket: null, loading: false, error: "" };
  },
  mounted: function () {
    this.loadTicket();
  },
  methods: {
    loadTicket: function () {
      var self = this;
      this.loading = true;
      this.error = "";

      ticketService
        .getTicketById(this.$route.params.id)
        .then(function (ticket) {
          self.ticket = ticket;
        })
        .catch(function (error) {
          if (error.response && error.response.status === 404) {
            self.error = "El ticket no existe.";
          } else {
            self.error = "No se pudo cargar el ticket.";
          }
        })
        .finally(function () {
          self.loading = false;
        });
    }
  }
};
</script>
```

Nótese el primer manejo de error **por código HTTP**: json-server responde
404 real cuando el id no existe, y axios lo expone en `error.response.status`.
Pruébalo con `/tickets/999`.

---

## ⚠️ Errores comunes

- olvidar levantar json-server y perder 20 minutos "debuggeando" el frontend
  (por eso el mensaje de error de `TicketsView` pregunta por la Mock API 😉);
- hacer `dispatch` de una action async y **no devolver la Promise** desde la
  action: la vista no puede encadenar nada y los errores se pierden;
- usar `try/catch` síncrono sobre código asíncrono (la deuda que pagamos hoy);
- dejar que los componentes reciban la respuesta cruda de axios en vez de
  `res.data` desde el servicio;
- editar `db.json` a mano **mientras** json-server corre con `--watch` y
  pisarse los cambios mutuamente: detén el server o edita vía API;
- versionar un `db.json` lleno de basura de pruebas: ten un `db.seed.json`
  limpio de referencia (ejercicio 14);
- hardcodear `http://localhost:3000` en los servicios en vez de usar el
  `baseURL` del `apiClient`.

---

## 🧪 Ejercicios (26)

**🟢 Fácil (1–8)**

1. Agrega 5 tickets más a `db.json` variando estado, prioridad y asignado.
2. Prueba desde el navegador: `/tickets?status=open`, `/tickets?priority=high`,
   `/tickets?q=correo`. Anota qué devuelve cada una.
3. Crea un ticket con curl o Postman (`POST /tickets`) y verifica que quedó
   escrito en `db.json`.
4. Borra ese ticket con `DELETE /tickets/:id`.
5. Cambia `FAKE_DELAY` a 2000 ms y verifica que el botón de login muestra
   "Ingresando..." y queda deshabilitado.
6. Apaga json-server y verifica el estado de error + botón "Reintentar" en
   `TicketsView`. Levántalo y reintenta.
7. Navega a `/tickets/999` y confirma que ves "El ticket no existe."
8. En DevTools → Network, captura el header `Authorization` de un request y
   pégalo en un comentario del código como evidencia de que el interceptor vive.

**🟡 Intermedio (9–17)**

9. Haz que `TicketsView` pida los tickets ordenados por fecha descendente
   usando `getTickets({ _sort: "createdAt", _order: "desc" })`.
10. Agrega un `<select>` con los estados; al cambiarlo, recarga la lista
    filtrada con `getTickets({ status: valor })`. (Filtro server-side; el
    filtro client-side llega en la Fase 4 para comparar.)
11. Agrega en `db.json` la colección `comments` (si no la tienes) y crea
    `commentService.js` con `getCommentsByTicket(ticketId)` usando
    `GET /comments?ticketId=X`.
12. Muestra los comentarios del ticket en `TicketDetailView`.
13. Agrega un formulario mínimo (un textarea + botón) para crear un comentario
    con `POST /comments` y recarga la lista al guardar.
14. Crea `db.seed.json` con datos limpios y un script npm
    `"mock:reset": "cp db.seed.json db.json"` (en Windows: `copy`). Documenta
    en el README cuándo usarlo.
15. Instala `concurrently` como devDependency y crea el script
    `"dev": "concurrently \"npm run mock\" \"npm run serve\""` para levantar
    todo con un solo comando.
16. Simula latencia real en la Mock API arrancándola con
    `json-server --watch db.json --port 3000 --delay 800`. ¿Qué mejora del UX
    se vuelve evidente?
17. Extrae el patrón loading/error/data a un mixin `asyncStateMixin` con
    `data` (`loading`, `error`) y un método `runAsync(promiseFactory)`. Úsalo
    en `TicketsView`. (Los mixins son MUY de la época: conócelos aunque hoy
    estén mal vistos.)

**🟠 Difícil (18–23)**

18. Migra el login para que consulte json-server: `GET /users?username=X`,
    y valida la contraseña contra un campo `password` que agregarás a los
    usuarios de `db.json`. Reflexiona en un comentario por qué esto es
    aceptable en un mock y terrible en producción.
19. Implementa un manejo de error diferenciado en `ticketService`: si no hay
    respuesta (`!error.response`), lanza un error "Sin conexión con el
    servidor"; si hay respuesta, propaga el status. La vista muestra mensajes
    distintos.
20. Agrega a `apiClient` un **interceptor de respuesta** que loguee en consola
    método, URL y tiempo de cada request (guarda `Date.now()` en el
    interceptor de request usando `config.metadata`).
21. Implementa "retry con backoff" casero: si `getTickets` falla, reintenta
    automáticamente 2 veces más esperando 1s y 2s antes de rendirse.
22. Haz que `updateTicket` use PUT en vez de PATCH y demuestra con un caso
    concreto qué campo se pierde si envías el objeto incompleto. Vuelve a PATCH
    y documenta la diferencia en un comentario.
23. Crea un `routes.json` de json-server que exponga la API bajo `/api/*`
    (`json-server --routes routes.json ...`) y ajusta el `baseURL` del
    apiClient. Ahora tu frontend habla con `/api/tickets`, como en producción.

**🔴 Muy difícil (24–26)**

24. Paga la deuda del 401 (ejercicio 23 de la Fase 2, ahora con API real):
    usando un middleware de json-server (`--middlewares`), rechaza con 401
    cualquier request sin header `Authorization`. Verifica que tu interceptor
    de respuesta limpia sesión y redirige al login.
25. Implementa una capa de caché simple en `ticketService`: `getTickets`
    guarda el resultado y timestamp; si se vuelve a llamar antes de 30
    segundos, devuelve el caché (envuelto en Promise) sin ir a la red. Agrega
    `getTickets({ force: true })` para saltarla. Discute en un comentario qué
    problemas trae esto (pista: datos stale tras un POST).
26. Escribe `API-CONTRACT.md`: documenta cada endpoint que usa el frontend
    (método, ruta, params, forma del request y response, códigos de error
    esperados). Este documento es lo que le entregarías al equipo de backend
    para reemplazar el mock. En proyectos reales, este contrato vale más que
    el código.

---

## 📚 Referencias

**Documentación oficial**

- json-server (v0.x, la de la época) — https://github.com/typicode/json-server/tree/v0
- json-server en npm — https://www.npmjs.com/package/json-server
- Axios — Handling Errors: https://axios-http.com/docs/handling_errors
- Axios — Config de request (params, etc.): https://axios-http.com/docs/req_config
- MDN — Using Promises: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Using_promises
- MDN — async/await: https://developer.mozilla.org/en-US/docs/Learn_web_development/Extensions/Async_JS/Promises
- Vue 2 — Instancia y ciclo de vida (diagrama de hooks): https://v2.vuejs.org/v2/guide/instance.html
- Vue 2 — Computed vs Methods: https://v2.vuejs.org/v2/guide/computed.html
- MDN — Promise.prototype.finally: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/finally
- Vuex 3 — Composing Actions (actions que devuelven Promises):
  https://v3.vuex.vuejs.org/guide/actions.html#composing-actions

**Video / apoyo**

- Traversy Media — Axios Crash Course: https://www.youtube.com/watch?v=6LyagkoRWYA
- Fake REST API con JSON Server: https://www.youtube.com/watch?v=RboyQ6IQDyI
- Vue + JSON Server + Axios: https://www.youtube.com/watch?v=yNrqlxn0nc0

**Orden de lectura sugerido:** README de json-server (sección routes y
filters) → MDN Using Promises → Vuex Composing Actions → volver al código.

---

## 🚀 Cierre

Al final de esta fase el Mini Jira ya tiene:

- una Mock API que se comporta como un backend real (persiste, filtra, da 404),
- una capa de servicios que esconde el HTTP a las vistas,
- el patrón **loading / error / data** instalado en el cerebro,
- login asíncrono con la forma definitiva,
- y **las dos deudas de la Fase 2 pagadas** ✅.

La señal de que quedó bien:

> "si mañana me cambian json-server por un backend real, solo toco el
> `baseURL` y quizás `authService`. Ninguna vista se entera."

**Siguiente parada:** 📋 Fase 4 — Dashboard de tickets: tabla Bootstrap,
badges de estado, filtros con computed y una lista que por fin parece un
sistema de soporte de verdad.
