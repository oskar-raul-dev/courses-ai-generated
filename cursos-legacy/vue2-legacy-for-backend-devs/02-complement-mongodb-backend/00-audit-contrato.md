# 📜 El contrato que el backend debe honrar

> **Documento maestro del Curso 02 — MongoDB para cerebros SQL.** El jefe de
> este proyecto no es Mongo ni Express: es el **frontend heredado** (el Mini
> Jira que construye el [Curso 01](../01-vue2-legacy/README.md); se entrega
> hecho y no se toca). Este documento fija qué significa exactamente "cambiar
> el `baseURL` y que no se entere", dónde esa promesa es estricta y dónde pasa
> a ser "el contrato crece, no se rompe".

> 🧭 **Quién manda cuando hay duda: el frontend.** Este contrato no inventa
> nada; **transcribe** lo que el Curso 01 ya hace. Si una cláusula de aquí
> contradice al código de una fase del Curso 01, la equivocada es la cláusula
> — se corrige aquí, no allá. Por eso cada sección dice **dónde verificarla**
> en el otro curso: son afirmaciones comprobables, no acuerdos de palabra.

---

## 🎯 La regla de oro y sus dos regímenes

| Régimen | Fases | Regla |
|---|---|---|
| **Promesa estricta** | 1 → 10 | El frontend cambia **una sola línea** (`baseURL`). Ningún otro archivo se toca. El backend imita a json-server hasta en sus manías. |
| **El contrato crece** | 11 → 15 | Se permiten **extensiones** (endpoints nuevos, códigos de estado nuevos, eventos nuevos). Se prohíben **rupturas** (cambiar la forma de una respuesta existente, renombrar un campo, exigir un header que antes no existía… con una excepción declarada abajo: el login). |

---

## 🔍 Dónde se verifica cada cláusula

Antes de discutir una cláusula, ábrela en su fuente. Todas las rutas son
relativas a este archivo:

| Qué | Fuente de verdad en el Curso 01 |
|---|---|
| `db.json`, endpoints de tickets, `baseURL`, login mock | [`../01-vue2-legacy/03-mock-api-minima.md`](../01-vue2-legacy/03-mock-api-minima.md) |
| Interceptor `Authorization: Bearer`, sesión en `localStorage` | [`../01-vue2-legacy/02-autenticacion-minima.md`](../01-vue2-legacy/02-autenticacion-minima.md) |
| Params del listado (`_sort`, `_order`, `status`) | [`../01-vue2-legacy/04-dashboard-tickets.md`](../01-vue2-legacy/04-dashboard-tickets.md) |
| Forma de las métricas (`utils/ticketStats.js`) | [`../01-vue2-legacy/07-metricas-minimas.md`](../01-vue2-legacy/07-metricas-minimas.md) |
| Sockets: puerto, evento, payload, el "cliente mentiroso" | [`../01-vue2-legacy/08-websockets-minimos.md`](../01-vue2-legacy/08-websockets-minimos.md) |
| `commentService`, `userService` | [`../01-vue2-legacy/09-panel-soporte.md`](../01-vue2-legacy/09-panel-soporte.md) |
| Colección `activity` (solo si se hizo una ruta) | [`q4`](../01-vue2-legacy/q4-timeline-actividad.md) · [`vu4`](../01-vue2-legacy/vu4-timeline-vuetify.md) · [`nx4`](../01-vue2-legacy/nx4-pagina-ssr-nueva.md) |
| Tests que congelan el contrato del lado cliente | [`../01-vue2-legacy/11-testing-minimo.md`](../01-vue2-legacy/11-testing-minimo.md) |

---

## 📡 Dialecto json-server a reimplementar (régimen estricto)

Lo que el frontend heredado consume hoy, con las manías exactas de
json-server 0.16:

| Método | Ruta | Manías a imitar |
|---|---|---|
| GET | `/tickets` | Soporta `?status=`, `?_sort=<campo>`, `?_order=asc\|desc`, `?q=`. Devuelve **array plano**, sin envelope. |
| GET | `/tickets/:id` | 404 **real** si no existe (el frontend lo espera). |
| POST | `/tickets` | Devuelve el ticket creado **con su `id` asignado**, status 201. |
| PATCH | `/tickets/:id` | Merge parcial. Devuelve el **ticket completo actualizado**. |
| DELETE | `/tickets/:id` | Devuelve `{}` con 200 (manía de json-server; se imita). |
| GET | `/users` | Soporta `?role=agent`. Array plano. |
| GET | `/comments` | Soporta `?ticketId=X`, `?_sort=createdAt` y `?_order=asc\|desc`. El `commentService` del frontend manda los tres. Array plano. |
| POST | `/comments` | Devuelve el comentario con `id`, status 201. |

**Reglas de forma (todas las respuestas):**

- JSON plano, **sin envelope** (`{ data: [...] }` está prohibido: la capa de
  servicios del frontend devuelve `res.data` y espera el recurso directo).
- Fechas como **string ISO 8601** (`"2020-03-10T10:00:00Z"`), nunca objetos
  `Date` serializados de otra forma ni timestamps numéricos.
- Los cuerpos de error pueden ser mejores que los de json-server (que devuelve
  `{}`): el frontend **no depende** del cuerpo de un error, solo del status.
  Aquí tenemos libertad.

### 🚧 Lo que el contrato NO incluye (y por qué importa saberlo)

Tan importante como la lista de arriba es lo que **no** está en ella. El
frontend del tronco (F0–F11) nunca lo pide, así que implementarlo es
sobre-ingeniería, no fidelidad:

- **Paginación server-side.** El dashboard trae todos los tickets y filtra en
  cliente. `?_page=` / `?_limit=` no se usan… **salvo si el alumno hizo la
  ruta Q o VU** — ver la sección dedicada más abajo.
- **`?priority=` como parámetro.** La prioridad se pinta como badge y se filtra
  en cliente; nunca viaja como query param.
- **`GET /users/:id`.** El frontend trae la lista entera y resuelve el username
  en memoria.
- **`GET /comments/:id`, `PATCH` o `DELETE` de comentarios.** Solo se listan y
  se crean.
- **Envelope, HATEOAS, metadatos de respuesta.** Array plano o recurso, nada
  más.

Y el que más sorprende: **no hay endpoint de login.** El `authService` heredado
resuelve las credenciales **en el navegador** contra un `MOCK_USER` y fabrica
el string `"mock-jwt-token-123"`. Por eso `POST /auth/login` es una *ruptura*
pactada y no una extensión: no está reemplazando un endpoint, está creando el
primero.

### La manía `?q=` (alcance acotado)

json-server busca `q` en **todos los valores** del recurso. Decisión: nuestro
backend busca solo en `title` y `description` (los únicos campos de texto
visibles donde el usuario buscaría). Es una **desviación declarada y
aceptable**: el comportamiento observable desde la UI es idéntico. Bonus
didáctico: en la Fase 7 esta búsqueda motiva el índice de texto vs `$regex`.

---

## 🆔 La decisión más importante: `id` vs `_id`

**El problema.** json-server sirve `id` numérico (`1, 2, 3…`). Mongo trae
`_id: ObjectId("5f8a...")`. El frontend usa `id` en rutas (`/tickets/:id`),
payloads y comparaciones.

**Opciones consideradas:**

1. ❌ **Ids numéricos autoincrementales en Mongo** (colección de contadores).
   Reproduce el instinto SQL de la secuencia, agrega un punto de contención en
   cada insert, y es exactamente el anti-patrón que el curso combate. Solo se
   menciona para descartarlo con argumentos (ejercicio de la Fase 1).
2. ✅ **ObjectId interno, mapeo en la frontera.** La base usa `_id: ObjectId`
   como Mongo manda. La capa API (controller) **serializa `_id` → `id`
   (string hex)** en cada respuesta y **traduce `:id` → ObjectId** en cada
   entrada. La base habla Mongo; la API habla el contrato.

**Riesgo declarado 🎯:** el `id` pasa de *número* a *string hex*. Los params de
ruta ya son strings, así que la navegación sobrevive. Pero si en algún punto
el frontend hace una comparación con casteo numérico (`Number(id)`) o un `===`
entre número y string, **ahí se rompe**. Mitigación:

- **Smoke test manual obligatorio** al final de la Fase 10 (checklist abajo).
- Si algo se rompe por esto, se clasifica como **bug latente del frontend
  heredado** (dependía de un detalle de implementación del mock, no del
  contrato) y su arreglo puntual **no cuenta como romper la promesa** — pero
  se documenta.

---

## 🔌 Sockets (régimen estricto → crece en Fase 12)

- Mismo servidor lógico en `:4000` (el puerto que hoy escucha el cliente),
  **socket.io 2.4** — la versión importa: 2.x y 3.x no se hablan.
- Mismo nombre de evento: `ticket:created` (y `ticket:updated` /
  `ticket:deleted` cuando se activen).
- **Misma forma del payload** que hoy emite el propio cliente (el "cliente
  mentiroso" heredado: quien crea el ticket emite el evento).
- El cambio de la Fase 12 es **quién emite** (el servidor tras persistir), no
  **qué** se emite. El frontend escucha lo mismo y no distingue. Muere el relé
  tonto sin funeral visible.
- Si el alumno hizo una ruta, hay un cuarto evento: `activity:created`, con la
  misma mecánica y la misma migración de emisor (ver la sección de `/activity`
  más abajo).

> ⚠️ **El nombre del evento es `activity:created`, no `activity:new`.** El
> Curso 01 llegó a usar las dos formas en distintas rutas; la convención
> `recurso:acción` de la guía de estilo (§5.4) resuelve a favor de
> `activity:created`, y así quedó unificado en las tres.

---

## 📈 Extensiones pactadas (régimen "el contrato crece")

| Extensión | Fase | Tipo |
|---|---|---|
| `POST /auth/login` → `{ token, user }` con JWT real | 11 | ⚠️ **La excepción declarada:** el login mock del frontend heredado es client-side; conectarlo exige tocar una función de su `authService.js`. Es la única ruptura admitida, se anuncia con nombre y apellido, y el frontend ya dejó el terreno preparado (el login ya devuelve una Promise). |
| `401` en cualquier endpoint con token inválido/ausente | 11 | Extensión. Si el frontend tiene interceptor de respuesta lo aprovecha; sin él, el usuario ve errores genéricos — feo pero no roto. |
| `403` por rol insuficiente | 11 | Extensión. |
| `409` en el doble "tomar" (update condicional falló) | 6/11 | Extensión. El PATCH del frontend recibe un error donde antes recibía un éxito silencioso mentiroso. El manejo fino es ejercicio. |
| `GET /stats` (agregaciones server-side) | 9 | Endpoint nuevo, ya previsto por el contrato heredado como pendiente. ⚠️ **Su forma NO es libre:** `byStatus`, `activeByAgent` y `resolvedPercent` replican exactamente las tres funciones puras de `utils/ticketStats.js` (Curso 01 · F7), porque el ejercicio 25 de esa fase exige poder hacer fallback al cálculo local. Ver la tabla de abajo. |
| `POST /attachments` (multipart) + `GET /attachments/:id/download` | 12 | Endpoint nuevo, ya previsto como pendiente. La ruta de descarga la fija el frontend: el apéndice de axios del Curso 01 ya la escribe así, con `responseType: "blob"`. Los adjuntos **no** son feature del tronco (viven en ese apéndice y como draft local del wizard), así que no hay más forma heredada que honrar. |
| Server emite los sockets | 12 | Cambio de emisor, no de contrato. |
| `?_page` / `?_limit` + header `X-Total-Count` (con `Access-Control-Expose-Headers`) | 10 | Extensión, **exigida solo si el alumno hizo la ruta Q o VU** (Q3 / VU3 migran el dashboard a una tabla con paginación server-side). Ver la sección dedicada abajo. |
| `GET /activity?ticketId=X&_sort=at&_order=desc` + `POST /activity` + evento `activity:created` | 12 | Endpoint nuevo, **exigido solo si el alumno hizo una ruta** (Q4 / VU4 / NX4 del Curso 01 añaden la colección `activity` al `db.json`). Ver la sección dedicada abajo. |

### 📊 La forma de `GET /stats` (la fija el frontend)

Las tres primeras claves son espejo literal de `utils/ticketStats.js`; el resto
son extensiones que el cliente nunca calculó:

| Clave | Forma | Origen |
|---|---|---|
| `byStatus` | `{ open: 5, in_progress: 3, … }` — **objeto** indexado por estado | `countByStatus()` |
| `activeByAgent` | `[{ agent, count }]` desc, solo `open`+`in_progress`, con bucket `"(sin asignar)"` | `activeByAgent()` |
| `resolvedPercent` | entero, `Math.round` | `resolvedPercent()` |
| `byPriority` | `{ high: 4, … }` — objeto, por simetría con `byStatus` | extensión |
| `byAgent` | `[{ agent, count }]` histórico completo, sin bucket | extensión |
| `resolution` | `{ avgHours, maxHours, tickets }` o `null` | extensión (usa `history`) |

**Regla:** conteo por campo → objeto indexado; ranking ordenado → array.

### 📄 Paginación server-side: solo si hiciste la ruta Q o VU

Q3 (`QTable`) y VU3 (`v-data-table`) migran el dashboard a la tabla del
framework, y esa tabla trae paginación server-side de fábrica. A partir de ahí
el frontend **sí** manda `_page` y `_limit`, y **espera el total en un header**:

| Qué | Valor |
|---|---|
| Query params extra en `GET /tickets` | `?_page=<n>&_limit=<n>` (además de los del régimen estricto) |
| Total de registros | Header de respuesta `X-Total-Count` (manía de json-server) |
| Dónde lo consume | `rowsNumber` en Quasar (Q3) · `serverItemsLength` en Vuetify (VU3) |

> ⚠️ **La trampa de CORS que se lleva una tarde.** Aunque tu Express mande
> `X-Total-Count`, el navegador **no deja al JavaScript leerlo** si no lo
> declaras expuesto: `Access-Control-Expose-Headers: X-Total-Count`. El síntoma
> es cruel — el header se ve perfecto en la pestaña Network y
> `response.headers["x-total-count"]` devuelve `undefined`. Las propias fases
> Q3 y VU3 avisan de esto desde el lado cliente; el backend es quien lo
> arregla.

> 🧭 **Alcance.** Igual que `/activity`: si el alumno terminó en F11, su tabla
> pagina en cliente y esto no se implementa. Si hizo Q o VU, es obligatorio o
> la tabla queda con una sola página. La ruta NX no lo necesita (no cambia de
> tabla). Es extensión de la Fase 10 y **no** entra en su smoke test base.

### 🕒 `/activity`: la colección que solo existe si hiciste una ruta

Las fases X4 de las tres rutas (Q4, VU4, NX4) añaden al `db.json` una colección
`activity` y la consumen así:

| Método | Ruta | Forma |
|---|---|---|
| GET | `/activity?ticketId=X&_sort=at&_order=desc` | Array plano de `{ id, ticketId, type, actor, from, to, at }` |
| POST | `/activity` | Devuelve el documento con su `id`, status 201 |
| socket | `activity:created` | El payload es el documento guardado |

`type` toma hoy `"status_change"` y `"assigned"`; el frontend **degrada con
elegancia** ante un tipo desconocido (lo dice Q4 §4), así que añadir
`"reopened"` o `"commented"` es extensión, no ruptura. El campo `at` es ISO
string, igual que `createdAt`.

> 💸 **La deuda que el frontend declaró y este contrato hereda:** en las rutas,
> el evento lo produce y postea **el cliente**, con el reloj del cliente. Es la
> misma muleta que el "cliente mentiroso" de F8, y se paga en el mismo lugar:
> Fase 12, cuando el servidor pase a registrar y emitir.

> 🧭 **Alcance.** Si el alumno no hizo ninguna ruta, `/activity` no existe en su
> frontend y este endpoint no se implementa. Por eso vive como extensión
> opcional de la Fase 12 y **no** entra en el smoke test de la Fase 10.

---

## 🌱 Semilla de datos

El `db.json` heredado es la **fixture oficial**. La Fase 1 lo importa a Mongo
con un script de seed que:

1. convierte cada `id` numérico en un `ObjectId` nuevo,
2. **retraduce las referencias** (`comments.ticketId` debe apuntar al ObjectId
   nuevo del ticket, no al número viejo — primer contacto con "la integridad
   referencial ahora es tu problema"),
3. convierte fechas string → `Date` de BSON (y la API las devuelve como ISO;
   ida y vuelta declarada).

Este script no es plomería: es el **primer ejercicio de paradigma** del curso.

> ⚠️ **La fixture viene con referencias rotas, y es a propósito que no las
> arreglamos en silencio.** Los tickets 2 y 3 tienen `assignee: "soporte2"` y
> `reporter: "usuario2"` / `"usuario3"`, usernames que **no existen** en el
> array `users`. json-server jamás se quejó porque no sabe qué es una
> referencia. Al importar a Mongo, la decisión es tuya y hay que **declararla**
> en `DATA-MODEL.md`: ¿las conservas tal cual (fidelidad al legacy, y el
> `$lookup` de la Fase 5 devolverá arrays vacíos), o las saneas creando los
> usuarios faltantes (base limpia, pero ya no reproduces el sistema real)?
> Ambas son defendibles; lo que no es defendible es no haberte dado cuenta.

---

## ✅ Smoke test de la promesa (checklist de la Fase 10)

Con json-server apagado y `baseURL` apuntando al Express:

- [ ] Login mock entra y el dashboard carga tickets
- [ ] Búsqueda (`?q=`) y filtros por status funcionan
- [ ] Orden por columna (`_sort`/`_order`) funciona
- [ ] Detalle de ticket carga; un id inexistente da la vista de 404
- [ ] Crear ticket (form y wizard) → aparece con id asignado
- [ ] Editar, tomar, cambiar estado, eliminar → la UI refleja el resultado
- [ ] Comentarios: listan ordenados y se crean
- [ ] Las métricas del dashboard siguen calculando en cliente sin errores
- [ ] *(si ya montaste `/stats`)* su respuesta es **idéntica** a lo que devuelven las funciones puras del cliente sobre los mismos datos
- [ ] Recarga de página con sesión activa: todo lo anterior sobrevive
- [ ] `git diff` del frontend: **exactamente una línea**
