# 🍃 Fase 1 — Mongo en 30 min para gente que ya sabe bases de datos

## 🎯 Propósito

En la Fase 0 dejaste Docker y una instancia Mongo 4.4 respirando, vacía. Hoy la
llenamos de verdad.

Ponerte a consultar MongoDB **hoy**, sin fingir que no sabes qué es una base de
datos. Llevas años con SQL Server / Oracle / PostgreSQL / MySQL: este capítulo
no te explica qué es una PK — te dice **cómo se llama ahora, qué cambió de
verdad y qué es solo vocabulario**.

Y termina con trabajo real: importar el `db.json` heredado (el mock que hoy
alimenta al frontend) a una instancia Mongo de época. Ese script de seed es tu
primer choque honesto con el paradigma: **la integridad referencial ahora es
tu problema.**

> ⚠️ Trabajamos con **MongoDB 4.4** a propósito. Es la versión que vas a
> encontrar en el legacy 2018–2021 que este curso simula. Lo que aprendas
> sirve hacia adelante; lo que NO existe en 4.4, no lo usamos aunque exista
> hoy.

---

## ✅ Qué queda listo al terminar

- el entorno de la Fase 0 adoptado como entorno del proyecto
  (`minijira-backend/` con su compose y su `.env` propios);
- el diccionario de traducción SQL↔Mongo interiorizado (y colgado en la pared);
- entender qué es un documento BSON, qué es un ObjectId y por qué no vas a
  extrañar el `AUTO_INCREMENT`;
- la base `minijira` sembrada desde el `db.json` heredado, con referencias
  retraducidas y fechas convertidas a `Date`;
- el archivo `INSTINTOS.md` creado con sus 2 primeras entradas.

## 🚫 Qué NO entra todavía

- consultas más allá de `find` básico (Fase 2, con todo el arsenal)
- decisiones de modelado embeber/referenciar (Fase 3 — no adelantes juicio)
- validación de esquema (Fase 4)
- aggregation, índices, transacciones (Fases 9, 7, 6)
- Express y cualquier cosa con HTTP (Fase 10)

---

## 📖 El diccionario de traducción

Pégalo donde lo veas. Las tres columnas importan: la del medio te dice si el
concepto **viaja intacto** o si el parecido es una trampa.

| SQL | ¿Viaja intacto? | MongoDB |
|---|---|---|
| Base de datos | ✅ sí | Base de datos |
| Tabla | ⚠️ casi | Colección (sin esquema impuesto por el motor) |
| Fila / registro | ⚠️ casi | Documento (BSON, anidable, campos variables) |
| Columna | ⚠️ casi | Campo (puede existir en unos documentos y en otros no) |
| PK | ✅ sí | `_id` (único, indexado, obligatorio, inmutable) |
| `AUTO_INCREMENT` / `SEQUENCE` | ❌ no | `ObjectId` (generado en el **cliente**, sin coordinación) |
| FK + constraint | ❌ **no existe** | Referencia por convención; **nadie la valida por ti** |
| JOIN | ❌ no | `$lookup` (existe, pero es plan B — Fase 5) |
| Índice | ✅ **sí, intacto** | Índice (B-tree, compuestos, prefijo izquierdo — Fase 7) |
| `EXPLAIN PLAN` | ✅ sí | `explain()` |
| Transacción multi-tabla | ⚠️ existe, pero no es el pegamento | Transacción multi-documento (4.0+) — Fase 6 |
| `CHECK` / `NOT NULL` | ⚠️ se mudó | JSON Schema Validation (opcional) — Fase 4 |
| `NULL` | ⚠️ trampa | `null` **o campo ausente** — son cosas distintas (Fase 2) |
| SQL (lenguaje) | ❌ no | MQL: documentos que describen consultas |
| Vista | ⚠️ casi | Vista (sobre aggregation) |
| `GROUP BY` | ⚠️ casi | Aggregation pipeline (Fase 9) |
| DBA te crea la base | ❌ no | La base y la colección **nacen al primer insert** |

### 🩻 Esto SÍ funciona igual

No vienes a olvidar todo. Estas intuiciones tuyas viajan intactas y este curso
las va a **usar**, no a demoler:

- **Los índices son índices.** B-trees, selectividad, compuestos, el costo de
  mantenerlos en cada escritura. Tu década de afinar queries vale (Fase 7).
- **La paranoia del N+1** sigue siendo virtud. Cambia el disfraz del problema,
  no el problema.
- **`EXPLAIN` es tu amigo.** `explain("executionStats")` te va a resultar
  familiar en 10 minutos.
- **El modelo de datos decide el rendimiento.** Esto es MÁS cierto en Mongo,
  no menos.

---

## 🧠 El documento en 60 segundos

Un documento es un objeto BSON (JSON binario con tipos extra: `Date`,
`ObjectId`, `Decimal128`, binarios…). Se parece a una fila, pero:

```js
{
  _id: ObjectId("5f8a1b2c3d4e5f6a7b8c9d0e"),
  title: "La impresora del piso 3 no imprime",
  status: "open",
  priority: "high",
  reporter: "usuario1",
  assignee: null,
  createdAt: ISODate("2020-03-10T10:00:00Z")
}
```

- puede **anidar** objetos y arrays (una "fila" con una tabla adentro);
- dos documentos de la misma colección pueden tener **campos distintos** —
  el motor no protesta (si eso te produce escalofríos: bien, guárdalos para
  la Fase 4);
- tope duro: **16 MB por documento** (te va a importar en la Fase 3).

### ObjectId: la PK que no necesita pedir permiso

12 bytes: `timestamp (4) + random de máquina/proceso (5) + contador (3)`.
Consecuencias que un cerebro SQL debe registrar:

1. **Se genera en el cliente**, antes de tocar la base. No hay viaje al
   servidor para pedir "el siguiente número". No hay contención en una
   secuencia. Insertas desde 40 procesos a la vez y nadie coordina nada.
2. **Lleva el timestamp adentro**: ordenar por `_id` ≈ ordenar por creación.
3. No es adivinable ni secuencial: nadie enumera tus recursos sumando 1.

> ### 🪞 Tu instinto dice… "necesito el id autoincremental"
>
> **Predicción falsable:** "sin `AUTO_INCREMENT` voy a necesitar una tabla de
> contadores para tener ids".
>
> Puedes construirla en Mongo (colección `counters` +
> `findOneAndUpdate({$inc:{seq:1}})` — el patrón circula por todos los foros
> de la época). Pero acabas de reintroducir **un punto de contención global en
> cada insert** para conseguir… ¿qué, exactamente? ¿Que los ids sean bonitos?
> El ObjectId te da unicidad sin coordinación, orden temporal aproximado y
> generación distribuida. **Veredicto: el instinto se equivoca.** El contador
> solo se justifica si un requisito de negocio exige números legibles por
> humanos (folio de factura). "Es lo que siempre hice" no es un requisito.
>
> 📓 Primera entrada de tu `INSTINTOS.md`.

> ### 🪞 Tu instinto dice… "primero el DDL: creo la base, las tablas, y después inserto"
>
> No hay DDL. `use minijira` no crea nada; el primer `insertOne` crea base y
> colección al vuelo. Comodísimo y aterrador: un typo en el nombre de la
> colección no da error — **crea una colección nueva** y tu insert cae ahí.
> `db.tikets.insertOne(...)` funciona perfecto. Ese es el precio.
> **Veredicto: el instinto se equivoca a medias** — no necesitas DDL, pero
> necesitas la disciplina que el DDL te regalaba. 📓 Segunda entrada.

---

## 🐳 El entorno (heredado de la Fase 0)

El `docker-compose.yml` parametrizable de la Fase 0 es el del proyecto: cópialo
(con su `.env`) a la raíz de `minijira-backend/` y ajusta dos parámetros para
que el entorno del curso quede identificado y separado de tu `playground`:

```bash
# .env del proyecto
MONGO_CONTAINER=minijira-mongo
MONGO_DATA_PATH=./mongo-data     # los datos del Mini Jira, físicamente aquí
```

```bash
docker compose up -d
mongosh mongodb://localhost:27017
```

Si elegiste el camino nativo (Windows/macOS), no cambia nada: mismo puerto,
mismas conexiones — tu `SETUP.md` de la Fase 0 ya documenta tu caso.

### Primeros comandos (2 minutos, en mongosh)

```js
show dbs                 // tus bases (minijira aún no existe)
use minijira             // "cámbiate" a ella (aún no existe: no importa)
db.tickets.insertOne({ title: "hola mundo", status: "open" })
show dbs                 // ahora sí existe
db.tickets.find()
db.tickets.drop()        // limpia el experimento
```

🔎 **Qué hace:** demuestra el nacimiento-al-primer-insert. Insertaste sin
declarar nada, y `find()` sin argumentos es tu `SELECT * FROM tickets`.

---

## 🌱 El seed: del mock heredado a Mongo de verdad

Aquí empieza el proyecto. El `db.json` heredado (la **fixture oficial**, 6
usuarios / 14 tickets / 23 comentarios) tiene esta forma —abajo va **un
extracto de una fila por colección**, no el archivo entero:

```json
{
  "tickets": [
    { "id": 1, "title": "La impresora del piso 3 no imprime",
      "description": "Otra vez.", "status": "open", "priority": "high",
      "assignee": null, "reporter": "usuario1",
      "createdAt": "2020-03-10T10:00:00Z" }
  ],
  "users": [
    { "id": 1, "username": "admin", "name": "Usuario Demo", "role": "agent" },
    { "id": 2, "username": "soporte1", "name": "Agente Uno", "role": "agent" },
    { "id": 3, "username": "usuario1", "name": "Usuario Reportador", "role": "reporter" }
  ],
  "comments": [
    { "id": 1, "ticketId": 1, "author": "soporte1",
      "body": "¿Probaste apagarla y prenderla?",
      "createdAt": "2020-03-10T11:00:00Z" }
  ]
}
```

> ⚠️ **`admin` ahí es un _username_, no un rol.** Los únicos roles válidos son
> `agent` y `reporter` (lo blindarás con validación de esquema en la Fase 4).
> Que un usuario se llame `admin` no le da un rol `admin`: ese valor no existe.

Fíjate en la mina enterrada: `comments.ticketId = 1` apunta al ticket `id: 1`.
En tu mundo, eso era una FK y el motor la custodiaba. Aquí vamos a reemplazar
cada `id` numérico por un ObjectId… y **nadie va a retraducir ese `ticketId`
por ti**.

### Estructura inicial del proyecto

```
minijira-backend/
  docker-compose.yml
  package.json
  .nvmrc                  ← 14.21.3
  data/
    db.json               ← copiado del proyecto heredado
  scripts/
    seed.js               ← lo escribimos ahora
  INSTINTOS.md            ← tu bitácora de instintos (ya tiene 2 entradas)
```

```bash
nvm use && npm init -y
npm install mongodb@3.6
```

### `scripts/seed.js`

```js
// Seed: importa el db.json heredado a MongoDB.
// Node 14 + driver nativo mongodb@3.6 — sin ODM, a mano, a propósito.
const { MongoClient, ObjectId } = require("mongodb");
const fs = require("fs");
const path = require("path");

const MONGO_URL = "mongodb://localhost:27017";
const DB_NAME = "minijira";

async function main() {
  const raw = fs.readFileSync(path.join(__dirname, "../data/db.json"), "utf8");
  const data = JSON.parse(raw);

  const client = await MongoClient.connect(MONGO_URL, {
    useUnifiedTopology: true
  });
  const db = client.db(DB_NAME);

  // Empezar de cero: el seed debe ser re-ejecutable (idempotente por las malas)
  await db.dropDatabase();

  // ── 1. users: id numérico → ObjectId, guardando el mapa de traducción
  const userIdMap = new Map(); // idViejo -> ObjectId nuevo
  const users = data.users.map(function (u) {
    const _id = new ObjectId();
    userIdMap.set(u.id, _id);
    return { _id, username: u.username, name: u.name, role: u.role };
  });
  await db.collection("users").insertMany(users);

  // ── 2. tickets: igual, más fechas string → Date
  const ticketIdMap = new Map();
  const tickets = data.tickets.map(function (t) {
    const _id = new ObjectId();
    ticketIdMap.set(t.id, _id);
    return {
      _id,
      title: t.title,
      description: t.description || "",
      status: t.status,
      priority: t.priority,
      assignee: t.assignee,          // username o null (así lo usa el frontend)
      reporter: t.reporter,
      createdAt: new Date(t.createdAt)
    };
  });
  await db.collection("tickets").insertMany(tickets);

  // ── 3. comments: AQUÍ está la lección de la fase.
  // ticketId apuntaba a un número que ya no existe. La "FK" la retraduces TÚ.
  const comments = data.comments.map(function (c) {
    const ticketId = ticketIdMap.get(c.ticketId);
    if (!ticketId) {
      // En SQL esto era un error del motor. Aquí es un console.log tuyo
      // o un comentario huérfano silencioso. Elige ser el motor.
      throw new Error("Comentario " + c.id + " apunta a ticket inexistente: " + c.ticketId);
    }
    return {
      _id: new ObjectId(),
      ticketId,                       // ObjectId del ticket nuevo
      author: c.author,
      body: c.body,
      createdAt: new Date(c.createdAt)
    };
  });
  await db.collection("comments").insertMany(comments);

  console.log("Seed OK:", users.length, "users,", tickets.length, "tickets,",
    comments.length, "comments");
  await client.close();
}

main().catch(function (err) {
  console.error("El seed falló:", err.message);
  process.exit(1);
});
```

🔎 **Qué hace:** lee el JSON, recorre cada colección generando ObjectIds
nuevos, **mantiene mapas de traducción** para reescribir las referencias, y
convierte fechas de string a `Date` de BSON. El `throw` de la sección 3 es el
momento didáctico: acabas de escribir a mano lo que `FOREIGN KEY` hacía gratis.

✅ **Buenas prácticas que ya quedaron sembradas:**

- el seed **arrasa y reconstruye** (`dropDatabase`) — re-ejecutable siempre;
- las fechas se guardan como `Date`, no como string (los strings no se
  comparan como fechas ni sirven para TTL ni para rangos eficientes);
- `assignee`/`reporter` guardan el `username` tal como el frontend lo espera —
  la tentación de "normalizarlo" a un ObjectId de `users` la discutimos con
  números en la Fase 3, no por reflejo.

```bash
node scripts/seed.js
# Seed OK: 6 users, 14 tickets, 23 comments
```

Verifica en Compass o mongosh:

```js
use minijira
db.tickets.countDocuments()
db.comments.findOne()      // mira el ticketId: es un ObjectId, no un número
```

> 💸 **Deuda declarada:** las fechas viajan a Mongo como `Date`, pero el
> contrato de la API exige devolverlas como string ISO. Esa ida y vuelta la
> paga la capa API en la Fase 10. Está firmado en `AUDIT-CONTRATO.md`.

### 📡 El contrato en el horizonte

Lo que acabas de sembrar no es un dataset de práctica: es **exactamente** lo
que los endpoints del contrato van a servir. Tenlo a la vista desde ya:

| Colección sembrada | Endpoints que alimentará (Fase 10) | Vocabulario cerrado |
|---|---|---|
| `tickets` | `GET /tickets` (+ `?status=`, `?_sort=`, `?_order=`, `?q=`), `GET/POST/PATCH/DELETE /tickets/:id` (con **404 real** en un `:id` inexistente) | `status`: `open · in_progress · resolved · closed` — `priority`: `low · medium · high` |
| `users` | `GET /users` (+ `?role=agent`) | `role`: `agent · reporter` |
| `comments` | `GET /comments?ticketId=X&_sort=createdAt`, `POST /comments` | — |

Dos consecuencias inmediatas: (1) esos enums son **vocabulario cerrado del
contrato** — cuando en la Fase 4 recuperes el `CHECK`, ya sabes qué validar;
(2) el frontend habla de `id` y tu base habla de `_id: ObjectId` — la
traducción en la frontera está decidida y firmada en `AUDIT-CONTRATO.md`, y
la implementa la Fase 10. Hoy solo debías saber que existe.

---

## 🧩 Chuleta de la fase

```js
// Levantar / entrar
docker compose up -d
mongosh mongodb://localhost:27017/minijira

// Supervivencia en mongosh
show dbs; use minijira; show collections
db.tickets.find()                        // SELECT *
db.tickets.findOne({ status: "open" })   // TOP 1 con WHERE
db.tickets.countDocuments()              // COUNT(*)
db.tickets.drop()                        // DROP TABLE

// Los 3 hechos que debes recordar
// 1. _id: ObjectId, generado en el cliente, sin secuencia, sin contención.
// 2. Base y colección nacen al primer insert. Los typos también.
// 3. Las referencias son convención tuya. El motor no valida nada.
```

---

## ⚠️ Errores comunes

- Guardar fechas como string "porque en el JSON venían así" (rompe rangos,
  sort correcto y TTL — y la Fase 7 te lo va a cobrar).
- El typo-colección: escribir `db.tiket.find()` y concluir "se borraron los
  datos". No hay error de "tabla no existe": hay colecciones fantasma.
- Comparar `_id` con un string: `find({ _id: "5f8a..." })` no encuentra nada;
  necesitas `new ObjectId("5f8a...")`. (La capa API de la Fase 10 vive de esta
  traducción.)
- Montar Mongo sin volumen y perder todo al recrear el contenedor.
- Construir la colección de contadores autoincrementales "por costumbre".
- Usar la imagen `mongo:latest` y estudiar contra una versión que tu legacy
  no tiene.

---

## 🧪 Ejercicios (30)

**🟢 Fácil (1–10)**

1. Adopta el compose de la Fase 0 en `minijira-backend/` con contenedor y ruta de datos propios. Verifica con `db.version()` y deja anotado en el README puerto, versión y ruta física de los datos.
2. Ejecuta el seed dos veces seguidas. ¿Por qué no duplica datos? Señala la línea responsable.
3. En mongosh: lista todos los tickets con `status: "open"`.
4. Cuenta cuántos usuarios tienen `role: "agent"` con `countDocuments`.
5. Inserta a mano (mongosh) un ticket nuevo con los mismos campos que los del seed. Verifica que Compass lo muestra.
6. Extrae el timestamp de un ObjectId con `.getTimestamp()`. Compáralo con el `createdAt` del documento. ¿Por qué no coinciden en los datos del seed?
7. Provoca el typo-colección a propósito: inserta en `db.tikets` y luego lista las colecciones. Bórrala con `drop()`.
8. Detén y elimina el contenedor (`docker compose down`) y vuelve a levantarlo: los datos siguen. Ahora ejecuta `docker compose down -v`: ¿siguieron también? Explica por qué el `-v` no destruyó nada con bind mount, y qué habría pasado con el volumen nombrado del ejercicio 12 de la Fase 0.
9. En Compass, usa la pestaña Schema sobre `tickets`. ¿Qué tipos infiere para cada campo? ¿De dónde salen si "Mongo no tiene esquema"?
10. Crea `INSTINTOS.md` con las 2 entradas de la fase, en formato: *instinto → predicción → qué pasó → veredicto*.

**🟡 Intermedio (11–20)**

11. Modifica el seed para que reciba la ruta del `db.json` como argumento de línea de comandos (`node scripts/seed.js ./data/db.json`), con mensaje de uso si falta.
12. Agrega al seed un modo `--dry-run` que haga todas las traducciones y reporte conteos sin escribir nada en Mongo.
13. Sabotea el `db.json`: agrega un comentario con `ticketId: 999`. Ejecuta el seed y verifica que el `throw` lo detecta. Ahora cámbialo por una versión que **acumule** todos los huérfanos y los reporte juntos al final antes de fallar.
14. Haz que el seed valide que no haya dos `username` iguales en `users` (en SQL era un `UNIQUE`; aquí, por ahora, eres tú).
15. Inserta un documento en `tickets` con un campo inventado (`color: "azul"`). ¿Protesta algo? Escribe en 3 líneas qué implicaciones tiene para un equipo de 6 devs. (Guárdalas: son el prólogo de la Fase 4.)
16. Escribe un script `scripts/verify.js` que compruebe que cada `comments.ticketId` apunta a un ticket existente y salga con código 1 si no. Acabas de escribir tu primer *checker* de integridad referencial.
17. Inserta 3 tickets en una sola llamada con `insertMany`. ¿Qué devuelve exactamente? Inspecciona `insertedIds`.
18. En `insertMany`, mete un documento inválido en la posición 2 (por ejemplo, `_id` duplicado de uno existente) y observa qué pasa con los documentos 1 y 3. Repite con la opción `{ ordered: false }` y explica la diferencia.
19. Genera un ObjectId en Node **sin conectarte a la base** (`new ObjectId()` a secas) e imprímelo. Explica en un comentario por qué esto es imposible con una secuencia de Oracle.
20. Cronometra el seed con `console.time`. Ahora duplica los datos del `db.json` (copia los tickets con títulos modificados) y vuelve a medir. Deja anotada la línea base: la vas a comparar en la Fase 7.

**🟠 Difícil (21–26)**

21. Implementa el contador autoincremental clásico (`counters` + `findOneAndUpdate` con `$inc` y `returnOriginal: false`) y úsalo para dar un campo `folio` numérico a cada ticket del seed. Funciona, ¿verdad? Ahora escribe en `INSTINTOS.md` **por qué no lo vas a usar como `_id`**: qué pasa con 40 procesos insertando a la vez contra ese documento contador. *(Nota de versión: `returnOriginal: false` es la opción del driver 3.6 que usamos; el `returnDocument: 'after'` que verás en tutoriales modernos es del driver 4.x y aquí no existe.)*
22. Demuestra la afirmación anterior: script que lance 20 inserts *concurrentes* (Promise.all) usando el contador, y otro con ObjectId puro. Mide ambos. ¿Se nota ya la contención? ¿Con cuántos se notaría? (Pista: prueba 500.)
23. Haz el seed **transaccionalmente honesto sin transacciones**: si falla la carga de `comments`, la base no debe quedar a medias. (Pista de época: escribir a colecciones temporales y renombrar, o validar todo antes de escribir nada. Elige, implementa y defiende tu elección en un comentario.)
24. Escribe `scripts/export.js`: el camino inverso, de Mongo a un `db.json` válido para json-server (ObjectId → string en `id`, `Date` → ISO string, y `ticketId` retraducido). Verifica que json-server arranca con el archivo exportado.
25. El `db.json` heredado trae fechas en ISO con `Z`. Modifica una a `"2020-03-10T10:00:00"` (sin zona) y observa qué `Date` produce `new Date(...)` en tu máquina. Documenta el peligro y haz que el seed rechace fechas sin zona horaria.
26. Empaqueta el seed como comando npm (`npm run seed`) y agrega `npm run seed:verify` que encadene seed + verify. Deja el README con las 4 líneas exactas para que otra persona levante todo desde cero.

**🔴 Muy difícil (27–29)**

27. Genera un `db.json` sintético de **100.000 tickets y 400.000 comentarios** (script generador con faker o aleatorios a mano, distribución realista: 60% closed, 20% open, fechas repartidas en 2 años). Siembra y cronometra. ¿`insertMany` de golpe o por lotes? Experimenta con tamaños de lote (100, 1.000, 10.000) y grafica/tabula los tiempos.
28. Sobre esa base grande: mide cuánto tarda `verify.js`. Propón e implementa una versión que no cargue todos los tickets en memoria (pista: un `Set` de ids sigue siendo memoria; piensa en recorrer comments con cursor y consultar en lotes).
29. Investiga y documenta (1 página en `INSTINTOS.md`): ¿por qué MongoDB eligió que el cliente genere los ids? Conéctalo con sistemas distribuidos: ¿qué pasa con una secuencia central cuando hay sharding? No necesitas sharding para responder; necesitas el argumento.

**🔥 Opcionales**

- 🔥 Lee la anatomía completa del ObjectId en la doc 4.4 y escribe un decodificador propio en Node: recibe el string hex y devuelve `{ timestamp, random, counter }` sin usar el driver. Compara tu timestamp con `.getTimestamp()`.

---

## 📚 Referencias

**Documentación oficial (MongoDB 4.4 y driver 3.6 — tus versiones)**

- Manual MongoDB 4.4 — Introducción: https://www.mongodb.com/docs/v4.4/introduction/
- Manual 4.4 — Databases and Collections: https://www.mongodb.com/docs/v4.4/core/databases-and-collections/
- Manual 4.4 — Documents: https://www.mongodb.com/docs/v4.4/core/document/
- Manual 4.4 — BSON Types: https://www.mongodb.com/docs/v4.4/reference/bson-types/
- Manual 4.4 — ObjectId: https://www.mongodb.com/docs/v4.4/reference/method/ObjectId/
- Manual 4.4 — SQL to MongoDB Mapping Chart (la tabla oficial equivalente a nuestro diccionario): https://www.mongodb.com/docs/v4.4/reference/sql-comparison/
- Driver Node.js 3.6 — Quick Start y API: https://mongodb.github.io/node-mongodb-native/3.6/
- Imagen Docker oficial: https://hub.docker.com/_/mongo
- mongosh: https://www.mongodb.com/docs/mongodb-shell/

**Libros**

- *MongoDB: The Definitive Guide*, 3.ª ed. (Bradshaw, Brazil, Chodorow —
  O'Reilly 2019; escrita justo para la época 4.x). Caps. 1–2 para esta fase.

**Web / apoyo**

- MongoDB University — M001 (MongoDB Basics; gratuito): https://learn.mongodb.com/
- Compass: https://www.mongodb.com/docs/compass/

**Video (YouTube)**

- MongoDB in 100 Seconds — Fireship: https://www.youtube.com/watch?v=-bt_y4Loofg
- MongoDB Crash Course — Traversy Media: https://www.youtube.com/watch?v=-56x56UppqQ
- How do NoSQL databases work? — Simply Explained: https://www.youtube.com/watch?v=0buKQHokLK8

**Orden de lectura sugerido para perfil senior:**
SQL to MongoDB Mapping Chart (10 min, vas a discutir con la tabla — bien) →
Documents + BSON Types → ObjectId → seed y ejercicios → Definitive Guide
caps. 1–2 solo si quieres consolidar.

---

## 🚀 Cierre

Al final de esta fase tienes: el entorno de época corriendo, el diccionario en
la pared, la base `minijira` sembrada desde el mock heredado, y —más
importante— **dos instintos auditados por escrito** y la primera experiencia
visceral de que la integridad referencial cambió de dueño: ahora eres tú.

La señal de que quedó bien:

> "puedo explicar qué es un ObjectId sin decir 'es como un autoincremental',
> y entiendo qué me regalaba el motor SQL que ahora tengo que ganarme".

**Siguiente parada:** 🔍 Fase 2 — Consultar: tu SQL, traducido. Todo tu
`SELECT` con su gemelo Mongo al lado, y las dos trampas (`null` y los tipos)
que hacen tropezar a todo veterano la primera semana.
