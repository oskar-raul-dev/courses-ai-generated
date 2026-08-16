# ✍️ Guía de estilo, tono y convenciones
## Curso Bitácora de Campo — Offline-first (CouchDB/PouchDB vs Firestore vs ElectricSQL)

Esta guía es la fuente de verdad editorial de este curso. Deriva de
`GUIA-DE-ESTILO-Y-CONVENCIONES.md` (curso legacy Vue2/MongoDB) adaptada al
modelo offline-first; no la copia literal. Cualquier chat que produzca un
`.md` de este curso la sigue. Su objetivo: que las doce fases se lean como
escritas por la misma mano, orientadas a que alguien diseñe y opere con
criterio un sistema que sincroniza sin coordinación previa.

> 🧭 **Regla de una línea que rige todo el código:** el **código en inglés**;
> todo lo demás —narrativa, comentarios, textos de interfaz— **en español**.
> Detalle completo en §4.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien reconozca, en la fase de
diseño, cuándo el conflicto de escritura concurrente sin coordinación es
parte del dominio y no un caso límite.** No enseñamos CouchDB "de moda" ni
sync "porque es lo nuevo". Enseñamos a decidir con el marco de 5 preguntas,
a medir en vez de narrar, y a nombrar con honestidad cuándo el modelo
completo se justifica y cuándo es sobre-ingeniería.

El norte del curso es una sola señal de éxito: **que el estudiante pueda
provocar un conflicto de tres vías a propósito, explicar exactamente por qué
ocurrió, y elegir con criterio —no por costumbre— la estrategia que lo
resuelve.** Todo lo que escribimos sirve a esa promesa.

---

## 2. Tono

El tono es **cálido, informal y directo** — de colega senior a colega senior,
con humor cuando cae bien. Es alguien que ya se quedó sin señal seis horas
con datos sin sincronizar explicándotelo con confianza y sin solemnidad.

- **Segunda persona, cercana, sin voseo.** Se usa **"tú"**, nunca "vos" ni
  sus conjugaciones ("tenés", "podés", "mirá"). Ejemplos correctos: "apaga
  la red y mira qué pasa con las dos escrituras", "si el `_rev` te confunde,
  primero lee el árbol de revisiones". El texto debe leerse igual de natural
  en cualquier país de habla hispana; evita también modismos regionales
  marcados.
- **Humor seco permitido, con moderación.** Un 😉, un 🪦 para jubilar una
  estrategia de resolución que no sirvió, un chiste sobre el reloj del
  contenedor que está dos horas adelantado. El humor desdramatiza la
  fricción de razonar sobre conflictos, no rellena.
- **Honesto sobre lo feo.** `campo_v1` es feo a propósito y se lo nombra sin
  piedad: "esto funciona en la demo con wifi de oficina y se desangra el
  primer día de campo real". No se finge que la sincronización casera es una
  mala práctica menor; se muestra exactamente cuánto cuesta, medido.
- **Orientado a la duda real.** Anticipa "¿y por qué CouchDB no simplemente
  elige un ganador y ya?" y la responde, muchas veces con una nota de
  contexto (📝) sobre por qué el modelo expone el conflicto en vez de
  esconderlo.
- **Cercanía sin condescendencia.** El lector es senior con años de
  instintos relacionales. No le expliques qué es una transacción, un lock o
  un índice: **lo sabe de SQL**. Lo nuevo es qué pasa cuando no hay un único
  árbitro al que preguntar antes de escribir.

Evitar: promesas vacías ("vas a dominar el offline-first"), motivación de
coach, solemnidad de manual corporativo, y explicar lo obvio para el perfil.
El humor es condimento, no plato principal.

> 🧠 **Matiz propio de este curso (el eje).** El lector no llega en blanco:
> llega convencido de que "hubo coordinación previa" es un hecho del mundo,
> no un supuesto del modelo relacional. El tono reconoce ese instinto y lo
> interpela de frente con dos micro-secciones recurrentes (§7.4): 🪞 *"tu
> instinto SQL dice… y esta vez no hay árbitro"* y 🩻 *"esto sí viaja
> igual"*. Nunca se ridiculiza el instinto relacional: se lo honra y se lo
> recalibra.

---

## 3. Idioma y forma (narrativa)

- Español claro y técnico, **sin voseo**, para todo lo que no es código
  (títulos, explicaciones, ejercicios, referencias).
- Los términos del stack se dejan en inglés cuando son el nombre real y
  traducirlos sonaría forzado: *sync*, *replication*, *conflict*,
  *offline-first*, *shape* (ElectricSQL), *last-write-wins*, *merge*,
  *attachment*, *checksum*, *deduplication*, *optimistic UI*, *replica*,
  *reconnect/disconnect*. No se inventan traducciones como "sincronía" o
  "adjunción".
- Markdown siempre.
- Encabezados con emoji **con moderación** — uno por sección de plantilla.
  Los subtítulos internos pueden llevar emoji-tipo (§7) cuando aporta
  lectura rápida.
- **Prosa antes que listas.** Se prefiere explicar razonando en párrafos.
  Las listas se usan cuando son de verdad una lista (pasos, ítems
  paralelos).
- **Tablas solo para comparar, decidir o mapear.** "Cuándo usar X vs Y",
  matrices de decisión, y —muy importante en este curso— **la tabla de
  traducción relacional ↔ offline-first** (§7.4). No para narrar.

---

## 4. Idioma del código fuente (código en inglés, curso en español)

Esta sección es normativa para **todo** fragmento de código del curso, sea
en el cuerpo de una fase, en la autopsia del villano, en un apéndice o en
un ejercicio resuelto.

### 4.1 Regla general

| Capa | Idioma | Ejemplo |
|---|---|---|
| **Código fuente** (identificadores) | 🇬🇧 Inglés | `function resolveConflict(local, remote) {}`, `const isOffline = true` |
| **Endpoints Express (capa de negocio, no sync)** | 🇬🇧 Inglés | `/auth/login`, `/sites/:id/assign` |
| **Bases y documentos CouchDB/PouchDB** | 🇬🇧 Inglés | `db.inspections`, `{ formData, findings, attachments, geo, deviceId, rev }` |
| **Constantes y enums internos** | 🇬🇧 Inglés | `status: 'draft'`, `CONFLICT_STRATEGY.LWW`, `MAX_ATTACHMENT_BYTES` |
| **Nombres de archivo, servicio, script** | 🇬🇧 Inglés | `syncService.ts`, `conflictResolver.ts`, `vs.ts` |
| **Comentarios de código** | 🇪🇸 Español | `// el _rev es un árbol: no lo trates como contador` |
| **Textos de interfaz (UI)** | 🇪🇸 Español | `<button>Sincronizar ahora</button>`, `"Sin conexión — guardando en el dispositivo…"` |
| **Narrativa del tutorial** | 🇪🇸 Español | Todo el texto fuera de bloques de código |

La app pedagógica **no tiene i18n**: es una app en español para inspectores
de habla hispana. Lo que ve el inspector —labels, botones, mensajes de
estado de sync— va en español. Lo que el equipo técnico lee y mantiene
—funciones, campos de documento, endpoints, constantes— va en inglés.

> 📝 **Por qué esta regla.** El protocolo de replicación que el curso enseña
> (CouchDB/PouchDB) es el mismo que se encuentra en producción en inglés en
> cualquier equipo real; escribir el pedagógico así hace que el vocabulario
> de identificadores sea el que el estudiante va a encontrar en la
> documentación oficial y en un sistema real.

### 4.2 Qué se traduce y qué no (criterio rápido)

| Elemento | ¿Inglés? | Ejemplo |
|---|---|---|
| Campos de documento CouchDB/PouchDB | ✅ Sí | `formData`, `findings`, `attachments`, `deviceId`, `rev` (no `_rev`, ese es reservado del motor) |
| Nombres de bases/colecciones | ✅ Sí | `inspections`, `sites`, `inspectors`, `inspectionTypes` |
| Funciones y módulos de sync | ✅ Sí | `syncService.ts`, `resolveConflict()`, `disconnect(clientId)` |
| Endpoints Express de negocio | ✅ Sí | `router.patch('/sites/:id/assign')` |
| Constantes de estrategia de resolución | ✅ Sí | `CONFLICT_STRATEGY.LWW`, `CONFLICT_STRATEGY.MERGE`, `CONFLICT_STRATEGY.MANUAL` |
| Comentarios `//`, `/* */` | ❌ No | `// el reloj de pared del dispositivo miente: usa el lógico` |
| Strings de interfaz (lo que ve el inspector) | ❌ No | `"Guardado localmente"`, `"2 conflictos por resolver"` |
| Mensajes de error legibles | ❌ No (la key sí) | `{ code: 'CONFLICT_DETECTED', message: 'Esta inspección cambió en otro dispositivo' }` |
| Nombres del dominio en la narrativa | ❌ No | El texto sigue hablando de "inspección", "hallazgo", "sitio", "inspector" |

> ⚠️ **Caso mixto frecuente — estado de sincronización visible en UI.** El
> objeto usa keys en inglés (`{ status, pendingCount }`), pero el texto que
> el inspector lee va en español:
> ```ts
> // syncStatus.ts
> export const SYNC_STATUS_LABEL: Record<SyncStatus, string> = {
>   offline:  'Sin conexión — trabajando en local',
>   syncing:  'Sincronizando…',
>   conflict: 'Hay conflictos por resolver',
>   synced:   'Todo sincronizado',
> };
> ```
> La **clave** (`offline`, `conflict`) es el enum que vive en el código;
> el **valor** es lo que ve el inspector, en español.

### 4.3 Diccionario de traducción del dominio (relacional → offline-first)

El diccionario operativo completo vive en `DICCIONARIO-SYNC.md`
(artefacto transversal, ver §7.4 y `BITACORA-DE-CAMPO-PROMPTS.md`). Como
referencia mínima, los términos centrales que **cada fase reafirma** con
vocabulario del dominio de inspecciones:

| Instinto relacional | Su forma en offline-first (este curso) |
|---|---|
| transacción | lote de revisiones aplicado localmente, replicado después |
| `UPDATE ... WHERE id = ?` | nueva revisión (`_rev`) sobre el documento; no hay "update in place" |
| columna `version` para concurrencia optimista | árbol de `_rev`: no rechaza la escritura divergente, **retiene ambas** |
| `updated_at` como reloj de orden | reloj lógico o vector; el reloj de pared del dispositivo miente |
| `FOREIGN KEY` entre tablas | referencia embebida dentro del agregado documental (la inspección se lee/escribe entera) |
| `SERIALIZABLE` / lock de fila | no hay lock: la coordinación se difiere a la reconciliación post-reconexión |
| `JOIN` en caliente | casi no ocurre en campo; los cruces viven en el servidor tras sincronizar |

### 4.4 Convenciones de nombrado

- **Funciones y variables:** `camelCase` en inglés — `resolveConflict`,
  `isSyncing`, `deviceId`.
- **Constantes de configuración:** `SCREAMING_SNAKE_CASE` —
  `MAX_ATTACHMENT_BYTES`, `RECONNECT_BACKOFF_MS`.
- **Documentos y campos CouchDB/PouchDB:** `camelCase` en inglés —
  `formData`, `findings`, `deviceId`, `createdAt`. Los campos reservados del
  motor (`_id`, `_rev`, `_attachments`, `_conflicts`) se dejan **tal cual**
  los define CouchDB, con guion bajo — no se renombran.
- **Endpoints Express:** sustantivo en plural, inglés — `/sites`,
  `/inspectors/:id`.
- **Scripts del laboratorio:** `kebab-case.ts` en `scripts/` —
  `scripts/vs.ts`, `scripts/seed-data.ts`.
- **Servicios/módulos de sync:** `<dominio>Service` — `syncService`,
  `conflictResolver`, `attachmentService`.

### 4.5 Lo que nunca cambia

- **Comentarios de código:** 100% español, explicando el porqué.
- **Textos de interfaz:** 100% español — labels, botones, mensajes de
  estado de sync, alertas de conflicto.
- **Narrativa del tutorial:** 100% español, sin voseo.
- **Nombres propios del dominio en la narrativa:** "inspección", "hallazgo",
  "sitio", "inspector", "adjunto" siguen siendo las palabras con que se
  *habla* del sistema, aunque el código diga `inspection`, `finding`,
  `site`, `inspector`, `attachment`.

### 4.6 La excepción del villano — `campo_v1`

`campo_v1` (el anti-patrón medido de las fases 1, 6 y 11) también se
normaliza a inglés en sus identificadores: `pendingOps[]`, `updatedAt`,
`version`. **Decisión de estilo (queda fijada acá):** el idioma del código
no confunde dos problemas independientes: *"está mal diseñado"* y *"está en
español"*. El olor del villano se mantiene por sus decisiones —reloj de
pared como fuente de verdad, `version` entera que no reconstruye qué
cambió, attachments fuera del protocolo de sync— no por su idioma.

---

## 5. Orientación a la práctica

Cada concepto se ancla en el dominio de Bitácora de Campo y en código que
corre contra un motor real, nunca en abstracto.

- **Nada de teoría suelta.** Si se explica el árbol de `_rev`, se explica
  sobre el conflicto real de dos inspectores editando el mismo sitio, no en
  abstracto. Si se explica un filtro de replicación, es sobre "cada
  inspector sincroniza solo sus sitios asignados", no un ejemplo genérico.
- **Código ejecutable y coherente.** Todo fragmento corre con las versiones
  fijadas del stack (CouchDB 3.5.2, PouchDB 9.0.0, Node 24, TypeScript 5.x)
  y no contradice fases anteriores. Nada de pseudocódigo que "se entiende".
- **Código mínimo.** El fragmento más pequeño que muestra el punto, pero
  ejecutable.
- **Comentarios que explican el porqué, no el qué, siempre en español.**
  `// no comparamos updatedAt: el reloj del dispositivo puede mentir` sí;
  `// incrementa el contador` no.
- **Distinguir capas.** Siempre queda claro si un comportamiento vive en el
  cliente PouchDB, en el servidor CouchDB, en la capa Express de negocio, o
  en el propio protocolo de replicación. Es la distinción que salva a quien
  depura un conflicto a las 3 am.

---

## 6. Manejo del villano (`campo_v1`)

- **No modernizar el villano a medias.** `campo_v1` se muestra tal como es:
  una cola de operaciones pendientes, `last-write-wins` por reloj de pared,
  una columna `version` que no alcanza. No se le "arregla" un poco para que
  parezca menos malo antes de la autopsia — la autopsia pierde fuerza si el
  villano ya no duele.
- **Corrección mínima vs. modelo completo.** Ante el primer conflicto en
  vivo de la Fase 1, se distingue el parche que alguien pondría en
  producción bajo presión (ignorar el conflicto, quedarse con el último) de
  lo que el curso enseña después con criterio.
- **El idioma del código (§4) no es negociable ni en el villano feo.** Se
  muestra viejo y mal diseñado, pero con identificadores en inglés (ver
  excepción documentada en §4.6). La fealdad que se enseña es de
  arquitectura y decisiones, no de idioma.

---

## 7. Marcadores y callouts (vocabulario visual del curso)

Este vocabulario se usa igual en las doce fases para que el lector lo
reconozca de un vistazo.

### 7.1 Marcadores de estado

- 🔥 **Opcional / ampliación.** Ejercicios o secciones que exceden el
  alcance base (p. ej. una demo con navegador real, RxDB como comparación
  extra).
- ⭐ **Fase o pieza central.** Fases 5 y 6 (el conflicto y su resolución):
  el corazón del curso.
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil / intermedio / difícil / muy
  difícil.

### 7.2 Callouts en blockquote (emoji-tipo)

- 📝 **Nota de contexto.** Por qué el modelo o el motor decide algo así. Ej:
  "CouchDB no esconde el conflicto a propósito: es una decisión de diseño
  de 2005, no un descuido."
- 📚 **Referencia rápida inline.** Un enlace útil justo donde surge la duda,
  sin esperar a la sección de referencias.
- 🪦 **Retiro / jubilación.** Cuando una estrategia o pieza cumple su
  función y se retira. Ej: "🪦 se jubila el `last-write-wins` ingenuo de
  `campo_v1`: ya cumplió su rol de villano medido."
- ⚠️ **Advertencia.** Algo que rompe si lo ignoras — CouchDB ≠ Couchbase,
  el reloj del contenedor desincronizado, la versión de ElectricSQL.
- 💡 **Truco o atajo** que ahorra tiempo real.

### 7.3 Secciones narrativas recurrentes

- **Detalles con intención.** Lista corta que destila las decisiones
  deliberadas de un bloque ("guardamos `deviceId` en cada revisión porque
  la reconciliación necesita saber de dónde vino cada escritura").
- **El patrón a memorizar.** Una o dos frases que extraen la lección
  transferible.
- **Prueba de fuego.** Verificación manual incrustada en el flujo:
  "desconecta dos clientes, edita el mismo campo en ambos, reconecta:
  aparece el conflicto, no un ganador silencioso."
- **Mini-repaso.** Cuando una fase usa un concepto que el lector relacional
  quizá no domina (árboles de revisión, relojes lógicos, CRDTs básicos), un
  repaso exprés en tabla antes del código, con su 📚.
- **La señal de que quedó bien.** En el cierre, un criterio en forma de
  cita: "si desconecto dos dispositivos, los dejo escribir seis horas y los
  reconecto, no perdí ni un hallazgo y puedo explicar cada conflicto que
  apareció."

### 7.4 Secciones propias de este curso (relacional → offline-first)

Estas cuatro son la columna vertebral del curso y aparecen cuando el
contenido lo pide:

- **📖 Tabla de traducción relacional ↔ offline-first.** Lado a lado, el
  instinto SQL y su forma en el modelo de sync. Es tabla (§3), no prosa. Ver
  §4.3 para el núcleo mínimo; el diccionario completo vive en
  `DICCIONARIO-SYNC.md`.
- **🪞 "Tu instinto SQL dice… y esta vez no hay árbitro."** Nombra la
  trampa **antes** de caer: "una columna `version` basta para detectar
  conflictos", "`updated_at` sirve para ordenar escrituras", "el motor
  siempre resuelve el conflicto por mí". Honra el instinto y lo recalibra.
- **🩻 "Esto sí viaja igual."** Lo reconfortante: validación de esquema,
  restricciones de dominio, "no confíes en la entrada" — todo intacto; lo
  único que cambia es *dónde* y *cuándo* se valida.
- **⚰️ Caso de estudio: la autopsia de `campo_v1`.** Medida, no narrada: se
  mide, duele, se convierte al modelo con números antes/después. Hilo que
  cose las fases 1, 6 y 11.

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden:

1. **🎯 Propósito** — qué resuelve esta fase; puede abrir con la situación
   heredada ("hasta ahora `campo_v1` pisa la escritura del segundo
   dispositivo sin dejar rastro…").
2. **✅ Qué queda listo al terminar** — checklist verificable.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase.
4. **🧠 Conceptos mínimos** — solo lo necesario, anclado al dominio. Aquí
   caben el **mini-repaso** y las **notas de contexto** (📝). Aquí suelen
   vivir la 📖 tabla de traducción y los recuadros 🪞/🩻.
5. **💻 Implementación y código comentado** — el grueso; código ejecutable
   con comentarios de porqué, identificadores en inglés (§4). Aquí caben
   **detalles con intención**, **el patrón a memorizar** y **prueba de
   fuego**.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente al
   trabajar con replicación y conflicto, y cómo depurarlo (leer `_conflicts`,
   inspeccionar el árbol de revisiones, revisar el filtro de replicación).
7. **🧪 Ejercicios progresivos** — 25 a 40 (§9).
8. **📚 Referencias** — con **URL completa** y advertencia de versión;
   **cada fase cierra con su propia sección de referencias**, curada del
   listado maestro de `07-bitacora-de-campo-semilla.md` §"Referencias por
   fase" — nunca se remite solo a un archivo global sin extraer lo que esa
   fase específica usó.
9. **🚀 Cierre y conexión con la siguiente fase** — qué sigue y por qué.
   Aquí va **la señal de que quedó bien**.

Los apéndices no siguen esta plantilla: usan índice de salto rápido +
secciones cortas + tabla "cuándo usar qué" + 5-10 ejercicios cortos.

---

## 9. Ejercicios

- **Cantidad: entre 25 y 40 por fase**, según lo que fije la semilla para
  esa fase; **ideal 30**. Las fases 5, 6 y 7 (conflicto, resolución,
  attachments) pueden llegar a 40 porque el diagnóstico ahí es
  particularmente rico.
- **Distribución equilibrada por nivel**, guía razonable para ~30: ~8 🟢,
  ~9 🟡, ~7 🟠, ~4–6 🔴, más los 🔥 opcionales aparte.
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
- **Progresión real.** Los 🟢 calientan (levantar el laboratorio, leer un
  `_rev`); los 🔴 exigen integrar varias fases o depurar algo esquivo
  (cerrar un conflicto de tres vías reproducible, medir con `vs.ts` y
  explicar el resultado).
- **Accionables y verificables.** "Provoca que dos dispositivos editen el
  mismo hallazgo offline y demuestra que ninguna escritura se pierde" — no
  "reflexiona sobre la sincronización".
- **De diagnóstico, en abundancia en las fases 5–7.** Se entrega un bug y se
  pide reproducir y localizar, no solo construir: "reproduce la escritura
  que se pierde cuando dos dispositivos reconectan en cierto orden",
  "localiza por qué esta foto quedó huérfana de su inspección", "el reloj
  de este contenedor está adelantado 90 minutos: demuestra qué escritura
  gana mal y arréglalo con un reloj lógico".
- **Enganchados al dominio.** Usan inspecciones, hallazgos, sitios,
  inspectores, dispositivos y conflictos reales, no ejemplos abstractos.
- **Cuando un ejercicio nombra código, usa el identificador en inglés
  vigente** ("implementa `resolveConflict` para el caso de merge
  campo-a-campo"), aunque el enunciado esté en español, sin voseo.
- Los 🔥 son opcionales y se listan aparte, sin numeración continua.

En apéndices bastan 5-10 ejercicios cortos de consulta.

---

## 10. Bibliografía y referencias

**Regla:** documentación oficial de la versión fijada del stack **primero**;
luego libros; luego blogs, videos y tutoriales. Siempre se advierte cuando
un enlace apunta a una versión distinta de la fijada.

### 10.1 Formato

- **URLs completas y clicables**, no solo el dominio.
- **Secciones separadas** dentro de "Referencias": documentación oficial
  (con URL completa y nota de versión), libros cuando apliquen, video/apoyo
  (con URL completa) y **orden de lectura sugerido** (una línea que
  encadena qué leer primero).
- **Cada fase cierra su capítulo con su propia sección de referencias**
  (§8, punto 8) — no basta con un archivo de referencias global al final
  del curso.

### 10.2 Fuentes oficiales del stack (usar URL completa al citar)

- **CouchDB 3.5:** https://docs.couchdb.org/en/stable/
- **PouchDB (guías y API):** https://pouchdb.com/ y https://pouchdb.com/api.html
- **Node.js 24 LTS:** https://nodejs.org/docs/latest-v24.x/api/
- **Firebase/Firestore:** https://firebase.google.com/docs/firestore
- **ElectricSQL:** https://electric-sql.com/docs — **verificar vigencia**,
  el proyecto reorganizó su modelo; confirmar que describe el sync
  read-path actual.
- **PostgreSQL 18:** https://www.postgresql.org/docs/18/
- **Zod:** https://zod.dev/
- **Docker Compose v2:** https://docs.docker.com/compose/

### 10.3 Advertencias

- **Sobre citas:** cuando se mencione un artículo, libro, video o post
  específico, se deja claro que URLs y títulos pueden estar desactualizados
  y el lector debe verificarlos. No se inventan números de página, DOIs ni
  IDs de video.
- **No usar en el código principal:** CouchDB ≠ **Couchbase** (nunca; ver
  §11), ElectricSQL en su versión histórica bidireccional con CRDTs en
  cliente, versiones del SDK de Firebase distintas a la fijada al redactar.
  Las alternativas o versiones distintas aparecen solo como comparación o en
  ejercicio 🔥.

---

## 11. Sobre el dominio (ficticio, sin NDA) y la precaución de nombres

Bitácora de Campo es un dominio **enteramente ficticio**: una app de
inspecciones inventada para este curso. No hay confidencialidad que
preservar ni sistema real que disfrazar.

> ⚠️ **CouchDB ≠ Couchbase — el error más caro de este curso.** CouchDB
> (Erlang, Apache 2.0, replicación offline-first, contraparte PouchDB) es el
> motor de Bitácora de Campo. Couchbase (C++, N1QL, memoria-first,
> source-available) **no aparece en ningún rol**. Comparten un ancestro
> histórico y nada más que importe. Cualquier mención de "Couchbase" en
> material de este curso es un bug a corregir de inmediato.

---

## 12. Coherencia entre documentos

- **No contradecir fases anteriores.** Un fragmento de la Fase 8 no puede
  asumir un modelo de `inspection` distinto del fijado en la Fase 3.
- **No reescribir decisiones aprobadas** sin señalar explícitamente la
  incompatibilidad y por qué.
- **Fuentes de verdad, en orden:** (1) instrucciones del proyecto, (2)
  `RUTA-NOSQL.md`, (3) `RUTA-NOSQL-FUNDAMENTOS.md`, (4)
  `07-bitacora-de-campo-semilla.md`, (5) entregables aprobados de fases
  anteriores, (6) decisiones explícitas del chat actual.
- Nombres de bases, campos, servicios y scripts se mantienen estables entre
  fases (en inglés, §4.4). Si algo se renombra, se documenta el cambio.

---

## 13. Autopsias e incidentes (post-mortems del modelo)

Cada incidente o autopsia (la de `campo_v1`, o cualquier bug de
sincronización reproducido en una fase) sigue esta estructura de ocho
puntos:

1. Síntoma (ej. "el hallazgo del inspector A desapareció").
2. Pasos de reproducción (secuencia exacta de `disconnect`/`reconnect`,
   orden de escrituras).
3. Evidencia observable (`_conflicts`, árbol de revisiones, logs de
   replicación, salida de `vs.ts`).
4. Causa raíz.
5. Corrección.
6. Prueba de regresión (reproducir el mismo escenario con `vs.ts` y
   verificar el número).
7. Prevención.
8. Post-mortem **sin culpabilización** (blameless): se analiza el protocolo
   y el diseño, no a quien escribió `campo_v1`.

El tono del post-mortem es sereno y analítico. El humor cálido del resto
del curso baja un punto aquí: una autopsia es seria, aunque no acartonada.

---

## 14. Checklist rápido antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono cálido e informal, segunda persona **sin voseo**, humor con
      moderación.
- [ ] Todo el código corre con las versiones fijadas del stack.
- [ ] **Identificadores, endpoints, bases, campos, constantes y enums del
      código en inglés (§4).**
- [ ] **Comentarios de código y textos de interfaz (UI) en español (§4.5).**
- [ ] No contradice ninguna fase anterior; respeta el modelo de `inspection`
      fijado en la Fase 3.
- [ ] Distingue capas (cliente PouchDB / servidor CouchDB / capa Express /
      protocolo de replicación) donde importa.
- [ ] Usa el vocabulario de callouts (📝 🪦 📚 ⚠️ 💡) y los recuadros propios
      del curso (📖 🪞 🩻 ⚰️ ⚖️) donde aporten.
- [ ] Marca 🔥 lo opcional.
- [ ] Tiene 25-40 ejercicios numerados con rangos 🟢🟡🟠🔴 equilibrados (o
      5-10 en apéndices), con un puñado de diagnóstico si la fase está
      entre la 5 y la 7.
- [ ] **Cierra con su propia sección de referencias** (§8, §10), con URL
      completa y advertencia de versión donde corresponda.
- [ ] Nunca confunde CouchDB con Couchbase.
- [ ] Explica el *porqué* de cada decisión relevante.
- [ ] Incluye "la señal de que quedó bien" en el cierre.
