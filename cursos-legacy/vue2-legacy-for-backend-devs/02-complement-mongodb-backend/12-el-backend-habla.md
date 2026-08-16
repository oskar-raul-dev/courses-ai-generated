# 🔌 Fase 12 — El backend habla: sockets del servidor y archivos reales

## 🎯 Propósito

Dos deudas heredadas siguen vivas, y las dos son del mismo tipo: **cosas que
el backend debía hacer y el cliente fingía**. Esta fase las paga:

1. **El cliente mentiroso 💸.** Hoy, quien crea un ticket es quien emite el
   evento `ticket:created` al relé tonto de 30 líneas, que lo rebota a todos.
   Consecuencia: cualquiera con la consola abierta emite tickets falsos, y un
   ticket creado por fuera del frontend no notifica a nadie. El arreglo es
   arquitectónico, no técnico: **el evento lo emite quien persiste** — el
   servidor, después de confirmar la escritura. Mismo evento, mismo payload,
   distinto emisor: el frontend no distingue (régimen del contrato: cambio de
   emisor, no de forma).
2. **La subida que nunca fue real 💸.** json-server no procesa multipart; los
   adjuntos fueron siempre ejercicios de fe. Entran **multer** (el multipart
   parseado) y **GridFS** (los bytes en Mongo, en chunks) con su pareja de
   endpoints: subir y descargar — extensiones pactadas en `00-audit-contrato.md`.

---

## ✅ Qué queda listo al terminar

- socket.io **2.4** servido desde tu proceso backend en el puerto `:4000`
  (el que el cliente ya escucha), con el relé tonto jubilado;
- los eventos emitidos **tras persistir**: `ticket:created` activo,
  `ticket:updated` y `ticket:deleted` listos (eran ejercicios del sistema
  heredado — ahora son reales);
- el módulo `realtime/` desacoplado de los services (sin dependencias
  circulares, sin `io` pasado de mano en mano);
- handshake de sockets **autenticable** con el JWT de la Fase 11, en modo
  compatible (la exigencia dura es decisión documentada);
- `POST /attachments` (multipart real) y `GET /attachments/:id/download`
  (streaming) sobre GridFS, con metadata ligada al ticket y al `req.user`;
- `SECURITY-NOTES.md` con dos tachones más y una entrada nueva (la que los
  sockets abren);
- 🔀 **solo si hiciste una ruta del Curso 01:** `GET /activity` y
  `POST /activity` con su evento `activity:created`, servidos desde el
  `history` que ya embebiste en la Fase 3.

## 🚫 Qué NO entra todavía

- testear sockets y streams (Fase 13 — y tiene su gracia)
- reconexión robusta, salas por usuario, presencia, escalado de sockets con
  adaptador Redis (se nombran; construirlos es otra película)
- antivirus/escaneo de archivos, thumbnails, S3 (la conversación honesta de
  "¿los archivos van en la base?" sí entra — la infraestructura alternativa no)
- rate limiting de uploads (Apéndice de seguridad)

---

## 🔀 `/activity`: la tercera deuda, y solo si hiciste una ruta

Esta sección es **opcional y condicional**. Si terminaste el Curso 01 en F11,
tu frontend no conoce `/activity` y puedes saltarla sin deber nada. Si hiciste
Q4, VU4 o NX4, tu frontend pide un endpoint que hoy tu backend no sirve — y el
timeline se queda vacío en cuanto apagues json-server.

Las tres rutas añadieron al `db.json` una colección `activity` y la consumen
igual:

```
GET  /activity?ticketId=X&_sort=at&_order=desc   → [{ id, ticketId, type, actor, from, to, at }]
POST /activity                                    → el documento con su id, 201
socket: activity:created                          → el documento guardado
```

Y la declararon **muleta 💸 con nombre**: el evento lo fabrica el cliente, con
el reloj del cliente, y lo postea antes de emitirlo. Es exactamente el mismo
pecado que el cliente mentiroso que acabas de matar en esta fase.

### 🪞 Tu instinto dice "creo la colección `activity`". Y esta vez se equivoca

Es la reacción natural: el frontend pide `/activity`, luego hago una colección
`activity`. Pero mira lo que ya tienes. En la Fase 3 embebiste `history` en el
ticket, y en la Fase 9 lo explotaste para calcular tiempos de resolución. **El
`history` embebido y la colección `activity` son el mismo dato con dos
diseños** — y el tuyo es mejor: se escribe en la misma operación atómica que
la transición que registra, así que no puede desincronizarse.

Crear la colección paralela te daría dos fuentes de verdad para el mismo
hecho, y el clásico bug de "el timeline dice que se cerró y el ticket dice que
está abierto". El endpoint, entonces, **es una proyección**:

```js
// src/lib/serializers.js — el timeline que el frontend espera, desde history
// El frontend pide "activity"; nosotros tenemos "history". La frontera traduce,
// como traduce _id → id. No cambiamos el modelo para acomodar un nombre.
function serializeActivity(ticket) {
  return (ticket.history || []).map(function (entry, i) {
    return {
      // el frontend solo lo usa como :key de lista; un id derivado y estable
      // es más honesto que un Date.now() (que era su 💸)
      id: ticket._id.toHexString() + "-" + i,
      ticketId: ticket._id.toHexString(),
      type: entry.to === "open" && entry.from ? "reopened" : "status_change",
      actor: entry.by,
      from: entry.from,
      to: entry.to,
      at: entry.at.toISOString()
    };
  });
}
```

La entrada de `history` que escribes desde la Fase 6 es
`{ from, to, by, at }`, así que el mapeo sale casi solo: `by` → `actor`, y
`from`/`to`/`at` viajan tal cual.

> ⚠️ **Hay un `type` que no puedes derivar, y conviene verlo ahora.** El
> frontend distingue `"status_change"` de `"assigned"`, pero tu `history` solo
> registra la transición de estado — cuando `takeTicket` cambia `assignee` y
> `status` en la misma operación, la entrada resultante es indistinguible de
> un cambio de estado normal. No es un bug del serializer: es **información
> que tu modelo no guarda**. El arreglo va donde nace el dato (una clave más
> en el `$push` de `takeTicket`), no en la frontera; queda como ejercicio 11.
> El síntoma —"no puedo proyectar lo que nunca registré"— es el mismo que te
> mordió con los tiempos de resolución en la Fase 9, y merece una línea en
> `INSTINTOS.md`.

Y el `POST /activity` que el frontend hace hoy: **deja de necesitarse**. La
transición ya escribe en `history` dentro del mismo `findOneAndUpdate` de la
Fase 6. Lo implementas como **no-op idempotente** que devuelve 201 con el
documento derivado, para que el frontend de la ruta no se rompa, y anotas la
deuda al revés: ahora el que sobra es el POST del cliente.

**El evento** sigue el mismo camino que `ticket:updated` en esta fase: lo emite
el servidor tras persistir la transición, con el mismo nombre
`activity:created` y el mismo payload. El componente del timeline no distingue.

> 🧭 **El patrón a memorizar:** cuando el cliente pide un recurso que tu modelo
> no tiene con ese nombre, la pregunta no es "¿creo la colección?" sino "¿ya
> tengo este hecho guardado en otro sitio?". Si la respuesta es sí, lo que
> falta es una proyección en la frontera, no una tabla más. Duplicar el hecho
> para que coincida el nombre es cómo nacen las bases que se contradicen a sí
> mismas — y es, literalmente, el pecado de `soporte_v1`.

---

## 🧠 El cambio arquitectónico en 60 segundos

```
ANTES (heredado):                        DESPUÉS (esta fase):
navegador A ──POST──▶ json-server        navegador A ──POST──▶ API Express
navegador A ──emit──▶ relé :4000                                  │ persiste
                        │ rebota                                  │ confirma
navegador B ◀──────────┘                                          ▼
                                         navegador B ◀──emit── io (:4000)
```

La diferencia que importa: en el modelo viejo, **el evento es testimonio del
cliente** ("yo digo que creé un ticket"); en el nuevo, **es consecuencia de
la persistencia** ("existe en la base, por eso te aviso"). Un evento que no
corresponde a un documento es ahora imposible por construcción — no por
vigilancia.

> ### 🪞 Tu instinto dice… "emito el evento dentro de la transacción, para que sea atómico"
>
> **Predicción falsable:** "si emito después de persistir pero el emit
> falla/el proceso muere entre ambos, pierdo la notificación; la solución es
> meterlo en la unidad atómica".
>
> La primera mitad es correcta: emit-tras-persistir es **at-most-once** — la
> escritura puede existir sin su evento. Pero un emit no es una operación de
> base: no puede participar del commit, y "dentro de la transacción" solo
> logra lo peor de ambos mundos (evento emitido de algo que luego abortó).
> La escalera honesta: (1) para notificaciones de UI —nuestro caso—
> at-most-once **basta**: el que no recibió el toast verá el ticket al
> refrescar; se documenta la tolerancia (Fase 5 dixit) y listo; (2) si el
> evento fuera de negocio (facturar, disparar un flujo), entonces **outbox
> transaccional** — que ya construiste en la Fase 6 (ej. 30) exactamente para
> esto. **Veredicto: el instinto huele bien el problema y receta mal la
> medicina.** 📓 A `INSTINTOS.md`.

### 🩻 Esto SÍ funciona igual

Pub/sub es pub/sub: tu experiencia con triggers que notifican, colas y
`LISTEN/NOTIFY` de Postgres es el mismo modelo mental. Y el streaming de
archivos es I/O de toda la vida: chunks, backpressure, content-type — nada
que un backend senior no haya peleado antes.

---

## 📡 socket.io 2.4 desde el backend

> ⚠️ **La versión no es negociable:** el cliente heredado usa
> `socket.io-client` **2.4.0**, y socket.io 2.x y 3.x **no se hablan** (cambió
> el protocolo). Servidor 2.4.1 o el frontend se queda sordo — sin error
> claro, solo silencio. Es el bug de versiones más famoso de la época.

```bash
npm install socket.io@2.4.1
```

### `src/realtime/io.js` — el singleton que rompe el nudo

```js
// El problema clásico: services necesita emitir, server crea el io,
// server importa routes que importan services... círculo. Solución de época:
// un módulo-singleton con init() y emit() — nadie importa al server.
let io = null;

function init(httpServer) {
  io = require("socket.io")(httpServer, {
    // El frontend corre en :8080 y el socket en :4000 → CORS del handshake
    origins: "*:*"        // sintaxis 2.x; se endurece en el ejercicio 14
  });

  io.on("connection", function (socket) {
    console.log("[io] cliente conectado:", socket.id);
    socket.on("disconnect", function (reason) {
      console.log("[io] desconectado:", socket.id, reason);
    });
  });
  return io;
}

function emit(event, payload) {
  if (!io) return;            // en tests o scripts sin realtime: no-op silencioso
  io.emit(event, payload);    // a TODOS los clientes conectados
}

module.exports = { init, emit };
```

🔎 **Por qué `io.emit` y no `socket.broadcast.emit`.** En el relé heredado
(Fase 8 de Track A) el emisor era **un navegador**, así que se usaba
`socket.broadcast.emit` para reenviar a todos **menos** al que ya había
pintado el ticket en su propia pantalla. Aquí el emisor es el **servidor**:
no es cliente de nada, no tiene una vista que ya se haya actualizado, así que
`io.emit` (a todos, sin excluir a nadie) es lo correcto y **no** duplica
eventos. El cliente que originó el `POST` recibe el `ticket:created` por el
socket igual que los demás, y su UI ya está preparada para reconciliar por
`id`. Mismo evento, misma forma de payload: cambia el emisor, no el contrato.

### `src/server.js` — dos puertas, un proceso

```js
const http = require("http");
const app = require("./app");            // el Express de la Fase 10
const realtime = require("./realtime/io");

// Puerta 1: la API donde siempre (:3000)
app.listen(3000, function () { console.log("API en :3000"); });

// Puerta 2: los sockets donde el cliente ya escucha (:4000)
const socketServer = http.createServer();   // http pelado: solo transporta al io
realtime.init(socketServer);
socketServer.listen(4000, function () { console.log("Sockets en :4000"); });
```

🔎 **Qué hace:** un solo proceso Node, dos listeners. El contrato fija ambos
puertos (`baseURL :3000`, socket `:4000`) y los respetamos a rajatabla — el
día que quieras unificarlos tras un proxy `/api` + `/socket.io`, es el pago
de la deuda de URLs hardcodeadas que el sistema heredado dejó anotada
(ejercicio 30). El relé tonto (`server/socket-server.js` del legacy) **se
apaga y no se reemplaza**: su puerto lo ocupa ahora alguien que dice la
verdad.

### El emit donde corresponde: tras confirmar

```js
// src/services/tickets.service.js (el create de la Fase 10, completado)
const realtime = require("../realtime/io");
const { serializeTicket } = require("../lib/serializers");
const { buildTicket } = require("../lib/tickets");   // helper de la Fase 11
const { getDb } = require("../db");

async function createTicket(data, user) {
  const doc = buildTicket(data, user);                       // Fase 11: reporter del token
  await getDb().collection("tickets").insertOne(doc);        // 1.º persistir
  const ticket = serializeTicket(doc);                       // 2.º MISMA forma que la API
  realtime.emit("ticket:created", ticket);                   // 3.º y solo entonces, hablar
  return ticket;
}
```

🔎 **Qué hace:** el orden es el mensaje — persistir, serializar con **el
mismo serializer del contrato** (el payload del evento y el de la respuesta
HTTP son la misma forma: `id` string, fechas ISO; el frontend no nota el
cambio de emisor), y emitir. ✅ **Buena práctica sembrada:** el evento se
emite en el **service** (la operación de negocio), no en el controller (el
transporte) — así el día que un script o un cron creen tickets, también
notifican.

### El handshake con credencial (los sockets ya no son anónimos)

El token de la Fase 11 existe; los sockets pueden pedirlo:

```js
// dentro de init(), antes de io.on("connection"):
const { verifyToken } = require("../lib/jwt");     // Fase 11

io.use(function (socket, next) {
  const token = socket.handshake.query && socket.handshake.query.token;
  if (!token) {
    socket.user = null;                            // modo compatible: anónimo
    return next();
  }
  try {
    socket.user = verifyToken(token);
    next();
  } catch (e) {
    next(new Error("invalid token"));              // token PRESENTE e inválido: fuera
  }
});
```

> 📝 **Nota legacy honesta — el modo compatible:** el `socketService` heredado
> se conecta **sin** enviar token (nadie se lo pidió nunca). Exigirlo hoy
> rompería la conexión: ruptura de contrato. Decisión documentada: token
> ausente = anónimo permitido (solo escucha), token inválido = rechazado, y
> `SECURITY-NOTES.md` gana la entrada *"los sockets aceptan anónimos: cerrar
> cuando el frontend envíe token en el handshake"* — con el cambio de una
> línea del cliente ya escrito como propuesta (ejercicio 13). Así se ve
> "el contrato crece, no se rompe" aplicado a tiempo real.

---

## 📎 Archivos reales: multer + GridFS

### La conversación previa (30 segundos de honestidad)

¿Archivos **dentro** de la base? La respuesta de la época — y la sensata:
GridFS brilla cuando quieres los archivos **con** la base (mismo backup de la
Fase 0/13, misma replicación, sin infraestructura extra: exactamente un
sistema interno como el Mini Jira); y pierde contra un object storage (S3 y
familia) en CDN, costos a escala y archivos enormes. Para adjuntos de mesa
de soporte (~PDFs y capturas): GridFS es la herramienta correcta, no un
compromiso. Documentado en `DATA-MODEL.md`, decisión defendida.

### Qué es GridFS en 60 segundos

El límite de 16 MB (Fase 3) aplica a documentos — GridFS lo esquiva
partiendo el archivo en **chunks de 255 KB** repartidos en dos colecciones
(`fs.files` con la metadata, `fs.chunks` con los bytes) que el driver
maneja por ti con `GridFSBucket`. No es magia: son documentos comunes que
puedes consultar (ejercicio 17 te hace mirarlos por dentro).

### `POST /attachments` — multipart de verdad

```bash
npm install multer@1.4.4
```

```js
// src/routes/attachments.routes.js
const router = require("express").Router();
const multer = require("multer");
const upload = multer({
  storage: multer.memoryStorage(),                 // el buffer va directo a GridFS
  limits: { fileSize: 10 * 1024 * 1024 }           // 10 MB: límite DECLARADO
});
const controller = require("../controllers/attachments.controller");
const { requireAuth } = require("../middleware/auth");   // Fase 11

router.post("/", requireAuth, upload.single("file"), controller.upload);
router.get("/:id", controller.download);
module.exports = router;
```

```js
// src/services/attachments.service.js (extracto)
const { GridFSBucket, ObjectId } = require("mongodb");
const { getDb } = require("../db");

function bucket() { return new GridFSBucket(getDb(), { bucketName: "attachments" }); }

function upload(file, ticketId, username) {
  return new Promise(function (resolve, reject) {
    const stream = bucket().openUploadStream(file.originalname, {
      contentType: file.mimetype,
      metadata: { ticketId: new ObjectId(ticketId), uploadedBy: username,
                  uploadedAt: new Date() }
    });
    stream.on("error", reject);
    stream.on("finish", function () {
      resolve({ id: stream.id.toHexString(), filename: file.originalname,
                contentType: file.mimetype, size: file.size });
    });
    stream.end(file.buffer);
  });
}

async function download(id, res) {
  const files = await getDb().collection("attachments.files")
    .find({ _id: new ObjectId(id) }).toArray();
  if (!files.length) return false;                  // el controller da el 404
  const f = files[0];
  res.set("Content-Type", f.contentType || "application/octet-stream");
  res.set("Content-Disposition", 'attachment; filename="' + f.filename + '"');
  bucket().openDownloadStream(f._id).pipe(res);     // stream, no buffer: 200 MB no matan tu RAM
  return true;
}
```

> 📌 **Por qué `/attachments/:id/download` y no `/attachments/:id`.** La ruta la
> fija el frontend: el apéndice de axios del Curso 01
> ([`a4-axios.md`](../01-vue2-legacy/a4-axios.md)) ya escribe la descarga
> contra `/attachments/:id/download` con `responseType: "blob"`. Además deja
> libre `/attachments/:id` para la **metadata** del adjunto, que es un JSON y
> no un binario. Dos representaciones del mismo recurso, dos rutas: el `:id` a
> secas te dice qué es el archivo; el `/download` te lo da.

🔎 **Qué hace:** subir = stream de escritura al bucket con la metadata que
liga el archivo a su ticket y a su autor (`req.user`, no el body — lección de
la Fase 11 aplicada a archivos); descargar = **pipe** del stream de lectura a
la respuesta, sin cargar el archivo en memoria. ✅ **Buenas prácticas
sembradas:** límite de tamaño declarado en multer (el error del cliente es un
413, no un server caído), `memoryStorage` porque el destino es otro stream
(nada toca el disco del server), y la metadata como ciudadana de primera —
`GET /attachments?ticketId=X` es un `find` sobre `attachments.files`
(ejercicio 6).

---

## 🧩 Chuleta de la fase

```js
// El principio de la fase:
//   el evento es CONSECUENCIA de la persistencia, no testimonio del cliente
//   → emit en el service, DESPUÉS del insert/update, con el MISMO serializer

realtime.emit("ticket:created", serializeTicket(doc))   // misma forma que la API
// notificación UI → at-most-once basta (tolerancia documentada)
// evento de negocio → outbox transaccional (F6 ej. 30)

// socket.io 2.4 (el cliente es 2.4.0: 2.x↔3.x NO se hablan)
io.use(middleware)                     // handshake: token en query → socket.user
// modo compatible: sin token = anónimo escucha · token inválido = rechazado

// GridFS: fs.files (metadata) + fs.chunks (255 KB) vía GridFSBucket
openUploadStream(name, { contentType, metadata }) ← stream.end(buffer)
openDownloadStream(id).pipe(res)       // streaming: la RAM no es tu buffer
multer({ memoryStorage, limits: { fileSize } })  // límite DECLARADO = 413
```

---

## ⚠️ Errores comunes y pieza forense

### Errores comunes

- Emitir **antes** de persistir (o en el controller): reconstruiste el
  cliente mentiroso con más pasos.
- Payload del evento distinto al de la API (olvidar el serializer): el
  frontend recibe `_id`/fechas crudas por socket y `id`/ISO por HTTP — bugs
  fantasma que solo pasan "cuando llega en vivo".
- socket.io 3.x/4.x en el server "porque es más nuevo": silencio total con
  el cliente 2.4. Media jornada perdida, garantizada.
- Importar `io` desde el server en los services (dependencia circular): el
  singleton `realtime/` existe para eso.
- Cargar el archivo entero en memoria para responderlo (`toArray` de chunks
  a mano en vez del stream): funciona en demo, muere con el PDF de 80 MB.
- multer sin `limits`: acabas de inaugurar un vector de denegación de
  servicio por upload.
- Subir a GridFS y guardar la relación al ticket "después": si el proceso
  muere entre ambos hay huérfanos — la metadata VA en el `openUploadStream`
  (una operación), no en un update posterior.
- Olvidar apagar el relé tonto: dos emisores en :4000 peleando… o peor, el
  viejo aún rebotando mentiras.

### Pieza forense de esta fase

Un backend que habla por dos canales tiene **dos fronteras**, y casi siempre solo
la primera está bien vigilada. Ésa es toda la pieza: el serializer que todo el
mundo aplica al responder un HTTP y nadie recuerda aplicar al emitir un evento.
El síntoma llega desde la interfaz —"en vivo se ve mal y al recargar se ve
bien"— y se diagnostica poniendo **los dos canales lado a lado**: pide el mismo
ticket con `curl` y escucha el evento por socket. Si las dos formas no coinciden,
ya sabes qué mitad del caso estás resolviendo. Después vienen las otras tres
preguntas de esta fase: dónde se emite, **si se emite antes o después de
escribir** —el orden es la deuda que este curso vino a pagar— y cuántos emisores
hay realmente, porque el relé tonto del sistema heredado puede seguir
encendido.

**🧨 Rompe a propósito**

Compara las dos fronteras en treinta segundos. Con el backend arriba, en una
consola del navegador:

```js
socket.on("ticket:updated", function (t) { console.log("socket:", t); });
```

Y en la terminal, sobre el mismo ticket:

```bash
curl -s localhost:4000/tickets/<id> | head -c 300
```

Si uno trae `_id` y fechas crudas y el otro `id` y fechas ISO, acabas de
encontrar el bug que solo pasa "cuando llega en vivo".

> 📄 El recorrido completo, con las salidas literales, en
> [`forense-fase-12.md`](forense-fase-12.md).

---

## 🧪 Ejercicios (38)

**🟢 Fácil (1–10)**

1. Apaga el relé tonto, levanta tu backend, abre el frontend en dos navegadores: crea un ticket en uno y verifica el toast en el otro. El momento mágico #2 — `git diff` del frontend: cero líneas.
2. Emite `ticket:updated` tras cada PATCH exitoso (el evento era ejercicio en el sistema heredado: ahora es real). Verifica el payload con el serializer.
3. Emite `ticket:deleted` tras el DELETE, con payload `{ id }`. ¿Por qué no el ticket completo? Defiende en un comentario.
4. Loguea conexiones y desconexiones con `socket.id` y el `reason`. Provoca 3 reasons distintos (cerrar pestaña, matar el server, timeout) y anótalos.
5. Prueba el cliente mentiroso post-mortem: desde la consola del navegador, intenta `socket.emit("ticket:created", {fake:true})` contra TU servidor. ¿Los demás navegadores lo reciben? Explica por qué el rebote murió por diseño (el server ya no re-emite lo que escucha).
6. `GET /attachments?ticketId=X`: lista la metadata de los adjuntos de un ticket (un `find` sobre `attachments.files` + serializer propio). Extensión pactada — regístrala en `00-audit-contrato.md`.
7. Sube tu primer archivo con `curl -F "file=@foto.png" -F "ticketId=..."` y descárgalo. Verifica bytes idénticos (`diff` o checksum).
8. Sube un archivo de 11 MB con el límite en 10. ¿Qué status devuelve? Convierte el error de multer en una respuesta JSON decente con el error handler de la Fase 10.
9. Adjunta el `uploadedBy` desde `req.user` e intenta falsificarlo mandándolo en el body. Verifica que se ignora (la lección del `reporter`, reaplicada).
10. Tacha en `SECURITY-NOTES.md` el cliente mentiroso y la subida irreal; agrega la entrada nueva de los sockets anónimos en modo compatible.

**🟡 Intermedio (11–20)**

11. El orden importa, demostrado: mueve el emit ANTES del `insertOne` y sabotea el insert (viola el validator de la Fase 4). ¿Qué recibieron los otros navegadores? Restaura el orden correcto y repite. Fotografía ambos comportamientos para `INSTINTOS.md`.
12. Implementa el middleware de handshake del capítulo. Conéctate sin token (debe entrar como anónimo), con token inválido (rechazado — ¿qué ve el cliente 2.4?) y con token válido (¿qué trae `socket.user`?).
13. Escribe la propuesta de cambio del cliente (UNA línea del `socketService` heredado: el token en `query` del connect) y el plan de despliegue en dos tiempos (cliente primero, exigencia después). Es el patrón "el contrato crece" con calendario.
14. Endurece el CORS del handshake: reemplaza `origins: "*:*"` por el origin del frontend. Verifica que el frontend entra y un HTML hostil servido desde otro puerto no.
15. Salas por ticket: al entrar al detalle, el cliente podría emitir `ticket:watch` con el id; implementa el lado servidor (`socket.join("ticket:" + id)`) y emite los `ticket:updated` de ese ticket **también** a su sala. (El cliente heredado no lo usa: deja el evento documentado como extensión disponible.)
16. Contador de conexiones en `/health` (Fase 10): agrega `sockets: io.engine.clientsCount`. Un endpoint HTTP y un servidor de sockets compartiendo proceso — muéstralo.
17. Abre el capó de GridFS: sube un archivo de 1 MB y examina `attachments.files` y `attachments.chunks` en mongosh. ¿Cuántos chunks? ¿Qué campos tiene cada uno? Verifica la cuenta 1 MB / 255 KB.
18. Descarga con rango: implementa soporte de `Range` headers en el download (streaming parcial — `openDownloadStream` acepta `start`/`end`). Pruébalo con `curl -H "Range: bytes=0-99"`. Es lo que un `<video>` pediría.
19. Borrado con juicio: `DELETE /attachments/:id` solo para el `uploadedBy` o un agente (roles de la Fase 11). ¿Borrar de GridFS es una operación o dos? (`bucket().delete(id)` — mira qué hace con files y chunks.)
20. Huérfanos: mata el proceso a mitad de un upload grande (archivo de 50 MB + `kill`). ¿Quedaron chunks sin su file? Escribe `scripts/gridfs-fsck.js` que los detecte y limpie — tu reconciliación (Fase 5) aplicada a bytes.

**🟠 Difícil (21–28)**

21. El torture-test con oídos: extiende el `npm run torture` (Fase 6, ej. 33) con un cliente socket.io que cuente eventos recibidos. Invariante nueva: eventos `ticket:created` recibidos ≤ tickets creados (at-most-once, nunca más). ¿Se cumple bajo carga?
22. Mide la pérdida real: con el server bajo carga, mata y reinicia el proceso 5 veces durante el torture. ¿Cuántos eventos se perdieron vs escrituras confirmadas? El número ES tu tolerancia at-most-once medida — a `DATA-MODEL.md`.
23. Conecta el outbox: para un evento hipotético de negocio (`ticket:resolved` que "dispara facturación"), usa tu outbox transaccional de la Fase 6: el worker emite por socket al procesar. Demuestra con el sabotaje del ej. 11 que este evento NO puede perderse ni inventarse.
24. Reconexión del lado que controlas: el cliente 2.x reconecta solo, pero se perdió lo emitido mientras tanto. Implementa `sync:since` — el cliente (hipotético) emite un timestamp y el server responde los tickets con `updatedAt` posterior (¡la Fase 4 pagando otra vez!). Documenta por qué esto convierte at-most-once en "at-most-once con recuperación".
25. Autorización fina en eventos: los tickets tienen `reporter`; emite `ticket:created` a TODOS los agentes pero solo al `reporter` dueño entre los anónimos... imposible con anónimos, ¿verdad? Escribe el análisis: qué autorización de eventos es posible en modo compatible y cuál exige el handshake con token. Es el argumento técnico para el despliegue del ej. 13.
26. Streaming end-to-end: sube un archivo de 200 MB (sube el límite temporalmente) monitoreando la RAM del proceso (`process.memoryUsage()` cada segundo). Repite con una versión saboteada que bufferea todo. Las dos curvas son la lección de streams — tabúlalas.
27. Content-type con malicia: sube un `.html` con `<script>` como adjunto y descárgalo desde el navegador. ¿Se ejecuta? Investiga y aplica las dos defensas de la época (`Content-Disposition: attachment` — ya la tienes, verifica — y `X-Content-Type-Options: nosniff` vía helmet). Documenta el ataque evitado en `SECURITY-NOTES.md`.
28. Presupuesto de GridFS: llena el bucket con 2 GB de archivos falsos, mide `db.stats()` antes/después, cronometra el backup de la Fase 0 (`mongodump`) con y sin el bucket (`--excludeCollection`). Escribe la política de backup de adjuntos del proyecto: ¿van en el dump diario o aparte?

**🔴 Muy difícil (29–34)**

29. El proxy unificador: monta nginx (o el proxy de webpack como referencia) que sirva `/api` → :3000 y `/socket.io` → :4000, y documenta qué cambiaría en el frontend (baseURL relativa + socket al mismo origin) para pagar la deuda de URLs hardcodeadas. Impleméntalo como docker-compose alterno — es el ensayo del compose final de la Fase 14.
30. Dos procesos, un problema: levanta DOS instancias de tu backend (puertos 3000/3001 con sockets 4000/4001) tras el proxy con round-robin. Crea un ticket vía la instancia A: ¿los clientes conectados a B se enteran? Documenta el problema (cada io tiene sus conexiones) e investiga el adaptador Redis de la época (`socket.io-redis` 5.x para io 2.x) — implementa el esqueleto o justifica por qué el Mini Jira no lo necesita aún.
31. GridFS vs archivos en disco: implementa la alternativa (`multer.diskStorage` + metadata en Mongo + streaming con `fs`) detrás de la MISMA interfaz del service. Compara: backup, permisos, borrado consistente, migración entre servers. Tabla de trade-offs y veredicto para ESTE proyecto en `DATA-MODEL.md`.
32. El emisor universal: crea `scripts/import-tickets.js` que inserte 50 tickets desde un CSV usando el **service** (no la colección directa). Verifica que los navegadores conectados recibieron los 50 eventos. Ahora reescríbelo insertando directo a la colección: silencio. La diferencia es el argumento "el emit vive en el service" — documéntala.
33. Replay de auditoría: usando `history` (Fase 3) + los eventos, escribe un endpoint de administración `GET /tickets/:id/timeline` que fusione transiciones, comentarios y adjuntos en una línea de tiempo ordenada. Tres colecciones, un `$unionWith` que suena a MongoDB moderno: ¿estará en 4.4? Verifícalo en la doc antes de asumir que no (spoiler: llegó justo en 4.4). Impleméntalo con y sin él, compara.
34. **El ensayo de la fase** (1 página, `INSTINTOS.md`): "El servidor como única fuente de eventos". Tesis: en el modelo heredado, el estado (base) y la narración del estado (eventos) tenían autores distintos — por eso podían mentirse; unificar el autor no elimina la pérdida de mensajes (mediste at-most-once) pero elimina la mentira, y la pérdida se gestiona con tolerancia declarada o outbox. Usa tus mediciones (ej. 21–23) y cierra con tu regla para decidir el nivel de garantía de un evento nuevo.

**🔀 Solo si hiciste una ruta del Curso 01 (35–38)**

35. Enriquece el `$push` de `takeTicket` (Fase 6) con la clave que falta para distinguir `"assigned"` de `"status_change"`, y haz que `serializeActivity` la use. Pregunta obligatoria antes de tocar nada: los tickets que **ya** tienen `history` sin esa clave, ¿qué `type` deben devolver? (Pista: es una migración de esquema en caliente, y la Fase 4 te dio el vocabulario.)
36. Monta `GET /activity?ticketId=X&_sort=at&_order=desc` sobre `serializeActivity`. Con el frontend de tu ruta apuntando a tu backend, abre el detalle de un ticket: el timeline tiene que pintar lo mismo que pintaba contra json-server. Cero líneas de `git diff` en el frontend.
37. Emite `activity:created` desde el servidor tras cada transición persistida, con el mismo payload del GET. Verifica en dos navegadores que la entrada aparece en vivo. Luego intenta emitirlo a mano desde la consola de uno: no debe llegar a nadie (murió el rebote, ejercicio 5).
38. `POST /activity` como no-op idempotente: devuelve 201 con la entrada derivada, sin escribir nada nuevo (la transición ya la escribió). Documenta la inversión de la deuda en `00-audit-contrato.md`: el 💸 ya no es del backend que no registra, sino del cliente que postea de más. ¿En qué fase del frontend se borraría esa llamada, y por qué no la borramos nosotros?

---

## 📚 Referencias

**Documentación oficial (versiones de la época)**

- socket.io 2.x — documentación archivada del servidor: https://socket.io/docs/v2/
- socket.io 2.x — Migración 2↔3 (léela para entender por qué NO migras): https://socket.io/docs/v4/migrating-from-2-x-to-3-0/
- GridFS (manual 4.4): https://www.mongodb.com/docs/v4.4/core/gridfs/
- Driver 3.6 — GridFSBucket: https://mongodb.github.io/node-mongodb-native/3.6/api/GridFSBucket.html
  > ⚠️ **Aviso de versión:** GridFS va por el **driver nativo 3.6** (`require("mongodb")`), no por Mongoose 5 (Fase 11). Tener Mongoose para los modelos no obliga a canalizar los streams de archivos por él; el bucket es cosa del driver.
- multer 1.x: https://github.com/expressjs/multer/tree/v1.4.4
- `$unionWith` (nuevo en 4.4 — para el ej. 33): https://www.mongodb.com/docs/v4.4/reference/operator/aggregation/unionWith/
- Node.js streams (v14): https://nodejs.org/docs/latest-v14.x/api/stream.html

**Web / apoyo**

- MDN — Range requests: https://developer.mozilla.org/en-US/docs/Web/HTTP/Range_requests
- OWASP — File Upload Cheat Sheet (el ej. 27 sale de aquí): https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html

**Video (YouTube)**

- WebSockets in 100 Seconds — Fireship: https://www.youtube.com/watch?v=1BfCnjr_Vjg
- Socket.io Crash Course — Traversy Media (verifica que use 2.x, o mira las diferencias con ojo crítico): https://www.youtube.com/watch?v=ZKEqqIO7n-k

**Orden de lectura sugerido para perfil senior:**
el diagrama del cambio arquitectónico (arriba — es la fase entera) →
ejercicios 1–5 y 11 (el orden emit/persist en carne propia) → GridFS del
manual (corto) → ejercicios de archivos → la doc de socket.io 2.x solo como
referencia de API → OWASP File Upload antes del ej. 27.

---

## 🚀 Cierre

Al final de esta fase el backend habla con voz propia: los eventos nacen de
la persistencia (el cliente mentiroso murió por diseño, no por vigilancia),
el relé tonto está jubilado, los sockets saben quién les habla cuando hay
token, y los adjuntos existen de verdad — subidos por multipart, guardados en
chunks, descargados en streaming, ligados a su ticket y a su autor. Dos
deudas heredadas tachadas y la tolerancia at-most-once medida, no supuesta.

La señal de que quedó bien:

> "puedo explicar por qué el evento se emite en el service después del
> insert, qué garantía pierdo por no meterlo 'en la transacción', y cuándo
> esa pérdida me obliga a sacar el outbox".

> 🏷️ **No cierres la fase sin el tag.** Con el checklist de arriba en verde y
> `git status` limpio:
>
> ```bash
> git tag -a fase-12-el-backend-habla -m "F12 cerrada: <el checklist, en una línea por ítem>"
> ```
>
> Los commits de la fase llevan su prefijo (`f12: …`) y los de ejercicio su
> número (`f12 ej17: …`). Si un ejercicio merece su propio marcador va en
> `ej/f12/17`, y un incidente resuelto en el par `inc/f12/<slug>-roto` /
> `-fix`. Todo eso está en
> [`../prompts/convencion-de-git-y-tags.md`](../prompts/convencion-de-git-y-tags.md).

**Siguiente parada:** 🧪 Fase 13 — Testing de API. Todo lo construido —
endpoints, precondiciones atómicas, serializers, sockets, streams — se puede
romper con un refactor inocente. Toca blindarlo: Jest + supertest +
mongodb-memory-server, y el smoke test manual del contrato convertido en
suite automática.

---

### 📌 Reservas para el cuaderno de incidentes

Esta fase aporta al [`cuaderno-incidentes.md`](cuaderno-incidentes.md) del curso:

| ID | Título propuesto | Categoría | Dif. |
|---|---|---|---|
| 11 | "En vivo llega mal y al recargar se ve bien" | Contrato | 🔴 |
