# 🔗 Fase 5 — `$lookup` y por qué es una alarma

## 🎯 Propósito

**Cambio de paradigma #3: el JOIN ya no es gratis ni es el plan A.**

Sí: Mongo tiene JOIN. Se llama `$lookup`, existe desde 3.2, y esta fase te lo
enseña completo — porque el legacy que heredarás está lleno de él y porque a
veces es exactamente la herramienta correcta. Pero el corazón de la fase es
la **regla de lectura** que separa a quien diseñó de quien tradujo:

> `$lookup` en el reporte nocturno es una herramienta.
> `$lookup` en el endpoint caliente es un **síntoma**: alguien modeló para
> normalizar y está pagando el JOIN sin el motor que lo hacía barato.

Y como la alternativa al `$lookup` caliente es denormalizar, la segunda mitad
de la fase paga esa cuenta con honestidad: **cómo se mantienen sincronizadas
las copias, y qué haces cuando (no "si") se desincronizan**.

---

## ✅ Qué queda listo al terminar

- `$lookup` dominado: sintaxis básica, con pipeline, y sus límites reales
  (qué no tiene: optimizador de orden de joins, hash join, estadísticas);
- las tres formas de "unir" comparadas y **medidas**: N+1, batch con `$in`,
  `$lookup` — sabes cuál usar cuándo;
- la regla del reporte nocturno vs endpoint caliente, con tus números;
- denormalización deliberada con su protocolo: quién escribe las copias,
  cómo se detecta el drift, cómo se reconcilia;
- segunda visita al anti-patrón ⚰️: el dashboard de `soporte_v1` con
  `$lookup`, cronómetro en mano, números a la tabla de la autopsia;
- `DATA-MODEL.md` con la sección "Uniones y copias: decisiones".

## 🚫 Qué NO entra todavía

- el aggregation pipeline completo (`$group`, `$facet`, ventanas…) — Fase 9;
  aquí tomas prestadas 4 etapas, las justas para unir
- índices para acelerar el lado derecho del `$lookup` — Fase 7 (y la
  Fase 8 mostrará que ni con eso se salva el modelo traducido)
- la atomicidad de la doble escritura al denormalizar — la carrera se nombra
  aquí, se resuelve en la Fase 6
- transacciones para "escribir las dos copias juntas" — Fase 6, con juicio

---

## 🧠 Lo prestado de aggregation (60 segundos, lo justo para unir)

`$lookup` vive dentro de `aggregate()`, que procesa documentos por **etapas
encadenadas** (un pipeline: cada etapa recibe lo que la anterior emite). Hoy
usas cuatro etapas y no preguntas más — la Fase 9 te da el arsenal:

```js
db.tickets.aggregate([
  { $match: { status: "open" } },      // 1. filtra (tu WHERE — va PRIMERO)
  { $lookup: { ... } },                // 2. une (el invitado de honor)
  { $unwind: "$someArray" },            // 3. desanida un array (opcional)
  { $project: { title: 1, x: 1 } }     // 4. proyecta (tu SELECT)
])
```

> ⚡ Regla robada a tu instinto de DBA (🩻 viaja intacto): **filtra antes de
> unir**. `$match` primero reduce lo que `$lookup` debe procesar — el mismo
> "predicado antes del join" que llevas años aplicando.

---

## 📖 `$lookup`: el espejo con tu LEFT JOIN

### Forma básica (igualdad de campos)

```sql
-- SQL: los comentarios de cada ticket abierto
SELECT t.title, c.body, c.author
FROM tickets t
LEFT JOIN comments c ON c.ticket_id = t.id
WHERE t.status = 'open';
```

```js
db.tickets.aggregate([
  { $match: { status: "open" } },
  { $lookup: {
      from: "comments",            // colección derecha
      localField: "_id",           // campo aquí
      foreignField: "ticketId",    // campo allá
      as: "comments"               // ⬅️ y AQUÍ la primera diferencia grande
  } }
])
```

Tres diferencias que tu cerebro SQL debe registrar antes de seguir:

1. **El resultado no es plano.** No hay filas repetidas de ticket×comentario:
   cada ticket sale UNA vez con un **array** `comments` adentro. Es un LEFT
   JOIN que agrupa solo (si quieres el plano de SQL, `$unwind` lo despliega —
   y entonces sí, filas repetidas).
2. **Siempre es LEFT.** Sin match, array vacío `[]` — nunca desaparece el
   documento izquierdo. El INNER se simula filtrando después:
   `{ $match: { comments: { $ne: [] } } }`.
3. **No hay simetría.** En SQL, `A JOIN B` y `B JOIN A` son el mismo plan
   para el optimizador. Aquí no hay optimizador de orden: el pipeline corre
   como TÚ lo escribiste, colección izquierda manda. Elegir el lado es tu
   trabajo ahora.

### Forma con pipeline (condiciones ricas, sub-filtros)

```js
// Los tickets con SOLO sus comentarios recientes (condición extra en la unión)
db.tickets.aggregate([
  { $match: { status: "open" } },
  { $lookup: {
      from: "comments",
      let: { tid: "$_id" },                       // variables del lado izquierdo
      pipeline: [
        { $match: { $expr: { $eq: ["$ticketId", "$$tid"] } } },
        { $match: { createdAt: { $gte: new Date("2020-06-01") } } },
        { $sort: { createdAt: -1 } },
        { $limit: 3 }
      ],
      as: "recentComments"
  } }
])
```

🔎 **Qué hace:** la forma pipeline (3.6+) permite lo que en SQL era el `ON`
con condiciones múltiples o el `LATERAL`: sub-consulta por cada documento
izquierdo, con `$$tid` como correlación. Potente — y proporcionalmente
peligrosa: ese pipeline interno corre **una vez por documento de la
izquierda**.

### Lo que `$lookup` NO tiene (y tu instinto asume que sí)

> ### 🪞 Tu instinto dice… "el motor optimizará el join"
>
> **Predicción falsable:** "como en SQL, da igual cómo escriba la unión: el
> optimizador elegirá orden, algoritmo (hash/merge/nested-loop) y usará
> estadísticas".
>
> Mídelo (ejercicios 19–22). Lo que hay detrás de `$lookup` es en esencia un
> **nested-loop**: por cada doc izquierdo, una búsqueda en la colección
> derecha. Sin hash join, sin reordenamiento de joins, sin estadísticas de
> cardinalidad. La única gran ayuda posible: que la búsqueda derecha pegue en
> un **índice** (`foreignField` indexado — Fase 7). Consecuencias prácticas:
> izquierda chica × derecha indexada = viable; izquierda grande = dolor
> lineal; cadena de 4 lookups = 4 nested-loops anidados que NADIE va a
> reordenar por ti. **Veredicto: el instinto se equivoca — el plan del join
> ahora lo escribes tú.** 📓 A `INSTINTOS.md`.

### 🩻 Esto SÍ funciona igual

Tu paranoia N+1 no solo sobrevive: **asciende**. Las tres formas de unir que
vas a medir son las mismas tres de tu vida anterior — el ORM que dispara una
query por fila (N+1), el `WHERE id IN (...)` cacheado en memoria (batch), y
el JOIN del motor. Cambian los nombres; el análisis es idéntico. Y "filtra
antes de unir" + "el lado indexado es el barato" son tus reflejos de siempre.

---

## ⚖️ Las tres formas de unir, medidas

El laboratorio central de la fase. Sobre `minijira` inflada a 100k
(generador de la Fase 1) — el detalle: 20 tickets con su autor legible.

```js
// FORMA 1 — N+1 (el pecado): una consulta por ticket
const tickets = await db.collection("tickets")
  .find({ status: "open" }).limit(20).toArray();
for (const t of tickets) {
  t.reporterInfo = await db.collection("users")
    .findOne({ username: t.reporter });          // 20 viajes 😬
}

// FORMA 2 — batch con $in (el clásico honesto de la época)
const usernames = [...new Set(tickets.map(t => t.reporter))];
const users = await db.collection("users")
  .find({ username: { $in: usernames } }).toArray();
const byName = new Map(users.map(u => [u.username, u]));
tickets.forEach(t => { t.reporterInfo = byName.get(t.reporter); });
// 2 viajes, join en memoria de la app

// FORMA 3 — $lookup (el join del motor)
const result = await db.collection("tickets").aggregate([
  { $match: { status: "open" } }, { $limit: 20 },
  { $lookup: { from: "users", localField: "reporter",
               foreignField: "username", as: "reporterInfo" } }
]).toArray();
// 1 viaje, join en el server
```

Los ejercicios 19–22 cronometran las tres a varias escalas. El patrón que
vas a encontrar (y que debes comprobar, no creer): N+1 pierde siempre en
cuanto hay red de por medio; batch y `$lookup` compiten — batch gana
flexibilidad (cachear usuarios entre requests) y reparte carga hacia la app;
`$lookup` gana en viajes y pierde cuanto más grande la izquierda y más fría
la derecha. **Y las tres pierden contra el campo que ya estaba en el
documento** — que es el punto de la Fase 3 y la razón de la sección
siguiente.

> 📝 **Nota legacy honesta:** en el código 2018–2021 que heredarás, la forma
> dominante es la 2 (batch `$in`), porque `$lookup` era joven y desconfiado.
> No lo leas como ignorancia: muchas veces era la decisión correcta. Audita
> antes de "modernizar" un batch a `$lookup` — puede ser un downgrade.

---

## 🎯 La regla: nocturno vs caliente

| Contexto | `$lookup` es… | Por qué |
|---|---|---|
| Reporte nocturno, export, migración, backoffice esporádico | ✅ legítimo | corre pocas veces, nadie espera con la pantalla abierta, y evita denormalizar solo para un reporte |
| Aggregation analítica (Fase 9) que cruza colecciones | ✅ legítimo | es su hábitat: el pipeline analítico |
| Endpoint caliente (el listado, el detalle, lo que la UI pide en cada render) | 🚨 síntoma | si cada lectura caliente necesita unir, el modelo no siguió "lo que se lee junto se guarda junto" — estás pagando JOIN de SQL sin el motor de SQL |
| Cadena de 3+ lookups en cualquier lado | 🚨🚨 síntoma agravado | nested-loops anidados sin optimizador: el olor inconfundible del modelo traducido |

**En el Mini Jira:** el detalle y el listado NO necesitan `$lookup` — la
Fase 3 pagó por adelantado (username en el ticket = referencia extendida).
El futuro `GET /stats` (Fase 9) podrá usarlo sin culpa: es agregación, no
render. Esa asimetría **es** la regla, encarnada en tu proyecto.

## ⚰️ Segunda visita al anti-patrón: el dashboard con cronómetro

`soporte_v1` no puede renderizar NADA sin unir: todo valor humano vive tras
un id. El laboratorio:

```js
// El listado del dashboard en soporte_v1: 20 tickets "legibles"
db.tickets.aggregate([
  { $sort: { createdAt: -1 } }, { $limit: 20 },
  { $lookup: { from: "statuses",   localField: "statusId",   foreignField: "_id", as: "status" } },
  { $lookup: { from: "priorities", localField: "priorityId", foreignField: "_id", as: "priority" } },
  { $lookup: { from: "users",      localField: "assigneeId", foreignField: "_id", as: "assignee" } },
  { $lookup: { from: "users",      localField: "reporterId", foreignField: "_id", as: "reporter" } },
  { $unwind: { path: "$status", preserveNullAndEmptyArrays: true } },
  { $unwind: { path: "$priority", preserveNullAndEmptyArrays: true } },
  { $unwind: { path: "$assignee", preserveNullAndEmptyArrays: true } },
  { $unwind: { path: "$reporter", preserveNullAndEmptyArrays: true } }
])
```

Cuatro nested-loops para pintar una tabla que `minijira` sirve con
`find().sort().limit()` — **cero uniones**, porque el documento ya se parece
a la fila que la UI pinta. Los ejercicios 23–25 lo cronometran (dashboard,
detalle, y la búsqueda `?q=` que en `soporte_v1` ni siquiera puede unirse
decentemente porque el texto está en una colección y los filtros en otra).
Números a la tabla "autopsia (antes)" de `DATA-MODEL.md` — la que la
**autopsia de la Fase 8** leerá para dictar el veredicto.

> 🎯 La lección la sella la Fase 8; el intento intermedio es la Fase 7,
> donde indexarás los `foreignField` de este horror y mejorará… algo. Pero
> seguirá siendo 4 uniones por render contra 0. **El índice acelera el plan;
> no arregla el modelo.**

---

## 📋 Denormalizar como adulto: el protocolo de las copias

> 💸 **Pago de deuda (viene de la Fase 3).** Allí guardaste `assigneeName`
> (referencia extendida) y `commentsCount` (computed) como copias sin
> protocolo: sabías copiar, pero no cómo mantenerlas sanas. La deuda era
> exactamente esa —la sincronización pendiente—. Aquí se paga: la copia deja
> de ser un campo suelto y pasa a tener dueño, reconciliación y tolerancia.

Elegiste copiar (referencia extendida, computed, subset — Fase 3). La copia
se va a desincronizar: un update parcial fallido, un script ajeno, un bug.
El protocolo de la época, cuatro piezas:

**1. Un solo escritor.** Cada dato copiado tiene UN camino de escritura (el
service de la Fase 10). Si tres módulos actualizan `assigneeName`, ya
perdiste. Documenta el dueño en `DATA-MODEL.md`.

**2. La doble escritura, nombrada.** Renombrar al agente = actualizar
`users` + N tickets. Dos operaciones, no atómicas entre sí:

```js
await db.collection("users").updateOne(
  { username: "soporte1" }, { $set: { name: "Agente Uno Pérez" } });
// ⚡ si el proceso muere AQUÍ: users nuevo, tickets viejos — drift nacido
await db.collection("tickets").updateMany(
  { assignee: "soporte1" }, { $set: { assigneeName: "Agente Uno Pérez" } });
```

La carrera queda **señalada con nombre y apellido**; la Fase 6 da las
respuestas (orden de escrituras que degrada bonito, transacción cuando
amerite) — hoy la respuesta es la pieza 3.

**3. Reconciliación programada.** El batch nocturno que compara fuente
contra copias y repara reportando:

```js
// scripts/reconcile-assignee-names.js — el fsck de tus copias
// por cada user: countDocuments({assignee: u.username, assigneeName: {$ne: u.name}})
// si > 0: updateMany + log. Idempotente, medible, aburrido. Perfecto.
```

Tu viejo amigo el job nocturno de integridad, con otro nombre. 🩻 Intacto.

**4. Tolerancia declarada.** ¿Cuánto drift aguanta el negocio? Un
`assigneeName` viejo por 24 h en la lista de tickets: nadie muere. Un saldo
copiado: cero tolerancia (y probablemente no debiste copiarlo — o es la
Fase 6 con transacción). Escribe el número; sin número no hay decisión.

---

## 🧩 Chuleta de la fase

```js
// $lookup básico: LEFT JOIN que agrupa en array
{ $lookup: { from, localField, foreignField, as } }
// INNER simulado:  + { $match: { as: { $ne: [] } } }
// aplanar a filas: + { $unwind: { path: "$as", preserveNullAndEmptyArrays: true } }

// $lookup pipeline: el ON complejo / LATERAL
{ $lookup: { from, let: { v: "$campo" },
             pipeline: [ { $match: { $expr: { $eq: ["$x", "$$v"] } } }, ... ],
             as } }

// Las 3 uniones: N+1 (nunca) · batch $in (flexible, cachea) · $lookup (1 viaje)
// Regla: $match antes de $lookup · izquierda chica · derecha indexada (F7)

// La regla de oro:
//   nocturno/analítico → herramienta ✅
//   endpoint caliente  → síntoma 🚨 (el modelo no pagó la Fase 3)

// Denormalización adulta: 1 escritor · carrera nombrada (F6) ·
//   reconciliación nocturna · tolerancia con número
```

---

## ⚠️ Errores comunes

- `$lookup` sin `$match` previo: unir todo para filtrar después (el pecado
  que tu instinto SQL jamás cometería con un WHERE — no lo cometas aquí).
- Esperar filas planas y recibir arrays (olvidar que agrupa; o al revés:
  `$unwind` sin `preserveNullAndEmptyArrays` y perder los tickets sin
  comentarios — el LEFT que se volvió INNER sin avisar).
- Encadenar lookups porque "así era el query SQL" en vez de preguntar si el
  modelo debió embeber (la cadena es el síntoma, no la solución).
- "Modernizar" un batch `$in` sano a `$lookup` sin medir.
- Denormalizar sin protocolo: copias con 3 escritores, sin reconciliación,
  sin tolerancia declarada.
- Reconciliar con el cañón: recorrer TODO cada noche cuando un filtro de
  `updatedAt` (¡Fase 4 pagando dividendos!) acota lo tocado desde ayer.
- Olvidar que el pipeline interno del `$lookup` con `let` corre por CADA doc
  izquierdo: un `$sort` caro ahí dentro se multiplica.

---

## 🧪 Ejercicios (33)

Base: `minijira` a 100k tickets / 400k comments (generador), `soporte_v1`
sembrada (Fase 3). Cronometra con `console.time` o el shell.

**🟢 Fácil (1–8)**

1. Tickets abiertos con sus comentarios embebidos en `comments` (lookup básico). Verifica que un ticket sin comentarios sale con `[]`.
2. El mismo, pero solo `title` y el `body` de cada comentario (`$project` — arrays anidados incluidos: investiga la sintaxis `"comments.body": 1`).
3. Convierte el resultado en filas planas ticket–comentario con `$unwind`. Cuenta filas antes y después: explica la diferencia con el LEFT JOIN de SQL.
4. Simula el INNER: solo tickets CON comentarios. Hazlo de las dos formas (filtrar el array vacío / `$unwind` sin preserve) y compara conteos.
5. Une tickets→users por `reporter`→`username` para el listado de 20. ¿El resultado trae a `reporterInfo` como array de 1? Aplánalo.
6. Los comentarios con los datos de SU ticket (invierte los lados: `comments` a la izquierda). ¿Qué cambia en tamaño del resultado y en tiempo? Primera intuición de "la izquierda manda".
7. Lookup pipeline: tickets con solo sus 3 comentarios más recientes (el ejemplo del capítulo, corriendo en tu base).
8. En `soporte_v1`: resuelve el nombre de la prioridad de 20 tickets con un lookup a la lookup-table `priorities`. Siente lo que es unir para leer un enum. Anota el fastidio (es dato, Fase 3 dixit).

**🟡 Intermedio (9–18)**

9. Escribe el SQL exacto equivalente al ejercicio 5 como comentario del script (el formato espejo ya es tuyo), y explica en dos líneas por qué el `$lookup` agrupa donde el `LEFT JOIN` aplana.
10. Registra en `DATA-MODEL.md` la sección "Uniones y copias": qué endpoints del contrato usan qué forma (spoiler tras revisar: los calientes, ninguna — documenta POR QUÉ).
11. `$lookup` con condición doble vía pipeline: comentarios del ticket **y** posteriores a la fecha del ticket (`$$` con dos variables en `let`). En SQL era un `ON` con AND — escríbelo como espejo.
12. El detalle completo del ticket en `minijira` con UNA aggregation: ticket + comentarios ordenados + datos del reporter. Compárala contra la versión "2 finds + batch" de la Fase 3 (ejercicio 19 de aquella fase): ¿cuál prefieres para el endpoint real de la Fase 10 y por qué? (Pista: el contrato pide comments por endpoint separado — ¿cambia eso la respuesta?)
13. Implementa las tres formas (N+1, batch, `$lookup`) del laboratorio como funciones Node con la misma firma: `listWithReporter(limit)`. Idéntico output verificado con un diff profundo.
14. Un `$lookup` de `tickets` (izquierda, 100k, sin `$match`) contra `users`: mídelo. Ahora con `$match` que deje 200 tickets. La diferencia ES "filtra antes de unir" — anota los números.
15. `$unwind` traicionero: sobre el resultado del ejercicio 1, aplica `$unwind` sin `preserveNullAndEmptyArrays`, cuenta, y encuentra cuántos tickets desaparecieron. Escribe el bug report como si un compañero lo hubiera cometido en producción (2019, caso real en miles de equipos).
16. La cadena: en `soporte_v1`, el detalle completo (ticket + estado + prioridad + asignado + reportador + comentarios + autor de cada comentario — este último es un lookup con pipeline anidado). Cuéntale las etapas. Guarda el engendro: es la pieza central del ejercicio 24.
17. Sincronización dirigida: implementa `renameAgent(username, newName)` con las dos escrituras del capítulo + logging de cuántos tickets tocó. Mátalo a la mitad (un `process.exit` entre ambas) y fotografía el drift con una consulta.
18. Escribe `scripts/reconcile-assignee-names.js` completo (detecta + repara + reporta, idempotente). Úsalo para sanar el drift del ejercicio 17. Prográmalo mentalmente: ¿cada cuánto correría en tu tolerancia declarada?

**🟠 Difícil (19–27)**

19. **El laboratorio central (parte 1):** cronometra las tres formas del listado (20 tickets + reporter) a 4 escalas de la colección izquierda: 1k, 10k, 100k, y con `limit` 20 vs 500. Tabla completa (forma × escala × limit) en `DATA-MODEL.md`.
20. **(parte 2):** repite la celda peor con la colección `users` crecida a 50k usuarios falsos. ¿Cambió el ranking? ¿Por qué el batch `$in` sufre menos con la derecha grande… o más? Explica con lo que sabes del nested-loop.
21. **(parte 3):** simula la latencia de red real (tu app y tu Mongo no comparten máquina en producción): agrega ~5 ms por round-trip (proxy con `toxiproxy`, o estimación aritmética documentada: viajes × 5 ms). Recalcula el ranking. El N+1 con red es OTRO deporte — demuéstralo.
22. `explain` de una aggregation: corre `db.tickets.explain("executionStats").aggregate([...])` sobre la forma 3. Localiza cuánto examina la izquierda. ¿El lookup interno aparece detallado? (En 4.4, poco: documenta qué visibilidad tienes y qué no — saberlo es parte del oficio.)
23. **Anti-patrón, medición 1:** el dashboard de `soporte_v1` (4 lookups) vs el de `minijira` (0 lookups), 100 ejecuciones, promedio y p95. A la tabla de la autopsia.
24. **Anti-patrón, medición 2:** el detalle completo (tu engendro del ej. 16) vs el detalle de `minijira`. Incluye la variante `soporte_v1` "batch $in a mano" (como haría un dev espabilado sin cambiar el modelo): demuestra que mejora… y que sigue perdiendo. El modelo manda.
25. **Anti-patrón, medición 3:** la búsqueda `?q=impresora` del contrato. En `minijira`: regex sobre title/description (Fase 2). En `soporte_v1`: el texto vive en `tickets` pero el dashboard necesita todo legible → regex + 4 lookups. Mide y documenta el efecto compuesto: el modelo malo encarece TAMBIÉN lo que no une.
26. Computed bajo protocolo: implementa `commentsCount` (Fase 3, ej. 11) con el protocolo completo de la fase — escritor único (`addComment` es el dueño), reconciliación (`reconcile-comment-counts.js` comparando contra `countDocuments` real), tolerancia declarada por escrito. La carrera del `$inc` queda señalada para la Fase 6.
27. El reporte nocturno legítimo: "actividad semanal por agente" (tickets asignados, comentarios escritos — cruza 3 colecciones con 2 lookups). Escríbelo SIN culpa, mídelo, y documenta por qué aquí `$lookup` es la herramienta correcta (frecuencia, quién espera, alternativa denormalizada que NO vale su costo). La regla de la fase, aplicada en positivo.

**🔴 Muy difícil (28–33)**

28. Radiografía del nested-loop: demuestra empíricamente que el costo del `$lookup` básico es ~lineal en la izquierda. Corre la misma unión con izquierda de 100, 1k, 10k, 100k (derecha constante), grafica/tabula tiempo vs tamaño, ajusta a ojo la curva.
29. El `$lookup` a la misma colección (self-join): agrega a algunos tickets un campo `duplicateOf` (ObjectId de otro ticket) y resuelve "tickets con los datos de su duplicado original". En SQL era un self-join de rutina; ¿aquí qué incomoda?
30. Reconciliación a escala: tu `reconcile-assignee-names` recorre todo. Rediséñalo incremental usando `updatedAt` (Fase 4): solo verifica copias de tickets/users tocados desde la última corrida (persiste el watermark en una colección `_jobs`). Mide: reconciliación completa vs incremental sobre 100k con 0.1% de drift.
31. Detector de síntomas: script `scripts/lookup-audit.js` que recibe un archivo con pipelines de aggregation (JSON) y reporta: cantidad de `$lookup` por pipeline, cadenas de 3+, lookups sin `$match` previo, pipelines internos con `$sort`/`$group`. Córrelo contra tus pipelines de la fase: ¿cuáles marcaría en un code review?
32. El caso "no denormalices esto": encuentra en el Mini Jira (o inventa con justificación) un dato que NUNCA copiarías aunque el render lo pida caliente (candidato: algo con tolerancia cero y alta frecuencia de cambio). Argumenta con el protocolo: si la tolerancia es cero y la reconciliación no puede ser instantánea, la copia está prohibida — ¿qué alternativas quedan? (Unir siempre, rediseñar la pantalla, o Fase 6.) Página a `DATA-MODEL.md`.
33. **El ensayo de la fase** (1 página, `INSTINTOS.md`): "El JOIN nunca fue gratis; era prepago". Tesis: el JOIN de SQL costaba — en el modelo rígido, en el optimizador que alguien programó, en los índices y estadísticas que lo alimentaban; Mongo no eliminó el costo del join: te lo cobra en la mesa (modelas para no unir, o unes y pagas al contado). Usa tus mediciones (19–25) como evidencia. Cierra con tu regla personal de cuándo aceptas un `$lookup` en un PR.

**🔥 Opcionales**

- 🔥 Sobre el ejercicio 28: ¿qué pasa con la forma pipeline + `$sort` interno? ¿Sigue siendo lineal en la izquierda, o el orden interno la dobla? Mídelo y explica.
- 🔥 La versión evento (adelanto arquitectónico honesto): rediseña `renameAgent` para que la segunda escritura sea asíncrona — el rename escribe `users` + inserta un doc en una colección `_outbox`; un worker separado procesa la outbox y actualiza los tickets, con reintento. Implementa el esqueleto (dos scripts). Discute: ¿qué ganaste (el rename nunca deja drift permanente) y qué pagaste (drift temporal SIEMPRE, infraestructura)? Es el patrón que en 2021 se volvía moda; conocer su costo es conocer su hype.

---

## 📚 Referencias

**Documentación oficial (4.4)**

> ⚠️ **Versiones fijadas.** Todo el código Node de esta fase corre con el
> **driver nativo `mongodb` 3.6** contra **MongoDB 4.4**. La forma `pipeline`
> de `$lookup` con `let` exige servidor 3.6+ (la tienes de sobra en 4.4). Los
> enlaces de abajo apuntan a la doc `/v4.4/`; si caes en otra versión, cambia
> el segmento de la URL.

- `$lookup` (referencia completa, ambas formas): https://www.mongodb.com/docs/v4.4/reference/operator/aggregation/lookup/
- `$unwind` (y `preserveNullAndEmptyArrays`): https://www.mongodb.com/docs/v4.4/reference/operator/aggregation/unwind/
- `$expr` y variables `$$` (la correlación del pipeline): https://www.mongodb.com/docs/v4.4/reference/operator/query/expr/
- Aggregation Pipeline Optimization (qué SÍ reordena el motor — spoiler: `$match`, no joins): https://www.mongodb.com/docs/v4.4/core/aggregation-pipeline-optimization/
- `explain` de aggregations: https://www.mongodb.com/docs/v4.4/reference/method/db.collection.explain/

**La serie de la época**

- Building with Patterns: The Extended Reference Pattern (la denormalización con nombre): https://www.mongodb.com/blog/post/building-with-patterns-the-extended-reference-pattern
- 6 Rules of Thumb for MongoDB Schema Design (releer la parte de referencing — ahora con números tuyos): https://www.mongodb.com/blog/post/6-rules-of-thumb-for-mongodb-schema-design

**Libros**

- *MongoDB: The Definitive Guide*, 3.ª ed. (Bradshaw, Brazil & Chodorow,
  O'Reilly, 2019) — cap. 7 (aggregation, la parte de `$lookup`). Ficha:
  https://www.oreilly.com/library/view/mongodb-the-definitive/9781491954454/
  ⚠️ La 3.ª ed. cubre MongoDB 4.0/4.2; la forma `pipeline` de `$lookup`
  (3.6+) ya está incluida y aplica igual en 4.4.

**Video (YouTube)**

> ℹ️ Estos dos no tienen un enlace único estable: son **criterios de
> búsqueda**, no URLs fijas. Parte del canal oficial de MongoDB
> (https://www.youtube.com/@MongoDB) y filtra por charlas de 2018–2020.

- `$lookup` / Joins in MongoDB — cualquier talk oficial de MongoDB de
  2018–2020 sobre aggregation; **verifica que use la sintaxis `let`/`pipeline`**
  (si solo muestra `localField`/`foreignField`, es previo a 3.6 y se queda
  corto para esta fase).
- "The Curse of the Unindexed Foreign Field" (el concepto, no un título
  literal): lo toca cualquier charla de *aggregation performance* de MongoDB
  World 2019. Búscalo por "MongoDB World 2019 aggregation performance".

**Orden de lectura sugerido para perfil senior:**
la referencia de `$lookup` (las dos formas, 20 min) → Aggregation Pipeline
Optimization (corto y revelador: verás qué poco reordena) → ejercicios 19–21
(el laboratorio: la fase se entiende con cronómetro) → Extended Reference
Pattern → 23–25 (el villano) → el ensayo.

---

## 🚀 Cierre

Al final de esta fase, `$lookup` está en tu caja de herramientas con su
etiqueta puesta: LEFT JOIN que agrupa, nested-loop sin optimizador, legítimo
en lo analítico y nocturno, alarma en lo caliente. Tienes las tres formas de
unir medidas a escala, el protocolo adulto de las copias (escritor único,
carrera nombrada, reconciliación, tolerancia con número), y al villano con
dos mediciones más en su expediente — esperando que la Fase 7 demuestre que
ni los índices lo salvan.

La señal de que quedó bien:

> "cuando veo un `$lookup` en un PR, mi primera pregunta ya no es '¿está bien
> escrito?' sino '¿en qué endpoint corre y cuántas veces por minuto?' — y
> cuando veo una copia denormalizada, pregunto quién la escribe y quién la
> reconcilia".

**Siguiente parada:** ⚛️ Fase 6 — Atomicidad del documento, transacciones y
consistencia. Quedaron dos carreras señaladas con banderita (la doble
escritura del rename, el `$inc` del contador) y un conflicto heredado sin
resolver (los dos agentes que "toman" el mismo ticket). Es hora de cobrar el
premio de haber embebido bien — y de conocer la transacción que existe pero
ya no es el pegamento.
