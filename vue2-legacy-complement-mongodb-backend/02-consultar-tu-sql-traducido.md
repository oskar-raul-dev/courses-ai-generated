# 🔍 Fase 2 — Consultar: tu SQL, traducido

## 🎯 Propósito

Devolverte la fluidez. Llevas años pensando consultas sin pensar en la
sintaxis; esta fase te lleva a ese mismo estado en MQL con el método más
directo: **cada consulta primero en tu idioma, después en el nuevo**, lado a
lado, sobre la base `minijira` que sembraste en la Fase 1.

Y te vacuna contra las dos trampas que muerden a todo veterano SQL la primera
semana: el `null` que no es tu `NULL`, y los tipos que nadie te obliga a
respetar.

> Todo lo de esta fase corre en **mongosh** contra la base sembrada. Nada de
> Node todavía: primero fluidez en el idioma, después el vehículo.

---

## ✅ Qué queda listo al terminar

- traducir de memoria: `WHERE`, `AND/OR/NOT`, `IN`, `BETWEEN`, `LIKE`,
  `IS NULL`, `ORDER BY`, `LIMIT/OFFSET`, `COUNT`, `DISTINCT`, lista de columnas;
- leer y escribir filtros con operadores (`$gt`, `$in`, `$ne`, `$or`,
  `$exists`, `$type`, `$regex`, `$elemMatch`);
- entender el cursor de `find` y por qué "no me devolvió los datos" casi
  siempre significa "no consumiste el cursor";
- las dos trampas dominadas y anotadas en `INSTINTOS.md`;
- la chuleta espejo de consultas impresa al lado del diccionario de la Fase 1.

## 🚫 Qué NO entra todavía

- `UPDATE`/`DELETE` y sus operadores (`$set`, `$inc`, `$push`) — Fase 6, donde
  la atomicidad les da sentido completo
- `GROUP BY` y todo lo agregado — Fase 9 (aguanta: la espera vale la pena)
- `JOIN`/`$lookup` — Fase 5 (y no antes, por diseño del curso)
- rendimiento e índices — Fase 7 (aquí consultamos; allá consultamos rápido)

---

## 🧠 Conceptos mínimos

### MQL en 60 segundos

En SQL escribes **frases** (`SELECT ... WHERE ...`). En MQL escribes
**documentos que describen la consulta**:

```js
db.tickets.find(
  { status: "open", priority: "high" },   // 1.º filtro (el WHERE)
  { title: 1, createdAt: 1 }              // 2.º proyección (la lista del SELECT)
)
```

Tres reglas mentales y ya está:

1. **Filtro = documento.** Cada par `campo: valor` es una condición de
   igualdad. Varias condiciones en el mismo documento = `AND` implícito.
2. **Condición no-igualdad = sub-documento con operador `$`:**
   `{ priority: { $in: ["high", "medium"] } }`.
3. **Proyección = segunda cara del documento:** `1` incluye, `0` excluye.
   No se mezclan (excepto `_id: 0`).

---

### 📖 El espejo: tu SELECT, línea por línea

#### Lo básico

```sql
-- SQL
SELECT * FROM tickets;
SELECT * FROM tickets WHERE status = 'open';
SELECT title, priority FROM tickets WHERE status = 'open';
SELECT * FROM tickets WHERE status = 'open' AND priority = 'high';
```

```js
// MongoDB
db.tickets.find()
db.tickets.find({ status: "open" })
db.tickets.find({ status: "open" }, { title: 1, priority: 1 })
db.tickets.find({ status: "open", priority: "high" })   // AND implícito
```

> 📝 La proyección `{ title: 1, priority: 1 }` **siempre incluye `_id`**
> salvo que lo apagues explícito: `{ title: 1, _id: 0 }`. Manía del motor;
> apréndetela una vez.

#### Comparación y rangos

```sql
SELECT * FROM tickets WHERE created_at >= '2020-01-01';
SELECT * FROM tickets WHERE created_at BETWEEN '2020-01-01' AND '2020-06-30';
SELECT * FROM tickets WHERE priority <> 'low';
```

```js
db.tickets.find({ createdAt: { $gte: ISODate("2020-01-01") } })
db.tickets.find({ createdAt: {
  $gte: ISODate("2020-01-01"),
  $lte: ISODate("2020-06-30")     // BETWEEN = dos operadores en el mismo campo
} })
db.tickets.find({ priority: { $ne: "low" } })   // ⚠️ trampa abajo: $ne y ausentes
```

Arsenal: `$eq $ne $gt $gte $lt $lte`. Se combinan dentro del mismo campo.

#### IN, OR, NOT

```sql
SELECT * FROM tickets WHERE status IN ('open', 'in_progress');
SELECT * FROM tickets WHERE status = 'open' OR priority = 'high';
SELECT * FROM tickets WHERE NOT (status = 'closed');
```

```js
db.tickets.find({ status: { $in: ["open", "in_progress"] } })
db.tickets.find({ $or: [ { status: "open" }, { priority: "high" } ] })
db.tickets.find({ status: { $not: { $eq: "closed" } } })   // o $ne directo
```

> 📝 `$or` vive en la **raíz** del filtro y recibe un array de condiciones.
> El error clásico de la primera semana es escribirlo dentro del campo.
> `$and` explícito solo hace falta cuando necesitas repetir el mismo campo en
> ramas distintas: `{ $and: [ { $or: [...] }, { $or: [...] } ] }`.

#### LIKE

```sql
SELECT * FROM tickets WHERE title LIKE '%impresora%';
SELECT * FROM tickets WHERE title LIKE 'La%';
```

```js
db.tickets.find({ title: { $regex: /impresora/i } })
db.tickets.find({ title: { $regex: /^La/ } })
```

> ⚡ **Adelanto para tu memoria de DBA:** el regex **anclado al inicio**
> (`/^La/`) puede usar índice; el `/impresora/` flotante, no — es tu
> `LIKE '%...%'` de siempre con el mismo full scan de siempre. Los números en
> la Fase 7. 🩻 Este instinto viaja intacto.

#### ORDER BY, LIMIT, OFFSET

```sql
SELECT * FROM tickets ORDER BY created_at DESC;
SELECT * FROM tickets ORDER BY priority ASC, created_at DESC;
SELECT * FROM tickets ORDER BY created_at DESC LIMIT 10 OFFSET 20;
```

```js
db.tickets.find().sort({ createdAt: -1 })
db.tickets.find().sort({ priority: 1, createdAt: -1 })
db.tickets.find().sort({ createdAt: -1 }).skip(20).limit(10)
```

> 📝 `1` asc, `-1` desc. Y sí: `skip` de páginas profundas duele igual que tu
> `OFFSET 100000` — el motor recorre y descarta. Mismo dolor, otro acento.

#### COUNT y DISTINCT

```sql
SELECT COUNT(*) FROM tickets WHERE status = 'open';
SELECT DISTINCT assignee FROM tickets;
```

```js
db.tickets.countDocuments({ status: "open" })
db.tickets.distinct("assignee")
```

> 📝 **Nota legacy honesta:** en código de la época verás `count()` a secas:
> está deprecado desde 4.0 porque miente en algunos escenarios (sharding,
> filtros). `countDocuments()` cuenta de verdad; `estimatedDocumentCount()`
> estima rápido con metadatos. Cuando audites legacy, cada `count()` es un
> candidato a bug sutil.

#### El cursor (o: "¿por qué no me devolvió nada?")

`find()` **no devuelve documentos: devuelve un cursor**. mongosh te malcría
imprimiendo los primeros 20 (y el comando `it` pide más). En Node no habrá
niñera:

```js
// mongosh te deja creer que find() "devuelve datos"
db.tickets.find({ status: "open" })

// La verdad con la que vivirás desde la Fase 10:
const cursor = db.collection("tickets").find({ status: "open" });
const docs = await cursor.toArray();          // o for await...of para streams
```

Piensa en él como el cursor de PL/SQL o T-SQL que siempre evitaste — solo que
aquí es el ciudadano de primera clase y `toArray()` es tu `FETCH ALL`.

---

### 🕳️ Trampa 1: el `null` que no es tu `NULL`

En SQL, toda fila tiene todas las columnas; una columna sin valor es `NULL` y
tienes el álgebra de tres valores tatuada a fuerza de sustos. Aquí hay **tres
estados**, no dos:

```js
{ title: "A", assignee: "soporte1" }   // 1. tiene valor
{ title: "B", assignee: null }         // 2. tiene null explícito
{ title: "C" }                         // 3. el campo NO EXISTE
```

Y la tabla que tienes que memorizar:

| Filtro | Doc 1 (valor) | Doc 2 (`null`) | Doc 3 (ausente) |
|---|---|---|---|
| `{ assignee: null }` | ✗ | ✅ | ✅ **¡también!** |
| `{ assignee: { $exists: false } }` | ✗ | ✗ | ✅ |
| `{ assignee: { $type: "null" } }` | ✗ | ✅ | ✗ |
| `{ assignee: { $ne: null } }` | ✅ | ✗ | ✗ |

> ### 🪞 Tu instinto dice… "`= NULL` no matchea nada; necesito `IS NULL`"
>
> **Predicción falsable:** "`find({ assignee: null })` no va a devolver
> nada, como el `WHERE assignee = NULL` de SQL".
>
> Pruébalo contra la base sembrada. Devuelve de todo: los `null` explícitos
> **y** los documentos donde el campo ni existe. En Mongo la igualdad con
> `null` sí matchea — y matchea de más. **Veredicto: el instinto se equivoca
> en la dirección contraria a la esperada.** Tu reflejo de desconfiar del
> null sigue siendo sano; el mecanismo exacto cambió. 📓 A `INSTINTOS.md`.

Bonus de la misma familia: `$ne: "x"` y `$nin` **también matchean documentos
donde el campo no existe**. "Distinto de x" incluye "no tener el campo". En el
Mini Jira: `find({ assignee: { $ne: "soporte1" } })` te trae los tickets sin
asignar. Si querías "asignados a otra persona", es
`{ assignee: { $ne: "soporte1", $exists: true, $type: "string" } }` — sí, en
serio.

### 🕳️ Trampa 2: los tipos que nadie custodia

```js
db.tickets.insertOne({ title: "Z", priority: 3 })        // ¿priority numérico? claro que sí
db.tickets.find({ priority: "3" })                        // ✗ no lo encuentra
db.tickets.find({ priority: 3 })                          // ✅
```

**No hay coerción en las comparaciones de igualdad.** `"3"` y `3` son valores
distintos de tipos distintos, y el motor no te va a convertir nada. Tu
`WHERE columna_varchar = 3` de Oracle (que convertía y a veces explotaba)
aquí simplemente **no encuentra** — sin error, sin warning, sin filas.

Peor: en `sort` y en rangos, los tipos se ordenan **entre tipos** según un
orden global fijo (null < números < strings < objetos < arrays < fechas < …).
Un `createdAt` que en la mitad de los documentos es `Date` y en la otra mitad
string ISO ordena en dos bloques separados. Por eso la Fase 1 insistió en
convertir fechas: no era manía.

> El antídoto sistémico llega en la Fase 4 (JSON Schema Validation). El
> antídoto de hoy es disciplina + `$type` para auditar:
> `db.tickets.find({ createdAt: { $type: "string" } })` — tu detector de
> fechas contaminadas.

---

### 🌿 Bonus mínimo: arrays (lo justo, la Fase 3 los hará protagonistas)

Los documentos del seed no tienen arrays todavía, pero el idioma los trata con
una naturalidad que a un cerebro SQL le parece brujería:

```js
db.tickets.updateOne({ title: "hola" }, { $set: { tags: ["hardware", "urgente"] } })

db.tickets.find({ tags: "hardware" })
// ✅ matchea si el array CONTIENE "hardware". Sin unnest, sin tabla puente.
```

Guarda esa sensación: es el primer aviso de por qué en la Fase 3 vamos a poder
embeber cosas que en SQL exigían otra tabla. `$all`, `$size` y `$elemMatch`
aparecen en los ejercicios; su hora protagónica llega con multikey en la
Fase 7.

---

### 📡 Del contrato a MQL: ya sabes consultar tu API

No aprendiste operadores en abstracto: cada parámetro del dialecto que el
frontend usa hoy contra json-server es una consulta de esta fase. La tabla
que la Fase 10 va a implementar, ya la sabes escribir:

| El frontend pide (contrato) | Tu MQL de esta fase |
|---|---|
| `GET /tickets?status=open` | `find({ status: "open" })` |
| `GET /tickets?priority=high` | `find({ priority: "high" })` — filtro por campo, mismo patrón que `?status=` |
| `GET /tickets?q=impresora` | `find({ $or: [ { title: /impresora/i }, { description: /impresora/i } ] })` — alcance de `q` firmado en `AUDIT-CONTRATO.md` |
| `GET /tickets?_sort=createdAt&_order=desc` | `.sort({ createdAt: -1 })` |
| `GET /tickets/:id` (404 si no existe) | `findOne({ _id: new ObjectId(id) })` → `null` = tu 404 |
| `GET /users?role=agent` | `find({ role: "agent" })` |
| `GET /comments?ticketId=X&_sort=createdAt` | `find({ ticketId: new ObjectId(X) }).sort({ createdAt: 1 })` — el frontend manda `X` como `id` string-hex; el casteo a `ObjectId` es la frontera que monta la Fase 10 |

> ⚠️ **El `q` de verdad va escapado.** Aquí escribes el regex a mano
> (`/impresora/i`) porque tú controlas el texto. Pero cuando ese `q` viene del
> usuario, un `.`, un `(` o un `*` sueltos lo rompen o cambian su sentido: por
> eso la Fase 10 construye el patrón con `new RegExp(escapeRegex(q), "i")`. Lo
> tocas de refilón en el ejercicio 17 — retenlo, es el mismo problema.

Y el vocabulario cerrado del contrato — `status` ∈ `open · in_progress ·
resolved · closed`, `priority` ∈ `low · medium · high` — es el que usan todos
los ejemplos y ejercicios: si un filtro tuyo usa otro valor, el bug es del
filtro, no de los datos.

---

## 💻 Implementación y código comentado

Esta fase no monta una app todavía: su "implementación" es la **chuleta espejo
condensada** que vas a tener al lado del teclado desde hoy hasta la Fase 10.
Todo corre en **mongosh contra `minijira`** (driver 3.6 cuando toque Node),
sin Express aún.

### 🧩 Chuleta de la fase

```js
// El espejo condensado
find({ a: 1 })                          // WHERE a = 1
find({ a: 1, b: 2 })                    // AND implícito
find({ a: { $gt: 5, $lte: 10 } })       // rangos / BETWEEN
find({ a: { $in: [1, 2] } })            // IN
find({ $or: [{ a: 1 }, { b: 2 }] })     // OR (en la raíz, array)
find({ t: { $regex: /^abc/i } })        // LIKE 'abc%'  (anclado = indexable)
find({}, { a: 1, _id: 0 })              // lista de columnas
.sort({ a: 1, b: -1 }).skip(20).limit(10)
countDocuments({ ... })                 // COUNT(*) honesto
distinct("campo")

// Las trampas
{ a: null }                    // null explícito Y campo ausente
{ a: { $exists: false } }      // solo ausente
{ a: { $ne: "x" } }            // "distinto de x" INCLUYE a los que no tienen a
{ a: { $type: "string" } }     // auditor de tipos

// El cursor
find() devuelve cursor → toArray() / for await
```

---

## ⚠️ Errores comunes y pieza forense

- Escribir `$or` dentro del campo en vez de en la raíz del filtro.
- Olvidar `ISODate(...)` / `new Date(...)` y comparar fechas contra strings
  (a veces "funciona" por el orden lexicográfico del ISO — hasta que no).
- Proyección mezclando `1` y `0` (solo `_id` puede ir a contracorriente).
- Confiar en `count()` heredado en vez de `countDocuments()`.
- Asumir que `$ne` significa "tiene otro valor" (incluye a los ausentes).
- `find({ _id: "5f8a..." })` con el string en vez del ObjectId (reincidencia
  de la Fase 1: aquí es donde más duele).
- Paginar con `skip` gigante y sorprenderse del costo (mismo pecado que
  `OFFSET`, misma penitencia).

---

## 🧪 Ejercicios (32)

Todos sobre la base `minijira` (re-siembra cuando la ensucies:
`npm run seed`). Para los que piden volumen, usa el generador del ejercicio
27 de la Fase 1.

**🟢 Fácil (1–8)**

1. Tickets con `priority: "high"`, solo título y estado, sin `_id`.
2. Tickets creados en 2020 (rango completo del año con `$gte`/`$lt`).
3. Tickets cuyo estado sea `open` **o** `in_progress`, con `$in`. Reescríbelo con `$or`. ¿Cuál prefieres y por qué?
4. Los 5 tickets más recientes, ordenados por `createdAt` descendente. Después, la "página 2": elementos 6–10 del mismo orden.
5. Usuarios que NO son agentes.
6. Todos los valores distintos de `status` presentes en la colección. ¿Coinciden con la máquina de estados documentada (`open/in_progress/resolved/closed`)?
7. Comentarios de un ticket concreto (elige un `_id` real de tu base), ordenados por fecha ascendente. Es exactamente la consulta que el frontend hace hoy vía `GET /comments?ticketId=X&_sort=createdAt`.
8. Tickets cuyo título contenga "impresora" sin importar mayúsculas; y, aparte, tickets cuyo título empiece por "La". Cuenta luego los tickets por hacer: `status: "open"` sin asignar (`assignee: null`). Guarda el número: la trampa 1 te va a hacer dudar de él en el ejercicio 10.

**🟡 Intermedio (9–17)**

9. Inserta 3 documentos de prueba: uno con `assignee: "soporte1"`, uno con `assignee: null` y uno **sin** el campo. Reproduce completa la tabla de la Trampa 1 (los 4 filtros × 3 documentos) y pégala verificada en `INSTINTOS.md`.
10. Con esos documentos aún presentes: ¿tu conteo del ejercicio 8 distinguía "sin asignar explícito" de "campo ausente"? Escribe la versión estricta (solo `null` explícito) y la versión laxa, y decide cuál necesita el negocio del Mini Jira.
11. "Tickets asignados a alguien que no es soporte1" — escríbelo mal (solo `$ne`) y bien (excluyendo ausentes y nulls). Verifica la diferencia con conteos.
12. Tickets de prioridad alta o media creados en el primer trimestre de 2020, no cerrados. (Tres condiciones combinadas; escríbelo primero en SQL como comentario y traduce debajo — este es el formato de tus apuntes a partir de ahora.)
13. Inserta un ticket con `priority: 3` (numérico). Encuentra todos los documentos donde `priority` **no** sea string. Escríbete un auditor general: un filtro por cada campo "sospechoso" (`priority`, `status`, `createdAt`).
14. Contamina un ticket con `createdAt` string (ISO). Ordena por `createdAt` y observa dónde cae. Explica el orden entre tipos con la doc 4.4 en la mano. Repara el documento.
15. `distinct("assignee")` incluye `null`. Obtén la lista de asignados *reales* (pista: `distinct` acepta un filtro como segundo argumento).
16. Tickets sin descripción "útil": campo ausente, `null`, o string vacío. Un solo filtro con `$or`.
17. Usa `$regex` para encontrar títulos que terminen en signo de interrogación. ¿Qué hay que escapar y por qué? (Este escape es exactamente el que la Fase 10 aplica al `q` del contrato.)

**🟠 Difícil (18–25)**

18. En mongosh, guarda un cursor en variable (`var c = db.tickets.find()`), y consúmelo con `c.next()` y `c.hasNext()`. ¿Qué imprime `c` después de agotarlo?
19. Mide con `.explain("executionStats")` (solo mira `totalDocsExamined`, del resto no te enamores todavía) la diferencia entre el regex anclado y el flotante del espejo. Anota los números: son tu "antes" de la Fase 7. Súbele la apuesta: ¿`$in` con 10.000 elementos sigue siendo viable? Genera la lista, mídela contra la base de 100k, encuentra el punto donde el tamaño del `$in` se vuelve el problema, y contrástalo con lo que sabes de `IN` gigantes en tu motor SQL de origen.
20. Escribe la consulta del listado del frontend con la firma exacta del contrato: `listTickets({ status, q, _sort, _order })` — 💸 el prototipo de lo que en la Fase 10 será `service.list(query)`, deuda que se salda allí al montarlo tras Express — filtro opcional por `status`, búsqueda `q` en `title` **o** `description` (regex, case-insensitive, alcance según `AUDIT-CONTRATO.md`), orden dinámico por cualquier campo con `_order: "asc" | "desc"`. Pruébala con las combinaciones que el frontend usa hoy: `{ status: "open" }`, `{ q: "impresora" }`, `{ _sort: "createdAt", _order: "desc" }` y las tres juntas. Acabas de prototipar el corazón de `GET /tickets` de la Fase 10.
21. Con `tags` agregados a algunos tickets (invéntalos): tickets que tengan el tag "hardware"; que tengan **ambos** "hardware" y "urgente" (`$all`); que tengan exactamente 2 tags (`$size`).
22. Inserta un ticket con un array de sub-documentos `checklist: [{ item, done }]`. Busca tickets con algún item no hecho. Ahora busca tickets con un item que **a la vez** se llame "reiniciar" y esté hecho — descubre por qué sin `$elemMatch` obtienes falsos positivos, y documenta la diferencia con un ejemplo mínimo.
23. La paginación del futuro: implementa "página siguiente" **sin `skip`**, usando el patrón range-based (`createdAt` + `_id` como desempate para fechas repetidas). Compárala contra `skip` en la base de 100k del generador: misma página 500 por ambos métodos, cronometrada.
24. Auditoría de nulls a escala: sobre la base de 100k (donde el generador metió `assignee` ausente en algunos), produce el reporte de los 3 estados (valor/null/ausente) con conteos, usando solo lo visto en esta fase (sin aggregation — sufre un poco: es el gancho de la Fase 9).
25. `find({ "user.name": "Ana" })` — notación de punto sobre sub-documentos. Inserta 2 tickets con un sub-documento `meta: { origin, channel }` y consulta por campo anidado. ¿Qué pasa si consultas `{ meta: { origin: "web" } }` (documento completo) versus `{ "meta.origin": "web" }`? Explica la diferencia (igualdad exacta de documento vs campo) — es un clásico de bugs legacy.

**🔴 Muy difícil (26–32)**

26. Reto de traducción inversa: te dan 5 filtros MQL (escríbelos con un compañero o genera 5 tú mismo mezclando `$or`, `$exists`, `$nin`, rangos y regex) y debes producir el SQL equivalente **exacto**, incluyendo el tratamiento de NULL. Documenta el caso donde la traducción perfecta es imposible y por qué.
27. El shell es JavaScript: escribe en mongosh un bucle que ejecute la consulta del ejercicio 20 con 20 combinaciones distintas de parámetros y reporte cuántos documentos devuelve cada una. (Sí, mongosh es un REPL de JS con esteroides; úsalo como herramienta de auditoría.)
28. **El caso del conteo que miente:** sobre la base de 100k, compara `countDocuments({})`, `estimatedDocumentCount()` y el legacy `count()` tras matar el proceso de Mongo a mitad de una carga (`docker kill`, no `stop`) y relevantarlo. Investiga en la doc por qué el estimado puede desviarse y cuándo se corrige. Escribe la regla de "cuál uso cuándo" en tu chuleta.
29. Reconstruye el operador `BETWEEN ... SYMMETRIC` de Postgres (rango que funciona aunque los límites vengan invertidos) como función de mongosh que genere el filtro correcto. Súbele la apuesta: que funcione para fechas y números.
30. Escribe un "linter de filtros" en JS (mongosh o Node): recibe un objeto filtro y reporta advertencias: `$ne`/`$nin` sin `$exists` acompañante, regex no anclado, comparación de `_id` contra string, mezcla de `1` y `0` en proyección. Pruébalo contra los filtros de esta fase.
31. El orden global de tipos completo: construye una colección `zoo` con un documento por cada tipo BSON que puedas producir desde mongosh (null, número, string, objeto, array, Date, ObjectId, booleano, regex). Ordena ascendente y verifica contra la tabla oficial de comparison/sort order de la doc 4.4. ¿Dónde caen los booleanos? ¿Y un array vacío? Documenta las 2 sorpresas más grandes.
32. **Mini-proyecto de cierre:** `scripts/query-audit.js` en Node (driver 3.6): conecta, ejecuta las 10 consultas más representativas de la fase (parametrizadas), imprime resultados formateados en tabla de texto y cierra la conexión limpiamente. Es tu primer programa Node contra Mongo real — y tu plantilla personal para las fases que vienen.

---

## 📚 Referencias

**Documentación oficial (4.4 / driver 3.6)**

- Manual 4.4 — `db.collection.find()`: https://www.mongodb.com/docs/v4.4/reference/method/db.collection.find/
- Manual 4.4 — Query and Projection Operators (el arsenal completo): https://www.mongodb.com/docs/v4.4/reference/operator/query/
- Manual 4.4 — Query for Null or Missing Fields (la Trampa 1, versión oficial): https://www.mongodb.com/docs/v4.4/tutorial/query-for-null-fields/
- Manual 4.4 — Comparison/Sort Order (la Trampa 2, versión oficial): https://www.mongodb.com/docs/v4.4/reference/bson-type-comparison-order/
- Manual 4.4 — Query an Array: https://www.mongodb.com/docs/v4.4/tutorial/query-arrays/
- Manual 4.4 — Iterate a Cursor: https://www.mongodb.com/docs/v4.4/tutorial/iterate-a-cursor/
- Manual 4.4 — `countDocuments`: https://www.mongodb.com/docs/v4.4/reference/method/db.collection.countDocuments/
- Driver 3.6 — Collection API (find, cursores): https://mongodb.github.io/node-mongodb-native/3.6/api/Collection.html

**Libros**

- *MongoDB: The Definitive Guide*, 3.ª ed. — cap. 4 (Querying). El capítulo
  entero es esta fase con otra voz.

**Web / apoyo**

- SQL to MongoDB Mapping Chart (revisítala: ahora la vas a leer distinto): https://www.mongodb.com/docs/v4.4/reference/sql-comparison/
- MongoDB University — M001, unidades de CRUD/query: https://learn.mongodb.com/

**Video (YouTube)**

- MongoDB Crash Course (sección de queries) — Traversy Media: https://www.youtube.com/watch?v=-56x56UppqQ
- MongoDB Tutorial (playlist, capítulos de find/operators) — Net Ninja: https://www.youtube.com/playlist?list=PL4cUxeGkcC9h77dJ-QJlwGlZlTd4ecZOA

**Orden de lectura sugerido para perfil senior:**
Query Operators (hojéala como quien hojea un diccionario) → Null/Missing
Fields → Comparison/Sort Order → ejercicios 12–17 (las trampas, en carne
propia) → el resto de ejercicios → Definitive Guide cap. 4 de postre.

---

## 🚀 Cierre

Al final de esta fase tienes fluidez de consulta: todo tu `SELECT` traducido y
practicado, el cursor entendido, y las dos trampas (`null` de tres estados,
tipos sin custodia) documentadas en `INSTINTOS.md` con experimentos que las
prueban. Además dejaste prototipada, sin saberlo del todo, la consulta que
será el endpoint más importante de la Fase 10.

La señal de que quedó bien:

> "leo un filtro MQL ajeno de corrido, y cuando veo un `$ne` me pregunto
> automáticamente qué pasa con los documentos que no tienen el campo".

**Siguiente parada:** ⚔️ Fase 3 — Embeber vs referenciar: el capítulo que
decide todo. Hasta ahora consultaste un modelo que otro decidió. Ahora te
toca decidir a ti — y tu instinto más querido, la normalización, va a pasar
al banquillo.
