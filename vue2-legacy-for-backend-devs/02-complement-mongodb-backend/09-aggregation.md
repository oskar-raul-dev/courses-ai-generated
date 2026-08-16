# 🧮 Fase 9 — Aggregation: tu GROUP BY con esteroides

## 🎯 Propósito

Devolverte tu SQL analítico. `GROUP BY`, `HAVING`, funciones de agregación,
subconsultas para pivotear — todo eso vive aquí bajo el nombre de
**aggregation pipeline**, y esta fase lo enseña como la Fase 2 enseñó el
`SELECT`: espejo contra tu idioma, sobre tus datos.

El modelo mental es el único cambio real: SQL es **declarativo** (describes
el resultado, el motor decide el cómo); el pipeline es una **cadena de
etapas** (describes el cómo, etapa por etapa, como una tubería Unix). Para
alguien que ha escrito planes de ejecución mentalmente durante años, esto es
menos un obstáculo que una confesión del motor: el plan eres tú.

Y el entregable tiene nombre y deuda: la lógica completa de **`GET /stats`**
— las métricas que el sistema heredado calcula en el navegador 💸 —, escrita,
medida y lista para que la Fase 10 la exponga como endpoint (extensión
pactada en `AUDIT-CONTRATO.md`).

> 📝 **Nota de coherencia:** `AUDIT-CONTRATO.md` (tabla de extensiones) fichó
> `GET /stats` como extensión de la "Fase 8". Es un desfase de numeración: la
> Fase 8 es la autopsia (no monta HTTP) y Express nace en la Fase 10 ("el
> contrato crece"). Aquí queda **la función pura**; el **endpoint** es Fase
> 10. Corrige esa celda del contrato a `10` cuando lo revises.

---

## ✅ Qué queda listo al terminar

- el arsenal de etapas dominado: `$match`, `$group`, `$project`, `$sort`,
  `$limit`, `$unwind`, `$addFields`, `$count`, `$facet`, `$bucket`, `$out`/`$merge`;
- los acumuladores (`$sum`, `$avg`, `$min`, `$max`, `$push`, `$addToSet`,
  `$first`, `$last`) mapeados a tus funciones de agregación;
- las traducciones canónicas: `GROUP BY`, `HAVING`, `COUNT(DISTINCT)`,
  `CASE WHEN` para pivotear, y la verdad incómoda sobre window functions
  en 4.4;
- la lógica de `GET /stats` completa: por estado, por prioridad, por agente
  (con la faceta `activeByAgent` que **reproduce clavada** la métrica que
  Track A calcula hoy en cliente, `TRACKA-07`), tiempos de resolución desde
  `history`, todo en UNA pasada con `$facet`;
- rendimiento del pipeline: qué optimiza el motor solo, qué índices
  aprovecha (`$match`/`$sort` tempranos), `allowDiskUse` y el límite de
  100 MB por etapa;
- `$out`/`$merge` para materializar (tu vista materializada artesanal).

## 🚫 Qué NO entra todavía

- el endpoint HTTP `GET /stats` (Fase 10 lo monta; aquí queda la función);
- `$lookup` de nuevo en profundidad (Fase 5 fue su capítulo; aquí aparece
  como una etapa más, ya domesticada);
- pipelines de update (los usaste en la Fase 4; no se repiten);
- map-reduce (legado del legado: se menciona para que lo reconozcas en
  código viejo y lo migres, no para usarlo).

---

## 🧠 El pipeline en 60 segundos

```js
db.tickets.aggregate([
  { $match: { status: { $ne: "closed" } } },   // WHERE   (filtra ANTES)
  { $group: {
      _id: "$priority",                         // GROUP BY priority
      total: { $sum: 1 },                       // COUNT(*)
      avgTouch: { $avg: "$touchCount" }         // AVG(touch_count)
  } },
  { $match: { total: { $gte: 5 } } },           // HAVING  (¡es otro $match!)
  { $sort: { total: -1 } }                      // ORDER BY
])
```

Documentos entran por la izquierda, cada etapa transforma, lo que sale
alimenta a la siguiente. Tres anclas para tu cerebro SQL:

1. **`HAVING` no existe como palabra**: es un `$match` *después* del
   `$group`. La posición en la tubería ES la semántica — el mismo `$match`
   es WHERE antes y HAVING después.
2. **`_id` del `$group` = tu lista de GROUP BY.** Compuesto:
   `_id: { s: "$status", p: "$priority" }`. Total general: `_id: null`.
3. **`"$campo"` con dólar = referencia al valor** (como el `$$` de la
   Fase 5, un solo nivel). Sin dólar, es un literal. El 80% de los pipelines
   rotos de la época son un dólar de menos.

### 🩻 Esto SÍ funciona igual

Tu intuición analítica completa: qué es agrupar, por qué filtrar antes de
agrupar es más barato que después, la diferencia WHERE/HAVING, el costo de
un DISTINCT gordo, el olor de un ORDER BY sin índice sobre millones de
filas. Y tu disciplina de construir la consulta analítica **incrementalmente**
— aquí es literal: escribes el pipeline etapa por etapa, ejecutando tras
cada una para ver qué fluye.

---

## 📖 El espejo analítico

### GROUP BY básico y compuesto

```sql
SELECT status, COUNT(*) AS total FROM tickets GROUP BY status;

SELECT status, priority, COUNT(*) AS total, MAX(created_at) AS last
FROM tickets GROUP BY status, priority;
```

```js
db.tickets.aggregate([
  { $group: { _id: "$status", total: { $sum: 1 } } }
])

db.tickets.aggregate([
  { $group: {
      _id: { status: "$status", priority: "$priority" },
      total: { $sum: 1 },
      last: { $max: "$createdAt" }
  } },
  // cosmética para que salga plano como tu SELECT:
  { $project: { _id: 0, status: "$_id.status", priority: "$_id.priority",
                total: 1, last: 1 } }
])
```

### COUNT(DISTINCT) y los acumuladores de conjunto

```sql
SELECT assignee, COUNT(DISTINCT reporter) AS reporters
FROM tickets GROUP BY assignee;
```

```js
db.tickets.aggregate([
  { $group: { _id: "$assignee", reporters: { $addToSet: "$reporter" } } },
  { $project: { reporters: { $size: "$reporters" } } }
])
// $addToSet junta el conjunto; $size lo cuenta. Dos pasos honestos:
// el motor te muestra el costo que tu COUNT(DISTINCT) escondía. 
```

### El pivote (tu CASE WHEN dentro del agregado)

```sql
SELECT assignee,
  SUM(CASE WHEN status = 'open' THEN 1 ELSE 0 END)   AS open,
  SUM(CASE WHEN status = 'closed' THEN 1 ELSE 0 END) AS closed
FROM tickets GROUP BY assignee;
```

```js
db.tickets.aggregate([
  { $group: {
      _id: "$assignee",
      open:   { $sum: { $cond: [{ $eq: ["$status", "open"] }, 1, 0] } },
      closed: { $sum: { $cond: [{ $eq: ["$status", "closed"] }, 1, 0] } }
  } }
])
// $cond ES tu CASE WHEN. La traducción más literal de toda la fase.
```

### `$unwind`: el UNNEST que agrupa por elementos de array

```js
// ¿Qué agente hizo más transiciones? history está embebido (Fase 3):
db.tickets.aggregate([
  { $unwind: "$history" },                       // 1 doc por entrada de history
  { $group: { _id: "$history.by", moves: { $sum: 1 } } },
  { $sort: { moves: -1 } }
])
```

El dato que en `soporte_v1` era una colección (`ticket_historial`) y aquí es
un array embebido se analiza **igual de bien**: `$unwind` lo despliega a
filas cuando la analítica lo pide. Embeber no te costó la analítica — otra
objeción de la Fase 3 que cae.

### Window functions: la verdad incómoda de 4.4

Tu `ROW_NUMBER() OVER (PARTITION BY ...)`, tus acumulados, tus rankings:
**`$setWindowFields` llega en MongoDB 5.0** — tu 4.4 no lo tiene. Las salidas
de la época, de más a menos digna:

1. re-preguntar: muchos "window" son un `$group` + `$unwind` disfrazados
   (top-N por grupo: `$group` con `$push` + `$slice` — ejercicio 17);
2. `$lookup` a la propia colección para el acumulado (caro, honesto);
3. traer los datos agrupados y terminar el ranking en Node (la app como
   window function — pecado venial si el grupo es chico);
4. materializar con `$merge` y calcular por lotes.

> 📝 **Nota legacy honesta:** cuando heredes un pipeline de 2020 con un
> `$lookup` a sí mismo y un `$arrayElemAt` sospechoso, estás viendo a alguien
> emulando `LAG()`. Reconócelo antes de juzgarlo: no había otra.

---

## 📊 `GET /stats`: la deuda, pagada en lógica

El sistema heredado calcula en el navegador: tickets por estado, por agente,
por prioridad. El backend lo hará en UNA pasada con `$facet` (sub-pipelines
paralelos sobre el mismo flujo de entrada):

```js
// lib/stats.js — la función que la Fase 10 expondrá como GET /stats
async function computeStats(db) {
  const [result] = await db.collection("tickets").aggregate([
    { $facet: {
        byStatus: [
          { $group: { _id: "$status", count: { $sum: 1 } } },
          { $project: { _id: 0, status: "$_id", count: 1 } }
        ],
        byPriority: [
          { $group: { _id: "$priority", count: { $sum: 1 } } },
          { $project: { _id: 0, priority: "$_id", count: 1 } }
        ],
        // OJO: el frontend (TRACKA-07, activeByAgent) grafica SOLO carga
        // activa — open + in_progress. Reproducimos ESA métrica al pie de la
        // letra para que el dashboard muestre los mismos números al migrar.
        activeByAgent: [
          { $match: { assignee: { $type: "string" },
                      status: { $in: ["open", "in_progress"] } } },
          { $group: { _id: "$assignee", count: { $sum: 1 } } },
          { $sort: { count: -1 } },
          { $project: { _id: 0, agent: "$_id", count: 1 } }
        ],
        // total histórico por agente (todos los estados). No lo pinta el
        // cliente hoy; queda disponible como extensión del contrato.
        byAgent: [
          { $match: { assignee: { $type: "string" } } },
          { $group: { _id: "$assignee", count: { $sum: 1 } } },
          { $sort: { count: -1 } },
          { $project: { _id: 0, agent: "$_id", count: 1 } }
        ],
        resolution: [
          // tiempo hasta resolved, calculado DESDE history (el premio analítico
          // de haberlo embebido): primera entrada cuyo "to" sea resolved
          { $unwind: "$history" },
          { $match: { "history.to": "resolved" } },
          { $group: { _id: "$_id", resolvedAt: { $min: "$history.at" },
                      createdAt: { $first: "$createdAt" } } },
          { $project: { hours: { $divide: [
              { $subtract: ["$resolvedAt", "$createdAt"] }, 3600000 ] } } },
          { $group: { _id: null, avgHours: { $avg: "$hours" },
                      maxHours: { $max: "$hours" }, tickets: { $sum: 1 } } },
          { $project: { _id: 0 } }
        ]
    } }
  ]).toArray();
  return result;   // { byStatus:[...], byPriority:[...], activeByAgent:[...], byAgent:[...], resolution:[{...}] }
}
```

🔎 **Qué hace:** `$facet` corre los análisis en paralelo lógico sobre la
misma colección, devolviendo un solo documento con todas las respuestas —
un solo viaje para todo el dashboard de métricas. La faceta `resolution` es
la estrella: aritmética de fechas (`$subtract` de dates da milisegundos)
sobre el `history` embebido — una métrica que el frontend **no podía**
calcular bien porque el sistema heredado ni registraba transiciones.

> 🪞 **Tu instinto dice** que "tickets por agente" es una sola consulta. Y
> esta vez casi acierta… salvo por un detalle que el frontend ya decidió por
> ti: el dashboard heredado (`TRACKA-07`, `activeByAgent`) grafica **carga
> activa** — solo `open` + `in_progress`, no el histórico completo. Si tu
> `byAgent` cuenta todos los estados, los números **no cuadran** con la dona
> que el usuario ya conoce. Por eso hay dos facetas: `activeByAgent`
> reproduce clavado lo que el cliente pinta hoy (fidelidad del contrato), y
> `byAgent` es el total histórico que el cliente nunca calculó — disponible
> como extensión, no como reemplazo. La regla de oro: **la métrica migrada
> tiene que dar el mismo número que la métrica que reemplaza.**

✅ **Buenas prácticas sembradas:** `$project` final en cada faceta para dejar
la forma de salida limpia y estable; `$match` primero donde lo hay; y el
conjunto queda como **función pura de datos** en `lib/` — testeable en la
Fase 13 sin HTTP de por medio.

> ⭐ **Este shape es el contrato de `/stats`.** Track A todavía no fija las
> claves (`TRACKA-07` solo crea `statsService.js`), así que **la forma
> canónica se declara aquí** y la Fase 10 la sirve tal cual, sin retocar:
>
> ```js
> {
>   byStatus:      [{ status, count }],      // reemplaza countByStatus (cliente)
>   byPriority:    [{ priority, count }],
>   activeByAgent: [{ agent, count }],       // = activeByAgent del cliente, clavado
>   byAgent:       [{ agent, count }],       // total histórico (extensión, nuevo)
>   resolution:    [{ avgHours, maxHours, tickets }]
> }
> ```
>
> Cuando Track A migre su cálculo local a este endpoint (ej. 25 de
> `TRACKA-07`), consume estas claves. Fijarlas ahora evita que backend y
> frontend inventen dos formas que no coinciden.

> ⚠️ Dos letras chicas de `$facet`: sus sub-pipelines **no usan índices**
> (reciben el flujo ya en curso — si necesitas un `$match` indexado, va
> ANTES del `$facet`), y toda la salida es UN documento (límite 16 MB: para
> facetas que devuelven listas grandes, no es la herramienta).

---

## ⚙️ Rendimiento del pipeline (lo justo, con tus reflejos)

- **El motor reordena poco pero bien:** `$match` y `$sort` al frente se
  fusionan con el acceso e **_aprovechan índices_**; después de la primera
  etapa transformadora (`$group`, `$unwind`, `$project` que renombra), los
  índices ya no existen para el pipeline. Traducción: tu "filtra primero" es
  aquí "filtra primero **y que sea la primera etapa**".
- **`explain` funciona en aggregate** (lo viste en la Fase 5): verifica que
  el `$match` inicial pegó en IXSCAN.
- **100 MB por etapa** en memoria; si un `$group`/`$sort` gordo lo revienta:
  `{ allowDiskUse: true }` — funciona y avisa que estás haciendo analítica
  pesada en el camino caliente (a esa hora, `$merge` nocturno te espera).
- **`$out` vs `$merge`:** ambos materializan el resultado a una colección.
  `$out` reemplaza todo; `$merge` (4.2+) hace upsert incremental — tu vista
  materializada con refresh, artesanal. El stats nocturno cacheado es el
  ejercicio 26.

---

## 🧩 Chuleta de la fase

```js
// El esqueleto mental
[ $match(WHERE) → $group(GROUP BY) → $match(HAVING) → $sort → $limit ]

$group: { _id: "$campo" | {a:"$a",b:"$b"} | null,
          x: { $sum: 1 | "$campo" }, $avg, $min, $max,
          $push (array), $addToSet (DISTINCT), $first, $last }

$project / $addFields    // SELECT de expresiones / añadir sin quitar
$cond                    // CASE WHEN
$unwind                  // UNNEST del array embebido (la analítica de F3)
$facet                   // N análisis, 1 pasada (¡sin índices adentro!)
$count                   // azúcar de { $group: {_id:null, n:{$sum:1}} }
$bucket / $bucketAuto    // histogramas por rangos
$out / $merge            // materializar (replace / upsert incremental)

// Fechas: $subtract de dos dates → ms · $divide para unidades
// Reglas: $match/$sort primero (índices) · $ referencia, sin $ literal
//         100 MB/etapa → allowDiskUse · window functions: 5.0 (emular en 4.4)
```

---

## ⚠️ Errores comunes y pieza forense

- El dólar ausente (`_id: "status"` agrupa TODO en el literal "status") — el
  bug silencioso número 1 de la época.
- `$match` que podría ir primero, tercero: regalarse el COLLSCAN.
- `HAVING` intentado dentro del `$group` en vez de un `$match` después.
- `$unwind` de un array grande sin `$match` previo: multiplicar millones de
  documentos para filtrar después.
- Meter en `$facet` el filtro indexable que debía ir antes.
- `$sort` gigante sin `allowDiskUse` (error de 100 MB) — o CON él en un
  endpoint caliente (funciona, y es la confesión de que eso era un batch).
- Redondear con `$project` al final lo que pudo proyectarse temprano: cada
  etapa arrastra los campos que no cortaste.
- Reescribir en pipeline lo que era un `find` (si no hay `$group`/`$unwind`/
  transformación, `find` + índices es más simple y igual de rápido).

### 🩻 Pieza forense: "mi GROUP BY devuelve UNA fila"

Heredas este pipeline. Debería contar tickets por estado; devuelve un solo
documento con el total global. Reprodúcelo y localiza la herida antes de
seguir leyendo:

```js
db.tickets.aggregate([
  { $group: { _id: "status", total: { $sum: 1 } } }
])
// salida real:
// [ { "_id" : "status", "total" : 100000 } ]
```

**El síntoma** es inconfundible para tu ojo SQL: un `GROUP BY status` que
colapsa a una fila es un `GROUP BY <constante>`. **La autopsia:** `_id:
"status"` (sin `$`) es el **literal** de cuatro letras `"status"`, no una
referencia al campo. Mongo agrupó por esa constante — un solo grupo, todos
los documentos dentro. El `_id` de la salida te lo confesó: dice `"status"`,
no `"open"`. Ese `_id` que "sale con el nombre del campo en vez del valor" es
la huella dactilar del bug.

**La cura** es un carácter:

```js
db.tickets.aggregate([
  { $group: { _id: "$status", total: { $sum: 1 } } }   // $status = el VALOR
])
// [ { "_id":"open", "total":41230 }, { "_id":"closed", "total":38110 }, ... ]
```

**La lección de depuración** (aplica al 80% de los pipelines rotos de la
época): cuando una etapa dé algo raro, **mira el `_id` de la salida**. Si
trae el nombre literal de un campo en vez de un valor de tus datos, te comiste
un `$`. Y el método del ejercicio 11 —ejecutar etapa por etapa mirando 2
documentos— habría cazado esto en la primera etapa, antes de que el `$group`
mintiera en silencio.

---

## 🧪 Ejercicios (36)

Base: `minijira` a 100k con `history` poblado (si tu generador no lo pobló,
el ejercicio 1 lo arregla). Formato espejo obligatorio: SQL como comentario
encima de cada pipeline.

**🟢 Fácil (1–11)**

1. Prepara el terreno: script que garantice `history` realista en la base grande (cada ticket no-open con sus transiciones coherentes con su status y fechas crecientes). Verifica con 3 muestras a mano.
2. Tickets por estado (el clásico). Compara el resultado contra 4 `countDocuments` sueltos: mismo número, ¿mismo costo? (explain de ambos).
3. Tickets por prioridad **y** estado (GROUP BY compuesto), aplanado con `$project` a la forma de tu SELECT.
4. Promedio, mínimo y máximo de comentarios por ticket usando `commentsCount` (Fase 6). ¿Y el ticket récord? (`$sort` + `$limit`).
5. `HAVING`: agentes con más de 10 tickets asignados. Marca con un comentario CUÁL `$match` es WHERE y cuál es HAVING.
6. `COUNT(DISTINCT)`: ¿cuántos reporters distintos ha atendido cada agente? (el espejo del capítulo, corriendo).
7. El pivote del dashboard: por agente, columnas open/in_progress/resolved/closed con `$cond`. Es literalmente la tabla del panel del frontend.
8. `$unwind` + `$group`: total de transiciones registradas por agente (el ejemplo del capítulo). Verifica contra un conteo manual de 2 tickets.
9. `$count` y su equivalencia: demuestra que `[{ $match: X }, { $count: "n" }]` = `countDocuments(X)`.
10. Los 5 tickets más comentados con título y contador — pipeline puro, sin traer datos a Node.
11. Meta-ejercicio de disciplina: toma el pipeline del ej. 7 y ejecútalo incrementalmente (etapa 1 sola, luego 1+2, luego 1+2+3...) mirando 2 documentos de salida en cada paso. Es EL método de construcción y depuración de pipelines — internalízalo ahora que son chicos.

**🟡 Intermedio (12–21)**

12. Histograma temporal: tickets creados por mes (`$group` con `_id: { y: { $year: "$createdAt" }, m: { $month: "$createdAt" } }`), ordenado cronológicamente. El espejo SQL con `EXTRACT`/`DATE_TRUNC` como comentario.
13. `$bucket`: distribución de tickets por antigüedad (0-7 días, 7-30, 30-90, 90+). ¿Y con `$bucketAuto` en 4 cubos? ¿Qué límites eligió?
14. Tiempo de primera respuesta: por ticket, horas entre `createdAt` y su PRIMER comentario (join con comments vía `$lookup` — ya domesticado — + `$min` + aritmética de fechas). Promedio global y por prioridad.
15. La métrica de resolución del capítulo, desmenuzada: reconstrúyela tú etapa por etapa (método del ej. 11) sin mirar el código, y compara tu versión con la del capítulo. ¿Diferencias? ¿Cuál maneja mejor un ticket resuelto DOS veces (reopen + re-resolve)? Decide la semántica (¿primera o última resolución?) y ajústala.
16. `$addFields` vs `$project`: agrega `ageDays` calculado a los tickets del listado SIN perder los demás campos. ¿Cuándo preferirías cada etapa?
17. Top-3 por grupo sin window functions: los 3 tickets más recientes de CADA agente (`$sort` + `$group` con `$push` + `$slice` en el `$project`). El espejo SQL con `ROW_NUMBER()` como comentario — y la nota de que esto en 5.0 sería `$setWindowFields`.
18. El acumulado (running total) de tickets creados por mes — elige tu salida de la sección de window functions (self-lookup / Node / repensar), implementa una y justifica el costo.
19. `$facet` completo del capítulo corriendo contra tu base. Cronométralo vs las 4 agregaciones por separado (4 viajes). ¿Cuánto ahorró el facet? ¿Y si la colección fuera 10× — dónde está el límite?
20. Demuestra la letra chica del `$facet`: mete un `$match: { status: "open" }` DENTRO de una faceta vs ANTES del facet, y compara explains. ¿Dónde desapareció el IXSCAN?
21. `distinct()` de la Fase 2 vs `$group`+`$addToSet`: mismos assignees únicos, dos caminos. ¿Cuándo se te queda corto `distinct()`? (Pista: ¿distinct de un campo POR grupo?)

**🟠 Difícil (22–30)**

22. Actividad semanal por agente v2: rehaz el reporte nocturno de la Fase 5 (ej. 27) ahora con el arsenal completo — una sola aggregation con `$facet` (tickets, comentarios vía lookup, transiciones vía unwind). Compárala con tu versión de entonces: ¿más clara o más críptica? La legibilidad también se audita.
23. `allowDiskUse` en vivo: fabrica un `$group` que reviente los 100 MB (agrupa con `$push` de documentos completos sobre la base grande), documenta el error exacto, sálvalo con `allowDiskUse` y mide el costo del desborde a disco.
24. Optimización verificable: toma un pipeline deliberadamente mal ordenado (te lo escribes: `$project` primero, `$match` al final, `$unwind` temprano) y optimízalo por pasos, midiendo cada mejora con explain + cronómetro. Tabla de la evolución: es tu viejo oficio de afinar queries, en pipeline.
25. `$merge` como vista materializada: materializa el resultado del `$facet` de stats a una colección `stats_cache` con timestamp, y escribe el par: `refreshStats()` (corre y merge) + `getStats()` (lee el caché con su edad). El patrón del stats nocturno de la época, completo.
26. Decide la arquitectura de `/stats`: ¿en vivo ($facet por request) o cacheado ($merge + TTL/refresh)? Con tus números del ej. 19 y una frecuencia inventada-pero-declarada del dashboard, escribe la decisión formato `DATA-MODEL.md` con el trigger de cambio ("si stats supera N req/min o la base M docs → caché").
27. La analítica transversal de la autopsia: re-implementa "actividad de un agente" (F8, tabla final) como aggregation sobre `soporte_v2`/`minijira` y añade la fila que faltaba: ¿la analítica pesada es donde el modelo normalizado se defendía? Mide contra `soporte_v1` (sus lookups ya indexados) y cierra el debate con números.
28. Auditoría de nulls a escala, saldada: rehaz el ejercicio 24 de la Fase 2 (el reporte de 3 estados de `assignee`) ahora en UNA aggregation con `$cond` + `$type`. Compara el sufrimiento de entonces con el de ahora: ese delta ES esta fase.
29. Encuentra el map-reduce fósil: busca en GitHub un `mapReduce()` de la época (2015–2019 abunda) y tradúcelo a pipeline. Documenta: ¿qué gana la traducción (legibilidad, rendimiento, mantenibilidad)? Es una tarea de modernización real que te va a tocar.
30. El pipeline como dato: guarda los pipelines de stats en `pipelines/*.json` (son JSON puro — esa es una superpotencia silenciosa) y escribe el runner que los carga, ejecuta y valida su forma de salida contra un schema (ajv de la Fase 4). Configuración analítica versionable y testeable.

**🔴 Muy difícil (31–36)**

31. SLA por prioridad: define umbrales (high: 24h, medium: 72h, low: 168h) y calcula, POR prioridad, el % de tickets resueltos dentro de su SLA — todo en pipeline (necesitarás `$switch` o `$cond` anidados + la métrica de resolución). La consulta que un Mini Jira real cobraría.
32. Cohortes: por mes de creación del ticket, ¿qué % está resuelto a los 7 / 30 / 90 días? Matriz mes × ventana. Es la consulta analítica más dura de la fase — método incremental o muerte.
33. El "explain del pipeline" como herramienta propia: script `scripts/pipeline-lint.js` que recibe un pipeline JSON y advierte: `$match` no-inicial que podría subir, `$unwind` antes de `$match`, `$project` temprano que corta campos usados después (¡detecta el error!), `$facet` con filtros indexables adentro. Córrelo sobre todos tus pipelines de la fase.
34. Percentiles sin percentile (llega en 7.0): calcula p50 y p95 del tiempo de resolución en 4.4 — `$push` + `$sort` del array + `$arrayElemAt` al índice calculado, o materializando. Implementa, valida contra un cálculo en Node, y documenta el truco: lo verás en legacy analítico.
35. El stress del stats: con la base a 1 millón de tickets (generador al máximo), ¿el `$facet` en vivo sigue siendo viable? Mide, encuentra el cuello (¿qué faceta?), optimiza lo optimizable (¿$match temprano común? ¿pre-agregación con $merge?) y actualiza la decisión del ej. 26 con los números nuevos. Las decisiones tienen fecha de vencimiento; acabas de ejercer una.
36. **El ensayo de la fase** (1 página, `INSTINTOS.md`): "El plan de ejecución que siempre escribiste". Tesis: el pipeline no es un lenguaje analítico peor que SQL — es el plan de ejecución sin el optimizador de por medio: pierdes al planificador declarativo, ganas control y transparencia totales; la pregunta es cuándo ese trade te conviene. Usa el ej. 24 (tu optimización manual) y el 27 como evidencia. Cierra con tu criterio: qué analítica dejas en pipeline, cuál materializas, y cuál — honestidad de Fase 15 — pertenece a otra herramienta.

**🔥 Opcionales**

- 🔥 **Fidelidad del contrato, probada:** corre `computeStats` contra tu base y, en paralelo, corre las funciones puras de Track A (`countByStatus`, `activeByAgent` de `TRACKA-07`) sobre el mismo dataset traído a Node. Assert de que `byStatus` y `activeByAgent` del backend dan **exactamente** los mismos números que el cliente. Si difieren, encontraste una regresión antes que el usuario. (Este es el test que la Fase 13 formaliza.)
- 🔥 **El caso `byAgent` que engaña:** construye a mano un escenario de 3 tickets (uno `open`, uno `closed`, uno `resolved`) todos del mismo agente y demuestra con números por qué `byAgent` (=3) y `activeByAgent` (=1) **deben** diferir. Escribe en una línea por qué mezclarlos rompería la dona del dashboard.
- 🔥 **map-reduce vs pipeline, cronometrado:** toma el fósil que tradujiste en el ej. 29 y mide ambos con la base grande. Documenta el factor de aceleración real; suele ser aleccionador.
- 🔥 **`$out` destructivo, la lección cara:** corre un `$out` a una colección que YA tiene datos y observa que la reemplaza entera (no hace merge). Recupérate. Escribe la regla mnemotécnica que te ahorrará el susto en producción.

---

## 📚 Referencias

**Documentación oficial (4.4)**

- Aggregation Pipeline (el hub): https://www.mongodb.com/docs/v4.4/core/aggregation-pipeline/
- Referencia de etapas (el diccionario): https://www.mongodb.com/docs/v4.4/reference/operator/aggregation-pipeline/
- Operadores de expresión ($cond, $subtract, fechas...): https://www.mongodb.com/docs/v4.4/reference/operator/aggregation/
- `$group` y acumuladores: https://www.mongodb.com/docs/v4.4/reference/operator/aggregation/group/
- `$facet`: https://www.mongodb.com/docs/v4.4/reference/operator/aggregation/facet/
- `$merge` (la vista materializada): https://www.mongodb.com/docs/v4.4/reference/operator/aggregation/merge/
- Pipeline Optimization (releída: ahora entiendes cada línea): https://www.mongodb.com/docs/v4.4/core/aggregation-pipeline-optimization/
- SQL to Aggregation Mapping Chart (el diccionario oficial de esta fase): https://www.mongodb.com/docs/v4.4/reference/sql-aggregation-comparison/
- Límites del pipeline (100 MB, allowDiskUse): https://www.mongodb.com/docs/v4.4/core/aggregation-pipeline-limits/

**Libros**

- *MongoDB: The Definitive Guide*, 3.ª ed. — cap. 7 completo (Introduction
  to the Aggregation Framework).
- *Practical MongoDB Aggregations* (Paul Done — libro online gratuito,
  nacido exactamente de la práctica de esta época; joya):
  https://www.practical-mongodb-aggregations.com/

**Video (YouTube)**

- Aggregation Pipeline Power++ — MongoDB World (busca charlas de Paul Done /
  Asya Kamsky sobre aggregation: Asya es LA referencia de pipelines de la
  época)
- MongoDB Aggregation Framework — freeCodeCamp / Net Ninja (playlists de
  2019–2021 con la sintaxis exacta de 4.4)

**Orden de lectura sugerido para perfil senior:**
SQL to Aggregation Mapping Chart (tu Rosetta, 15 min) → ejercicios 1–11 con
el método incremental → Pipeline Optimization → Practical MongoDB
Aggregations (caps. de "Optimizing" y "Sharding-aware" opcionales) → el
resto de ejercicios → $merge/$facet como referencia.

---

## 🚀 Cierre

Al final de esta fase, tu SQL analítico habla pipeline: GROUP BY/HAVING
traducidos con naturalidad, el pivote con `$cond`, la analítica sobre arrays
embebidos con `$unwind` (cerrando la última objeción contra la Fase 3), los
límites de 4.4 conocidos con sus salidas dignas, y la lógica de `GET /stats`
escrita, medida y decidida (en vivo vs materializada) como función pura
esperando su endpoint.

La señal de que quedó bien:

> "construyo pipelines etapa por etapa como quien arma una tubería Unix, sé
> exactamente dónde el motor deja de ayudarme con índices — y cuando veo un
> pipeline heredado de 15 etapas, lo leo de arriba a abajo sin miedo".

> ⚠️ **Antes de cruzar a la Fase 10 — el smoke test de la promesa.**
> `AUDIT-CONTRATO.md` ubica **aquí** (checklist de la Fase 9) la verificación
> de que todo lo construido hasta ahora sostiene el contrato con el frontend:
> con json-server apagado y `baseURL` apuntando al Express, el login mock
> entra, el dashboard carga, filtros/orden/búsqueda (`?q=`) funcionan, el 404
> real aparece, crear/editar/tomar/eliminar se reflejan, los comentarios
> listan ordenados, **las métricas del dashboard siguen calculando en cliente
> sin errores** (la deuda 💸 aún viva: la pagará el `GET /stats` que acabas de
> escribir), y el `git diff` del frontend es **exactamente una línea**.
> Córrelo entero: es la prueba de que la migración fue invisible.

**Siguiente parada:** 🚂 Fase 10 — Express: el vehículo (sin ceremonia). Todo
lo que este curso construyó vive en scripts y funciones de `lib/`. Es hora
del momento por el que existe el proyecto: montarlo detrás de HTTP, imitar a
json-server hasta en sus manías… y apagarlo para siempre con el frontend
mirando — sin que se entere.
