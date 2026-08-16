# 🧬 Fase 4 — El esquema que no está en la base

## 🎯 Propósito

**Cambio de paradigma #2: el esquema no desaparece — se muda.** De la base a
la aplicación, del DDL al código, del `ALTER TABLE` a la convivencia de
versiones.

En tu mundo, el esquema era un contrato que el motor imponía: nada entraba a
la tabla sin la forma correcta, y cambiar la forma era un evento (el `ALTER`
del viernes a las 11 pm). En Mongo el motor acepta cualquier documento — pero
tu aplicación NO. El esquema existe igual; la pregunta es **quién lo custodia
y qué pasa cuando cambia**. Esta fase responde ambas: custodia compartida
(la app valida siempre; el motor puede ayudar con JSON Schema Validation, el
`CHECK` que creías perdido) y cambio sin evento (versiones conviviendo +
migración perezosa o masiva, a elección con criterio).

---

## ✅ Qué queda listo al terminar

- entender por qué "schemaless" es un nombre mentiroso ("schema-on-read" es
  el honesto);
- el patrón `schemaVersion` y documentos de 3 versiones conviviendo sin drama;
- decidir entre migración **perezosa** y **masiva** con una tabla de criterio;
- JSON Schema Validation activa en `tickets`, `users` y `comments`, validando
  el **vocabulario cerrado del contrato** (los enums de status/priority/role);
- la **forma del sub-documento de transición** de `history` fijada aquí
  (`{ from, to, by, at }`), cerrando lo que la Fase 3 dejó abierto: eligió el
  array embebido pero no bautizó sus campos;
- `validationLevel` y `validationAction` entendidos y elegidos con razones;
- una migración masiva real ejecutada sobre el proyecto (con dry-run y backup);
- `DATA-MODEL.md` actualizado con la sección "Esquema y versiones".

## 🚫 Qué queda fuera por ahora

- los operadores de update en profundidad (`$set` asoma aquí; el arsenal
  completo y su atomicidad, en la Fase 6)
- aggregation para auditar formas a escala (Fase 9; aquí usamos `$type` y
  conteos de la Fase 2)
- Mongoose y sus schemas de aplicación (Fase 11 — y esta fase explica por
  qué un schema de ODM **no** sustituye al del motor)
- índices sobre los campos nuevos (Fase 7)

---

## 🧠 "Schemaless" en 60 segundos (y por qué es marketing)

Lo que Mongo no tiene es **esquema impuesto en escritura** (schema-on-write).
Pero el esquema existe en tres lugares, lo declares o no:

1. **En tus documentos** — la forma que de hecho tienen (Compass la infiere
   en la pestaña Schema: eso ES un esquema, descubierto en vez de declarado).
2. **En tu código** — cada `ticket.status` que tu backend lee es una
   suposición de forma. El esquema vive en cada línea que accede a un campo.
3. **En el contrato** — el frontend espera `status`, `priority`, `assignee`,
   `reporter`, `createdAt` con tipos exactos. Eso es un esquema con auditor
   externo.

> ### 🪞 Tu instinto dice… "sin esquema en el motor, esto es el salvaje oeste"
>
> **Predicción falsable:** "en una colección sin validación, a los 6 meses
> habrá documentos con formas incompatibles y consultas que fallan en
> silencio".
>
> La predicción es **correcta** — lo probaste en la Fase 2 (el `priority: 3`
> que ningún filtro por string encuentra). Pero la conclusión "entonces Mongo
> es inviable en serio" se equivoca por incompleta: la flexibilidad no es un
> descuido del motor, es una **herramienta con dos filos**. El filo bueno:
> desplegar un campo nuevo sin `ALTER`, sin lock, sin ventana de
> mantenimiento, con versiones conviviendo mientras migras a tu ritmo. El
> filo malo: nadie te protege por defecto. La respuesta madura no es fingir
> que el esquema no existe ni añorar el DDL: es **declararlo donde aporta**
> (validación del motor para invariantes duras; disciplina de app para el
> resto). **Veredicto: el instinto acierta el riesgo y falla la solución.**
> 📓 A `INSTINTOS.md`.

### 🩻 Esto SÍ funciona igual

Tu paranoia de tipos y dominios — la que te hacía elegir `VARCHAR(20)` con
`CHECK` en vez de texto libre — viaja intacta y aquí vale doble. Y el
concepto de **invariante de negocio** (qué debe ser verdad siempre) es
idéntico; solo cambia dónde se declara.

---

## 🕰️ Versiones conviviendo: la escena que vas a heredar

Así se ve una colección real tras 3 años de evolución sin disciplina:

```js
// v1 (2019): sin prioridad, fecha string 😱
{ _id: ..., title: "...", status: "open",
  reporter: "usuario1", createdAt: "2019-06-01T10:00:00Z" }

// v2 (2020): prioridad y assignee, fecha ya Date
{ _id: ..., title: "...", status: "open", priority: "high",
  assignee: null, reporter: "usuario1", createdAt: ISODate("...") }

// v3 (2021): history embebido (¡nuestra Fase 3!), tags
{ _id: ..., title: "...", status: "open", priority: "high",
  assignee: "soporte1", reporter: "usuario1", createdAt: ISODate("..."),
  history: [ ... ], tags: ["hardware"] }
```

No hay `ALTER TABLE` que las unifique porque no hay tabla que alterar. Tus
opciones son dos, y ambas son legítimas:

### El patrón `schemaVersion`

Cada documento declara su forma:

```js
{ _id: ..., schemaVersion: 3, title: "...", ... }
```

El código lee la versión y actúa. Sin este campo, tu código "detecta" la
versión oliendo campos (`if (!ticket.priority)`) — funciona hasta que dos
versiones huelen igual. Declarar la versión cuesta un campo; adivinarla
cuesta bugs.

### Migración perezosa vs masiva

| | Perezosa (lazy) | Masiva (eager) |
|---|---|---|
| Cómo | al **leer/escribir** un doc viejo, la app lo actualiza de paso | un script recorre y transforma todo de una vez |
| Cuándo brilla | colecciones enormes, cambio no urgente, tráfico que ya toca los docs | el código nuevo NO quiere cargar con lecturas multi-versión; colección abarcable |
| Costo | el código soporta N versiones **mientras dure** (¿y los docs que nadie lee nunca?) | ventana de ejecución, carga sobre el server, necesita dry-run y backup |
| El legado que deja | `if (schemaVersion < 3)` esparcidos — cada uno es deuda con fecha | un script en `scripts/migrations/` — historia auditable |

Regla de la época: **perezosa para lo caliente y enorme; masiva para lo
abarcable; y siempre una fecha de defunción para el código multi-versión**
(la perezosa sin fecha de fin es cómo nacen los legacies que este curso
enseña a heredar).

### Migración masiva de verdad: `updatedAt` para todos

El proyecto la necesita (el PATCH de la Fase 10 querrá sellar modificaciones):

```js
// scripts/migrations/002-add-updatedAt.js  (driver 3.6, Node 14)
const { MongoClient } = require("mongodb");

async function main() {
  const dryRun = process.argv.includes("--dry");
  const client = await MongoClient.connect("mongodb://localhost:27017",
    { useUnifiedTopology: true });
  const col = client.db("minijira").collection("tickets");

  const filter = { updatedAt: { $exists: false } };
  const total = await col.countDocuments(filter);
  console.log((dryRun ? "[DRY] " : "") + "Documentos a migrar:", total);

  if (!dryRun && total > 0) {
    // updatedAt arranca igual a createdAt: honesto y consultable.
    // OJO: esta migración NO toca schemaVersion. Estampar aquí un "2" fijo
    // pisaría a los documentos que ya son v3 (priority + history). La versión
    // se infiere por forma en su propia migración (001-add-schemaVersion.js,
    // ejercicio 13): sin priority → 1; con priority sin history → 2; con
    // history → 3. Una migración, una responsabilidad.
    const result = await col.updateMany(filter, [
      { $set: { updatedAt: "$createdAt" } }
    ]);
    console.log("Modificados:", result.modifiedCount);
  }
  await client.close();
}
main().catch(function (e) { console.error(e); process.exit(1); });
```

🔎 **Qué hace:** filtra los no-migrados (re-ejecutable: correrlo dos veces no
rompe nada — **idempotencia**, la virtud número 1 de un script de migración),
soporta `--dry`, y usa el *update con pipeline* (corchetes en el segundo
argumento — disponible desde 4.2) para copiar `createdAt` en `updatedAt`, algo
que el update clásico no puede hacer (referenciar otro campo del documento).

✅ **Buenas prácticas sembradas:** numerar migraciones
(`scripts/migrations/00N-*.js`), dry-run siempre, backup JSON antes (Fase 0
te dio el script), y anotar en `DATA-MODEL.md` qué versión introduce qué.

---

## 🛡️ JSON Schema Validation: el `CHECK` que creías perdido

Desde 3.6 el motor **sí puede** validar en escritura — si se lo pides. En 4.4
está maduro y es exactamente lo que un cerebro SQL quiere recuperar:

```js
// En mongosh: activar validación sobre una colección EXISTENTE
db.runCommand({
  collMod: "tickets",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["title", "status", "priority", "reporter", "createdAt"],
      properties: {
        title:    { bsonType: "string", minLength: 1, maxLength: 200 },
        // El vocabulario cerrado del CONTRATO, ahora custodiado por el motor:
        status:   { enum: ["open", "in_progress", "resolved", "closed"] },
        priority: { enum: ["low", "medium", "high"] },
        assignee: { bsonType: ["string", "null"] },   // username o null
        reporter: { bsonType: "string" },
        createdAt:{ bsonType: "date" },               // date BSON EN LA BASE; la API la serializa a ISO string (contrato, Fase 10)
        updatedAt:{ bsonType: "date" },
        schemaVersion: { bsonType: "int" },
        history: {
          bsonType: "array",
          items: {
            bsonType: "object",
            required: ["from", "to", "by", "at"],
            properties: {
              from: { enum: ["open", "in_progress", "resolved", "closed"] },
              to:   { enum: ["open", "in_progress", "resolved", "closed"] },
              by:   { bsonType: "string" },
              at:   { bsonType: "date" }
            }
          }
        }
      }
    }
  },
  validationLevel: "moderate",
  validationAction: "error"
})
```

🔎 **Qué hace:** declara forma, obligatorios, tipos BSON y **enums** — tus
`NOT NULL` + `CHECK` + tipado, en sintaxis JSON Schema. Nota `assignee` con
tipo doble `["string", "null"]`: el null explícito del contrato es legal, la
ausencia del campo también (no está en `required`) — decisión consciente que
viene de la trampa 1 de la Fase 2.

Las dos perillas que cambian todo:

| Perilla | Valores | Qué decide |
|---|---|---|
| `validationLevel` | `strict` (valida todo update/insert) / `moderate` (**solo** docs que ya cumplen + inserts; los viejos inválidos pueden seguir actualizándose) | qué hacer con el pasado |
| `validationAction` | `error` (rechaza) / `warn` (deja pasar y escribe al log) | qué hacer con el presente |

> 📝 **Nota legacy honesta — el despliegue en 3 tiempos:** sobre una
> colección con años de datos, activar `strict`+`error` de golpe es un viernes
> negro: los updates a documentos v1 empiezan a fallar en producción. La
> secuencia adulta de la época: (1) `warn` + revisar logs = censo de
> violaciones sin romper nada; (2) migrar/reparar lo que el censo encontró;
> (3) subir a `moderate`+`error`, y a `strict` solo cuando el censo dé cero.
> Los ejercicios 21–23 recorren el camino completo.

> ⚠️ **Lo que la validación NO hace:** no valida *transiciones* (que un
> ticket no salte de `closed` a `in_progress` sin pasar por `open` no es
> expresable aquí — eso es lógica de negocio y se paga en la Fase 11), no
> valida referencias (que `assignee` exista en `users` sigue siendo tu
> problema — Fase 1 dixit), y no sustituye la validación de entrada de la API
> (express-validator, Fase 10): el motor es la **última línea**, no la única.

---

## 🧩 Chuleta de la fase

```js
// Censo de formas (Fase 2 al servicio de esta)
db.tickets.find({ updatedAt: { $exists: false } }).count()
db.tickets.find({ createdAt: { $type: "string" } })      // contaminación
db.tickets.distinct("schemaVersion")

// Validación
db.getCollectionInfos({ name: "tickets" })   // ver el validator vigente
db.runCommand({ collMod: "tickets", validator: {...},
                validationLevel: "moderate", validationAction: "warn" })
// crear colección YA validada:
db.createCollection("users", { validator: {...} })

// Migración
updateMany(filtro-de-no-migrados, cambio)     // idempotente o no es migración
updateMany(filtro, [ { $set: { b: "$a" } } ]) // pipeline: copiar campo a campo

// Los 3 tiempos del despliegue: warn → reparar → error (moderate → strict)
```

---

## ⚠️ Errores comunes

- Confundir el schema de Mongoose (Fase 11) con validación del motor: el ODM
  valida **en tu proceso Node**; cualquier otro cliente (mongosh, otro
  servicio, el script de un compañero) escribe lo que quiere. El validator
  del motor aplica a **todos**.
- Activar `strict + error` sobre datos históricos sin censo previo.
- Migraciones no idempotentes (correrla dos veces duplica o corrompe).
- Migrar sin `--dry` ni backup ("era un updateMany chiquito").
- Validar demasiado: convertir el validator en una réplica del negocio
  entero. Invariantes duras al motor; reglas que cambian seguido, a la app.
- Olvidar que `validator` también aplica a tus scripts de seed: el seed de la
  Fase 1 debe pasar la validación (si no pasa, la validación acaba de
  encontrarle un bug al seed — funciona).
- El `bsonType: "int"` vs los números de JavaScript: el driver manda
  `double` por defecto; si exiges `int`, usa `NumberInt()` en mongosh /
  `{ $numberInt: ... }` o relaja a `"number"`. Clásico de hora y media
  perdida.

---

## 🧪 Ejercicios (34)

**🟢 Fácil (1–10)**

1. Censo inicial: ¿cuántos tickets no tienen `updatedAt`? ¿Cuántos tienen `createdAt` string? ¿Qué versiones de `schemaVersion` conviven? (Antes de tocar nada: medir.)
2. Ejecuta la migración `002-add-updatedAt.js` en `--dry`, luego real, luego **otra vez real**. Verifica la idempotencia con los conteos.
3. Activa el validator de `tickets` del capítulo con `warn`. Inserta un ticket con `priority: "urgente"` — ¿entró? Encuentra la advertencia en los logs del contenedor (`docker compose logs mongo | grep -i warn`).
4. Sube a `validationAction: "error"` e intenta lo mismo. Lee el error completo del driver: ¿te dice QUÉ regla falló? (Guarda tu opinión para el ejercicio 26.)
5. Escribe el validator de `users`: `username` y `name` obligatorios strings, `role` con el enum del contrato (`agent`/`reporter`).
6. Escribe el validator de `comments`: `ticketId` de tipo `objectId`, `author` y `body` strings no vacíos, `createdAt` date.
7. Verifica que el seed completo de la Fase 1 pasa las tres validaciones (re-siémbralo con todo activo). Si algo falla, arregla el seed, no la validación.
8. Intenta insertar un ticket sin `reporter`. Ahora uno con `reporter: null`. ¿Ambos fallan? ¿Por qué? (Conecta con la trampa 1 de la Fase 2: `required` vs tipo `null`.)
9. `db.getCollectionInfos({ name: "tickets" })`: localiza el validator vigente y su level/action. Es lo primero que auditarás en cualquier legacy.
10. Documenta en `DATA-MODEL.md` la sección "Esquema y versiones": versión vigente de cada colección, qué introdujo cada una, validators activos y su nivel.

**🟡 Intermedio (11–20)**

11. Fabrica la escena heredada: inserta (desactivando temporalmente la validación con `validationLevel: "off"`) 5 tickets v1 (sin priority, fecha string) y 5 v2. Reactiva en `moderate`. ¿Puedes seguir editando el `title` de un v1? ¿Y con `strict`? Documenta la diferencia exacta que observaste.
12. Escribe la migración `003-normalize-dates.js`: convierte los `createdAt` string a `Date` (pipeline update con `$toDate`), idempotente y con `--dry`. Pruébala sobre los v1 del ejercicio anterior.
13. Escribe `001-add-schemaVersion.js` (la que debió ser primera): marca todo documento sin el campo con la versión que **infiera** de su forma (sin priority → 1; con priority sin history → 2; con history → 3). La inferencia es exactamente el trabajo sucio que `schemaVersion` evita hacia adelante.
14. Implementa la **migración perezosa** en un módulo Node `lib/ticketUpgrader.js`: función `upgrade(doc)` pura que recibe un ticket de cualquier versión y devuelve la forma v3 (sin escribir a la base). Tests mentales: pásale un v1, un v2, un v3 (debe devolverlo intacto).
15. Conecta la perezosa: script que lea 10 tickets al azar, los pase por `upgrade()`, y **persista solo los que cambiaron** (compara versiones). Es el esqueleto del "reparar al tocar" que la Fase 10 podría montar en el service.
16. La fecha de defunción: define el criterio medible para borrar `ticketUpgrader.js` ("cuando `countDocuments({schemaVersion:{$lt:3}})` sea 0 durante 30 días"). Escribe el check como script que un cron correría. La perezosa sin esto es deuda eterna.
17. Valida el vocabulario del contrato con un experimento hostil: intenta colar cada valor ilegal (`status: "OPEN"` en mayúsculas, `priority: "critical"`, `role: "admin"`). Confirma que el motor rechaza los tres. Acabas de blindar los enums que la Fase 2 declaró.
18. `moderate` a fondo: con un v1 inválido vivo, ¿qué updates te deja hacer y cuáles no? Prueba: editar `title` (no toca lo inválido), poner `priority: "high"` (repara parcialmente), poner `priority: "urgente"` (empeora). Tabla de resultados.
19. El validator de `history` exige `from`/`to` del enum. Inserta una transición ilegal *semánticamente* pero legal *sintácticamente* (`from: "closed", to: "resolved"` sin pasar por open). ¿El motor protesta? Escribe en `INSTINTOS.md` la línea divisoria: forma vs negocio.
20. `bsonType` en carne propia: exige `schemaVersion: { bsonType: "int" }` e inserta desde mongosh con `schemaVersion: 3` a secas. ¿Pasa? Repite con `NumberInt(3)`. Investiga qué tipo numérico manda mongosh por defecto y decide: ¿`"int"` o `"number"` para este curso? Justifica.

**🟠 Difícil (21–28)**

21. **El despliegue en 3 tiempos, completo (parte 1):** sobre una base contaminada a propósito (usa el generador de 100k y saboteala: 10% sin updatedAt, 5% fechas string, 2% priority ilegal), activa `warn` y construye el **censo de violaciones** parseando el log de mongod (script que cuente violaciones por tipo).
22. **(parte 2):** repara con migraciones numeradas e idempotentes cada categoría del censo. Re-ejecuta el censo hasta cero.
23. **(parte 3):** sube a `moderate`+`error`, verifica que la app hipotética (tus scripts) sigue funcionando, y sube a `strict`. Documenta el runbook completo en `DATA-MODEL.md`: es un procedimiento que ejecutarás en la vida real.
24. Mide el costo de validar: con la base de 100k, cronometra 10.000 inserts con validator activo vs sin validator (`validationLevel: "off"`). ¿Cuánto cuesta el `CHECK` recuperado? ¿Cambia con un validator 3 veces más complejo?
25. El validator también sabe de condicionales: usando `dependencies` o combinando `oneOf`/`anyOf` de JSON Schema, exige que **si** `status` es `in_progress`, `assignee` no sea null. Pruébalo en las 4 combinaciones. (Acabas de expresar una regla de negocio parcial en el motor — discute en 3 líneas si debería vivir ahí.)
26. Los errores de validación de 4.4 son crípticos (un "Document failed validation" seco). Escribe `lib/validationExplainer.js`: recibe el documento rechazado y el `$jsonSchema`, y reporta EN ESPAÑOL qué reglas viola (valida en Node con la librería `ajv` contra el mismo schema). Es la herramienta de soporte que tu equipo te agradecerá.
27. Sincroniza motor y aplicación: extrae el `$jsonSchema` de tickets a un archivo `schemas/ticket.schema.json` que sea **la única fuente**: un script lo aplica al motor (`collMod`) y la app lo carga para pre-validar con `ajv` antes de escribir. Cambia el enum en un solo lugar y verifica que ambos mundos lo tomaron.
28. Migración con volumen y sin ventana: sobre 100k documentos, tu `003-normalize-dates` de golpe vs por lotes de 1.000 con pausa de 50 ms (patrón de la época para no ahogar el server compartido). Cronometra ambos y mide (a ojo con `mongostat` si quieres extra) el impacto. ¿Cuál usarías en el server de producción del que dependen 40 personas?

**🔴 Muy difícil (29–34)**

29. Construye el **framework mínimo de migraciones** del proyecto: colección `_migrations` que registra qué scripts ya corrieron (nombre, fecha, duración), runner `scripts/migrate.js` que ejecuta en orden los pendientes de `scripts/migrations/`, con `--dry` global y bloqueo simple contra doble ejecución concurrente (un doc lock en `_migrations` — tu primer sabor de la Fase 6). Es la pieza que TODO backend serio de la época tenía artesanal.
30. Rollback honesto: agrega a tu framework el par `up`/`down` por migración e implementa el `down` de `002-add-updatedAt`. Escribe después el párrafo incómodo: ¿por qué el `down` de una migración perezosa es casi imposible? ¿Y el de una que *destruyó* información (`unset` de un campo)?
31. Detección de drift: script `scripts/schema-drift.js` que compare la forma REAL de la colección (muestrea 1.000 docs, infiere campos/tipos/frecuencias) contra el `ticket.schema.json` declarado, y reporte: campos en datos que el schema no conoce, campos declarados que nadie usa, tipos divergentes. Córrelo tras sabotear la base. (Compass hace esto visual; tú lo acabas de hacer auditable y programable.)
32. Versionado del validator mismo: diseña cómo evolucionar el `$jsonSchema` cuando el contrato crezca (Fase 11 agregará campos de auth). Propón el flujo: PR al `.schema.json` → migración que aplica `collMod` → censo. Implementa el esqueleto y documenta en `DATA-MODEL.md` la política.
33. El caso multi-tenant de la época: una colección `tickets` compartida por 3 clientes donde el cliente A exige un campo extra obligatorio (`costCenter`) y los otros no lo tienen. ¿Se puede expresar en un solo validator? (`anyOf` por discriminador `tenant`.) Impleméntalo, mide la legibilidad, y escribe tu recomendación honesta: ¿un validator condicional o la validación por tenant en la app?
34. **El ensayo de la fase** (1 página, `INSTINTOS.md`): "El ALTER TABLE era una ceremonia; la ceremonia era el punto". Tesis a explorar: el dolor del `ALTER` en SQL forzaba diseño previo y cambios deliberados; su ausencia en Mongo transfiere esa disciplina al equipo — y los equipos que no la asumieron produjeron los legacies de 3 versiones sin `schemaVersion` que ahora heredas. Usa tus experimentos como evidencia. Cierra con tu protocolo personal de 5 reglas para cambiar un esquema en Mongo.

---

## 📚 Referencias

**Documentación oficial (4.4)**

- Schema Validation (el capítulo central): https://www.mongodb.com/docs/v4.4/core/schema-validation/
- `$jsonSchema` (sintaxis y keywords soportadas): https://www.mongodb.com/docs/v4.4/reference/operator/query/jsonSchema/
- `collMod` (aplicar validación a colección existente): https://www.mongodb.com/docs/v4.4/reference/command/collMod/
- Updates with Aggregation Pipeline (el update de corchetes): https://www.mongodb.com/docs/v4.4/tutorial/update-documents-with-aggregation-pipeline/
- `updateMany`: https://www.mongodb.com/docs/v4.4/reference/method/db.collection.updateMany/
- Data Modeling — Schema Versioning pattern (en Building with Patterns, abajo)

**La serie de la época**

- Building with Patterns: The Schema Versioning Pattern (Alger & Coupal): https://www.mongodb.com/blog/post/building-with-patterns-the-schema-versioning-pattern
- The Outlier Pattern y The Document Versioning Pattern de la misma serie — lectura lateral que redondea.

**JSON Schema (el estándar detrás)**

- Understanding JSON Schema (guía canónica): https://json-schema.org/understanding-json-schema
- ajv (validador para el lado Node, ej. 26–27): https://ajv.js.org/

**Libros**

- *MongoDB: The Definitive Guide*, 3.ª ed. — secciones de schema design y
  administración de colecciones.

**Video (YouTube)**

- MongoDB Schema Validation — canal oficial MongoDB en YouTube: https://www.youtube.com/@MongoDB (⚠️ sin URL estable a un video único que sobreviva al tiempo: busca "schema validation" dentro del canal y prioriza los subidos entre 2019–2021, que usan la sintaxis exacta de esta fase; los posteriores muestran la UI de Atlas, que no aplica a tu 4.4 self-hosted)

**Orden de lectura sugerido para perfil senior:**
Schema Validation de la doc (te va a parecer corta: bien, el concepto es
chico) → `$jsonSchema` como referencia mientras escribes los validators →
Schema Versioning Pattern → ejercicios 21–23 (el despliegue en 3 tiempos es
LA habilidad operativa de la fase) → Understanding JSON Schema solo como
consulta.

---

## 🚀 Cierre y conexión con la siguiente fase

Al final de esta fase el esquema dejó de ser un fantasma: está declarado en
`schemas/*.json`, custodiado por el motor con el nivel elegido a conciencia,
versionado con `schemaVersion`, y sus cambios viajan en migraciones numeradas,
idempotentes y con dry-run. El vocabulario cerrado del contrato (los enums)
tiene ahora un guardián que ningún cliente puede esquivar.

La señal de que quedó bien:

> "puedo heredar una colección de 3 versiones sin `ALTER TABLE` y sin pánico:
> sé censarla, sé decidir perezosa o masiva, y sé desplegar validación sin
> romper el viernes de nadie".

**Siguiente parada:** 🔗 Fase 5 — `$lookup` y por qué es una alarma. El JOIN
existe en Mongo. Vas a aprenderlo, vas a medirlo… y vas a aprender a
desconfiar de él en el lugar exacto donde tu instinto SQL lo pondría.
