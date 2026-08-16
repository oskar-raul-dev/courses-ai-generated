# 🔐 Fase 2 — Autenticación mínima

## 🎯 Propósito

Agregar sobre la base de la Fase 1 la autenticación **más pequeña posible pero
con forma de proyecto real**, tal como se veía en frontends internos de
2018–2021:

- pantalla de login
- usuario hardcodeado
- token mock
- sesión persistida en `localStorage`
- guard de rutas
- interceptor de axios
- logout

> ⚠️ Esto **no es seguridad de producción**. Es el flujo de sesión que
> necesitas entender para mantener una app legacy y para conectar un backend
> real después sin rehacer todo.

---

## ✅ Qué queda listo al terminar

- entrar por `/login` y validar credenciales hardcodeadas;
- generar y guardar un token mock;
- restaurar la sesión al recargar la página;
- proteger rutas privadas;
- adjuntar el token automáticamente a los requests HTTP;
- cerrar sesión y volver al login.

## 🚫 Qué NO entra todavía

- backend real de auth (empieza a asomarse en Fase 3)
- refresh token, expiración real de JWT
- roles y permisos completos
- recuperación de contraseña, MFA
- seguridad productiva real

---

## 🧱 Qué se agrega a la estructura de la Fase 1

```
src/
  services/
    authService.js        ← nuevo
  store/
    modules/
      auth.js             ← nuevo
  views/
    LoginView.vue         ← nuevo
```

Y se ajustan: `router/index.js`, `services/apiClient.js`, `store/index.js`,
`App.vue` y `AppHeader.vue`. La regla sigue siendo la misma:

> hacer lo mínimo necesario, pero extendiendo la estructura, no rompiéndola.

---

## 🧠 JWT en 60 segundos (lo justo para esta fase)

Un **JWT** (JSON Web Token) es un texto compacto que el backend emite tras el
login y que el frontend envía en cada request:

```
Authorization: Bearer <token>
```

Suele contener claims: id de usuario, rol, expiración. Para esta fase **no**
nos importa la firma ni la criptografía. Solo necesitas entender el flujo:

el frontend **recibe** un token → lo **guarda** → lo **adjunta** a cada
request → usa su existencia como señal de sesión activa.

Aquí el token será mock (`"mock-jwt-token-123"`). El flujo queda idéntico al
real, así que cambiarlo después es trivial.

---

## ⚠️ Consideraciones de seguridad (léelas, son 6)

1. **Esto es didáctico.** En un sistema real, autenticar, firmar tokens,
   validar expiración y permisos es trabajo del **backend**. Que exista un
   token en el navegador no prueba nada.
2. **localStorage tiene trade-offs.** Es cómodo y muy común en legacy, pero
   cualquier script de la página puede leerlo: un XSS expone el token. Lo
   usamos por claridad didáctica, no como recomendación universal.
3. **Guarda lo mínimo:** token, username, nombre visible. Nunca la contraseña
   ni payloads sensibles.
4. **HTTPS obligatorio** el día que esto hable con un backend real.
5. **Un 401 debe cerrar el ciclo:** limpiar sesión, redirigir a login, avisar.
   (Lo dejamos como ejercicio 🔴.)
6. **JWT no sustituye buenas prácticas:** validación de inputs, cuidado con
   `innerHTML`, manejo de errores.

---

## 🔄 Flujo mínimo (entiéndelo antes del código)

1. Usuario entra a `/login` y escribe credenciales.
2. La vista despacha `auth/login` al store.
3. La action llama a `authService.login()` (valida contra el mock).
4. Si son válidas → token mock + datos mínimos de usuario.
5. Vuex guarda la sesión en memoria; el servicio la persiste en `localStorage`.
6. El router redirige a una vista privada.
7. axios adjunta el token automáticamente (interceptor).
8. Al recargar, el store se reconstruye desde `localStorage`.
9. Logout: limpiar store + localStorage, volver a `/login`.

---

## 🖼️ Ajuste del layout

El layout completo (header + sidebar) no debe verse en el login. Solución
mínima: una condición sobre la ruta. Nada de layouts anidados todavía.

### `App.vue`

```vue
<template>
  <div id="app" class="d-flex flex-column min-vh-100">
    <template v-if="showLayout">
      <app-header />
      <div class="container-fluid flex-grow-1">
        <div class="row">
          <div class="col-md-3 col-lg-2 bg-light border-right p-0">
            <app-sidebar />
          </div>
          <main class="col-md-9 col-lg-10 p-4">
            <router-view />
          </main>
        </div>
      </div>
    </template>

    <template v-else>
      <router-view />
    </template>
  </div>
</template>

<script>
import AppHeader from "./components/layout/AppHeader.vue";
import AppSidebar from "./components/layout/AppSidebar.vue";

export default {
  name: "App",
  components: { AppHeader, AppSidebar },
  computed: {
    showLayout: function () {
      return this.$route.path !== "/login";
    }
  }
};
</script>
```

---

## 🛣️ Router con guard

Se agregan: la ruta `/login`, `meta.requiresAuth` en rutas privadas y un guard
global `beforeEach`.

### `router/index.js`

```js
import Vue from "vue";
import Router from "vue-router";
import LoginView from "../views/LoginView.vue";
import HomeView from "../views/HomeView.vue";
import TicketsView from "../views/TicketsView.vue";
import TicketDetailView from "../views/TicketDetailView.vue";
import NotFoundView from "../views/NotFoundView.vue";

Vue.use(Router);

var router = new Router({
  mode: "history",
  routes: [
    { path: "/login", name: "login", component: LoginView },
    { path: "/", name: "home", component: HomeView, meta: { requiresAuth: true } },
    { path: "/tickets", name: "tickets", component: TicketsView, meta: { requiresAuth: true } },
    { path: "/tickets/:id", name: "ticket-detail", component: TicketDetailView, meta: { requiresAuth: true } },
    { path: "*", name: "not-found", component: NotFoundView }
  ]
});

router.beforeEach(function (to, from, next) {
  var token = localStorage.getItem("token");
  var requiresAuth = to.matched.some(function (record) {
    return record.meta.requiresAuth;
  });

  if (requiresAuth && !token) {
    next("/login");
    return;
  }

  if (to.path === "/login" && token) {
    next("/");
    return;
  }

  next();
});

export default router;
```

> 📝 **Nota legacy honesta:** el guard y el interceptor leen `localStorage`
> directamente, aunque el store también tiene el token. En un diseño más
> pulcro, la única fuente de verdad sería el store (o helpers del
> `authService`). Lo dejamos así **a propósito** porque (a) evita problemas de
> orden de inicialización entre router y store, y (b) es exactamente lo que
> vas a encontrar en bases legacy reales. El ejercicio 24 propone limpiarlo.

---

## 🧰 Servicio de autenticación

### `services/authService.js`

```js
var MOCK_USER = {
  username: "admin",
  password: "1234",
  name: "Usuario Demo"
};

function login(username, password) {
  if (username === MOCK_USER.username && password === MOCK_USER.password) {
    return {
      token: "mock-jwt-token-123",
      user: { username: MOCK_USER.username, name: MOCK_USER.name }
    };
  }
  throw new Error("Credenciales inválidas");
}

function saveSession(session) {
  localStorage.setItem("token", session.token);
  localStorage.setItem("user", JSON.stringify(session.user));
}

function clearSession() {
  localStorage.removeItem("token");
  localStorage.removeItem("user");
}

function getStoredSession() {
  var token = localStorage.getItem("token");
  var user = JSON.parse(localStorage.getItem("user") || "null");
  return { token: token || "", user: user };
}

export default {
  login: login,
  saveSession: saveSession,
  clearSession: clearSession,
  getStoredSession: getStoredSession
};
```

Responsabilidades separadas y visibles: validar login, persistir, limpiar,
reconstruir sesión. La vista no toca `localStorage` jamás.

---

## 🗂️ Módulo Vuex de auth

La sesión sí justifica un módulo Vuex desde ya: es estado transversal que
afecta header, router y HTTP.

### `store/modules/auth.js`

```js
import authService from "../../services/authService";

var storedSession = authService.getStoredSession();

const state = {
  token: storedSession.token,
  user: storedSession.user
};

const mutations = {
  SET_SESSION: function (state, session) {
    state.token = session.token;
    state.user = session.user;
  },
  CLEAR_SESSION: function (state) {
    state.token = "";
    state.user = null;
  }
};

const actions = {
  // 💸 Deuda declarada: hoy esta action es síncrona porque el login es mock.
  // En la Fase 3 el login será una llamada HTTP y esta action devolverá una
  // Promise. El try/catch de LoginView dejará de servir tal cual y lo
  // migraremos a .then/.catch. Lo dejamos así para ver el problema en vivo.
  login: function (context, credentials) {
    var session = authService.login(credentials.username, credentials.password);
    authService.saveSession(session);
    context.commit("SET_SESSION", session);
  },
  logout: function (context) {
    authService.clearSession();
    context.commit("CLEAR_SESSION");
  }
};

const getters = {
  isAuthenticated: function (state) {
    return !!state.token;
  },
  currentUser: function (state) {
    return state.user;
  }
};

export default {
  namespaced: true,
  state: state,
  mutations: mutations,
  actions: actions,
  getters: getters
};
```

### `store/index.js`

```js
import Vue from "vue";
import Vuex from "vuex";
import auth from "./modules/auth";
import tickets from "./modules/tickets";

Vue.use(Vuex);

export default new Vuex.Store({
  modules: { auth: auth, tickets: tickets }
});
```

---

## 🌐 Interceptor de axios

El `apiClient.js` placeholder de la Fase 1 se aterriza ahora.

### `services/apiClient.js`

```js
import axios from "axios";

// baseURL apunta a json-server (llega oficialmente en la Fase 3).
// El Stubby de la Fase 0 (puerto 8888) queda retirado desde aquí.
var apiClient = axios.create({
  baseURL: "http://localhost:3000"
});

apiClient.interceptors.request.use(function (config) {
  var token = localStorage.getItem("token");
  if (token) {
    config.headers.Authorization = "Bearer " + token;
  }
  return config;
});

export default apiClient;
```

Lo que debe quedar claro: el token **no** se agrega a mano request por
request; una instancia compartida de axios centraliza eso, y esta pieza sirve
igual para la Mock API que para un backend real futuro.

---

## 🧾 Vista de login

### `views/LoginView.vue`

```vue
<template>
  <div class="container mt-5" style="max-width: 420px;">
    <page-title title="Iniciar sesión" />

    <form @submit.prevent="submitLogin" class="mt-4">
      <div class="form-group">
        <label>Usuario</label>
        <input v-model="form.username" class="form-control" />
      </div>

      <div class="form-group">
        <label>Contraseña</label>
        <input v-model="form.password" type="password" class="form-control" />
      </div>

      <div v-if="error" class="alert alert-danger">{{ error }}</div>

      <button class="btn btn-primary btn-block">Ingresar</button>
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
      error: ""
    };
  },
  methods: {
    submitLogin: function () {
      this.error = "";

      if (!this.form.username || !this.form.password) {
        this.error = "Debe completar usuario y contraseña";
        return;
      }

      // 💸 Este try/catch funciona SOLO porque la action es síncrona hoy.
      // Cuando el login sea async (Fase 3), habrá que usar .then/.catch.
      try {
        this.$store.dispatch("auth/login", this.form);
        this.$router.push("/");
      } catch (error) {
        this.error = error.message;
      }
    }
  }
};
</script>
```

Reparto de responsabilidades: la vista **captura datos**, el store
**coordina estado**, el servicio **encapsula la sesión**.

---

## 👤 Header con usuario y logout

### `components/layout/AppHeader.vue`

```vue
<template>
  <header class="navbar navbar-dark bg-dark px-3 d-flex justify-content-between">
    <span class="navbar-brand mb-0 h1">Mini Jira</span>

    <div v-if="currentUser" class="text-white">
      <span class="mr-3">{{ currentUser.name }}</span>
      <button class="btn btn-sm btn-outline-light" @click="logout">Salir</button>
    </div>
  </header>
</template>

<script>
export default {
  name: "AppHeader",
  computed: {
    currentUser: function () {
      return this.$store.getters["auth/currentUser"];
    }
  },
  methods: {
    logout: function () {
      this.$store.dispatch("auth/logout");
      this.$router.push("/login");
    }
  }
};
</script>
```

---

## 🧩 Chuleta de la fase

Si te quedas con un solo bloque, que sea este:

```js
// 1. Login
var session = authService.login(username, password);
authService.saveSession(session);
store.commit("auth/SET_SESSION", session);
router.push("/");

// 2. Guard
if (requiresAuth && !localStorage.getItem("token")) { next("/login"); return; }

// 3. Interceptor
config.headers.Authorization = "Bearer " + token;

// 4. Logout
authService.clearSession();
store.commit("auth/CLEAR_SESSION");
router.push("/login");
```

---

## ⚠️ Errores comunes

- meter toda la lógica de auth dentro de `LoginView.vue`;
- duplicar lecturas de `localStorage` por todo el proyecto (aquí lo hicimos
  **dos veces y con nota explícita**; sin la nota, es un olor a código);
- agregar el token a mano en cada request;
- convertir esta fase en una implementación de seguridad real;
- crear demasiadas capas para un caso todavía simple;
- olvidar que el guard solo verifica *existencia* de token, no validez.

---

## 🧪 Ejercicios (26)

**🟢 Fácil (1–8)**

1. Bloquea el submit si usuario o contraseña están vacíos (ya está; agrega ahora mensajes de error *por campo*).
2. Muestra el `username` en el header en lugar del nombre completo.
3. Cambia el texto del botón a "Ingresando..." mientras se procesa el login.
4. Agrega un segundo usuario mock (`soporte` / `abcd`) y verifica que ambos entran.
5. Agrega una ruta pública `/about` que no requiera autenticación.
6. Muestra un `alert-success` de "Sesión iniciada" en Home tras un login correcto.
7. Prueba manualmente: borra el token desde DevTools → Application → localStorage y navega a `/tickets`. ¿Qué pasa y por qué?
8. Haz que el link "Mini Jira" del header navegue a `/`.

**🟡 Intermedio (9–16)**

9. Mueve toda la gestión de `localStorage` a helpers internos del `authService` (que login/logout no sepan que existe localStorage).
10. Si el usuario ya tiene token, redirige desde `/login` a `/tickets` en lugar de `/`.
11. Agrega un checkbox "Recordarme": sin él, guarda la sesión en `sessionStorage` en vez de `localStorage`.
12. Muestra en el header las iniciales del usuario dentro de un círculo (avatar CSS simple).
13. Convierte el usuario mock en un **arreglo** de usuarios y haz que `login()` busque con `Array.find`.
14. Agrega el campo `role` al usuario mock y muéstralo en el header como badge.
15. Extrae el formulario de login a un componente `LoginForm.vue` que emita un evento `submit` con las credenciales.
16. Agrega un contador de intentos fallidos; al tercer fallo, deshabilita el botón 10 segundos.

**🟠 Difícil (17–22)**

17. Simula expiración: guarda `expiresAt` (ahora + 1 min) junto al token; el guard debe tratar un token vencido como ausencia de sesión y limpiar localStorage.
18. Refactoriza la action `login` para que devuelva una **Promise** (envuelve el mock en `Promise.resolve/reject`) y migra `LoginView` a `.then/.catch`. Acabas de pagar la deuda 💸 antes de tiempo.
19. Agrega un guard que, si la ruta tiene `meta.roles`, verifique el rol del usuario y redirija a una vista `ForbiddenView.vue` (403) si no cumple.
20. Crea `SupportLoginView.vue` en `/support/login` reutilizando `LoginForm.vue` y la misma action, pero redirigiendo a una ruta distinta tras el login.
21. Haz que el guard lea del **store** en vez de localStorage, resolviendo el problema de inicialización (pista: importa el store en `router/index.js`).
22. Al hacer logout, redirige a `/login?from=<ruta-actual>` y, tras un nuevo login, vuelve a esa ruta usando el query param.

**🔴 Muy difícil (23–26)**

23. Implementa un **interceptor de respuesta** que, ante un 401, limpie la sesión, redirija al login y muestre un mensaje "Tu sesión expiró". Pruébalo forzando un request a una URL protegida falsa.
24. Elimina *toda* lectura directa de `localStorage` fuera de `authService`: guard, interceptor y store deben pasar por el servicio. Documenta en un comentario qué problema de orden de inicialización tuviste que resolver.
25. Genera un "JWT falso pero con forma real": tres segmentos base64 (`header.payload.signature`) donde el payload contenga `username`, `role` y `exp`. Decodifícalo en el frontend con `atob` para leer la expiración real en el guard. (Sin firmar nada: el punto es entender la anatomía del token.)
26. Escribe en un archivo `SECURITY-NOTES.md` del repo: 5 razones por las que esta implementación no sirve para producción y qué haría falta cambiar en cada una. (Sí, escribir también es un ejercicio.)

---

## 📚 Referencias

**Documentación oficial**

- Vue Router 3 — Navigation Guards: https://v3.router.vuejs.org/guide/advanced/navigation-guards.html
- Vuex 3 — Actions: https://v3.vuex.vuejs.org/guide/actions.html
- Vuex 3 — Modules: https://v3.vuex.vuejs.org/guide/modules.html
- Axios — Interceptors: https://axios-http.com/docs/interceptors
- MDN — Authorization header: https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Headers/Authorization
- MDN — Web Storage API: https://developer.mozilla.org/en-US/docs/Web/API/Web_Storage_API

**JWT (conceptual)**

- JWT Introduction — https://jwt.io/introduction
- RFC 7519 (solo exploratorio) — https://datatracker.ietf.org/doc/html/rfc7519

**Seguridad (para el que quiera profundizar)**

- OWASP Session Management Cheat Sheet — https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html
- OWASP HTML5 Security Cheat Sheet — https://cheatsheetseries.owasp.org/cheatsheets/HTML5_Security_Cheat_Sheet.html
- OWASP Testing JSON Web Tokens — https://owasp.org/www-project-web-security-testing-guide/latest/4-Web_Application_Security_Testing/06-Session_Management_Testing/10-Testing_JSON_Web_Tokens

**Video / cursos (apoyo)**

- Vue Mastery — Token-Based Authentication: https://www.vuemastery.com/courses/token-based-authentication/intro-to-authentication/
- Fireship — Session vs Token Auth in 100 Seconds: https://www.youtube.com/watch?v=UBUNrFtufWo
- Traversy Media — Axios Crash Course: https://www.youtube.com/watch?v=6LyagkoRWYA

**Orden de lectura sugerido para perfil senior:**
jwt.io/introduction → Navigation Guards → Axios Interceptors → OWASP Session
Management → volver al código y experimentar.

---

## 🚀 Cierre

Al final de esta fase tienes: login sencillo, sesión mock persistida, rutas
protegidas, axios centralizado y **dos deudas técnicas declaradas** 💸 (action
síncrona y lecturas duplicadas de localStorage) que iremos pagando.

La señal de que quedó bien:

> "entiendo cómo entra el usuario, dónde se guarda la sesión, cómo se protegen
> las rutas y por dónde crecería esto al conectar un backend real".

**Siguiente parada:** 🧪 Fase 3 — Mock API con json-server, donde Stubby se
jubila y el login se vuelve asíncrono de verdad.
