# ⚙️ Apéndice 5 — Webpack y Babel (repaso de consulta)

## 🎯 Para qué sirve este apéndice

Todo el curso, dos comandos hicieron magia sin explicarse: `npm run serve` y
`npm run build`. Debajo están **webpack** (empaquetador) y **Babel**
(traductor), escondidos por Vue CLI. Este apéndice abre la caja lo justo:
qué problema resuelven, qué pasa exactamente al correr esos comandos, cómo
leer y tocar `vue.config.js`, y el diagnóstico de sus errores — que son de
los más crípticos del ecosistema precisamente porque la herramienta es
invisible hasta que falla.

---

## 🧩 El problema que resuelven (o: por qué src/ es "ilegal")

Mira lo que `src/` da por sentado y el navegador de la época NO entiende:

```js
import Vue from "vue";                        // ① módulos ES + resolver "vue"
import App from "./App.vue";                  // ② ¿.vue? eso no es un formato web
import "bootstrap/dist/css/bootstrap.min.css" // ③ ¿importar CSS desde JS?
// ...y sintaxis JS que navegadores viejos no hablan                    ④
```

La división del trabajo:

- **Webpack** resuelve ①②③: parte de `main.js` (el *entry*), sigue cada
  `import` construyendo el **grafo de dependencias** (tus archivos + lo de
  node_modules), pasa cada tipo de archivo por su **loader**, y lo funde todo
  en unos pocos archivos finales (el **bundle**) que cualquier navegador
  carga con `<script>` y `<link>` normales.
- **Babel** resuelve ④: traduce (*transpila*) JavaScript moderno a JavaScript
  viejo, según qué navegadores declares soportar.

```
main.js ──import──▶ App.vue ──▶ router, store, components, axios, bootstrap.css...
   └──────────────── webpack recorre el grafo ────────────────┘
          cada archivo pasa por su loader ▼
   .vue → vue-loader │ .js → babel-loader │ .css → css-loader
                     ▼
        dist/  →  app.[hash].js + chunk-vendors.[hash].js + css + index.html
```

## 🚚 Los loaders — el traductor de cada dialecto

Webpack solo entiende JavaScript; los loaders convierten todo lo demás:

| Loader | Traduce | 📍 Conexión con el curso |
|---|---|---|
| **vue-loader** | descompone el `.vue` en sus tres bloques y despacha cada uno | TODO componente del curso pasa por aquí |
| (dentro) **vue-template-compiler** | `<template>` → *render functions* de JS | por eso su versión debe = la de vue (F0/F1), y por eso es devDependency (Apéndice 3): el navegador recibe funciones, no HTML |
| **babel-loader** | JS moderno → JS compatible | ver Babel abajo |
| **css-loader + extractores** | CSS importado desde JS → hojas de estilo reales | el `import bootstrap.css` de la F0 |
| **file/url-loader** | imágenes, fuentes → archivos con hash o base64 | assets/ |

## 🈯 Babel — el traductor de sintaxis

Babel reescribe sintaxis nueva en equivalente viejo: arrow functions →
`function`, spread → `Object.assign`-ish, clases → prototipos, etc. Dos
piezas de configuración:

- **`@babel/preset-env`**: el "traduce lo necesario" — decide QUÉ transformar
  según los navegadores objetivo.
- **`browserslist`** (en package.json o `.browserslist`): la lista de
  navegadores objetivo — `"> 1%", "last 2 versions", "not dead"` típico de
  la época. Cambiarla cambia cuánto traduce Babel (y cuánto pesa el bundle).

📍 **La conexión con la Fase 10:** la nota sobre `...mapGetters()` vs
`Object.assign` era exactamente esto — el *spread en objetos* es sintaxis que
Babel debe soportar/transformar según su versión y presets. "Esta sintaxis
funciona en un proyecto y explota en otro" casi siempre es Babel config, no
JavaScript. Distinción fina: Babel traduce **sintaxis**; los **métodos**
nuevos (`Promise.allSettled` — F9, `Array.includes`) son *polyfills*, otra
capa (core-js) que preset-env también puede inyectar. Sintaxis vs API: dos
problemas, dos soluciones.

## 🔥 `npm run serve` — el modo desarrollo

Lo que realmente ocurre:

```
1. webpack compila TODO a memoria (no escribe dist/)
2. levanta un servidor HTTP local (webpack-dev-server, :8080)
3. queda VIGILANDO tus archivos:
   guardas un archivo → recompila SOLO ese módulo → lo inyecta al navegador
   sin recargar la página = HMR (Hot Module Replacement)
```

HMR explica magias y rarezas del curso: editas un componente y lo ves al
instante **conservando el estado** de los demás… casi siempre. Cuando el
estado queda raro tras muchos hot-reloads (el store confundido, un socket
duplicado), un F5 honesto reinicia el mundo — no es tu bug, es HMR llegando
a su límite. Y los cambios en `vue.config.js` o `.env` **no** se
hot-recargan: reinicia el serve (clásico "cambié la config y no pasa nada").

## 📦 `npm run build` — el modo producción

```
vue-cli-service build
 └─ NODE_ENV=production → minificar, tree-shaking, sin warnings de dev
 └─ escribe dist/:
    index.html                    ← con los <script>/<link> ya inyectados
    js/app.[hash].js              ← TU código
    js/chunk-vendors.[hash].js    ← node_modules (cambia poco → caché aparte)
    css/app.[hash].css
```

Los `[hash]` cambian con el contenido: **cache-busting** — el navegador
cachea agresivo y aun así los usuarios reciben la versión nueva porque el
nombre cambió. Y el detalle que muerde en el deploy: `dist/` es **estático**
— con el `mode: "history"` del router (F1), entrar directo a `/tickets/5`
pide ese archivo al servidor… que no existe. El servidor debe responder
`index.html` para toda ruta desconocida (el *history fallback*; el dev
server lo hace solo — producción hay que configurarlo). Si el build "funciona
en local y da 404 en el servidor al refrescar", es esto.

📍 `process.env.NODE_ENV !== "production"` (strict mode, F10) funciona porque
webpack **reemplaza esa expresión por el literal** en build-time — en el
bundle de producción queda `"production" !== "production"` → `false`, y la
minificación borra el código muerto del strict mode. No hay Node en el
navegador: hay un recado dejado al compilar (Apéndice 2 lo anticipó).

## 🎛️ `vue.config.js` — la perilla sin abrir la caja

Vue CLI genera la config de webpack internamente; `vue.config.js` (en la
raíz, junto a package.json) la ajusta. Las tres entradas que un dev de
mantenimiento usa de verdad:

```js
// vue.config.js
module.exports = {
  // 1) PROXY del dev server — la mejora natural del curso:
  //    el frontend pide a /api (mismo origen: adiós CORS, adiós URL hardcodeada)
  //    y el dev server reenvía a json-server
  devServer: {
    proxy: {
      "/api": {
        target: "http://localhost:3000",
        pathRewrite: { "^/api": "" }
      }
    }
  },
  // 2) publicPath: si la app se sirve bajo una subruta (ej. /mini-jira/)
  publicPath: process.env.NODE_ENV === "production" ? "/mini-jira/" : "/",
  // 3) escotillas a webpack crudo, cuando las perillas no alcanzan:
  configureWebpack: { /* se FUSIONA con la config generada */ }
};
```

📍 El proxy es la versión adulta del `routes.json` del ejercicio 23 de la
Fase 3: con él, `apiClient` usa `baseURL: "/api"` — sin host, sin puerto —
y el mismo código sirve para dev (proxy) y producción (el servidor real
monta la API bajo /api). Las URLs absolutas hardcodeadas del curso
(`localhost:3000`, `localhost:4000` en F8) eran la deuda didáctica; esta es
la forma de pagarla.

Para ver la config completa que Vue CLI generó: `npx vue inspect > webpack.txt`
— largo pero revelador; ahí están los loaders, el alias y todo lo descrito
aquí, con nombre y apellido.

### Env vars — `VUE_APP_*`

```
.env                → VUE_APP_API_URL=/api        (todas las builds)
.env.development    → VUE_APP_SOCKET_URL=http://localhost:4000
.env.production     → VUE_APP_SOCKET_URL=https://sockets.miempresa.com
```

```js
// en el código:
var socketUrl = process.env.VUE_APP_SOCKET_URL;
```

Solo las prefijadas `VUE_APP_` llegan al bundle (protección contra filtrar
secretos del build por accidente — que igual: **nada en un bundle frontend es
secreto**, cualquiera lo lee). Son reemplazo en build-time, como NODE_ENV:
cambiar un `.env` requiere reiniciar/rebuildar. Ejercicio natural: migrar las
URLs de `apiClient` y `socketService` a esto.

### El alias `@`

`@` → `src/` está definido en la config de webpack que Vue CLI genera
(`resolve.alias`). El `jsconfig.json` de la Fase 1 le enseña **al editor** el
mismo mapa, y el preset de Jest (F11) se lo enseña **a los tests**
(`moduleNameMapper`). Tres herramientas, un alias, tres configuraciones — si
`@` funciona al compilar pero no en el editor o en los tests, ya sabes cuál
de las tres copias falta.

---

## ⚠️ Diagnóstico rápido

| Síntoma | Causa probable |
|---|---|
| `Vue packages version mismatch` | `vue` ≠ `vue-template-compiler` — el clásico de F0/F1 |
| "You are using the runtime-only build..." | config apuntando al build de Vue sin compilador mientras usas `template:` en JS — en proyectos CLI, casi siempre síntoma de config tocada |
| `Module not found: Can't resolve '@/...'` | alias roto o typo de ruta; recuerda: webpack, editor y Jest tienen SU copia del alias |
| Cambié `vue.config.js` / `.env` y nada | requieren reiniciar `npm run serve` — no hay hot-reload de config |
| Funciona con serve, 404 al refrescar en producción | history mode sin fallback a index.html en el servidor |
| El bundle pesa una barbaridad | `import _ from "lodash"` trae TODO lodash; los imports puntuales (`import debounce from "lodash/debounce"`) dejan tree-shakear — audita con `build --report` |
| Sintaxis que explota solo en ciertos navegadores/build | Babel: browserslist demasiado moderna, o sintaxis fuera del preset |
| Estado rarísimo en dev sin explicación | HMR acumulado — F5 y volver a juzgar |
| Build lentísimo de repente | caché de webpack corrupta: borra `node_modules/.cache` antes de medidas drásticas |

---

## 🧪 Ejercicios (35) — todos opcionales

> Los apéndices son material de consulta y práctica libre. Haz los que te
> sirvan, cuando te sirvan.

**🟢 Fácil (1–10)**

1. Corre `npm run build` y explora `dist/` a mano: abre el index.html,
   identifica app vs chunk-vendors, verifica los hashes.
2. Abre `dist/js/app.[hash].js` y busca un string tuyo ("Mini Jira").
   Contempla tu código minificado — y confirma con tus ojos que nada del
   bundle es secreto.
3. `npx vue inspect --rules`: lista los loaders activos. Identifica los cinco
   de la tabla de este apéndice.
4. Rompe y repara el mismatch de `vue-template-compiler`, ahora entendiendo
   QUIÉN lanza ese error.
5. Cambia algo en `vue.config.js` sin reiniciar el serve y comprueba que no
   pasa nada. Reinicia y confirma.
6. Haz dos builds seguidos sin cambiar código: ¿los hashes son iguales?
   ¿Y si cambias una letra de un componente?
7. Mide el tiempo de `npm run build` y el peso total de `dist/`. Anótalos:
   son tu línea base para los ejercicios de optimización.
8. Provoca un error de sintaxis a propósito en un `.vue` y lee el error de
   webpack completo: identifica el archivo, la línea y el loader que se
   quejó.
9. Añade un `console.log(process.env.NODE_ENV)` en `main.js` y compara lo que
   imprime en serve vs en un build servido localmente.
10. Encuentra el `browserslist` del proyecto (package.json o
    `.browserslistrc`) y tradúcelo con `npx browserslist` a la lista real de
    navegadores.

**🟡 Intermedio (11–20)**

11. Sirve el build de producción localmente (`npx serve dist`), navega a
    `/tickets/5` directo y presencia el 404 del history mode. Investiga la
    opción de fallback.
12. Configura el proxy `/api` del ejemplo, cambia `baseURL` a `"/api"` en
    apiClient y verifica que TODO sigue funcionando — sin CORS y sin hosts
    hardcodeados. (Guárdalo: es mejora permanente.)
13. Migra `SOCKET_URL` (F8) a `VUE_APP_SOCKET_URL` con `.env.development` y
    `.env.production`. Confirma que cambiar el archivo exige reiniciar.
14. Añade una variable SIN el prefijo `VUE_APP_` y comprueba que no llega al
    bundle. Entiende la protección.
15. `npx vue inspect > webpack.txt`: busca el `resolve.alias` y encuentra el
    `@`. Localiza también su gemelo en la config de Jest (F11).
16. Rompe el alias en el editor (borra el `jsconfig.json`) y observa qué se
    pierde (autocompletado) sin que la compilación falle. Tres copias, tres
    dueños.
17. Cambia `browserslist` a solo `"last 1 Chrome version"`, rebuild y compara
    el tamaño del bundle. Vuelve atrás. Acabas de medir el precio de IE11.
18. Añade un alias propio (`@utils` → `src/utils`) vía `configureWebpack` y
    hazlo funcionar también en el editor y en los tests. Tres archivos, un
    concepto.
19. Importa un SVG desde un componente y descubre qué loader lo maneja y qué
    devuelve (URL vs inline). Cambia el límite de `url-loader` y observa el
    cambio en el bundle.
20. Genera un source map de producción, provoca un error en la app servida y
    verifica que DevTools te muestra el código original. Investiga por qué
    subir source maps a producción es una decisión (no un default).

**🟠 Difícil (21–25)**

21. Reporte de bundle (`--report` o webpack-bundle-analyzer): abre el treemap
    e identifica los 3 paquetes más pesados. ¿Sorpresas? (lodash y bootstrap
    suelen dar conversación.)
22. Convierte los `import _ from "lodash"` a imports puntuales
    (`lodash/countBy`), re-mide y documenta los KB ganados.
23. Lazy loading de rutas: convierte las rutas pesadas (métricas con
    chart.js, el panel) a imports dinámicos
    (`component: () => import("../views/MetricsView.vue")`). Verifica en
    Network que los chunks se cargan al navegar. Mide el impacto en el bundle
    inicial.
24. Arqueología inversa: toma UNA función de `src/utils/`, pásala por el REPL
    de babeljs.io con dos targets (moderno vs `ie 11`) y compara. Después
    búscala minificada en tu bundle real. Acabas de seguir una línea de
    código desde tu editor hasta el navegador.
25. Polyfills: usa `Promise.allSettled` (F9) en el código, apunta
    browserslist a un navegador viejo, y descubre si Babel lo polyfillea
    solo. Investiga `useBuiltIns` y core-js hasta hacerlo funcionar.
    Sintaxis vs API, en carne propia.

**🔴 Muy difícil (26–35)**

26. Webpack desde cero: monta el proyecto SIN Vue CLI — tu propio
    `webpack.config.js` con vue-loader, babel-loader, css-loader,
    HtmlWebpackPlugin y dev server, hasta que `serve` y `build` funcionen.
    Compáralo con lo que Vue CLI generaba (`vue inspect`). Es el ejercicio
    que convierte la magia en ingeniería.
27. Plugin de webpack propio: uno que, en cada build, escriba un
    `build-info.json` en `dist/` con fecha, versión del package.json y hash
    de git. Muéstralo en la app en un `/about`. Bienvenido a los hooks de
    compilación.
28. Loader propio: escribe un loader que transforme archivos `.rules` (tu
    máquina de estados en un formato custom) a un módulo JS. Úsalo para
    cargar `ticketTransitions.rules`. Entenderás para siempre qué es un
    loader.
29. Optimización agresiva: `splitChunks` afinado (separa vendor "estable" de
    vendor "volátil"), `runtimeChunk`, y compresión gzip/brotli en build.
    Mide el resultado contra la línea base del ejercicio 7 y presenta un
    informe con números.
30. Presupuesto de rendimiento (performance budget): configura webpack para
    que **falle el build** si el bundle inicial supera X KB. Elige el X con
    criterio (justifícalo con el tipo de usuarios del Mini Jira) y arregla el
    proyecto hasta cumplirlo.
31. Migración a Vite (el experimento honesto): monta el proyecto con Vite +
    `@vitejs/plugin-vue2`. Descubre qué funciona igual, qué rompe (CommonJS
    en dependencias, `require`, globals de jQuery) y cuánto costaría de
    verdad. Escribe el informe: la pregunta "¿migramos el build?" te la harán
    en un legacy real, y esta es la respuesta con datos.
32. Módulo Federation / micro-frontend de juguete: expón el panel de soporte
    como un módulo remoto consumible por otra app webpack. (Requiere webpack
    5: hazlo en un proyecto aparte y evalúa qué implicaría subir de webpack
    4 a 5 el Mini Jira.)
33. Build determinista y auditable: consigue que dos builds del mismo commit
    produzcan bytes idénticos (hashes de contenido, orden de módulos,
    timestamps). Investiga qué lo rompe. Es requisito real en entornos
    regulados.
34. Análisis de tiempos de build: instrumenta el build (speed-measure-plugin
    o los hooks del ej. 27) para saber qué loader/plugin consume el tiempo.
    Optimiza el más caro (caché de babel, `thread-loader`, excluir
    node_modules) y presenta el antes/después. En un legacy grande, el build
    de 8 minutos es un problema de negocio, no un capricho.
35. El informe de modernización: con TODO lo aprendido (este apéndice, los
    ejercicios 28 de A3 y 31 de aquí), escribe `MODERNIZATION.md` — la
    evaluación honesta de qué costaría llevar el Mini Jira a Vue 3 + Vite +
    Pinia: qué se migra mecánicamente, qué exige reescribir (filters, event
    bus, `$on`, vuelidate 0.x, chart.js 2, socket.io 2), en qué orden, con
    qué riesgos y qué red de seguridad (los tests de F11). Este documento es
    el entregable final del curso — el que separa a quien "sabe Vue 2" de
    quien **puede hacerse cargo** de un Vue 2.

## 📚 Referencias

- Vue CLI — guía y vue.config.js: https://cli.vuejs.org/config/
- Vue CLI — modos y env vars: https://cli.vuejs.org/guide/mode-and-env.html
- webpack 4 — conceptos (la versión de Vue CLI 3/4): https://v4.webpack.js.org/concepts/
- vue-loader: https://vue-loader.vuejs.org/
- Babel — preset-env: https://babeljs.io/docs/babel-preset-env
- browserslist: https://github.com/browserslist/browserslist
- REPL de Babel (ej. 10): https://babeljs.io/repl
- history mode y fallback del servidor:
  https://v3.router.vuejs.org/guide/essentials/history-mode.html
