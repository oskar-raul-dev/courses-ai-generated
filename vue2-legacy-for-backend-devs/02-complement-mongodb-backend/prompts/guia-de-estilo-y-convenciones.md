# ✍️ Guía de estilo, tono y convenciones
## Curso Vue 2 Legacy (Track A) + MongoDB para cerebros SQL (Track B)

Esta guía es la fuente de verdad editorial de **ambos tracks**. Cualquier chat
que produzca un `.md` la sigue. Su objetivo: que las decenas de documentos de
los dos cursos se lean como escritos por la misma mano, orientados a la
práctica de mantenimiento de un sistema real.

Los dos cursos comparten un único dominio pedagógico —**Mini Jira**, una mesa
de soporte interna— y por eso comparten esta guía y un único
`DICCIONARIO-CODIGO.md`. Track A construye el frontend (Vue 2, época
2018–2021); Track B construye el backend real (MongoDB 4.4 + Express/Node 14)
que reemplaza al mock sin que el frontend se entere.

> 🧭 **Regla de una línea que rige todo el código:** el **código en inglés**;
> todo lo demás —narrativa, comentarios, textos de interfaz— **en español**.
> El detalle completo está en §4 y el diccionario operativo de términos del
> dominio en `DICCIONARIO-CODIGO.md`.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien arregle un sistema real sin
romperlo.** No enseñamos Vue "bonito" ni MongoDB "de moda". Enseñamos a leer,
entender, reproducir, corregir y prevenir. Si un párrafo no ayuda a
diagnosticar, depurar o arreglar, sobra.

El norte compartido de ambos tracks es una sola señal de éxito: **cambiar el
`baseURL` del frontend y que la aplicación no se entere.** Track A deja el
frontend viviendo de un mock (json-server); Track B lo reemplaza por un
backend real que honra el mismo contrato (`AUDIT-CONTRATO.md`). Todo lo que
escribimos sirve a esa promesa.

---

## 2. Tono

El tono es **cálido, informal y directo** — de colega senior a colega senior,
con humor cuando cae bien. No es un manual acartonado: es alguien que ya
sufrió este código explicándotelo con confianza y sin solemnidad.

- **Segunda persona, cercana.** Háblale al lector de "tú": "apaga json-server y verás el error", "si el `$lookup` te tienta, primero medí".
- **Humor seco permitido.** Un 😉, un chiste sobre "20 minutos debuggeando el frontend cuando el mock estaba apagado", un 🪦 para jubilar código. El humor desdramatiza la fricción del legacy, no rellena.
- **Honesto sobre lo feo.** Cuando algo es horrible (y en legacy lo es a menudo), se dice con gracia: "este patrón es horrible pero está en producción y así se lee". No se finge elegancia. Track B lleva esto a un caso central: el anti-patrón `soporte_v1` es feo a propósito y se lo nombra sin piedad.
- **Orientado a la duda real.** Anticipa "¿y esto por qué está así?" y respóndela, muchas veces con una **nota de época** (📝) que da contexto histórico.
- **Cercanía sin condescendencia.** El lector es senior. En Track A no le expliques HTTP, JSON ni tokens. En Track B no le expliques qué es un índice, una transacción o el plan de una query: **lo sabe de SQL**. Lo nuevo es cómo cambia (o no) en Mongo.

Evitar: promesas vacías ("vas a dominar Vue"/"Mongo lo resuelve todo"),
motivación de coach, solemnidad de manual corporativo, y explicar lo obvio
para el perfil. El humor es condimento, no plato principal.

> 🧠 **Matiz propio de Track B (el eje del curso).** El lector no llega en
> blanco: llega con 10 años de instintos relacionales. El tono reconoce esos
> instintos y los interpela de frente con dos micro-secciones recurrentes
> (§7.4): 🪞 *"tu instinto SQL dice… y esta vez se equivoca"* y 🩻 *"esto sí
> funciona igual"*. Nunca se ridiculiza el instinto SQL: se lo honra y se lo
> recalibra.

---

## 3. Idioma y forma (narrativa)

- Español claro y técnico para todo lo que **no** es código (títulos, explicaciones, ejercicios, referencias). Los términos del stack se dejan en inglés cuando son el nombre real: *store*, *mutation*, *action*, *getter*, *slice de estado*, *watcher*, *computed*, *mixin*, *pipeline*, *aggregation*, *replica set*, *index*, *sharding*, *race condition*, *N+1*. No se traducen forzadamente.
- Markdown siempre.
- Encabezados con emoji **con moderación** — uno por sección de plantilla. Los subtítulos internos pueden llevar emoji-tipo (§7) cuando aporta lectura rápida.
- **Prosa antes que listas.** Se prefiere explicar razonando en párrafos. Las listas se usan cuando son de verdad una lista (pasos, ítems paralelos).
- **Tablas solo para comparar, decidir o mapear.** "Cuándo usar X vs Y", matrices de decisión, mapeos versión-a-versión, tablas de opciones/directivas, y —muy importante en Track B— **tablas de traducción SQL ↔ Mongo** (§7.4). No para narrar.

---

## 4. Idioma del código fuente (código en inglés, curso en español)

Esta sección es normativa para **todo** fragmento de código de ambos cursos,
sea en el cuerpo de una fase, en un incidente, en un apéndice o en un
ejercicio resuelto.

### 4.1 Regla general

| Capa | Idioma | Ejemplo |
|---|---|---|
| **Código fuente** (identificadores) | 🇬🇧 Inglés | `function takeTicket(id) {}`, `const isLoading = false` |
| **Endpoints y rutas** | 🇬🇧 Inglés | `/tickets`, `/tickets/:id/comments`, `/auth/login` |
| **Constantes y enums internos** | 🇬🇧 Inglés | `status: 'open'`, `SET_LOADING`, `POLLING_INTERVAL_MS` |
| **Colecciones y campos de Mongo** | 🇬🇧 Inglés | `db.collection('tickets')`, `{ assignee, reporter, createdAt }` |
| **Nombres de archivo, componente, módulo Vuex, servicio** | 🇬🇧 Inglés | `TicketForm.vue`, `ticketsModule`, `ticketService`, `tickets.service.js` |
| **Comentarios de código** | 🇪🇸 Español | `// el ticket nace 'open': regla de negocio, no del form` |
| **Textos de interfaz (UI)** | 🇪🇸 Español | `<button>Tomar ticket</button>`, `"Cargando tickets…"` |
| **Narrativa del tutorial** | 🇪🇸 Español | Todo el texto fuera de bloques de código |

La app pedagógica **no tiene i18n**: es una app en español para usuarios de
habla hispana. Por eso los textos que ve la persona usuaria —labels, botones,
mensajes de alerta, placeholders— se escriben en español. Lo que va en inglés
es el código que lee y mantiene el equipo: nombres de función, variable,
componente, módulo, acción, mutation, endpoint, colección, campo y constante.

> 📝 **Por qué esta regla.** El código de un sistema real mantenido por un
> equipo técnico suele estar en inglés (con comentarios en español, igual que
> acá). Escribir el pedagógico así hace que el vocabulario de identificadores
> sea el mismo que la persona va a encontrar en producción — y que un track y
> el otro nombren lo mismo de la misma forma (`ticket` es `ticket` en Vue, en
> Express y en Mongo).

### 4.2 Qué se traduce y qué no (criterio rápido)

| Elemento | ¿Inglés? | Ejemplo |
|---|---|---|
| `function`, `const`, `let` (nombre) | ✅ Sí | `function getTickets()` |
| Datos/props/computed/`data()` de un componente | ✅ Sí | `this.form.assignee`, `<ticket-form :initial-ticket="…" />` |
| Endpoints (`ticketService.get(...)`, rutas Express) | ✅ Sí | `apiClient.get('/tickets')`, `router.patch('/tickets/:id')` |
| Módulos Vuex, mutations, actions, getters | ✅ Sí | `namespaced: true`, `SET_TICKETS`, `fetchTickets`, `currentUser` |
| Colecciones, campos y valores de enum de Mongo | ✅ Sí | `collection('comments')`, `status: 'in_progress'` (no `'en_progreso'`) |
| Nombres de componente/archivo/servicio/capa | ✅ Sí | `TicketsTable.vue`, `ticketService.js`, `tickets.controller.js` |
| Clases CSS/Sass propias del proyecto | ✅ Sí | `.ticket-card`, no `.tarjeta-ticket` (las de Bootstrap ya vienen en inglés) |
| `data-testid` | ✅ Sí (para que combine con el código) | `data-testid="ticket-row"` |
| Comentarios `//`, `/* */`, `<!-- -->` | ❌ No | `// valida antes de confiar en res.data` |
| Strings de interfaz (lo que ve el usuario) | ❌ No | `"Tomar ticket"`, `"No hay tickets todavía…"` |
| Mensajes de error legibles para el usuario | ❌ No | `{ message: 'No se pudo cargar el ticket' }` — la **key** en inglés, el **valor** en español |
| Nombres del dominio de negocio en la narrativa | ❌ No | El texto sigue hablando de "ticket", "comentario", "agente", "reportador" |

> ⚠️ **Caso mixto frecuente — mensajes de error y etiquetas de estado.** El
> objeto usa keys en inglés (`{ message, type }`), pero el **valor** de
> `message` que ve el usuario va en español: `{ message: 'El servidor no
> respondió a tiempo', type: 'timeout' }`. Igual con el mapeo de estado a
> etiqueta: la **clave** es el enum en inglés, el **valor** es lo que ve el
> usuario en español. Este mapeo es real y vive en Track A:
>
> ```js
> // components/tickets/statusMeta.js  (Track A)
> export const STATUS_META = {
>   open:        { label: 'Abierto',     css: 'badge-danger' },
>   in_progress: { label: 'En progreso', css: 'badge-warning' },
>   resolved:    { label: 'Resuelto',    css: 'badge-success' },
>   closed:      { label: 'Cerrado',     css: 'badge-secondary' }
> };
> ```
>
> La clave (`open`) es el enum que viaja por la API y vive en Mongo; el
> `label` (`'Abierto'`) es UI y va en español. **Nunca** guardes `'Abierto'`
> como valor de `status` en la base o en el payload.

### 4.3 Diccionario del dominio (Mini Jira)

El diccionario completo y jerarquizado —entidades, estados, roles, campos,
verbos de negocio, jerga de Vue y jerga de Mongo/Express— vive en
`DICCIONARIO-CODIGO.md`. Como referencia mínima, los términos centrales:

| Español (dominio, narrativa, UI) | Inglés (código) |
|---|---|
| ticket / tickets | `ticket` / `tickets` |
| comentario | `comment` |
| usuario | `user` |
| adjunto | `attachment` |
| agente / reportador | `agent` / `reporter` (roles) |
| abierto → en progreso → resuelto → cerrado | `open` → `in_progress` → `resolved` → `closed` |
| baja / media / alta (prioridad) | `low` / `medium` / `high` |
| asignado (a) | `assignee` |
| reportado por | `reporter` |
| tomar (un ticket) | `take` |
| asignar / resolver / cerrar / reabrir | `assign` / `resolve` / `close` / `reopen` |

Los nombres de componentes, módulos, servicios, actions y controllers se arman
combinando estos términos con los verbos técnicos habituales (`get`, `fetch`,
`create`, `update`, `delete`, `take`, `assign`) — ver ejemplos completos en el
diccionario.

### 4.4 Convenciones de nombrado

**Comunes a ambos tracks**

- **Funciones y variables:** `camelCase` en inglés — `takeTicket`, `isTicketOpen`, `createdAt`.
- **Constantes de configuración:** `SCREAMING_SNAKE_CASE` — `POLLING_INTERVAL_MS`, `MAX_UPLOAD_BYTES`.
- **Endpoints REST:** sustantivo en plural, inglés — `/tickets`, `/tickets/:id/comments`, `/stats`.
- **Valores de enum/status:** inglés, `snake_case` si son compuestos — `in_progress` (no `inProgress` ni `en_progreso`).

**Track A (Vue 2)**

- **Componentes:** `PascalCase` en inglés — `TicketsTable`, `TicketForm`, `SaleWizard`→`TicketWizard`, `StatusBadge`.
- **Archivos de componente:** mismo nombre que el componente, `.vue` — `TicketForm.vue`. En template kebab-case: `<ticket-form>`.
- **Módulos Vuex:** `<dominio>Module` o el namespace corto en inglés — `ticketsModule`, namespaces `'tickets'`, `'auth'`, `'ui'`, `'comments'`.
- **Mutations:** `SCREAMING_SNAKE_CASE` en inglés — `SET_TICKETS`, `SET_LOADING`, `UPSERT_TICKET`, `CLEAR_SESSION`.
- **Actions:** verbo + dominio, `camelCase` — `fetchTickets`, `createTicket`, `takeTicket`, `login`.
- **Getters:** sustantivo o `is/can` — `currentUser`, `openTickets`, `canTransition`.
- **Servicios:** `<dominio>Service` — `ticketService`, `authService`, `commentService`, `socketService`, `userService`, `attachmentService`, `statsService`.

**Track B (Mongo/Express)**

- **Colecciones:** sustantivo plural en inglés — `tickets`, `users`, `comments`, `attachments`.
- **Campos de documento:** `camelCase` en inglés — `title`, `description`, `status`, `priority`, `assignee`, `reporter`, `createdAt`, `updatedAt`, `schemaVersion`, `history`.
- **Capas del backend:** `<dominio>.<capa>.js` en inglés — `tickets.routes.js` → `tickets.controller.js` → `tickets.service.js`; helpers en `lib/` (`lib/serializers.js`, `lib/jwt.js`), `middleware/auth.js`, `realtime/io.js`.
- **Eventos de socket:** `recurso:acción` en inglés — `ticket:created`, `ticket:updated`, `ticket:deleted` (los tres del contrato; cualquier otro se declara como extensión, ver `AUDIT-CONTRATO.md`).
- **Índices:** el nombre autogenerado de Mongo o uno explícito en inglés — `status_1_createdAt_-1`.

### 4.5 Lo que nunca cambia

- **Comentarios de código:** 100% español, explicando el porqué (§5).
- **Textos de interfaz de usuario:** 100% español — labels, botones, placeholders, mensajes de alerta, `alt`, `title` de tooltips, y los `label` de los mapeos de estado/prioridad.
- **Narrativa del tutorial:** 100% español.
- **Nombres propios del dominio en la narrativa:** "ticket", "comentario", "agente", "reportador" siguen siendo las palabras con que *hablás* del sistema, aunque el código diga `ticket`, `comment`, `agent`, `reporter`.

### 4.6 Ajuste de fases ya escritas

Las fases y apéndices ya entregados que usen identificadores en español se
ajustan fase por fase, en el orden en que fueron escritos:

1. Aplicar `DICCIONARIO-CODIGO.md` a cada bloque de código.
2. Verificar consistencia con lo ya ajustado y **entre tracks** (si Track A llama a la action `takeTicket`, Track B expone la operación como `takeTicket`/`PATCH /tickets/:id` coherente; no aparece `tomarTicket` en ningún lado).
3. Dejar intactos comentarios, narrativa y textos de UI.
4. Revisar ejercicios y referencias que citen nombres de código.
5. Marcar el archivo como ajustado en la matriz de verificación (`DICCIONARIO-CODIGO.md` §6).

No se reescribe la explicación ni la pedagogía: es un cambio de
identificadores, no de contenido.

> ⚖️ **La excepción del villano — `soporte_v1` (Track B).** El anti-patrón
> `soporte_v1` de las fases 3, 5, 7 y 7.5 es una base "migrada a Mongo
> transcribiendo el esquema relacional tabla por tabla". **Decisión de estilo
> (queda fijada acá):** el villano **también se normaliza a inglés** —
> `statuses`, `priorities`, `users`, `comments`, `statusId`, `assigneeId`,
> `reporterId`— para no confundir dos problemas independientes: *"está en
> español"* y *"está mal diseñado"*. Un esquema en inglés puede ser igual de
> Postgres-disfrazado. El **olor** del villano se mantiene por sus decisiones,
> no por su idioma: lookup-tables de ≤10 documentos con forma
> `{_id numérico, name}`, FKs enteras que nadie valida, siete colecciones para
> lo que el buen modelo resuelve en una o dos. El "detector de traducido-no-
> diseñado" (ejercicio de la Fase 3) huele **estructura**, no idioma — y así
> es más honesto. (Si en algún ejemplo el español agrega valor histórico
> genuino, se admite en un comentario 📝 de nota de época, nunca en los
> identificadores.)

---

## 5. Orientación a la práctica

Cada concepto se ancla en el dominio de Mini Jira y en código que corre.

- **Nada de teoría suelta.** Si se explica `findOneAndUpdate` con precondición, se explica sobre el doble "tomar" de un ticket, no en abstracto. Si se explica un `watcher` de Vue, es sobre el filtro de estado del dashboard.
- **Código ejecutable y coherente.** Todo fragmento corre con las versiones fijadas (§stack de cada track) y no contradice fases anteriores ni al otro track. Nada de pseudocódigo que "se entiende".
- **Código mínimo.** El fragmento más pequeño que muestra el punto, pero ejecutable.
- **Comentarios que explican el porqué, no el qué, siempre en español.** `// la precondición va en el filtro: si otro agente ya lo tomó, matchea 0 docs` sí; `// incrementa i` no.
- **Distinguir capas.** Siempre queda claro si un comportamiento vive en el componente Vue, en el store (Vuex), en el servicio HTTP, o —en Track B— en la ruta, el controller, el service o el propio Mongo. Es la distinción que salva al que depura.

---

## 6. Manejo del código legacy (el corazón de ambos cursos)

- **No modernizar automáticamente.** Si el módulo real de Track A es un componente con Options API y `this.$store`, se muestra así. No se "mejora" a Composition API ni a `<script setup>` salvo en una fase o ejercicio 🔥 marcado. En Track B, se usa el **driver nativo** primero y **Mongoose** recién cuando el curso lo introduce (Fase 10): "primero a mano, después el wrapper".
- **Estilos legacy conviven.** Options API y algún patrón viejo de Vuex conviven; se enseña a leer código mezclado sin marearse.
- **Corrección mínima vs refactor.** Ante un fix, se distingue el parche mínimo (lo que va en un hotfix) de la refactorización (lo que iría en otro momento, con más pruebas).
- **El idioma del código (§4) no es negociable ni en código legacy "feo".** Un módulo viejo y mal escrito se muestra viejo y mal escrito, pero con identificadores en inglés. La fealdad que se enseña es de arquitectura y decisiones, no de idioma (ver la excepción documentada del villano en §4.6).

### Convenciones de código concretas

- **Track A:** métodos de componente como funciones nombradas en `methods`; arrow functions en callbacks. `v-model.trim` donde aplique. Fechas con timezone explícito; nunca `new Date()` sin considerar TZ.
- **Track B:** dinero (si apareciera) en enteros, nunca floats. Fechas como `Date` de BSON en la base y **ISO string** en la frontera de la API (lo exige el contrato). Promesas siempre atrapadas (el `asyncHandler` del Apéndice 3 existe por esto).
- Identificadores, endpoints, colecciones y constantes en inglés (§4); comentarios y textos de UI en español (§4.5).

---

## 7. Marcadores y callouts (vocabulario visual de ambos cursos)

Este vocabulario se usa igual en todos los documentos para que el lector lo
reconozca de un vistazo.

### 7.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Todo shortcut o patrón feo que se deja a propósito. Se **declara** en una fase y se **paga** explícitamente en otra (§7.3). Ejemplos vivos: el "cliente mentiroso" que emite el socket (Track A) se paga cuando el servidor emite (Track B, Fase 11); el doble "tomar" sin candado se paga con la precondición en el filtro (Track B, Fase 6).
- 🔥 **Opcional / ampliación.** Ejercicios o secciones que exceden el alcance base.
- ⭐ **Fase o pieza central.** En Track B, las fases 3 y 6; en Track A, las de CRUD y wizard.
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil / intermedio / difícil / muy difícil.

### 7.2 Callouts en blockquote (emoji-tipo)

Se usan como blockquotes cortos para marcar el *tipo* de nota:

- 📝 **Nota de época.** Contexto histórico de un patrón feo o una decisión de versión. Ej: "en 2019 mucha gente 'migró a Mongo' transcribiendo tablas; así nació `soporte_v1`."
- 📚 **Referencia rápida inline.** Un enlace útil justo donde surge la duda, sin esperar a la sección de referencias.
- 🪦 **Retiro / jubilación.** Cuando algo cumple su función y se retira. Ej: "🪦 Se apaga json-server: el mock ya cumplió."
- ⚠️ **Advertencia.** Algo que rompe si lo ignorás (versión incompatible, socket.io 2.x vs 3.x, `id` numérico vs string hex del contrato).
- 💡 **Truco o atajo** que ahorra tiempo real.

### 7.3 Secciones narrativas recurrentes (comunes)

- **💸 Pago de deuda.** Donde una deuda declarada antes se salda. Se nombra qué deuda era, de qué fase venía, y se muestra el cambio.
- **Detalles con intención.** Lista corta que destila las decisiones deliberadas de un bloque ("devolvemos `res.data`, no la respuesta cruda de axios, porque el componente no debería conocer la forma de axios").
- **El patrón a memorizar.** Una o dos frases que extraen la lección transferible.
- **Prueba de fuego.** Verificación manual concreta incrustada en el flujo: "apaga json-server, apunta el `baseURL` al Express, recarga: el dashboard carga igual."
- **Mini-repaso.** Cuando una fase usa sintaxis que el lector quizá no domina (JSX no aplica acá; sí `computed`/`watch` de Vue para un backend dev, o el pipeline de aggregation para alguien que viene de SQL), un repaso exprés en tabla antes del código, con su 📚.
- **La señal de que quedó bien.** En el cierre, un criterio en forma de cita: "si mañana me cambian el mock por el backend real, solo toco el `baseURL` y ninguna vista se entera."

### 7.4 Secciones propias de Track B (SQL → Mongo)

Estas cuatro son la columna vertebral del track de MongoDB y aparecen cuando el
contenido lo pide:

- **📖 Tabla de traducción SQL ↔ Mongo.** Lado a lado, la consulta relacional y su equivalente MQL. Ej: `SELECT * FROM tickets WHERE status='open'` ↔ `db.tickets.find({ status: 'open' })`. Es tabla (§3), no prosa.
- **🪞 "Tu instinto SQL dice… y esta vez se equivoca."** Nombra la trampa **antes** de caer: el `$lookup` que parece un JOIN gratis, la transacción multi-documento como moneda corriente, el `_id` numérico autoincremental. Honra el instinto y lo recalibra.
- **🩻 "Esto sí funciona igual."** Lo reconfortante: índices, selectividad, `explain()`, el N+1 siguen valiendo exactamente lo que valían en SQL. Baja la ansiedad del lector.
- **⚰️ Caso de estudio: el anti-patrón.** `soporte_v1` mal diseñada: se mide, duele, se arregla. Es el hilo que cose las fases 3 a 7.5.

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden:

1. **🎯 Propósito** — qué resuelve esta fase; puede abrir con la situación heredada ("hasta ahora el frontend vive de un mock que miente…").
2. **✅ Qué queda listo al terminar** — checklist verificable.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase.
4. **🧠 Conceptos mínimos** — solo lo necesario, anclado al dominio. Aquí caben el **Mini-repaso** y las **Notas de época**. En Track B, aquí suelen vivir la 📖 tabla de traducción y los recuadros 🪞/🩻.
5. **💻 Implementación y código comentado** — el grueso; código ejecutable con comentarios de porqué, identificadores en inglés (§4). Aquí caben **Detalles con intención**, **El patrón a memorizar**, **Prueba de fuego** y **💸 Pago de deuda**.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente y cómo depurarlo.
7. **🧪 Ejercicios progresivos** — 25 a 35 (§9).
8. **📚 Referencias** — §10.
9. **🚀 Cierre y conexión con la siguiente fase** — qué sigue y por qué. Aquí va **La señal de que quedó bien**.

Los apéndices no siguen esta plantilla: usan índice de salto rápido +
secciones cortas + tabla "cuándo usar qué" + 5-10 ejercicios cortos.

---

## 9. Ejercicios

- **Cantidad: mínimo 25, ideal 30-35 por fase.** Menos de 25 se queda corto.
- **Distribución equilibrada por nivel.** Reparte parejo entre 🟢🟡🟠🔴. Guía razonable para ~30: ~8 🟢, ~9 🟡, ~7 🟠, ~4-6 🔴, más los 🔥 aparte.
- **Numeración continua con encabezado de rango por dificultad:**
  ```
  ## 🧪 Ejercicios (30)

  **🟢 Fácil (1–8)**
  1. ...
  **🟡 Intermedio (9–17)**
  9. ...
  **🟠 Difícil (18–24)**
  18. ...
  **🔴 Muy difícil (25–30)**
  25. ...
  **🔥 Opcionales**
  - 🔥 ...
  ```
  El título lleva el conteo total: `## 🧪 Ejercicios (30)`.
- **Progresión real.** Los 🟢 calientan; los 🔴 exigen integrar varias fases o depurar algo esquivo (en Track B: medir un `explain()`, reproducir un N+1, cerrar una race condition en el "tomar").
- **Accionables y verificables.** "Haz que el ticket `#0347` no pueda tomarse dos veces bajo doble click rápido" — no "reflexiona sobre concurrencia".
- **Algunos de diagnóstico.** Al menos un puñado entrega un bug y pide reproducir y localizar, no solo construir.
- **Enganchados al dominio.** Usan tickets, comentarios, agentes, reportadores, estados y prioridades, no ejemplos abstractos.
- **Cuando un ejercicio nombra código, usa el identificador en inglés vigente** ("agregá la action `createTicket`", "escribí el `serializeTicket`"), aunque el enunciado en sí esté en español.
- Los 🔥 son opcionales y se listan aparte, sin numeración continua.

En apéndices bastan 5-10 ejercicios cortos de consulta.

---

## 10. Bibliografía y referencias

**Regla:** documentación oficial compatible con las versiones legacy
**primero**; luego libros; luego blogs, videos y tutoriales. Siempre se
advierte cuando un enlace apunta a docs de una versión distinta a la fijada.

### 10.1 Formato

- **URLs completas y clicables**, no solo el dominio.
- **Secciones separadas** dentro de "Referencias": Documentación oficial (con URL completa y nota de versión), Libros cuando apliquen, Video/apoyo (screencasts, crash courses en YouTube con URL completa), y **Orden de lectura sugerido** (una línea que encadena qué leer primero).

### 10.2 Fuentes oficiales por tema (usar URL completa al citar)

**Track A (Vue 2 Legacy)**
- **Vue 2:** https://v2.vuejs.org
- **Vuex 3:** https://v3.vuex.vuejs.org
- **Vue Router 3:** https://v3.router.vuejs.org
- **Vue Test Utils (Vue 2):** https://v1.test-utils.vuejs.org
- **Bootstrap 4.6:** https://getbootstrap.com/docs/4.6
- **axios:** https://axios-http.com/docs/intro
- **json-server:** https://github.com/typicode/json-server/tree/v0.16.3

**Track B (MongoDB / Express)**
- **MongoDB 4.4 (manual):** https://www.mongodb.com/docs/v4.4/
- **Driver Node `mongodb` 3.6:** https://www.mongodb.com/docs/drivers/node/v3.6/
- **Mongoose 5:** https://mongoosejs.com/docs/5.x/
- **Express 4:** https://expressjs.com/en/4x/api.html
- **socket.io 2.4:** https://socket.io/docs/v2/
- **Jest:** https://jestjs.io · **supertest:** https://github.com/ladjs/supertest · **mongodb-memory-server:** https://github.com/nodkz/mongodb-memory-server

**Común**
- **MDN** para JS base (Promises, Intl, fechas): https://developer.mozilla.org

### 10.3 Advertencias

- **Sobre citas:** cuando se mencione un artículo, libro, video o post específico, hay que dejar claro que URLs y títulos pueden estar desactualizados o ser inexactos; el lector debe verificarlos. No se inventan números de página, DOIs ni IDs de video.
- **No usar en el código principal:** APIs exclusivas de Vue 3 (Composition API como norma, `<script setup>`), Vue Router 4, Vuex 4/Pinia, MongoDB ≥5 (transacciones sin replica set, `$setWindowFields`), driver `mongodb` 4/5/6, socket.io 3/4, Mongoose 6/7/8. Las alternativas modernas aparecen solo como comparación o en fase opcional 🔥. **socket.io 2.x y 3.x no se hablan: la versión importa.**

---

## 11. Sobre el dominio (ficticio, sin NDA)

Mini Jira es un dominio **enteramente ficticio**: una mesa de soporte interna
inventada para estos cursos. No hay confidencialidad que preservar ni sistema
real que disfrazar. Esto simplifica dos cosas respecto de otros cursos:

- Los ejemplos pueden ser todo lo concretos que convenga; no hace falta
  "generalizar ante la duda".
- El vocabulario del dominio (ticket, comentario, agente, reportador, estados)
  es estable y se fija en `DICCIONARIO-CODIGO.md`; no compite con ningún
  vocabulario "real" que haya que evitar.

La regla de idioma del código (§4) es una convención de calidad, no una
cuestión de NDA: se traduce el vocabulario del dominio pedagógico
("ticket" → `ticket`) por consistencia y realismo, no por confidencialidad.

---

## 12. Coherencia entre documentos y entre tracks

- **No contradecir fases anteriores** (ni dentro de un track ni respecto del otro). Un fragmento de la Fase 6 de Mongo no puede devolver una forma de `ticket` distinta de la que el frontend de Track A espera; el **contrato** (`AUDIT-CONTRATO.md`) manda.
- **No reescribir decisiones aprobadas** sin señalar explícitamente la incompatibilidad y por qué.
- **Fuentes de verdad, en orden:** (1) instrucciones del proyecto, (2) `AUDIT-CONTRATO.md` (el contrato que une los dos tracks), (3) `PLAN-FORMACION-NOSQL-MONGODB.md` y el plan de Track A, (4) entregables aprobados de fases anteriores, (5) decisiones explícitas del chat actual.
- **El contrato es la costura entre tracks.** Endpoints, forma de las respuestas, enums (`status`, `priority`), nombres de evento de socket y el mapeo `id`↔`_id` son idénticos a ambos lados. Si un track los cambia, el otro se entera y se documenta.
- Nombres de archivos, componentes, módulos, servicios, colecciones y campos se mantienen estables entre fases y entre tracks (en inglés, §4.4). Si algo se renombra, se documenta el cambio.

---

## 13. Post-mortems e incidentes

Cada incidente sigue esta estructura de ocho puntos:

1. Síntoma.
2. Pasos de reproducción.
3. Evidencia observable (logs, DevTools, Network; en Track B también el profiler o `explain()`).
4. Causa raíz.
5. Corrección.
6. Prueba de regresión.
7. Prevención.
8. Post-mortem **sin culpabilización** (blameless): se analiza el sistema y el proceso, no a la persona.

El tono del post-mortem es sereno y analítico. El humor cálido del resto del
curso baja un punto aquí: un post-mortem es serio, aunque no acartonado.

---

## 14. Checklist rápido antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono cálido e informal, segunda persona, humor con moderación.
- [ ] Todo el código corre con las versiones fijadas del track.
- [ ] **Identificadores, endpoints, colecciones, campos, constantes y enums del código en inglés (§4).**
- [ ] **Comentarios de código y textos de interfaz (UI) en español (§4.5).**
- [ ] No contradice ninguna fase anterior **ni el otro track** (ni en pedagogía ni en nombres de código); respeta `AUDIT-CONTRATO.md`.
- [ ] Distingue capas (componente / store / servicio / ruta / controller / service / Mongo) donde importa.
- [ ] Usa el vocabulario de callouts (📝 🪦 📚 ⚠️ 💡) y, en Track B, los recuadros 📖 🪞 🩻 ⚰️ donde aporten.
- [ ] Marca 💸 la deuda técnica (y la paga si corresponde) y 🔥 lo opcional.
- [ ] Tiene 25-35 ejercicios numerados con rangos 🟢🟡🟠🔴 equilibrados (o 5-10 en apéndices).
- [ ] Enlaza su pieza forense e incidentes.
- [ ] Referencias con URL completa, secciones (oficial / libros / video / orden de lectura), advertencia de versión.
- [ ] Explica el *porqué* de cada decisión relevante.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
