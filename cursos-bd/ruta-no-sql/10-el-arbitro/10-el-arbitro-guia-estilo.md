# ✍️ El Árbitro — Guía de estilo, tono y convenciones

> Deriva de `GUIA-DE-ESTILO-Y-CONVENCIONES.md` (guía legacy de la ruta),
> adaptada al modelo de este curso: **persistencia políglota**, no un motor
> nuevo. Donde esta guía no dice nada distinto, rige la legacy. Donde
> contradice, gana esta guía para todo documento del curso 10.

> 🧭 **Regla de una línea que rige todo el código:** el **código en inglés**;
> todo lo demás —narrativa, comentarios, textos de interfaz— **en español**,
> sin voseo. El detalle completo está en §3.

---

## 1. Principio rector

**Todo lo que se escribe apunta a que alguien defienda una arquitectura con
números, en la reunión donde alguien propone sumar el motor de moda.** El
curso no enseña a operar cinco motores: enseña a decidir cuándo sumar uno,
cómo mantenerlo coherente con la fuente de verdad, y cuánto cuesta de verdad
tenerlo encendido. Si un párrafo no ayuda a decidir, medir o pagar esa
factura, sobra.

La señal de éxito del curso, repetida en cada cierre de fase, tiene una
forma fija: *"puedo nombrar, por escrito, quién opera este motor, cuánto
tarda su restore y cómo me entero de que se desincronizó — o todavía no
está listo para sumarse"*.

---

## 2. Tono

El tono es **cálido, informal y directo** — de colega senior a colega senior,
con humor cuando cae bien. El lector de este curso ya hizo (o pudo haber
hecho) el resto de la ruta: no le expliques qué es un índice, un plan de
ejecución o una transacción. Lo nuevo acá no es ningún motor individual —ya
los conoce o los conoció en cursos anteriores— sino **la aritmética de
combinarlos**.

- **Segunda persona, cercana, sin voseo.** El lector se trata de "tú", nunca
  de "vos": "monta el laboratorio y cronometra el arranque", "si el
  `$lookup` entre dos motores te tienta, ahí está mal el corte" — nunca
  "montá", "cronometrá" ni "tenés".
- **Humor seco permitido, con un límite claro.** Un chiste sobre la
  "arquitectura de diapositiva" que impresiona en la reunión y desangra en
  la guardia cae bien; el tema del dinero real en el ledger y el de
  restaurar un sistema tras una pérdida real se tratan con humor bajo, casi
  nulo — son las dos zonas donde este curso baja el tono un escalón,
  igual que el resto de la ruta baja el tono en un post-mortem.
- **Honesto sobre el costo.** Cuando sumar un motor cuesta caro, se dice sin
  vueltas: "esto te compra 40% menos latencia en p99 y te vende un backup
  nuevo, un runbook nuevo y una superficie de guardia que hoy no tenés". No
  se disfraza el costo operativo de detalle menor.
- **Orientado a la pregunta que nadie hace en la reunión de arquitectura.**
  El curso anticipa esa pregunta incómoda —"si restauras Postgres a las
  14:03 y Mongo a las 14:07, ¿qué estado tiene el sistema?"— y la responde
  con procedimiento, no con optimismo.
- **Cercanía sin condescendencia.** No se explica qué es JSONB, ni cómo
  funciona un índice invertido, ni qué es `SKIP LOCKED` desde cero: se
  explica **por qué este dominio elige uno u otro**, dando por sentado que
  el lector puede buscar la sintaxis si la olvidó.

> 🧠 **Matiz propio de El Árbitro (el eje del curso).** El lector no llega en
> blanco ni llega con instintos de un solo paradigma: llega con instintos de
> **varios** motores, cada uno correcto por separado. El tono interpela un
> instinto específico y más peligroso que cualquier trampa de sintaxis: la
> intuición monolítica de que "la base es consistente", que deja de ser
> cierta apenas hay dos almacenes. Las dos micro-secciones recurrentes de
> toda la ruta (🪞 y 🩻) se usan acá con foco en la costura, no en un motor:
> 🪞 nombra dónde la intuición de consistencia falla al cruzar un almacén; 🩻
> confirma qué sigue viajando igual (capacidad, índices, selectividad,
> contención dentro de cada motor individual).

Evitar: presentar la persistencia políglota como moda o como condena —el
curso defiende explícitamente una arquitectura de tres motores, con
números—, solemnidad de manual de arquitectura corporativa, y explicar
desde cero cualquier motor que ya apareció en la ruta.

---

## 3. Idioma y forma (narrativa)

- Español claro y técnico, **sin voseo** (nunca "vos", "tenés", "podés";
  siempre "tú", "tienes", "puedes") para todo lo que **no** es código:
  títulos, explicaciones, ejercicios, referencias, callouts.
- Los términos del stack se dejan en inglés cuando son el nombre real del
  concepto: *outbox*, *dual-write*, *change data capture* (CDC), *event
  sourcing* de la costura, *replica set*, *WAL*, *sharding*, *snapshot*,
  *replication lag*, *idempotency key*, *dead-letter queue*. No se
  traducen forzadamente.
- Markdown siempre.
- Encabezados con emoji **con moderación** — uno por sección de plantilla.
- **Prosa antes que listas.** Se prefiere explicar razonando en párrafos.
  Las listas se reservan para pasos concretos o ítems genuinamente
  paralelos.
- **Tablas solo para comparar, decidir o mapear.** El uso propio de este
  curso: la **ficha de factura por motor** (§7.4), la tabla del marco de
  cinco preguntas, el diccionario de traducción entre lenguajes de consulta
  (Apéndice C), y cualquier "esto cuesta X en Postgres, Y en el motor
  nuevo". No para narrar.

---

## 4. Idioma del código fuente (código en inglés, curso en español)

Sección normativa para todo fragmento de código del curso: fase, incidente,
apéndice o ejercicio resuelto.

### 4.1 Regla general

| Capa | Idioma | Ejemplo |
|---|---|---|
| **Código fuente** (identificadores) | 🇬🇧 Inglés | `function createHold(seatId, ttlMs) {}` |
| **Endpoints y rutas** | 🇬🇧 Inglés | `/events`, `/events/:id/holds`, `/payouts/:organizerId` |
| **Colecciones/tablas y campos** | 🇬🇧 Inglés | `db.collection('events')`, `hold_expires_at`, `payout_settled_at` |
| **Constantes y enums internos** | 🇬🇧 Inglés | `status: 'on_sale'`, `HOLD_TTL_SECONDS` |
| **Eventos que viajan por la costura** | 🇬🇧 Inglés, `recurso.acción`, en pasado | `order.created`, `hold.expired`, `payout.settled` |
| **Nombres de archivo, servicio, consumidor** | 🇬🇧 Inglés | `holdService.ts`, `catalogProjector.ts`, `payoutConsumer.ts` |
| **Comentarios de código** | 🇪🇸 Español | `// el hold expira solo: nadie confirma, nadie libera a mano` |
| **Textos de interfaz (lo que ve el usuario)** | 🇪🇸 Español | `"Quedan 3 entradas"`, `"Tu reserva expira en 09:58"` |
| **Narrativa del tutorial** | 🇪🇸 Español, sin voseo | Todo el texto fuera de bloques de código |

> 📝 **Por qué esta regla también acá.** Un sistema políglota real, mantenido
> por un equipo técnico, tiene su código en inglés con comentarios locales —
> y además, el contrato de eventos que cruza cuatro motores necesita que el
> mismo identificador (`order.created`) signifique lo mismo en el
> publicador y en cada consumidor, sea cual sea el idioma en que se explique
> alrededor.

### 4.2 Diccionario del dominio (Ágora)

| Español (narrativa, interfaz) | Inglés (código) |
|---|---|
| evento / función | `event` / `session` |
| recinto | `venue` |
| asiento | `seat` |
| reserva temporal | `hold` |
| pedido | `order` |
| pago | `payment` |
| liquidación al organizador | `payout` |
| organizador | `organizer` |
| asistente | `attendee` |
| escaneo en puerta | `scan` |
| aforo | `capacity` |

Los estados van en inglés y en `snake_case` cuando son compuestos:
`on_sale`, `sold_out`, `checked_in`. Los eventos de la costura siguen
`recurso.acción` en inglés y pasado: `order.created`, `hold.expired`,
`event.published`, `payout.settled`.

> ⚠️ **Caso mixto: mensajes de error y texto de reserva.** La clave va en
> inglés, el valor que ve la persona usuaria va en español:
> ```ts
> // holdService.ts
> throw new HoldConflictError({
>   code: 'seat_already_held',              // clave: inglés, la lee el código
>   message: 'Este asiento ya tiene una reserva activa', // valor: español, lo lee la persona
> });
> ```

### 4.3 Lo que nunca cambia

- Comentarios de código: 100% español, sin voseo, explicando el porqué.
- Textos de interfaz: 100% español, sin voseo.
- Narrativa del tutorial: 100% español, sin voseo.
- Nombres propios del dominio en la narrativa: "evento", "asiento",
  "reserva", "liquidación" siguen siendo las palabras con que se habla del
  sistema, aunque el código diga `event`, `seat`, `hold`, `payout`.

---

## 5. Orientación a la práctica

- **Nada de teoría suelta sobre un motor aislado.** Si se explica un
  `$jsonSchema` de Mongo, es sobre la ficha heterogénea de un evento de
  Ágora, no en abstracto. Si se explica `SKIP LOCKED`, es sobre la reserva
  de un asiento bajo contención real, no con una tabla de ejemplo genérica.
- **Todo lo que se mide, se mide con `scripts/vs.ts`.** Ningún "vs" se narra
  ("Mongo es más rápido para esto"); todo "vs" se corre, con calentado
  previo y bajo la misma carga de k6, y el número entra a `BENCHMARKS.md`
  con fecha, versión de motor y máquina.
- **Código mínimo, ejecutable.** El fragmento más pequeño que muestra el
  punto de integración o de costura, corriendo con las versiones fijadas
  del stack (ver semilla). Nada de pseudocódigo que "se entiende".
- **Comentarios que explican el porqué de la decisión de arquitectura, no el
  qué del código.** `// el consumidor es idempotente por orderId: puede
  reprocesar el mismo evento sin duplicar el pago` sí; `// crea el pedido`
  no.
- **Distinguir capas y motores siempre que importe.** En este curso "capa"
  no es solo componente/servicio/ruta: es también **qué almacén** guarda
  este dato, **quién** lo escribió primero, y **por dónde** viajó el cambio
  hasta llegar acá. Es la distinción que salva a quien depura una
  divergencia entre almacenes.

---

## 6. El villano y su tratamiento

El villano de este curso —la arquitectura de diapositiva, motores sumados
por moda y sin factura nombrada— se construye **de verdad** en la Fase 11,
nunca como hombre de paja. Se le da su mejor presentación posible (cada
motor elegido por una razón real, no absurda) y aun así se mide dónde cede.
El tratamiento sigue la misma disciplina que el resto de la ruta aplicó a
sus propios villanos (EAV en Proteo, Redis como fuente de verdad en
Portalón): se nombra el olor **estructural**, se mide con números
antes/después, y se muestra la autopsia completa en `BENCHMARKS.md`, sin
maquillaje, incluidos los resultados que contradigan la expectativa
declarada.

El villano tiene una versión espejo tratada con la misma dureza: el
veterano que se niega a sumar el segundo motor cuando la evidencia ya lo
pide, sin haber puesto número a nada tampoco. El curso no romantiza la
prudencia sin evidencia: es el mismo pecado que el entusiasmo sin evidencia,
con mejor reputación.

---

## 7. Marcadores y callouts (vocabulario visual de la ruta, adaptado)

### 7.1 Marcadores de estado

- 💸 **Deuda técnica intencional.** Un atajo que se declara en una fase y se
  paga en otra. Ejemplo vivo del curso: en la Fase 2 se acepta dual-write
  temporal para tener algo funcionando rápido; se paga formalmente en la
  Fase 3 cuando nace la tabla `outbox`.
- 🔥 **Opcional / ampliación.** Ejercicios o secciones que exceden el
  alcance base (por ejemplo, portar el arnés a un sexto motor por
  curiosidad).
- ⭐ **Fase o pieza central.** En este curso: la Fase 3 (fuente de verdad),
  la Fase 7 (la costura) y la Fase 11 (la autopsia).
- 🟢🟡🟠🔴 **Dificultad de ejercicios.** Fácil / intermedio / difícil / muy
  difícil.

### 7.2 Callouts en blockquote

- 📝 **Nota de época o de contexto de industria.** Por ejemplo, por qué
  dual-write sigue apareciendo en sistemas reales de 2026 aunque se sepa
  que es un antipatrón.
- 📚 **Referencia rápida inline.**
- ⚠️ **Advertencia.** Especialmente para versiones de motor, o para la
  distinción CouchDB ≠ Couchbase heredada de la lista maestra.
- 💡 **Truco o atajo** operativo real (un flag de Compose, un healthcheck
  bien escrito).
- 💾 **Propio de este curso: nota de restore.** Cualquier vez que se
  mencione un procedimiento de backup sin su restore cronometrado al lado,
  este callout marca la ausencia como una alerta, no como un detalle
  pendiente.

### 7.3 Los cinco recuadros del esqueleto compartido (obligatorios donde aplican)

- 🪞 **Instinto falsable y medido.** Predicción escrita antes de medir,
  firmada, con el procedimiento del arnés y el veredicto con número. En
  este curso, los instintos más interesantes casi nunca son sobre un motor:
  son sobre costo ("cuántos motores hacen falta", "cuánto tarda un
  restore coherente").
- 🩻 **"Esto SÍ viaja igual."** Lo que la experiencia relacional (o la
  experiencia con cada motor individual de la ruta) sigue valiendo intacto:
  capacidad, índices, selectividad, contención, aislamiento — todo eso
  sigue siendo cierto *dentro* de cada motor. Lo que deja de viajar es la
  intuición de consistencia global, y el 🪞 correspondiente lo nombra.
- ⚰️ **Anti-patrón transversal con autopsia.** La arquitectura de
  diapositiva de la Fase 11, medida antes y después de reducirla.
- 📖 **Diccionario de traducción.** En este curso no es SQL↔Mongo sino la
  misma pregunta semántica en cinco lenguajes de consulta a la vez
  (Apéndice C): SQL, MQL, comandos de Valkey, la API de Meilisearch, SQL
  analítico de DuckDB. Sigue siendo tabla, nunca prosa.
- ⚖️ **Veredicto honesto: cuándo NO usar esta familia.** En este curso, "esta
  familia" es la persistencia políglota entera, y el veredicto vive
  formalmente en la Fase 12, con el árbol de decisión completo (ver
  `EL-ARBITRO-ALCANCE.md` §4).

### 7.4 Sección propia de este curso: la ficha de factura

Cada vez que Ágora suma un motor, la fase que lo suma llena una **ficha de
factura** con esta forma fija (idéntica a la tabla que define la semilla):
imagen y versión, backup, restore (cronometrado, no estimado), modos de
fallo, observabilidad, runbook, consistencia (qué duplica, con qué retraso,
cómo se detecta la divergencia), y aprendizaje (cuánto tarda alguien nuevo
del equipo en tocarlo sin miedo). Esta ficha es tabla siempre, nunca prosa,
y acumula en `FACTURA.md`.

---

## 8. Plantilla obligatoria de cada fase (9 secciones)

Se conserva la plantilla de la ruta, con una única nota de adaptación en el
punto 4 y el punto 5.

1. **🎯 Propósito** — qué patrón de acceso o qué pieza de la costura resuelve
   esta fase; puede abrir con la situación heredada de la fase anterior.
2. **✅ Qué queda listo al terminar** — checklist verificable, incluida la
   entrada correspondiente en `BENCHMARKS.md` y, si aplica, en `FACTURA.md`.
3. **🚫 Qué queda fuera por ahora** — qué se difiere y a qué fase.
4. **🧠 Conceptos mínimos** — solo lo necesario para *esta* decisión de
   integración, no un curso del motor. Aquí viven el marco de 5 preguntas
   aplicado al patrón de la fase, y los recuadros 🪞/🩻/📖 cuando aportan.
5. **💻 Implementación y código comentado** — el grueso; incluye siempre la
   medición con `scripts/vs.ts` del patrón contra su alternativa sin el
   motor nuevo. Aquí caben **Detalles con intención**, **El patrón a
   memorizar**, **Prueba de fuego** y **💸 Pago de deuda**.
6. **⚠️ Errores comunes y pieza forense** — qué se rompe típicamente en la
   costura o en el motor nuevo, y cómo diagnosticarlo (incluye, cuando
   corresponde, la 💾 nota de restore).
7. **🧪 Ejercicios progresivos** — 25 a 40, ver §9.
8. **📚 Referencias** — ver §10. **Sección obligatoria al final de cada
   fase**, sin excepción, incluso en apéndices.
9. **🚀 Cierre y conexión con la siguiente fase** — qué sigue y por qué. Aquí
   va **La señal de que quedó bien**, y en las fases donde se sumó un motor,
   la ficha de factura recién llenada (§7.4).

Los apéndices no siguen esta plantilla completa: usan índice de salto
rápido, secciones cortas, la tabla "cuándo usar qué" que corresponda, y una
sección de referencias breve al cierre igualmente obligatoria.

---

## 9. Ejercicios

- **Cantidad: 20 a 40 por fase, 30 como objetivo cómodo.** Distribución
  sugerida para treinta: ~8 🟢, ~9 🟡, ~8 🟠, ~5 🔴, más los 🔥 aparte.
- **Diversidad de nivel obligatoria en cada fase.** Ninguna fase se publica
  con todos los ejercicios concentrados en uno o dos niveles: los 🟢
  calientan (leer una métrica, ejecutar un escenario existente del arnés),
  los 🟡 construyen (agregar un consumidor, escribir un escenario nuevo para
  `vs.ts`), los 🟠 integran dos o más piezas del sistema y suelen exigir
  medir antes de decidir, y los 🔴 son de arquitectura y dolor real: cerrar
  una ventana de sobreventa, hacer converger un derivado atrasado sin parar
  el sistema, reconstruir el estado coherente tras un restore desalineado.
- **Numeración continua con encabezado de rango por dificultad:**
  ```
  ## 🧪 Ejercicios (30)

  **🟢 Fácil (1–8)**
  1. ...
  **🟡 Intermedio (9–17)**
  9. ...
  **🟠 Difícil (18–25)**
  18. ...
  **🔴 Muy difícil (26–30)**
  26. ...
  **🔥 Opcionales**
  - 🔥 ...
  ```
- **Al menos cinco ejercicios de diagnóstico por fase.** Se entrega el
  sistema con un fallo ya inyectado —un consumidor no idempotente, un
  índice derivado que perdió documentos, un `wal_level` mal configurado, un
  umbral de alerta que nunca dispara— y se pide reproducir, localizar y
  explicar antes de arreglar.
- **Accionables y verificables, anclados a Ágora.** "Cierra la ventana de
  sobreventa del evento `#0412` bajo doble clic simultáneo" — no
  "reflexiona sobre concurrencia distribuida". Usan eventos, funciones,
  asientos, reservas, pedidos, liquidaciones y escaneos de puerta; nunca
  `foo` y `bar`.
- **Identificador en inglés vigente cuando el ejercicio nombra código**
  ("agrega el consumidor `catalogProjector`", "instrumenta `createHold`"),
  aunque el enunciado esté en español, sin voseo.
- Los 🔥 son opcionales, se listan aparte y no llevan numeración continua.

En apéndices bastan 5 a 10 ejercicios cortos de consulta o de configuración.

---

## 10. Bibliografía y referencias

**Regla:** documentación oficial de la versión fijada en el stack primero;
luego libros; luego blogs, artículos y video. Cada fase cierra con su
sección **📚 Referencias**, sin excepción — no es opcional ni queda para "una
fase más adelante".

### 10.1 Formato de la sección de referencias de cada fase

Toda fase termina con una sección `## 📚 Referencias` que incluye, en este
orden:

1. **Documentación oficial** — URL completa y clicable, con nota de versión
   cuando la ruta de la documentación depende de la serie del motor
   (`/docs/18/` de PostgreSQL, `/docs/v8.0/` de MongoDB, etc.).
2. **Libros** — cuando aplique al contenido de la fase, con nota de "edición
   a verificar".
3. **Video / apoyo** — únicamente descrito por tema a buscar, nunca con un
   ID de video inventado.
4. **Orden de lectura sugerido** — una línea que encadena qué leer primero
   dentro de las referencias de esa fase.

### 10.2 Fuentes oficiales del curso (usar URL completa al citar)

- **PostgreSQL 18:** https://www.postgresql.org/docs/18/
- **MongoDB 8.0:** https://www.mongodb.com/docs/manual/
- **Valkey 9.1:** https://valkey.io/topics/
- **Meilisearch 1.48:** https://www.meilisearch.com/docs
- **DuckDB 1.5:** https://duckdb.org/docs/
- **Debezium 3.6:** https://debezium.io/documentation/
- **Redpanda:** https://docs.redpanda.com/
- **OpenTelemetry:** https://opentelemetry.io/docs/
- **Prometheus:** https://prometheus.io/docs/ · **Grafana:** https://grafana.com/docs/
- **k6:** https://grafana.com/docs/k6/latest/
- **Node.js 24 LTS:** https://nodejs.org/docs/latest-v24.x/api/
- **Fastify 5:** https://fastify.dev/docs/latest/
- **Zod:** https://zod.dev/
- **Testcontainers:** https://testcontainers.com/
- **pgBackRest:** https://pgbackrest.org/

### 10.3 Advertencias (heredadas de la guía legacy, vigentes acá)

- **Sobre citas.** Cuando se mencione un artículo, libro, video o post
  específico, se deja claro que URLs y títulos deben verificarse antes de
  publicarse; no se inventan números de página, DOIs ni identificadores de
  video (ver también §12 de esta guía).
- **No usar en el código principal** versiones distintas a las fijadas en el
  stack de la semilla (PostgreSQL 18.x, MongoDB 8.0.x, Valkey 9.1.x,
  Meilisearch 1.48.x, DuckDB 1.5.x, Debezium 3.6.x, Node 24 LTS). Las
  alternativas o versiones más nuevas aparecen solo como comparación o en
  una sección 🔥.

---

## 11. Sobre el dominio (ficticio, sin NDA)

Ágora es un dominio enteramente ficticio: una plataforma de venta de
entradas inventada para este curso. No hay confidencialidad que preservar ni
sistema real que disfrazar. El vocabulario del dominio (evento, asiento,
reserva, pedido, liquidación, escaneo) es estable y se fija en la tabla de
§4.2; no compite con ningún vocabulario "real" que haya que evitar.

La regla de idioma del código (§4) es una convención de calidad y de
realismo, no una cuestión de NDA.

---

## 12. Coherencia entre documentos

- **No contradecir fases anteriores.** Un consumidor de la Fase 8 no puede
  asumir un contrato de evento distinto del que la Fase 7 definió; el
  esquema versionado del evento manda.
- **No reescribir decisiones aprobadas** sin señalar explícitamente la
  incompatibilidad y por qué.
- **Fuentes de verdad, en orden:** (1) instrucciones del proyecto de la
  Fábrica de arranque, (2) `RUTA-NOSQL.md` (lista maestra), (3)
  `RUTA-NOSQL-FUNDAMENTOS.md`, (4) `10-el-arbitro-semilla.md`, (5) esta
  guía de estilo, (6) entregables aprobados de fases anteriores del curso,
  (7) decisiones explícitas del chat actual.
- **El diccionario de §4.2 es la costura del propio curso.** Si una fase
  necesita un término nuevo del dominio, se agrega ahí y se propaga hacia
  atrás si alguna fase anterior lo usó con otro nombre.
- Nombres de archivos, servicios, colecciones, tablas y campos se mantienen
  estables entre fases (en inglés, §4). Si algo se renombra, se documenta
  el cambio y se marca qué fases anteriores quedan desalineadas.

---

## 13. Post-mortems e incidentes

Cada incidente inyectado (Fases 8, 10 y 11 principalmente) sigue esta
estructura de ocho puntos:

1. Síntoma (lo que ve el usuario o el equipo de guardia).
2. Pasos de reproducción.
3. Evidencia observable (métricas de Prometheus, trazas de OpenTelemetry,
   `EXPLAIN` en Postgres, `explain()` en Mongo, `SLOWLOG` en Valkey, lag de
   consumidor en Redpanda — la que corresponda al motor implicado).
4. Causa raíz.
5. Corrección.
6. Prueba de regresión (incluida, cuando aplica, en `scripts/vs.ts`).
7. Prevención.
8. Post-mortem **sin culpabilización**: se analiza el sistema y la costura,
   nunca a la persona.

El tono baja un punto acá, como en el resto de la ruta: un post-mortem es
serio, aunque no acartonado.

---

## 14. Checklist rápido antes de dar por cerrado un `.md` del curso

- [ ] Sigue la plantilla de 9 secciones (o el formato reducido de apéndice).
- [ ] Tono cálido e informal, segunda persona **sin voseo**, humor con
      moderación y bajo en las zonas de dinero y de pérdida de datos.
- [ ] Todo el código corre con las versiones fijadas del stack.
- [ ] Identificadores, endpoints, colecciones/tablas, campos, constantes y
      eventos de la costura en inglés (§4).
- [ ] Comentarios de código y textos de interfaz en español, sin voseo
      (§4.3).
- [ ] No contradice ninguna fase anterior; respeta el diccionario de §4.2.
- [ ] Todo "vs" fue producido por `scripts/vs.ts` y tiene fecha, versión de
      motor y máquina en `BENCHMARKS.md`; ningún "vs" está narrado.
- [ ] Si la fase suma un motor, la ficha de factura (§7.4) está completa en
      `FACTURA.md`.
- [ ] Usa el vocabulario de callouts (📝 📚 ⚠️ 💡 💾) y los recuadros del
      esqueleto compartido (🪞 🩻 ⚰️ 📖 ⚖️) donde aporten.
- [ ] Marca 💸 la deuda técnica intencional y 🔥 lo opcional.
- [ ] Tiene 20-40 ejercicios numerados con rangos 🟢🟡🟠🔴, con diversidad de
      nivel real (no concentrados en uno o dos rangos), y al menos cinco de
      diagnóstico.
- [ ] **Cierra con la sección `## 📚 Referencias`**, con URL completa, nota
      de versión, y advertencia de verificación donde corresponda —
      obligatoria en toda fase y todo apéndice, sin excepción.
- [ ] Explica el *porqué* de cada decisión de integración, no solo el cómo.
- [ ] Incluye "La señal de que quedó bien" en el cierre.
