# 🧰 Apéndice A4 — CRA por Dentro

Material de **consulta rápida**, no de lectura secuencial. Lo abrís cuando una
fase te manda acá o cuando `react-scripts` hace algo que no entendés y querés
saber qué pasa por debajo.

La Fase 0 te prometió dos cosas: explicarte *qué hace Webpack escondido bajo
CRA* y *por qué no hacemos `eject`*. Este apéndice paga esa promesa. También
cubre variables de entorno, el proxy de desarrollo y un puñado de trucos de
performance que vas a necesitar cuando el bundle empiece a pesar.

> ⚠️ **Qué NO es esto.** No es un tutorial de Webpack ni de Babel. No vas a
> aprender a escribir un `webpack.config.js` desde cero —justamente porque el
> chiste de CRA es que no lo tocás. Acá aprendés a *convivir* con la caja
> negra: qué podés cambiar sin abrirla, qué pasa si la abrís, y cuándo (casi
> nunca) vale la pena.

Contexto que damos por sabido: Node y npm (Apéndice A3), y que la app corre en
el puerto `3000`, el CRUD mock en `3001` y la lotería mock en `3002` (Fase 3).

---

## 🔎 Salto rápido

1. [react-scripts, el Webpack que no ves](#1-react-scripts-el-webpack-que-no-ves)
2. [Estructura de carpetas: `public/`, `src/`, `node_modules/`](#2-estructura-de-carpetas)
3. [Environment variables: `.env` y sus variantes](#3-environment-variables)
4. [Proxy en desarrollo: `setupProxy.js`](#4-proxy-en-desarrollo-setupproxyjs)
5. [Customizar sin `eject`](#5-customizar-sin-eject)
6. [`eject`: qué hace y por qué (casi) nunca](#6-eject-qué-hace-y-por-qué-casi-nunca)
7. [Performance: code splitting, lazy, source maps](#7-performance-hints)
8. [🗺️ Tabla: cuándo hacer qué](#8-️-tabla-cuándo-hacer-qué)
9. [🧪 Ejercicios cortos](#-ejercicios-cortos-7)
10. [📚 Referencias](#-referencias)

---

## 1. react-scripts, el Webpack que no ves

**Cuándo mirar acá:** buscaste `webpack.config.js` en la raíz del proyecto y no
existe. No estás loco: CRA lo esconde.

Cuando corrés `npm start` o `npm run build`, no ejecutás Webpack directo:
ejecutás `react-scripts`, un paquete que trae adentro una configuración
completa y ya armada de Webpack, Babel, ESLint, PostCSS y un dev server con
hot reload. Vos ves cuatro archivos en `src/`; `react-scripts` maneja cientos
de líneas de config por debajo. Esa config vive, en solo-lectura, dentro de
`node_modules/react-scripts/config/`.

Los cuatro scripts que te da CRA 4:

| Script | Qué hace |
|---|---|
| `npm start` | Dev server en `3000` con hot reload y source maps completos |
| `npm run build` | Bundle optimizado y minificado en `build/` para producción |
| `npm test` | Corre Jest en modo watch (ver Fase 10) |
| `npm run eject` | Vuelca toda la config oculta a tu repo — **irreversible** (§6) |

**Ejemplo mínimo — espiar la config sin romper nada:**

```bash
# La config real de Webpack que usa react-scripts, en solo-lectura.
# Leela para entender; NO la edites (los cambios se pierden en el próximo npm i).
cat node_modules/react-scripts/config/webpack.config.js | less
```

**Error común:** crear un `webpack.config.js` en la raíz esperando que CRA lo
tome. No lo hace: CRA ignora cualquier config de Webpack que pongas vos. O lo
customizás por los caminos permitidos (§5), o hacés `eject` (§6). No hay punto
medio nativo.

---

## 2. Estructura de carpetas

**Cuándo mirar acá:** no sabés si un archivo va en `public/` o en `src/`, o por
qué una imagen no carga en producción.

```
raffles-app/
├── public/              # servido tal cual, sin procesar por Webpack
│   ├── index.html       # la única página; el div#root vive acá
│   ├── favicon.ico
│   └── logo-lottery.png # assets que referenciás por URL absoluta
├── src/                 # todo lo que Webpack procesa y empaqueta
│   ├── index.js         # punto de entrada: ReactDOM.render en #root
│   ├── App.jsx
│   ├── api/apiClient.js
│   ├── components/
│   └── setupProxy.js    # config del proxy de dev (§4), si existe
├── node_modules/        # dependencias; nunca se toca a mano, nunca se commitea
├── build/               # salida de npm run build; se genera, no se versiona
├── .env                 # variables de entorno (§3)
├── package.json
└── package-lock.json    # lockfile — ver Apéndice A3
```

La regla que resuelve el 90% de las dudas: **`src/` lo procesa Webpack;
`public/` no.** Si importás un archivo desde JavaScript (`import logo from
'./logo.png'`), va en `src/` y Webpack le pone un hash, lo optimiza y te
garantiza que existe en build-time. Si lo referenciás por URL suelta desde el
HTML o necesitás una ruta estable y conocida, va en `public/` y lo pedís con
`%PUBLIC_URL%`.

**Ejemplo mínimo — cada asset en su lugar:**

```jsx
// src/components/Header.jsx
// Import procesado por Webpack: hash, optimización, error en build si no existe.
import logo from "../assets/logo-lottery.png";

function Header() {
  return <img src={logo} alt="Rifas y chances" />; // alt en español (UI)
}
```

```html
<!-- public/index.html -->
<!-- %PUBLIC_URL% lo reemplaza CRA por la base del sitio en build-time. -->
<link rel="icon" href="%PUBLIC_URL%/favicon.ico" />
```

**Error común:** poner un asset en `public/` y después importarlo desde `src/`
con `import '../../public/foo.png'`. Rompe o duplica el archivo. Si lo vas a
`import`, movelo a `src/`. Los de `public/` se referencian por URL, nunca por
import.

---

## 3. Environment variables

**Cuándo mirar acá:** querés que la app apunte a distinta URL según el ambiente,
o metiste una variable en `.env` y `undefined` te mira de vuelta.

Dos reglas mandan en CRA 4:

1. **Solo las variables con prefijo `REACT_APP_` llegan al código del navegador.**
   Cualquier otra cosa que pongas en `.env` la ignora el bundle del cliente.
   (Ya lo viste en la Fase 0 con `REACT_APP_ORGANIZER`.)
2. **Se inyectan en build-time, no en runtime.** El valor queda *horneado* en el
   bundle cuando corrés `build`. Cambiar el `.env` después no cambia un bundle
   ya compilado: hay que reconstruir.

CRA carga varios archivos y los combina con esta precedencia (gana el de más
arriba):

| Archivo | Cuándo se carga | Se commitea |
|---|---|---|
| `.env.development.local`, `.env.production.local` | Local + ambiente | ❌ No |
| `.env.local` | Siempre, salvo en `test` | ❌ No |
| `.env.development` / `.env.production` | Según `npm start` vs `npm run build` | ✅ Sí |
| `.env` | Siempre (base) | ✅ Sí |

`npm start` corre en modo `development`; `npm run build` corre en `production`.
CRA elige el archivo de ambiente solo, según el script.

**Ejemplo mínimo — la URL del mock por ambiente:**

```bash
# .env.development  → lo toma npm start
REACT_APP_API_URL=http://localhost:3001

# .env.production   → lo toma npm run build
REACT_APP_API_URL=https://api.uat.internal
```

```js
// src/api/apiClient.js
// En Fase 3 el baseURL vino hardcodeado a http://localhost:3001 (deuda 💸).
// Acá se ve cómo se salda: leerlo del entorno según el ambiente.
export const apiClient = axios.create({
  baseURL: process.env.REACT_APP_API_URL, // horneado en build-time
  timeout: 5000,
});
```

> 💡 **Contraste con el `.env` del mock.** El `.env` que la Fase 3 usa para
> `CHAOS_LEVEL` es de un **proceso Node** (`server.js`), no del bundle de CRA.
> Por eso `CHAOS_LEVEL` **no** lleva prefijo `REACT_APP_`: lo lee
> `process.env` de Node en el servidor, no el navegador. Dos mundos distintos
> que comparten el nombre "variable de entorno" y confunden a todo el mundo al
> menos una vez.

**Error común (y peligroso):** creer que `REACT_APP_` te da un lugar para
guardar secretos. **No.** Todo lo que empieza con `REACT_APP_` termina en texto
plano dentro del bundle que baja el navegador — cualquiera lo lee con las
DevTools. API keys reales y contraseñas van en el backend, nunca en el cliente.

---

## 4. Proxy en desarrollo: `setupProxy.js`

**Cuándo mirar acá:** en desarrollo pegás contra `json-server` en `3001` y el
navegador te tira errores de CORS, o querés que `/api/...` vaya al mock sin
escribir el host completo en cada request.

CRA levanta el dev server en `3000` y el mock en `3001`: son orígenes distintos,
y el navegador aplica CORS. Un proxy de desarrollo hace que el dev server
reenvíe ciertas rutas al mock, así que desde el navegador todo parece salir del
mismo origen (`3000`).

Para reglas simples alcanza el campo `"proxy"` en `package.json`. Para control
fino —varias rutas, reescrituras, varios destinos— usás
`src/setupProxy.js`, que CRA detecta y carga solo (no se importa en ningún
lado). Necesita `http-proxy-middleware`, que ya viene con `react-scripts`.

**Ejemplo mínimo — `/api` al CRUD, `/lottery` a la lotería:**

```js
// src/setupProxy.js
// CRA carga este archivo automáticamente en desarrollo. No hace falta importarlo.
const { createProxyMiddleware } = require("http-proxy-middleware");

module.exports = function (app) {
  // El CRUD de rifas vive en el mock de la Fase 3, puerto 3001.
  app.use(
    "/api",
    createProxyMiddleware({
      target: "http://localhost:3001",
      changeOrigin: true,
      pathRewrite: { "^/api": "" }, // /api/raffles → /raffles en el mock
    })
  );

  // La lotería simulada vive aparte, en 3002 (Fase 7).
  app.use(
    "/lottery",
    createProxyMiddleware({ target: "http://localhost:3002", changeOrigin: true })
  );
};
```

**Error común:** asumir que el proxy también aplica en producción. **No.**
`setupProxy.js` es exclusivo del dev server (`npm start`). El bundle de
`npm run build` no lo incluye: en producción el ruteo lo resuelve tu servidor
real (nginx, el gateway, lo que sea). Por eso el `baseURL`/env de §3 sigue
importando: el proxy te salva de CORS en dev, no te configura producción.

---

## 5. Customizar sin `eject`

**Cuándo mirar acá:** necesitás cambiar *algo* del comportamiento de build y
estás por escribir `npm run eject`. Frená: probablemente no haga falta.

Sin `eject`, CRA 4 te deja tocar bastante por caminos oficiales:

- **Variables de entorno** (§3) — URLs, flags, comportamiento por ambiente.
- **Proxy de desarrollo** (`setupProxy.js`, §4).
- **Target de navegadores** — el campo `browserslist` en `package.json`, que
  controla qué transpila Babel y qué prefijos agrega PostCSS.
- **Jest, parcialmente** — la clave `jest` en `package.json` acepta un subconjunto
  de opciones (ver Fase 10).
- **Source maps** — la variable `GENERATE_SOURCEMAP` (§7).

Lo que **no** podés sin `eject`: reescribir la config de Webpack, cambiar
loaders, meter plugins de Babel arbitrarios.

Para ese caso hay una tercera vía que evita el `eject`: herramientas como
**CRACO** o **react-app-rewired**, que inyectan overrides sobre la config de CRA
sin volcarla a tu repo. Mantenés las actualizaciones de `react-scripts` y
sumás solo tus cambios.

> 🔥 **Opcional.** CRACO/react-app-rewired son ampliación, no parte del alcance
> base del curso. Si el sistema real los usa, se documentan aparte; acá basta
> saber que existen como alternativa a `eject`.

**Ejemplo mínimo — apuntar el target de navegadores sin tocar Webpack:**

```jsonc
// package.json
"browserslist": {
  "production": [">0.2%", "not dead", "not op_mini all"],
  "development": ["last 1 chrome version", "last 1 firefox version"]
}
```

**Error común:** llegar a `eject` sin haber probado los caminos de arriba. El
80% de lo que la gente cree que "necesita eject" se resuelve con una env var,
el proxy o `browserslist`.

---

## 6. `eject`: qué hace y por qué (casi) nunca

**Cuándo mirar acá:** alguien en el equipo propuso ejectar, o heredaste un
proyecto ya ejectado y querés entender en qué te metiste.

`npm run eject` vuelca toda la configuración oculta —Webpack, Babel, ESLint,
los scripts— a carpetas `config/` y `scripts/` dentro de tu repo, y reemplaza
la dependencia `react-scripts` por sus decenas de dependencias sueltas en tu
`package.json`.

**Es irreversible.** No hay `un-eject`. Una vez ejectado, sos dueño de toda
esa config para siempre.

Qué ganás: control total sobre el build. Qué perdés (y es caro):

- **Las actualizaciones de `react-scripts` dejan de existir para vos.** Cada
  fix, cada parche de seguridad que Facebook publicaba en un solo paquete, ahora
  tenés que replicarlo a mano sobre tu config.
- **Pasás a mantener ~30 dependencias de build** que antes estaban prolijamente
  encapsuladas.
- **El onboarding se complica:** cualquiera que llegue al proyecto ahora tiene
  que entender tu Webpack en vez de "es CRA estándar".

> 💸 **Deuda técnica.** Ejectar es contraer una deuda de mantenimiento
> permanente a cambio de flexibilidad puntual. En un proyecto de *mantenimiento*
> como el nuestro —donde el objetivo es tocar poco y romper nada— casi nunca
> compensa. Se justifica solo si necesitás una customización de build imposible
> por los otros caminos (§5) **y** el equipo asume conscientemente el costo de
> mantener la config.

**Ejemplo mínimo — no lo hagas para espiar:**

```bash
# NO ejecutes esto solo para "ver la config".
# Para eso ya tenés (§1):
cat node_modules/react-scripts/config/webpack.config.js
```

**Error común:** ejectar para resolver un problema puntual —"necesito un loader
raro"— sin evaluar CRACO (§5) primero, y quedar con una config propia enorme
por una necesidad que tenía salida más barata.

---

## 7. Performance hints

**Cuándo mirar acá:** el `bundle.js` que viste en el Network tab (Fase 0)
empezó a pesar, o el dashboard (Fase 9) tarda en aparecer.

### Code splitting con `React.lazy` + `Suspense`

Por defecto CRA empaqueta todo en un bundle que el usuario baja entero antes de
ver nada. Con `React.lazy` partís el código por ruta o por componente pesado:
cada pieza se baja solo cuando se necesita.

```jsx
// src/App.jsx
import React, { lazy, Suspense } from "react";
import { Route, Switch } from "react-router-dom"; // Router 5, ver Fase 1

// El dashboard (Fase 9, con gráficos pesados) se baja solo al entrar a /dashboard.
const Dashboard = lazy(() => import("./features/dashboard/Dashboard"));

function App() {
  return (
    // fallback: lo que se muestra mientras baja el chunk. Texto en español (UI).
    <Suspense fallback={<p>Cargando…</p>}>
      <Switch>
        <Route path="/dashboard" component={Dashboard} />
      </Switch>
    </Suspense>
  );
}
```

**Error común:** usar `React.lazy` sin envolverlo en un `<Suspense>`. React tira
un error en runtime: todo componente lazy necesita un `Suspense` con `fallback`
arriba en el árbol.

### Source maps

Los source maps mapean el bundle minificado de vuelta a tu código original para
que puedas depurar con nombres reales en las DevTools. En `npm start` están
siempre activos. En `npm run build`, CRA 4 los genera por defecto y podés
controlarlo con `GENERATE_SOURCEMAP`:

```bash
# Build de producción sin source maps (no exponés tu código fuente).
GENERATE_SOURCEMAP=false npm run build
```

**Error común:** dejar source maps públicos en producción sin pensarlo, y
regalar tu código fuente completo a cualquiera que abra las DevTools. Es una
decisión consciente: depurabilidad en UAT contra exposición en PROD. Una salida
intermedia habitual es generarlos pero servirlos solo a tu herramienta de
errores (Sentry y similares), no al público.

---

## 8. 🗺️ Tabla: cuándo hacer qué

| Querés… | Hacé | NO hagas | Por qué |
|---|---|---|---|
| Cambiar la URL del API mock por ambiente | `REACT_APP_API_URL` en `.env.development` / `.env.production` | Hardcodear el `baseURL` (deuda de Fase 3) | El bundle de cada ambiente apunta solo, sin tocar código |
| Guardar una variable solo en tu máquina | `.env.local` (no se commitea) | Commitear un `.env` con datos sensibles | `.env.local` está fuera de git; pero recordá que `REACT_APP_` **igual** viaja al bundle |
| Un secreto de verdad (API key real) | Ponelo en el backend | Meterlo en cualquier `REACT_APP_*` | Todo `REACT_APP_` queda en texto plano en el cliente |
| Evitar CORS contra json-server en dev | `src/setupProxy.js` con `http-proxy-middleware` | Confiar en el proxy para producción | El proxy es solo del dev server; PROD lo resuelve otro servidor |
| Ver la config de Webpack | Leer `node_modules/react-scripts/config/` (solo-lectura) | `eject` para espiar | Ejectar es irreversible; para entender no hace falta |
| Customizar el build sin perder CRA | CRACO / react-app-rewired 🔥, o env vars y `browserslist` | `eject` de entrada | Mantenés `react-scripts` actualizable |
| Un cambio de build imposible por otra vía, con equipo que lo va a mantener | `eject`, consciente y documentado | Ejectar sin plan de mantenimiento | Pasás a ser dueño de ~30 deps de build para siempre |
| Reducir el bundle inicial | `React.lazy` + `Suspense` por ruta | Importar todo en `App.jsx` | El usuario baja solo el código de la vista que abre |
| Depurar PROD/UAT con stack real | Source maps servidos a tu herramienta de errores | Dejarlos públicos en PROD sin pensarlo | Exponen tu código fuente: es seguridad vs debug |
| Entender un error de build raro | Leer el output de `react-scripts build` + este apéndice | `eject` "para ver qué pasa" | Casi siempre se resuelve sin abrir la caja negra |

---

## 🧪 Ejercicios cortos (7)

1. 🟢 Buscá en tu proyecto la config real de Webpack de CRA sin ejectar. ¿En
   qué ruta de `node_modules` está? Abrila en solo-lectura y encontrá la línea
   donde define el punto de entrada (`entry`).

2. 🟢 Creá `REACT_APP_API_URL` en `.env.development` apuntando a
   `http://localhost:3001` y logueala con `console.log(process.env.REACT_APP_API_URL)`
   en `src/index.js`. Después sacá el prefijo `REACT_APP_` (dejala como
   `API_URL`) y confirmá que ahora imprime `undefined`. Explicá por qué.

3. 🟡 Escribí un `src/setupProxy.js` que mande `/api/*` al CRUD de `3001` y
   `/lottery/*` a la lotería de `3002`. Verificá con el Network tab que un
   `GET /api/raffles` desde la app sale sin error de CORS.

4. 🟡 Tenés `REACT_APP_API_URL` en `.env` y otra distinta en `.env.development`.
   Corré `npm start` y determiná cuál gana. Después agregá `.env.local` con una
   tercera y volvé a mirar. Ordená las tres por precedencia según lo que
   observaste.

5. 🟠 Convertí una ruta de tu router (por ejemplo `/dashboard`) a carga con
   `React.lazy`. Confirmá en el Network tab que aparece un chunk `.js` aparte
   que **solo** se baja al navegar a esa ruta. Después quitá el `<Suspense>` a
   propósito, reproducí el error en runtime y anotá el mensaje exacto.

6. 🟠 Corré `npm run build` dos veces: una normal y otra con
   `GENERATE_SOURCEMAP=false`. Compará el contenido de `build/static/js/`:
   ¿qué archivos aparecen o desaparecen? Explicá el trade-off entre las dos
   builds para un ambiente de UAT y para PROD.

7. 🔴 Alguien propone `eject` para agregar un loader de Webpack. Sin ejectar,
   escribí una nota de una carilla para el equipo que: (a) liste dos caminos
   alternativos que habría que descartar primero, (b) enumere qué se pierde al
   ejectar, y (c) dé el único criterio bajo el cual lo aprobarías. Apoyate en §5
   y §6.

---

## 📚 Referencias

### Documentación oficial

- **Create React App — Getting Started:** https://create-react-app.dev/docs/getting-started — cubre versiones recientes; nosotros usamos **4.0.3**, así que algunas features no aplican. Útil para scripts y estructura.
- **CRA — Adding Custom Environment Variables:** https://create-react-app.dev/docs/adding-custom-environment-variables — el prefijo `REACT_APP_`, precedencia de archivos `.env`, build-time vs runtime.
- **CRA — Proxying API Requests in Development:** https://create-react-app.dev/docs/proxying-api-requests-in-development — campo `"proxy"` simple y `setupProxy.js`.
- **CRA — Code Splitting:** https://create-react-app.dev/docs/code-splitting — `React.lazy`, `Suspense` y split por ruta.
- **CRA — Available Scripts / eject:** https://create-react-app.dev/docs/available-scripts — qué hace cada script, incluido `eject`.
- **React — `React.lazy` y `Suspense`:** https://legacy.reactjs.org/docs/code-splitting.html — doc legacy (React 16), coherente con nuestra versión.
- **http-proxy-middleware:** https://github.com/chimurai/http-proxy-middleware — opciones de `createProxyMiddleware` (`target`, `pathRewrite`, `changeOrigin`).

> ⚠️ **Advertencia de versión.** La doc de CRA cubre releases posteriores a la
> **4.0.3** que usamos. Las ideas (env vars, proxy, code splitting) son
> estables entre versiones, pero verificá cualquier detalle fino contra tu
> `react-scripts@4.0.3`. Las URLs y títulos pueden haber cambiado: confirmalos.

### Apéndices y fases relacionadas

- **Apéndice A3 — Node y npm:** lockfiles, `npm ci` vs `npm i`, semver, `.nvmrc`.
- **Fase 0 — Setup y Hola Mundo con CRA:** el error de OpenSSL/Node, `REACT_APP_ORGANIZER`, primer vistazo al Network tab.
- **Fase 3 — Mock API:** `apiClient` con su `baseURL`, puertos `3001`/`3002`, el `.env` con `CHAOS_LEVEL` del proceso Node.

### Orden de lectura sugerido

Este apéndice §1–§3 → doc de env vars de CRA → doc de proxy → volver a
`setupProxy.js` con los puertos de la Fase 3 → §5–§6 antes de que a alguien se
le ocurra ejectar.
