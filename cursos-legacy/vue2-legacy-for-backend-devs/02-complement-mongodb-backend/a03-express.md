# 🚂 Apéndice 3 — Express a fondo

## 🎯 Para qué sirve este apéndice

La Fase 10 dijo la verdad: Express es el vehículo, no el tema. Pero un vehículo
que no entiendes te deja tirado — y el legacy de 2018–2021 está construido
sobre Express 4 con costumbres que hoy parecen arbitrarias y tienen razones
muy concretas.

Aquí está lo que la Fase 10 usó sin justificar, empezando por lo más importante:
**por qué existe ese `asyncHandler` que envolvía todos tus controllers**. Si
solo lees una sección de este apéndice, que sea esa: es el bug número uno de
los backends Node de la época, y explica el 90% de los "el servidor se colgó y
no dejó ni un log".

---

## 🧠 El modelo mental único: una tubería de funciones

Express no es un framework: es un **despachador de middlewares**. Todo — el
parser de JSON, el logger, tus rutas, el manejo de errores — es la misma cosa:
una función `(req, res, next)` en una fila que se ejecuta **en el orden en que
la registraste**.

```js
app.use(logger);           // 1º
app.use(express.json());   // 2º
app.use("/tickets", ticketsRouter);   // 3º
app.use(notFound);         // 4º  (si nadie respondió antes)
app.use(errorHandler);     // 5º  (el de 4 argumentos: solo si hubo error)
```

Cada middleware tiene exactamente tres salidas:

| Hace | Consecuencia |
|---|---|
| `res.send()/json()/status().end()` | **responde**: la tubería se acaba ahí |
| `next()` | pasa al siguiente middleware |
| `next(err)` | salta a la vía de errores (el handler de 4 args) |
| *nada de lo anterior* | 💀 **el request queda colgado para siempre** — sin respuesta, sin error, sin log. El cliente espera hasta su timeout |

Esa última fila es el corazón del apéndice. Recuérdala.

> 🩻 **Esto SÍ funciona igual:** es la cadena de filtros de tu servlet
> container, el pipeline de middleware de ASP.NET, los interceptores de Spring.
> Mismo patrón, sintaxis distinta. Lo que cambia es que aquí **nadie te
> protege** si una función olvida terminar su trabajo.

---

## 💥 La sección estrella: `async` y por qué Express 4 no lo atrapa

### El bug

```js
// ⚠️ EL BUG. Este código parece correcto y NO lo es.
router.get("/:id", async function (req, res) {
  const ticket = await service.getById(req.params.id);   // ← si esto REVIENTA...
  res.json(ticket);
});
```

Si `service.getById` rechaza (Mongo caído, ObjectId inválido, un `throw`
tuyo), la promesa devuelta por tu handler queda **rechazada y sin dueño**.
Express 4 fue escrito en 2014, antes de `async/await`: **no mira lo que tu
handler devuelve**. Para él, tu función simplemente… terminó sin responder y
sin llamar a `next()`. Resultado:

- el cliente **cuelga** hasta su timeout (no recibe ni un 500);
- tu error handler **nunca se entera**;
- en la consola, un `UnhandledPromiseRejectionWarning` — que en Node 14 es un
  warning, y desde Node 15 **mata el proceso**;
- tu monitoreo no ve nada. El request se evaporó.

### Las tres curas de la época (las verás las tres en legacy)

```js
// CURA 1 — try/catch en CADA handler: correcta, explícita, insoportable
router.get("/:id", async function (req, res, next) {
  try {
    const ticket = await service.getById(req.params.id);
    res.json(ticket);
  } catch (err) {
    next(err);                     // ⬅️ la línea que salva el request
  }
});

// CURA 2 — el wrapper asyncHandler: LO QUE USÓ LA FASE 10
function asyncHandler(fn) {
  return function (req, res, next) {
    Promise.resolve(fn(req, res, next)).catch(next);   // ⬅️ toda la magia
  };
}
router.get("/:id", asyncHandler(async function (req, res) {
  res.json(await service.getById(req.params.id));      // sin try/catch: el wrapper lo hace
}));

// CURA 3 — el paquete express-async-errors (un require y ya)
require("express-async-errors");   // parchea Express por dentro. Cómodo y mágico.
```

🔎 **Qué hace la cura 2:** `Promise.resolve(...)` normaliza (funcione tu
handler con async o sin él), y `.catch(next)` **conecta la vía de rechazo de
promesas con la vía de errores de Express**. Cinco líneas que arreglan el
agujero estructural del framework. Por eso todo backend serio de la época
tenía este helper — o el paquete que lo hace por dentro.

> 📝 **Nota legacy honesta:** en **Express 5** (que tardó una década en salir)
> esto se arregló: el framework sí atrapa promesas rechazadas. Pero tu legacy
> es Express 4, y lo será por años. Cuando audites un backend Node y **no
> encuentres** ni try/catch, ni wrapper, ni `express-async-errors`: acabas de
> encontrar un bug latente en cada handler async. Es de los hallazgos más
> valiosos que puedes reportar.

### El primo del bug: errores en callbacks y en código síncrono

```js
// Express SÍ atrapa los throws SÍNCRONOS (y solo esos):
app.get("/x", function (req, res) { throw new Error("boom"); });   // ✅ va al handler

// Pero NO los de un callback asíncrono:
app.get("/y", function (req, res, next) {
  setTimeout(function () { throw new Error("boom"); }, 10);        // 💀 mata el proceso
});
// La regla: dentro de cualquier callback async, los errores se pasan con next(err) A MANO
```

---

## 🚦 El error handler y los códigos del contrato

```js
// src/middleware/errorHandler.js — SIEMPRE el último app.use, SIEMPRE 4 argumentos
// (Express identifica el handler de errores por la ARIDAD: 4 args = error handler.
//  Si escribes 3, es un middleware normal y nunca verá un error. Bug clásico.)
function errorHandler(err, req, res, next) {
  // Errores esperados: los que TÚ lanzaste con intención
  if (err.status) {
    return res.status(err.status).json({ error: err.message });
  }
  // Errores del motor que sabes traducir (F4: el validator)
  if (err.code === 121) {
    return res.status(422).json({ error: "Documento inválido" });
  }
  // Lo inesperado: 500 seco, log completo, CERO detalles al cliente
  console.error(err);                                  // el stack, a TU log
  res.status(500).json({ error: "Internal server error" });   // nada al atacante
}
```

✅ **Buenas prácticas sembradas:** una clase `HttpError` propia (con `status`)
para lo esperado; el stack **nunca** viaja al cliente (regalo para un
atacante); y los códigos del contrato (404 real, 409 del doble-tomar, 401/403
de la F11, 413 del upload de la F12) se lanzan desde el service y se traducen
aquí — **un solo lugar decide el HTTP**.

---

## 🧱 Las piezas que la Fase 10 montó, explicadas

```js
const app = express();

app.use(morgan("dev"));               // ① log de requests
app.use(cors());                      // ② el navegador y su Same-Origin Policy
app.use(express.json({ limit: "1mb" }));   // ③ el body parser
app.use(helmet());                    // ④ cabeceras de seguridad (A4)

app.use("/tickets", ticketsRouter);   // ⑤ router montado con prefijo
app.use("/comments", commentsRouter);

app.use(notFound);                    // ⑥ nadie respondió → 404
app.use(errorHandler);                // ⑦ 4 args, el último
```

**① morgan.** Formato `dev` para desarrollo (coloreado, conciso); `combined`
(Apache) para producción, que es lo que tu agregador de logs espera.

**② cors.** El navegador bloquea las llamadas del frontend (`:8080`) a otro
origin (`:3000`) salvo que el servidor lo permita. `cors()` a secas abre a
todos — aceptable en desarrollo, **no en producción**: restringe con
`{ origin: "http://localhost:8080" }`. Ojo con el detalle que muerde: el
navegador manda un **preflight OPTIONS** antes de un PATCH con headers custom
(tu `Authorization`), y si tu servidor no lo contesta, el PATCH nunca sale.
Cuando "la petición no llega al backend pero curl funciona": es CORS,
siempre.

**③ express.json.** Parsea el body **solo si el `Content-Type` es
application/json**. Los dos bugs eternos: (a) sin él, `req.body` es
`undefined` — no vacío, *undefined*; (b) con `Content-Type` mal puesto por el
cliente, tampoco parsea, y culparás a Express. El `limit` no es cosmético: sin
él, un body de 500 MB es tu denegación de servicio.

**⑤ Router.** Un `Router` es una mini-app montable. El `router.get("/:id")`
montado en `/tickets` responde `/tickets/:id` — el prefijo vive en el
montaje, no en las rutas. Ventaja: mueves el recurso de URL cambiando una
línea.

**⑥ El 404.** Como el `notFound` es solo "un middleware al que nadie respondió
antes", el **orden importa**: si lo pones antes de los routers, todo es 404.
El error más cómico y más común.

### `req` y `res`, lo que de verdad usas

```js
req.params.id        // de la ruta /:id
req.query.status     // del ?status=open        ⚠️ TODO llega como string... o como OBJETO
req.body             // parseado (si hubo parser Y content-type correcto)
req.headers.authorization
req.user             // ⬅️ NO existe: lo pone TU middleware de auth (F11). Convención, no API

res.status(201).json(x)
res.status(204).end()
res.set("Content-Type", ...)     // F12: los streams
res.sendStatus(404)              // status + cuerpo de texto: OJO, rompe el contrato JSON
```

> 💥 **`req.query` no siempre es un string.** `?status=open` te da `"open"`.
> Pero `?status[$ne]=null` te da **un objeto** `{ $ne: null }` — porque el
> parser de query strings de Express soporta sintaxis anidada. Ese objeto,
> pasado directo a un filtro de Mongo, **es la inyección NoSQL de la Fase 11**.
> El apéndice A4 lo desarma a fondo; aquí queda dicho de dónde nace: no es
> culpa de Mongo, es del query parser.

---

## 🧩 Chuleta

```js
// Middleware = (req, res, next). Se ejecutan EN ORDEN de registro.
// Salidas: responder · next() · next(err) · 💀 nada (request colgado)

// ⭐ EL BUG DE LA ÉPOCA: Express 4 NO atrapa promesas rechazadas
const asyncHandler = fn => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);
// alternativas: try/catch en cada handler · require("express-async-errors")
// Express 5 lo arregla — tu legacy es 4

// Error handler: 4 ARGUMENTOS (la aridad lo identifica) y SIEMPRE el último
(err, req, res, next) => ...   // 3 args = middleware normal = nunca ve errores

// Orden canónico:
//   logger → cors → json → helmet → routers → notFound → errorHandler

// req.query puede ser OBJETO (?a[$ne]=1) → inyección NoSQL (A4)
// req.user lo pone TU middleware, no Express
// sin express.json → req.body === undefined
// CORS: el preflight OPTIONS es el que falla, no tu PATCH
```

---

## ⚠️ Diagnóstico rápido

| Síntoma | Causa |
|---|---|
| El request **cuelga** sin respuesta ni log | un handler async sin wrapper/try-catch que rechazó (¡EL bug!), o un middleware que no llamó a `next()` ni respondió |
| `UnhandledPromiseRejectionWarning` | lo mismo, visto desde el proceso |
| Todo devuelve 404 | el `notFound` registrado antes de los routers |
| `req.body` es `undefined` | falta `express.json()` — o el cliente no mandó `Content-Type: application/json` |
| El error handler nunca se ejecuta | lo escribiste con 3 argumentos, o no es el último `app.use` |
| `Cannot set headers after they are sent` | dos respuestas en el mismo request (típico: `res.json()` y luego `next()`) |
| Funciona con curl, falla desde el navegador | CORS (mira el OPTIONS en la pestaña Network) |
| El PATCH "no llega al servidor" | el preflight OPTIONS fue rechazado |
| El proceso muere sin explicación | `throw` dentro de un callback asíncrono |
| Recibes 413 sin querer | el `limit` del body parser (o de multer, F12) |

---

## 🧪 Ejercicios (34) — todos opcionales

**🟢 Fácil (1–10)**

1. Middleware propio de 5 líneas que loguee método, ruta y timestamp. Regístralo primero y verifica que lo ve TODO; muévelo al final y observa que ya no ve nada.
2. Reproduce el request colgado: un handler que no responde ni llama a `next()`. Míralo colgar en el navegador y en curl. Mata el suspense con un `res.json` y respira.
3. **Reproduce EL bug:** handler `async` sin wrapper que lanza. Observa: cliente colgado, `UnhandledPromiseRejectionWarning` en consola, error handler mudo. Ahora envuélvelo con `asyncHandler` y verifica el 500 limpio.
4. Escribe `asyncHandler` de memoria (5 líneas) y aplícalo a todos tus controllers. Cuenta cuántos handlers async tenía tu Fase 10 **sin** protección (si es que alguno).
5. Error handler con 3 argumentos: escríbelo mal a propósito, lanza un error y comprueba que nunca se ejecuta. Añade el cuarto argumento. La aridad como API: raro pero real.
6. Lanza los códigos del contrato desde el service con una clase `HttpError(status, message)` y tradúcelos en un solo lugar. Prueba 404, 409 y 422.
7. Provoca `Cannot set headers after they are sent`: responde y luego llama a `next()`. Lee el error y explica en un comentario por qué Express se queja.
8. Quita `express.json()` y haz un POST con body. ¿Qué vale `req.body`? Ahora ponlo de vuelta pero manda `Content-Type: text/plain`. ¿Y ahora?
9. Router montado: mueve `/tickets` a `/api/tickets` cambiando UNA línea. Verifica que ninguna ruta interna se tocó.
10. `morgan("dev")` vs `morgan("combined")`: mira ambas salidas para el mismo request. ¿Cuál le darías a tu agregador de logs y por qué?

**🟡 Intermedio (11–22)**

11. Reproduce el bug de CORS: quita `cors()` y llama desde el frontend. Lee el error EXACTO del navegador. Ahora restringe el origin y verifica que el frontend entra y otro origin no.
12. El preflight en vivo: haz un PATCH con header `Authorization` y observa en la pestaña Network el OPTIONS que lo precede. Bloquéalo (config de cors sin `allowedHeaders`) y verifica que el PATCH ni se intenta.
13. Middleware de autenticación (F11) escrito de cero: lee el header, verifica, pone `req.user`, o `next(err)` con 401. Añade un `requireRole("agent")` encadenable. Encadena ambos en una ruta.
14. El orden como bug: coloca tu middleware de auth DESPUÉS del router de tickets. ¿Qué pasa? Explica en una línea qué acabas de aprender sobre el orden.
15. `req.query` hostil: haz `GET /tickets?status[$ne]=null` a tu API y loguea `typeof req.query.status` y su contenido. Fotografía el objeto. (No lo pases a Mongo todavía: eso es el A4.)
16. Body parser con límite: baja `limit` a `1kb` y manda un ticket con descripción larga. ¿Qué status recibes? Conviértelo en un error decente del contrato.
17. Middleware de tiempo: mide la duración de cada request (`Date.now()` al entrar, en el `res.on("finish")` al salir) y loguéala. ¿Por qué en `finish` y no después de `next()`? (Piensa en async.)
18. Un middleware que responda solo bajo condición (por ejemplo, mantenimiento activado por env var: 503 para todos menos `/health`). Regístralo en el sitio correcto de la tubería.
19. `express.static`: sirve una carpeta con un HTML de prueba desde tu API y llama a tus endpoints desde ahí. Bonus: ahora estás en el mismo origin — ¿sigue haciendo falta CORS?
20. Reescribe tres controllers en los tres estilos de la época (callbacks del driver, `.then/.catch`, async con wrapper). Compara legibilidad y manejo de errores. ¿Cuál te encontrarás en un repo de 2018? ¿Y en uno de 2021?
21. Testea el error handler (F13, ej. 18): mockea el service para lanzar y afirma 500 con cuerpo seguro (sin stack). Ahora lanza un `HttpError(409)` y afirma que sí viaja su mensaje.
22. El 404 que no era: coloca `notFound` antes de los routers y observa el desastre. Documenta el síntoma con exactitud — te ahorrará una hora algún día.

**🟠 Difícil (23–29)**

23. Auditoría de handlers async: escribe un script que recorra tu carpeta `routes/` y detecte handlers `async` NO envueltos en `asyncHandler` (análisis de texto o AST con `esprima`/`acorn` si te animas). Es un linter propio contra el bug de la época — y una herramienta real para auditar legacy ajeno.
24. `express-async-errors` vs el wrapper: instálalo, quita tus wrappers y verifica que sigue funcionando. Investiga en su código QUÉ parchea (son ~30 líneas). ¿Confías en el parche de un módulo sobre el prototipo del router? Escribe tu veredicto de code review.
25. Composición de middlewares: crea `validate(schema)` que valide `req.body` con ajv (los schemas de la F4) y devuelva 422 con detalles por campo. Aplícalo a POST y PATCH de tickets. Ahora tienes validación de entrada, de motor y de contrato: dibuja las tres capas y qué atrapa cada una.
26. Graceful shutdown: al recibir SIGTERM (lo que hace `docker compose down`), deja de aceptar requests nuevos, espera a los en vuelo (con timeout), cierra Mongo y los sockets, y sale. Pruébalo mientras un request lento está en curso. Es la diferencia entre un deploy limpio y uno que corta transacciones.
27. Timeouts: implementa un middleware que aborte requests que superen N segundos con un 503, y demuestra que tu request colgado del ejercicio 2 ahora muere con dignidad. Discute: ¿esto arregla el bug async o solo lo maquilla? (Respuesta: lo segundo — pero en producción quieres ambos.)
28. Rutas con conflicto: define `/tickets/stats` DESPUÉS de `/tickets/:id` y observa que `stats` se interpreta como un id. Arréglalo. (Es exactamente el ejercicio 22 de la Fase 1 del curso Vue, del otro lado del cable: el enrutamiento tiene las mismas leyes en ambas orillas.)
29. Instrumentación: expón un endpoint `/metrics` con contadores por ruta (requests, errores, latencia p95 en memoria). Sin librerías. Ahora tu API se puede monitorear — y entiendes qué hace por dentro cualquier cliente de Prometheus.

**🔴 Muy difícil (30–34)**

30. Escribe tu mini-Express: un `http.createServer` con una cadena de middlewares propia (registro, `next`, error handler de 4 args, router con params). ~120 líneas. Al terminar, Express dejará de ser magia para siempre — y entenderás exactamente por qué NO atrapa tus promesas (porque nadie mira el valor de retorno... salvo que tú decidas mirarlo: hazlo, y acabas de escribir Express 5).
31. Auditoría de un backend ajeno: elige un repo Express+Mongo de 2018–2021 en GitHub. Busca los 5 hallazgos del apéndice (handlers async sin protección, error handler con aridad errónea o ausente, `cors()` abierto en producción, body parser sin límite, orden de middlewares roto). Informe de 1 página con severidad y parche propuesto.
32. Migración mental a Express 5: lee su changelog y lista qué de tu código cambiaría (promesas atrapadas, `req.query` y su nuevo parser, rutas y path-to-regexp). Decide con criterio: ¿migrarías el Mini Jira? ¿Qué ganarías y qué romperías?
33. El pipeline como diagrama: dibuja (mermaid o a mano) el recorrido COMPLETO de tres requests de tu API — un GET exitoso, un PATCH que da 409, y un POST que revienta con error inesperado — nombrando cada middleware que atraviesan y dónde se bifurcan. Pégalo en el README del backend: es el mapa que un dev nuevo necesita el día 1.
34. **El ensayo**: "El framework que no te salva". Media página sobre el bug async como caso de estudio: qué significa que un framework no atrape los errores de su propio paradigma dominante, por qué tardó una década en arreglarse, y qué te dice eso sobre elegir dependencias. Cierra con la pregunta que le harás a la próxima librería que adoptes.

---

## 📚 Referencias

**Documentación oficial**

- Express 4 — Guide: https://expressjs.com/en/guide/routing.html
- Express 4 — Using middleware: https://expressjs.com/en/guide/using-middleware.html
- Express 4 — **Error handling** (lee "the default error handler" y llora un poco): https://expressjs.com/en/guide/error-handling.html
- Express 4 — API reference (req, res, Router): https://expressjs.com/en/4x/api.html
- Express — Production best practices (performance y seguridad): https://expressjs.com/en/advanced/best-practice-performance.html
- Express 5 — Migration guide (lo que cambia, incluido el async): https://expressjs.com/en/guide/migrating-5.html
- morgan: https://github.com/expressjs/morgan
- cors: https://github.com/expressjs/cors
- express-async-errors (30 líneas, léelas): https://github.com/davidbanham/express-async-errors
- MDN — CORS (la verdad sobre el preflight): https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS

**Video (YouTube)**

- Express JS Crash Course — Traversy Media (la referencia de la época): https://www.youtube.com/watch?v=L72fhGm1tfE
- Node.js Ultimate Beginner's Guide — Fireship (el modelo mental en 10 min)

**Orden de lectura sugerido:**
la sección del bug async de este apéndice (si solo lees una cosa, esa) →
Error handling de la doc oficial → Using middleware → los ejercicios 3–5 (el
bug en carne propia) → MDN CORS el día que te muerda → el resto como consulta.
