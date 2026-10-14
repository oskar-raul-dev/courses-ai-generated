# ✍️ Guía de estilo, tono y convenciones — Centinela de Flota

## Curso wide-column (Cassandra / ScyllaDB vs PostgreSQL)

Esta guía es la fuente de verdad editorial del curso. Cualquier chat que
produzca un `.md` de una fase, un apéndice o un artefacto acumulativo la
sigue. Adapta la guía editorial legacy de la Ruta NoSQL (ver
`GUIA-DE-ESTILO-Y-CONVENCIONES.md`) al modelo wide-column; donde esta guía no
diga algo explícitamente, gana la guía legacy.

> 🧭 **Regla de una línea que rige todo el código:** el **código en inglés**;
> toda la narrativa, comentarios y textos de operador **en español**. El
> detalle completo está en §4.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien sepa, con números propios,
cuándo un régimen de escritura desborda un motor relacional y cuándo no.** No
enseñamos Cassandra "porque escala": enseñamos a medir el punto exacto donde
deja de bastar la coordinación central, y a pagar con los ojos abiertos el
costo operativo de la alternativa. Si un párrafo no ayuda a decidir, modelar,
medir o diagnosticar, sobra.

El norte del curso es una sola señal de éxito: **el estudiante puede mirar un
sistema de ingesta ajeno y decir, antes de escribir una línea, si wide-column
vota o no — y defenderlo con un número, no con una preferencia.**

---

## 2. Tono

El tono es **cálido, informal y directo** — de colega senior a colega senior,
con humor cuando cae bien. No es un manual acartonado: es alguien que ya
migró un sistema a Cassandra donde no tocaba, lo sufrió, y te lo cuenta con
confianza y sin solemnidad.

- **Segunda persona formal, sin voseo.** Se usa "tú", nunca "vos": "diseña la
  partition key antes de escribir la primera fila", "si el `ALLOW FILTERING`
  te tienta, primero mide". Se evita también el "usted" — el registro es
  cercano, no protocolar; simplemente no se usa la conjugación voseante
  ("vos tenés", "diseñá") en ningún documento del curso.
- **Humor seco permitido.** Un 😉, una nota sobre "la partición caliente que
  te despierta a las 3 am", un 🪦 para jubilar una tabla mal diseñada. El
  humor desdramatiza la fricción de operar un clúster distribuido; no rellena.
- **Honesto sobre el costo operativo.** Cuando adoptar el modelo implica
  `nodetool`, compactación que sintonizar y tombstones que vigilar, se dice
  con gracia pero sin minimizar: "esto escribe rápido y te regala un trabajo
  nuevo: mantener el clúster que lo logra". No se vende wide-column como bala
  de plata.
- **Orientado a la duda real.** Anticipa "¿y por qué no puedo hacer un
  `JOIN`?" y la responde con la razón física (el dato vive repartido en
  cientos de nodos), no con un "así es este motor".
- **Cercanía sin condescendencia.** El lector es senior de bases relacionales.
  No le expliques qué es un índice, una transacción o el plan de una query:
  **lo sabe de SQL**. Lo nuevo es cómo se ve (o desaparece) en un motor que
  desnormaliza por diseño.

> 🧠 **Matiz propio del curso (el eje pedagógico).** El lector llega con años
> de instintos relacionales bien entrenados. El tono los reconoce y los
> interpela de frente con las micro-secciones recurrentes de §7.4: 🪞 *"tu
> instinto relacional dice… y aquí se equivoca"* y 🩻 *"esto sí viaja igual"*.
> Nunca se ridiculiza el instinto SQL: se lo honra —fue correcto en su
> régimen— y se lo recalibra para el régimen de alto caudal.

Evitar: promesas vacías ("Cassandra lo resuelve todo", "vas a dominar
wide-column en una fase"), motivación de coach, solemnidad de manual
corporativo, y explicar lo obvio para el perfil senior. El humor es
condimento, no plato principal.

---

## 3. Idioma y forma (narrativa)

- Español claro y técnico para todo lo que **no** es código (títulos,
  explicaciones, ejercicios, referencias). Los términos del stack se dejan en
  inglés cuando son el nombre real del concepto: *partition key*, *clustering
  column*, *column family*, *wide row*, *tombstone*, *compaction*,
  *SSTable*, *consistency level*, *replication factor*, *hot partition*,
  *batching*, *backpressure*, *roll-up*, *time-bucketing*. No se traducen
  forzadamente ("clave de partición" puede usarse como glosa la primera vez
  que aparece el término, pero el término técnico en inglés es el que se
  repite).
- Markdown siempre.
- Encabezados con emoji **con moderación** — uno por sección de plantilla. Los
  subtítulos internos pueden llevar emoji-tipo (§7) cuando aporta lectura
  rápida.
- **Prosa antes que listas.** Se prefiere explicar razonando en párrafos. Las
  listas se usan cuando son de verdad una lista (pasos, ítems paralelos).
- **Tablas solo para comparar, decidir o mapear.** "Cuándo usar wide-column vs
  relacional", matrices de decisión, mapeos de niveles de consistencia, y
  —muy importante en este curso— **tablas de traducción relacional ↔
  wide-column/CQL** (§7.4). No para narrar.

---

## 4. Idioma del código fuente (código en inglés, curso en español)

Esta sección es normativa para **todo** fragmento de código del curso, sea en
el cuerpo de una fase, en la autopsia del villano, en un apéndice o en un
ejercicio resuelto.

### 4.1 Regla general

| Capa | Idioma | Ejemplo |
|---|---|---|
| **Identificadores de código** (funciones, variables, clases) | 🇬🇧 Inglés | `function computeHourlyRollup() {}`, `const isHotPartition = false` |
| **Nombres de keyspace, tabla, columna, campo CQL** | 🇬🇧 Inglés | `readings_by_device`, `deviceId`, `bucketStart`, `avgTemperature` |
| **Endpoints de la API de consulta** | 🇬🇧 Inglés | `/devices/:id/readings`, `/regions/:id/rollups/hourly` |
| **Constantes y enums internos** | 🇬🇧 Inglés | `RESOLUTION.PER_HOUR`, `CONSISTENCY_LEVEL.QUORUM`, `MAX_BATCH_SIZE` |
| **Nombres de script, módulo, archivo del arnés** | 🇬🇧 Inglés | `vs.ts`, `generateReading.ts`, `rollupWriter.ts` |
| **Comentarios de código** | 🇪🇸 Español | `// la partition key acota por hora: sin esto, la partición crece sin límite` |
| **Textos de operador (logs legibles, mensajes de la API)** | 🇪🇸 Español | `"No se pudo escribir la lectura: nivel de consistencia no alcanzado"` |
| **Narrativa del curso** | 🇪🇸 Español | Todo el texto fuera de bloques de código |

La aplicación pedagógica **no tiene i18n**: es una API en español para
operadores de habla hispana. Los textos que ve un humano —mensajes de error,
etiquetas de alerta, salidas de CLI del arnés— van en español. Lo que va en
inglés es el código que lee y mantiene el equipo, y **el nombre físico de
tablas, columnas y keyspaces**, porque eso es lo que el estudiante va a
encontrar en un clúster Cassandra real de cualquier empresa.

> 📝 **Por qué esta regla.** El esquema de una base wide-column de producción
> casi siempre está en inglés, y el CQL que se escribe contra ella también.
> Escribir el pedagógico así hace que el vocabulario de tablas y columnas sea
> el mismo que el estudiante va a auditar en un `DESCRIBE TABLE` real.

### 4.2 Qué se traduce y qué no (criterio rápido)

| Elemento | ¿Inglés? | Ejemplo |
|---|---|---|
| Nombre de tabla / column family | ✅ Sí | `readings_by_device`, `rollup_per_hour` |
| Nombre de columna / campo | ✅ Sí | `deviceId`, `bucketStart`, `avgVoltage`, `regionCode` |
| Partition key / clustering column (nombre) | ✅ Sí | `PRIMARY KEY ((deviceId, bucketDate), readingTime)` |
| Endpoints de la API de consulta | ✅ Sí | `apiClient.get('/devices/:id/readings')` |
| Funciones y variables del arnés `vs.ts` | ✅ Sí | `function measureWriteLatency()`, `const repetitions = 30` |
| Nombres de script/módulo/archivo | ✅ Sí | `deviceGenerator.ts`, `rollupWriter.ts`, `vs.ts` |
| Comentarios `//`, `/* */` | ❌ No | `// el batch logueado agrupa por partición, no es transaccional cross-partition` |
| Mensajes de error legibles para un operador | ❌ No | `{ code: 'CONSISTENCY_NOT_MET', message: 'No se alcanzó el nivel de consistencia' }` — la **key**/código en inglés, el **valor** en español |
| Nombres del dominio en la narrativa | ❌ No | El texto sigue hablando de "dispositivo", "lectura", "flota", "roll-up", "umbral" |

> ⚠️ **Caso mixto frecuente — errores y niveles de consistencia.** El objeto
> usa códigos en inglés (`{ code, message }`), pero el **valor** de `message`
> que ve el operador va en español:
>
> ```ts
> // lib/errors.ts
> export const CONSISTENCY_ERRORS = {
>   NOT_MET:      { code: 'CONSISTENCY_NOT_MET',  message: 'No se alcanzó el nivel de consistencia solicitado' },
>   TIMEOUT:      { code: 'WRITE_TIMEOUT',        message: 'El nodo coordinador no confirmó a tiempo' },
>   UNAVAILABLE:  { code: 'UNAVAILABLE_EXCEPTION', message: 'No hay suficientes réplicas disponibles' },
> };
> ```
>
> El `code` es lo que el arnés y el cliente comparan programáticamente; el
> `message` es lo que un humano lee en un log o una alerta. **Nunca** se usa
> el mensaje en español como clave de comparación en el código.

### 4.3 Diccionario de traducción (relacional → wide-column)

El diccionario completo vive en el propio 📖 recuadro de cada fase donde
aplica (§7.4); como referencia mínima acumulada, los términos centrales del
curso:

| Relacional (instinto de origen) | Wide-column / CQL (Cassandra-ScyllaDB) |
|---|---|
| tabla | column family / tabla CQL |
| primary key (identifica la fila) | **partition key** (decide el nodo) + **clustering columns** (ordenan dentro de la partición) |
| `JOIN` | tabla desnormalizada diseñada por consulta (no hay `JOIN`) |
| `WHERE` sobre cualquier columna | `WHERE` solo sobre la partition key / clustering, salvo índice secundario o SAI |
| `ORDER BY` en tiempo de consulta | orden físico ya materializado por el clustering |
| índice secundario (uso libre) | secondary index / SAI — recurso acotado, `ALLOW FILTERING` como olor |
| transacción multi-fila ACID | `BATCH` logueado (no es lo mismo: agrupa, no aísla entre particiones) |
| `DELETE` físico inmediato | tombstone + compactación (el borrado tarda en desaparecer físicamente) |
| trabajo de borrado por antigüedad (cron) | TTL nativo por fila |
| vista materializada / agregación en `SELECT` | tabla de roll-up pre-computada en el camino de ingesta |
| nivel de aislamiento (`READ COMMITTED`, etc.) | nivel de consistencia por consulta (`ONE`, `QUORUM`, `ALL`) |

### 4.4 Convenciones de nombrado

- **Funciones y variables:** `camelCase` en inglés — `writeReading`,
  `isHotPartition`, `bucketStart`.
- **Constantes de configuración:** `SCREAMING_SNAKE_CASE` — `MAX_BATCH_SIZE`,
  `ROLLUP_INTERVAL_MS`, `DEFAULT_CONSISTENCY_LEVEL`.
- **Tablas CQL:** `snake_case` plural, con sufijo `_by_<criterio>` cuando el
  nombre por sí solo no deja claro el patrón de acceso — `readings_by_device`,
  `readings_by_region`, `rollup_per_hour`.
- **Columnas CQL:** `camelCase` — `deviceId`, `readingTime`, `avgTemperature`,
  `bucketStart`.
- **Scripts y módulos del arnés:** `<dominio><Verbo>.ts` — `deviceGenerator.ts`,
  `rollupWriter.ts`, `vs.ts`, `consistencyBench.ts`.
- **Endpoints REST:** sustantivo en plural + acción, inglés —
  `/devices/:id/readings`, `/regions/:id/rollups/:resolution`.

### 4.5 Lo que nunca cambia

- **Comentarios de código:** 100 % español, explicando el porqué (§5).
- **Textos de operador:** 100 % español — mensajes de error legibles, salidas
  de CLI, etiquetas de alerta.
- **Narrativa del tutorial:** 100 % español.
- **Nombres propios del dominio en la narrativa:** "dispositivo", "lectura",
  "flota", "roll-up", "umbral" siguen siendo las palabras con que *hablas*
  del sistema, aunque el código diga `device`, `reading`, `fleet`, `rollup`,
  `threshold`.

---

## 5. Orientación a la práctica

Cada concepto se ancla en el dominio de la telemetría de flota y en código
que corre contra un clúster real.

- **Nada de teoría suelta.** Si se explica el `BATCH` logueado, se explica
  sobre la escritura simultánea de una lectura en tres tablas del patrón
  *tabla por consulta*, no en abstracto.
- **Código ejecutable y coherente.** Todo fragmento corre con las versiones
  fijadas del stack (Cassandra 5.0.x, ScyllaDB 2026.1, PostgreSQL 17,
  Node 24, TypeScript 5.x) y no contradice fases anteriores.
- **Código mínimo.** El fragmento más pequeño que muestra el punto, pero
  ejecutable contra el clúster de la Fase 0.
- **Comentarios que explican el porqué, no el qué, siempre en español.**
  `// la partition key incluye bucketDate: sin acotarla, la partición crece
  para siempre y se vuelve caliente` sí; `// crea la tabla` no.
- **Distinguir capas.** Siempre queda claro si un comportamiento vive en el
  generador de datos, en el camino de ingesta (writer), en la API de
  consulta, o en el propio motor (Cassandra/Scylla/Postgres). Es la
  distinción que salva al que depura una partición caliente a las 3 am.

---

## 6. Manejo del costo operativo (el corazón del curso)

- **No esconder la superficie operativa.** Si una fase requiere ajustar el
  heap de un nodo, sintonizar una estrategia de compactación o vigilar
  tombstones, se muestra tal cual, con el comando real y el porqué. No se
  reduce a "y así queda listo".
- **El costo se nombra, no se minimiza.** Cada vez que el curso gana algo
  (escritura distribuida, disponibilidad multi-DC), nombra lo que cuesta
  mantenerlo (`nodetool`, monitoreo de particiones, tuning de compactación).
- **Corrección mínima vs. rediseño.** Ante un problema (partición caliente,
  tormenta de tombstones), se distingue el ajuste puntual (cambiar el
  time-bucketing) del rediseño de fondo (repensar la partition key desde
  cero).
- **El idioma del código (§4) no es negociable ni en el villano.** El CRUD
  mal montado sobre Cassandra (Fase 11) se muestra con sus decisiones
  torpes intactas, pero con identificadores en inglés. La torpeza que se
  enseña es de arquitectura, no de idioma.

---

## 7. Marcadores y callouts (vocabulario visual del curso)

### 7.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Todo atajo que se deja a propósito y se
  paga después. Ejemplo vivo: el `BATCH` sin retry declarado en la Fase 6 se
  paga con backpressure explícito en la Fase 6.5 (o donde corresponda).
- 🔥 **Opcional / ampliación.** Ejercicios o secciones que exceden el
  alcance base (drivers en otros lenguajes, dashboard visual, ML sobre
  telemetría).
- ⭐ **Fase o pieza central.** Fase 3 (tabla por consulta) y Fase 6 (ingesta
  a alto caudal) son las estrellas del curso.
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil / intermedio / difícil / muy
  difícil.

### 7.2 Callouts en blockquote (emoji-tipo)

- 📝 **Nota de contexto.** Por qué el ecosistema wide-column tomó una
  decisión de diseño particular (por qué CQL imita la sintaxis de SQL a
  propósito, por qué Bigtable inspiró a Cassandra).
- 📚 **Referencia rápida inline.** Un enlace útil justo donde surge la duda,
  sin esperar a la sección de referencias del capítulo.
- 🪦 **Retiro.** Cuando una tabla, un enfoque o un motor se jubila del curso.
  Ej.: "🪦 Se apaga el CRUD sobre Cassandra: cumplió su función de villano."
- ⚠️ **Advertencia.** Algo que rompe si se ignora (versión incompatible,
  `ALLOW FILTERING` sin medir, `BATCH` cruzando particiones creyendo que es
  transaccional).
- 💡 **Truco o atajo** que ahorra tiempo real de operación.

### 7.3 Secciones narrativas recurrentes

- **💸 Pago de deuda.** Dónde se salda una deuda declarada antes.
- **Detalles con intención.** Lista corta de decisiones deliberadas de un
  bloque de modelado ("particionamos por `deviceId` + `bucketDate`, no solo
  por `deviceId`, porque sin la fecha la partición nunca deja de crecer").
- **El patrón a memorizar.** Una o dos frases con la lección transferible.
- **Prueba de fuego.** Verificación manual concreta: "sube el caudal del
  generador a 5.000 escrituras/segundo y observa la curva de latencia de
  Postgres despegar mientras Cassandra sostiene."
- **Mini-repaso.** Cuando una fase usa un concepto que el lector relacional
  quizá no domina (CAP, consistencia sintonizable), un repaso exprés en
  tabla antes del código, con su 📚.
- **La señal de que quedó bien.** En el cierre, un criterio en forma de
  cita: "si mañana triplico el caudal de ingesta, la latencia de escritura
  no se mueve — solo agrego nodos."

### 7.4 Secciones propias del curso (SQL → wide-column)

Estas cuatro son la columna vertebral del curso y aparecen cuando el
contenido lo pide:

- **📖 Tabla de traducción relacional ↔ CQL.** Lado a lado, la operación
  relacional y su equivalente wide-column. Ej.: `SELECT * FROM readings
  WHERE device_id=? ORDER BY ts DESC LIMIT 100` ↔ `SELECT * FROM
  readings_by_device WHERE deviceId=? LIMIT 100` (el orden ya viene dado por
  el clustering, no por un `ORDER BY` calculado). Es tabla (§3), no prosa.
- **🪞 "Tu instinto relacional dice… y aquí se equivoca."** Nombra la trampa
  **antes** de caer en ella: la partition key como "la PK de siempre", el
  `BATCH` como transacción real, `ALLOW FILTERING` como solución cómoda.
  Honra el instinto y lo recalibra.
- **🩻 "Esto sí viaja igual."** Lo reconfortante: pensar en el patrón de
  acceso, la selectividad de un índice, medir antes de optimizar — sigue
  valiendo exactamente lo que valía en SQL. Baja la ansiedad del lector.
- **⚰️ Caso de estudio: el villano.** Cassandra montada donde el volumen no
  la justifica — se mide, duele, se migra de vuelta a Postgres con números.
  Es el hilo que cose la Fase 11 con el resto del curso.

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Toda fase produce un `.md` con exactamente estas nueve secciones, en orden
(decisión ya fijada en la semilla: se mantienen las 9 secciones del esqueleto
compartido, sin ajuste adicional):

1. **🎯 Propósito** — qué resuelve esta fase; puede abrir con la situación
   heredada ("hasta ahora cada lectura se escribe una sola vez, sin roll-up…").
2. **✅ Qué queda listo al terminar** — checklist verificable.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase.
4. **🧠 Conceptos mínimos** — solo lo necesario, anclado al dominio de la
   flota. Aquí caben el **Mini-repaso**, las **Notas de contexto**, la 📖
   tabla de traducción y los recuadros 🪞/🩻.
5. **💻 Implementación y código comentado** — el grueso; código ejecutable
   contra el clúster, identificadores en inglés (§4). Aquí caben **Detalles
   con intención**, **El patrón a memorizar**, **Prueba de fuego** y
   **💸 Pago de deuda**.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente
   (partición caliente, tormenta de tombstones, `ALLOW FILTERING`
   silencioso) y cómo diagnosticarlo con las herramientas del motor
   (`nodetool`, `EXPLAIN` en Postgres, tracing de CQL).
7. **🧪 Ejercicios progresivos** — 20 a 40, graduados (§9).
8. **📚 Referencias** — al cierre de cada fase, no al final del curso (§10).
9. **🚀 Cierre y conexión con la siguiente fase** — qué sigue y por qué. Aquí
   va **La señal de que quedó bien**.

Los apéndices (A–E) no siguen esta plantilla: usan índice de salto rápido +
secciones cortas + tabla "cuándo usar qué" + 5-10 ejercicios cortos.

---

## 9. Ejercicios

- **Cantidad: 20 a 40 por fase**, según la nota de la semilla — fases más
  densas (partition key, roll-ups, ingesta a alto caudal) tienden al extremo
  alto del rango; apéndices llevan 5-10.
- **Distribución equilibrada por nivel de dificultad.** Guía razonable para
  ~30: ~8 🟢, ~9 🟡, ~7 🟠, ~4-6 🔴, más los 🔥 opcionales aparte. Ningún
  nivel queda vacío ni sobrerrepresentado — un capítulo con solo ejercicios
  🟢 o solo 🔴 no cumple esta guía.
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
- **Progresión real.** Los 🟢 calientan (escribir una tabla, un `INSERT`, una
  consulta por clave). Los 🔴 exigen integrar varias fases o depurar algo
  esquivo (reproducir el ahogo de escritura de Postgres bajo el cruce de
  caudal, cazar una tormenta de tombstones, cerrar la brecha de un `ALLOW
  FILTERING`).
- **Accionables y verificables.** "Diseña `readings_by_region` de modo que la
  consulta de las últimas 24 h de la región `north` no dispare `ALLOW
  FILTERING`" — no "reflexiona sobre el particionamiento".
- **Al menos un puñado por fase son de diagnóstico.** Se entrega un bug — una
  partición que crece sin límite, un roll-up que cuenta doble, una consulta
  que exige `ALLOW FILTERING` — y se pide reproducir y localizar, no solo
  construir.
- **Enganchados al dominio.** Usan dispositivos, lecturas, roll-ups, regiones,
  umbrales — nunca ejemplos abstractos ("tabla A", "entidad X").
- **Cuando un ejercicio nombra código, usa el identificador en inglés
  vigente** ("agrega la tabla `readings_by_metric_threshold`", "escribe
  `computeHourlyRollup`"), aunque el enunciado en sí esté en español.
- Los 🔥 son opcionales y se listan aparte, sin numeración continua.

En apéndices bastan 5-10 ejercicios cortos de consulta.

---

## 10. Bibliografía y referencias

**Regla:** documentación oficial de las versiones fijadas del stack
**primero**; luego libros; luego blogs, videos y tutoriales. Siempre se
advierte cuando un enlace apunta a una versión distinta de la fijada. **Cada
fase cierra su propia sección de referencias** (sección 8 de la plantilla,
§8) — no se difiere todo a un documento único al final del curso, aunque
también existe una compilación acumulada por bloques de fases en la semilla
para planificación.

### 10.1 Formato

- **URLs completas y clicables**, no solo el dominio.
- **Secciones separadas** dentro de "📚 Referencias" de cada fase:
  Documentación oficial (con URL completa y nota de versión), Libros cuando
  apliquen, Video/apoyo (con URL completa), y **Orden de lectura sugerido**
  (una línea que encadena qué leer primero).

### 10.2 Fuentes oficiales por tema (usar URL completa al citar)

- **Apache Cassandra 5.0:** https://cassandra.apache.org/doc/latest/
- **ScyllaDB 2026.1:** https://docs.scylladb.com/
- **PostgreSQL 17:** https://www.postgresql.org/docs/17/
- **`cassandra-driver` (Node, DataStax):** repositorio y doc oficial
  (verificar URL vigente antes de citar en una fase).
- **`pg` (node-postgres):** https://node-postgres.com/
- **Bigtable (paper original, Google, 2006):** verificar URL del paper antes
  de citar; es lectura conceptual, no operativa.
- **Zod:** https://zod.dev/

### 10.3 Advertencias

- **Sobre citas:** cuando se mencione un artículo, libro, video o post
  específico, se deja claro que URLs y títulos pueden estar desactualizados o
  ser inexactos; el lector debe verificarlos. No se inventan números de
  página, DOIs ni IDs de video.
- **No usar en el código principal:** APIs o versiones fuera del stack
  fijado (Cassandra < 5.0 o Cassandra 6.x sin confirmar, ScyllaDB fuera de la
  línea 2026.1, PostgreSQL < 17). Las alternativas más nuevas o más viejas
  aparecen solo como comparación o en una nota 🔥, nunca en el código
  principal de una fase.

---

## 11. Sobre el dominio (ficticio, sin NDA)

La flota de dispositivos de Centinela de Flota es un dominio **enteramente
ficticio**: no representa ninguna empresa real ni un despliegue de producción
concreto. Esto simplifica dos cosas:

- Los ejemplos pueden ser todo lo concretos que convenga (regiones, umbrales,
  tipos de dispositivo) sin tener que "generalizar ante la duda".
- El vocabulario del dominio (dispositivo, lectura, flota, roll-up, umbral,
  alerta) es estable y se fija en la tabla de §4.3; no compite con ningún
  vocabulario "real" que haya que evitar por confidencialidad.

La regla de idioma del código (§4) es una convención de calidad, no una
cuestión de NDA.

---

## 12. Coherencia entre documentos

- **No contradecir fases anteriores.** Un fragmento de la Fase 8 no puede
  asumir un esquema de `readings_by_device` distinto del fijado en la
  Fase 3.
- **No reescribir decisiones aprobadas** sin señalar explícitamente la
  incompatibilidad y por qué.
- **Fuentes de verdad, en orden:** (1) instrucciones del proyecto de la Ruta
  NoSQL, (2) `RUTA-NOSQL-FUNDAMENTOS.md`, (3) `05-centinela-de-flota-semilla.md`,
  (4) esta guía de estilo, (5) entregables aprobados de fases anteriores,
  (6) decisiones explícitas del chat actual.
- Nombres de tablas, columnas, keyspaces, scripts y módulos se mantienen
  estables entre fases (en inglés, §4.4). Si algo se renombra, se documenta
  el cambio y se propaga a las fases ya escritas.

---

## 13. Post-mortems e incidentes

Cada incidente del curso (partición caliente, tormenta de tombstones, clúster
que no forma anillo) sigue esta estructura de ocho puntos:

1. Síntoma.
2. Pasos de reproducción (incluyendo el caudal o el comando `nodetool` que lo
   dispara).
3. Evidencia observable (`nodetool status`/`tablestats`, tracing de CQL,
   `EXPLAIN` de Postgres cuando el incidente es del control relacional).
4. Causa raíz.
5. Corrección.
6. Prueba de regresión (medida con `vs.ts`, no narrada).
7. Prevención.
8. Post-mortem **sin culpabilización** (blameless): se analiza el diseño de
   la tabla o la operación del clúster, no a la persona.

El tono del post-mortem es sereno y analítico. El humor cálido del resto del
curso baja un punto aquí: un post-mortem es serio, aunque no acartonado.

---

## 14. Checklist rápido antes de dar por cerrado un `.md`

- [ ] Sigue la plantilla de 9 secciones (o el formato de apéndice).
- [ ] Tono cálido e informal, segunda persona **sin voseo**, humor con
      moderación.
- [ ] Todo el código corre con las versiones fijadas del stack.
- [ ] **Identificadores, tablas, columnas, keyspaces y endpoints del código
      en inglés (§4).**
- [ ] **Comentarios de código y textos de operador en español (§4.5).**
- [ ] No contradice ninguna fase anterior; respeta el esquema fijado en
      fases previas.
- [ ] Distingue capas (generador / writer de ingesta / API de consulta /
      motor) donde importa.
- [ ] Usa el vocabulario de callouts (📝 🪦 📚 ⚠️ 💡) y los recuadros
      📖 🪞 🩻 ⚰️ donde aporten.
- [ ] Marca 💸 la deuda técnica (y la paga si corresponde) y 🔥 lo opcional.
- [ ] Tiene 20-40 ejercicios numerados con rangos 🟢🟡🟠🔴 equilibrados (o
      5-10 en apéndices), con **diversidad real de dificultad** — ningún
      nivel vacío.
- [ ] Toda afirmación comparativa ("Cassandra vs Postgres", "Cassandra vs
      Scylla") está respaldada por `scripts/vs.ts` y registrada en
      `BENCHMARKS.md`; ninguna se narra sin medir.
- [ ] **Trae su propia sección de referencias al final del capítulo**
      (§8 de la plantilla / §10 de esta guía): oficial / libros / video /
      orden de lectura sugerido, con advertencia de versión.
- [ ] Explica el *porqué* de cada decisión de modelado relevante.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
