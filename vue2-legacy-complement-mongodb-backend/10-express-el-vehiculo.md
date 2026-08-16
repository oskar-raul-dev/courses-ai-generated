# 🚂 Fase 10 — Express: el vehículo (sin ceremonia)

## 🎯 Propósito

El momento por el que existe el curso. Ocho fases y media de datos; hoy se
montan detrás de HTTP y ocurre la prueba de fuego:

> **json-server se apaga. El `baseURL` del frontend cambia. Y el frontend no
> se entera.**

Express se enseña rápido y sin ceremonia — eres backend: routing,
middlewares, códigos de estado y capas son tu pan en otro lenguaje. El
trabajo fino de la fase no es Express: es **honrar el contrato hasta en sus
manías** (`AUDIT-CONTRATO.md` en mano): el dialecto de json-server, el mapeo
`_id → id` en la frontera, las fechas de vuelta a ISO, el 404 real, el array
plano sin envelope.

Todo con **driver nativo** — Mongoose espera a la Fase 11 para no contaminar
el momento mágico con dos novedades.

---

## ✅ Qué queda listo al terminar

- el backend Express 4.17 con capas limpias:
  `routes → controllers → services → lib/db`;
- el contrato completo implementado: los 8 endpoints con el dialecto
  contratado (`?status=`, `?q=`, `?_sort=`, `?_order=`), formas y manías
  exactas — más `?priority=` como **extensión** fiel al dialecto (json-server
  filtra por cualquier campo), declarada, no de contrabando;
- la **frontera de traducción**: `_id → id` string, `Date → ISO`, `:id →
  ObjectId` (con 404 limpio ante ids malformados);
- el 409 del doble "tomar" montado sobre la primitiva de la Fase 6
  (extensión pactada);
- manejo de errores centralizado, async sin bombas, CORS, logging, config
  por entorno;
- **el smoke test del contrato aprobado**: json-server apagado, frontend
  vivo, `git diff` de una línea;
- validación de entrada mínima con express-validator (la seria, con auth,
  en la Fase 11).

## 🚫 Qué NO entra todavía

- autenticación real, roles, `reporter` del token (Fase 11 — hoy el backend
  es tan ingenuo como el mock al que reemplaza: **paridad primero, mejoras
  después**);
- la política de transiciones de la máquina de estados (Fase 11);
- Mongoose (Fase 11, como refactor);
- sockets emitidos por el servidor y adjuntos (Fase 12) — el tiempo real vive
  aparte en `:4000` con socket.io 2.4 (el puerto que el cliente ya escucha,
  `AUDIT-CONTRATO.md`); hoy solo montamos el HTTP en `:3000`;
- `GET /stats` como endpoint... entra HOY al final, porque la lógica ya
  existe (Fase 9) y es extensión inofensiva — pero el frontend actual no lo
  consume: queda listo para el ejercicio del panel.

---

## 🧠 Conceptos mínimos

Esto ya lo sabes en otro lenguaje, así que vamos rápido: la arquitectura de
capas (routes → controllers → services → db), la frontera de serialización
que traduce entre el mundo Mongo y el mundo del contrato, y el dialecto de
json-server que hay que imitar manía por manía. Tres piezas, ni una de
Express que no hayas visto ya en tu stack de siempre.

### La estructura (tu arquitectura de capas, acento JavaScript)

```
minijira-backend/
  src/
    config.js               ← puerto, URI de Mongo, por variables de entorno
    db.js                   ← conexión singleton del driver
    app.js                  ← el ensamblaje de Express (exportable: F13 lo testea)
    server.js               ← el listen (separado del app: también por F13)
    routes/
      tickets.routes.js
      users.routes.js
      comments.routes.js
      stats.routes.js
    controllers/            ← HTTP puro: leer request, llamar service, responder
      tickets.controller.js
      ...
    services/               ← lógica de datos (aquí viven tus funciones de lib/)
      tickets.service.js
      ...
    lib/
      serializers.js        ← LA FRONTERA: _id→id, Date→ISO
      objectId.js           ← :id → ObjectId con 404 limpio
      stats.js              ← la de la Fase 9, tal cual
      tickets.js            ← takeTicket y compañía (Fase 6), tal cual
  scripts/ ...              ← todo lo acumulado del curso
```

**Regla de dependencia (tu regla de siempre):** controllers conocen services;
services conocen el driver; **nadie más** toca `db`. Y la regla espejo del
frontend heredado ("ninguna vista importa axios") aquí es "ningún controller
importa mongodb".

### `src/db.js` — la conexión, una sola vez

```js
const { MongoClient } = require("mongodb");
const config = require("./config");

let db = null;

async function connect() {
  const client = await MongoClient.connect(config.mongoUri, {
    useUnifiedTopology: true
  });
  db = client.db(config.dbName);
  return db;
}

function getDb() {
  if (!db) throw new Error("DB no conectada: llama a connect() al arrancar");
  return db;
}

module.exports = { connect, getDb };
```

🔎 El singleton por módulo (los módulos de Node se evalúan una vez — el mismo
fundamento del `apiClient` del frontend heredado). El pool de conexiones vive
DENTRO del client del driver: una conexión lógica, muchas físicas — no abras
un client por request (el error de novato #1 del Node de la época).

---

## 💻 Implementación y código comentado

### 🛂 La frontera: donde la base habla Mongo y la API habla contrato

La pieza más importante de la fase. Firmada en `AUDIT-CONTRATO.md`, escrita
una sola vez, usada en todas las respuestas:

#### `src/lib/serializers.js`

```js
// La base habla Mongo (_id: ObjectId, Date). La API habla el contrato
// (id: string, fechas ISO). ESTA es la aduana — y es el único lugar
// del proyecto donde se permite esa conversación.

function serializeTicket(doc) {
  if (!doc) return null;
  return {
    id: doc._id.toHexString(),          // _id → id string (decisión firmada)
    title: doc.title,
    description: doc.description,
    status: doc.status,
    priority: doc.priority,
    assignee: doc.assignee,             // username o null, tal cual
    reporter: doc.reporter,
    createdAt: doc.createdAt.toISOString()   // Date → ISO (ida y vuelta F1 💸: pagada)
    // history NO se serializa: campo interno (decisión de la Fase 3).
    // updatedAt tampoco POR AHORA: el contrato no lo conoce; exponerlo
    // sería extensión — se decide en la Fase 11, no de contrabando.
  };
}

function serializeComment(doc) {
  if (!doc) return null;
  return {
    id: doc._id.toHexString(),
    ticketId: doc.ticketId.toHexString(),  // ref → string hex, igual que el ticket
    author: doc.author,                    // USERNAME (string), como el frontend pinta `c.author`
    body: doc.body,
    createdAt: doc.createdAt.toISOString()
    // OJO: el modelo sano usa `author` (username). El `authorId` numérico
    // es del villano soporte_v1 — no cruza jamás la frontera del contrato.
  };
}
function serializeUser(doc)    { /* id, username, name, role */ }

module.exports = { serializeTicket, serializeComment, serializeUser };
```

✅ Nota la disciplina en los comentarios: la frontera es también donde se
decide qué **no** sale. Campos internos (`history`, `schemaVersion`,
`updatedAt`) no se filtran al contrato por accidente — el ejercicio 30 de la
Fase 13 testeará exactamente eso.

#### `src/lib/objectId.js` — la otra dirección

```js
const { ObjectId } = require("mongodb");

// ":id" del URL → ObjectId. Un id malformado ("abc") NO es un error 500:
// es un recurso que no existe → 404, como json-server habría respondido.
function toObjectId(id) {
  return ObjectId.isValid(id) ? new ObjectId(id) : null;
}

module.exports = { toObjectId };
```

---

### 📡 El dialecto json-server, implementado

El corazón del `GET /tickets` — cada línea responde a una fila del audit:

#### `src/services/tickets.service.js` (extracto)

```js
const { getDb } = require("../db");

async function list(query) {
  const filter = {};

  if (query.status) filter.status = query.status;      // ?status= (contratado)
  if (query.priority) filter.priority = query.priority; // ?priority= EXTENSIÓN:
  // no está en la tabla de dialecto del audit. json-server filtra por cualquier
  // campo, así que es fiel al dialecto; se declara como extensión inofensiva.
  // (El frontend heredado hoy filtra status/priority/búsqueda en cliente y solo
  //  manda ?_sort/?_order — ver TRACKA-04; esto es paridad con el mock, no algo
  //  que la UI ejerza aún.)

  if (query.q) {                                        // ?q= (alcance firmado)
    const rx = new RegExp(escapeRegex(query.q), "i");
    filter.$or = [{ title: rx }, { description: rx }];
  }

  const sortField = query._sort || "id";                // ?_sort= / ?_order=
  const sortDir = query._order === "desc" ? -1 : 1;     // (asc por defecto,
  const sort = { [sortField === "id" ? "_id" : sortField]: sortDir };  // como json-server)

  return getDb().collection("tickets").find(filter).sort(sort).toArray();
}

function escapeRegex(s) {                               // el ?q=".*" de un gracioso
  return s.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");      // no será tu COLLSCAN eterno
}
```

🔎 Tres manías honradas: `_sort=id` se traduce a `_id` (el frontend ordena
por la columna id — la frontera funciona en ambos sentidos), `_order` ausente
= ascendente (json-server dixit), y el regex **escapado** (primer gesto de
la Fase 11: el input del usuario nunca se interpola crudo — ni en regex).

#### El controller y las manías de forma

```js
// src/controllers/tickets.controller.js (extracto)
const service = require("../services/tickets.service");
const { serializeTicket } = require("../lib/serializers");
const { toObjectId } = require("../lib/objectId");

async function list(req, res, next) {
  try {
    const docs = await service.list(req.query);
    res.json(docs.map(serializeTicket));        // array PLANO, sin envelope
  } catch (err) { next(err); }
}

async function getById(req, res, next) {
  try {
    const oid = toObjectId(req.params.id);
    const doc = oid && await service.getById(oid);
    if (!doc) return res.status(404).json({});  // el 404 REAL que el frontend espera
    res.json(serializeTicket(doc));
  } catch (err) { next(err); }
}

async function create(req, res, next) {
  try {
    const doc = await service.create(req.body); // valida, sella createdAt/history
    res.status(201).json(serializeTicket(doc)); // 201 + el ticket CON id
  } catch (err) { next(err); }
}

async function patch(req, res, next) {
  try {
    const oid = toObjectId(req.params.id);
    if (!oid) return res.status(404).json({});
    const result = await service.patch(oid, req.body);
    if (result.conflict) return res.status(409)          // la EXTENSIÓN pactada:
      .json({ error: "El ticket ya fue tomado" });       // el doble "tomar" (F6)
    if (!result.doc) return res.status(404).json({});
    res.json(serializeTicket(result.doc));               // el ticket COMPLETO actualizado
  } catch (err) { next(err); }
}

async function remove(req, res, next) {
  try {
    const oid = toObjectId(req.params.id);
    if (oid) await service.remove(oid);
    res.json({});                               // {} con 200: la manía, imitada
  } catch (err) { next(err); }
}
```

El `service.patch` merece su nota: json-server hace **merge parcial** — cada
campo del body se aplica, el resto queda. Tu `$set` con el body (validado y
filtrado a campos permitidos) es exactamente eso. Y dentro del patch vive la
bifurcación: si el body intenta asignar `assignee` sobre un ticket, el
service usa `takeTicket` (Fase 6, precondición `assignee: null`) y traduce
su `conflict` al 409. La primitiva atómica encontró su endpoint.

> 📝 **Nota legacy honesta — Express 4 y el async:** Express 4 **no captura**
> excepciones de handlers async: una promesa rechazada sin `try/catch` deja
> el request colgado y el error sin manejar. De ahí el `try { } catch (err)
> { next(err) }` en cada handler — o el wrapper `asyncHandler(fn)` que lo
> abstrae (ejercicio 12). Express 5 lo arregla; tu legacy es Express 4:
> conócele la cicatriz.

#### El ensamblaje

```js
// src/app.js
const express = require("express");
const cors = require("cors");
const morgan = require("morgan");

const app = express();
app.use(cors());                    // el frontend vive en :8080 — sin esto, no hay magia
app.use(express.json());
app.use(morgan("dev"));

app.use("/tickets", require("./routes/tickets.routes"));
app.use("/users", require("./routes/users.routes"));
app.use("/comments", require("./routes/comments.routes"));
app.use("/stats", require("./routes/stats.routes"));   // extensión: nadie la pide aún

app.use(function (req, res) { res.status(404).json({}); });

app.use(function (err, req, res, next) {               // el safety net central
  console.error(err);
  res.status(500).json({ error: "Internal error" });   // el body de error es libre:
});                                                     // el frontend solo mira el status

module.exports = app;
```

```js
// src/server.js
const app = require("./app");
const { connect } = require("./db");
const config = require("./config");

connect().then(function () {
  app.listen(config.port, function () {
    console.log("Mini Jira backend en :" + config.port);
  });
});
```

Puerto: **3000** — el que json-server ocupaba. Así el cambio del frontend es
literalmente cosmético… pero se hace igual, porque el ritual importa.

---

## ✨ El momento mágico (protocolo oficial)

1. `npm run seed` (base fresca del `db.json` heredado — Fase 1).
2. Levanta tu backend: `npm start` → `:3000`.
3. **Apaga json-server.** Para siempre. (Un minuto de silencio: sirvió bien.)
4. En el frontend: `services/apiClient.js`, la línea del `baseURL`…
   apunta a `http://localhost:3000`. *(Sí: es el mismo valor. Cámbiala igual
   — a una variable de entorno si quieres ganarte el punto del Apéndice A5
   del curso heredado. El `git diff` debe existir y debe ser UNA línea.)*
5. Ejecuta el **smoke test completo** de `AUDIT-CONTRATO.md`: login, listado,
   búsqueda, orden, detalle, 404, crear (form y wizard), editar, tomar,
   transiciones, eliminar, comentarios, métricas del navegador, recarga con
   sesión.
6. `git diff` en el repo del frontend: **una línea**. Captura de pantalla al
   README. Es tu trofeo.

Si algo falla, el orden de sospecha: (1) CORS (la consola del navegador
grita), (2) una manía de forma (envelope, fecha no-ISO, id que no viajó),
(3) el dialecto (`_sort`/`_order`/`q`), (4) el riesgo declarado del audit
(un `Number(id)` en el frontend — se documenta como bug latente heredado y
se procede según lo firmado).

---

## 🧩 Chuleta de la fase

```
Capas: routes → controllers (HTTP puro) → services (datos) → db (singleton)
Nadie salta capas. Ningún controller importa mongodb.

La frontera (serializers.js):  _id→id hex · Date→ISO · interno NO sale
La aduana inversa (objectId.js): id inválido = 404, jamás 500

Dialecto (contratado): ?status → filter · ?q → $or regex ESCAPADO · ?_sort/_order → sort
          (_sort=id → _id · _order ausente = asc)
          ?priority → filter: EXTENSIÓN fiel al dialecto, no está en el audit
Manías:  array plano sin envelope · 404 {} · POST 201 + doc · PATCH merge
         parcial + doc completo · DELETE {} 200
Extensiones montadas: 409 (takeTicket F6) · GET /stats (F9)

Express 4 + async = try/catch + next(err) SIEMPRE (o asyncHandler)
CORS antes que nada · app.js ≠ server.js (testeabilidad, F13)
HTTP en :3000 (el de json-server) · sockets en :4000 son F12, no esta fase
```

---

## ⚠️ Errores comunes y pieza forense

- Un `MongoClient.connect` por request (agotas conexiones en minutos).
- El async sin `next(err)`: el request que se queda colgado eterno — el bug
  Express 4 por excelencia.
- Devolver el documento crudo de Mongo (con `_id`, `history`, fechas Date
  serializadas por accidente) — la frontera existe para pasarse por ella.
- El envelope reflejo (`{ data: [...] }`): el frontend hace `res.data` de
  axios y espera el recurso directo. Rompe TODO, silenciosamente.
- `_sort` interpolado directo al sort sin traducir `id`→`_id`.
- El regex del `?q=` sin escapar (funciona… hasta el primer `(`).
- Validar el body a medias y dejar pasar campos al `$set` (el `reporter`
  inventado sigue pasando HOY — a propósito: paridad con el mock; la Fase 11
  lo mata con lista blanca + token).
- Olvidar CORS y perder una hora culpando al código.
- Diferencias de forma "mejoradas" de contrabando (un campo extra "útil"):
  el contrato crece en la Fase 11, no por accidente en la 10.

### 🩻 Pieza forense: el request que no vuelve

El bug marca de la casa de Express 4. Te entrego el síntoma: haces `GET
/tickets/5f8a1c2e...` (id válido en forma pero cuyo service lanza) y el
navegador se queda girando **para siempre** — sin 404, sin 500, sin nada en la
pestaña de red salvo "pending". El server sigue vivo y atiende otras rutas.

Reprodúcelo y localízalo:

1. **Mira el log de morgan.** ¿Aparece la línea del request? En `morgan("dev")`
   la línea se imprime **cuando la respuesta se cierra**. Si no hay línea, la
   respuesta nunca se envió: el handler entró y no salió.
2. **Sospecha del `await` sin red.** Un service async que lanza (o una promesa
   rechazada) dentro de un handler **sin** `try/catch` + `next(err)`: Express 4
   no captura ese rechazo, el handler muere en silencio y el request queda
   colgado. No es un 500 — es un no-response.
3. **Confírmalo:** envuelve ese handler en `asyncHandler` (ej. 12) o añádele el
   `try { } catch (err) { next(err) }`. Ahora el mismo request devuelve el 500
   del middleware central (o el 404 limpio si era eso) y morgan por fin imprime
   su línea.

La lección: en Express 4 un handler async sin captura no falla ruidosamente,
**falla callado**. Por eso el `next(err)` no es opcional: es la diferencia
entre un error que ves y un request que desaparece.

---

## 🧪 Ejercicios (33 + 🔥)

**🟢 Fácil (1–11)**

1. Levanta el esqueleto (config, db, app, server) con un `GET /health` que devuelva `{ ok: true, db: "up" }` verificando la conexión con un ping real.
2. Implementa `GET /users` con `?role=` y su serializer. Pruébalo con curl contra los usuarios del seed.
3. `GET /tickets` sin dialecto (todo, plano, serializado). Verifica con curl: ¿el `id` es string hex? ¿el `createdAt` es ISO? ¿NO viajan `history`/`schemaVersion`?
4. Agrega `?status=` (contratado) y `?priority=` (mismo patrón: filtro por campo, como json-server — pero **no está en la tabla de dialecto del audit**: documéntalo como extensión inofensiva, no como manía contratada). Verifica contra los conteos que ya conoces de la Fase 2. Prueba también el combinado `?priority=high&status=open`.
5. Agrega `?_sort=` y `?_order=` (con la traducción `id`→`_id`). Prueba las 4 combinaciones del frontend.
6. Agrega `?q=` con el regex escapado. Prueba: "impresora", "IMPRESORA", "impre", y el hostil `".*"` (debe buscar el literal punto-asterisco, no matchear todo).
7. `GET /tickets/:id` con los tres caminos: existe (200), no existe (404 `{}`), id malformado "abc" (404 `{}`, no 500). Curl a los tres.
8. `GET /comments?ticketId=X&_sort=createdAt` completo con su serializer (¡`ticketId` también se serializa a string!).
9. `POST /comments`: valida ticketId existente (404 si no — decisión: json-server no validaba; nosotros sí, es extensión inofensiva de robustez… ¿o rompe algo? Verifica contra el frontend y documenta).
10. `DELETE /tickets/:id` con la manía del `{}` 200. ¿Qué hace tu backend con los comentarios del ticket borrado? Por ahora: lo mismo que json-server (nada — huérfanos). Anótalo como deuda propia 💸 con fase de pago (ejercicio 28).
11. morgan en modo `dev`: identifica en el log método, ruta, status y tiempo de 5 requests del smoke. Tu access log de siempre.

**🟡 Intermedio (12–22)**

12. Escribe `asyncHandler(fn)` y refactoriza todos los controllers: cero try/catch repetidos. Demuestra que funciona lanzando un error a propósito desde un service: ¿llegó al middleware central con status 500 y el server siguió vivo?
13. `POST /tickets` completo: lista blanca de campos del body (title, description, priority, assignee, reporter — el reporter inventado pasa HOY, con su comentario 💸 apuntando a la F11), defaults (status: "open", createdAt: now, history: []), validación con express-validator (title requerido no vacío, priority del enum del contrato), 201 + serializado.
14. Verifica que el validator del MOTOR (Fase 4) sigue detrás: salta la validación de express-validator a propósito (comenta la línea) e intenta colar `priority: "urgente"`. ¿Quién te salvó? Las dos líneas de defensa, demostradas.
15. `PATCH /tickets/:id` con merge parcial por lista blanca + el doc completo de vuelta. Prueba: editar solo `title`; editar `status`; body con campo desconocido (`hacker: true` — debe ignorarse en silencio, como json-server).
16. Monta el 409: el `PATCH` que asigna `assignee` sobre ticket libre pasa; sobre ticket tomado → 409. Reusa `takeTicket` de la Fase 6 tal cual (si tu firma no encaja, arregla el service, no la primitiva).
17. El duelo por HTTP: adapta el script de dos agentes concurrentes (F6, ej. 29) para atacar TU endpoint real. Exactamente un 200 y un 409 por ronda, 100 rondas.
18. ¿Y el frontend ante el 409? Con el panel de soporte abierto en dos navegadores, toma el mismo ticket en ambos. Documenta qué ve el perdedor (¿error genérico? ¿nada?) y por qué eso es "feo pero no roto" según el régimen del audit. La mejora fina es de la Fase 11/ejercicios del frontend.
19. `GET /stats` montado sobre `computeStats` (F9) tal cual, con su route y (sin) serializer — decide: ¿la forma que produjo la Fase 9 ES el contrato del endpoint nuevo? Documenta la forma en `AUDIT-CONTRATO.md` como extensión oficial.
20. Config por entorno de verdad: `.env` + `dotenv` (puerto, mongoUri, dbName), `config.js` que valide presencia y falle al arrancar si falta algo (fail-fast). El `.env.example` versionado (costumbre de la Fase 0, cobrando sentido).
21. Graceful shutdown: SIGINT/SIGTERM → deja de aceptar conexiones, cierra el client de Mongo, sale limpio. Pruébalo con Ctrl+C a mitad de una carga del torture (F6).
22. **El momento mágico, ejecutado:** protocolo completo de la sección, smoke test del audit ítem por ítem, `git diff` de una línea capturado. Si el riesgo del `Number(id)` aparece, procede según lo firmado y documenta.

**🟠 Difícil (23–30)**

23. El middleware de contrato: escribe `contractGuard` (solo para desarrollo) que intercepte cada respuesta saliente y valide su forma contra schemas ajv derivados del contrato (array plano, id string, ISO dates, sin campos internos). Cualquier violación: error ruidoso en consola. Tu contrato, ejecutable.
24. Paridad forense con json-server: levanta json-server en :3001 (solo para esto) y escribe `scripts/contract-diff.js` que dispare las mismas 20 requests contra ambos y compare respuestas normalizadas (ids aparte). Reporte de diferencias: debe salir vacío o cada diferencia debe estar firmada en el audit. La paridad, demostrada por máquina.
25. Los índices bajo HTTP: con el plan de la Fase 7 activo, mide p50/p95 de los 4 endpoints calientes bajo carga (script de N requests concurrentes, o `autocannon` si lo prefieres — decláralo). Ahora dropea los índices y repite. La tabla que conecta las fases 7 y 9.
26. Rate limiting básico (adelanto del Apéndice 4): `express-rate-limit` en `/tickets` con límites generosos. Verifica el 429 con un bucle de curl. ¿El frontend sobrevive a un 429 esporádico? (Régimen del audit: extensión — status nuevo en caso extremo.)
27. Logging estructurado: reemplaza morgan por (o compleméntalo con) un logger JSON propio (request id, ruta, status, duración, y el userId cuando exista en F11). Middleware de ~20 líneas. Grep-eable, como debe ser.
28. Paga tu deuda del ej. 10: DELETE de ticket ahora decide sobre sus comentarios. Opciones: borrado en cascada (dos operaciones — ¿la carrera importa aquí? argumenta), soft-delete del ticket, o huérfanos + reconciliación (F5). Elige, implementa, documenta en formato decisión. (Pista incómoda: ¿qué hacía el frontend al borrar? ¿Alguien ve esos comentarios después? El contrato guía.)
29. El error middleware adulto: clasifica errores (validación → 400 con detalle, ObjectId/no encontrado → 404, conflicto → 409, resto → 500 sin filtrar internals), con clase `ApiError` propia y su factoría. Refactoriza dos controllers para usarla. El patrón exacto del legacy Express bien hecho.
30. Auditoría de frontera: script que recorra TODAS las respuestas de tu API (las 20 requests del ej. 24) buscando fugas: cualquier `_id`, cualquier fecha no-ISO, cualquier campo fuera del contrato. Cero tolerancia. Se integra al `npm run smoke`.

**🔴 Muy difícil (31–33)**

31. El dialecto completo de json-server, investigado: json-server 0.16 también soporta `_page`/`_limit`, `_start`/`_end` (con header `X-Total-Count`), y filtros `campo_gte`/`campo_lte`/`campo_ne`. El frontend heredado no los usa — pero un frontend gemelo podría. Implementa `_page`/`_limit` + `X-Total-Count` como extensión fiel al dialecto y documenta el resto en el audit como "no implementado, no consumido".
32. Compresión y ETag: agrega `compression` y verifica con curl los headers; investiga el ETag automático de Express (está ON por defecto): ¿el frontend con axios se beneficia del 304? Mide una respuesta grande con y sin. Media página de hallazgos.
33. **El ensayo de la fase** (1 página, `INSTINTOS.md`): "El contrato manda, la base se adapta". Tesis: la frontera de serialización no es plomería — es la declaración de independencia entre tu modelo (que optimizaste 8 fases para el acceso) y el contrato (que otro equipo congeló hace años); confundirlos es cómo nacen las APIs que exponen su base de datos. Usa el mapeo `_id→id` y los campos que NO salen como evidencia. Cierra con tu regla para el futuro: qué cambios pide el contrato, cuáles pide el modelo, y por qué casi nunca es el mismo cambio.

**🔥 Opcionales (ampliación)**

- 🔥 El torture HTTP: versión final del torture (F6, ej. 33) contra la API completa — mezcla realista de todos los endpoints, 60 segundos, invariantes verificadas al final + presupuesto de latencia (declara p95 objetivo por endpoint y falla si se excede). `npm run torture:http`. La Fase 13 lo heredará.
- 🔥 Blue-green casero del momento mágico: script que levante TU backend en :3002, corra `contract-diff` contra el backend viejo en :3000, y si sale limpio, haga el switch (mata el viejo, relevanta el nuevo en :3000). El deploy sin downtime en 50 líneas — y la comprensión de por qué el proxy `/api` del Apéndice A5 heredado habría hecho esto trivial.
- 🔥 Repite el momento mágico desde CERO en una máquina limpia (o contenedor): clona ambos repos, sigue solo los READMEs, cronometra. Cada fricción que encuentres es un bug de documentación: arréglalos. El estándar: de git clone a frontend funcionando en < 15 minutos.

---

## 📚 Referencias

**Documentación oficial (Express 4.17 / driver 3.6)**

- Express 4.x — API Reference: https://expressjs.com/en/4x/api.html
- Express — Routing: https://expressjs.com/en/guide/routing.html
- Express — Using middleware: https://expressjs.com/en/guide/using-middleware.html
- Express — Error handling (la página del async, léela dos veces): https://expressjs.com/en/guide/error-handling.html
- Driver 3.6 — Connection pooling / MongoClient: https://mongodb.github.io/node-mongodb-native/3.6/api/MongoClient.html
- cors: https://github.com/expressjs/cors
- morgan: https://github.com/expressjs/morgan
- express-validator 6.x: https://express-validator.github.io/docs/
- dotenv: https://github.com/motdotla/dotenv
- json-server 0.16 (el contrato a imitar — su README ES la spec): https://github.com/typicode/json-server/tree/v0.16.3

**Libros / apoyo**

- *Node.js Design Patterns* (Casciaro & Mammino) — caps. de módulos y
  arquitectura, para el fundamento del singleton y las capas.
- MDN — HTTP response status codes (el repaso de 200/201/404/409): https://developer.mozilla.org/en-US/docs/Web/HTTP/Status

**Video (YouTube)**

- Express Crash Course — Traversy Media (la referencia exprés de la época): https://www.youtube.com/watch?v=L72fhGm1tfE
- REST API con Node/Express/Mongo — cualquier build-along 2019–2020 sirve
  de contraste: míralo DESPUÉS de tu implementación y detecta qué hacen sin
  frontera de serialización (spoiler: casi todos exponen `_id`).

**Orden de lectura sugerido para perfil senior:**
Error handling de Express (la única lectura obligatoria: el async es LA
trampa) → el README de json-server 0.16 (tu spec) → implementar con el audit
al lado → ejercicios 23–24 (el contrato ejecutable) → el momento mágico →
el resto.

---

## 🚀 Cierre

Al final de esta fase existe lo prometido: un backend real con MongoDB
sirviendo al frontend heredado, que cambió una línea y no se enteró de nada.
La frontera traduce en ambos sentidos sin fugas, el dialecto está honrado
manía por manía y demostrado por máquina (contract-diff), el 409 y `/stats`
entraron como extensiones firmadas, y json-server descansa en paz.

La señal de que quedó bien:

> "el `git diff` del frontend tiene una línea, el smoke pasa completo — y si
> mañana el contrato exigiera `id` numérico o fechas Unix, sé exactamente
> QUÉ archivo cambia y qué archivos NO".

**Siguiente parada:** 🔐 Fase 11 — Auth real y el pago de deudas. El backend
funciona pero es tan crédulo como el mock que enterró: cree cualquier token,
acepta cualquier `reporter`, permite cualquier transición. Se acabó la
paridad con el teatro: Mongoose entra como refactor, bcrypt y JWT entran en
serio, y `SECURITY-NOTES.md` — nueve fases esperando — por fin empieza a
tacharse.
