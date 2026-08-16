# 🧪 Fase 13 — Testing de API: tocar sin miedo

## 🎯 Propósito

Tienes un backend con precondiciones atómicas, serializers de frontera,
transiciones custodiadas, sockets y streams. Todo eso se rompe con un
refactor inocente — a menos que algo grite primero. Esta fase monta la red:
**Jest + supertest + mongodb-memory-server**, con la pirámide adaptada a un
backend de datos y una tesis heredada del proyecto que aquí rinde examen:

> **La testeabilidad es un detector de diseño.** Si una pieza cuesta testear,
> tiene demasiadas responsabilidades — y este backend, si las fases hicieron
> su trabajo, debería testearse casi solo. Donde no, encontraste deuda.

El premio final de la fase: el **smoke test manual del contrato**
(la checklist de `AUDIT-CONTRATO.md`, aprobada en la Fase 10 —su origen es el
smoke de Track A) convertido en suite automática.
El contrato deja de verificarse con fe y pasa a verificarse con `npm test`.

---

## ✅ Qué queda listo al terminar

- Jest configurado para el backend (nada de vue-test-utils aquí: esto es
  territorio Node puro);
- **mongodb-memory-server** levantando un Mongo 4.4 real y efímero por suite —
  tests contra el motor de verdad, sin tocar tu base, sin Docker en CI;
- la pirámide del proyecto poblada: funciones puras (serializers,
  transiciones) → services contra Mongo efímero → HTTP con supertest →
  contrato completo;
- el duelo del doble "tomar" (Fase 6) y el torture (`npm run torture`)
  convertidos en tests con aserciones — la concurrencia bajo CI;
- autenticación en tests resuelta con un acuñador de JWT de utilería;
- sockets testeados con `socket.io-client` desde Jest;
- **la suite de contrato**: cada fila de la checklist del smoke test, en código.

## 🚫 Qué NO entra todavía

- e2e con el frontend real (el smoke manual aprobado en la Fase 10 sigue
  siendo el rito de la promesa; aquí automatizamos el lado API)
- coverage como métrica-objetivo (se mide, no se persigue — la conversación
  está en los errores comunes)
- CI/CD, pipelines (la Fase 14 deja el compose; el pipeline es tuyo)
- performance testing serio (los cronómetros de las fases 5–7 son tu base;
  formalizarlo excede el curso)

---

## 🧠 La pirámide de ESTE backend en 60 segundos

```
        ▲  contrato (supertest, ~1 suite)     ← el smoke automatizado: caro, valioso
       ▲▲  HTTP por recurso (supertest)       ← rutas+middleware+controller+errores
      ▲▲▲  services (memory-server)           ← la lógica contra Mongo REAL efímero
     ▲▲▲▲  puro (sin I/O)                     ← serializers, transiciones, validadores
```

La decisión de época que ordena todo: **no mockeamos Mongo**. Un mock de la
colección te hace testear tu imaginación del motor (¿tu mock reproduce que
`$ne` matchea ausentes? ¿el upsert que colisiona?). mongodb-memory-server
descarga un `mongod` real y lo levanta en memoria: tus precondiciones
atómicas, validators de la Fase 4 e índices únicos se prueban **contra el
comportamiento verdadero** — a costo de milisegundos, no de fe.

> ### 🪞 Tu instinto dice… "la base se mockea; los tests no tocan un motor real"
>
> **Predicción falsable:** "testear contra un Mongo real será lento y frágil;
> lo profesional es mockear la capa de datos".
>
> Ese instinto viene de un mundo donde 'base real' significaba el Oracle
> compartido de QA: lento, con estado, peleado con otros equipos. Mídelo
> aquí (ejercicio 5): el memory-server arranca en ~1–2 s **una vez por
> suite**, cada test corre contra una base recién nacida, y borrarla cuesta
> nada. Lo que era caro (una instancia limpia) se volvió gratis, y con ello
> el mock pierde su razón de ser — quedándose solo con su costo: mantener en
> paralelo una imitación del motor. La regla de esta casa: **mockea las
> fronteras que no controlas o que cuestan de verdad** (HTTP externo, relojes,
> el emit de sockets cuando no es lo testeado), **no el motor que puedes
> levantar gratis**. **Veredicto: el instinto era correcto en 2009.** 📓 A
> `INSTINTOS.md`.

### 🩻 Esto SÍ funciona igual

Arrange-Act-Assert, fixtures, aislamiento entre tests, el olor de un test que
depende del orden, "un assert conceptual por test", tests de regresión al
cerrar un bug. Tu disciplina de testing de cualquier lenguaje viaja completa
— cambia el runner, no el oficio.

> ### 📖 La aserción que ya escribías, ahora contra Mongo efímero
>
> Lo que en SQL comprobabas con un `SELECT COUNT` y un assert de tu framework
> es exactamente lo mismo aquí — cambia el dialecto de la consulta, no la
> lógica de la verificación:
>
> | La verificación en SQL (tu vida hasta ayer) | La misma, contra el Mongo efímero |
> |---|---|
> | `assertEquals(1, SELECT COUNT(*) FROM tickets WHERE assignee IS NOT NULL)` | `expect(await db.collection("tickets").countDocuments({ assignee: { $ne: null } })).toBe(1)` |
> | `assertEquals('open', SELECT status FROM tickets WHERE id=?)` | `expect((await coll.findOne({ _id })).status).toBe("open")` |
> | fixture con `INSERT` en `setUp()` | `makeTicket()` + `insertOne` en `beforeAll` |
> | rollback de la transacción de test al terminar | base con nombre único por suite: no limpias, la tiras |
>
> El instinto de "arrange-act-assert contra una base real" no solo sobrevive:
> es justamente lo que el memory-server te devuelve barato. Lo único nuevo es
> que la base la levantas tú en milisegundos, no la comparte medio equipo.

---

## 🧰 El montaje

```bash
npm install --save-dev jest@26 supertest@6 mongodb-memory-server@6
```

> ⚠️ **Fijar el binario a la época:** mongodb-memory-server descarga un
> `mongod` — por defecto, uno moderno. El curso testea contra **4.4**, el
> motor real del proyecto:

```js
// jest.config.js
module.exports = {
  testEnvironment: "node",
  // hooks compartidos por suite (custom matchers, beforeEach globales) irían aquí;
  // por ahora vacío — la opción REAL es setupFilesAfterEnv (array), no setupFilesAfterEach
  setupFilesAfterEnv: [],
  globalSetup: "./test/globalSetup.js",
  globalTeardown: "./test/globalTeardown.js"
};
```

```js
// test/globalSetup.js — UN memory-server para toda la corrida
const { MongoMemoryServer } = require("mongodb-memory-server");

module.exports = async function () {
  const mongod = await MongoMemoryServer.create({
    binary: { version: "4.4.18" }          // ← el motor del curso, no "latest"
  });
  process.env.MONGO_URL = mongod.getUri();
  global.__MONGOD__ = mongod;
};
```

```js
// test/globalTeardown.js
module.exports = async function () { await global.__MONGOD__.stop(); };
```

```js
// test/helpers/db.js — cada suite, su base virgen
const { MongoClient } = require("mongodb");
let client;

async function connect() {
  client = await MongoClient.connect(process.env.MONGO_URL,
    { useUnifiedTopology: true });
  // nombre único por suite: aislamiento sin limpiar nada
  return client.db("test_" + Date.now() + "_" + Math.random().toString(36).slice(2));
}
async function close() { if (client) await client.close(); }
module.exports = { connect, close };
```

🔎 **Qué hace:** un solo `mongod` efímero para toda la corrida (arrancar uno
por test sería el instinto sobreprotector pagando de más), y **una base con
nombre único por suite** — el aislamiento por espacio, no por limpieza: nunca
más un `afterEach` que borra colecciones y a veces olvida una.

> 📝 **Nota legacy honesta — el `{ session }` de los tests:** ¿y las
> transacciones de la Fase 6? El memory-server también sabe de replica sets:
> `MongoMemoryReplSet` levanta un RS de un nodo efímero. Cuesta un par de
> segundos más de arranque y solo lo necesitan las suites que testean
> transacciones — el ejercicio 19 lo monta. El resto del curso corre en
> standalone efímero: más rápido, suficiente.

### El seed de tests: fixtures con nombre

```js
// test/fixtures/index.js — datos mínimos, deterministas, con nombre propio
const { ObjectId } = require("mongodb");

const users = {
  agent:    { _id: new ObjectId(), username: "soporte1", name: "Agente Uno",
              role: "agent" },
  reporter: { _id: new ObjectId(), username: "usuario1", name: "Usuario Reportador",
              role: "reporter" }
};

function makeTicket(overrides) {
  return Object.assign({
    _id: new ObjectId(), title: "Ticket de prueba", description: "",
    status: "open", priority: "medium", assignee: null,
    reporter: "usuario1", createdAt: new Date(), updatedAt: new Date(),
    schemaVersion: 3, history: []
  }, overrides || {});
}

module.exports = { users, makeTicket };
```

✅ **Buenas prácticas sembradas:** las fixtures usan el **vocabulario del
contrato** (mismos enums, mismos usernames del `db.json`), tienen forma v3
completa (pasan el validator de la Fase 4 — que también se instala en el
setup de las suites que lo prueban), y `overrides` permite el caso raro sin
duplicar la fixture.

---

## 🪜 La pirámide, piso por piso

### Piso 1 — puro: serializers y transiciones

```js
// test/lib/serializers.test.js
const { serializeTicket } = require("../../src/lib/serializers");
const { makeTicket } = require("../fixtures");

describe("serializeTicket (la frontera del contrato)", function () {
  test("_id se vuelve id string", function () {
    const out = serializeTicket(makeTicket());
    expect(typeof out.id).toBe("string");
    expect(out._id).toBeUndefined();
  });

  test("las fechas salen como ISO string", function () {
    const out = serializeTicket(makeTicket());
    expect(out.createdAt).toMatch(/^\d{4}-\d{2}-\d{2}T.*Z$/);
  });

  test("history NO se expone (decisión de la Fase 3)", function () {
    const out = serializeTicket(makeTicket({ history: [{}] }));
    expect(out.history).toBeUndefined();
  });
});
```

Cero I/O, milisegundos, y ya custodian las tres decisiones de frontera más
importantes del proyecto. Si algún día alguien "simplifica" el serializer, el
contrato grita aquí antes de que el frontend llore allá.

### Piso 2 — services contra Mongo efímero: el duelo, ahora es un test

```js
// test/services/tickets.take.test.js
const { connect, close } = require("../helpers/db");
const { users, makeTicket } = require("../fixtures");
const makeService = require("../../src/services/tickets.service");

let db, service;
beforeAll(async function () {
  db = await connect();
  service = makeService(db);                 // la costura: el service recibe su db
});
afterAll(close);

describe("takeTicket — el doble 'tomar' (Fase 6)", function () {
  test("dos agentes concurrentes: exactamente un ganador", async function () {
    for (let round = 0; round < 20; round++) {
      const t = makeTicket();
      await db.collection("tickets").insertOne(t);

      const [a, b] = await Promise.all([
        service.takeTicket(t._id.toHexString(), "soporte1"),
        service.takeTicket(t._id.toHexString(), "admin")
      ]);

      const winners = [a, b].filter(function (r) { return r.ok; });
      expect(winners).toHaveLength(1);                    // ni cero ni dos
      const doc = await db.collection("tickets").findOne({ _id: t._id });
      expect(doc.assignee).toBe(winners[0].ticket.assignee);
      expect(doc.history).toHaveLength(1);                  // la atomicidad, auditada
    }
  });

  test("tomar un tomado → conflict; inexistente → not_found", async function () {
    const t = makeTicket({ assignee: "admin", status: "in_progress" });
    await db.collection("tickets").insertOne(t);
    const r1 = await service.takeTicket(t._id.toHexString(), "soporte1");
    expect(r1).toEqual({ ok: false, reason: "conflict" });
    const r2 = await service.takeTicket(new (require("mongodb").ObjectId)().toHexString(), "soporte1");
    expect(r2).toEqual({ ok: false, reason: "not_found" });
  });
});
```

🔎 **Qué hace:** el duelo de la Fase 6 (ej. 12) ya no es un script que corres
cuando te acuerdas: son 20 rondas de carrera real contra un motor real, en
cada `npm test`. Y fíjate en la **costura**: `makeService(db)` — el service
recibe su base en vez de importar el singleton. Si tu Fase 10 usó el singleton
`db.js` directo, este es el momento del refactor mínimo (ejercicio 8): la
testeabilidad acaba de detectar el acople, tal como prometía la tesis.

### Piso 3 — HTTP con supertest: el transporte y sus manías

```js
// test/http/tickets.routes.test.js
const request = require("supertest");
const { mintToken } = require("../helpers/auth");   // acuña JWT de utilería (F11)

test("GET /tickets/:id inexistente → 404 real (manía del contrato)", async function () {
  const res = await request(app)
    .get("/tickets/5f8a1b2c3d4e5f6a7b8c9d0e")
    .set("Authorization", "Bearer " + mintToken({ username: "soporte1", role: "agent" }));
  expect(res.status).toBe(404);
});

test("PATCH de un tomado → 409 (la extensión pactada)", async function () {
  // ... sembrar tomado, PATCH con otro agente, esperar 409
});
```

### Piso 4 — la suite de contrato: el smoke, automatizado

```js
// test/contract/json-server-dialect.test.js
// Cada fila de la checklist de AUDIT-CONTRATO.md, en código:
//   array plano sin envelope · ?status= · ?q= en title+description
//   ?_sort=&_order= · POST devuelve id asignado y 201 · PATCH merge parcial
//   DELETE devuelve {} con 200 · fechas ISO · GET /users?role=agent ...
```

Suite lenta y sagrada: se toca cuando cambia el contrato, nunca "para que
pase". Es la diferencia entre *creer* que el frontend no se enterará y
*saberlo* en cada commit.

---

## 🧩 Chuleta de la fase

```js
// La pirámide: puro → service (memory-server) → HTTP (supertest) → contrato
// Regla: mockea fronteras caras/ajenas (HTTP externo, reloj, emits) — NO el motor gratis

MongoMemoryServer.create({ binary: { version: "4.4.18" } })  // el motor DEL CURSO
db único por suite ("test_" + unique)   // aislamiento por espacio, no por limpieza
makeService(db)                          // la costura: inyecta, no importes singletons

// concurrencia en tests: Promise.all + aserción de invariante (1 ganador, N rondas)
// auth en tests: mintToken(claims) — utilería, mismo verify real
// sockets: socket.io-client@2.4 conectado al server de test + done/promesa por evento
// coverage: se MIDE (--coverage), no se persigue
```

---

## ⚠️ Errores comunes y pieza forense

- Mockear la colección de Mongo y celebrar tests verdes que no prueban nada
  (tu mock jamás reproducirá el upsert que colisiona ni el `$ne` con
  ausentes).
- Un memory-server por test (lentitud autoinfligida) o una base compartida
  con `deleteMany` en `afterEach` (el test fantasma que depende del orden).
- No fijar la versión del binario: tests contra Mongo 7 de un backend que
  correrá en 4.4 — verde en CI, rojo en producción.
- Tests de concurrencia con UNA ronda: la carrera es probabilística; sin
  repeticiones, el verde es suerte.
- Asserts sobre el documento crudo cuando el contrato habla del serializado
  (o al revés): decide qué piso estás testeando.
- Perseguir el 100% de coverage tapando los huecos con tests que ejecutan
  sin afirmar. El coverage detecta lo NO probado; no certifica lo probado.
- Olvidar `--runInBand` o el aislamiento por base al paralelizar suites que
  comparten nombres de colección.
- Testear el emit de sockets en TODOS los tests de service (ruido): el
  singleton `realtime` con su no-op ya te protege; los sockets tienen su
  suite propia.

### 🩻 Pieza forense — "verde en mi máquina, rojo en CI"

El incidente más clásico de esta fase. Sigue la estructura de post-mortem del
curso (blameless: se analiza el sistema, no a la persona).

1. **Síntoma.** La suite pasa en local en cada corrida; en CI, una suite de
   `services/` falla intermitente con asserts sobre `$ne` y sobre el upsert que
   colisiona — a veces verde, a veces rojo, sin cambios de código.
2. **Reproducción.** Corre la suite en una máquina limpia (o borra la caché de
   binarios de mongodb-memory-server) sin fijar `binary.version`. El motor que
   descarga no es el mismo que en tu laptop.
3. **Evidencia observable.** `mongod --version` dentro del server efímero
   imprime un 7.x en CI y 4.4 en tu equipo (donde el binario ya estaba
   cacheado de otra fase). El log de arranque del `globalSetup` lo delata.
4. **Causa raíz.** Sin `binary: { version: "4.4.18" }`, mongodb-memory-server
   baja "el más nuevo disponible". El comportamiento de precondiciones
   atómicas e índices únicos que testeas **cambia entre versiones del motor**:
   tu test no es flaky, está midiendo dos motores distintos.
5. **Corrección.** Fija el binario en el `globalSetup` (ya está en el capítulo)
   y bórralo del entorno como variable suelta. Un solo motor, el del curso.
6. **Prueba de regresión.** Un test trivial que afirme
   `expect(db.admin().serverInfo().version).toMatch(/^4\.4/)` en una suite —
   si alguien "moderniza" el binario, grita antes que los tests de lógica.
7. **Prevención.** El binario fijado vive en el repo (no en la máquina de
   quien lo corrió primero); cachéalo en CI por su versión exacta, no por
   "latest".
8. **Post-mortem.** Nadie "rompió" nada: el default del paquete es descargar lo
   nuevo, y el primer dev tenía 4.4 cacheado de la Fase 0. El sistema permitía
   dos motores; el arreglo es que deje de permitirlo. La lección viaja al 🪞:
   "base real efímera" solo desarma al mock si es la **misma** base real.

---

## 🧪 Ejercicios (33)

**🟢 Fácil (1–8)**

1. Monta el esqueleto completo (jest.config con `setupFilesAfterEnv`, globalSetup con binario 4.4, helpers, fixtures) y logra el primer verde: los tests del serializer del capítulo. Deja instalado el ritual: `npm test` en verde + script `test:watch`.
2. Completa la suite del serializer: `assignee: null` viaja como null (no desaparece), campos desconocidos del doc no se filtran al contrato, y el serializer de comments hace lo propio con `ticketId`.
3. Testea `lib/objectId.js` (Fase 10): hex válido → ObjectId; basura → el error que el controller traduce a 404. Tabla de casos con `test.each`.
4. Testea las transiciones puras (la máquina de estados como datos): cada transición legal, tres ilegales, y el reopen desde cada estado.
5. Mide tu suite: ¿cuánto tarda el arranque del memory-server vs el total? Corre 3 veces y anota. Es el número que desarma el "testear contra base real es lento" — a `INSTINTOS.md` junto al 🪞.
6. Escribe `test/helpers/auth.js`: `mintToken(claims)` firmando con el mismo secreto de test que usa el `verify` real (variable de entorno de test). Pruébalo con un token expirado (`exp` en el pasado).
7. Primer supertest: `GET /health` responde 200 con la forma esperada. Descubre qué necesita `app` para ser importable sin hacer `listen` (si tu Fase 10 mezcló ambos: primera costura detectada). Encadena el 401: request sin token y con token corrupto a una ruta protegida, verificando también el **cuerpo** del error (la forma que definió tu error handler).
8. La costura del service: refactoriza `tickets.service` a `makeService(db)` (o factory equivalente) sin romper el server real. El diff debe ser pequeño; si no lo es, documenta qué acople lo agrandó.

**🟡 Intermedio (9–19)**

9. La suite del duelo (capítulo) corriendo: 20 rondas, invariantes de ganador único e history de 1. Sube a 100 rondas: ¿cuánto tarda? Decide el número para CI y defiéndelo.
10. Testea `releaseTicket` (Fase 6, ej. 14): dueño suelta → ok; no-dueño → conflict; con la variante admin.
11. Testea la transición con precondición contra el motor: `closed → resolved` debe fallar POR FILTRO (matchea 0), no por if. Verifica que el documento no cambió ni ganó entrada de history.
12. Instala el validator de la Fase 4 en el setup de una suite y testea que el motor rechaza `priority: "critical"`. El vocabulario del contrato, custodiado por un test que custodia al custodio.
13. Testea el upsert con carrera (Fase 6, ej. 24): 200 incrementos concurrentes al MISMO día nuevo con el índice único + retry. Invariante: contador final = 200, un solo documento. (Si los 200 inflan el `npm test`, baja a 50 aquí y deja los 200 originales para `test:torture` — pero dilo en el test, no cambies el número en silencio.)
14. Testea el dialecto y sus manías de forma en una sola suite: `?_sort=createdAt&_order=desc` devuelve orden correcto (siembra 5 con fechas conocidas), `?q=impresora` encuentra por título Y por descripción, `?q=` respeta el alcance firmado (no busca en `reporter`); y la forma: array plano sin envelope (el test falla si alguien "mejora" la respuesta a `{data: [...]}`), fechas ISO con regex, `DELETE` → `{}` con 200.
15. `POST /tickets`: 201, el `id` viene asignado y es hex de 24, el `reporter` sale del token aunque el body mienta (el test del ataque de la Fase 11).
16. `PATCH` es merge parcial: siembra completo, parchea solo `priority`, afirma que el resto sobrevivió — incluido lo que el serializer no expone (verifica en el doc crudo).
17. El 409 de punta a punta: dos PATCH "tomar" concurrentes vía supertest (Promise.all sobre la app). Uno 200, uno 409. El ensayo general de la Fase 6 (ej. 29), ahora bajo CI para siempre.
18. Testea el error handler: fuerza un error inesperado (mockea el service para lanzar — aquí SÍ se mockea: es tu frontera) y verifica 500 con cuerpo seguro (sin stack, sin detalles internos).
19. Monta `MongoMemoryReplSet` en una suite aparte y testea el rename transaccional de la Fase 6: el sabotaje (throw dentro del callback) deja CERO cambios en ambas colecciones. Anota el costo de arranque del RS efímero.

**🟠 Difícil (20–27)**

20. Sockets bajo test: levanta el server de sockets en un puerto efímero, conecta `socket.io-client@2.4` desde Jest, crea un ticket vía service y afirma que el evento llegó con la forma del serializer (promesa que resuelve en el `on`). Timeout decente y cleanup prolijo.
21. El orden emit/persist como test de regresión: mockea `realtime.emit` (frontera), sabotea el insert (validator), y afirma **cero llamadas** al emit. El bug del ej. 11 de la Fase 12, imposible de reintroducir.
22. El handshake: token válido → conecta y `socket.user` presente (expónlo en un evento de eco de test); token inválido → el cliente recibe `error`; sin token → conecta anónimo. Tres tests, tres destinos.
23. Streams bajo test: sube un archivo vía supertest (`.attach()`), descárgalo, compara checksums. Agrega el caso 413 (archivo sobre el límite) y el 404 de id inexistente.
24. El fsck de GridFS (Fase 12, ej. 20) testeado: fabrica huérfanos a mano (inserta chunks sin file), corre el script, afirma la limpieza y que los archivos sanos sobrevivieron.
25. El torture como test: adapta `npm run torture` (Fase 6/11) a una suite `test:torture` separada del `npm test` normal (60 s no van en cada commit): mezcla concurrente 15 s + TODAS las verificaciones de invariantes como asserts. Documenta cuándo corre (pre-release, nightly).
26. Suite de contrato completa: implementa `test/contract/` con TODAS las filas de la checklist de `AUDIT-CONTRATO.md`. Etiquétala y créale su script (`test:contract`). Cuenta: ¿cuántas filas eran automatizables al 100%? ¿Cuáles siguen necesitando el frontend real?
27. Rompe el contrato a propósito: renombra `id` → `ticketId` en el serializer y corre `test:contract`. Cuenta cuántos tests gritan y CUÁLES. Si algún cambio de contrato pasara en silencio, acabas de encontrar un hueco en la suite — tápalo. (Testear los tests: el oficio completo.)

**🔴 Muy difícil (28–33)**

28. Reloj bajo control: los tokens expiran y `updatedAt` sella — testea ambos con tiempo falso (jest fake timers donde aplique; para el `exp` del JWT, acuña con fechas elegidas). Caso duro: el test del token que expira "durante" el request.
29. Property-based casero: genera 500 tickets aleatorios VÁLIDOS (generador con el vocabulario del contrato) y afirma la propiedad universal: `serialize(deserialize(serialize(x)))` estable, y todo serializado pasa una validación ajv del contrato (el schema de la Fase 4, versión API). Un bug de esquina que los ejemplos fijos no cazan, ¿aparece?
30. Mutación artesanal: introduce a mano 5 mutaciones al service (invierte la precondición del take, quita el `$push` de history, cambia un `$gte` por `$gt`...) y verifica que la suite mata las 5. La que sobreviva delata un hueco — repáralo. (Es Stryker sin Stryker: el concepto, con las manos.)
31. Presupuesto de suite: mide y tabula el tiempo por piso de la pirámide. Propón y aplica el reparto para un `npm test` de <30 s (qué corre siempre, qué en `test:slow`, qué nightly). La velocidad de la suite ES una feature: sin ella, nadie la corre.
32. Auditoría ajena: toma un proyecto Node+Mongo de GitHub de la época CON tests. Clasifica sus tests en la pirámide, detecta mocks del motor, tests dependientes del orden, y asserts vacíos. Reporte de 1 página con los tres hallazgos más graves y su arreglo. La promesa del curso, aplicada al testing.
33. **El ensayo de la fase** (1 página, `INSTINTOS.md`): "El test no prueba que funciona: prueba que sigue funcionando igual". Tesis: en un backend de datos, el valor de la suite no está en el momento verde sino en fijar el comportamiento del contrato y las invariantes de concurrencia contra el refactor futuro — por eso se testea contra el motor real (el comportamiento incluye al motor) y por eso la suite de contrato es sagrada. Usa el ej. 27 y 30 como evidencia. Cierra con tu política personal: qué exige test antes del merge en TU equipo.

---

## 📚 Referencias

**Documentación oficial (versiones de la época)**

- Jest 26: https://jestjs.io/docs/26.x/getting-started
- supertest: https://github.com/ladjs/supertest
- mongodb-memory-server (v6, la de la época — configuración de binario): https://github.com/nodkz/mongodb-memory-server/tree/v6.9.6
- socket.io-client 2.x: https://socket.io/docs/v2/client-api/
- Jest — fake timers (26.x): https://jestjs.io/docs/26.x/timer-mocks

**Web / apoyo**

- Testing Node.js + Mongo con mongodb-memory-server (el README versionado es la mejor guía práctica, incluida la configuración de binario): https://github.com/nodkz/mongodb-memory-server/blob/v6.9.6/README.md
- Martin Fowler — Test Pyramid (el original, para discutirlo): https://martinfowler.com/articles/practical-test-pyramid.html
- Kent C. Dodds — Write tests. Not too many. Mostly integration. (la contracorriente de la época, pertinente a ESTE backend): https://kentcdodds.com/blog/write-tests

**Video (YouTube)**

- Jest Crash Course — Traversy Media: https://www.youtube.com/watch?v=7r4xVDI2vho
- Test-Driven Development // Fun TDD in 100 seconds — Fireship: https://www.youtube.com/watch?v=Jv2uxzhPFl4

**Orden de lectura sugerido para perfil senior:**
la pirámide del capítulo → montar el esqueleto (ej. 1) ANTES de leer más →
el 🪞 con tu medición del ej. 5 → Fowler vs Dodds (dos posturas, 40 min, y
decide dónde cae este backend) → los pisos 2–4 con sus ejercicios → el README
de mongodb-memory-server como referencia permanente.

---

## 🚀 Cierre

Al final de esta fase el backend está blindado por pisos: las decisiones de
frontera custodiadas en tests puros, el duelo del doble "tomar" corriendo 20
rondas en cada commit contra un Mongo 4.4 real y efímero, el dialecto y sus
manías fijados en la suite de contrato, y hasta los sockets y los streams con
sus verificaciones. La tesis rindió examen: donde el test costó, apareció un
acople (y lo cosiste); donde el diseño era limpio, el test salió solo.

La señal de que quedó bien:

> "puedo refactorizar el service de tickets un viernes a las 6 sin sudar:
> si rompo el contrato o una invariante de concurrencia, algo grita antes
> del push — y sé exactamente qué piso de la pirámide gritó y por qué".

**Siguiente parada:** 🛠️ Fase 14 — Operación: lo que un dev SQL sí extraña.
El sistema funciona y está blindado; falta operarlo como adulto: backups
programados con oplog, índices en producción sin bloquear a nadie, el
profiler como tu Slow Query Log de siempre, y el docker-compose final que
empaqueta todo.
