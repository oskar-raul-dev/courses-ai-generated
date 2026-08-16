# ⚡ Fase 7 — Índices: donde tu experiencia SQL vale intacta

## 🎯 Propósito

**Cambio de paradigma #5 — y es el bueno: el índice sigue siendo el índice.**

Cuatro fases cuestionándote certezas. Esta es la fase reconfortante, y es
reconfortante **a propósito**: B-trees, selectividad, compuestos, prefijo
izquierdo, el costo de mantener índices en cada escritura, el plan de
ejecución como juez — tu década afinando queries viaja casi entera. Lo que
esta fase agrega es lo que tu mundo no tenía (índices **multikey** sobre
arrays — la pieza que hace viable embeber —, parciales, TTL, de texto) y una
lección final con el villano: **el índice acelera el plan; no arregla el
modelo.**

Al terminar, el Mini Jira tiene su plan de índices completo, derivado del
contrato endpoint por endpoint, con cada índice justificado por un `explain`
antes/después.

---

## ✅ Qué queda listo al terminar

- `explain()` leído con la misma fluidez que tu `EXPLAIN PLAN`: COLLSCAN,
  IXSCAN, `totalDocsExamined` vs `nReturned`, sorts en memoria detectados;
- compuestos con prefijo izquierdo y la **regla ESR** (Equality, Sort, Range)
  aplicada;
- multikey entendido y medido: consultar dentro de arrays embebidos con
  índice — el complemento técnico de la Fase 3;
- índices únicos, parciales y TTL en uso real;
- la búsqueda `?q=` del contrato resuelta con criterio: regex anclado vs
  índice de texto, medidos;
- **el plan de índices del Mini Jira**, derivado del contrato y documentado
  en `DATA-MODEL.md` con sus números;
- tercera visita al anti-patrón ⚰️: `soporte_v1` indexada a conciencia… y
  perdiendo igual.

## 🚫 Qué NO entra todavía

- la autopsia completa del villano (Fase 8 — inmediatamente después)
- `$group`/aggregation y sus índices (Fase 9 los aprovecha)
- creación de índices en producción sin ventana (Fase 14, operación)
- sharding y sus índices (fuera de alcance del curso)

---

## 🧠 Lo que viaja intacto (empecemos por celebrar)

### 🩻 Esto SÍ funciona igual — la lista grande

| Tu concepto SQL | Aquí | Cambio real |
|---|---|---|
| B-tree | B-tree | ninguno |
| Full table scan | **COLLSCAN** | el nombre |
| Index scan / seek | **IXSCAN** | el nombre |
| `EXPLAIN PLAN` | `explain("executionStats")` | la sintaxis |
| Índice compuesto | compound index | ninguno |
| Prefijo izquierdo | leftmost prefix | ninguno |
| Selectividad manda | selectividad manda | ninguno |
| Índices encarecen escrituras | ídem | ninguno |
| Índice cubriente | covered query | ninguno |
| Índice único | `{ unique: true }` | ninguno |
| El optimizador elige plan | el query planner elige plan | menos maduro, mismos principios |

Léela dos veces: es la fase entera diciéndote "confía en lo que sabes".

### El vocabulario mínimo nuevo

```js
db.tickets.createIndex({ status: 1, createdAt: -1 })   // compuesto, con dirección
db.tickets.getIndexes()                                  // inventario
db.tickets.dropIndex("status_1_createdAt_-1")           // por nombre
db.tickets.find({ status: "open" }).explain("executionStats")
```

Los tres números que leerás siempre en el `explain`:

- **`totalDocsExamined`** — cuántos documentos tocó el motor;
- **`nReturned`** — cuántos devolvió;
- **la razón entre ambos** — tu métrica de eficiencia de siempre: examinar
  100.000 para devolver 20 es el mismo pecado en cualquier motor. Y el campo
  `stage`: `COLLSCAN` (alarma en caliente), `IXSCAN` (bien), `SORT` (sort en
  memoria: el índice no ordenó por ti — huele a compuesto mal diseñado).

---

## 📐 Compuestos: prefijo izquierdo y la regla ESR

El prefijo izquierdo funciona como en Oracle/Postgres: el índice
`{ status: 1, createdAt: -1 }` sirve para filtrar por `status` solo, o por
`status + createdAt`; **no** sirve para `createdAt` solo.

Lo que la época destiló como **regla ESR** para ordenar los campos del
compuesto — y que vas a reconocer como la formalización de tu intuición:

> **E**quality primero, **S**ort después, **R**ange al final.

```js
// El listado del contrato: GET /tickets?status=open&_sort=createdAt&_order=desc
// E: status (igualdad) · S: createdAt (orden) · R: (no hay)
db.tickets.createIndex({ status: 1, createdAt: -1 })

// find({status:"open"}).sort({createdAt:-1})
//   → IXSCAN + SIN etapa SORT: el índice YA entrega ordenado. El premio ESR.

// ¿Y si hubiera rango? "abiertos de 2020, ordenados por prioridad":
// E: status · S: priority · R: createdAt
db.tickets.createIndex({ status: 1, priority: 1, createdAt: -1 })
```

🔎 **Por qué ESR:** la igualdad fija un tramo contiguo del B-tree; dentro del
tramo, el sort sale gratis si es el siguiente campo; el rango al final porque
después de un rango el orden del índice ya no coincide con el del sort. Es tu
conocimiento de B-trees de siempre, con acrónimo de la época.

> 📝 **Nota sobre las direcciones (1/-1):** para un índice de un solo campo,
> la dirección da igual (se recorre al revés gratis). En compuestos con sort
> mixto (`sort({a: 1, b: -1})`) las direcciones del índice deben coincidir o
> ser el espejo exacto. Clásico de hora perdida — ejercicio 14.

---

## 🌿 Multikey: el índice que hace viable la Fase 3

Aquí está la pieza que tu mundo no tenía y que sostiene todo el paradigma de
embeber. Un índice sobre un campo array indexa **cada elemento**:

```js
db.tickets.createIndex({ tags: 1 })              // multikey automático
db.tickets.find({ tags: "hardware" })            // IXSCAN 🎉

// Y sobre campos DE documentos DENTRO de arrays:
db.tickets.createIndex({ "history.by": 1 })
db.tickets.find({ "history.by": "soporte1" })    // "todo lo que tocó soporte1"
                                                  // — la consulta transversal de
                                                  // la Fase 3, ahora indexada
```

> ### 🪞 Tu instinto dice… "los datos dentro de un array embebido son de segunda: no se pueden indexar ni consultar en serio"
>
> **Predicción falsable:** "la consulta transversal '¿qué tickets tocó
> soporte1?' contra `history` embebido va a ser un full scan inevitable; por
> eso el historial debía ser tabla aparte".
>
> Mídelo (ejercicio 17): con `{ "history.by": 1 }`, es un IXSCAN con los
> mismos números que tendría la colección separada indexada. El array
> embebido NO es un ciudadano de segunda para el motor — el multikey era la
> mitad que te faltaba del argumento de la Fase 3. **Veredicto: el instinto
> se equivoca — y con él cae la última objeción seria contra embeber.**
> 📓 A `INSTINTOS.md`.

> 💸 **Pago de deuda.** La **Fase 3** dejó a crédito el historial transversal:
> "¿y si necesito todo lo que tocó un agente, con el history embebido?" —
> prometido allí como resoluble, sin la herramienta a mano. El multikey
> `{ "history.by": 1 }` es esa herramienta: la consulta transversal es un
> IXSCAN, no el full scan que el instinto temía. Y la **Fase 5** difirió
> explícitamente "índices para acelerar el lado derecho del `$lookup` — Fase 7":
> los índices en cada `foreignField` de `soporte_v1` (⚰️ más abajo) saldan esa
> otra deuda… y demuestran que ni pagándola el villano se salva.

La letra chica del multikey (para que no te sorprenda): infla el índice (un
ticket con 10 entradas de history = 10 claves), tiene restricciones en
compuestos (solo UN campo array por índice compuesto), y los rangos sobre
multikey tienen semántica sutil con `$elemMatch` (ejercicio 18).

---

## 🎯 Los índices con condición y con reloj

**Único** — tu `UNIQUE` de siempre, con la sorpresa de los nulls:

```js
db.users.createIndex({ username: 1 }, { unique: true })
// ⚠️ dos documentos SIN el campo violan el unique (null cuenta como valor).
// La salida de la época ↓
```

**Parcial** — el índice que solo indexa lo que cumple una condición (tu
filtered index de SQL Server, tu partial de Postgres):

```js
// Solo indexa tickets CON assignee: la "cola de trabajo por agente"
db.tickets.createIndex(
  { assignee: 1, status: 1 },
  { partialFilterExpression: { assignee: { $type: "string" } } }
)
// más chico, más barato de mantener, y resuelve el unique-con-nulls.
// ⚠️ `email` NO está en la fixture del contrato (users trae username/name/role):
// lo agregas tú para este ejercicio de unique parcial.
db.users.createIndex({ email: 1 },
  { unique: true, partialFilterExpression: { email: { $exists: true } } })
```

**TTL** — el que tu mundo resolvía con un job nocturno de DELETE:

```js
// Sesiones/eventos que expiran solos a los 30 días
db.events.createIndex({ createdAt: 1 }, { expireAfterSeconds: 2592000 })
```

🔎 El monitor TTL corre ~cada 60 s y borra lo vencido. Requiere campo `Date`
— si tus fechas fueran strings (Fase 1 te lo advirtió), el TTL simplemente
no borra nada, sin error. El silencio más caro de la época.

---

## 🔍 La búsqueda `?q=` del contrato: regex vs índice de texto

El contrato exige buscar en `title` y `description`. Dos caminos de época:

```js
// Camino 1: regex — el que ya usas desde la Fase 2
db.tickets.find({ $or: [ { title: /impresora/i }, { description: /impresora/i } ] })
// anclado (/^impre/) usa índice; flotante e insensible: COLLSCAN. Tu LIKE '%..%'.

// Camino 2: índice de texto (uno solo por colección)
db.tickets.createIndex({ title: "text", description: "text" },
                       { default_language: "spanish" })
db.tickets.find({ $text: { $search: "impresora" } })
```

La comparación honesta (mídela — ejercicios 20–21): el índice de texto gana
en velocidad y pierde en semántica (tokeniza por palabras: no encuentra
substrings como "impre", aplica stemming español — "imprime" y "impresora"
pueden o no coincidir según stemming). **Decisión del proyecto:** el
comportamiento observable del contrato es "substring, insensible" (así lo
hace json-server) → nos quedamos con regex, aceptamos el COLLSCAN acotado
(el `?q=` siempre viaja con pocos resultados esperados y frecuencia baja) y
documentamos el índice de texto como alternativa si la búsqueda se volviera
caliente. La desviación y su porqué, a `DATA-MODEL.md`. Este párrafo es la
fase entera en miniatura: **el índice se elige con el contrato y el patrón de
acceso en la mano, no por catálogo.**

---

## 📋 El plan de índices del Mini Jira (derivado del contrato)

| Endpoint / operación | Consulta | Índice | Justificación |
|---|---|---|---|
| `GET /tickets?status=&_sort=createdAt` | find+sort | `{ status: 1, createdAt: -1 }` | ESR; sort gratis |
| listado sin filtro, ordenado | sort | `{ createdAt: -1 }` | el default del dashboard |
| `GET /comments?ticketId=&_sort=createdAt` | find+sort | `{ ticketId: 1, createdAt: 1 }` | ESR; la consulta más frecuente del detalle |
| `GET /users?role=agent` | find | `{ role: 1 }` | chica pero caliente (selector) |
| login (Fase 11) / unicidad | find exacto | `{ username: 1 } unique` | identidad |
| panel del agente | find | `{ assignee: 1, status: 1 } partial` | cola de trabajo; parcial excluye los null |
| transversal de auditoría | find en array | `{ "history.by": 1 }` | multikey (el del 🪞) |
| `?q=` | regex `$or` | *(ninguno — decisión documentada)* | frecuencia baja, semántica del contrato |

Cada fila del plan se **verifica** con explain antes/después (ejercicios
10–13) y viaja a `DATA-MODEL.md`. Y la contraparte de siempre: cada índice
encarece cada insert/update que toque su campo — el plan también dice qué
índices **no** creamos y por qué (ejercicio 23).

## ⚰️ Tercera visita al anti-patrón: los índices no lo salvan

El experimento estrella. `soporte_v1` recibe el mejor tratamiento posible:
índices en TODOS los `foreignField` de sus lookups (`statusId`,
`priorityId`, `assigneeId`, `reporterId`, `ticketId`, `authorId`).
Re-corre las mediciones de la Fase 5 (dashboard, detalle, búsqueda):

- mejora — a veces mucho: los nested-loops del `$lookup` ahora pegan en
  índice en vez de escanear (celebra: tu reflejo de "indexa la FK" sigue
  siendo correcto);
- y **sigue perdiendo** contra `minijira`, que sirve lo mismo con CERO
  uniones — porque ningún índice elimina los 4 viajes por render, ni el
  trabajo de armar en runtime un documento que el modelo sano ya tenía
  armado en disco.

Números a la tabla de la autopsia. La conclusión, que es el puente a la
autopsia de la Fase 8: **cuando el explain está limpio y sigue lento, el problema ya no
es de índices — es de modelo.** El DBA que solo sabe indexar se queda sin
herramientas exactamente aquí; tú tienes la Fase 3.

---

## 🧩 Chuleta de la fase

```js
createIndex({ a: 1, b: -1 }, { unique, partialFilterExpression, expireAfterSeconds })
getIndexes() / dropIndex("name")
find(...).explain("executionStats")
//   stage: COLLSCAN 🚨 | IXSCAN ✅ | SORT (en memoria) 🤔
//   eficiencia = nReturned / totalDocsExamined

// Compuestos: prefijo izquierdo · regla ESR (Equality, Sort, Range)
// Multikey: arrays y "array.campo" — un solo campo array por compuesto
// Parcial: índice con WHERE · TTL: borrado automático (campo Date o nada)
// Texto: 1 por colección, tokeniza palabras — no es LIKE %..%

// El plan de índices sale del CONTRATO, se verifica con explain,
// y se documenta con sus números. Y: el índice no arregla el modelo.
```

---

## ⚠️ Errores comunes

- Indexar por catálogo ("uno por campo importante") en vez de por consulta
  real del contrato.
- El compuesto al revés (`{ createdAt: -1, status: 1 }` para una consulta
  E+S): prefijo izquierdo desperdiciado, y el explain te lo grita con su
  etapa SORT.
- No mirar `totalDocsExamined`: "usa índice" no es "usa BIEN el índice" (un
  IXSCAN que examina 90k para devolver 20 es un COLLSCAN con corbata).
- Regex insensible o flotante esperando IXSCAN.
- TTL sobre fechas string: no borra, no avisa.
- Unique sin pensar en los documentos sin el campo.
- Crear índices alegremente en una colección de escritura intensa sin medir
  el costo en los inserts (ejercicio 24 lo cuantifica).
- Y el meta-error de la fase: seguir afinando índices cuando el explain ya
  está limpio y lo lento es el modelo.

---

## 🧪 Ejercicios (34)

Base: `minijira` a 100k/400k y `soporte_v1`. Todo índice se justifica con
explain antes/después — sin números no cuenta.

**🟢 Fácil (1–10)**

1. `explain` del listado (`find({status:"open"}).sort({createdAt:-1}).limit(20)`) SIN índices: identifica COLLSCAN, la etapa SORT, y los tres números. Guárdalo: es tu "antes".
2. Crea `{ status: 1, createdAt: -1 }` y repite: ¿IXSCAN? ¿desapareció el SORT? ¿`totalDocsExamined` ≈ `nReturned`?
3. Verifica el prefijo izquierdo: con ese índice, `find({status:"open"})` ¿lo usa? ¿Y `find({createdAt: {$gte: ...}})` solo? Explica con el B-tree.
4. `getIndexes()` en las tres colecciones: inventario inicial (¿qué índice viene gratis siempre?).
5. Crea el índice de comments del plan y verifica la consulta del contrato (`ticketId + sort createdAt`).
6. El unique de `username`: créalo, intenta insertar un duplicado, lee el error `E11000` completo (lo verás en logs de producción toda tu vida).
7. Mide una consulta cubierta: `find({status:"open"}, {status:1, createdAt:1, _id:0})` con el índice del ej. 2. Busca en el explain la señal de covered (`totalDocsExamined: 0`). Tu índice cubriente de siempre.
8. Crea `{ tags: 1 }`, consulta por un tag, y localiza en el explain la marca `isMultiKey: true`.
9. Borra un índice y confirma con explain que la consulta volvió a COLLSCAN. Saber degradar es parte de saber operar.
10. Documenta en `DATA-MODEL.md` el plan de índices con las filas verificadas hasta ahora (índice, consulta, números antes/después).

**🟡 Intermedio (11–20)**

11. ESR completo: "abiertos, ordenados por prioridad, creados en 2020". Diseña el compuesto por la regla, créalo, verifica sort-sin-SORT, y luego **desordénalo a propósito** (R en medio) para ver la degradación en el explain.
12. La dirección importa: `sort({ priority: 1, createdAt: -1 })` — ¿tu compuesto `{priority: 1, createdAt: 1}` lo sirve sin SORT? ¿Y `{priority: 1, createdAt: -1}`? ¿Y el sort espejo exacto? Tabla de las 4 combinaciones.
13. El parcial de la cola del agente: créalo, y compara su tamaño (`db.tickets.stats().indexSizes`) contra la versión no-parcial. ¿Cuánto ahorraste? ¿La consulta `{assignee: "soporte1", status: "in_progress"}` lo usa? ¿Y `{assignee: null}`? (Esa última NO debe — explica por qué está bien que no.)
14. Resuelve el unique-con-nulls: índice único parcial sobre `email` en users (campo que **agregas tú** para el ejercicio — no está en la fixture del contrato — y que no todos tienen). Demuestra: dos sin email conviven; dos con el mismo email, no.
15. TTL en vivo: colección `sessions` con `expireAfterSeconds: 60`, inserta, cronometra su desaparición (recuerda: el monitor pasa cada ~60 s — puede tardar hasta ~2 min). Ahora inserta una con fecha string y demuestra el silencio más caro.
16. `hint()`: fuerza un índice subóptimo en una consulta y compara contra el que el planner eligió. ¿Cuándo usarías hint en producción? (Respuesta corta esperada: casi nunca, y documentado.)
17. **El experimento del 🪞:** la transversal `{"history.by": "soporte1"}` sin índice (COLLSCAN, número gordo) y con `{"history.by": 1}` (multikey). Compara además contra la alternativa "colección separada `ticketEvents` indexada" (constrúyela con un script desde los history): ¿los números le dan la razón a quién?
18. Multikey sutil: tickets con `checklist: [{name, priority: n}]`. ¿`find({"checklist.priority": {$gte: 3, $lte: 5}})` significa "UN elemento en ese rango" o "alguno ≥3 y alguno ≤5"? Demuestra la diferencia con `$elemMatch` y dos documentos trampa. (El bug de rangos multikey de la época.)
19. Compuesto con array: intenta crear `{ tags: 1, "history.by": 1 }` (dos arrays). Lee el error. Ahora `{ status: 1, tags: 1 }` (uno solo): funciona. Documenta la restricción.
20. La comparación `?q=`: regex flotante insensible vs índice de texto en español, sobre 100k. Mide: tiempo, `totalDocsExamined`, y 5 búsquedas semánticamente traicioneras ("impre", "imprime", "IMPRESORA", una palabra con tilde, una frase de dos palabras). Tabla completa.

**🟠 Difícil (21–28)**

21. Cierra la decisión del `?q=`: con la tabla del ej. 20 y la frecuencia estimada del endpoint (invéntala razonablemente y decláralo), escribe en `DATA-MODEL.md` la decisión final con el formato de la Fase 3 (alternativa considerada incluida, y el trigger que la reabriría: "si q supera N req/min…").
22. Covered query estricta para el dashboard: diseña el índice que cubra COMPLETO el listado (todos los campos que la tabla del frontend pinta). ¿Vale la pena el tamaño? Mide índice vs ganancia y decide con números.
23. Los índices que NO creamos: elige 3 candidatos plausibles (p. ej. `{priority: 1}`, `{reporter: 1}`, `{title: 1}`), argumenta por qué no entran al plan (frecuencia, selectividad, redundancia con compuestos existentes) y déjalo escrito. Decir que no también se documenta.
24. El costo de escritura: mide 10.000 inserts en tickets con 0, 3, 6 y 9 índices activos (crea dummies para llegar). Tabula tiempo vs número de índices. ¿Lineal? Es el precio del catálogo que ahora puedes citar.
25. **El villano indexado (parte 1):** crea los 6 índices de foreignFields en `soporte_v1`. Verifica con explain que los `$lookup` del dashboard ahora pegan en IXSCAN (el explain de aggregation de la Fase 5 te dijo qué visibilidad hay).
26. **(parte 2):** re-corre las tres mediciones de la Fase 5 (dashboard, detalle, búsqueda) contra `soporte_v1` indexada Y contra `minijira`. Tabla final de la fase a la autopsia: sin índices / con índices / modelo sano. Escribe la conclusión en una frase que le dirías a tu yo del pasado.
27. Selectividad en carne propia: crea `{ status: 1 }` solo, y compara `find({status: "closed"})` (60% de la base, generador dixit) contra `find({status: "open"})` (20%). ¿El planner usa el índice en ambos? ¿DEBERÍA? Mide IXSCAN vs COLLSCAN forzado con hint para el caso gordo. Tu regla de selectividad de siempre, verificada aquí.
28. El planner cambia de opinión: con dos índices candidatos para la misma consulta, usa explain con `allPlansExecution` para ver los planes rivales y quién ganó. Investiga (doc 4.4) cómo cachea el planner los planes y qué lo hace re-evaluar. ¿Te suena de tu motor anterior?

**🔴 Muy difícil (29–34)**

29. Construye `scripts/index-audit.js`: para cada colección, cruza `getIndexes()` contra `$indexStats` (aggregation stage que cuenta usos) y reporta: índices jamás usados (candidatos a borrar), índices redundantes por prefijo (`{a:1}` cuando existe `{a:1,b:1}`). Córrelo tras una sesión de smoke del proyecto.
30. Paginación profunda, revisited: retoma el ejercicio 23 de la Fase 2 (skip vs range-based) y re-mídelo CON el índice `{createdAt: -1, _id: -1}`. ¿El índice salvó al skip profundo? ¿Por qué el range-based sí lo aprovecha completo? Explica con el B-tree y cierra la recomendación para el contrato (que pagina con `_sort` + límites).
31. El experimento del orden físico: ¿importa el orden de inserción? Genera dos colecciones idénticas, una insertada en orden cronológico y otra en orden aleatorio, mismo índice `{createdAt: -1}`. Mide la consulta del listado en ambas (y mira `totalKeysExamined` vs docs). Investiga qué papel juega la localidad en WiredTiger. Media página de hallazgos honestos (incluido "no encontré diferencia", si es el caso: negativo medido > positivo supuesto).
32. Índice comodín de la época tardía: investiga los wildcard indexes de 4.2+ (`{"$**": 1}`), crea uno sobre una colección con metadatos variables (`meta.*` de la Fase 2, ej. 25), mide contra índices explícitos, y escribe cuándo son herramienta y cuándo son rendición del diseño.
33. El torture de lectura: adapta el `npm run torture` de la Fase 6 para que mezcle las consultas calientes del contrato bajo carga, y corre 3 configuraciones: sin índices, plan del Mini Jira, plan + 6 índices basura. Latencias p50/p95 de cada consulta por configuración. La tabla que demuestra que MÁS índices no es MEJOR.
34. **El ensayo de la fase** (1 página, `INSTINTOS.md`): "El explain limpio que sigue lento". Tesis: el índice optimiza el acceso a un modelo dado; cuando el modelo obliga a N accesos por operación, el índice solo abarata cada uno de los N — y el DBA que no modela se estanca en ese óptimo local. Usa la tabla del villano (ej. 26) como evidencia central. Cierra con tu checklist personal de "cuándo dejo de indexar y empiezo a remodelar" — que es exactamente lo que harás en la Fase 8.

---

## 📚 Referencias

**Documentación oficial (4.4)**

- Indexes (el hub): https://www.mongodb.com/docs/v4.4/indexes/
- Compound Indexes y prefijos: https://www.mongodb.com/docs/v4.4/core/index-compound/
- Multikey Indexes: https://www.mongodb.com/docs/v4.4/core/index-multikey/
- Partial Indexes: https://www.mongodb.com/docs/v4.4/core/index-partial/
- TTL Indexes: https://www.mongodb.com/docs/v4.4/core/index-ttl/
- Text Indexes: https://www.mongodb.com/docs/v4.4/core/index-text/
- `explain` Results (el diccionario del plan): https://www.mongodb.com/docs/v4.4/reference/explain-results/
- `$indexStats`: https://www.mongodb.com/docs/v4.4/reference/operator/aggregation/indexStats/
- Query Plans (el planner y su caché): https://www.mongodb.com/docs/v4.4/core/query-plans/

**La regla ESR (fuentes de época)**

- The ESR (Equality, Sort, Range) Rule — MongoDB docs/blog: https://www.mongodb.com/docs/v4.4/tutorial/equality-sort-range-rule/
- Performance Best Practices: Indexing (serie del blog oficial, 2020): https://www.mongodb.com/blog/post/performance-best-practices-indexing
  (verifica que el ejemplo use sintaxis 4.4; el post se actualiza sin avisar)

**Libros**

- *MongoDB: The Definitive Guide*, 3.ª ed. — cap. 5 (Indexes) y 6 (Special
  Index and Collection Types): el par de capítulos más directamente
  aprovechable del libro para un ex-DBA.

**Video (YouTube)**

- Tips and Tricks for Query Performance — MongoDB World 2019 (busca el
  título; es explain + ESR en 40 min)
- MongoDB Indexing Best Practices — canal oficial MongoDB

**Orden de lectura sugerido para perfil senior:**
explain Results (tu nuevo diccionario, 20 min) → ESR Rule → ejercicios 1–3 y
11–12 (la fase se aprende con el explain abierto) → Multikey (la única
lectura conceptualmente nueva) → el resto de ejercicios → Partial/TTL/Text
como consulta.

---

## 🚀 Cierre

Al final de esta fase, el Mini Jira tiene su plan de índices completo —
derivado del contrato, verificado con explain, documentado con números,
incluidos los índices que decidimos NO crear. Tu experiencia de DBA quedó
validada donde correspondía (compuestos, prefijos, selectividad, costo de
escritura) y ampliada donde hacía falta (multikey, parciales, TTL). Y el
villano recibió su mejor oportunidad: índices perfectos en cada foreignField…
y la tabla final lo condena igual.

La señal de que quedó bien:

> "leo un explain de Mongo con la misma cara que un plan de Oracle, diseño
> compuestos con ESR sin pensarlo — y cuando el explain está limpio y sigue
> lento, ya no busco más índices: busco el modelo".

**Siguiente parada:** ⚰️ Fase 8 — La autopsia. El villano está
medido tres veces y condenado con evidencia. Ahora te toca a ti hacer lo que
harás en la vida real: rediseñarlo, migrarlo y demostrar con números que la
cirugía valió la pena.
