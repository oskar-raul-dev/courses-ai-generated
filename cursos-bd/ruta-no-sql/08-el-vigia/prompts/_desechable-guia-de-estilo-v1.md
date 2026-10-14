# ✍️ Guía de estilo, tono y convenciones — El Vigía

## Curso de Series Temporales (Ruta NoSQL, curso #8)

Esta guía deriva de `GUIA-DE-ESTILO-Y-CONVENCIONES.md` (curso legacy) y de
`08-el-vigia-semilla.md`, adaptada al modelo de acceso de series temporales y
a un dominio propio: **monitoreo de métricas de infraestructura**, medido
contra InfluxDB 3 Core, TimescaleDB y las colecciones Time Series de MongoDB.
Es la fuente de verdad editorial de todo `.md` que se produzca para este
curso.

> 🧭 **Regla de una línea que rige todo el código:** el **código en inglés**;
> todo lo demás —narrativa, comentarios, textos de interfaz, UI del
> tablero— **en español**. Detalle completo en §4.
>
> 🧭 **Regla de tratamiento:** el lector se trata de **"tú"**, nunca de
> "vos". Ningún voseo en ningún documento del curso, en ningún callout, en
> ningún enunciado de ejercicio.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien mida antes de afirmar.** No
enseñamos InfluxDB o TimescaleDB "de moda": enseñamos a reconocer un patrón
de acceso temporal, elegir con criterio entre las respuestas serias del
mercado, y descartar el modelo cuando no toca. Si un párrafo no ayuda a
diseñar, medir, diagnosticar o decidir, sobra.

El norte del curso es una sola señal de éxito, la que cierra la Fase 11:
**poder mirar cualquier tabla con un `timestamp` y decidir, con números en la
mano, si le toca partición temporal, compresión columnar y retención
escalonada — o si el villano ya la tiene tomada.** Todo lo que se escribe
sirve a esa promesa.

---

## 2. Tono

El tono es **cálido, informal y directo** — de colega senior a colega senior,
con humor cuando cae bien. Es alguien que ya vio una tabla de tres mil
millones de filas con `VACUUM` sin terminar a las 3 am, explicándotelo con
confianza y sin solemnidad.

- **Segunda persona, cercana, sin voseo.** "Apaga el generador y mira cómo
  se degrada la ingesta", "si el índice sobre `timestamp` te tienta, primero
  mide". Nunca "vos apagás", nunca "fijate". Siempre "tú", "mira", "fíjate".
- **Humor seco permitido.** Un 😉, un chiste sobre el `VACUUM` que nunca
  termina, un 🪦 para jubilar el villano cuando se lo reemplaza. El humor
  desdramatiza la fricción de operar a escala; no rellena.
- **Honesto sobre lo feo.** Cuando el villano es un desastre (y lo es a
  propósito), se dice con gracia: "esta tabla funciona en la demo con diez
  mil filas y es una bomba de tiempo a partir de la fila tres mil millones".
  No se finge elegancia donde no la hay.
- **Orientado a la duda real.** Anticipa "¿y esto por qué se hace así en
  InfluxDB y no en Postgres?" y la responde, muchas veces con una nota que da
  contexto de por qué la generación 3 de InfluxDB (reescrita en Rust, motor
  columnar) es la referencia vigente y no la 1.x/2.x.
- **Cercanía sin condescendencia.** El lector es senior de bases
  relacionales. No le expliques qué es un índice, una transacción o un plan
  de consulta: **lo sabe de SQL**. Lo nuevo es cómo cambia (o no) frente al
  eje temporal.

> 🧠 **Matiz propio de El Vigía (el eje del curso).** El lector no llega en
> blanco: llega con años de instinto relacional. El tono reconoce esos
> instintos y los interpela de frente con dos recuadros recurrentes (§7.3):
> 🪞 *"tu instinto SQL dice… y esta vez se equivoca"* y 🩻 *"esto sí viaja
> igual"*. El instinto SQL se honra y se recalibra; nunca se ridiculiza.

Evitar: promesas vacías ("vas a dominar InfluxDB"), motivación de coach,
solemnidad de manual corporativo, explicar lo obvio del mundo relacional. El
humor es condimento, no plato principal.

---

## 3. Idioma y forma (narrativa)

- Español claro y técnico para todo lo que **no** es código (títulos,
  explicaciones, ejercicios, referencias). Los términos del stack se dejan
  en inglés cuando son el nombre real y no tienen traducción estándar de
  uso: *hypertable*, *chunk*, *continuous aggregate*, *retention policy*,
  *downsampling*, *tag*, *field*, *line protocol*, *bucket pattern*,
  *time bucket*, *gap-filling*, *cardinality*. No se traducen forzadamente.
- Markdown siempre.
- Encabezados con emoji **con moderación** — uno por sección de plantilla.
  Los subtítulos internos pueden llevar emoji-tipo (§7) cuando aporta
  lectura rápida.
- **Prosa antes que listas.** Se prefiere explicar razonando en párrafos.
  Las listas se usan cuando son de verdad una lista (pasos, ítems
  paralelos).
- **Tablas solo para comparar, decidir o mapear.** "Cuándo usar InfluxDB vs.
  TimescaleDB vs. Mongo Time Series", el marco de 5 preguntas, y —muy
  importante en este curso— las **tablas de traducción SQL ↔ cada motor**
  (§7.3). No para narrar.

---

## 4. Idioma del código fuente (código en inglés, curso en español)

Normativa para todo fragmento de código de El Vigía, sea en el cuerpo de una
fase, en un incidente, en un apéndice o en un ejercicio resuelto.

### 4.1 Regla general

| Capa | Idioma | Ejemplo |
|---|---|---|
| **Código fuente** (identificadores) | 🇬🇧 Inglés | `function computeP99Latency() {}`, `const cardinalityLimit = 50_000` |
| **Endpoints de la API de tablero** | 🇬🇧 Inglés | `/metrics/recent`, `/metrics/aggregate`, `/metrics/compare` |
| **Nombres de measurement / hypertable / colección** | 🇬🇧 Inglés | `cpu_usage`, `hypertable('metrics')`, `db.collection('metrics')` |
| **Tags y fields (InfluxDB) / columnas (Timescale) / campos (Mongo)** | 🇬🇧 Inglés | `host`, `region`, `metric_name`, `value` |
| **Constantes y variables de configuración** | 🇬🇧 Inglés | `RETENTION_HOT_DAYS`, `SAMPLE_INTERVAL_MS` |
| **Nombres de archivo, módulo, servicio** | 🇬🇧 Inglés | `metricsGenerator.ts`, `dashboardApi.ts`, `vs.ts` |
| **Comentarios de código** | 🇪🇸 Español | `// el índice engorda porque nada está particionado` |
| **Textos de interfaz (tablero, Grafana opcional)** | 🇪🇸 Español | `"Uso de CPU"`, `"Últimos 15 minutos"` |
| **Narrativa del tutorial** | 🇪🇸 Español | Todo el texto fuera de bloques de código |

> 📝 **Por qué esta regla.** El código de un sistema de observabilidad real
> mantenido por un equipo técnico suele estar en inglés (con comentarios en
> español, igual que aquí). Escribir el pedagógico así hace que el
> vocabulario de identificadores sea el mismo que el lector va a encontrar
> en producción, y que el generador, el arnés `vs.ts` y la API de tablero
> nombren lo mismo de la misma forma en los tres motores.

### 4.2 Diccionario del dominio (El Vigía)

| Español (dominio, narrativa, UI) | Inglés (código) |
|---|---|
| host / máquina | `host` |
| métrica | `metric` |
| etiqueta | `tag` |
| valor (de una medición) | `value` / `field` |
| ventana (de tiempo) | `window` |
| rango | `range` |
| retención | `retention` |
| envejecimiento / poda | `downsampling` / `pruning` |
| cardinalidad | `cardinality` |
| serie (identidad única de tags) | `series` |
| cubo (bucket pattern manual) | `bucket` |
| agregado continuo | `continuous aggregate` |
| resolución completa | `full resolution` |
| histórico | `historical` |
| tablero | `dashboard` |
| flota (conjunto de hosts) | `fleet` |

Los nombres de measurements, hypertables, colecciones, endpoints y módulos se
arman combinando estos términos con los verbos técnicos habituales (`get`,
`compute`, `ingest`, `retain`, `downsample`, `compare`).

### 4.3 Convenciones de nombrado

- **Funciones y variables:** `camelCase` en inglés — `ingestBatch`,
  `isCardinalityHealthy`, `retentionCutoffMs`.
- **Constantes de configuración:** `SCREAMING_SNAKE_CASE` —
  `RETENTION_HOT_DAYS`, `MAX_SERIES_CARDINALITY`, `SAMPLE_INTERVAL_MS`.
- **Endpoints REST de la API de tablero:** sustantivo en plural o acción
  clara, inglés — `/metrics/recent`, `/metrics/window-compare`.
- **Measurements de InfluxDB / hypertables de Timescale / colecciones de
  Mongo:** `snake_case` en inglés — `cpu_usage`, `disk_io`, `network_latency`.
- **Tags:** nombres cortos en inglés, sin alta cardinalidad por diseño —
  `host`, `region`, `env`. Nunca un identificador único de evento como tag
  (ver el villano de cardinalidad, Fase 4).
- **Campos del generador y del arnés `vs.ts`:** `camelCase` — `p50`, `p95`,
  `p99`, `diskBytesCompressed`, `runsDiscardedAsWarmup`.

### 4.4 Lo que nunca cambia

- **Comentarios de código:** 100% español, explicando el porqué (§5).
- **Textos de interfaz de usuario** (tablero, alertas legibles, tooltips):
  100% español.
- **Narrativa del tutorial:** 100% español, sin voseo.
- **Nombres propios del dominio en la narrativa:** "host", "métrica",
  "ventana", "retención" siguen siendo las palabras con las que *hablas* del
  sistema, aunque el código diga `host`, `metric`, `window`, `retention`.

---

## 5. Orientación a la práctica

Cada concepto se ancla en el dominio del monitoreo y en código que corre.

- **Nada de teoría suelta.** Si se explica partición temporal, se explica
  sobre `cpu_usage` de una flota real de hosts, no en abstracto. Si se
  explica cardinalidad, es sobre el tag `request_id` que no debía existir,
  no sobre un ejemplo genérico de "alta cardinalidad".
- **Código ejecutable y coherente.** Todo fragmento corre con las versiones
  fijadas del stack (§Stack de la semilla) y no contradice fases anteriores.
  Nada de pseudocódigo que "se entiende".
- **Código mínimo.** El fragmento más pequeño que muestra el punto, pero
  ejecutable.
- **Comentarios que explican el porqué, no el qué, siempre en español.**
  `// se descarta el warm-up: las primeras corridas mienten sobre la latencia
  real` sí; `// suma uno al contador` no.
- **Distinguir motores.** Siempre queda claro si un comportamiento vive en
  InfluxDB, en TimescaleDB/Postgres, en MongoDB, o en la capa de generador o
  API propia. Es la distinción que salva al que después tiene que decidir
  cuál motor usar en un proyecto real.

---

## 6. El villano y su contracara (el corazón del curso)

- **No se suaviza el villano.** La tabla `metrics(id, timestamp, metric,
  host, value)` con índice B-tree sobre `timestamp` se construye de verdad,
  se carga hasta que duele, y se mide antes/después. No se resume "esto no
  escala" sin números.
- **El crimen inverso se nombra con la misma seriedad.** Montar InfluxDB o
  TimescaleDB para datos que se actualizan y se consultan por entidad —no
  por ventana de tiempo— es el mismo villano con la cara cambiada. Cada vez
  que el curso muestra la victoria de un motor temporal, también recuerda el
  límite de esa victoria.
- **Nada se afirma sin `vs.ts`.** Ninguna frase "X es más rápido que Y" o
  "X comprime mejor" entra a una fase sin pasar por el arnés y quedar
  registrada en `BENCHMARKS.md`. Los benchmarks de marketing de cualquiera
  de los tres motores se citan solo para contrastarlos con lo medido, nunca
  como fuente de verdad.

---

## 7. Marcadores y callouts (vocabulario visual del curso)

### 7.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Todo shortcut que se deja a propósito
  en el laboratorio (sin auth, sin HA, retención mínima en desarrollo). Se
  declara en una fase y, si corresponde, se paga en otra.
- 🔥 **Opcional / ampliación.** Ejercicios o secciones que exceden el
  alcance base (ver `EL-VIGIA-ALCANCE.md` §2).
- ⭐ **Fase o pieza central.** Fases 5 (roll-ups y downsampling) y 7
  (bucket pattern vs. Time Series nativo de Mongo).
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil / intermedio / difícil / muy
  difícil.

### 7.2 Callouts en blockquote (emoji-tipo)

- 📝 **Nota de época / versión.** Contexto sobre por qué se fija la
  generación 3 de InfluxDB y no la 1.x/2.x, o por qué Time Series nativo de
  Mongo cambia el panorama frente al bucket pattern manual.
- 📚 **Referencia rápida inline.** Un enlace útil justo donde surge la duda,
  sin esperar a la sección de referencias del cierre de fase.
- 🪦 **Retiro / jubilación.** Cuando el villano se reemplaza. Ej.: "🪦 se
  jubila la tabla `metrics` genérica: ya cumplió su función de doler."
- ⚠️ **Advertencia.** Algo que rompe si se ignora (versión incompatible,
  cardinalidad que tumba el contenedor, etc.).
- 💡 **Truco o atajo** que ahorra tiempo real.

### 7.3 Secciones propias de El Vigía (SQL → motor temporal)

Estas cuatro son la columna vertebral del curso y aparecen cuando el
contenido lo pide:

- **📖 Tabla de traducción SQL ↔ motor.** Lado a lado, la consulta
  relacional y su equivalente en InfluxDB / TimescaleDB / Mongo. Ej.:
  `SELECT date_trunc('hour', ts), avg(value) FROM metrics GROUP BY 1` ↔
  `SELECT time_bucket('1 hour', time), avg(value) FROM cpu_usage GROUP BY 1`
  (Timescale) ↔ el equivalente en InfluxDB y en la agregación de Mongo. Es
  tabla (§3), no prosa.
- **🪞 "Tu instinto SQL dice… y esta vez se equivoca."** Nombra la trampa
  **antes** de caer: "le pongo un índice al timestamp y listo", "un tag más
  no cuesta nada", "ya hago el downsampling con un `GROUP BY` nocturno".
  Honra el instinto y lo recalibra.
- **🩻 "Esto sí viaja igual."** Lo reconfortante: SQL, `EXPLAIN`,
  selectividad de índice, la idea de throughput vs. latencia y por qué las
  colas mienten — todo eso cruza intacto, sobre todo hablando con
  TimescaleDB. Baja la ansiedad del lector.
- **⚰️ Caso de estudio: la autopsia del villano.** La tabla genérica medida
  de punta a punta, con números antes/después. Es el hilo que cose las fases
  1 a 11.

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden:

1. **🎯 Propósito** — qué resuelve esta fase; puede abrir con la situación
   heredada ("hasta ahora el `timestamp` es una columna más en una tabla
   genérica…").
2. **✅ Qué queda listo al terminar** — checklist verificable.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase (ver
   también `EL-VIGIA-ALCANCE.md` §2 para lo que queda fuera del curso
   entero).
4. **🧠 Conceptos mínimos** — solo lo necesario, anclado al dominio del
   monitoreo. Aquí suelen vivir la 📖 tabla de traducción y los recuadros
   🪞/🩻.
5. **💻 Implementación y código comentado** — el grueso; código ejecutable
   con comentarios de porqué, identificadores en inglés (§4). Aquí caben
   **Detalles con intención**, **El patrón a memorizar**, **Prueba de
   fuego** y **💸 Pago de deuda** si aplica.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente
   (índice que engorda, cardinalidad explotada, retención que borra de más)
   y cómo depurarlo con `EXPLAIN`/profiler del motor correspondiente.
7. **🧪 Ejercicios progresivos** — 20 a 40, graduados 🟢🟡🟠🔴 (§9).
8. **📚 Referencias** — obligatoria en **todo** documento de fase y en todo
   apéndice, sin excepción (§10). Ningún `.md` de fase se da por cerrado sin
   su sección de referencias propia al final.
9. **🚀 Cierre y conexión con la siguiente fase** — qué sigue y por qué.
   Aquí va **"La señal de que quedó bien"**.

Los apéndices no siguen esta plantilla completa: usan índice de salto rápido
+ secciones cortas + tabla "cuándo usar qué" + 5 a 10 ejercicios cortos +
**su propia sección de referencias al cierre**, igual que las fases.

---

## 9. Ejercicios

- **Cantidad: 20 a 40 por fase**, según lo que la semilla fije para cada
  una (la mayoría de fases apunta a ~30; fases de montaje o cierre pueden
  tener menos). Menos de 20 se queda corto para un modelo con tres motores
  en juego.
- **Distribución equilibrada por nivel.** Reparte parejo entre
  🟢🟡🟠🔴. Guía razonable para ~30: ~8 🟢, ~9 🟡, ~7 🟠, ~5-6 🔴, más los 🔥
  opcionales aparte.
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
- **Progresión real.** Los 🟢 calientan (escribir una consulta de rango,
  crear una hypertable, insertar con line protocol). Los 🔴 exigen integrar
  varias fases o depurar algo esquivo (comparar compresión medida entre dos
  motores, cerrar un caso de cardinalidad descontrolada, optimizar ingesta a
  un percentil objetivo).
- **Accionables y verificables.** "Diseña una política de retención que
  conserve resolución completa 7 días y promedios horarios 1 año, y mide el
  crecimiento de disco con y sin ella" — no "reflexiona sobre la retención".
- **Al menos un puñado por fase de diagnóstico.** Se entrega un motor mal
  configurado (índice que engorda, cardinalidad explotada, retención que
  borra lo que no debía, downsampling que promedia mal) y se pide
  **reproducir y localizar** con `EXPLAIN`/profiler antes de arreglar.
- **Enganchados al dominio.** Usan hosts, métricas, tags, ventanas y
  retención — no ejemplos abstractos de "series numéricas".
- **Sin voseo en el enunciado**, igual que el resto del documento.
- **Cuando un ejercicio nombra código, usa el identificador en inglés
  vigente** ("agrega el campo `cardinalityLimit`", "escribe
  `computeP99Latency`"), aunque el enunciado en sí esté en español.
- Los 🔥 son opcionales y se listan aparte, sin numeración continua (comparar
  contra un cuarto motor, integrar Grafana, simular una flota de 10k hosts).

En apéndices bastan 5 a 10 ejercicios cortos de consulta.

---

## 10. Bibliografía y referencias

**Regla:** documentación oficial de la versión vigente del stack
**primero**; luego libros; luego blogs, videos y screencasts. Siempre se
advierte cuando un enlace podría apuntar a docs de una generación distinta
(InfluxDB 1.x/2.x vs. 3.x es el riesgo principal de este curso).

### 10.1 Formato — obligatorio al cierre de cada fase y apéndice

- **URLs completas y clicables**, no solo el dominio.
- **Cada `.md` de fase y de apéndice termina con su propia sección
  `## 📚 Referencias`**, aunque el tema se repita entre fases: se cita lo
  que esa fase específica usó, no un enlace genérico al inicio del curso.
- **Secciones separadas** dentro de "Referencias": Documentación oficial
  (con URL completa y nota de versión), Libros cuando apliquen, Video/apoyo
  (screencasts, crash courses con URL completa), y **Orden de lectura
  sugerido** cuando la fase mezcla más de una fuente.

### 10.2 Fuentes oficiales por motor (usar URL completa al citar)

- **InfluxDB 3 Core:** `https://docs.influxdata.com/` (navegar a la sección
  de InfluxDB 3 Core; verificar que no resuelva a docs de 1.x/2.x).
- **TimescaleDB / Tiger Data:** `https://docs.tigerdata.com/` (verificar; el
  dominio de docs migró de `docs.timescale.com`).
- **PostgreSQL 17/18:** `https://www.postgresql.org/docs/` (elegir la
  versión fijada en la Fase 0).
- **MongoDB Time Series:**
  `https://www.mongodb.com/docs/manual/core/timeseries-collections/`
  (verificar contra la versión 8.x fijada).
- **Node.js 24 LTS:** `https://nodejs.org/docs/latest-v24.x/api/`.

### 10.3 Advertencias

- **Sobre citas:** cuando se mencione un artículo, libro, video o post
  específico, hay que dejar claro que URLs y títulos pueden estar
  desactualizados o ser inexactos; el lector debe verificarlos. No se
  inventan números de página, DOIs ni IDs de video.
- **No usar en el código principal:** InfluxDB 1.x/2.x (Go, legacy), ni
  versiones de Timescale incompatibles con el Postgres fijado. Las
  alternativas legacy aparecen solo como contraste histórico (📝) o en un
  apéndice, nunca en el código base del curso.

---

## 11. Sobre el dominio (sintético, sin NDA)

El dataset de telemetría de El Vigía es **enteramente sintético**, generado
por el módulo propio del curso: no hay confidencialidad que preservar ni
sistema real que disfrazar. Esto simplifica dos cosas:

- La cardinalidad y la cadencia son **parametrizables a propósito**, para
  que el villano duela de forma controlada y reproducible en cualquier
  portátil de desarrollo.
- El vocabulario del dominio (host, métrica, tag, ventana, retención) es
  estable y se fija en el diccionario de traducción del curso (§4.2); no
  compite con ningún vocabulario "real" que haya que evitar.

---

## 12. Coherencia entre documentos

- **No contradecir fases anteriores.** Un fragmento de la Fase 8 no puede
  asumir una forma de dato distinta de la que el generador de la Fase 0
  produce, ni un nombre de campo distinto del diccionario (§4.2).
- **No reescribir decisiones aprobadas** sin señalar explícitamente la
  incompatibilidad y por qué.
- **Fuentes de verdad, en orden:** (1) instrucciones del proyecto, (2)
  `RUTA-NOSQL.md` (lista maestra), (3) `RUTA-NOSQL-FUNDAMENTOS.md`, (4)
  `08-el-vigia-semilla.md`, (5) entregables aprobados de fases anteriores,
  (6) decisiones explícitas del chat actual.
- **El dataset semántico es la costura entre motores.** El generador debe
  producir el mismo host, métrica, tag y valor en las tres formas de
  entrada. Si el generador cambia, los tres motores se enteran y el arnés
  `vs.ts` se actualiza en conjunto.
- Nombres de measurements, hypertables, colecciones, campos y tags se
  mantienen estables entre fases (en inglés, §4). Si algo se renombra, se
  documenta el cambio.

---

## 13. Post-mortems e incidentes (pieza forense)

Cada incidente del curso —cardinalidad explotada, retención que borró de
más, downsampling que promedió mal— sigue esta estructura de ocho puntos:

1. Síntoma.
2. Pasos de reproducción (con el generador, a la cardinalidad/cadencia que
   lo dispara).
3. Evidencia observable (`EXPLAIN`, profiler del motor, métricas del propio
   `vs.ts`).
4. Causa raíz.
5. Corrección.
6. Prueba de regresión.
7. Prevención (¿qué política o chequeo automático hubiera detectado esto
   antes?).
8. Post-mortem **sin culpabilización** (blameless): se analiza el sistema y
   el proceso, no a la persona.

El tono del post-mortem es sereno y analítico. El humor cálido del resto del
curso baja un punto aquí: un post-mortem es serio, aunque no acartonado.

---

## 14. Checklist rápido antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono cálido e informal, segunda persona **"tú"**, sin voseo, humor con
      moderación.
- [ ] Todo el código corre con las versiones fijadas del stack (semilla).
- [ ] **Identificadores, endpoints, measurements/hypertables/colecciones,
      tags y campos en inglés (§4).**
- [ ] **Comentarios de código y textos de interfaz en español.**
- [ ] No contradice ninguna fase anterior; respeta el diccionario de
      traducción (§4.2) y el dataset semántico del generador.
- [ ] Distingue motores donde importa (InfluxDB / TimescaleDB / Mongo /
      capa propia de generador o API).
- [ ] Usa el vocabulario de callouts (📝 🪦 📚 ⚠️ 💡) y los recuadros
      propios 📖 🪞 🩻 ⚰️ donde aporten.
- [ ] Marca 💸 la deuda técnica y 🔥 lo opcional.
- [ ] Tiene entre 20 y 40 ejercicios numerados con rangos 🟢🟡🟠🔴
      equilibrados (o 5-10 en apéndices), sin voseo en los enunciados.
- [ ] Ninguna afirmación de rendimiento o compresión sin respaldo de
      `vs.ts` en `BENCHMARKS.md`.
- [ ] **Termina con su propia sección `## 📚 Referencias`**, con URL
      completa, secciones (oficial / libros / video / orden de lectura si
      aplica), y advertencia de versión.
- [ ] Explica el *porqué* de cada decisión relevante.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
