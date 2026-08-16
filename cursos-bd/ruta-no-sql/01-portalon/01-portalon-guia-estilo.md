# ✍️ Guía de estilo, tono y convenciones
## Curso Portalón — Clave-valor en memoria para cerebros SQL

Esta guía es la fuente de verdad editorial del curso Portalón. Cualquier
chat que produzca un `.md` de este curso la sigue. Se deriva de la guía
legacy de la ruta (`GUIA-DE-ESTILO-Y-CONVENCIONES.md`), adaptada al modelo
clave-valor: cambia el villano, el diccionario de traducción y los
recuadros propios, pero conserva el principio rector, el tono y la
plantilla de fase.

> 🧭 **Regla de una línea que rige todo el código:** el **código en inglés**;
> todo lo demás —narrativa, comentarios, textos de interfaz— **en español**.
> El detalle completo está en §4 y el diccionario operativo de términos del
> dominio en §4.3.

> 🗣️ **Segunda persona formal, sin voseo.** Se usa "tú" en toda la
> narrativa ("apaga el gateway y verás cómo se ahoga el backend"), nunca
> "vos" ni sus conjugaciones. Es una decisión de consistencia editorial de
> toda la ruta, no una preferencia regional.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que un ingeniero senior de Postgres deje
de meter en la base transaccional cosas que no son estado de negocio, y
sepa cuándo un motor en memoria es el amortiguador correcto —y cuándo es una
trampa.** No enseñamos Redis "porque está de moda": enseñamos un **modelo de
acceso** —clave, TTL, estructuras nativas, latencia sub-milisegundo— que
sobrevive al motor concreto y al lenguaje concreto.

El norte del curso es una sola señal de éxito, repetida en cada fase con
variaciones: **"apago el gateway y el backend se ahoga; lo enciendo y
respira."** Todo lo que escribimos sirve a que el lector reconozca, mida y
construya esa capa caliente sin que se le cuele el villano —convertirla en
la fuente de verdad.

---

## 2. Tono

El tono es **cálido, informal y directo** — de colega senior a colega
senior, con humor cuando cae bien. Es alguien que ya pagó el precio de meter
Redis donde no tocaba (o de no meterlo donde sí tocaba) explicándotelo con
confianza y sin solemnidad.

- **Segunda persona, cercana, sin voseo.** "Tú" siempre: "mide antes de
  confiar en tu instinto", "si el `MULTI`/`EXEC` te tienta como excusa para
  no pensar en atomicidad, primero mide".
- **Humor seco permitido.** Un 😉, un chiste sobre el rate limit que se
  escapa un viernes a las 5pm, un 🪦 para jubilar un patrón. El humor
  desdramatiza la fricción de lo distribuido, no rellena.
- **Honesto sobre el costo operativo.** Un motor en memoria nuevo es
  superficie operativa nueva: se dice sin dramatizar y sin minimizar
  ("esto es rápido, y también es una guardia nueva que aprende evicción").
- **Orientado a la duda real.** Anticipa "¿y por qué no lo guardo directo en
  Postgres, si igual tengo la base ahí?" y la responde con números, no con
  fe.
- **Cercanía sin condescendencia.** El lector es senior. No le expliques qué
  es una transacción, un índice o un `SELECT ... FOR UPDATE`: **lo sabe de
  SQL**. Lo nuevo es cómo se ve esa misma necesidad resuelta —o no— en
  clave-valor.

Evitar: promesas vacías ("Redis lo resuelve todo"), motivación de coach,
solemnidad de manual corporativo, y explicar lo obvio para el perfil. El
humor es condimento, no plato principal.

> 🧠 **Matiz propio de Portalón (el eje del curso).** El lector no llega en
> blanco: llega con años de instintos relacionales sobre atomicidad,
> transacciones e índices. El tono reconoce esos instintos y los interpela
> de frente con las dos micro-secciones recurrentes de §7.4: 🪞 *"tu instinto
> SQL dice… y esta vez se equivoca"* y 🩻 *"esto sí funciona igual"*. Nunca
> se ridiculiza el instinto SQL: se lo honra y se lo recalibra.

---

## 3. Idioma y forma (narrativa)

- Español claro y técnico para todo lo que **no** es código (títulos,
  explicaciones, ejercicios, referencias). Los términos del stack se dejan
  en inglés cuando son el nombre real del comando, la estructura o el
  concepto: *sorted set*, *stream*, *pipeline*, *TTL*, *eviction*,
  *rate limit*, *sliding window*, *lock distribuido* se dice así aunque
  "candado distribuido" exista, porque es el término que el lector
  encontrará en la documentación. No se traducen forzadamente.
- Markdown siempre.
- Encabezados con emoji **con moderación** — uno por sección de plantilla.
  Los subtítulos internos pueden llevar emoji-tipo (§7) cuando aporta
  lectura rápida.
- **Prosa antes que listas.** Se prefiere explicar razonando en párrafos.
  Las listas se usan cuando son de verdad una lista (pasos, ítems
  paralelos, opciones de un árbol de decisión).
- **Tablas solo para comparar, decidir o mapear.** "Cuándo usar lista vs
  stream", matrices de decisión, el árbol ⚖️ de cuándo NO usar la familia, y
  —muy importante en este curso— **tablas de traducción SQL ↔
  clave-valor** (§7.4). No para narrar.

---

## 4. Idioma del código fuente (código en inglés, curso en español)

Esta sección es normativa para **todo** fragmento de código del curso, sea
en el cuerpo de una fase, en un ejercicio resuelto, en `vs.ts` o en un
apéndice.

### 4.1 Regla general

| Capa | Idioma | Ejemplo |
|---|---|---|
| **Código fuente** (identificadores) | 🇬🇧 Inglés | `function checkRateLimit(ip) {}`, `const isSessionValid = false` |
| **Rutas del gateway** | 🇬🇧 Inglés | `/gateway/rate-limit`, `/gateway/sessions/:id`, `/gateway/jobs` |
| **Comandos RESP/estructuras del motor** | 🇬🇧 Inglés (son el protocolo) | `INCR`, `EXPIRE`, `ZADD`, `LPUSH`, `XADD` |
| **Claves de Redis/Valkey/Dragonfly** | 🇬🇧 Inglés, con namespacing por `:` | `session:user:42`, `ratelimit:ip:203.0.113.7`, `leaderboard:support:weekly` |
| **Nombres de archivo, módulo, servicio** | 🇬🇧 Inglés | `rateLimiter.ts`, `sessionStore.ts`, `jobQueue.ts`, `vs.ts` |
| **Comentarios de código** | 🇪🇸 Español | `// el TTL expira sola la sesión; no hace falta un cron de limpieza` |
| **Textos de interfaz (UI), logs legibles, mensajes de error** | 🇪🇸 Español | `"Límite de peticiones alcanzado"`, `"Sesión expirada"` |
| **Narrativa del tutorial** | 🇪🇸 Español | Todo el texto fuera de bloques de código |

La app pedagógica **no tiene i18n**: es un gateway para lectores de habla
hispana. Los textos que ve o recibe quien consume la API —mensajes de
error, respuestas legibles— se escriben en español. Lo que va en inglés es
el código que lee y mantiene el equipo, y el **espacio de claves** del
motor: nombre de función, módulo, ruta, comando y clave.

> 📝 **Por qué esta regla.** Un gateway real mantenido por un equipo técnico
> suele tener código e identificadores en inglés (con comentarios en
> español, igual que acá), y las claves de Redis en producción casi siempre
> siguen una convención `namespace:entidad:id` en inglés porque así las lee
> cualquier operador con `KEYS`/`SCAN` o `redis-cli` sin traducir mentalmente.
> Escribir el pedagógico así deja al lector con el vocabulario que va a
> encontrar en un incidente real a las 3am.

### 4.2 Qué se traduce y qué no (criterio rápido)

| Elemento | ¿Inglés? | Ejemplo |
|---|---|---|
| `function`, `const`, `let` (nombre) | ✅ Sí | `function slideWindow(key)` |
| Namespace y segmentos de una clave | ✅ Sí | `job:queue:emails`, `lock:job:8823` |
| Nombres de campo en un hash (`HSET`) | ✅ Sí | `HSET session:42 userId 7 role agent expiresAt …` |
| Nombres de módulo/servicio/capa | ✅ Sí | `rateLimiter.ts`, `sessionService.ts`, `jobQueue.controller.ts` |
| Scripts Lua (identificadores internos) | ✅ Sí | `local currentCount = redis.call('GET', KEYS[1])` |
| Comentarios `//`, `/* */` | ❌ No | `// si ya expiró, el GET devuelve nil: tratamos como 0` |
| Strings de interfaz o de respuesta al cliente de la API | ❌ No | `{ error: 'Demasiadas peticiones, intenta de nuevo en unos segundos' }` |
| Nombres del dominio de negocio en la narrativa | ❌ No | El texto sigue hablando de "límite de peticiones", "sesión", "trabajo", "ranking" |

> ⚠️ **Caso mixto frecuente — mensajes de error y códigos de estado HTTP.**
> El objeto de respuesta usa keys en inglés (`{ error, code }`), pero el
> **valor** de `error` que ve quien consume la API va en español:
> `{ error: 'Sesión expirada, vuelve a iniciar sesión', code: 'SESSION_EXPIRED' }`.
> La **clave** de negocio (`SESSION_EXPIRED`) es el enum en inglés; el
> **valor** es lo que se lee en español.

### 4.3 Diccionario del dominio (Portalón)

Como referencia mínima, los términos centrales del gateway. El diccionario
completo con nombres de función y de claves vive, cuando el curso lo
produzca, en un `DICCIONARIO-CODIGO.md` propio.

| Español (dominio, narrativa) | Inglés (código / claves) |
|---|---|
| límite de peticiones | `rate limit` |
| ventana deslizante / ventana fija | `sliding window` / `fixed window` |
| sesión | `session` |
| invalidar (una sesión) | `invalidate` |
| trabajo / cola de trabajos | `job` / `job queue` |
| consumidor / grupo de consumidores | `consumer` / `consumer group` |
| tablero de clasificación / ranking | `leaderboard` |
| puntuación | `score` |
| candado distribuido | `distributed lock` |
| desalojo (de memoria) | `eviction` |
| tiempo de vida / expiración | `TTL` / `expiration` |
| motor primario / capa caliente | `primary store` / `hot layer` |

### 4.4 Convenciones de nombrado

- **Funciones y variables:** `camelCase` en inglés — `checkRateLimit`,
  `isSessionExpired`, `enqueueJob`.
- **Constantes de configuración:** `SCREAMING_SNAKE_CASE` —
  `RATE_LIMIT_WINDOW_MS`, `SESSION_TTL_SECONDS`, `MAX_QUEUE_RETRIES`.
- **Rutas del gateway:** sustantivo, inglés — `/rate-limit/check`,
  `/sessions/:id`, `/jobs`, `/leaderboard/:boardId/top`.
- **Claves del motor:** `namespace:entidad:identificador`, siempre en
  inglés y en minúsculas — `ratelimit:ip:203.0.113.7`,
  `session:user:42`, `queue:emails`, `leaderboard:support:weekly`.
- **Nombres de archivo/servicio:** `<dominio>Service.ts` o
  `<dominio>.routes.ts` — `rateLimiter.ts`, `sessionStore.ts`,
  `jobQueue.ts`, `leaderboard.routes.ts`.
- **Scripts Lua:** archivo `.lua` con nombre descriptivo del algoritmo,
  inglés — `slidingWindowIncrement.lua`, `compareAndInvalidate.lua`.

### 4.5 Lo que nunca cambia

- **Comentarios de código:** 100% español, explicando el porqué (§5).
- **Textos de interfaz / respuestas legibles de la API:** 100% español.
- **Narrativa del tutorial:** 100% español.
- **Nombres propios del dominio en la narrativa:** "sesión", "trabajo",
  "ranking", "límite de peticiones" siguen siendo las palabras con que
  *hablas* del sistema, aunque el código diga `session`, `job`,
  `leaderboard`, `rateLimit`.

---

## 5. Orientación a la práctica

Cada concepto se ancla en el dominio de Portalón y en código que corre.

- **Nada de teoría suelta.** Si se explica `WATCH`/`MULTI`/`EXEC`, se
  explica sobre el doble-consumo de un trabajo de la cola, no en abstracto.
  Si se explica evicción, es sobre qué le pasa al leaderboard cuando la
  memoria se llena, no con `maxmemory-policy` en el aire.
- **Código ejecutable y coherente.** Todo fragmento corre con las versiones
  fijadas del stack (Valkey 9.x / Redis 8.x / Dragonfly 1.x / PostgreSQL
  17.x / Node 24 LTS / TypeScript 5.x) y no contradice fases anteriores.
  Nada de pseudocódigo que "se entiende".
- **Código mínimo.** El fragmento más pequeño que muestra el punto, pero
  ejecutable contra los motores reales del laboratorio.
- **Comentarios que explican el porqué, no el qué, siempre en español.**
  `// usamos ZADD con score = timestamp para que el ranking se mantenga
  ordenado sin recalcular` sí; `// suma uno` no.
- **Distinguir capas.** Siempre queda claro si una decisión vive en el
  middleware del gateway, en el cliente RESP, o en el propio motor. Es la
  distinción que salva a quien depura un rate limit que se escapa.

---

## 6. Manejo del villano (el corazón del curso)

- **El villano se construye, no se narra.** "Redis como base de datos
  primaria" no es una advertencia abstracta: el curso monta un subsistema
  villano real —por ejemplo, usuarios y sus relaciones en estructuras
  clave-valor— y lo mide con el mismo `vs.ts` que todo lo demás (Fase 11).
- **El villano también respeta §4.** Sus claves y su código están en
  inglés, igual que el resto del curso: la fealdad que se enseña es de
  diseño y de decisión arquitectónica, no de idioma.
- **Corrección mínima vs rediseño.** Ante un incidente del villano, se
  distingue el parche mínimo (lo que va en un hotfix, si acaso lo hay) del
  rediseño real (moverlo a Postgres), y se deja claro cuál es la lección.
- **El olor del villano se nombra por su estructura, no por su intención.**
  Ausencia de índice secundario, dependencia de `KEYS`/`SCAN` para lo que
  debería ser una consulta, y datos que no se reconstruyen si el proceso
  muere son las señales que el curso enseña a detectar.

---

## 7. Marcadores y callouts (vocabulario visual del curso)

Este vocabulario se usa igual en todos los documentos para que el lector lo
reconozca de un vistazo.

### 7.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Todo shortcut o patrón que se deja a
  propósito y se paga explícitamente en otra fase.
- 🔥 **Opcional / ampliación.** Ejercicios o secciones que exceden el
  alcance base.
- ⭐ **Fase o pieza central.** La Fase 4 (leaderboard) y la Fase 11
  (autopsia) llevan esta marca.
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil / intermedio / difícil / muy
  difícil (§9).

### 7.2 Callouts en blockquote (emoji-tipo)

- 📝 **Nota de época.** Contexto histórico de una decisión de versión o de
  gobernanza. Ej: "en 2024 Redis cambió de licencia; así nació Valkey."
- 📚 **Referencia rápida inline.** Un enlace útil justo donde surge la duda,
  sin esperar a la sección de referencias del final de la fase.
- 🪦 **Retiro / jubilación.** Cuando un enfoque cumple su función y se
  retira. Ej: "🪦 se jubila el contador de ventana fija: la deslizante lo
  reemplaza desde aquí."
- ⚠️ **Advertencia.** Algo que rompe si lo ignoras (diferencia de comandos
  entre motores, madurez de un binding de cliente, versión incompatible).
- 💡 **Truco o atajo** que ahorra tiempo real.

### 7.3 Secciones narrativas recurrentes (comunes)

- **💸 Pago de deuda.** Dónde se salda una deuda declarada antes.
- **Detalles con intención.** Lista corta que destila las decisiones
  deliberadas de un bloque ("usamos `ZADD` con `NX` porque no queremos
  pisar el score si el jugador ya está en el ranking").
- **El patrón a memorizar.** Una o dos frases que extraen la lección
  transferible.
- **Prueba de fuego.** Verificación manual concreta: "apaga el gateway,
  golpea el backend directo con 500 req/s, míralo ahogarse; enciende el
  gateway, repite, míralo respirar."
- **La señal de que quedó bien.** En el cierre, un criterio en forma de
  cita.

### 7.4 Secciones propias del curso (SQL → clave-valor)

Estas cuatro son la columna vertebral del curso y aparecen cuando el
contenido lo pide:

- **📖 Tabla de traducción SQL ↔ clave-valor.** Lado a lado, la operación
  relacional y su equivalente en comandos RESP. Ej:
  `SELECT COUNT(*) FROM requests WHERE ip=? AND ts > now()-60` ↔
  `ZCOUNT ratelimit:ip:203.0.113.7 (now-60) +inf`. Es tabla (§3), no prosa.
- **🪞 "Tu instinto SQL dice… y esta vez se equivoca."** Nombra la trampa
  **antes** de caer: la tabla `requests` con índice para contar peticiones,
  la sesión guardada "por si acaso" en la base transaccional, el `SELECT
  ... FOR UPDATE SKIP LOCKED` como respuesta universal a toda cola. Honra el
  instinto y lo recalibra con un número de `vs.ts`.
- **🩻 "Esto sí funciona igual."** Lo reconfortante: la atomicidad, el
  optimistic locking (`WATCH` como primo de `SELECT ... FOR UPDATE`), y la
  idea de índice (una sorted set *es* un índice mantenido incrementalmente)
  siguen valiendo lo que valían en SQL. Baja la ansiedad del lector.
- **⚰️ Caso de estudio: el villano.** El subsistema "todo en clave-valor"
  mal diseñado: se mide, duele, se compara contra su equivalente honesto en
  Postgres. Es el hilo que cose la Fase 11.

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden:

1. **🎯 Propósito** — qué resuelve esta fase; puede abrir con la situación
   heredada ("hasta ahora el rate limit vive en la cabeza de nadie…").
2. **✅ Qué queda listo al terminar** — checklist verificable.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase.
4. **🧠 Conceptos mínimos** — solo lo necesario, anclado al dominio. Aquí
   viven la 📖 tabla de traducción y los recuadros 🪞/🩻.
5. **💻 Implementación y código comentado** — el grueso; código ejecutable
   contra los motores reales, con comentarios de porqué, identificadores en
   inglés (§4). Aquí caben **Detalles con intención**, **El patrón a
   memorizar**, **Prueba de fuego** y **💸 Pago de deuda**.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente (una
   ráfaga que se escapa, una sesión que no expira, un trabajo consumido dos
   veces) y cómo depurarlo.
7. **🧪 Ejercicios progresivos** — 20 a 40 (§9), anclados al dominio de
   Portalón.
8. **📚 Referencias** — al **final del capítulo**, con el formato de §10.
   Ninguna fase se da por cerrada sin esta sección.
9. **🚀 Cierre y conexión con la siguiente fase** — qué sigue y por qué.
   Aquí va **La señal de que quedó bien**.

Los apéndices no siguen esta plantilla: usan índice de salto rápido +
secciones cortas + tabla "cuándo usar qué" + 5-10 ejercicios cortos.

---

## 9. Ejercicios

- **Cantidad: 20 a 40 por fase**, según lo que justifique la semilla
  (`01-portalon-semilla.md` §🧪 Nota sobre ejercicios). Para ~30 ejercicios,
  la distribución sugerida es ~8 🟢, ~9 🟡, ~7 🟠, ~4–6 🔴, más los 🔥 aparte.
- **Diverso nivel de dificultad, siempre presente.** Ninguna fase se
  entrega solo con ejercicios de un nivel: los 🟢 calientan con comandos
  básicos y TTL; los 🟡 combinan dos operaciones (ventana deslizante, set de
  sesiones); los 🟠 exigen scripting o paginación; los 🔴 integran varias
  fases, miden en `vs.ts` o cierran una condición de carrera bajo
  contención real.
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
- **Progresión real.** Los 🟢 calientan; los 🔴 exigen integrar varias fases
  o depurar algo esquivo (medir un duelo en `vs.ts`, reproducir un doble
  consumo, cerrar una condición de carrera bajo ráfaga).
- **Accionables y verificables.** "Haz que el rate limit de la IP
  `203.0.113.7` no se pueda saltar con ráfagas de 200 req en 100ms" — no
  "reflexiona sobre concurrencia".
- **Algunos de diagnóstico.** Al menos un puñado por fase entrega un bug
  —un rate limit que se escapa, una sesión que no expira, un trabajo
  duplicado— y pide **reproducir y localizar**, no solo construir.
- **Enganchados al dominio.** Usan IPs, sesiones, trabajos y jugadores
  reales del gateway, nunca ejemplos abstractos tipo `foo`/`bar`.
- **Cuando un ejercicio nombra código, usa el identificador en inglés
  vigente** ("agrega el TTL a la clave `session:user:42`", "escribe
  `slidingWindowIncrement.lua`"), aunque el enunciado en sí esté en español.
- **Sin voseo en ningún enunciado.** "Implementa", "mide", "reproduce" —
  nunca "implementá", "medí", "reproducí".
- Los 🔥 son opcionales y se listan aparte, sin numeración continua.

En apéndices bastan 5-10 ejercicios cortos de consulta.

---

## 10. Bibliografía y referencias (obligatorias al final de cada capítulo)

**Regla:** documentación oficial del motor/versión fijada **primero**;
luego el rival de control (PostgreSQL); luego libros; luego blogs, videos y
tutoriales. Siempre se advierte cuando un enlace apunta a una versión
distinta de la fijada.

### 10.1 Dónde van

Cada fase (sección 8 de la plantilla de 9) cierra con su propio bloque
`## 📚 Referencias`, **al final del capítulo**, nunca disperso ni al
principio. No es una sección compartida entre fases: cada `.md` de fase
lleva la suya, aunque repita entradas de la lista base.

### 10.2 Formato

- **URLs completas y clicables**, no solo el dominio.
- **Secciones separadas** dentro de "Referencias": Documentación oficial
  (con URL completa y nota de versión), Libros cuando apliquen, Video/apoyo
  (screencasts, crash courses en YouTube con URL completa), y **Orden de
  lectura sugerido** (una línea que encadena qué leer primero).

### 10.3 Fuentes oficiales base (usar URL completa al citar)

- **Valkey:** https://valkey.io/docs/ (verificar línea 9.x)
- **Redis:** https://redis.io/docs/latest/ (verificar línea 8.x y licencia AGPLv3)
- **Dragonfly:** https://www.dragonflydb.io/docs (verificar compatibilidad de comandos)
- **PostgreSQL:** https://www.postgresql.org/docs/17/ (rival de control)
- **Node.js 24 LTS:** https://nodejs.org/docs/latest-v24.x/api/
- **Express 5:** https://expressjs.com/ (verificar que la doc es de la v5)

### 10.4 Advertencias

- **Sobre citas:** cuando se mencione un artículo, libro, video o post
  específico, se deja claro que URLs y títulos pueden estar desactualizados
  o ser inexactos; el lector debe verificarlos. No se inventan números de
  página, DOIs ni IDs de video.
- **No usar como referencia principal:** benchmarks de marketing de
  ninguno de los tres motores (§ regla del arnés en la semilla — "si el
  número no salió de `vs.ts` en tu máquina, no entra en `BENCHMARKS.md`");
  documentación de versiones distintas a las fijadas del stack (Valkey 9.x,
  Redis 8.x, Dragonfly 1.x, PostgreSQL 17.x, Node 24 LTS, Express 5.x) salvo
  para contraste explícito de versión.

---

## 11. Sobre el dominio (ficticio, sin NDA)

Portalón es un gateway **enteramente ficticio**: no protege ningún backend
real ni disfraza un sistema en producción. Esto simplifica dos cosas:

- Los ejemplos pueden ser todo lo concretos que convenga (IPs, sesiones,
  trabajos y jugadores sintéticos); no hace falta "generalizar ante la
  duda".
- El vocabulario del dominio (rate limit, sesión, trabajo, leaderboard) es
  estable y se fija en §4.3; no compite con ningún vocabulario "real" que
  haya que evitar.

La regla de idioma del código (§4) es una convención de calidad, no una
cuestión de NDA.

---

## 12. Coherencia entre documentos

- **No contradecir fases anteriores.** Una clave o un nombre de campo que
  la Fase 1 fija (`ratelimit:ip:<ip>`) no cambia de forma en la Fase 6 sin
  documentarlo.
- **No reescribir decisiones aprobadas** sin señalar explícitamente la
  incompatibilidad y por qué.
- **Fuentes de verdad, en orden:** (1) instrucciones del proyecto, (2)
  `RUTA-NOSQL-FUNDAMENTOS.md`, (3) `01-portalon-semilla.md`, (4)
  entregables aprobados de fases anteriores, (5) decisiones explícitas del
  chat actual.
- Nombres de archivos, módulos, servicios, rutas y claves se mantienen
  estables entre fases (en inglés, §4.4). Si algo se renombra, se documenta
  el cambio.

---

## 13. Post-mortems e incidentes (Fase 6 y Fase 11 especialmente)

Cada incidente sigue esta estructura de ocho puntos:

1. Síntoma.
2. Pasos de reproducción.
3. Evidencia observable (`SLOWLOG`, métricas del cliente, salida de `vs.ts`).
4. Causa raíz.
5. Corrección.
6. Prueba de regresión.
7. Prevención.
8. Post-mortem **sin culpabilización** (blameless): se analiza el sistema y
   el proceso, no a la persona.

El tono del post-mortem es sereno y analítico. El humor cálido del resto
del curso baja un punto aquí: un post-mortem es serio, aunque no acartonado.

---

## 14. Checklist rápido antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono cálido e informal, segunda persona **sin voseo**, humor con
  moderación.
- [ ] Todo el código corre con las versiones fijadas del stack.
- [ ] **Identificadores, rutas, claves, comandos y constantes del código en
  inglés (§4).**
- [ ] **Comentarios de código y textos de interfaz/respuestas de API en
  español (§4.5).**
- [ ] No contradice ninguna fase anterior; respeta `01-portalon-semilla.md`.
- [ ] Distingue capas (middleware / cliente RESP / motor) donde importa.
- [ ] Usa el vocabulario de callouts (📝 🪦 📚 ⚠️ 💡) y los recuadros
  📖 🪞 🩻 ⚰️ donde aporten.
- [ ] Marca 💸 la deuda técnica (y la paga si corresponde) y 🔥 lo opcional.
- [ ] Tiene 20-40 ejercicios numerados con rangos 🟢🟡🟠🔴 equilibrados y de
  **diverso nivel de dificultad** (o 5-10 en apéndices).
- [ ] Todo "vs" citado en la fase viene de `BENCHMARKS.md`, nunca narrado
  sin número.
- [ ] **Referencias al final del capítulo**, con URL completa, secciones
  (oficial / libros / video / orden de lectura) y advertencia de versión.
- [ ] Explica el *porqué* de cada decisión relevante.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
