# 🅥 Fase VU1 — Leer Vuetify

> **Ruta VU · Fase 2 de 5** — Reconocimiento puro. Cero código del Mini Jira.
> Después de esta fase abrís cualquier repo Vuetify 2 de la empresa y sabés **dónde está cada cosa** y **por qué el layout no pinta**.
> Si tu trabajo es solo *leer* Vuetify — parchear un bug, revisar un PR, entender un flujo antes de una reunión — **esta fase te alcanza**. VU2, VU3 y VU4 son para quien va a escribir.

> ### 📍 Venís de VU0
> Ya escribiste la red: tests de **regresión** sobre el CRUD (F5) y el dashboard (F4), **contra el código que vas a borrar**. Esos tests **no se tocan en VU1** — VU1 no escribe una línea del Mini Jira. Vuelven a correr en VU2, verdes o rojos, y ahí te dirán si migraste o si rompiste.
>
> VU0 te dejó **dos** preguntas abiertas, no una:
> 1. *"tus tests buscan `.b-table`; `v-data-table` no la tiene."* → la contesta **VU3**.
> 2. *"`<v-app>` obligatorio puede romper el `mount()` de tus tests aislados."* → VU1 **no** la resuelve, pero acá vas a entender **por qué** `v-app` es obligatorio. Con eso, la solución de test en **VU2** —donde el helper `mountView` que VU0 dejó vacío por fin se llena— te va a parecer obvia.

---

## 1. 🎯 Propósito

Aprender a **leer** un proyecto Vuetify 2.6 sin escribir una línea del Mini Jira.

Tu objetivo al terminar: te pasan un repo Vuetify, lo clonás, y en 20 minutos podés responder:

- ¿Dónde está `main.js`? (spoiler: **está**, y ahí ya empieza la diferencia con Quasar)
- ¿Dónde se configura el **tema**? ¿Por qué el color `primary` no está en ningún CSS?
- ¿Por qué esta pantalla está **en blanco** aunque el componente existe y no hay error en consola?
- ¿Este `<v-flex>` que veo en un componente de 2019 y este `<v-col>` de al lado… son lo mismo? ¿Por qué conviven?
- ¿Por qué "el icono no sale"?

Nada más. Nada menos.

**Antes de empezar: corrijamos la premisa.**

Casi todo el mundo que llega a Vuetify desde afuera cree una de estas dos cosas:

> ❌ "Vuetify es como Bootstrap pero con componentes `v-`"
> ❌ "Vuetify se instala y ya, es un paquete más"

La primera te va a costar horas con el layout. La segunda es media verdad — y la media que falta es la que muerde.

**Las dos cosas que tenés que tener claras desde la línea uno:**

| Vuetify es… | Qué significa para vos |
|---|---|
| 🎨 **Un framework de UI Material Design completo** | ~80 componentes (`v-text-field`, `v-data-table`, `v-dialog`, `v-app`…), grid propio **por componentes** (no por clases), sistema de iconos, breakpoints, y un **sistema de temas que vive en JavaScript**, no en CSS |
| 🧩 **Un plugin de Vue CLI, no un build system** | A diferencia de Quasar, **no se come el proyecto**. Tu `main.js` sigue ahí. Tu `vue.config.js` sigue ahí. Vuetify entra como **un `Vue.use()` más** |

El segundo punto es la buena noticia de esta ruta — y hay que decirlo bien, porque es **un dato, no un atajo**:

> 🔑 **La frase para memorizar:** Quasar arma la app y vos le decís cómo. **Vuetify no arma nada: tu app sigue siendo tuya, y Vuetify es una pieza que le enchufás.** Tu `main.js` sobrevive.

Eso significa que **casi todo lo que aprendiste en F0–F11 sigue valiendo tal cual**: el router es el mismo, Vuex es el mismo, el interceptor de axios de F2 no se mueve, tu `main.js` con `new Vue({...})` sigue siendo el punto de entrada. Vuetify no te reestructura nada.

Y entonces, ¿dónde está la dificultad de esta ruta, si el andamiaje no cambia? En tres lugares que Bootstrap **no tiene** y que Quasar **regala sin que te enteres**:

1. **`<v-app>`**: un componente raíz obligatorio que, si falta, rompe todo **sin un solo error**.
2. **El tema vive en JS.** El color `primary` no está en un `.scss`. Está en un objeto JavaScript. Cambiás una línea de JS y cambia toda la app.
3. **Dos sintaxis de grid conviviendo** en el mismo repo: la de Vuetify 2 (`v-row`/`v-col`) y la de Vuetify 1 (`v-layout`/`v-flex`), que **te vas a encontrar** en código de 2019.

Esos tres son VU1. El resto es reconocer nombres.

---

## 2. ✅ Qué queda al terminar

- Sabés qué es Vuetify y qué **no** es (no es Bootstrap, no es un build system).
- Entendés por qué se instala con **`vue add vuetify`** y qué implica que sea un **plugin de Vue CLI** y no un CLI propio.
- Sabés qué toca y qué **no** toca `vue add vuetify` — y por qué **tu `main.js` sobrevive** (el contraste con Quasar, que lo borra).
- Distinguís **Vuetify 1.x / 2.x / 3.x** y sabés en cuál está el legacy de la empresa.
- Entendés **`<v-app>`**: qué es, por qué es obligatorio, y sabés diagnosticar en 5 segundos el bug de "la pantalla está en blanco y no hay error".
- Ubicás **`src/plugins/vuetify.js`** como el lugar donde vive la config: tema, iconos, y (más adelante) el a-la-carte.
- **Leés y modificás el tema en JS**: `theme.themes.light.primary`, y sabés activar **dark mode**.
- Reconocés el grid por **componentes** (`<v-container>`/`<v-row>`/`<v-col>`) y sabés que **no son clases**.
- Reconocés al vuelo la sintaxis **`v-layout`/`v-flex`** de Vuetify 1 y sabés **traducirla mentalmente** a `v-row`/`v-col`.
- Sabés leer breakpoints **en JS** con `$vuetify.breakpoint.smAndDown`, no solo en CSS.
- Diagnosticás el clásico **"el icono no sale"** (MDI no declarado / fuente no cargada).
- Tenés la **tabla de equivalencias** curso-base → Vuetify internalizada.
- Sabés qué es el **full import** y por qué te infla el bundle a ~500kb (deuda 💸 que se paga en VU3).

---

## 3. 🚫 Qué NO hacemos acá

- ❌ **No tocamos el Mini Jira.** Cero. Ni un componente. VU1 es reconocimiento.
- ❌ **No tocamos los tests de VU0.** Siguen intactos hasta VU2. En VU1 no hay nada que puedan verificar.
- ❌ **No migramos nada.** El CRUD a `v-form` es **VU2**. El dashboard a `v-data-table` es **VU3**.
- ❌ **No usamos `v-form`, `v-data-table` ni `:rules`.** Los mirás de lejos; se escriben en VU2/VU3.
- ❌ **No sacamos Bootstrap.** Se queda. Conviven. La colisión (`.row` en los dos) se explota en **VU3**.
- ❌ **No configuramos a-la-carte todavía.** Arrancamos con full import a propósito, para no distraernos. Se paga en **VU3**. 💸
- ❌ **No Vuetify 3.x** (Vue 3, Composition API). Fuera de scope del curso entero.
- ❌ **No hacemos theming "de diseñador"** (paletas, contraste, accesibilidad). Vemos el **mecanismo**, no el gusto. El theming en serio, aplicado, es **VU4**.

---

## 4. 🧠 Concepto

### 4.1 Las tres versiones de Vuetify

Vas a googlear un componente y vas a caer en la doc equivocada. Aprendé a datar el código de un vistazo:

| Versión | Vue | Estado | Cómo la reconocés |
|---|---|---|---|
| **v1.x** (2017–2019) | Vue 2 | 💀 **Vieja.** Aún viva en repos legacy | Grid con **`<v-layout>` / `<v-flex>`**, props como `<v-flex xs12 md6>` |
| **v2.x** (2019–2022) | **Vue 2.6** | ✅ **La nuestra.** Options API | Grid con **`<v-row>` / `<v-col>`**, `src/plugins/vuetify.js`, `new Vuetify({...})` |
| **v3.x** (2021–hoy) | Vue 3 | 🔮 Actual, **fuera de scope** | `createVuetify()`, Composition API, `<script setup>` |

> 🔎 **Qué hace:** la señal más rápida para datar Vuetify es abrir un template y mirar el grid.
> - ¿Ves `<v-flex xs12>`? → hay **v1** en el repo (o alguien migró a medias).
> - ¿Ves `<v-col cols="12">`? → es **v2**. Es tu curso.
> - ¿Ves `createVuetify` en el entry point? → **v3**. No es tu curso.

Nosotros usamos **Vuetify 2.6.x**, la última v2. Vue 2.6.14. Options API. Igual que todo el curso base.

> ⚠️ **La trampa de la doc:** el dominio raíz `vuetifyjs.com` sirve **v3**. La doc de tu versión está en **`v2.vuetifyjs.com`**. Guardá ese link con la `v2.` delante o vas a leer una API que no existe en tu proyecto. (El mismo problema que Quasar con `v1.quasar.dev`.)

---

### 4.2 `vue add vuetify`: un plugin, no un secuestro

Acá está la diferencia estructural con Quasar, y conviene mirarla de frente porque **define el peso de toda la ruta VU**.

En Quasar, meter el framework significaba `quasar create` → un proyecto nuevo, sin `main.js`, con `quasar.conf.js` y boot files. Quasar **es** el proyecto.

En Vuetify:

```bash
vue add vuetify
```

Y eso es todo. **No hay proyecto nuevo.** Vuetify entra sobre tu Mini Jira existente. El plugin te pregunta un preset:

| Pregunta | Respuesta | Por qué |
|---|---|---|
| Choose a preset | **Configure (advanced)** | Para **ver** las opciones en vez de aceptar defaults a ciegas. Es un curso de leer, hay que ver qué se decide |
| Use a-la-carte components? | **No** (por ahora) | Full import. Deuda 💸 consciente, se paga en VU3 |
| Use custom theme? | **Yes** | Queremos ver el objeto de tema. Es medio VU1 |
| Icon font | **mdi** (Material Design Icons) | El default de Vuetify 2 |

**Qué toca `vue add vuetify`:**

```
src/main.js            ← AÑADE una línea: import vuetify + lo mete en new Vue({...})
src/plugins/vuetify.js ← CREA este archivo (la config: tema, iconos, a-la-carte)
src/App.vue            ← ENVUELVE tu template en <v-app>...</v-app>
package.json           ← añade vuetify, sass, sass-loader, @mdi/font
vue.config.js          ← puede tocar transpileDependencies
```

**Qué NO toca:**

```
src/router/            ← intacto. Vue Router 3 de F1, igual
src/store/             ← intacto. Vuex 3 de F10, igual
src/services/          ← intacto. Tu apiClient de F2/F3, igual
src/views/, components/ ← intactos. Los migrás vos, cuando quieras, en VU2/VU3
```

> 🔑 **El spoiler que hay que decir en voz alta:** en Quasar, tu `main.js` **desaparece**. En Vuetify, tu `main.js` **sobrevive** — solo le agregan una línea. Eso no es un atajo que te estamos dando: es **lo que Vuetify es**. Un plugin. Toda la ruta VU pesa menos en "dónde está mi código" (no se movió) y más en "qué hace este objeto de config que no entiendo".

Así queda `main.js` después de `vue add vuetify`:

```js
// src/main.js
import Vue from "vue";
import App from "./App.vue";
import router from "./router";
import store from "./store";
import vuetify from "./plugins/vuetify"; // 🔎 LA LÍNEA NUEVA

Vue.config.productionTip = false;

new Vue({
  router,
  store,
  vuetify, // 🔎 se registra igual que router y store
  render: function (h) { return h(App); }
}).$mount("#app");
```

> 🔎 **Qué hace:** `vuetify` se inyecta en la instancia raíz **exactamente igual** que `router` y `store`. Por eso todos tus componentes tienen `this.$vuetify` disponible (lo vas a usar para breakpoints y dark mode). Es el mismo mecanismo de inyección de F1 y F10 — no hay magia nueva.

✅ **Buenas prácticas:** cuando abras un repo Vuetify ajeno, tu **primer archivo** es `src/plugins/vuetify.js`, no `main.js`. En `main.js` solo vas a ver la línea de import; **toda la decisión** (tema, iconos, a-la-carte) está en el plugin.

---

### 4.3 ⭐ `<v-app>`: el componente raíz que rompe todo en silencio

Este es el bug número uno de todo el que llega a Vuetify. Vas a verlo en tu vida al menos una vez, y si leíste esta sección, lo vas a diagnosticar en 5 segundos en vez de en 2 horas.

**La regla:** todo componente de Vuetify tiene que tener, en algún ancestro, un `<v-app>`. Uno solo, en la raíz. Normalmente vive en `App.vue`:

```html
<!-- src/App.vue -->
<template>
  <v-app>                    <!-- 🔎 obligatorio, la raíz de TODO Vuetify -->
    <v-main>                 <!-- el contenedor del contenido de la ruta -->
      <router-view />
    </v-main>
  </v-app>
</template>
```

> 🔎 **Qué hace `<v-app>`:** no es un `<div>` decorativo. Vuetify lo usa para:
> - montar una **capa raíz** donde se posicionan los componentes flotantes (`v-dialog`, `v-menu`, `v-snackbar`, tooltips). Sin `v-app`, esos componentes **no saben dónde renderizarse**.
> - inyectar las **variables del tema** en el árbol (el `primary` que definiste en JS baja desde acá).
> - calcular breakpoints y aplicar los estilos base.

**Y ahora la parte cruel.** Mirá qué pasa si falta.

**Demostración — montá algo sin `v-app`:**

```html
<!-- App.vue SIN v-app (mal a propósito) -->
<template>
  <div id="app">
    <v-btn color="primary">Guardar</v-btn>
    <v-dialog v-model="open">
      <v-card>Hola</v-card>
    </v-dialog>
  </div>
</template>
```

**Resultado:**

- El `<v-btn>` **quizás** se ve, pero **descolorido, sin el color del tema, sin elevación**. Como un botón a medio pintar.
- El `<v-dialog>`, cuando pongas `open = true`, **no aparece**. O aparece en una esquina, roto, sin overlay.
- **La consola no dice nada.** No hay error. No hay warning rojo. Nada.

> ⚠️ **Este es EL error clásico de Vuetify.** La pantalla está "casi bien" pero los colores no son los del tema y los diálogos no abren, y **no hay ningún mensaje** que te apunte a la causa. En Vuetify 2 no hay un error claro tipo *"v-dialog must be inside v-app"*. Simplemente no funciona.

> 🔑 **El reflejo que VU1 te instala:** ¿colores del tema que no se aplican + diálogos que no abren + consola limpia? → **buscá `<v-app>`.** Es lo primero que mirás, siempre. Cinco segundos, no dos horas.

**Y acá se cierra el círculo con VU0:** ¿te acordás de la segunda pregunta abierta? *"`<v-app>` obligatorio puede romper el `mount()` de tus tests."* Ahora ya sabés por qué: tus tests de VU0 montan un componente **aislado**, sin `App.vue`, o sea **sin `v-app` ancestro**. Cuando ese componente empiece a usar Vuetify, el `mount()` se va a quejar (o peor, va a pasar pero renderizar mal). VU1 no lo resuelve — pero ya entendés el mecanismo. La solución es de **VU2**: ahí el helper `mountView` que VU0 dejó vacío se llena con la instancia de Vuetify y el wrapper `<v-app>`, y ningún test de regresión se entera.

---

### 4.4 `src/plugins/vuetify.js`: el objeto de configuración

Este es el archivo que Quasar tiene repartido en `quasar.conf.js`. En Vuetify está todo junto acá, y es corto:

```js
// src/plugins/vuetify.js
import Vue from "vue";
import Vuetify from "vuetify";
import "vuetify/dist/vuetify.min.css"; // 🔎 full import: TODO el CSS de Vuetify (~la deuda 💸)
import "@mdi/font/css/materialdesignicons.css"; // 🔎 la fuente de iconos MDI

Vue.use(Vuetify); // 🔎 registra Vuetify como plugin de Vue (el mismo Vue.use de siempre)

export default new Vuetify({
  icons: {
    iconfont: "mdi" // 🔎 le decimos que use Material Design Icons
  },
  theme: {
    themes: {
      light: {
        primary: "#1976D2",   // 🔎 ESTOS colores son el tema. No están en ningún .scss
        secondary: "#424242",
        accent: "#82B1FF",
        error: "#FF5252",
        info: "#2196F3",
        success: "#4CAF50",
        warning: "#FB8C00"
      }
    }
  }
});
```

> 🔎 **Qué hace cada bloque:**
> - `import "vuetify/dist/vuetify.min.css"` → mete **todo** el CSS de Vuetify de una. Eso es el **full import**. Cómodo hoy, caro en el bundle (💸, VU3).
> - `import "@mdi/font..."` → carga la **fuente** de iconos. Si esta línea falta, "el icono no sale" (§4.7).
> - `Vue.use(Vuetify)` → el mismo mecanismo de plugin que ya conocés.
> - `new Vuetify({ theme, icons })` → **la instancia** que se exporta y que `main.js` inyecta.

✅ **Buenas prácticas:** cuando abras este archivo en un repo ajeno, mirá **tres cosas**: (1) ¿es full import o a-la-carte? (busca `import Vuetify from "vuetify"` vs imports de componentes sueltos); (2) ¿qué colores tiene el tema y cuántos temas hay (`light`/`dark`)?; (3) ¿qué `iconfont` declara? Con eso ya sabés el 80% de cómo está configurada la UI.

---

### 4.5 ⭐ Theming en JS: lo que Bootstrap no tiene y Quasar no regala

**Este es el peso alto de VU1.** Dedicale tiempo real, porque es el diferencial de la ruta y lo que más te va a confundir viniendo de Bootstrap.

En Bootstrap (F4), un badge rojo era esto:

```html
<span class="badge badge-danger">Abierto</span>
```

El color `danger` vivía en el **CSS** de Bootstrap. Para cambiarlo, tocabas SCSS o sobreescribías clases. El color era una **clase**.

En Vuetify, el color vive en **JavaScript**, en el objeto `theme` que viste arriba. Y en el template te referís a él **por nombre semántico**:

```html
<v-btn color="primary">Guardar</v-btn>
<v-chip color="error">Abierto</v-chip>
<v-icon color="success">mdi-check</v-icon>
```

> 🔎 **Qué hace:** `color="primary"` **no** es una clase CSS con ese nombre. Vuetify **resuelve** `primary` contra `theme.themes.light.primary` (ese `#1976D2`) **en tiempo de ejecución** y genera el estilo. Cambiás **una línea** en `vuetify.js`:
>
> ```js
> primary: "#1976D2"  →  primary: "#6A1B9A"
> ```
>
> …y **todos** los `color="primary"` de toda la app cambian de golpe. Sin tocar un solo template.

Eso es lo que Bootstrap no puede hacer sin recompilar SCSS, y lo que Quasar hace por CSS vars (menos flexible). En Vuetify el tema es **un objeto de datos**, y por eso podés:

**Dark mode — dos líneas:**

```js
// definir el tema oscuro en vuetify.js
theme: {
  dark: false,               // 🔎 arranca en claro
  themes: {
    light: { primary: "#1976D2", /* ... */ },
    dark:  { primary: "#2196F3", /* ... */ } // 🔎 otra paleta para modo oscuro
  }
}
```

Y en cualquier componente, en runtime:

```js
methods: {
  toggleDark: function () {
    this.$vuetify.theme.dark = !this.$vuetify.theme.dark; // 🔎 flip global, reactivo
  }
}
```

> 🔎 **Qué hace `this.$vuetify.theme.dark = true`:** cambia el modo de **toda la app** al instante. Vuetify recalcula todos los colores contra el bloque `dark` del tema. Es reactivo: no recargás nada.

✅ **Buenas prácticas de lectura:** cuando en un repo ajeno veas `color="warning"` y quieras saber **qué color es realmente**, no busques en el CSS — no está ahí. Andá a `plugins/vuetify.js` → `theme.themes.light.warning`. Ese es el mapa. Si el color se ve raro, el problema casi siempre está en el objeto de tema, no en el template.

> 💸 **Nota:** el theming en serio — badges de F4 que sacan su color del tema en vez de `badge-danger` hardcodeado, timeline que cambia entero al cambiar el tema, dark mode que rompe cosas — se **aplica** en VU3 y VU4. Acá solo aprendés el **mecanismo**. Pero es el mecanismo que hace especial a esta ruta.

---

### 4.6 El grid: componentes, no clases (y la trampa de v1)

En Bootstrap (F4), el grid era **clases** sobre `<div>`:

```html
<div class="container">
  <div class="row">
    <div class="col-md-6">…</div>
    <div class="col-md-3">…</div>
  </div>
</div>
```

En Vuetify 2, el grid son **componentes**:

```html
<v-container>
  <v-row>
    <v-col cols="12" md="6">…</v-col>   <!-- 🔎 cols=móvil, md=desktop -->
    <v-col cols="6"  md="3">…</v-col>
  </v-row>
</v-container>
```

> 🔎 **Qué hace:** `<v-col cols="12" md="6">` = "ocupá las 12 columnas en móvil, la mitad (6) de `md` para arriba". Es el mismo modelo de 12 columnas de Bootstrap, pero como **componentes con props** en vez de clases. Por dentro Vuetify les pone clases flex, pero vos trabajás con props.

**Y ahora la trampa que hace de esto ORO para un curso de legacy.**

En **Vuetify 1.x** (2017–2019) el grid se escribía **distinto**:

```html
<!-- Vuetify 1.x — lo vas a ver en código de 2019 -->
<v-layout row wrap>
  <v-flex xs12 md6>…</v-flex>   <!-- 🔎 xs12 = cols="12", md6 = md="6" -->
  <v-flex xs6  md3>…</v-flex>
</v-layout>
```

`v-layout` era el `v-row`, y `v-flex` era el `v-col`. Los breakpoints se escribían **pegados**: `xs12` en vez de `cols="12"`, `md6` en vez de `md="6"`.

> ⚠️ **Por qué esto es oro para legacy:** Vuetify 2 **mantuvo compatibilidad** con `v-layout`/`v-flex` durante toda la v2 (deprecados, pero funcionan). Resultado: en un repo real de 2019–2021 que se fue actualizando, **conviven las dos sintaxis en el mismo proyecto** — a veces en el mismo componente. Un dev migró unas pantallas a `v-row`/`v-col` y dejó otras en `v-layout`/`v-flex`. Vos vas a entrar a mantener eso.

**Tu tabla de traducción mental v1 → v2:**

| Vuetify 1 (viejo) | Vuetify 2 (nuevo) | Qué significa |
|---|---|---|
| `<v-layout row wrap>` | `<v-row>` | La fila (`wrap` ya es default en v2) |
| `<v-flex xs12>` | `<v-col cols="12">` | Columna full en móvil |
| `<v-flex md6>` | `<v-col md="6">` | Media columna en desktop |
| `<v-flex xs12 md6>` | `<v-col cols="12" md="6">` | Las dos combinadas |

> 🔑 **El reflejo:** ¿ves `v-flex xs12 md6`? → traducilo en tu cabeza a `v-col cols="12" md="6"` y seguí leyendo. Es lo mismo, escrito con la sintaxis de 2019. **No lo migres en VU1** — solo reconocelo. (Y no te asustes si en el mismo archivo hay de las dos: es un legacy normal.)

---

### 4.7 Iconos: MDI por defecto, y por qué "el icono no sale"

Vuetify 2 usa **Material Design Icons (MDI)** por defecto. En el template:

```html
<v-icon>mdi-magnify</v-icon>           <!-- lupa -->
<v-btn icon><v-icon>mdi-delete</v-icon></v-btn>
<v-text-field prepend-icon="mdi-account" />
```

> 🔎 **Qué hace:** `mdi-magnify` es el **nombre** del glifo en la fuente MDI. Vuetify sabe que tiene que buscarlo en la fuente porque el `iconfont: "mdi"` de `vuetify.js` se lo dijo.

**El clásico "el icono no sale" (aparece un cuadradito □ o nada):**

Casi siempre es **una** de estas tres, en orden de frecuencia:

1. **La fuente MDI no está cargada.** Falta `import "@mdi/font/css/materialdesignicons.css"` en `vuetify.js`, o `@mdi/font` no está en `package.json`. → El icono no tiene de dónde sacar el glifo.
2. **El nombre está mal.** Es `mdi-magnify`, no `mdi-search`. En un repo ajeno, un nombre de otra versión de MDI que ya no existe. → Buscá el nombre en la doc de MDI.
3. **Falta el prefijo `mdi-`.** Escribieron `<v-icon>delete</v-icon>` (eso es Material Icons, otra fuente) en un proyecto configurado con `iconfont: "mdi"`. → Mezcla de fuentes.

> ⚠️ **Ojo con el sedimento legacy:** Vuetify soporta también `md` (Material Icons, la de Google) y `fa` (Font Awesome). En un repo viejo podés encontrar `iconfont: "md"` con iconos `<v-icon>delete</v-icon>` **sin** prefijo. No está roto — está en otra fuente. Confirmá siempre el `iconfont` de `vuetify.js` antes de decir "el nombre está mal".

✅ **Buenas prácticas de lectura:** ¿icono que no aparece? Chequeá en este orden: (1) ¿está `@mdi/font` importado en `vuetify.js`? → (2) ¿qué `iconfont` declara el plugin? → (3) ¿el nombre coincide con esa fuente? Tres pasos, y cae solo.

---

### 4.8 Breakpoints en JS: `$vuetify.breakpoint`

En Bootstrap, "esto solo en móvil" era una clase (`d-md-none`) o media queries en CSS. Vuetify te da eso **también en JavaScript**, y por eso podés cambiar **lógica** (no solo estilo) según el tamaño de pantalla:

```html
<template>
  <!-- opción CSS-like, con props -->
  <v-navigation-drawer :permanent="$vuetify.breakpoint.mdAndUp" />
</template>

<script>
export default {
  computed: {
    isMobile: function () {
      return this.$vuetify.breakpoint.smAndDown; // 🔎 true si la pantalla es sm o menor
    },
    columnas: function () {
      // 🔎 lógica que depende del tamaño, imposible con solo CSS
      return this.isMobile ? 1 : 3;
    }
  }
};
</script>
```

> 🔎 **Qué hace `$vuetify.breakpoint`:** expone el breakpoint actual como **dato reactivo**. `smAndDown`, `mdAndUp`, `xs`, `name` (`"md"`), `width`… Cuando el usuario redimensiona, estos valores cambian y tus computed se recalculan. Es lo que te permite decidir en JS: "en móvil cargo 10 items, en desktop 50", cosa que una media query CSS no puede.

✅ **Buenas prácticas de lectura:** cuando en un repo veas `$vuetify.breakpoint.algo`, entendé que ahí hay **lógica** atada al viewport, no solo estilo. Es un punto donde el comportamiento cambia según el dispositivo — anotalo, porque los bugs "solo en móvil" suelen vivir ahí.

---

### 4.9 🗺️ Tabla de equivalencias: curso base → Vuetify

La internalizás y ya podés mapear cualquier pantalla Bootstrap del Mini Jira a su versión Vuetify **sin migrar nada** todavía:

| Curso base (Bootstrap / a pelo) | Vuetify 2 | Dónde se usa / migra |
|---|---|---|
| `main.js` con `new Vue({...})` | **El mismo** `main.js` + `import vuetify` | VU1 — **sobrevive** |
| `App.vue` con navbar + `router-view` | `App.vue` envuelto en **`<v-app>`** + `<v-main>` | VU1 |
| — (no había config de UI) | **`src/plugins/vuetify.js`** (tema, iconos) | VU1 |
| `<div class="container/row/col-md-6">` | `<v-container>`/`<v-row>`/`<v-col cols md>` | VU1 (leer) / VU3 (usar) |
| `<v-layout>`/`<v-flex>` (si es repo v1) | ≡ `<v-row>`/`<v-col>` | VU1 — reconocer, no migrar |
| `<b-form-input>` + vuelidate | `<v-text-field :rules>` | **VU2** |
| `<select>` de F5 | `<v-select :item-text :item-value>` | **VU2** |
| `<b-modal>` de F5 | `<v-dialog>` | **VU2** |
| `<table>` + filtro/orden/paginación a mano (F4) | `<v-data-table>` | **VU3** |
| `<span class="badge badge-danger">` (F4) | `<v-chip color="error">` (color **del tema**) | **VU3 / VU4** |
| Tu componente de alertas de F5 | `<v-snackbar>` / `<v-alert>` | VU2/VU3 |
| Colores en clases CSS (`badge-*`, `btn-*`) | **El tema en JS** (`theme.themes.light.*`) | VU1 (leer) / VU4 (explotar) |
| `d-md-none` / media queries | `$vuetify.breakpoint.smAndDown` | VU1 (leer) |

> 🔎 **Cómo leer esta tabla:** la columna de la derecha con "VU1" es lo que **ya podés reconocer** al salir de esta fase. Lo de "VU2/VU3/VU4" lo reconocés pero **no lo tocás todavía**. La tabla es tu diccionario de lectura.

---

## 5. 💻 Código mínimo: un tour de lectura, no de escritura

Recordá: **VU1 no escribe Mini Jira.** Este bloque es un `App.vue` de referencia para que **reconozcas** las piezas juntas. Miralo como quien abre un repo ajeno.

```html
<!-- src/App.vue — el esqueleto típico de un proyecto Vuetify 2 -->
<template>
  <v-app>                                <!-- 🔎 (1) raíz obligatoria. Sin esto, nada -->
    <v-app-bar app color="primary" dark> <!-- 🔎 (2) navbar; color="primary" sale del TEMA -->
      <v-toolbar-title>Mini Jira</v-toolbar-title>
      <v-spacer />
      <v-btn icon @click="toggleDark">   <!-- 🔎 (3) botón dark mode -->
        <v-icon>mdi-theme-light-dark</v-icon> <!-- 🔎 (4) icono MDI -->
      </v-btn>
    </v-app-bar>

    <v-main>                             <!-- 🔎 (5) contenedor del contenido de la ruta -->
      <v-container>                      <!-- 🔎 (6) grid: container > row > col -->
        <router-view />                  <!-- 🔎 el mismo router-view de F1 -->
      </v-container>
    </v-main>
  </v-app>
</template>

<script>
export default {
  name: "App",
  methods: {
    toggleDark: function () {           // 🔎 function () {}, no arrow — convención del curso
      this.$vuetify.theme.dark = !this.$vuetify.theme.dark; // 🔎 (7) dark mode global
    }
  }
};
</script>
```

**Leé el esqueleto por números:**

1. `<v-app>` — la raíz. Si no está, §4.3 te dice qué se rompe (todo, en silencio).
2. `color="primary"` — **no** es una clase, es el nombre semántico que resuelve contra el tema (§4.5).
3–4. Botón + icono MDI. Si el icono no sale, §4.7.
5. `<v-main>` — el hueco del contenido. Reemplaza a tu `<div class="container">` de layout.
6. `<v-container>` — arranca el grid por componentes (§4.6).
7. `this.$vuetify.theme.dark` — dark mode en una línea (§4.5).

> 🔑 **El ejercicio mental de VU1:** abrí este `App.vue` e identificá, sin ejecutarlo, **cada** pieza contra la sección de Concepto donde se explica. Si podés hacer eso, ya leés Vuetify.

---

## 6. ⚠️ Errores comunes

| Síntoma | Causa real | Cómo lo confirmás |
|---|---|---|
| Pantalla "casi bien" pero **colores del tema no se aplican y los diálogos no abren**, consola limpia | Falta **`<v-app>`** en la raíz | Buscá `<v-app>` en `App.vue`. §4.3 |
| El color `primary` "no es el que puse" | Estás buscándolo en el CSS; vive en **`vuetify.js`** | Abrí `plugins/vuetify.js` → `theme.themes.light.primary`. §4.5 |
| **El icono no sale** (cuadradito o nada) | Fuente MDI no cargada / nombre mal / prefijo faltante | Chequeá `@mdi/font` importado → `iconfont` → nombre. §4.7 |
| `<v-flex xs12>` "no anda como esperaba" o te confunde | Es sintaxis **Vuetify 1**, no es tu v2 | Traducí a `<v-col cols="12">` mentalmente. §4.6 |
| Leo la doc y **la API no coincide** con el proyecto | Caíste en `vuetifyjs.com` = **v3** | Usá **`v2.vuetifyjs.com`**. §4.1 |
| `<v-col>` "no se acomoda" | Falta el `<v-row>` padre, o el `<v-container>` | El grid necesita los tres: container > row > col. §4.6 |
| El bundle pesa una barbaridad (~500kb solo Vuetify) | **Full import** activado | Es la deuda 💸 consciente. Se paga en VU3. §4.4 |
| `this.$vuetify` es `undefined` en un test | El componente se montó **sin la instancia Vuetify** inyectada | Es el mismo problema que `<v-app>` en tests. Se resuelve en **VU2**, dentro del helper `mountView` |

> ⚠️ **El error que más horas cuesta y menos avisa** es el de `<v-app>`. Si internalizás una sola cosa de VU1, que sea esa: **colores del tema que no aplican + diálogos que no abren + consola en silencio = falta `v-app`.**

---

## 7. 🧪 Ejercicios

Todos son de **lectura y reconocimiento** — cero migración del Mini Jira. Sirven igual al dev que solo va a leer Vuetify. Graduados 🟢 fácil → 🟡 medio → 🟠 difícil → 🔴 muy difícil.

### 🟢 Básicos (reconocer y ubicar)

**🟢 1.** Abrí `plugins/vuetify.js` (el de §4.4). ¿En qué línea está definido el color `primary` y qué valor tiene? ¿Está en un archivo `.css`? (Respondé: no. ¿Dónde entonces?)

**🟢 2.** En el `App.vue` de §5, señalá la línea **exacta** sin la cual "nada de Vuetify funciona". Nombrá el componente.

**🟢 3.** Datá estos tres fragmentos como v1, v2 o v3:
   a) `<v-flex xs12 md6>`  b) `<v-col cols="12" md="6">`  c) `createVuetify({ theme })`

**🟢 4.** ¿Cuál de estos NO toca `vue add vuetify`? `main.js` / `App.vue` / `router/index.js` / `plugins/vuetify.js`

**🟢 5.** Traducí a Vuetify 2: `<v-layout row wrap><v-flex xs12 md4>…</v-flex></v-layout>`.

**🟢 6.** ¿Qué fuente de iconos usa Vuetify 2 por defecto? ¿Qué prefijo llevan sus nombres?

**🟢 7.** En `<v-btn color="primary">`, ¿`primary` es una clase CSS, un color hex, o un nombre que se resuelve en runtime? ¿Contra qué se resuelve?

**🟢 8.** ¿Cuál es el dominio correcto de la doc para tu versión? ¿Qué pasa si entrás al dominio raíz `vuetifyjs.com`?

**🟢 9.** Nombrá los tres componentes del grid de Vuetify 2, en orden de anidamiento.

**🟢 10.** Verdadero/falso y por qué: "Al instalar Vuetify, mi `main.js` desaparece como en Quasar".

<details><summary>Soluciones 🟢</summary>

1. Línea del `primary: "#1976D2"`. No está en CSS: vive en el objeto `theme.themes.light` de `plugins/vuetify.js` (§4.5).
2. `<v-app>` (§4.3).
3. a) v1  b) v2  c) v3 (§4.1).
4. `router/index.js` — Vuetify no toca el router (§4.2).
5. `<v-row><v-col cols="12" md="4">…</v-col></v-row>` (§4.6).
6. MDI (Material Design Icons); prefijo `mdi-` (§4.7).
7. Un **nombre semántico** que se resuelve **en runtime** contra `theme.themes.light.primary` (§4.5).
8. `v2.vuetifyjs.com`. El raíz sirve **v3**, cuya API no coincide con tu proyecto (§4.1).
9. `<v-container>` > `<v-row>` > `<v-col>` (§4.6).
10. **Falso.** Vuetify es un **plugin de Vue CLI**: `main.js` sobrevive, solo le agregan un import (§4.2). Es la diferencia estructural con Quasar.
</details>

---

### 🟡 Medios (diagnosticar y comparar)

**🟡 11.** Te pasan una pantalla donde los botones se ven grises sin color de tema y un `<v-dialog>` no abre al setear su `v-model` a `true`. La consola está **limpia**. ¿Cuál es tu primera hipótesis y qué archivo abrís para confirmarla?

**🟡 12.** En un repo, `color="warning"` pinta un naranja que no es el que esperabas. ¿Dónde está definido ese color realmente? Escribí la ruta de acceso (`archivo` → `objeto` → `propiedad`).

**🟡 13.** Un `<v-icon>mdi-trash</v-icon>` muestra un cuadradito. Listá las tres causas posibles en orden de probabilidad y cómo descartás cada una.

**🟡 14.** Explicá en 2–3 frases, a un compañero backend, por qué el theming de Vuetify "vive en JS" es más potente que las clases `badge-danger` de Bootstrap. Dá un ejemplo concreto de algo que podés hacer en Vuetify y no en Bootstrap sin recompilar.

**🟡 15.** En el mismo componente ves esto:
   ```html
   <v-layout row><v-flex xs12 md6>A</v-flex></v-layout>
   <v-row><v-col cols="12" md="6">B</v-col></v-row>
   ```
   ¿Está roto? ¿Por qué conviven? ¿Cuál migrarías si tuvieras que tocar ese archivo, y cuál dejarías?

**🟡 16.** `$vuetify.breakpoint.smAndDown` en un `computed`. Explicá por qué esto permite algo que una media query CSS **no** puede, con un ejemplo del Mini Jira (pista: cantidad de items a cargar).

**🟡 17.** Comparás el `App.vue` "a pelo" del curso base con el `App.vue` post-Vuetify. Listá **exactamente** qué se agregó y qué se mantuvo igual (incluido `router-view`).

**🟡 18.** ¿Por qué el preset **"Configure (advanced)"** es mejor que el default para este curso? (Pista: es un curso de **leer**.)

**🟡 19.** Te dan un `plugins/vuetify.js`. Escribí las **tres** preguntas que le hacés al archivo para entender en 30 segundos cómo está configurada la UI (§4.4, buenas prácticas).

**🟡 20.** Dark mode: escribí la línea que lo activa en runtime y explicá por qué **toda** la app cambia sin recargar.

<details><summary>Soluciones 🟡</summary>

11. Hipótesis: **falta `<v-app>`** en la raíz. Abrís `App.vue` (§4.3). Colores del tema que no aplican + diálogos que no abren + consola limpia = firma de `v-app` ausente.
12. `plugins/vuetify.js` → `theme.themes.light` → `warning` (§4.5). No está en el CSS.
13. (1) Fuente MDI no cargada → chequeá el `import "@mdi/font..."` y `package.json`. (2) Nombre inexistente → es `mdi-delete`, no `mdi-trash`; verificá en la doc MDI. (3) `iconfont` distinto → mirá si el plugin usa `md`/`fa` en vez de `mdi` (§4.7).
14. El color es un **dato** (objeto JS), no una clase compilada. Ejemplo: cambiar `primary` en una línea recolorea toda la app al instante, o alternar dark/light en runtime — sin recompilar SCSS (§4.5).
15. No está roto: Vuetify 2 mantiene `v-layout`/`v-flex` (deprecados) por compatibilidad; conviven porque alguien migró a medias. Si tocás el archivo, migrás el bloque `v-layout` a `v-row`/`v-col` para no dejar sintaxis muerta — pero **solo si ya lo estás tocando por otra razón** (en VU1 no migrás nada). §4.6.
16. La media query solo cambia **estilo**; `$vuetify.breakpoint` te da el valor en **JS**, así que podés cambiar **lógica**: en móvil cargar 10 tickets, en desktop 50. Eso es una decisión de datos, no de CSS (§4.8).
17. Se agregó: import de `vuetify` en `main.js`, `vuetify` en `new Vue({...})`, `<v-app>`+`<v-main>` en `App.vue`, `plugins/vuetify.js`. Se mantuvo: `router`, `store`, `render`, `router-view`, toda la lógica (§4.2).
18. Porque "advanced" te **muestra** las decisiones (a-la-carte, tema, iconos) en vez de aceptarlas a ciegas — y este curso entrena a **leer** esas decisiones (§4.2).
19. (1) ¿full import o a-la-carte? (2) ¿qué colores y cuántos temas (light/dark)? (3) ¿qué `iconfont`? (§4.4).
20. `this.$vuetify.theme.dark = true`. Cambia el modo global reactivamente; Vuetify recalcula todos los colores contra el bloque `dark` del tema, sin recarga (§4.5).
</details>

---

### 🟠 Difíciles (leer repos reales, predecir problemas)

**🟠 21.** Te dan este `plugins/vuetify.js`:
   ```js
   import Vuetify from "vuetify/lib";
   import { VBtn, VTextField } from "vuetify/lib";
   export default new Vuetify({ theme: { themes: { light: { primary: "#000" } } } });
   ```
   ¿Es full import o a-la-carte? ¿Cómo lo sabés? ¿Qué pasará si un template usa `<v-dialog>` y no está importado acá?

**🟠 22.** Un repo tiene `iconfont: "md"` en `vuetify.js` y templates con `<v-icon>delete</v-icon>` (sin prefijo `mdi-`). Un dev nuevo "arregla" los iconos poniéndoles `mdi-` a todos. ¿Qué rompe? Explicá.

**🟠 23.** En un componente hay `<v-app>` anidado **dentro** de otro `<v-app>` (uno en `App.vue`, otro que alguien metió en una vista). ¿Qué problemas podés predecir sin ejecutarlo? (Pista: dónde se montan los diálogos, de dónde bajan las variables de tema.)

**🟠 24.** Un proyecto tiene Bootstrap y Vuetify cargados. Ambos definen `.row`. Sin ejecutarlo, predecí **qué** podría romperse y **de qué depende** que se rompa o no (pista: orden de imports de CSS). Esto lo vas a desactivar recién en VU3, pero acá ya lo tenés que **predecir**.

**🟠 25.** Te dan un `App.vue` sin `<v-app>` pero la app "parece andar" en la home. En qué pantalla o interacción específica va a explotar, y por qué la home no lo mostró. (Pista: ¿qué componentes necesitan `v-app` sí o sí?)

**🟠 26.** Un `computed` devuelve `this.$vuetify.breakpoint.width`. Un test unitario de ese componente **falla** con `Cannot read property 'width' of undefined`. ¿Por qué? ¿Qué le falta al `mount()` del test? (Conectá con la pregunta abierta de VU0.)

**🟠 27.** Leyendo un repo, encontrás colores hardcodeados en templates (`style="color:#1976D2"`) que resultan ser **el mismo hex** que `primary` del tema. ¿Por qué es una deuda? ¿Qué se rompe el día que alguien cambie el tema?

<details><summary>Soluciones 🟠</summary>

21. **A-la-carte:** importa desde `vuetify/lib` y trae componentes **sueltos** (`VBtn`, `VTextField`). Si un template usa `<v-dialog>` sin importar `VDialog`, **no renderiza** (y puede no dar error claro — mismo espíritu que el `<v-app>` faltante). Es el patrón que se configura en VU3 para bajar el bundle (§4.4).
22. Rompe **todos** los iconos: el proyecto usa la fuente **Material Icons** (`md`), no MDI. Ponerles `mdi-` los busca en una fuente que no está cargada → cuadraditos. El "nombre mal" era en realidad "fuente distinta" (§4.7).
23. Diálogos/menús pueden montarse en el `v-app` equivocado (z-index y posicionamiento rotos); las variables de tema pueden bajar de un contexto y no del otro → colores inconsistentes. `v-app` debe ser **uno**, en la raíz (§4.3).
24. Se rompe el **grid**: si el CSS de Bootstrap se carga después del de Vuetify (o al revés), la definición de `.row` que gane pisa a la otra. Depende del **orden de imports**. Reordenar imports "inocentemente" puede romper todo el layout. Es la bomba de convivencia de VU3 (§3, y ESTRUCTURA §Convivencia).
25. Explota en la primera pantalla que use `v-dialog`, `v-menu`, `v-snackbar` o cualquier flotante — típicamente al abrir un modal (VU2 lo usa a full). La home solo tenía botones/texto, que se degradan pero "se ven", así que el bug quedó latente (§4.3).
26. El `mount()` del test no inyectó la **instancia de Vuetify**, entonces `this.$vuetify` es `undefined`. Le falta pasar `vuetify` (y a veces un `<v-app>` wrapper) en las opciones de montaje. **Es exactamente la segunda pregunta abierta de VU0**, que **VU2** resuelve (Concepto 5, dentro del helper `mountView`).
27. Porque el hardcode **no se entera** de que el tema cambió: el día que muevan `primary` en `vuetify.js`, todo lo que use `color="primary"` cambia, pero el `#1976D2` incrustado a mano queda con el color viejo → inconsistencia visual silenciosa. El theming en JS solo funciona si **todo** pasa por el tema (§4.5).
</details>

---

### 🔴 Muy difíciles (el nivel "ya leés Vuetify legacy solo")

**🔴 28.** **Auditoría de configuración.** Te dan un `plugins/vuetify.js` de 60 líneas de un repo real. Escribí un informe de media página que responda: (1) ¿full import o a-la-carte, y cómo lo confirmaste? (2) ¿cuántos temas hay y en qué difieren `light`/`dark`? (3) ¿qué `iconfont`, y hay riesgo de "el icono no sale"? (4) ¿hay `options` raras (`customProperties`, `variations`, `rtl`)? (5) **una deuda que ya podés predecir** solo leyendo este archivo.

<details><summary>Guía de evaluación 🔴 28</summary>
Buen informe: identifica el patrón de import por la línea de `import` (§4.4), cuenta temas y nombra al menos una diferencia de color, confirma la fuente de iconos contra los imports de fuente, y **predice** algo estructural (ej.: "full import → bundle ~500kb, deuda de VU3"; o "define `dark` pero ningún componente togglea `$vuetify.theme.dark` → el tema oscuro está muerto"). Predicción cosmética = insuficiente.
</details>

**🔴 29.** **Cazá el `v-app` fantasma.** Te dan un repo donde "a veces los modales no abren, a veces sí, según por qué ruta entraste". Sin ejecutarlo, formulá una hipótesis que explique la **intermitencia** (pista: ¿y si `v-app` está en un layout que solo envuelve **algunas** rutas, no todas?). Describí cómo lo confirmarías leyendo el router y los componentes de layout.

<details><summary>Guía de evaluación 🔴 29</summary>
La clave es entender que `v-app` da/quita capacidad **según el árbol de la ruta activa**. Si el `v-app` vive en un `LayoutA.vue` usado por unas rutas y otras rutas usan `LayoutB.vue` sin `v-app`, los modales abren en las primeras y no en las segundas → intermitencia "según por dónde entraste". Confirmación: mapear en el router qué rutas usan qué layout, y grep de `<v-app>` en los layouts. Conecta §4.3 con el patrón de layouts anidados de F1.
</details>

**🔴 30.** **El ejercicio de la fase.** Buscá un repo **Vuetify 2** real en GitHub (buscá en el buscador de código `"vuetify": "^2` junto a `v-data-table` o `plugins/vuetify.js`; o mirá los starters de la comunidad). Cloná uno, **sin correrlo**, y escribí un informe de 1 página:

1. **Datación:** versión de Vuetify, de Vue, de Vue CLI. ¿Cómo lo confirmaste? (`package.json` **y** un template).
2. **El plugin:** abrí `plugins/vuetify.js`. ¿Full o a-la-carte? ¿Cuántos temas? ¿Qué iconfont? ¿Alguna `option` rara?
3. **El `<v-app>`:** ¿dónde vive? ¿En `App.vue` o en un layout? ¿Envuelve **todas** las rutas? (si no, predecí un bug — ej. 29).
4. **Sedimento de grid:** grepeá `v-flex`/`v-layout` (v1) vs `v-col`/`v-row` (v2). ¿Conviven? ¿Cuánta de cada? Eso te dice si la migración a v2 quedó a medias.
   ```bash
   grep -rohE "<v-(flex|layout)" src/ | wc -l   # sintaxis v1
   grep -rohE "<v-(col|row)" src/ | wc -l        # sintaxis v2
   ```
5. **Deuda de bundle:** ¿full import? Estimá el impacto. ¿Hay `vuetify-loader` en `package.json` (señal de a-la-carte configurado)?
6. **Deuda de tema:** ¿hay colores hardcodeados en templates (`#hex`, `style="color:"`) que deberían salir del tema? (ej. 27). ¿Define `dark` pero nadie lo togglea?
7. **Un bug que ya podés predecir** sin correr el proyecto, y por qué.

> 💡 **¿Sin conexión o sin repo a mano?** Hacé el informe sobre tu Mini Jira **después de `vue add vuetify`** (secciones 1–3, 5) más un `plugins/vuetify.js` inventado con `v-flex` mezclado y un color hardcodeado (secciones 4, 6, 7). Lo que se entrena es la **lectura**, no de dónde salió el código.

<details><summary>Guía de evaluación 🔴 30</summary>

No hay solución única. Se evalúa:

- **(1)** ¿Cruzó `package.json` **y** un template? El grid (`v-col` vs `v-flex`) confirma la versión mejor que el `package.json` solo.
- **(2)** ¿Distinguió full de a-la-carte por la **línea de import**? (§4.4).
- **(3)** ¿Entendió que `v-app` mal ubicado = bug **intermitente** según la ruta? (ej. 29). Este es el punto que separa "leo Vuetify" de "entiendo Vuetify".
- **(4)** El grep de sedimento es el corazón del ejercicio legacy: **casi siempre conviven las dos sintaxis** en repos 2019–2021. Reconocerlo es la lección de la fase.
- **(6)** El mejor informe detecta la **deuda de tema silenciosa**: define `dark` pero nadie togglea `$vuetify.theme.dark` (tema muerto), o hex hardcodeados que ignoran el tema.
- **(7)** El mejor bug predicho es **estructural**: "full import + sin `vuetify-loader` → bundle ~500kb"; o "`v-app` solo en `LayoutMain`, la ruta `/login` usa otro layout → el snackbar de error de login no aparece"; o "Bootstrap y Vuetify comparten `.row`, y el orden de imports en `main.js` decide cuál gana".

**Este ejercicio es VU1 entero.** Si lo podés hacer, ya leés Vuetify legacy solo.
</details>

---

## 8. 📚 Referencias

### Vuetify 2 (⚠️ usá SIEMPRE el subdominio `v2.` — el raíz sirve v3)

- **Docs Vuetify v2 (oficial):** https://v2.vuetifyjs.com/
  > 🔥 **Guardá este link con la `v2.` delante.** Si googleás "vuetify v-data-table" caés en `vuetifyjs.com` (que es **v3**, Vue 3) y la API es distinta. Siempre `v2.vuetifyjs.com`.
- **Instalación / Vue CLI plugin (v2):** https://v2.vuetifyjs.com/en/getting-started/installation/
- **`v-app` y layouts (v2):** https://v2.vuetifyjs.com/en/components/application/
- **Theme configuration (v2):** https://v2.vuetifyjs.com/en/features/theme/
- **Grid system (v2):** https://v2.vuetifyjs.com/en/components/grid/
- **Breakpoints / `$vuetify.breakpoint` (v2):** https://v2.vuetifyjs.com/en/features/breakpoints/
- **Icons / iconfont (v2):** https://v2.vuetifyjs.com/en/features/icons/
- **A-la-carte / treeshaking (v2):** https://v2.vuetifyjs.com/en/features/treeshaking/
- **Material Design Icons (buscador de nombres `mdi-*`):** https://pictogrammers.com/library/mdi/
- **`vue add vuetify` (plugin):** https://github.com/vuetifyjs/vue-cli-plugins/tree/master/packages/vue-cli-plugin-vuetify

### Del curso base (releé si algo no cierra)

| Si te perdés en… | Volvé a… |
|---|---|
| Los tests de regresión que ya escribiste (y no tocás en VU1) | **VU0 — La red de seguridad** |
| Vue Router 3, rutas anidadas, layouts, el alias `@` | **F1 — Estructura base legacy** |
| El interceptor de axios que Vuetify **no toca** | **F2 — Autenticación mínima** |
| json-server, `baseURL` (que sigue igual en toda la ruta VU) | **F3 — Mock API mínima** |
| El dashboard con badges `badge-*` hardcodeados que **VU3** va a migrar | **F4 — Dashboard de tickets** |
| El CRUD, el `<b-modal>` y **vuelidate** que **VU2** va a migrar | **F5 — CRUD de tickets** |
| Vuex 3, módulos, `mapState` — que Vuetify **no toca** | **F10 — Vuex a fondo** |
| `Vue.use()`, plugins de Vue, la instancia raíz | **F1 — Estructura base legacy** |
| Bootstrap 4: grid `.row`/`.col`, badges, utilidades | **A1 — Bootstrap** |
| npm, `-g`, semver (`^2.6.x`) | **A3 — npm** |
| webpack, babel, el bundle | **A5 — webpack y babel** |

### Contraste con la ruta gemela (curiosidad, no camino)

- **Q1 — Leer Quasar.** Si ya la hojeaste: fijate que Quasar gasta su peso en `quasar.conf.js` y boot files (**estructura**), mientras VU1 lo gasta en **theming en JS**, `<v-app>` y la trampa de `v-flex`. **No son la misma fase con otro prefijo** — y si te suenan iguales, una de las dos está mal escrita.

---

## 9. 🌉 Cierre y puente a VU2

**Qué lograste:**

Podés abrir un repo Vuetify 2 y en 20 minutos armar el mapa mental completo. Sabés que:

- **Tu `main.js` sigue ahí.** Vuetify es un **plugin de Vue CLI**, no un build system. El router, Vuex, el interceptor de F2, tu estructura de carpetas — **todo sobrevive**. Eso es un **dato** sobre qué es Vuetify, no un atajo.
- **`<v-app>` es la raíz obligatoria** y su ausencia rompe todo **en silencio**: colores del tema que no aplican, diálogos que no abren, consola limpia. Es EL bug de Vuetify, y ahora te cuesta 5 segundos, no 2 horas.
- **El tema vive en JS**, en `plugins/vuetify.js`. El color `primary` no está en ningún CSS: es un objeto de datos. Cambiás una línea → cambia toda la app. Eso es lo que Bootstrap no puede y Quasar no regala.
- **El grid son componentes** (`v-container`/`v-row`/`v-col`), y en un repo legacy **conviven** con la sintaxis v1 (`v-layout`/`v-flex`). Reconocés las dos y traducís la vieja a la nueva de memoria.
- **`$vuetify.breakpoint`** te da los breakpoints en JS, no solo en CSS — ahí vive la lógica "solo en móvil".
- **"El icono no sale"** tiene tres causas conocidas y las descartás en orden.
- Y arrancamos con **full import** a propósito: ~500kb de bundle, deuda 💸 consciente que se paga con un ejercicio 🔴 en VU3.

**Lo que NO hiciste:** tocar el Mini Jira. Ni una línea. VU1 es reconocimiento y nada más.

**Y si tu trabajo es solo leer Vuetify** — parchear, revisar PRs, entender un flujo antes de una reunión — **acá podés parar**. En serio. VU1 es autosuficiente para eso, y es la mayoría de la gente.

---

### 🌉 Puente a VU2 — Migrar el CRUD

Ahora que sabés **dónde vive cada cosa** y **por qué el layout pinta (o no)**, VU2 te hace **mover** el CRUD de F5 a Vuetify.

| De… (curso base) | A… (VU2) | Qué aprendés |
|---|---|---|
| `<b-form-input v-model>` + **vuelidate** | `<v-text-field :rules="[...]">` | Que la validación **deja de ser tuya** |
| `$v.title.$touch()` / `$v.$error` | `<v-form v-model="valid">` | Que el flag de validez lo da el componente |
| El `<div v-if="error">` que pintabas a mano | El `v-text-field` pinta el error solo | Que borraste código de mostrar errores |
| `<select>` de F5 | `<v-select :item-text :item-value>` | El drama de emitir el `id` y no el objeto |
| `<b-modal>` de F5 | `<v-dialog>` | **El peso de VU2** — y que el dialog necesita el `<v-app>` que ya entendés |
| **`vuelidate` en `package.json`** | `:rules` | Que **sacás una dependencia entera** del proyecto |

**El spoiler incómodo de VU2:**

VU2 no es "cambiar `<b-form-input>` por `<v-text-field>`". F5 valida con **vuelidate 0.7.7**. Migrar a `:rules` significa **borrar vuelidate del `package.json`** — adiós `$v`, `$touch`, `$error`. Qué **ganás** (menos código, validación declarativa) y qué **perdés** (control fino del `$touch`, validación fuera del componente) en ese trueque es media VU2.

> ⚠️ **Aviso de peso:** VU2 es **más corta** que su gemela Q2, porque `v-form` ≈ `QForm` (casi idénticos). El peso extra de VU2 va a **`v-dialog`**, que es donde vive el CRUD, y que — spoiler — necesita el `<v-app>` que acabás de entender. Todo se conecta.

**La pregunta que abre VU2:**

> Tenés el CRUD de tickets (F5, con vuelidate) funcionando en Vue CLI + Bootstrap.
> Ya tenés Vuetify instalado sobre el mismo proyecto (tu `main.js` intacto).
> Y tenés los tests de regresión de VU0, intactos.
> **¿Qué reescribís, qué borrás porque Vuetify ya lo trae, qué dependencia sacás del `package.json` — y qué tests se ponen rojos sin que hayas roto nada?**

Y los tests de VU0 son el árbitro.

**Nos vemos en VU2.** 🚀
