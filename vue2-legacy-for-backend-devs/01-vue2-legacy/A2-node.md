# 🟢 Apéndice 2 — Node (repaso de consulta)

## 🎯 Para qué sirve este apéndice

La paradoja del frontend moderno-legacy: el Mini Jira **corre en el
navegador**, pero no existe sin Node. Este apéndice explica esa relación —
qué es Node, qué papel juega en el proyecto, y las dos o tres cosas de su
mundo (módulos, versiones, APIs) con las que ya chocaste durante el curso sin
que las nombráramos del todo. Consúltalo cuando un error de terminal (no del
navegador) te deje mirando la pantalla.

---

## 🧠 Qué es Node, en un párrafo

Node.js es el motor de JavaScript de Chrome (V8) sacado del navegador y
puesto en tu máquina, con APIs para lo que un navegador no hace: leer
archivos, abrir servidores, hablar con el sistema operativo. Mismo lenguaje,
otro hábitat: en Node no existen `window`, `document` ni el DOM; existen
`fs`, `http`, `process`.

## 🗺️ Los cuatro papeles de Node en el Mini Jira

Aunque ninguna línea de `src/` corre en Node en producción, Node está debajo
de todo:

| Papel | Qué hace | 📍 En el curso |
|---|---|---|
| 🔧 **Tooling** | Vue CLI, webpack, babel, jest, ESLint — todos son programas Node que transforman tu código | `npm run serve/build/test:unit` (F0, F11, Apéndice 5) |
| 🎭 **Mocks** | servidores falsos para desarrollar sin backend | Stubby (F0), json-server (F3) |
| 📡 **Servidor real (mini)** | el único código nuestro que SÍ corre en Node | `server/socket-server.js` (F8), middlewares de json-server (ejs. F3/F5/F9) |
| 📜 **Scripts** | utilidades de un solo uso | el generador de 5.000 tickets (F7 ej. 21) |

La consecuencia práctica: cuando algo falla, primero pregúntate **en qué
mundo falló** — un error en la terminal es del mundo Node (tooling, mocks,
server); un error en la consola del navegador es del mundo frontend. Es la
primera bifurcación de todo diagnóstico.

---

## 🔢 Versiones y NVM (el resumen ejecutivo de la Fase 0)

- La versión del curso es **Node 14.21.3** (16.20.2 en macOS Apple Silicon),
  documentada en `.nvmrc`. No es nostalgia: el tooling de la época
  (Vue CLI 3, webpack 4, node-sass si aparece) **rompe** con Node modernos.
- NVM existe porque en una misma máquina convives con proyectos que exigen
  Node distintos. Ritual al entrar a cualquier proyecto ajeno:
  `cat .nvmrc` (si existe) → `nvm use` → `node -v` para confirmar.
- El error delator de versión equivocada: instalaciones que compilan binarios
  nativos y fallan con murallas de `node-gyp`/`gyp ERR!`, o paquetes que
  gritan `The engine "node" is incompatible with this module`. Antes de
  googlear el error: **verifica la versión**. Resuelve el 70% de las veces.

---

## 📦 CommonJS vs ES Modules — los dos idiomas que el repo mezcla

Esta es LA fuente de confusión del proyecto, así que va con calma. Hay dos
sistemas de módulos en JavaScript:

| | CommonJS (CJS) | ES Modules (ESM) |
|---|---|---|
| Importar | `var x = require("mod")` | `import x from "mod"` |
| Exportar | `module.exports = {...}` | `export default {...}` / `export function` |
| Origen | el de Node desde siempre | el estándar del lenguaje (2015) |
| Carga | síncrona, dinámica (puede ir dentro de un if) | estática (analizable por herramientas) |
| Quién lo entiende | Node nativamente | navegadores modernos y... webpack |

**¿Por qué nuestro repo tiene ambos?** Porque tiene dos mundos:

- **`src/`** usa `import/export` — pero ojo: el navegador de la época no lo
  ejecuta directo; **webpack+babel lo traducen** al empaquetar (Apéndice 5).
  El ESM de `src/` es para las herramientas, no para Node.
- **`server/socket-server.js`, middlewares, scripts** usan `require` —
  porque los ejecuta **Node 14 directamente** (`node server/socket-server.js`),
  y Node 14 sin configuración extra solo habla CommonJS.

El error que delata la confusión (lo viste o lo verás):

```
SyntaxError: Cannot use import statement outside a module
```

Traducción: *le diste un archivo ESM a Node pelado*. Pasa al intentar
`require`/ejecutar algo de `src/` desde un script Node — exactamente el
problema del **ejercicio 24 de la Fase 9** (compartir `ticketTransitions.js`
con el middleware de json-server). Las salidas de la época, de más a menos
usada: escribir el archivo compartido en CJS, mantener dos copias con un
comentario de vergüenza, o compilarlo. La lección de fondo: **un archivo que
deba correr en ambos mundos debe hablar el idioma del más limitado** (CJS),
porque webpack entiende ambos pero Node 14 no.

Dos extras de ESM que el curso usa y conviene nombrar: los **named exports**
(`import { countByStatus } from ...` — F7) contra el default
(`import apiClient from ...`), y que los módulos ESM se evalúan **una vez** —
el fundamento de los singletons `apiClient` y `socketService` (F8, mini
repaso).

---

## 🔌 Las APIs de Node que el curso rozó

No hace falta el catálogo completo; sí reconocer las que aparecieron:

```js
// http — el servidor de sockets (F8): crear un server sin Express
var http = require("http");
var server = http.createServer();
server.listen(4000, callback);

// fs — archivos: el watch del ejercicio 22 (F8), el generador de datos (F7 ej. 21)
var fs = require("fs");
fs.writeFileSync("db.json", JSON.stringify(data, null, 2));
fs.watch("db.json", callback);

// process — el proceso actual: env vars y argumentos
process.env.NODE_ENV      // "development"/"production" — el strict mode (F10)
process.argv              // argumentos de línea de comandos
process.exit(1)           // terminar con código de error

// path + __dirname — rutas a prueba de sistema operativo
var path = require("path");
path.join(__dirname, "db.json");  // __dirname = carpeta de ESTE archivo
```

Sobre `process.env.NODE_ENV`: en `src/` ese código lo **reemplaza webpack en
build-time** por el string literal (Apéndice 5) — no es Node corriendo en el
navegador, es Node dejando un recado antes de empaquetar. Sutil pero
importante para no buscarle tres pies al gato.

## ⚙️ El event loop en cinco líneas (por qué todo es async)

Node ejecuta tu JavaScript en **un solo hilo**. Para no congelarse esperando
(disco, red), delega esas operaciones al sistema y sigue; cuando terminan,
sus callbacks entran a una cola que el *event loop* va despachando. Por eso
el ecosistema entero es asíncrono — los callbacks del socket server (F8), las
Promises de todo el curso (F3) y el `setTimeout` del login mock son la misma
mecánica con distinta ropa. Y por eso un `while(true)` en un middleware de
json-server congela **todo** el mock: un hilo es un hilo.

---

## ⚠️ Diagnóstico rápido

| Síntoma (en la TERMINAL) | Causa probable |
|---|---|
| `Cannot use import statement outside a module` | archivo ESM ejecutado por Node pelado — reescribe en CJS o revisa qué estás ejecutando |
| `gyp ERR!` / muralla de compilación al instalar | versión de Node incompatible con el paquete (o Apple Silicon con Node 14 → F0: usa 16.20.2) |
| `The engine "node" is incompatible` | ídem: `nvm use` antes de reinstalar |
| `EADDRINUSE: address already in use :::3000` | algo ya usa el puerto — un json-server zombie de otra terminal; mátalo o cambia el puerto |
| `Cannot find module 'x'` | dependencia sin instalar (`npm install`), o ruta relativa mal escrita en un `require` |
| `node -v` distinto entre terminales | NVM configura por sesión de shell — corre `nvm use` en la nueva, o define `nvm alias default` |
| El script "no hace nada" y termina | olvidaste el `listen`/callback, o todo era async y el proceso terminó antes — Node muere cuando no queda trabajo pendiente |

---

## 🧪 Ejercicios (35) — todos opcionales

> Los apéndices son material de consulta y práctica libre. Haz los que te
> sirvan, cuando te sirvan.

**🟢 Fácil (1–10)**

1. Corre `node` a secas (REPL): evalúa `2+2`, `process.version` y
   `typeof window`. Sal con `.exit`.
2. `scripts/hola.js` que imprima sus argumentos (`process.argv`). Córrelo con
   `node scripts/hola.js uno dos`.
3. Provoca `EADDRINUSE`: levanta json-server dos veces. Aprende a encontrar y
   matar el proceso culpable en tu sistema operativo.
4. Copia una función pura de `src/utils/` a un script y ejecútala con Node.
   Documenta qué tuviste que cambiar (spoiler: el export).
5. Imprime `__dirname` y `process.cwd()` desde un script ejecutado desde dos
   carpetas distintas. Explica la diferencia.
6. Lee `db.json` con `fs.readFileSync` + `JSON.parse` e imprime cuántos
   tickets hay.
7. Comprueba que Node no tiene DOM: intenta `document.querySelector` en el
   REPL y lee el error con cariño.
8. `nvm ls`, `nvm current`, `node -v`, `npm -v`: haz el inventario de tu
   máquina y anota qué versiones tienes.
9. Cambia de versión de Node con `nvm use 16` (si la tienes) y verifica que
   `npm -v` cambió también: npm viaja con Node.
10. Añade un `console.log(process.version)` al arranque del socket server
    (F8) y confirma en qué Node corre.

**🟡 Intermedio (11–20)**

11. `scripts/stats.js`: lee `db.json` con `fs`, cuenta tickets por estado
    (reusa la lógica de `countByStatus`, adaptada a CJS) e imprime la tabla.
12. Provoca `Cannot use import statement outside a module` haciendo
    `require("../src/utils/ticketStats")` desde ese script. Anota el mensaje
    completo: lo reconocerás para siempre.
13. Puerto por variable de entorno: `process.env.SOCKET_PORT || 4000` en el
    socket server. Pruébalo con `SOCKET_PORT=4500 node server/socket-server.js`.
14. `scripts/seed.js` que genere N tickets falsos (N por `process.argv`) y
    escriba `db.json`. La base del ejercicio 21 de la F7.
15. Async en Node: reescribe el lector de `db.json` con la versión callback
    (`fs.readFile`) y luego con `fs.promises`. Compara los tres estilos
    (sync, callback, promesa) del Apéndice 4 / F3.
16. Script que valide `db.json`: cada ticket tiene los campos obligatorios y
    un `status` de la máquina de estados. Sale con `process.exit(1)` si algo
    falla — ya es un lint de datos.
17. Middleware de json-server (F3 ej. 24) que loguee cada request con método,
    ruta y timestamp. Es tu primer código Node en el camino del request real.
18. Servidor HTTP mínimo sin librerías: `http.createServer` que responda
    `{"pong": true}` en `/ping`. Sin Express, sin nada. Entiende qué te
    regalan las librerías midiendo lo que cuesta no tenerlas.
19. Lee variables de un `.env` a mano (sin dotenv): parsea el archivo con
    `fs` y puebla `process.env`. Luego instala `dotenv` y compara.
20. Añade al socket server (F8) el conteo de clientes conectados expuesto en
    un endpoint HTTP `/health` del mismo proceso (`http` + socket.io
    conviviendo).

**🟠 Difícil (21–25)**

21. Congela el mock a propósito: middleware con un busy-wait de 5 segundos.
    Observa desde el navegador cómo TODAS las rutas esperan. El event loop,
    sentido en carne propia. Ahora hazlo con `setTimeout` y explica por qué
    NO congela.
22. Watcher casero: `fs.watch` sobre `db.json` que emita un evento de socket
    `tickets:changed` (F8 ej. 22). Cuidado con los eventos duplicados que
    `fs.watch` dispara — investiga por qué pasa y mitígalo con debounce.
23. Middleware de autenticación real en json-server: valida el JWT falso
    (F2 ej. 25) decodificando el payload base64 y verificando `exp`. Rechaza
    con 401. Sin librerías de JWT: a mano, con `Buffer.from(x, "base64")`.
24. Streams: escribe un script que lea un `db.json` de 100 MB (genéralo
    primero) sin cargarlo entero en memoria, usando streams + un parser
    incremental. Compara el uso de RAM contra `readFileSync` con
    `process.memoryUsage()`.
25. Haz que `ticketTransitions.js` funcione en ambos mundos (F9 ej. 24):
    patrón UMD-casero (detectar `module.exports` y asignar condicionalmente)
    o doble build. Implementa una, documenta por qué es incómoda.

**🔴 Muy difícil (26–35)**

26. Backend real de reemplazo: sustituye json-server por un Express propio
    (~150 líneas) con las mismas rutas, persistiendo en un JSON en disco.
    Ahora el `API-CONTRACT.md` (F3) es TU contrato: cúmplelo exactamente
    para que el frontend no note el cambio — cambiar el backend sin tocar una
    línea de `src/` es la prueba definitiva de la capa de servicios.
27. Sobre ese backend: implementa la autorización de verdad (el
    `SECURITY-NOTES.md` de nueve fases pidiéndolo) — validar el token, que
    el `reporter` salga del token y no del payload, que solo el assignee
    resuelva. Repite los ataques de los ejercicios de F8/F9 y verifica que
    ahora fallan. Este ejercicio cierra la historia de seguridad del curso.
28. Emisión de sockets desde el backend (no desde el cliente): cuando el
    POST /tickets confirma, ES EL SERVIDOR quien emite `ticket:created`.
    Elimina el emit del cliente (F8). El "cliente mentiroso" del ejercicio 24
    de la F8 queda muerto por diseño. Documenta la diferencia arquitectónica.
29. Autenticación con JWT firmado de verdad: genera y verifica con
    `crypto.createHmac` (sin librerías), con secreto en variable de entorno,
    expiración real y refresh token. Reimplementa el interceptor del cliente
    para el refresh. Ahora sí es un sistema de auth, no un mock.
30. Worker threads: mueve la generación de un reporte pesado (agregar 100.000
    tickets) a un `worker_thread` para no bloquear el event loop. Demuestra
    con timestamps que el servidor sigue respondiendo mientras calcula.
31. Cluster: arranca N procesos del backend con el módulo `cluster` (uno por
    core). Descubre que los sockets se rompen (cada worker tiene sus
    conexiones) e investiga por qué en producción se usa un adaptador
    (Redis). Escribe qué implicaría hacerlo bien.
32. CLI del proyecto: un `bin/minijira.js` con subcomandos
    (`seed`, `stats`, `validate`, `reset`) usando solo `process.argv`
    parseado a mano (o `commander` si prefieres). Añádelo a `package.json`
    como `bin` y úsalo con `npx`.
33. Watch mode propio: un script que vigile `src/utils/*.js` y corra sus
    tests de Jest afectados al guardar (sin usar el `--watch` de Jest:
    `fs.watch` + `child_process.spawn`). Entenderás qué hacen por dentro
    todas las herramientas "watch" que usas.
34. Migración de datos: script que transforme `db.json` del esquema actual a
    uno nuevo (ej. añadir `updatedAt` a todos los tickets, normalizar
    estados viejos), con backup previo, dry-run (`--dry`) y reporte de
    cambios. Es exactamente lo que harás en un legacy real el día que el
    modelo cambie.
35. Perfilado: genera carga contra tu backend (un script con N requests
    concurrentes usando `http` nativo), perfila con
    `node --prof` / `--inspect` y encuentra el cuello de botella real.
    Documenta el hallazgo. Sabrás medir en vez de adivinar — la habilidad
    más rara del mantenimiento.

## 📚 Referencias

- Node.js — docs de la línea 14: https://nodejs.org/docs/latest-v14.x/api/
- Node.js — diferencias CJS/ESM: https://nodejs.org/docs/latest-v14.x/api/modules.html
- NVM (Linux/macOS): https://github.com/nvm-sh/nvm
- nvm-windows: https://github.com/coreybutler/nvm-windows
- El event loop, explicado (charla clásica "What the heck is the event
  loop anyway?" — Philip Roberts, JSConf): buscar en YouTube
