# ⚛️ Fase 6 — Atomicidad del documento, transacciones y consistencia

## 🎯 Propósito

**Cambio de paradigma #4: la transacción existe, pero deja de ser el
pegamento.**

En tu mundo, `BEGIN...COMMIT` era el envoltorio universal: cualquier cambio
que tocara varias filas o tablas viajaba dentro de uno, y el motor te
garantizaba todo-o-nada. En Mongo, la unidad natural de consistencia es
**el documento**: toda escritura a UN documento es atómica siempre, gratis,
sin ceremonia — y si modelaste bien (Fase 3), la mayoría de tus "transacciones"
de antes caben en una sola de estas escrituras. Ese es el premio de haber
embebido con criterio.

Las transacciones multi-documento existen (desde 4.0) y esta fase las enseña
de verdad. Pero llegan al final y con etiqueta de precio, porque en este
paradigma son el plan C: primero rediseña el documento, después usa updates
atómicos con condición, y solo entonces — cuando el negocio de verdad exige
todo-o-nada entre documentos — paga la transacción.

De paso, esta fase **paga la deuda del doble "tomar"** 💸 (la única deuda
canónica de concurrencia del curso, nacida en Track A) y de camino **cierra dos
carreras señaladas** que quedaron con cita a esta fase: la del `$inc` del
contador (Fase 5, ej. 26) y la del bucket (Fase 3, ej. 25).

---

## ✅ Qué queda listo al terminar

- el arsenal de update dominado: `$set`, `$unset`, `$inc`, `$push`, `$pull`,
  `$addToSet`, y la joya `findOneAndUpdate`;
- entender qué significa "el documento es atómico" y cobrar su premio: la
  transición de estado + su entrada de `history` en UNA operación;
- el patrón **update condicional** (read-check-write sin carrera) y con él
  resuelto el doble "tomar" → `409` (extensión pactada en `AUDIT-CONTRATO.md`);
- write concern y read concern: qué prometen `w:1`, `w:"majority"`,
  `journal`, y qué eliges para el Mini Jira;
- el entorno convertido a **replica set de un nodo** (requisito de
  transacciones) sin perder datos;
- transacciones multi-documento: sintaxis, reintentos, costos, y el criterio
  de cuándo NO usarlas;
- las carreras de las fases 3 y 5 cerradas con la técnica que corresponde a
  cada una.

## 🚫 Qué queda fuera por ahora

- el endpoint HTTP que devuelve el 409 (Fase 10 — aquí dejas lista la función
  de datos que lo decide)
- la validación de transiciones de la máquina de estados como regla de
  negocio completa (Fase 11; aquí construyes la **primitiva atómica** que esa
  fase usará)
- réplicas reales de varios nodos, elecciones, failover (fuera de alcance;
  el RS de un nodo es para transacciones, no para alta disponibilidad)
- locks pesimistas y colas de trabajo (se mencionan como contraste, no se
  construyen)

---

## 🧠 La atomicidad del documento en 60 segundos

Toda operación de escritura sobre **un** documento es atómica. Siempre. Sin
pedirlo. Aunque toque veinte campos y tres arrays anidados:

```js
// TODO esto ocurre o no ocurre — nadie ve el estado intermedio:
db.tickets.updateOne(
  { _id: id },
  {
    $set:  { status: "in_progress", updatedAt: new Date() },
    $push: { history: { from: "open", to: "in_progress",
                        by: "soporte1", at: new Date() } },
    $inc:  { touchCount: 1 }
  }
)
```

Aquí está el premio de la Fase 3: elegiste `history` **embebido** justamente
porque "cambia junto" con el ticket — y ahora la transición y su auditoría
son UNA escritura atómica. En `soporte_v1` (ticket en una colección,
historial en otra) esta misma operación son dos escrituras con una carrera
entre ellas. **El modelo decide cuánta atomicidad te sale gratis.**

> ### 🪞 Tu instinto dice… "esto necesita una transacción"
>
> **Predicción falsable:** "cambiar el estado + registrar el historial +
> sellar `updatedAt` son tres cambios: necesito un BEGIN/COMMIT".
>
> Cuenta de nuevo: son tres cambios a **un documento**. La transacción que
> pides ya la tienes, implícita, en cada `updateOne`. Tu instinto no está
> loco — está calibrado para un modelo donde esos tres datos vivían en dos
> tablas. La pregunta correcta en este paradigma no es "¿dónde pongo la
> transacción?" sino "**¿puedo modelar esto para que quepa en un
> documento?**" — y la respuesta la diste en la Fase 3, antes de saber que
> estabas respondiendo esto. **Veredicto: el instinto se equivoca de
> pregunta.** 📓 A `INSTINTOS.md`.

### 🩻 Esto SÍ funciona igual

Todo tu entrenamiento en **concurrencia** viaja intacto: qué es una carrera,
qué es un read-modify-write peligroso, por qué "leer, decidir en la app,
escribir" pierde contra "decidir en el motor", optimistic vs pessimistic
locking, idempotencia de reintentos. Los nombres de las herramientas
cambian; el análisis de intercalados es EXACTAMENTE el mismo músculo.

---

## 🛠️ El arsenal de update (tu UPDATE, con esteroides de documento)

```sql
-- SQL                                   -- MongoDB
UPDATE t SET a = 1 WHERE id = X;         updateOne({_id: X}, { $set: { a: 1 } })
UPDATE t SET n = n + 1 WHERE id = X;     updateOne({_id: X}, { $inc: { n: 1 } })
UPDATE t SET a = NULL ...                updateOne(..., { $set: { a: null } })
--  (quitar la columna: imposible)       updateOne(..., { $unset: { a: "" } })
```

Y los que no tienen espejo porque tu mundo no tenía arrays en la fila:

```js
$push:     { history: {...} }                  // append al array
$push:     { recent: { $each: [x], $slice: -3 } }  // append + poda (subset F3)
$pull:     { tags: "obsoleto" }                // remover por valor/condición
$addToSet: { tags: "hardware" }                // push sin duplicar
"history.0.by"                                  // dot-notation a un índice
$ /  $[]  /  $[elem]                            // el matcheado / todos / filtrados
```

```js
// $[elem] + arrayFilters: actualizar SOLO ciertos elementos del array
db.tickets.updateOne(
  { _id: id },
  { $set: { "checklist.$[item].done": true } },
  { arrayFilters: [ { "item.name": "reiniciar" } ] }
)
```

🔎 **Qué hace:** los operadores de array editan **dentro** del documento sin
reescribirlo tú: el servidor aplica el delta atómicamente. La alternativa
ingenua — leer el documento, modificar el array en JS, `$set` completo — es
un read-modify-write con carrera clásica: dos procesos leyendo a la vez, el
último pisa al primero. Con `$push`/`$inc`/`$pull` **el motor hace la
aritmética**: dos `$inc: 1` concurrentes suman 2, siempre.

> 💥 Y con esto queda cerrada la **carrera del contador** (Fase 5, ej. 26):
> `commentsCount` se incrementa con `$inc`, no con leer-sumar-escribir. La
> reconciliación nocturna queda como red de seguridad, no como mecanismo.

### `findOneAndUpdate`: la navaja de la fase

```js
const result = await col.findOneAndUpdate(
  filtro,                          // puede incluir CONDICIONES (ahora viene lo bueno)
  cambio,
  { returnOriginal: false }        // devuélveme el documento YA modificado
);
// result.value === null  →  ningún documento cumplía el filtro
```

> 📝 **Nota legacy honesta:** en el driver 3.6 la opción se llama
> `returnOriginal: false`; en drivers modernos verás `returnDocument:
> "after"`. Mismo concepto, época distinta — al auditar legacy encontrarás
> la primera.

Lee-y-modifica **en una operación atómica del servidor**: nadie puede colarse
entre tu lectura y tu escritura, porque no hay "entre". Es el equivalente
moral de tu `UPDATE ... RETURNING` — y la base del patrón estrella:

---

## 🥊 El update condicional: el doble "tomar", resuelto

**La deuda heredada 💸:** dos agentes ven el mismo ticket libre en el panel;
ambos pulsan "Tomar"; el frontend manda dos `PATCH /tickets/:id` con
`{ assignee: ... }`; el último gana **en silencio**. El sistema heredado lo
mitigó en el cliente y admitió por escrito que no lo resolvía.

**El instinto SQL** pide `SELECT ... FOR UPDATE` o un campo `version`
(optimistic locking clásico). Pero el contrato manda: el frontend **no envía
versión** y no puedes cambiarle el payload. La restricción te empuja a la
solución más idiomática de Mongo — **la precondición viaja en el filtro**:

```js
// lib/tickets.js — la primitiva que la Fase 10 montará en el PATCH
async function takeTicket(db, ticketId, agentUsername) {
  const result = await db.collection("tickets").findOneAndUpdate(
    {
      _id: new ObjectId(ticketId),
      assignee: null,                   // ⬅️ LA PRECONDICIÓN: solo si está libre…
      status: "open"                    // …y solo desde 'open' (tomar = empezar)
    },
    {
      $set:  { assignee: agentUsername, status: "in_progress",
               updatedAt: new Date() },
      $push: { history: { from: "open", to: "in_progress",
                          by: agentUsername, at: new Date() } }
    },
    { returnOriginal: false }
  );

  if (result.value === null) {
    // Nadie cumplía "libre Y open": o no existe, o ALGUIEN LO TOMÓ PRIMERO,
    // o ya no está en 'open' (resuelto/cerrado/reabierto por otro).
    // La Fase 10 traduce esto a HTTP: 404 o 409 (extensión pactada).
    const exists = await db.collection("tickets")
      .countDocuments({ _id: new ObjectId(ticketId) });
    return { ok: false, reason: exists ? "conflict" : "not_found" };
  }
  return { ok: true, ticket: result.value };
}
```

🔎 **Qué hace:** el filtro es la condición de carrera resuelta — "asígnalo
**solo si sigue libre y abierto**" se evalúa y ejecuta atómicamente en el
servidor. Dos agentes concurrentes: exactamente uno matchea, el otro recibe
`null`.
No hay ventana. No hay lock explícito. No hay campo de versión. El estado
mismo ES la versión.

> ⚠️ **Por qué `status: "open"` va también en el filtro.** "Libre" no basta:
> un ticket puede quedar `assignee: null` y **no** estar en `open` (un
> `releaseTicket` — ej. 14 — que suelta un ticket ya `resolved`, o un reopen a
> medias). Sin esa segunda condición, "tomar" arrastraría un ticket
> resuelto/cerrado de vuelta a `in_progress` y —peor— escribiría en `history`
> un `from: "open"` **mentiroso**. La precondición correcta es el par completo
> del invariante de negocio: *tomar = empezar un ticket que está abierto y sin
> dueño*. Como el `from` es constante `"open"`, el filtro debe garantizar que
> eso sea cierto; si algún día se admite "tomar" desde otros estados, deriva
> `from` del estado real (`from: ticket.status`) en vez de fijarlo. Regla
> general: **cada valor que escribes de forma constante en un `$set`/`$push` es
> una precondición implícita que el filtro tiene que sostener.**

✅ **Buenas prácticas sembradas:** la precondición en el filtro es optimistic
locking sin campo extra (funciona cuando la condición de negocio es
expresable como filtro — "libre", "en estado X"); distinguir `conflict` de
`not_found` cuesta una consulta extra SOLO en el camino del error; y la misma
técnica sirve para las transiciones de la máquina de estados
(`{ _id, status: "open" }` como precondición de pasar a `in_progress`) — la
primitiva que la Fase 11 usará para validar transiciones server-side.

> 💥 Segunda carrera cerrada: el **bucket** (Fase 3, ej. 25). "Push al cubo
> abierto si no está lleno" es un update condicional de manual:
> `findOneAndUpdate({ ticketId, count: { $lt: 100 } }, { $push: ..., $inc:
> { count: 1 } })` — y si devuelve `null`, insertas cubo nuevo (con upsert y
> su propia sutileza: ejercicio 24).

---

## 📡 Write concern y read concern: qué te prometen

Tu `COMMIT` de SQL era binario: confirmó o no. Aquí la confirmación tiene
perillas — cuánta durabilidad exiges a cambio de latencia:

| Perilla | Valor | Promesa |
|---|---|---|
| `w` | `1` (default) | el primario lo aplicó en memoria. Rápido; si el primario muere ANTES de replicar/journalear, se puede perder |
| `w` | `"majority"` | la mayoría del replica set lo tiene. La escritura sobrevive a la muerte del primario |
| `j` | `true` | además, está en el **journal** en disco (no solo en RAM) |
| `readConcern` | `"local"` (default) | lees lo más fresco del nodo, aunque teóricamente pudiera revertirse |
| `readConcern` | `"majority"` | lees solo lo que ya es mayoría — no verás datos que puedan desaparecer |

```js
await col.updateOne(filtro, cambio, { writeConcern: { w: "majority", j: true } });
```

**Para el Mini Jira** (un nodo, sistema interno): los defaults son razonables
y lo importante es **saber que las perillas existen** — el legacy que
heredarás puede tenerlas afinadas (o des-afinadas: un `w: 0` "fire and
forget" de la época era el "no me cuentes si falló"). Regla mental: `w`
responde *¿cuántos lo tienen?*, `j` responde *¿sobrevive un apagón?*,
`readConcern` responde *¿puedo leer algo que luego no pasó?*

---

## 🔄 El replica set de un nodo (peaje de las transacciones)

Las transacciones multi-documento **requieren replica set** — en standalone
no funcionan, ni en 4.4 ni hoy. Para desarrollo, el estándar de la época: RS
de un solo nodo. Ajuste al compose de la Fase 0:

```yaml
# docker-compose.yml — el servicio mongo gana dos cosas:
    command: ["mongod", "--replSet", "rs0"]
```

```js
// Una sola vez, en mongosh:
rs.initiate({ _id: "rs0", members: [{ _id: 0, host: "localhost:27017" }] })
// el prompt cambia a rs0:PRIMARY — ya eres un replica set (de uno)
```

Y la connection string del proyecto gana su parámetro:
`mongodb://localhost:27017/?replicaSet=rs0`. Tus datos sobreviven al cambio
(mismo `MONGO_DATA_PATH`); el ejercicio 15 lo verifica y documenta el
procedimiento en `SETUP.md`.

## 💳 Transacciones multi-documento: el plan C, bien hecho

Cuándo tocan de verdad: **todo-o-nada entre documentos/colecciones que no
puede modelarse de otra forma y cuya tolerancia al drift es cero.** En el
Mini Jira hay un caso legítimo de estudio: la doble escritura del rename
(Fase 5) si el negocio declarara tolerancia cero.

```js
// El rename de la Fase 5, ahora todo-o-nada
const session = client.startSession();
try {
  await session.withTransaction(async function () {
    await db.collection("users").updateOne(
      { username: "soporte1" },
      { $set: { name: "Agente Uno Pérez" } },
      { session }                                    // ⬅️ cada op DEBE llevarla
    );
    await db.collection("tickets").updateMany(
      { assignee: "soporte1" },
      { $set: { assigneeName: "Agente Uno Pérez" } },
      { session }
    );
  }, {
    readConcern:  { level: "majority" },
    writeConcern: { w: "majority" }
  });
} finally {
  await session.endSession();
}
```

🔎 **Qué hace:** `withTransaction` abre la transacción, ejecuta tu callback y
comitea — y **reintenta** automáticamente ante errores transitorios
(`TransientTransactionError`), que en este mundo son esperables, no
excepcionales: las transacciones usan un optimismo interno y pueden abortar
por conflicto con otra escritura. Por eso tu callback debe ser **idempotente
o seguro de reejecutar** — tu vieja disciplina de reintentos, intacta.

**La etiqueta de precio (léela dos veces):**

- ⏱️ límite de vida: **60 segundos** por defecto — la transacción no es un
  contenedor para trabajo lento;
- 📦 tope práctico de tamaño (la época decía: no metas miles de documentos;
  para lo masivo, lotes + reconciliación);
- 🐌 costo real de latencia y conflictos bajo concurrencia (lo mides en el
  ejercicio 28);
- 🧠 y el costo cognitivo: cada transacción es una confesión de que el modelo
  no pudo contener la invariante — a veces es verdad y está bien; a veces es
  la Fase 3 mal hecha.

> 📝 **Nota legacy honesta:** en el código 2018–2021 verás MENOS transacciones
> de las que tu instinto espera (equipos que venían de 3.x donde no existían)
> y, en los equipos que migraron tarde desde SQL, MÁS de las que deberían
> (envolviendo updates de un solo documento "por si acaso" — costo sin
> beneficio). Ambos excesos se auditan con la misma pregunta: *¿qué
> invariante entre QUÉ documentos protege esto?* Si la respuesta es "uno
> solo", sobra; si es "ninguna en particular", sobra dos veces.

---

## 🧩 Chuleta de la fase

```js
// La escalera de la consistencia (de gratis a caro):
// 1. UN documento, UN update           → atomicidad implícita (el premio de F3)
// 2. read-modify-write                 → NO: usa $inc/$push/$pull (delta en el motor)
// 3. leer-decidir-escribir             → NO: findOneAndUpdate con PRECONDICIÓN en el filtro
// 4. invariante entre documentos       → ¿remodelable? → F3. ¿Tolerancia > 0? → reconciliación (F5)
// 5. tolerancia CERO entre documentos  → transacción (RS requerido, withTransaction, precio)

findOneAndUpdate(
  { _id, assignee: null },          // la precondición ES el lock optimista
  { $set: {...}, $push: {...} },    // multi-campo, multi-array: sigue siendo atómico
  { returnOriginal: false }
)  // → value === null: no matcheó → conflicto o inexistente

// Arrays: $push (+$each+$slice) · $pull · $addToSet · $[elem]+arrayFilters
// Durabilidad: w:1 | w:"majority" · j:true · readConcern local|majority
// Transacción: session en CADA operación · callback re-ejecutable · 60 s
```

---

## ⚠️ Errores comunes

- Read-modify-write en la app cuando existía el operador de delta (todo
  `doc.n++; save()` es una carrera con disfraz).
- Verificar-y-luego-escribir en dos operaciones (`findOne` + `updateOne`):
  la ventana entre ambas es exactamente el bug del doble "tomar". La
  precondición va EN el filtro.
- Olvidar pasar `{ session }` a una operación dentro de la transacción: corre
  FUERA de ella, sin error, y el todo-o-nada quedó agujereado. El más
  traicionero de la fase.
- Envolver updates de un documento en transacción "por seguridad": pagas
  precio por una garantía que ya tenías.
- Trabajo lento o llamadas externas (HTTP, disco) dentro de `withTransaction`:
  el límite de 60 s y los conflictos te lo cobran.
- Interpretar `matchedCount: 0` como "no existe" cuando tu filtro llevaba
  precondición: puede existir y no cumplirla — son dos respuestas distintas
  (404 vs 409) y el contrato las distingue.
- Confiar en que `w:1` sobrevive cualquier cosa. Sabe qué compraste.

---

## 🧪 Ejercicios (34)

Concurrencia se prueba con concurrencia: varios ejercicios piden lanzar
operaciones simultáneas con `Promise.all` desde Node. La base: `minijira`.

**🟢 Fácil (1–10)**

1. La transición atómica del capítulo: escribe `transition(db, id, from, to, by)` que cambie status + push a history + updatedAt en un solo `updateOne` **con precondición `status: from`**. Pruébala con una transición válida y una que no matchee.
2. `$inc` vs leer-sumar-escribir: implementa ambas versiones de `commentsCount++` y lánzalas 50 veces concurrentes (`Promise.all`) contra el mismo ticket. Compara el contador final de cada versión con el esperado. La carrera, fotografiada.
3. `$push` con `$each` + `$slice: -3`: implementa el subset de "últimos 3 comentarios" (Fase 3, ej. 32) ahora con el operador correcto. Verifica que el array nunca pasa de 3.
4. `$addToSet` vs `$push` sobre `tags`: agrega "hardware" dos veces con cada uno. Cuenta.
5. `$pull`: elimina de `checklist` todos los items con `done: true`. En SQL era un DELETE sobre la tabla hija: ¿qué es aquí?
6. `arrayFilters`: marca `done: true` SOLO en los items del checklist cuyo nombre empiece por "re" (regex en el arrayFilter). 
7. `findOneAndUpdate` con `returnOriginal: false` vs por defecto: ejecuta la misma operación con ambos y muestra qué documento devuelve cada uno. ¿Cuándo querrías el original? (Piensa en auditoría.)
8. `upsert: true`: incrementa un contador en una colección `stats_daily` con clave `{ day: "2020-03-10" }` que puede no existir. Córrelo dos veces y verifica: primera crea, segunda incrementa.
9. `updateOne` con precondición que no matchea: inspecciona `matchedCount` y `modifiedCount`. Fabrica también el caso `matchedCount: 1, modifiedCount: 0` (¿cómo?) y explica qué significa.
10. Documenta en `DATA-MODEL.md` la sección "Invariantes y atomicidad": qué invariantes del Mini Jira caben en un documento (transición+history) y cuáles cruzan documentos (rename+copias, comment+contador).

**🟡 Intermedio (11–20)**

11. Implementa `takeTicket` completa (la del capítulo, con la distinción conflict/not_found y la precondición `assignee: null, status: "open"`) y verifícala secuencialmente: tomar libre-y-abierto → ok; tomar tomado → conflict; tomar un ticket libre pero `resolved` → conflict (¡no debe volver a `in_progress`!); id inexistente → not_found.
12. **El duelo:** lanza 2 `takeTicket` concurrentes de agentes distintos sobre el mismo ticket libre, 100 rondas (re-liberando entre rondas). Cuenta: ¿exactamente un ganador por ronda, siempre? Aserción automática, no ojo.
13. La versión ROTA a propósito: implementa `takeTicketNaive` (findOne para verificar libre + updateOne para asignar) y repite el duelo. ¿Cuántas rondas terminaron con doble asignación silenciosa? Acabas de reproducir el bug heredado en laboratorio.
14. `releaseTicket(id, agent)`: soltar el ticket SOLO si eres tú quien lo tiene (precondición `assignee: agent`). ¿Qué devuelve cuando otro lo tiene? ¿Y la variante del admin que libera cualquiera?
15. Convierte tu entorno a RS de un nodo siguiendo el capítulo. Verifica que los datos sobrevivieron, que el prompt dice PRIMARY, y que la connection string del proyecto funciona. Documenta el runbook en `SETUP.md` (incluido cómo volver atrás).
16. Primera transacción: el rename todo-o-nada del capítulo, corriendo. Verifica el resultado en ambas colecciones.
17. Sabotea la transacción: lanza un `throw` entre las dos escrituras del callback. Verifica que NINGUNA quedó aplicada. Repite con el `throw` DESPUÉS de `withTransaction`: ¿qué quedó?
18. El agujero del `{ session }`: quita la session de la segunda escritura, repite el sabotaje del 17. Fotografía el desastre: primera revertida, segunda aplicada. Es EL bug de transacciones de la época — reconócelo para siempre.
19. Transición de la máquina de estados con precondición: usa tu `transition()` del ej. 1 para implementar las reglas reales del contrato (`open→in_progress→resolved→closed` + reopen). Prueba una transición ilegal (`closed→resolved`): debe fallar por filtro, no por if en la app. (La política completa — QUÉ transiciones permite QUIÉN — es de la Fase 11; la primitiva es tuya desde hoy.)
20. Write concern en vivo: la misma escritura con `w:1` vs `{w:"majority", j:true}` — en tu RS de un nodo, ¿cambia la latencia? Mide 1.000 escrituras de cada una y explica por qué el resultado da lo que da (pista: ¿cuántos nodos hay que esperar?).

**🟠 Difícil (21–28)**

21. El bucket, cerrado: implementa `recordEvent` versión final — `findOneAndUpdate({ ticketId, count: { $lt: 100 } }, { $push + $inc })`; si `null`, crea el cubo nuevo. Lanza 500 eventos concurrentes y verifica: ningún cubo con más de 100, ningún evento perdido (suma total = 500).
22. La sutileza del cubo nuevo: en tu solución del 21, dos procesos concurrentes pueden decidir "crear cubo" a la vez. ¿Qué pasa? Provoca la condición (muchos procesos justo al llenarse un cubo), observa (¿cubos duplicados con pocos eventos? ¿está mal?), y decide: ¿es un bug o una tolerancia aceptable del patrón? Defiende por escrito.
23. Idempotencia de reintentos: haz que `takeTicket` sea segura si el driver reintenta (red parpadea, la operación llegó pero la respuesta se perdió, el driver reenvía). ¿El update condicional ya es naturalmente idempotente para este caso? Analiza campo por campo (el `$push` a history, ¿duplicaría entrada?) y corrige si hace falta (pista: un `transitionId` único en la entrada + precondición).
24. Upsert con carrera: implementa el contador diario del ej. 8 lanzando 200 incrementos concurrentes del MISMO día nuevo. ¿Apareció `E11000 duplicate key` en algunos? Investiga por qué el upsert puede colisionar al crear, cómo lo mitiga un índice único + retry, e impleméntalo.
25. `findOneAndUpdate` como cola de trabajo (el patrón job-queue de la época): colección `jobs` con `{ status: "pending" }`; N workers concurrentes que reclaman con `findOneAndUpdate({ status: "pending" }, { $set: { status: "taken", by: worker } }, { sort: { createdAt: 1 } })`. Lanza 5 workers sobre 100 jobs y verifica: cada job procesado exactamente una vez. (Acabas de escribir el corazón de miles de sistemas 2019.)
26. Transacción con conflicto real: dos transacciones concurrentes que tocan el mismo documento en orden cruzado. Provoca el `TransientTransactionError`, obsérvalo en los logs, y comprueba que `withTransaction` reintentó solo. Ahora inserta un contador de intentos en el callback: ¿cuántas veces corrió?
27. La transacción prohibida: mete un `setTimeout` de 70 segundos dentro del callback. Documenta el error exacto del límite de vida. Ahora la versión realista: una llamada HTTP lenta simulada dentro de la transacción — escribe en `INSTINTOS.md` la regla que este experimento graba a fuego.
28. Mide el precio: el rename con transacción (ej. 16) vs sin transacción (dos escrituras + reconciliación de la Fase 5), bajo carga concurrente (20 renames simultáneos de agentes distintos + 200 lecturas). Latencias p50/p95 de ambos. La tabla que justifica "el plan C": números tuyos.

**🔴 Muy difícil (29–34)**

29. **La deuda cobrada de punta a punta:** monta un mini-servidor HTTP provisional (30 líneas de Node `http`, sin Express — la Fase 10 hará el real) que exponga solo `PATCH /tickets/:id/take` usando `takeTicket`, y un script "dos navegadores" que dispare tomas concurrentes vía HTTP. Verifica el 409 en el perdedor. Es el ensayo general del pago oficial en la Fase 10/11.
30. Outbox transaccional: mejora el patrón outbox del 🔥 opcional de la Fase 5 — la escritura de negocio y el insert a `_outbox` ahora viajan en la MISMA transacción (esa es la gracia del patrón completo: el evento existe si y solo si el cambio existe). Worker aparte procesa con at-least-once. Demuestra con sabotajes que no hay evento huérfano ni cambio sin evento.
31. Saga en miniatura (el contraste arquitectónico): implementa el rename como saga — paso 1 (users) + paso 2 (tickets) con **compensación** (revertir users si tickets falla definitivamente). Compárala con la transacción del ej. 16 en: complejidad de código, qué ve un lector concurrente a mitad de camino, y qué pasa si la compensación TAMBIÉN falla. Media página honesta: cuándo la saga es sobreingeniería y cuándo es la única opción (pista: sharding, servicios separados).
32. Auditoría de un legacy real: busca en GitHub un proyecto Node+Mongo de la época con updates. Caza: read-modify-writes con carrera, findOne+update separables, transacciones de un solo documento, `w:0`. Reporte de 1 página con veredicto por hallazgo (bug real / riesgo teórico / correcto). Es la promesa del curso aplicada a concurrencia.
33. El torture-test del Mini Jira: script que durante 60 segundos lance mezcla concurrente realista (tomas, transiciones, comentarios con `$inc`, renames) y al final ejecute TODAS las verificaciones de invariantes (un solo assignee coherente con history, contadores exactos, copias sincronizadas o drift ≤ tolerancia). Déjalo como `npm run torture` — la Fase 13 lo convertirá en test de verdad.
34. **El ensayo de la fase** (1 página, `INSTINTOS.md`): "La transacción era el pegamento porque el modelo estaba en pedazos". Tesis a desarrollar: la normalización fragmenta la unidad de negocio en filas y tablas, y la transacción es el mecanismo que las vuelve a juntar en cada escritura; el documento invierte el orden — junta primero (modelado), pega después solo lo que quedó fuera. Usa el duelo (ej. 12–13), el precio medido (ej. 28) y tu experiencia SQL como evidencia. Cierra con tu escalera personal de consistencia (la de la chuleta, con tus palabras y tus números).

**🔥 Opcionales (exceden el alcance base)**

- 🔥 El corazón de mil sistemas 2019: convierte el `findOneAndUpdate` job-queue del ej. 25 en un worker con reintento, backoff y "visibility timeout" (un job `taken` que nadie completa en N segundos vuelve a `pending`). Es la cola de trabajo casera de la época, con sus dos bugs clásicos incluidos.
- 🔥 La saga del ej. 31 llevada a dos procesos Node separados que se hablan por una colección `_outbox`: mide qué ve un lector concurrente a mitad de camino y compáralo con lo que vería dentro de la transacción del ej. 16. La comparación es el argumento arquitectónico completo.
- 🔥 Reescribe la chuleta de la escalera de consistencia como diagrama de decisión (un `.md` con un árbol): entrada "necesito que X sea consistente", hojas "un documento / precondición en filtro / reconciliación / transacción". Es tu resumen de la fase en una imagen.

---

## 📚 Referencias

**Documentación oficial (4.4 / driver 3.6)**

- Atomicity and Transactions (la página que ordena todo): https://www.mongodb.com/docs/v4.4/core/write-operations-atomicity/
- Update Operators (el arsenal completo): https://www.mongodb.com/docs/v4.4/reference/operator/update/
- `findOneAndUpdate`: https://www.mongodb.com/docs/v4.4/reference/method/db.collection.findOneAndUpdate/
- `arrayFilters` (Update with filtered positional): https://www.mongodb.com/docs/v4.4/reference/operator/update/positional-filtered/
- Transactions (requisitos, límites, sintaxis): https://www.mongodb.com/docs/v4.4/core/transactions/
- Transactions — Production Considerations (la etiqueta de precio oficial): https://www.mongodb.com/docs/v4.4/core/transactions-production-consideration/
- Write Concern: https://www.mongodb.com/docs/v4.4/reference/write-concern/
- Read Concern: https://www.mongodb.com/docs/v4.4/reference/read-concern/
- Driver 3.6 — Transactions / sessions: https://mongodb.github.io/node-mongodb-native/3.6/api/ClientSession.html
- Deploy a Replica Set (para el RS de 1 nodo basta la parte de `rs.initiate`): https://www.mongodb.com/docs/v4.4/tutorial/deploy-replica-set/

**Libros**

- *MongoDB: The Definitive Guide*, 3.ª ed. — caps. de updates y el cap. de
  transacciones (escrito exactamente para la 4.x: transacciones recién
  llegadas y con juicio).

**Web / apoyo**

- Building with Patterns: The Bucket Pattern (relectura, ahora con la carrera resuelta): https://www.mongodb.com/blog/post/building-with-patterns-the-bucket-pattern
- How To SELECT ... FOR UPDATE inside MongoDB Transactions (findAndModify como lock — artículo clásico del blog de MongoDB, escrito para 4.0): https://www.mongodb.com/blog/post/how-to-select-for-update-inside-mongodb-transactions

**Video (YouTube)**

- MongoDB Transactions (MongoDB oficial, 2018–2019 — los talks del lanzamiento de 4.0 explican el "plan C" mejor que nadie, porque tuvieron que justificarlo). Sin permalink versionado estable: búscalo en el canal oficial de MongoDB filtrando por 2018–2019.
- Are Transactions Right For You? — MongoDB World (busca el título en el canal oficial; es la Fase 6 en formato charla). Sin permalink estable a una versión concreta.

**Orden de lectura sugerido para perfil senior:**
Write Operations Atomicity (corta y central) → Update Operators (hojear como
diccionario) → ejercicios 11–13 (el duelo ANTES de leer más: la fase se
entiende ganándolo) → Transactions + Production Considerations → ejercicios
de transacciones → Write/Read Concern al final (es la parte que menos usarás
y más impresiona en entrevistas).

---

## 🚀 Cierre

Al final de esta fase tienes la escalera de consistencia completa y tres
victorias con nombre: el doble "tomar" resuelto con precondición en el filtro
(sin tocar el contrato — el 409 espera su endpoint en la Fase 10), el contador
del `$inc` sin carrera con la reconciliación degradada a red de seguridad, y
el bucket cerrando eventos concurrentes sin perder ninguno. Las transacciones
quedaron donde pertenecen: disponibles, entendidas, medidas — y al final de
la escalera, no al principio.

La señal de que quedó bien:

> "ante cualquier 'necesito que esto sea consistente', mi primera pregunta ya
> no es dónde va el BEGIN: es si cabe en un documento, luego si cabe en un
> filtro, y solo al final cuánto cuesta el pegamento".

**Siguiente parada:** ⚡ Fase 7 — Índices: donde tu experiencia SQL vale
intacta. Cuatro fases cuestionándote certezas; toca la fase reconfortante.
Tu `EXPLAIN PLAN`, tus compuestos, tu prefijo izquierdo — casi todo viaja. Y
el villano recibirá sus índices… para demostrar que ni así se salva.
